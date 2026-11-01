// Unit-level simulations of the M02 acceptance: airplane/network back, kill mid-upload, duplicate push, Wi-Fi-only,
// 500×3 backoff, 400 → needs_attention, stale_version, Retry-After, per-user outbox, full-size purge, metrics, skew,
// triggers and the one-run-at-a-time rule.
// Requirement: docs/agents/acceptance/M02.md; PLAN §13 A1–A6, B3–B5, F1, G-profiles (timing against real network
//   profiles is Q01's BM-11/12); mobile-design.md §3; backend-design.md §3; D-005, D-011, D-029.
// Callers: `flutter test test/sync`.

import 'dart:async';
import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:dio/dio.dart';
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

  ResponseBody error(int status, String code, {Map<String, String> headers = const {}}) => json(
    {
      'error': {'code': code},
    },
    status: status,
    headers: headers,
  );

  test('airplane: saved with pending 1; network back: one run sends it and the count is 0', () async {
    final id = await w.save();
    expect(await w.pending(), 1);

    w.server.offline = true;
    await w.sync.runOnce();
    expect(await w.pending(), 1, reason: 'still waiting, nothing lost');
    expect((await w.entry(id)).status, EntryStatus.saved);

    w.server.offline = false;
    w.advance(const Duration(seconds: 3)); // past the first 2 s backoff
    await w.sync.runOnce();
    expect(await w.pending(), 0);
    expect((await w.entry(id)).status, EntryStatus.confirmed);
    expect(w.server.entries.keys, [id]);
  });

  test('kill mid-upload: after restart the photo is uploaded once more, one server row, no duplicate', () async {
    final id = await w.save(photos: 1);
    final hang = Completer<ResponseBody>();
    w.server.intercept = (r) => r.method == 'PUT' ? hang.future : null;
    unawaited(w.sync.runOnce()); // the app is killed while this PUT is in flight
    while (w.server.seen('PUT', 's3.test').isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    w.server.intercept = null;
    w.advance(const Duration(minutes: 6));
    final restarted = w.newService();
    await restarted.resetAfterKill();
    await restarted.runOnce();

    expect(w.server.seen('PUT', 's3.test'), hasLength(2), reason: 'the killed PUT and exactly one re-upload');
    expect(w.server.pushedIds, [id], reason: 'the entry was not pushed again');
    expect(w.server.entries, hasLength(1));
    expect((await w.mediaOf(id)).single.uploadStatus, UploadStatus.done);
    expect(await w.pending(), 0);
    await restarted.dispose();
  });

  test('duplicate push (entry already on the server) is confirmed, still one server row', () async {
    final id = await w.save();
    w.server.entries[id] = {'client_id': id, 'data': <String, Object?>{}};
    await w.sync.runOnce();
    expect((await w.entry(id)).status, EntryStatus.confirmed);
    expect(w.server.entries, hasLength(1));
    expect(await w.pending(), 0);
  });

  test('Wi-Fi-only: the entry is sent on mobile data, the photo waits for Wi-Fi; after confirm the full-size file '
      'is gone and the thumbnail remains', () async {
    await w.init(wifiOnlyPhotos: true);
    final id = await w.save(photos: 1);
    await w.sync.runOnce();
    expect((await w.entry(id)).status, EntryStatus.confirmed);
    expect(w.server.seen('PUT', 's3.test'), isEmpty);
    expect(await w.pending(), 1, reason: 'the photo is still waiting');

    w.network = 'wifi';
    await w.sync.runOnce();
    final media = (await w.mediaOf(id)).single;
    expect(w.server.seen('PUT', 's3.test'), hasLength(1));
    expect(w.server.seen('POST', '/v1/sync/photos/confirm'), hasLength(1));
    expect(media.uploadStatus, UploadStatus.done);
    expect(media.objectKey, 'evidence/fpo-1/${media.mediaId}.jpg');
    expect(media.purgedAt, isNotNull);
    expect(File(media.localPath).existsSync(), isFalse);
    expect(File(media.thumbPath).existsSync(), isTrue);
    expect(await w.pending(), 0);
    final put = w.server.seen('PUT', 's3.test').single;
    expect(put.headers['x-amz-checksum-sha256'], isNotEmpty);
    expect(put.headers.containsKey('Authorization'), isFalse);
  });

  test('500 three times → backoff 2, 4, 8 s (jitter fixed at the middle), then sent', () async {
    final id = await w.save();
    var fails = 3;
    w.server.intercept = (r) => r.path == '/v1/sync/push' && fails-- > 0 ? error(500, 'internal_error') : null;
    for (final seconds in [2, 4, 8]) {
      await w.sync.runOnce();
      final row = await w.outboxOf(id);
      expect(row.nextAttemptAt.difference(w.clock), Duration(seconds: seconds));
      expect(row.lastError, 'internal_error');
      await w.sync.runOnce(); // not due yet: nothing is sent
      w.advance(Duration(seconds: seconds));
    }
    await w.sync.runOnce();
    expect(w.server.seen('POST', '/v1/sync/push'), hasLength(4));
    expect(await w.pending(), 0);
  });

  test('400 → needs_attention with the error code, never retried', () async {
    final id = await w.save();
    w.server.intercept = (r) => r.path == '/v1/sync/push' ? error(400, 'validation_error') : null;
    await w.sync.runOnce();
    w.advance(const Duration(hours: 1));
    await w.sync.runOnce();
    final row = await w.outboxOf(id);
    expect((row.status, row.lastError), (OutboxStatus.needsAttention, 'validation_error'));
    expect((await w.entry(id)).status, EntryStatus.rejected);
    expect(w.server.seen('POST', '/v1/sync/push'), hasLength(1));
    expect(await w.pending(), 1, reason: 'entries never die; it stays visible');
  });

  test('a rejected entry needs attention; stale_version is retried once and the re-push answers duplicate', () async {
    final stale = await w.save();
    final bad = await w.save();
    var first = true;
    w.server.intercept = (r) {
      if (r.path != '/v1/sync/push' || !first) return null;
      first = false;
      w.server.entries[stale] = {'client_id': stale, 'data': <String, Object?>{}}; // the overlapping push won
      return json({
        'server_time': w.clock.toIso8601String(),
        'results': [
          {
            'client_id': stale,
            'status': 'rejected',
            'error': {'code': 'stale_version'},
          },
          {
            'client_id': bad,
            'status': 'rejected',
            'error': {'code': 'forbidden'},
          },
        ],
      });
    };
    await w.sync.runOnce();
    expect(
      ((await w.outboxOf(stale)).status, (await w.outboxOf(stale)).lastError),
      (OutboxStatus.waiting, 'stale_version'),
    );
    expect(
      ((await w.outboxOf(bad)).status, (await w.entry(bad)).status),
      (OutboxStatus.needsAttention, EntryStatus.rejected),
    );

    w.advance(const Duration(seconds: 2));
    await w.sync.runOnce();
    expect((await w.entry(stale)).status, EntryStatus.confirmed);
    expect(w.server.entries, hasLength(1));
  });

  test('M14: after a failed push the queue retries in order; a row in backoff holds back every later row', () async {
    final farmer = await w.saveEntry('farmer', {'name': 'Muthu'});
    final consent = await w.saveEntry('consent', {'farmer_id': 'f-new'});
    final plot = await w.saveEntry('plot', {'farmer_id': 'f-new'});
    var fails = 1;
    w.server.intercept = (r) => r.path == '/v1/sync/push' && fails-- > 0 ? error(500, 'internal_error') : null;
    await w.sync.runOnce();
    final waits = {
      for (final id in [farmer, consent, plot]) (await w.outboxOf(id)).nextAttemptAt,
    };
    expect(waits, hasLength(1), reason: 'one backoff for the whole batch');

    // Even when a later row is due before the farmer (the old per-row jitter), it must not overtake it.
    await w.db.outboxDao.markWaiting((await w.outboxOf(consent)).seq, backoff: Duration.zero, now: w.clock);
    await w.sync.runOnce();
    expect(w.server.seen('POST', '/v1/sync/push'), hasLength(1));

    w.advance(const Duration(seconds: 2));
    await w.sync.runOnce();
    expect(w.server.seen('POST', '/v1/sync/push'), hasLength(2));
    expect(w.server.pushedIds.skip(3), [farmer, consent, plot], reason: 'one batch, in order');
    expect(await w.pending(), 0);
  });

  test('M14: a missing-dependency rejection is retried once; a validation rejection is final', () async {
    final consent = await w.saveEntry('consent', {'farmer_id': 'f-new'});
    final plot = await w.saveEntry('plot', {'farmer_id': 'f-new'});
    var first = true;
    w.server.intercept = (r) {
      if (r.path != '/v1/sync/push' || !first) return null;
      first = false;
      return json({
        'server_time': w.clock.toIso8601String(),
        'results': [
          for (final (id, code) in [(consent, 'not_found'), (plot, 'validation_error')])
            {
              'client_id': id,
              'status': 'rejected',
              'error': {'code': code},
            },
        ],
      });
    };
    await w.sync.runOnce();
    expect((await w.outboxOf(consent)).status, OutboxStatus.waiting);
    expect((await w.outboxOf(plot)).status, OutboxStatus.needsAttention);

    w.advance(const Duration(seconds: 2));
    await w.sync.runOnce();
    expect((await w.entry(consent)).status, EntryStatus.confirmed);
    expect(w.server.pushedIds, [consent, plot, consent], reason: 'the plot is never resent');
  });

  test('429 honours Retry-After', () async {
    final id = await w.save();
    w.server.intercept = (r) =>
        r.path == '/v1/sync/push' ? error(429, 'rate_limited', headers: {'retry-after': '30'}) : null;
    await w.sync.runOnce();
    expect((await w.outboxOf(id)).nextAttemptAt.difference(w.clock), const Duration(seconds: 30));
  });

  test('D-029: only the signed-in user\'s rows are sent and counted; the other user\'s are stranded', () async {
    final mine = await w.save(photos: 1);
    final theirs = await w.save(owner: 'user-2');
    expect(await w.pending(), 2);
    expect(await w.db.outboxDao.strandedCount().first, 1);

    await w.sync.runOnce();
    expect(w.server.pushedIds, [mine]);
    expect(await w.pending(), 0);
    expect(await w.db.outboxDao.strandedCount().first, 1);

    await w.init(userId: 'user-2');
    expect(await w.pending(), 1);
    expect(await w.db.outboxDao.strandedCount().first, 0, reason: "user-1's rows are all confirmed");
    await w.sync.runOnce();
    expect(w.server.pushedIds, [mine, theirs]);
  });

  test('metrics: the ack metric is shipped in the next push and marked shipped; photo time recorded', () async {
    final a = await w.save(photos: 1);
    await w.sync.runOnce();
    final rows = await w.db.select(w.db.syncMetrics).get();
    expect(rows.single.entryId, a);
    expect((rows.single.networkType, rows.single.shipped), ('mobile', false));
    expect(rows.single.photoUploadMs, isNotNull);

    await w.save();
    await w.sync.runOnce();
    final second = w.server.seen('POST', '/v1/sync/push').last.body! as Map;
    expect(((second['metrics'] as List).single as Map)['entry_client_id'], a);
    expect((await w.db.select(w.db.syncMetrics).get()).first.shipped, isTrue);
  });

  test('clock skew over 10 minutes is recorded, under 10 minutes stored as 0', () async {
    await w.save();
    w.server.clock = () => w.clock.subtract(const Duration(minutes: 11));
    await w.sync.runOnce();
    expect(await w.db.syncStateDao.get('clock_skew_ms'), '${const Duration(minutes: 11).inMilliseconds}');
    w.server.clock = () => w.clock;
    await w.save();
    await w.sync.runOnce();
    expect(await w.db.syncStateDao.get('clock_skew_ms'), '0');
  });

  test('an expired upload URL is re-requested by re-pushing the entry (answered duplicate)', () async {
    final id = await w.save(photos: 1);
    w.server.intercept = (r) => r.method == 'PUT' ? error(503, 'unavailable') : null;
    await w.sync.runOnce();
    w.server.intercept = null;
    w.advance(const Duration(minutes: 20)); // the 15-min URL has expired
    await w.sync.runOnce();
    expect(w.server.pushedIds, [id, id], reason: 'second push only to get a fresh URL');
    expect((await w.mediaOf(id)).single.uploadStatus, UploadStatus.done);
  });

  test('fast uploads run three in parallel, slow ones one at a time', () async {
    await w.db.syncStateDao.set('upload_kbps', '5000');
    final id = await w.save(photos: 3);
    var inFlight = 0;
    var most = 0;
    w.server.intercept = (r) async {
      if (r.method != 'PUT') return null;
      most = (++inFlight) > most ? inFlight : most;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      inFlight--;
      return null;
    };
    await w.sync.runOnce();
    expect(most, 3);
    expect((await w.mediaOf(id)).every((m) => m.uploadStatus == UploadStatus.done), isTrue);
  });

  test(
    'triggers: a save syncs after 500 ms when reachable, a connectivity change probes, runs never overlap',
    () async {
      await w.sync.start(); // app open: nothing to send yet
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(w.server.seen('POST', '/v1/sync/push'), isEmpty);

      await w.save();
      await w.save();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(w.server.seen('POST', '/v1/sync/push'), isEmpty, reason: 'debounced');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(w.server.seen('POST', '/v1/sync/push'), hasLength(1), reason: 'both saves in one push');

      w.reachable = false;
      await w.save();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(w.server.seen('POST', '/v1/sync/push'), hasLength(1), reason: 'unreachable: no run');
      w.reachable = true;
      w.networkChanges.add('wifi');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(w.server.seen('POST', '/v1/sync/push'), hasLength(2));

      await w.save();
      await Future.wait([w.sync.sendNow(), w.sync.sendNow()]);
      expect(
        w.server.seen('POST', '/v1/sync/push'),
        hasLength(3),
        reason: 'one run at a time; the second finds nothing',
      );
    },
  );
}
