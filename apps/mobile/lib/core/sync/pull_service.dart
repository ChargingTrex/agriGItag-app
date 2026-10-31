// Pull phase: read server-side changes with a cursor (`GET /v1/sync/pull`) and upsert them into the offline store:
// lots, flags, event status, and photos the server still waits for.
// Requirement: FR4; mobile-design.md §3 ("then pull with cursor"); backend-design.md §3 `GET /v1/sync/pull`;
//   docs/api/conventions.md "Pull" (B07: changes upsert by `data.id`, opaque cursor, `photo_pending` on the last
//   page, ~30 s visibility lag); Arch §Offline-first; D-005, D-029.
// Callers: sync_service.dart (pullChanges each run, before the photo phase); tests.
// Data shapes: B07 `events/pull_service.py` (`_lot_json`, `_flag_json`, EventOut + subject_type/lot_id, photo_pending
//   `{id, event_id, event_version_id, status}`); decimals arrive as strings.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'sync_context.dart';

/// SyncState key holding the server's pull cursor.
const pullCursorKey = 'pull_cursor';

/// Most pages read in one run, so a server that always answers `has_more` cannot keep the run going forever.
const _maxPages = 50;

/// Pulls every change since the stored cursor, page by page (200 per page).
///
/// [c] is the run. Each page is applied in one transaction together with its new cursor, so a crash never skips a
/// change. A change that cannot be read is logged and skipped, so one bad record cannot block the cursor. An empty
/// page proves nothing about very fresh server writes (they appear about 30 s later); the next run picks them up.
/// A cursor the server refuses (422, e.g. after a server reset) is dropped, so the next run pulls from the start
/// (upserts are idempotent). Returns when `has_more` is false. Throws [DioException] when a request fails (the
/// caller logs it; the next run resumes from the stored cursor). Side effects: Lots, Flags, Entries, Media and
/// Outbox rows change.
Future<void> pullChanges(SyncContext c) async {
  for (var page = 0; page < _maxPages; page++) {
    final cursor = await c.db.syncStateDao.get(pullCursorKey);
    final Map<String, Object?> data;
    try {
      final res = await c.api.get<Map<String, Object?>>(
        '/v1/sync/pull',
        queryParameters: {'cursor': ?cursor, 'limit': 200},
        options: SyncContext.authed,
      );
      data = res.data!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 && cursor != null) {
        await (c.db.delete(c.db.syncState)..where((s) => s.key.equals(pullCursorKey))).go();
      }
      rethrow;
    }
    await c.db.transaction(() async {
      for (final change in (data['changes'] as List).cast<Map<String, Object?>>()) {
        try {
          await _apply(c, change['entity'] as String, (change['data'] as Map).cast<String, Object?>());
        } catch (e) {
          if (e is! TypeError && e is! FormatException) rethrow;
          developer.log('pull: skipped unreadable ${change['entity']} change ($e)', name: 'agritrace.sync');
        }
      }
      final next = data['next_cursor'];
      if (next is String) await c.db.syncStateDao.set(pullCursorKey, next);
    });
    if (data['has_more'] != true) return;
  }
}

