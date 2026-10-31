// Push phase: send the signed-in user's saved entries to `POST /v1/sync/push` oldest first, in batches of at most 50
// entries and 256 KB, and apply each entry's result (accepted / duplicate → confirmed with upload URLs; rejected →
// needs_attention; stale_version → one more try).
// Requirement: FR4; PLAN §13 A2 (tick only on server ack), A3 (client-UUID idempotency), A4 (≤ 50 entries or
//   256 KB), A6 (retry policy), F1 (`metrics[]`); mobile-design.md §3; backend-design.md §3 (envelope, per-entry
//   results); Arch §Offline-first "Outbox queue"; D-005, D-029.
// Callers: sync_service.dart (pushEntries each run), photo_uploader.dart (refreshUploadUrls); tests.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/daos/entries_dao.dart' show undoEntryType;
import '../db/daos/outbox_dao.dart';
import '../db/database.dart';
import 'enum_wire_names.dart';
import 'metrics.dart';
import 'retry.dart';
import 'sync_context.dart';

/// The server's push body limit (backend-design.md §3, PLAN §13 A4).
const maxPushBytes = 256 * 1024;

/// Payload keys that belong to the event version itself, not to its typed payload; lifted out of `payloadJson`
/// when present (feature screens store them there because Entries has no column for them).
const _versionKeys = ['occurred_on', 'occurred_end_on', 'batch_id', 'reason_text'];

/// Pushes the signed-in user's due entries, batch after batch, until none is due or a request fails.
///
/// [c] is the run. Returns when done; throws only on database errors. Side effects: outbox, entry, media and metric
/// rows change; one or more HTTP requests.
Future<void> pushEntries(SyncContext c) async {
  while (true) {
    final batch = await c.db.outboxDao.nextBatch(ownerUserId: c.userId, now: c.now());
    if (batch.isEmpty || !await _pushBatch(c, batch)) return;
  }
}

/// Re-pushes already confirmed [entries] so the server, answering `duplicate`, hands out fresh upload URLs for the
/// photos it does not have yet (backend-design.md §3). Their outbox rows are not touched.
///
/// Returns when the URLs are stored. Throws [DioException] (or another error for an unparseable body) when the
/// request fails; the caller applies the retry policy to the photos.
Future<void> refreshUploadUrls(SyncContext c, List<Entry> entries) async {
  final data = await _post(c, [for (final e in entries) await entryToWire(c.db, e)], const []);
  for (final r in (data['results'] as List).cast<Map<String, Object?>>()) {
    if (r['status'] != 'rejected') await _storeUploads(c, r['client_id'] as String, r['photo_uploads']);
  }
}

/// Builds the push entry (`SyncEntry`) for [e], reading its media and, for an undo, the version it undoes from [db].
///
/// Entry types `plot`, `consent`, `quality_reading` and `flag_resolution` are sent as that kind with the payload as
/// `data`; every other type is an `event_version` built from the columns and the payload. Returns the JSON map.
/// Throws [FormatException] when `payloadJson` is not a JSON object and [StateError] when an undo's original is
/// missing (cannot happen: entries are never deleted).
Future<Map<String, Object?>> entryToWire(AppDatabase db, Entry e) async {
  var payload = (jsonDecode(e.payloadJson) as Map).cast<String, Object?>();
  final kind = fromWire(SyncKind.values, e.entryType) ?? SyncKind.eventVersion;
  if (kind != SyncKind.eventVersion) return {'client_id': e.entryId, 'kind': wireName(kind), 'data': payload};

  var eventType = e.entryType;
  if (e.entryType == undoEntryType) {
    // The server stores an undo as a full version of the same type; the phone's undo row carries no payload.
    final original = await (db.select(db.entries)..where((o) => o.entryId.equals(e.supersedesEntryId!))).getSingle();
    eventType = original.entryType;
    payload = (jsonDecode(original.payloadJson) as Map).cast<String, Object?>();
  }
  final lifted = {for (final k in _versionKeys) k: payload.remove(k)};
  final media = await (db.select(db.media)..where((m) => m.entryId.equals(e.entryId))).get();
  final change = e.version == 1
      ? ChangeKind.create
      : (e.entryType == undoEntryType ? ChangeKind.undo : ChangeKind.correct);
  return {
    'client_id': e.entryId,
    'kind': wireName(SyncKind.eventVersion),
    'data': {
      'event_id': e.rootId,
      'version_no': e.version,
      'change_kind': wireName(change),
      'subject_type': e.lotId != null ? 'lot' : 'batch',
      'lot_id': e.lotId,
      'batch_id': lifted['batch_id'],
      'plot_id': e.plotId,
      'event_type': eventType,
      'instance_no': e.instanceNo,
      'occurred_on': lifted['occurred_on'] ?? e.deviceTime.toLocal().toIso8601String().substring(0, 10),
      'occurred_end_on': lifted['occurred_end_on'],
      'payload': payload,
      'clocks': {'device_time': _iso(e.deviceTime), 'gps_time': _iso(e.gpsTime)},
      'gps': e.lat == null || e.lng == null ? null : {'lat': e.lat, 'lon': e.lng, 'accuracy_m': e.accuracyM},
      'photos': [
        for (final m in media)
          {
            'client_id': m.mediaId,
            'sha256': m.sha256,
            'size_bytes': m.bytes,
            'content_type': contentTypeOf(m),
            'exif_taken_at': _iso(m.capturedAt),
            'exif_gps': m.lat == null || m.lng == null ? null : {'lat': m.lat, 'lon': m.lng},
          },
      ],
      'reason_code': e.reasonCode,
      'reason_text': lifted['reason_text'],
    },
  };
}

