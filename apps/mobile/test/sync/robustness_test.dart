// Tests for the engine's robustness rules: backoff never overflows, a user switch resets the per-user sync state, a
// killed row is retried on the next run, a failed probe is retried once, sign-in starts a sync, a refused envelope
// does not poison later pushes with its metrics, the two isolates do not mark a confirmed photo missing, the 256 KB
// trim on the real body, and the `secure` marker on every sync call.
// Requirement: PLAN §13 A1, A4, A6, F1; mobile-design.md §3; D-029; review M02-r1 P1-1, P1-3, P2-1, P2-3..P2-6,
//   P3-10, P3-11.
// Callers: `flutter test test/sync`.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/connectivity.dart';
import 'package:agritrace/core/sync/metrics.dart';
import 'package:agritrace/core/sync/pull_service.dart';
import 'package:agritrace/core/sync/retry.dart';
import 'package:agritrace/core/sync/sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late World w;
  setUp(() async {
    w = World();
    await w.init();
  });
  tearDown(() => w.dispose());

  test('backoff stays within (0, 5 min] after 60 failures (no int overflow)', () {
    for (final attempts in [54, 55, 60, 1000]) {
      final d = backoff(attempts, Random(0));
      expect(d, greaterThan(Duration.zero));
      expect(d, lessThanOrEqualTo(maxBackoff));
    }
  });

  test('D-029: a new user on the phone starts with no pull cursor and no bundles of the previous user', () async {
    w.server.pullPages.add((const [], 'c2', false));
    w.server.reference['plots'] = (41, '"a"', {'plots': <Object?>[]});
    await w.sync.runOnce();
    expect(await w.db.syncStateDao.get(pullCursorKey), 'c2');
    expect(await w.db.refBundlesDao.versions(), {'plots': 41});

    await w.init(userId: 'user-2');
    w.server.reference['plots'] = (
      41,
      '"b"',
      {
        'plots': [
          {
            'id': 'plot-b',
            'farmer_id': 'farmer-b',
            'pin': {'lat': 9.5, 'lon': 78.1},
            'declared_area': '2',
            'area_unit': 'acre',
          },
        ],
      },
    );
    await w.sync.runOnce();
    expect(w.server.seen('GET', '/v1/sync/pull').last.query.containsKey('cursor'), isFalse);
    expect(w.server.seen('GET', '/v1/sync/reference').last.query.containsKey('since'), isFalse);
    expect((await w.db.refBundlesDao.get('plots'))!.etag, '"b"');
    expect(await w.db.syncStateDao.get(syncUserKey), 'user-2');
  });

  test('a row left sending by a quick kill is retried by the next run once 5 min have passed', () async {
    final id = await w.save();
    await w.db.outboxDao.markSending([(await w.outboxOf(id)).seq], w.clock);
    w.advance(const Duration(minutes: 6));
    await w.sync.runOnce(); // a run, not a restart
    expect(w.server.pushedIds, [id]);
    expect(await w.pending(), 0);
  });

  test('a failed probe is tried once more after 10 s', () {
    fakeAsync((async) {
      w.reachable = false;
      unawaited(w.sync.start());
      async.flushMicrotasks();
      expect(w.probes, 1);
      w.reachable = true;
      async.elapse(probeRetry);
      async.flushMicrotasks();
      expect(w.probes, 2);
      expect(w.server.seen('GET', '/v1/sync/pull'), hasLength(1), reason: 'the retry ran a sync');
      async.elapse(const Duration(minutes: 1));
      expect(w.probes, 2, reason: 'no probe loop');
    });
  });

  test('signing in starts a sync (first pull and bundles do not wait for a resume)', () async {
    await w.db.delete(w.db.sessionTable).go();
    await w.sync.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(w.server.seen('GET', '/v1/sync/reference'), isEmpty);
    await w.init();
    // 500 ms debounce, then a whole run (push, pull, photos, bundles); poll instead of guessing the run's length.
    for (var i = 0; i < 40 && w.server.seen('GET', '/v1/sync/reference').isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(w.server.seen('GET', '/v1/sync/reference'), hasLength(1));
  });

  test('a refused envelope drops its metrics, so the next push is not refused again', () async {
    await w.db.syncMetricsDao.record(SyncMetricsCompanion.insert(entryId: 'old', savedAt: t0, networkType: 'x'));
    var first = true;
    w.server.intercept = (r) {
      if (r.path != '/v1/sync/push' || !first) return null;
      first = false;
      return json({
        'error': {'code': 'validation_error'},
      }, status: 422);
    };
    await w.save();
    await w.sync.runOnce();
    await w.save();
    await w.sync.runOnce();
    final second = w.server.seen('POST', '/v1/sync/push').last.body! as Map;
    expect(second['metrics'], isEmpty);
    expect(w.server.entries, hasLength(1));
  });

  test('photo time adds PUT failures to the ack row and never writes a negative count', () async {
    final id = await w.save();
    await w.sync.runOnce(); // ack row with failures 0
    await recordPhotoTime(w.contextFor(), id, 120, -1);
    final row = await w.db.select(w.db.syncMetrics).getSingle();
    expect((row.photoUploadMs, row.failures), (120, 0));
  });

  test('a photo the other isolate already confirmed and deleted is not marked file_missing', () async {
    final id = await w.save(photos: 2);
    final media = await w.mediaOf(id);
    var once = true;
    w.server.intercept = (r) async {
      if (r.method != 'PUT' || !once) return null;
      once = false;
      // Meanwhile the WorkManager isolate uploads, confirms and purges the second photo.
      final other = media.last;
      await w.db.mediaDao.setUploadState(
        other.mediaId,
        MediaCompanion(uploadStatus: const Value(UploadStatus.done), purgedAt: Value(w.clock)),
      );
      await w.db.outboxDao.markConfirmed([(await w.outboxOf(other.mediaId)).seq]);
      File(other.localPath).deleteSync();
      return null;
    };
    await w.sync.runOnce();
    final row = await w.outboxOf(media.last.mediaId);
    expect((row.status, row.lastError), (OutboxStatus.confirmed, null));
    expect((await w.mediaOf(id)).every((m) => m.uploadStatus == UploadStatus.done), isTrue);
    expect(await w.pending(), 0);
  });

  test(
    '256 KB on the real body: entries that fit by payload but not with the envelope split; 300 KB goes alone',
    () async {
      // nextBatch measures payloads only (2 × 124 KB fits); 100 unshipped metrics push the real body over 256 KB.
      for (var i = 0; i < 100; i++) {
        await w.db.syncMetricsDao.record(SyncMetricsCompanion.insert(entryId: 'm$i', savedAt: t0, networkType: 'x'));
      }
      final big = {'note': 'x' * (124 * 1024)};
      await w.saveEntry('harvest', big, lotId: 'lot-1');
      await w.saveEntry('harvest', big, lotId: 'lot-1');
      await w.sync.runOnce();
      final pushes = w.server.seen('POST', '/v1/sync/push');
      expect(pushes.map((p) => ((p.body! as Map)['entries'] as List).length), [1, 1]);

      final c = await w.saveEntry('harvest', {'note': 'x' * (300 * 1024)}, lotId: 'lot-1');
      w.server.intercept = (r) => r.path == '/v1/sync/push'
          ? json({
              'error': {'code': 'payload_too_large'},
            }, status: 413)
          : null;
      await w.sync.runOnce();
      expect(w.server.pushedIds.last, c, reason: 'sent alone, not blocking the queue');
      expect((await w.outboxOf(c)).lastError, 'payload_too_large');
    },
  );

  test('every /v1/sync/* call carries the AccessToken marker; the probe and the presigned PUT do not', () async {
    await w.save(photos: 1);
    w.server.pullPages.add((const [], 'c1', false));
    await w.sync.runOnce();
    final calls = w.server.requests.where((r) => r.path.startsWith('/v1/sync/')).toList();
    expect(calls.map((r) => r.path).toSet(), {
      '/v1/sync/push',
      '/v1/sync/pull',
      '/v1/sync/photos/confirm',
      '/v1/sync/reference',
    });
    expect(calls.every((r) => r.secure), isTrue);
    expect(w.server.seen('PUT', 's3.test').single.secure, isFalse);
    final before = w.server.requests.length;
    expect(await isReachable(w.sync.api), isTrue);
    expect(w.server.requests.skip(before).single.secure, isFalse, reason: 'healthz is public');
  });
}
