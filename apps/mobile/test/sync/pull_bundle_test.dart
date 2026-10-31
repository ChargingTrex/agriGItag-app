// Tests for the pull and bundle phases: cursor paging, upserts of lots and flags, event undo, photo_pending
// re-upload, refused cursor; reference delta with every held part in `since`, 304, plots mirrored, gi_region absent.
// Requirement: PLAN §13 C2; mobile-design.md §3; backend-design.md §3; docs/api/conventions.md "Pull" and
//   "Reference bundles" (B07 shapes); D-006, D-016.
// Callers: `flutter test test/sync`.

import 'dart:convert';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/bundle_fetcher.dart';
import 'package:agritrace/core/sync/pull_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  late World w;
  setUp(() async {
    w = World();
    await w.init();
  });
  tearDown(() => w.dispose());

  test('pull pages: lots and flags upserted, undo applied, cursor stored after each page', () async {
    final id = await w.save();
    await w.sync.runOnce(); // confirmed locally
    final lot = {
      'id': 'lot-1',
      'farmer_id': 'farmer-1',
      'plot_id': 'plot-1',
      'crop_id': 'crop-1',
      'season_label': '2026-rabi',
      'code': 'L1',
      'status': 'drying',
      'harvested_kg': '195.000',
      'packed_kg': '0',
    };
    w.server.pullPages.addAll([
      (
        [
          {'entity': 'lot', 'op': 'upsert', 'data': lot},
          {
            'entity': 'notification',
            'op': 'upsert',
            'data': <String, Object?>{'id': 'n1'},
          },
        ],
        'c1',
        true,
      ),
      (
        [
          {'entity': 'lot', 'op': 'upsert', 'data': lot..['status'] = 'ready_for_sale'},
          {
            'entity': 'flag',
            'op': 'upsert',
            'data': {
              'id': 'flag-1',
              'subject_type': 'lot',
              'subject_id': 'lot-1',
              'rule_code': 'yield_over_ceiling',
              'severity': 'warn',
              'details': {'ratio': '1.4'},
              'status': 'open',
              'raised_at': t0.toIso8601String(),
              'resolution_reason_code': null,
              'resolved_at': null,
            },
          },
          {
            'entity': 'event',
            'op': 'upsert',
            'data': {'id': id, 'status': 'undone', 'version_no': 1},
          },
          {
            'entity': 'lot',
            'op': 'upsert',
            'data': <String, Object?>{'id': 'broken'},
          },
        ],
        'c2',
        false,
      ),
    ]);
    await pullChanges(w.contextFor());
    final lots = await w.db.select(w.db.lots).get();
    expect((lots.single.status, lots.single.kgHarvested), ('ready_for_sale', 195.0));
    final flag = await w.db.select(w.db.flags).getSingle();
    expect((flag.farmerId, flag.type), ('farmer-1', 'yield_over_ceiling'));
    expect(jsonDecode(flag.detailJson), {'ratio': '1.4'});
    expect((await w.entry(id)).status, EntryStatus.undone);
    expect(await w.db.syncStateDao.get(pullCursorKey), 'c2');
    expect(w.server.seen('GET', '/v1/sync/pull').map((r) => r.query['cursor']), [null, null, 'c1']);
  });

  test(
    'pull of the lot as `open` after a local ready packing keeps it ready; pull as `received` replaces it',
    () async {
      Map<String, Object?> lotAs(String status) => {
        'id': 'lot-1',
        'farmer_id': 'farmer-1',
        'plot_id': 'plot-1',
        'crop_id': 'crop-1',
        'season_label': '2026-rabi',
        'status': status,
        'harvested_kg': '195.000',
        'packed_kg': '300.000',
      };
      w.server.pullPages.add((
        [
          {'entity': 'lot', 'op': 'upsert', 'data': lotAs('open')},
        ],
        'c1',
        false,
      ));
      await pullChanges(w.contextFor());
      // M07 packing made the lot ready on the phone (the server keeps `open` until intake).
      await w.saveEntry('packing', {'bags': 6}, lotId: 'lot-1');
      await w.db.update(w.db.lots).write(const LotsCompanion(status: Value('ready_for_sale')));
      for (final (server, expected) in [
        ('open', 'ready_for_sale'),
        ('drying', 'ready_for_sale'),
        ('received', 'received'),
      ]) {
        w.server.pullPages.add((
          [
            {'entity': 'lot', 'op': 'upsert', 'data': lotAs(server)},
          ],
          'c-$server',
          false,
        ));
        await pullChanges(w.contextFor());
        final lot = await w.db.select(w.db.lots).getSingle();
        expect((lot.status, lot.kgPacked), (expected, 300.0), reason: 'server says $server');
      }
    },
  );

  test('a ready lot whose packing was rejected or undone takes the server status `open`', () async {
    for (final status in [EntryStatus.rejected, EntryStatus.undone]) {
      // One lot per case: entries are append-only (no delete between cases).
      final lot = 'lot-${status.name}';
      final packing = await w.saveEntry('packing', {'bags': 6}, lotId: lot);
      await (w.db.update(
        w.db.entries,
      )..where((e) => e.entryId.equals(packing))).write(EntriesCompanion(status: Value(status)));
      await w.db
          .into(w.db.lots)
          .insertOnConflictUpdate(
            LotsCompanion.insert(
              lotId: lot,
              plotId: 'plot-1',
              farmerId: 'farmer-1',
              cropId: 'crop-1',
              season: '2026-rabi',
              status: 'ready_for_sale',
              updatedAt: t0,
            ),
          );
      w.server.pullPages.add((
        [
          {
            'entity': 'lot',
            'op': 'upsert',
            'data': {
              'id': lot,
              'farmer_id': 'farmer-1',
              'plot_id': 'plot-1',
              'crop_id': 'crop-1',
              'season_label': '2026-rabi',
              'status': 'open',
              'harvested_kg': '195.000',
              'packed_kg': '0',
            },
          },
        ],
        'c-$status',
        false,
      ));
      await pullChanges(w.contextFor());
      final row = await (w.db.select(w.db.lots)..where((l) => l.lotId.equals(lot))).getSingle();
      expect(row.status, 'open', reason: 'packing $status');
    }
  });

  test('a refused cursor (422) is dropped so the next pull starts over', () async {
    await w.db.syncStateDao.set(pullCursorKey, 'bogus');
    w.server.intercept = (r) => r.path == '/v1/sync/pull'
        ? json({
            'error': {'code': 'validation_error'},
          }, status: 422)
        : null;
    await expectLater(pullChanges(w.contextFor()), throwsA(isA<DioException>()));
    expect(await w.db.syncStateDao.get(pullCursorKey), isNull);
  });

  test('photo_pending re-requests the URL (re-push answered duplicate) and uploads in the same run', () async {
    final id = await w.save(photos: 1);
    await w.sync.runOnce();
    final media = (await w.mediaOf(id)).single;
    w.server.objects.remove(media.mediaId); // the server lost it / never verified it
    // Pretend the local copy still exists (purge happened after confirm): restore the file and the row state.
    await w.db.mediaDao.setUploadState(
      media.mediaId,
      const MediaCompanion(uploadStatus: Value(UploadStatus.pending), purgedAt: Value(null)),
    );
    w.restoreFile(media.localPath);
    w.server.pullPages.add((
      [
        {
          'entity': 'photo_pending',
          'op': 'upsert',
          'data': {'id': media.mediaId, 'event_id': id, 'event_version_id': id, 'status': 'pending_upload'},
        },
      ],
      'c1',
      false,
    ));
    w.advance(const Duration(hours: 25));
    await w.sync.runOnce();
    expect(w.server.pushedIds, [id, id]);
    expect(w.server.objects.containsKey(media.mediaId), isTrue);
    expect((await w.mediaOf(id)).single.uploadStatus, UploadStatus.done);
  });

  test(
    'reference delta: first run gets every part and mirrors plots; next run lists held parts and gets 304',
    () async {
      final plots = {
        'plots': [
          {
            'id': 'plot-1',
            'farmer_id': 'farmer-1',
            'code': 'P1',
            'pin': {'lat': 9.5598, 'lon': 78.1335},
            'declared_area': '1.5',
            'area_unit': 'acre',
            'gi_tag_id': 'gi-1',
          },
        ],
      };
      w.server.reference
        ..['plots'] = (41, '"p41"', plots)
        ..['crops'] = (7, '"c7"', {'crops': <Object?>[]});
      await fetchBundles(w.contextFor());
      expect(await w.db.refBundlesDao.versions(), {'plots': 41, 'crops': 7});
      expect(jsonDecode((await w.db.refBundlesDao.get('plots'))!.bodyJson), plots);
      final plot = await w.db.select(w.db.plots).getSingle();
      expect((plot.pinLat, plot.declaredArea, plot.areaUnit), (9.5598, 1.5, 'acre'));
      expect(await w.db.refBundlesDao.get('gi_region'), isNull, reason: 'no region in effect: absent, not an error');

      expect(w.server.seen('GET', '/v1/sync/reference').single.query.containsKey('since'), isFalse);
      await fetchBundles(w.contextFor());
      expect(w.server.seen('GET', '/v1/sync/reference').last.query['since'], 'plots:41,crops:7');
      final fetchedAt = (await w.db.refBundlesDao.get('crops'))!.fetchedAt;

      w.server.reference['crops'] = (5, '"c5"', {'crops': <Object?>[]}); // a fingerprint part: differs, not greater
      w.advance(const Duration(minutes: 1));
      await fetchBundles(w.contextFor());
      final crops = (await w.db.refBundlesDao.get('crops'))!;
      expect((crops.version, crops.etag, crops.fetchedAt.isAfter(fetchedAt)), (5, '"c5"', true));
    },
  );

  test('the plots part never overwrites a known plot\'s accuracy, method, GI status, lock or version', () async {
    await w.db
        .into(w.db.plots)
        .insert(
          PlotsCompanion.insert(
            plotId: 'plot-1',
            farmerId: 'farmer-1',
            pinLat: 1,
            pinLng: 2,
            pinAccuracyM: 4.2,
            pinMethod: 'map_pin',
            declaredArea: 1,
            areaUnit: 'cent',
            surveyNoLocalOnly: const Value('S-12'),
            giStatus: 'inside',
            locked: true,
            version: 3,
          ),
        );
    w.server.reference['plots'] = (
      42,
      '"p42"',
      {
        'plots': [
          {
            'id': 'plot-1',
            'farmer_id': 'farmer-1',
            'pin': {'lat': 9.5598, 'lon': 78.1335},
            'declared_area': '1.5',
            'area_unit': 'acre',
          },
        ],
      },
    );
    await fetchBundles(w.contextFor());
    final p = await w.db.select(w.db.plots).getSingle();
    expect((p.pinAccuracyM, p.pinMethod, p.giStatus, p.locked, p.version), (4.2, 'map_pin', 'inside', true, 3));
    expect(
      (p.pinLat, p.pinLng, p.declaredArea, p.areaUnit, p.surveyNoLocalOnly),
      (9.5598, 78.1335, 1.5, 'acre', 'S-12'),
    );
  });
}