/// MIME type of [m] as the server expects it: JPEG for photos, `audio/ogg` for `.ogg` voice notes (Android 10+),
/// `audio/mp4` for `.m4a` (iOS, Android 8–9). Returns the type; throws nothing.
String contentTypeOf(MediaFile m) =>
    m.kind != 'voice' ? 'image/jpeg' : (m.localPath.endsWith('.ogg') ? 'audio/ogg' : 'audio/mp4');

/// Pushes [batch] (trimmed to the 256 KB body limit) and applies the results. Returns false when the request
/// failed, so the caller stops for this run. Throws only on database errors.
Future<bool> _pushBatch(SyncContext c, List<OutboxBatchItem> batch) async {
  final wires = [for (final i in batch) await entryToWire(c.db, i.entry)];
  final metrics = await c.db.syncMetricsDao.unshipped();
  // nextBatch measures payloads only; the real body (clocks, photos, metrics) decides. One entry always goes, so an
  // oversized one gets its 413 and needs_attention instead of blocking the queue.
  var n = wires.length;
  while (n > 1 && utf8.encode(jsonEncode(_envelope(c, wires.sublist(0, n), metrics))).length > maxPushBytes) {
    n--;
  }
  final sent = batch.sublist(0, n);
  await c.db.outboxDao.markSending([for (final i in sent) i.row.seq], c.now());
  final Map<String, Object?> data;
  try {
    data = await _post(c, wires.sublist(0, n), metrics);
  } catch (e) {
    await _failed(c, sent, e);
    return false;
  }
  await c.db.syncMetricsDao.markShipped([for (final m in metrics) m.id]);
  await _applyResults(c, sent, data);
  return true;
}

/// Sends one push envelope with [entries] and [metrics]. Returns the response body. Throws [DioException] on a
/// network error or a non-2xx answer, and [TypeError] when the body is not a JSON object. Side effect: records the
/// clock skew (see [_recordSkew]).
Future<Map<String, Object?>> _post(SyncContext c, List<Map<String, Object?>> entries, List<SyncMetric> metrics) async {
  final res = await c.api.post<Map<String, Object?>>(
    '/v1/sync/push',
    data: jsonEncode(_envelope(c, entries, metrics)),
    options: SyncContext.authed,
  );
  final data = res.data!;
  await _recordSkew(c, DateTime.parse(data['server_time'] as String));
  return data;
}

/// The push envelope (`SyncPushIn`) for [entries] and [metrics]. Returns the JSON map; throws nothing.
///
/// DECISION D-003: the sync engine posts JSON maps through the generated client's dio instead of the generated
///   built_value models; test/sync/contract_test.dart pins every key against packages/openapi/openapi.json.
///   ADV: the entry payload is stored as JSON and goes out as JSON (no 11-variant model round trip); `/sync/pull`
///   and `/sync/reference` (B07) are not in main's spec yet, so they could not use generated methods anyway.
///   COMPROMISE: the compiler does not check these keys; the contract test does, against the committed spec.
Map<String, Object?> _envelope(SyncContext c, List<Map<String, Object?>> entries, List<SyncMetric> metrics) => {
  'device_id': c.deviceId,
  'app_version': c.appVersion,
  'device_time': _iso(c.now()),
  'metrics': [for (final m in metrics) metricToWire(m)],
  'entries': entries,
};

