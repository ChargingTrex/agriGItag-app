// Photo phase: upload photos and voice notes of confirmed entries by single presigned PUT (SHA-256 bound), 1–3 at a
// time by measured upload speed, confirm them with `POST /v1/sync/photos/confirm`, then delete the full-size file
// and keep the thumbnail.
// Requirement: FR4, FR61; PLAN §13 A5 (1–3 parallel uploads by measured speed, ≥ 1 Mbps → 3), B3 (presigned PUT +
//   SHA-256, whole-PUT retry), B4 (delete full-size after confirm, keep thumbnail), F1 (photo upload time);
//   mobile-design.md §3; backend-design.md §3 "Photo upload and confirm"; Arch §Offline-first "Small first, photos
//   second"; D-011, D-029.
// Callers: sync_service.dart (uploadPhotos each run unless Wi-Fi-only blocks it); tests.

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/daos/media_dao.dart';
import '../db/database.dart';
import 'metrics.dart';
import 'outbox_processor.dart';
import 'retry.dart';
import 'sync_context.dart';

/// Measured upload speed at or above which three PUTs run in parallel instead of one (PLAN §13 A5), in kbit/s.
const fastUploadKbps = 1000;

/// SyncState key holding the speed of the last successful PUT in kbit/s.
const uploadKbpsKey = 'upload_kbps';

/// Uploads and confirms the signed-in user's due media.
///
/// [c] is the run. Media whose upload URL is missing or about to expire (judged on the server's clock) are first
/// re-requested by re-pushing their entries (the server answers `duplicate` with fresh URLs). Stops before the next
/// authed call or PUT when another user signed in (D-029). Returns when done; throws only on database errors.
/// Side effects: HTTP PUTs and confirm calls; media and outbox rows change; full-size files are deleted; the
/// measured speed and photo metrics are stored.
Future<void> uploadPhotos(SyncContext c) async {
  var due = await c.db.mediaDao.pendingUploads(ownerUserId: c.userId, now: c.now());
  // `expires_at` is server time: compare it with the server's clock (phone clock minus the skew _recordSkew stored),
  // so a phone running fast does not see every fresh URL as stale.
  final skew = Duration(milliseconds: int.tryParse(await c.db.syncStateDao.get(clockSkewKey) ?? '') ?? 0);
  bool usable(MediaUpload u) =>
      u.media.uploadUrl != null &&
      u.media.uploadUrlExpiresAt!.isAfter(c.now().subtract(skew).add(const Duration(minutes: 1)));
  final stale = due.where((u) => !usable(u)).toList();
  if (stale.isNotEmpty) {
    if (await c.userChanged()) return;
    final ids = {for (final u in stale) u.media.entryId};
    final entries = await (c.db.select(c.db.entries)..where((e) => e.entryId.isIn(ids))).get();
    try {
      await refreshUploadUrls(c, entries);
    } catch (e) {
      await Future.wait(stale.map((u) => _failed(c, u, e)));
    }
    due = await c.db.mediaDao.pendingUploads(ownerUserId: c.userId, now: c.now());
  }

  final ready = due.where(usable).toList();
  final msByEntry = <String, int>{};
  var i = 0;
  while (i < ready.length) {
    if (await c.userChanged()) return;
    final n = await _parallelism(c);
    await Future.wait(ready.skip(i).take(n).map((u) => _put(c, u, msByEntry)));
    i += n;
  }
  await _confirm(c, msByEntry);
}

/// 3 when the last measured PUT ran at ≥ [fastUploadKbps], else 1 (also before the first measurement).
/// Returns the count; throws nothing.
Future<int> _parallelism(SyncContext c) async =>
    (int.tryParse(await c.db.syncStateDao.get(uploadKbpsKey) ?? '') ?? 0) >= fastUploadKbps ? 3 : 1;

/// PUTs the full-size file of [u] to its presigned URL with the bound headers and adds the elapsed time to
/// [msByEntry]. Returns when done; throws only on database errors (HTTP and file errors go through [_failed]).
/// Side effects: outbox row `sending` → `sent`, media `uploading`; stores the measured speed.
Future<void> _put(SyncContext c, MediaUpload u, Map<String, int> msByEntry) async {
  final m = u.media;
  await c.db.outboxDao.markSending([u.row.seq], c.now());
  await c.db.mediaDao.setUploadState(m.mediaId, const MediaCompanion(uploadStatus: Value(UploadStatus.uploading)));
  final watch = Stopwatch()..start();
  try {
    final bytes = await File(m.localPath).readAsBytes();
    // DECISION D-011: one presigned PUT per file; the server signed Content-Type and the SHA-256, so these headers
    //   are rebuilt exactly as evidence.upload_instruction sends them (no extra column for headers).
    //   ADV: storage refuses bytes that differ from the promised digest.  COMPROMISE: a dropped PUT restarts the
    //   whole ~300 KB file.
    await c.uploads.put<void>(
      m.uploadUrl!,
      data: Stream.value(bytes),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentTypeOf(m),
          Headers.contentLengthHeader: bytes.length,
          'x-amz-checksum-sha256': base64.encode([
            for (var i = 0; i < m.sha256.length; i += 2) int.parse(m.sha256.substring(i, i + 2), radix: 16),
          ]),
        },
      ),
    );
    watch.stop();
    await c.db.outboxDao.markSent([u.row.seq]);
    msByEntry[m.entryId] = (msByEntry[m.entryId] ?? 0) + watch.elapsedMilliseconds;
    // bits per millisecond = kbit/s.
    await c.db.syncStateDao.set(uploadKbpsKey, '${bytes.length * 8 ~/ (watch.elapsedMilliseconds + 1)}');
  } catch (e) {
    await _failed(c, u, e);
  }
}

