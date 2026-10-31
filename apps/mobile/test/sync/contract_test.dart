// Contract tests: every enum value and every JSON key the sync engine puts on the wire exists in the committed
// OpenAPI spec (the D-003 guard for the hand-built push envelope), and wireName maps camelCase to snake_case.
// Requirement: D-003 (one contract), backend-design.md §3, M01 review P3-6 (camelCase on disk, snake_case on the
//   wire); WP-M02 deliverable 6.
// Callers: `flutter test test/sync` (run from apps/mobile, so the spec is ../../packages/openapi/openapi.json).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/enum_wire_names.dart';
import 'package:agritrace/core/sync/metrics.dart';
import 'package:agritrace/core/sync/outbox_processor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  final schemas =
      ((jsonDecode(File('../../packages/openapi/openapi.json').readAsStringSync()) as Map)['components']
              as Map)['schemas']
          as Map;
  Set<String> props(String schema) => ((schemas[schema] as Map)['properties'] as Map).keys.cast<String>().toSet();
  Set<String> required(String schema) => ((schemas[schema] as Map)['required'] as List).cast<String>().toSet();

  test('wireName / fromWire: camelCase ↔ snake_case for every enum the engine sends', () {
    expect(wireName(SyncKind.flagResolution), 'flag_resolution');
    expect(fromWire(SyncKind.values, 'quality_reading'), SyncKind.qualityReading);
    expect(fromWire(SyncKind.values, 'harvest'), isNull);
    final kind = ((schemas['SyncEntry'] as Map)['properties'] as Map)['kind'] as Map;
    expect(SyncKind.values.map(wireName), unorderedEquals((kind['enum'] as List).cast<String>()));
    final changeKinds = ((schemas['ChangeKind'] as Map)['enum'] as List).cast<String>();
    expect(changeKinds, containsAll(ChangeKind.values.map(wireName)));
  });

  test('a built event_version entry, its photos and a metric use only spec keys and carry the required ones', () async {
    final w = World();
    await w.init();
    final id = await w.save(photos: 1);
    final wire = await entryToWire(w.db, await w.entry(id));
    final data = wire['data']! as Map<String, Object?>;
    expect(props('SyncEntry'), containsAll(wire.keys));
    expect(props('HarvestVersion'), containsAll(data.keys));
    expect(data.keys, containsAll(required('HarvestVersion')));
    final photo = (data['photos']! as List).single as Map<String, Object?>;
    expect(props('PhotoIn'), containsAll(photo.keys));
    expect(props('ThreeClocks'), containsAll((data['clocks']! as Map).keys));
    expect(props('GeoPoint'), containsAll((data['gps']! as Map).keys));
    expect(data['change_kind'], 'create');
    expect((data['clocks']! as Map)['device_time'], endsWith('Z'));

    await w.db.syncMetricsDao.record(SyncMetricsCompanion.insert(entryId: id, savedAt: t0, networkType: 'wifi'));
    final metric = metricToWire((await w.db.syncMetricsDao.unshipped()).single);
    expect(props('SyncMetricIn'), containsAll(metric.keys));

    await w.sync.runOnce();
    final envelope = w.server.seen('POST', '/v1/sync/push').single.body! as Map;
    expect(props('SyncPushIn'), containsAll(envelope.keys.cast<String>()));
    expect(envelope.keys, containsAll(required('SyncPushIn')));
    final confirm = w.server.seen('POST', '/v1/sync/photos/confirm').single.body! as Map;
    expect(props('PhotosConfirmIn'), containsAll(confirm.keys.cast<String>()));
    await w.dispose();
  });

  test('an undo is sent as an undo version of the original event type and payload', () async {
    final w = World();
    await w.init();
    final id = await w.save();
    final undoId = await w.db.entriesDao.undo(id, now: t0.add(const Duration(hours: 1)));
    final data = (await entryToWire(w.db, await w.entry(undoId)))['data']! as Map<String, Object?>;
    expect((data['event_id'], data['version_no'], data['change_kind'], data['event_type']), (id, 2, 'undo', 'harvest'));
    expect((data['payload']! as Map)['bags'], 13);
    await w.dispose();
  });
}
