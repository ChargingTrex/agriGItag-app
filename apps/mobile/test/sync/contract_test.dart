// Contract tests: every enum value and every JSON key the sync engine puts on the wire exists in the committed
// OpenAPI spec (the D-003 guard for the hand-built push envelope; officer corrections included), and wireName maps
// camelCase to snake_case.
// Requirement: D-003 (one contract), backend-design.md §3, M01 review P3-6 (camelCase on disk, snake_case on the
//   wire); WP-M02 deliverable 6.
// Callers: `flutter test test/sync` (run from apps/mobile, so the spec is ../../packages/openapi/openapi.json).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/enum_wire_names.dart';
import 'package:agritrace/core/sync/metrics.dart';
import 'package:agritrace/core/sync/outbox_processor.dart';
import 'package:agritrace/features/officer_flags/flag_actions.dart';
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
    // D-031/D-032 kinds `farmer` and `assist_session` (B15) and D-040 `lot_intake` (B16) are all in the spec.
    expect(SyncKind.values.map(wireName), unorderedEquals((kind['enum'] as List).cast<String>()));
    expect(eventTypes, unorderedEquals(((schemas['EventType'] as Map)['enum'] as List).cast<String>()));
    final changeKinds = ((schemas['ChangeKind'] as Map)['enum'] as List).cast<String>();
    expect(changeKinds, containsAll(ChangeKind.values.map(wireName)));
  });

  test('a built event_version entry, its photos and a metric use only spec keys and carry the required ones', () async {
    final w = World();
    await w.init();
    final id = await w.save(photos: 1);
    final wire = (await entryToWire(w.db, await w.entry(id)))!;
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

  test('every response key and enum value the engine reads exists in the spec (push, confirm, pull, reference)', () {
    Set<String> enumOf(String schema, [String? property]) {
      final s = schemas[schema] as Map;
      final e = property == null ? s : (s['properties'] as Map)[property] as Map;
      return (e['enum'] as List).cast<String>().toSet();
    }

    final paths = (jsonDecode(File('../../packages/openapi/openapi.json').readAsStringSync()) as Map)['paths'] as Map;
    Set<String> params(String path) => {
      for (final p in (((paths[path] as Map)['get'] as Map)['parameters'] as List).cast<Map<String, Object?>>())
        p['name']! as String,
    };

    // Push and confirm answers (outbox_processor.dart, photo_uploader.dart).
    expect(props('SyncPushOut'), containsAll({'server_time', 'results'}));
    expect(props('SyncResult'), containsAll({'client_id', 'status', 'photo_uploads', 'error'}));
    expect(enumOf('SyncResult', 'status'), {'accepted', 'duplicate', 'rejected'});
    expect(props('PhotoUpload'), containsAll({'photo_client_id', 'url', 'expires_at'}));
    expect(props('PhotoConfirmOut'), containsAll({'client_id', 'status'}));
    expect(enumOf('PhotoConfirmOut', 'status'), {'received', 'missing'});
    // Pull (pull_service.dart): entities the engine applies, and the paging keys.
    expect(params('/v1/sync/pull'), containsAll({'cursor', 'limit'}));
    expect(props('PullOut'), containsAll({'changes', 'next_cursor', 'has_more'}));
    expect(props('PullChange'), containsAll({'entity', 'op', 'data'}));
    expect(enumOf('PullChange', 'entity'), containsAll({'lot', 'flag', 'event', 'photo_pending'}));
    // Reference delta (bundle_fetcher.dart).
    expect(params('/v1/sync/reference'), contains('since'));
    expect(props('ReferenceOut'), contains('parts'));
    expect(props('ReferencePart'), containsAll({'version', 'etag', 'body'}));
    expect(enumOf('BundlePart'), containsAll({'plots', 'gi_region'}));
  });

  test('an undo is sent as an undo version of the original event type and payload', () async {
    final w = World();
    await w.init();
    final id = await w.save();
    final undoId = await w.db.entriesDao.undo(id, now: t0.add(const Duration(hours: 1)));
    final data = (await entryToWire(w.db, await w.entry(undoId)))!['data']! as Map<String, Object?>;
    expect((data['event_id'], data['version_no'], data['change_kind'], data['event_type']), (id, 2, 'undo', 'harvest'));
    expect((data['payload']! as Map)['bags'], 13);
    await w.dispose();
  });

  test(
    'an officer "Fix it" goes out as a `correct` version with the reason and the original day, nothing else',
    () async {
      final w = World();
      await w.init();
      final original = await w.entry(await w.save());
      final day = ((await entryToWire(w.db, original))!['data']! as Map)['occurred_on'];
      final flag = Flag(
        flagId: 'flag-1',
        farmerId: original.farmerId,
        entryId: original.rootId,
        type: 'yield_above_limit',
        severity: 'warn',
        status: 'open',
        detailJson: '{}',
        updatedAt: t0,
      );
      final now = t0.add(const Duration(days: 3));
      await saveFlagAction(
        w.db,
        flag: flag,
        action: FlagAction.fix,
        reasonCode: 'field_visit',
        now: now,
        entry: original,
        bags: 10,
      );
      final rows = await w.db.select(w.db.entries).get();
      expect(rows.map((e) => e.entryType), ['harvest', 'harvest'], reason: 'no flag_resolution with a fix');
      final wire = (await entryToWire(w.db, rows.singleWhere((e) => e.version == 2)))!;
      final data = wire['data']! as Map<String, Object?>;
      expect(props('SyncEntry'), containsAll(wire.keys));
      expect(props('HarvestVersion'), containsAll(data.keys));
      expect(data.keys, containsAll(required('HarvestVersion')));
      expect(((schemas['ChangeKind'] as Map)['enum'] as List), contains(data['change_kind']));
      expect(
        (data['event_id'], data['version_no'], data['change_kind'], data['reason_code'], data['occurred_on']),
        (original.rootId, 2, 'correct', 'field_visit', day),
      );
      await w.dispose();
    },
  );

  // D-031/D-032 are served since B15 merged (2026-10-31): the two kinds and the per-entry key are in openapi.json.
  test('D-040 (B16): SyncEntry has kind lot_intake and IntakeIn needs no processor_id', () {
    expect(wireName(SyncKind.lotIntake), 'lot_intake');
    final kind = ((schemas['SyncEntry'] as Map)['properties'] as Map)['kind'] as Map;
    expect(kind['enum'] as List, contains(wireName(SyncKind.lotIntake)));
    expect(required('IntakeIn'), isNot(contains('processor_id')));
  });

  test('D-031/D-032: SyncEntry has kinds farmer and assist_session and a top-level assist_session_id', () {
    final entry = (schemas['SyncEntry'] as Map)['properties'] as Map;
    final kinds = ((entry['kind'] as Map)['enum'] as List).cast<String>();
    expect(kinds, containsAll([wireName(SyncKind.farmer), wireName(SyncKind.assistSession)]));
    expect(entry.keys, contains('assist_session_id'), reason: 'on the entry, beside kind, not in data');
  });

  test(
    'onboarding push from [farmer, assist_session, consent, plot] Entries: kinds, order and lifted session id',
    () async {
      final w = World();
      await w.init();
      // Saved out of order on purpose: the batch puts the farmer, then the session, first (D-031).
      final consent = await w.saveEntry('consent', {'farmer_id': 'f-new', 'assist_session_id': 'as-1', 'type': 'x'});
      final farmer = await w.saveEntry('farmer', {'name': 'Muthu', 'assist_session_id': 'ignored-by-server'});
      final plot = await w.saveEntry('plot', {'farmer_id': 'f-new', 'assist_session_id': 'as-1'});
      final session = await w.saveEntry('assist_session', {'farmer_id': 'f-new', 'started_at': t0.toIso8601String()});
      final unknown = await w.saveEntry('mystery', {});
      await w.sync.runOnce();

      final entries = ((w.server.seen('POST', '/v1/sync/push').single.body! as Map)['entries'] as List)
          .cast<Map<String, Object?>>();
      expect(entries.map((e) => e['client_id']), [farmer, session, consent, plot]);
      expect(entries.map((e) => e['kind']), ['farmer', 'assist_session', 'consent', 'plot']);
      expect(entries.map((e) => e['assist_session_id']), ['ignored-by-server', null, 'as-1', 'as-1']);
      expect(entries.every((e) => !(e['data']! as Map).containsKey('assist_session_id')), isTrue);
      final rejected = await w.outboxOf(unknown);
      expect((rejected.status, rejected.lastError), (OutboxStatus.needsAttention, 'unknown_entry_type'));
      await w.dispose();
    },
  );

  test('an event captured in an assist session carries the session id on the entry, not in its payload', () async {
    final w = World();
    await w.init();
    final id = await w.saveEntry('harvest', {'bags': 2, 'assist_session_id': 'as-9'}, lotId: 'lot-1');
    final wire = (await entryToWire(w.db, await w.entry(id)))!;
    expect(wire['assist_session_id'], 'as-9');
    expect(((wire['data']! as Map)['payload'] as Map).containsKey('assist_session_id'), isFalse);
    await w.dispose();
  });
}