/// Applies the retry policy to [u] after [error]. A 403 from storage means the URL expired or no longer matches:
/// the URL is dropped so the next run asks for a fresh one. A missing local file can never upload and needs an
/// officer (`file_missing`), unless the other isolate (foreground vs WorkManager) confirmed the photo and deleted the
/// file meanwhile (`purgedAt` set, which only happens after confirm): then this run's in-flight marks are undone
/// (media done, outbox confirmed). Returns when written; throws nothing. Side effect: one log line.
Future<void> _failed(SyncContext c, MediaUpload u, Object error) async {
  final m = u.media;
  if (error is FileSystemException) {
    final current = await (c.db.select(c.db.media)..where((x) => x.mediaId.equals(m.mediaId))).getSingle();
    if (current.purgedAt != null) {
      await c.db.mediaDao.setUploadState(m.mediaId, const MediaCompanion(uploadStatus: Value(UploadStatus.done)));
      await c.db.outboxDao.markConfirmed([u.row.seq]);
      return;
    }
  }
  final code = error is FileSystemException ? 'file_missing' : errorCode(error);
  final action = error is FileSystemException ? FailureAction.attention : classify(error);
  final expired = error is DioException && error.response?.statusCode == 403 && error.requestOptions.method == 'PUT';
  await c.db.mediaDao.setUploadState(
    m.mediaId,
    MediaCompanion(
      uploadStatus: const Value(UploadStatus.failed),
      uploadUrl: expired ? const Value(null) : const Value.absent(),
    ),
  );
  if (action == FailureAction.attention && !expired) {
    await c.db.outboxDao.markNeedsAttention(u.row.seq, code);
  } else {
    final wait = expired ? Duration.zero : backoff(u.row.attempts + 1, c.random, error);
    await c.db.outboxDao.markWaiting(u.row.seq, backoff: wait, now: c.now(), error: code);
  }
  developer.log('upload of ${m.mediaId} failed ($code)', name: 'agritrace.sync');
}

/// Confirms every PUT-done media of the user (this run's and any left from a failed confirm), 50 per call.
/// `received` → done, outbox confirmed, full-size file deleted (thumbnail kept), photo time recorded from
/// [msByEntry]; `missing` → back to pending without URL, so it is re-requested and uploaded again. A failed call
/// leaves the rows `sent` for the next run. Returns when done; throws only on database errors.
Future<void> _confirm(SyncContext c, Map<String, int> msByEntry) async {
  final sent = await c.db.mediaDao.awaitingConfirm(c.userId);
  for (var i = 0; i < sent.length; i += 50) {
    if (await c.userChanged()) return;
    final chunk = {for (final u in sent.skip(i).take(50)) u.media.mediaId: u};
    final List<Object?> results;
    try {
      final res = await c.api.post<List<Object?>>(
        '/v1/sync/photos/confirm',
        data: {
          'photos': [
            for (final id in chunk.keys) {'client_id': id},
          ],
        },
        options: SyncContext.authed,
      );
      results = res.data!;
    } catch (e) {
      developer.log('photo confirm failed (${errorCode(e)}); retried next run', name: 'agritrace.sync');
      return;
    }
    for (final r in results.cast<Map<String, Object?>>()) {
      final u = chunk[r['client_id']];
      if (u == null) continue;
      if (r['status'] == 'received') {
        await _received(c, u, msByEntry);
      } else {
        await c.db.mediaDao.setUploadState(
          u.media.mediaId,
          const MediaCompanion(uploadStatus: Value(UploadStatus.pending), uploadUrl: Value(null)),
        );
        await c.db.outboxDao.markWaiting(
          u.row.seq,
          backoff: backoff(u.row.attempts, c.random),
          now: c.now(),
          error: 'missing',
        );
      }
    }
  }
}

/// Settles a confirmed media [u]: done with its object key (the presigned URL's path), outbox confirmed, full-size
/// file deleted with the thumbnail kept (PLAN §13 B4), photo time recorded for its entry once. Returns when done;
/// throws nothing (a missing file is ignored by the purge).
Future<void> _received(SyncContext c, MediaUpload u, Map<String, int> msByEntry) async {
  final m = u.media;
  final key = m.uploadUrl == null ? null : Uri.parse(m.uploadUrl!).path.replaceFirst('/', '');
  await c.db.mediaDao.setUploadState(
    m.mediaId,
    // The presigned URL is dropped: it is only needed until the confirm (kill-safety).
    MediaCompanion(uploadStatus: const Value(UploadStatus.done), objectKey: Value(key), uploadUrl: const Value(null)),
  );
  await c.db.outboxDao.markConfirmed([u.row.seq]);
  await c.db.mediaDao.purgeFullSize(m.mediaId, now: c.now());
  final ms = msByEntry.remove(m.entryId);
  if (ms != null) await recordPhotoTime(c, m.entryId, ms, u.row.attempts - 1);
}