/// Applies the per-entry results in [data] to the [sent] rows; a row the server did not answer (cannot happen
/// with B06) waits for a retry. Returns when written; throws only on database errors or an unparseable body.
Future<void> _applyResults(SyncContext c, List<OutboxBatchItem> sent, Map<String, Object?> data) async {
  final serverTime = DateTime.parse(data['server_time'] as String);
  final open = {for (final i in sent) i.entry.entryId: i};
  for (final r in (data['results'] as List).cast<Map<String, Object?>>()) {
    final item = open.remove(r['client_id']);
    if (item == null) continue;
    final id = item.entry.entryId;
    if (r['status'] == 'accepted' || r['status'] == 'duplicate') {
      await c.db.entriesDao.markConfirmed(id, serverTime);
      await _storeUploads(c, id, r['photo_uploads']);
      await recordAck(c, item);
      continue;
    }
    final code = ((r['error'] as Map?)?['code'] as String?) ?? 'rejected';
    // DECISION D-005: `stale_version` is retried once. A second push of the same client id (foreground and
    //   background isolates can overlap) may lose the version check before the first one commits; the retry then
    //   answers `duplicate`. A second `stale_version` is a real conflict (someone else took the number).
    //   ADV: no needs_attention for a race the server would resolve itself.  COMPROMISE: a real conflict waits one
    //   backoff longer before an officer sees it.
    if (code == 'stale_version' && item.row.lastError != code) {
      await c.db.outboxDao.markWaiting(
        item.row.seq,
        backoff: backoff(item.row.attempts + 1, c.random),
        now: c.now(),
        error: code,
      );
    } else {
      await c.db.entriesDao.markRejected(id, code);
    }
  }
  for (final item in open.values) {
    await c.db.outboxDao.markWaiting(
      item.row.seq,
      backoff: backoff(item.row.attempts + 1, c.random),
      now: c.now(),
      error: 'no_result',
    );
  }
}

/// Stores the presigned [uploads] (`photo_uploads` of a result) on the media of [entryId]. A media row the server
/// did not list is already in storage (a `duplicate` lists only photos still owed), so its outbox row moves to
/// `sent` and the next `/sync/photos/confirm` settles it. Returns when written; throws nothing.
Future<void> _storeUploads(SyncContext c, String entryId, Object? uploads) async {
  final listed = {for (final u in (uploads as List? ?? const []).cast<Map<String, Object?>>()) u['photo_client_id']: u};
  final media = await (c.db.select(c.db.media)..where((m) => m.entryId.equals(entryId))).get();
  for (final m in media.where((m) => m.uploadStatus != UploadStatus.done)) {
    final u = listed[m.mediaId];
    if (u != null) {
      await c.db.mediaDao.setUploadState(
        m.mediaId,
        MediaCompanion(
          uploadUrl: Value(u['url'] as String),
          uploadUrlExpiresAt: Value(DateTime.parse(u['expires_at'] as String)),
        ),
      );
      continue;
    }
    final rows =
        await (c.db.select(c.db.outbox)..where(
              (o) =>
                  o.kind.equalsValue(OutboxKind.media) &
                  o.refId.equals(m.mediaId) &
                  o.status.equalsValue(OutboxStatus.waiting),
            ))
            .get();
    await c.db.outboxDao.markSent([for (final o in rows) o.seq]);
  }
}

/// Applies the retry policy (retry.dart) to the [sent] rows after the push failed with [error]: retryable and
/// session errors wait for their backoff; other 4xx reject every entry of the batch with the error code (the
/// server refused the envelope). Returns when written; throws nothing. Side effect: one log line.
Future<void> _failed(SyncContext c, List<OutboxBatchItem> sent, Object error) async {
  final code = errorCode(error);
  if (classify(error) == FailureAction.attention) {
    for (final i in sent) {
      await c.db.entriesDao.markRejected(i.entry.entryId, code);
    }
    developer.log('push refused ($code): ${sent.length} entries need attention', name: 'agritrace.sync');
    return;
  }
  for (final i in sent) {
    final wait = backoff(i.row.attempts + 1, c.random, error);
    await c.db.outboxDao.markWaiting(i.row.seq, backoff: wait, now: c.now(), error: code);
    developer.log(
      'push failed ($code); entry ${i.entry.entryId} retries in ${wait.inMilliseconds} ms',
      name: 'agritrace.sync',
    );
  }
}

/// Records the clock skew when the phone clock and [serverTime] differ by more than 10 minutes (mobile-design.md
/// §3), else stores 0. Returns when written; throws nothing.
Future<void> _recordSkew(SyncContext c, DateTime serverTime) async {
  final skew = c.now().difference(serverTime);
  final value = skew.abs() > const Duration(minutes: 10) ? skew.inMilliseconds : 0;
  await c.db.syncStateDao.set('clock_skew_ms', '$value');
}

/// [t] as ISO 8601 UTC with `Z` (the server refuses naive timestamps), or null. Throws nothing.
String? _iso(DateTime? t) => t?.toUtc().toIso8601String();