/// Applies one change of [entity] with [d] (always an upsert by `id`). `intake` and `notification` have no local
/// table yet and are ignored. A lot the phone made ready keeps `ready_for_sale` while the server says open/drying and
/// its local packing entry is neither rejected nor undone. Returns when written; throws [TypeError] when a required
/// key is missing.
Future<void> _apply(SyncContext c, String entity, Map<String, Object?> d) async {
  final db = c.db;
  switch (entity) {
    case 'lot':
      final lotId = d['id'] as String;
      var status = d['status'] as String;
      // The server never sets `ready_for_sale` after a packing (only `POST /v1/lots/{id}/ready`, which no phone calls;
      // it re-runs the moisture gate at intake, Architect-Gate ruling 2026-10-31b §1). So a pull saying `open` or
      // `drying` keeps the phone's ready preview (D-006, M07 packing), else the Sell QR (M08) would vanish; a later
      // server status (`received`, `batched`, ...) still wins. Only while the packing that made it ready stands: once
      // that entry is rejected or undone the server's status wins too (M08 review of merge f2cfb60).
      if (status == 'open' || status == 'drying') {
        final local = await (db.select(db.lots)..where((l) => l.lotId.equals(lotId))).getSingleOrNull();
        final packing =
            await (db.select(db.entries)
                  ..where(
                    (e) =>
                        e.lotId.equals(lotId) &
                        e.entryType.equals('packing') &
                        e.status.isNotInValues([EntryStatus.rejected, EntryStatus.undone]),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (local?.status == 'ready_for_sale' && packing != null) status = 'ready_for_sale';
      }
      // Columns the pull does not carry (last moisture, QR payload) are left as they are.
      await db
          .into(db.lots)
          .insertOnConflictUpdate(
            LotsCompanion.insert(
              lotId: lotId,
              plotId: d['plot_id'] as String,
              farmerId: d['farmer_id'] as String,
              cropId: d['crop_id'] as String,
              season: d['season_label'] as String,
              status: status,
              kgHarvested: Value(_number(d['harvested_kg']) ?? 0),
              kgPacked: Value(_number(d['packed_kg']) ?? 0),
              updatedAt: c.now(),
            ),
          );
    case 'flag':
      final subject = d['subject_id'] as String;
      final type = d['subject_type'] as String;
      await db
          .into(db.flags)
          .insertOnConflictUpdate(
            FlagsCompanion.insert(
              flagId: d['id'] as String,
              farmerId: await _farmerOf(db, type, subject),
              entryId: Value(type == 'event' ? subject : null),
              plotId: Value(type == 'plot' ? subject : null),
              type: d['rule_code'] as String,
              severity: d['severity'] as String,
              status: d['status'] as String,
              detailJson: jsonEncode(d['details'] ?? const {}),
              resolvedReason: Value(d['resolution_reason_code'] as String?),
              updatedAt: DateTime.parse((d['resolved_at'] ?? d['raised_at']) as String),
            ),
          );
    case 'event':
      // Only the undo state can be applied: the pulled event carries no version id, so a version this phone has
      // never seen (an officer correction, history on a new phone) cannot become an Entries row yet (TODO, B07).
      if (d['status'] == 'undone') {
        await (db.update(db.entries)
              ..where((e) => e.rootId.equals(d['id'] as String) & e.status.equalsValue(EntryStatus.confirmed)))
            .write(const EntriesCompanion(status: Value(EntryStatus.undone)));
      }
    case 'photo_pending':
      await _reopenPhoto(c, d['id'] as String);
  }
}

/// The farmer a flag is about, from the local copy of its [subjectType] row [subjectId] (lot, plot or event);
/// empty when this phone does not hold that row. Returns the id; throws nothing.
Future<String> _farmerOf(AppDatabase db, String subjectType, String subjectId) async {
  final row = switch (subjectType) {
    'lot' => await (db.select(db.lots)..where((l) => l.lotId.equals(subjectId))).getSingleOrNull(),
    'plot' => await (db.select(db.plots)..where((p) => p.plotId.equals(subjectId))).getSingleOrNull(),
    'event' =>
      await (db.select(db.entries)
            ..where((e) => e.rootId.equals(subjectId))
            ..limit(1))
          .getSingleOrNull(),
    _ => null,
  };
  return switch (row) {
    Lot l => l.farmerId,
    Plot p => p.farmerId,
    Entry e => e.farmerId,
    _ => '',
  };
}

/// The server still waits for photo [mediaId] 24 h after its entry (`photo_pending`): when the full-size file is
/// still on the phone, the media goes back to pending without URL and its outbox row is due now, so the photo phase
/// that follows re-pushes the entry (answered `duplicate` with a fresh URL) and uploads again. A purged file cannot
/// be sent again and is only logged. Returns when written; throws nothing.
Future<void> _reopenPhoto(SyncContext c, String mediaId) async {
  final db = c.db;
  final m = await (db.select(db.media)..where((m) => m.mediaId.equals(mediaId))).getSingleOrNull();
  if (m == null || m.purgedAt != null) {
    developer.log('pull: photo $mediaId pending on the server but not on this phone', name: 'agritrace.sync');
    return;
  }
  await db.mediaDao.setUploadState(
    mediaId,
    const MediaCompanion(uploadStatus: Value(UploadStatus.pending), uploadUrl: Value(null)),
  );
  final rows = await (db.select(
    db.outbox,
  )..where((o) => o.kind.equalsValue(OutboxKind.media) & o.refId.equals(mediaId))).get();
  for (final o in rows) {
    await db.outboxDao.markWaiting(o.seq, backoff: Duration.zero, now: c.now(), error: 'photo_pending');
  }
}

/// A decimal sent as a string (B07), a number, or a `{"value": n, "unit": …}` quantity, as a double; null when
/// absent. Throws [TypeError] or [FormatException] for any other shape.
double? _number(Object? v) => switch (v) {
  null => null,
  num n => n.toDouble(),
  String s => double.parse(s),
  _ => _number((v as Map)['value']),
};
