// Scripted farmer flows through the real app with fake camera, GPS and compressor: each of the eight events in at most
// three taps (+1 optional) with photo, GPS and clocks; 6 bags × 50 kg → 300 kg; packing at 12 % not ready; "Did you
// already sow?" once; blurry photo → retake; weak GPS → save anyway; offline → cloud; double tap saves once; undo.
// Requirement: plan §7.2 M07 acceptance; UserFlows §Logging a farm event, §Each farm event, §When things go wrong;
//   FR3, FR57, FR58; Dataflow Stages 1–6.
// Callers: flutter test (CI mobile job); integration_test/farmer_flows_test.dart runs the same main on a device (Q01).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/capture/photo_quality_check.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// One scripted event: wire [type], the F04 [card] text, [plus] taps on the stepper's + (adjustments, not counted),
/// the forward [extra] taps (counted), the expected [payload] and the expected forward [taps].
typedef ScriptedFlow = ({
  String type,
  String card,
  int plus,
  List<String> extra,
  Map<String, Object?> payload,
  int taps,
});

/// The eight events (UserFlows §Each farm event).
const List<ScriptedFlow> flows = [
  (
    type: 'land_preparation',
    card: 'Land prep',
    plus: 0,
    extra: [],
    payload: {
      'cultivated_area': {'value': 1, 'unit': 'acre'},
      'last_ploughed_on': '2026-02-14',
    },
    taps: 3,
  ),
  (type: 'nursery', card: 'Nursery', plus: 0, extra: ['K2'], payload: {'seed_variety': 'K2'}, taps: 4),
  // Seed variety comes from the nursery entry by itself.
  (type: 'sowing', card: 'Sowing', plus: 0, extra: [], payload: {'seed_variety': 'K2'}, taps: 3),
  (
    type: 'input_application',
    card: 'Fertiliser, spray',
    plus: 5,
    extra: ['Organic Fertilizer Gold'],
    payload: {
      'input_id': 'in-ofg',
      'quantity': {'value': 300, 'unit': 'kg'},
    },
    taps: 4,
  ),
  (
    type: 'harvest',
    card: 'Harvest',
    plus: 5,
    extra: ['Next'],
    payload: {
      'quantity': {'value': 300, 'unit': 'kg'},
      'bags': 6,
    },
    taps: 4,
  ),
  (type: 'drying', card: 'Drying', plus: 0, extra: ['Drying done'], payload: {'phase': 'end'}, taps: 4),
  (
    type: 'packing',
    card: 'Packing',
    plus: 5,
    extra: ['Next'],
    payload: {
      'quantity': {'value': 300, 'unit': 'kg'},
      'bags': 6,
    },
    taps: 4,
  ),
  (type: 'problem', card: 'Problem', plus: 0, extra: ['Pest'], payload: {'problem_type': 'pest'}, taps: 4),
];

/// Runs [flow] from the event grid (F04) to the saved screen on [h]: card, extra taps, shutter, tick. [tester] drives
/// the app. Returns when the saved screen shows; fails the test when a step is missing.
Future<void> runFlow(WidgetTester tester, FlowHarness h, ScriptedFlow flow) async {
  expect(h.path, '/log');
  await h.tap(tester, find.text(flow.card));
  for (var i = 0; i < flow.plus; i++) {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  }
  for (final text in flow.extra) {
    await h.tap(tester, find.text(text));
  }
  await h.tap(tester, find.text('Take photo'));
  expect(h.path, '/log/${flow.type}/confirm');
  await h.tap(tester, find.text('Correct'));
  expect(h.path, '/home/saved');
}

void main() {
  group('each event: ≤ 3 taps (+1 optional), photo + GPS + clocks', () {
    for (final flow in flows) {
      testWidgets(flow.type, (tester) async {
        final h = FlowHarness();
        await h.start(tester, location: '/log');
        final clock = Stopwatch()..start();
        await runFlow(tester, h, flow);
        clock.stop();
        // ignore: avoid_print
        print('M07 flow ${flow.type}: ${h.taps} taps, ${clock.elapsedMilliseconds} ms (host, fake camera)');

        expect(h.taps, flow.taps, reason: 'forward taps');
        expect(h.taps, lessThanOrEqualTo(4));
        expect(clock.elapsed, lessThan(const Duration(seconds: 20)));
        final entry = (await h.saved(flow.type)).single;
        expect(jsonDecode(entry.payloadJson), flow.payload);
        expect(entry.lotId, 'lot-1');
        expect(entry.plotId, 'plot-1');
        expect(entry.farmerId, 'farmer-1');
        expect(entry.enteredByUserId, 'user-1');
        expect(entry.assistMode, isFalse);
        expect(entry.status, EntryStatus.saved);
        // Three clocks: phone time here, GPS time from the fix, server time on sync.
        expect(entry.deviceTime, flowNow);
        expect(entry.gpsTime, DateTime.utc(2026, 2, 14, 4, 0, 1));
        expect(entry.undoDeadline, flowNow.add(const Duration(hours: 24)));
        expect((entry.lat, entry.lng, entry.accuracyM), (9.5501, 78.2002, 8.0));
        expect(entry.locationStatus, LocationStatus.ok);
        final photo = (await h.mediaOf(entry.entryId)).single;
        expect((photo.kind, photo.width, photo.height, photo.sha256), ('photo', 1600, 1200, 'ab' * 32));
        expect(photo.thumbPath, endsWith('_thumb.jpg'));
        expect(photo.localPath, startsWith(h.media.path));
        expect(photo.lat, 9.5501);
        // The camera original is never kept.
        expect(h.compressor.originals.every((f) => !f.existsSync()), isTrue);
        await h.dispose(tester);
      });
    }
  });

  testWidgets('6 bags × 50 kg harvest is stored as {value: 300, unit: kg}, instance 2', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log');
    await runFlow(tester, h, flows.firstWhere((f) => f.type == 'harvest'));
    final entry = (await h.saved('harvest')).single;
    expect((jsonDecode(entry.payloadJson) as Map)['quantity'], {'value': 300, 'unit': 'kg'});
    expect(entry.instanceNo, 2, reason: 'the seeded 195 kg harvest is round 1');
    await h.dispose(tester);
  });

  testWidgets('packing at 12 % moisture does not make the lot ready; "keep drying" sheet', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log', lastMoisture: 12);
    await runFlow(tester, h, flows.firstWhere((f) => f.type == 'packing'));
    expect((await h.db.select(h.db.lots).getSingle()).status, 'open');
    expect(find.text('Not dry enough yet. Keep drying; the officer will check the moisture.'), findsOneWidget);
    expect(find.text('Ready to sell.'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('packing at 10 % makes the lot ready_for_sale; undo puts it back', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log', lastMoisture: 10);
    await runFlow(tester, h, flows.firstWhere((f) => f.type == 'packing'));
    expect((await h.db.select(h.db.lots).getSingle()).status, 'ready_for_sale');
    expect(find.text('Ready to sell.'), findsOneWidget);

    await h.tap(tester, find.text('Undo'));
    expect(h.path, '/home');
    expect((await h.db.select(h.db.lots).getSingle()).status, 'open');
    final packing = (await h.saved('packing')).single;
    expect(packing.status, EntryStatus.undone);
    expect((await h.saved('undo')).single.supersedesEntryId, packing.entryId);
    await h.dispose(tester);
  });

  testWidgets('"Did you already sow?" is asked once, kept in a local marker, never blocks', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log', withHistory: false);
    await h.tap(tester, find.text('Harvest'));
    expect(find.text('Did you already sow?'), findsOneWidget);
    // Android Back neither closes the sheet nor records an answer.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Did you already sow?'), findsOneWidget);
    await h.tap(tester, find.text('Yes'));
    await h.tap(tester, find.text('Next'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect(h.path, '/home/saved');

    // Phone-only marker in SyncState (no pull touches it); nothing is written into the server-mirror Flags table.
    expect(jsonDecode((await h.db.syncStateDao.get('order_asked:lot-1'))!), [
      {
        'event_type': 'harvest',
        'missing': ['land_preparation', 'sowing'],
        'farmer_says_done': true,
      },
    ]);
    expect(await h.db.select(h.db.flags).get(), isEmpty);

    // Second harvest on the same lot: no question.
    h.go('/log');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Harvest'));
    expect(find.text('Did you already sow?'), findsNothing);
    expect(find.text('Next'), findsOneWidget);
    expect(jsonDecode((await h.db.syncStateDao.get('order_asked:lot-1'))!), hasLength(1));
    await h.dispose(tester);
  });

  testWidgets('blurry photo → "Photo is not clear. Take again?" → retake → saved', (tester) async {
    final h = FlowHarness(verdicts: [PhotoQuality.tooBlurry, PhotoQuality.ok]);
    await h.start(tester, location: '/log');
    await h.tap(tester, find.text('Sowing'));
    await h.tap(tester, find.text('Take photo'));
    expect(find.text('Photo is not clear. Take again?'), findsOneWidget);
    expect(File('${h.media.path}/photo_1_1600.jpg').existsSync(), isFalse, reason: 'rejected photo deleted');
    await h.tap(tester, find.text('Retake'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    final entry = (await h.saved('sowing')).single;
    expect((await h.mediaOf(entry.entryId)).single.localPath, endsWith('photo_2_1600.jpg'));
    await h.dispose(tester);
  });

  testWidgets('Back from Confirm and a new shot deletes the first photo files', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/sowing');
    await h.tap(tester, find.text('Take photo'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Take photo'));
    expect(File('${h.media.path}/photo_1_1600.jpg').existsSync(), isFalse);
    expect(File('${h.media.path}/photo_1_thumb.jpg').existsSync(), isFalse);
    expect(File('${h.media.path}/photo_2_1600.jpg').existsSync(), isTrue);
    await h.dispose(tester);
  });

  testWidgets('weak GPS → ring → "Save anyway" after 60 s → saved as low_accuracy', (tester) async {
    final h = FlowHarness(fixes: [fixOf(50)]);
    await h.start(tester, location: '/log');
    await h.tap(tester, find.text('Sowing'));
    await h.tap(tester, find.text('Take photo'));
    expect(find.text('Hold the phone up, finding your location'), findsOneWidget);
    expect(find.text('Save anyway'), findsNothing);
    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Save anyway'));
    await h.tap(tester, find.text('Correct'));
    final entry = (await h.saved('sowing')).single;
    expect(entry.locationStatus, LocationStatus.lowAccuracy);
    expect(entry.accuracyM, 50);
    await h.dispose(tester);
  });

  testWidgets('offline → green tick + grey cloud "Saved. Will send when signal comes."', (tester) async {
    final h = FlowHarness(pending: 2);
    await h.start(tester, location: '/log');
    await runFlow(tester, h, flows.firstWhere((f) => f.type == 'sowing'));
    expect(find.text('Saved. Will send when signal comes.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNWidgets(2), reason: 'app bar cloud + big cloud');
    await h.dispose(tester);
  });

  testWidgets('a double tap on the tick saves one entry', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log');
    await h.tap(tester, find.text('Sowing'));
    await h.tap(tester, find.text('Take photo'));
    await tester.tap(find.text('Correct'));
    await h.tap(tester, find.text('Correct'));
    expect(await h.saved('sowing'), hasLength(1));
    final queued = (await h.db.select(h.db.outbox).get()).where((o) => o.createdAt == flowNow);
    expect(queued, hasLength(2), reason: 'one entry row + one photo row (the seeded history is queued too)');
    await h.dispose(tester);
  });

  testWidgets('problem with a voice note: photo + voice media rows', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log');
    await h.tap(tester, find.text('Problem'));
    await h.tap(tester, find.text('Disease'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Voice note'));
    // The tick waits while the note records, so an early tick cannot drop it.
    final tick = find.ancestor(of: find.text('Correct'), matching: find.bySubtype<FilledButton>());
    expect(tester.widget<FilledButton>(tick).onPressed, isNull);
    await h.tap(tester, find.text('Stop'));
    expect(find.text('Voice added'), findsOneWidget);
    await h.tap(tester, find.text('Correct'));
    final entry = (await h.saved('problem')).single;
    expect(jsonDecode(entry.payloadJson), {'problem_type': 'disease'});
    final kinds = [for (final m in await h.mediaOf(entry.entryId)) m.kind]..sort();
    expect(kinds, ['photo', 'voice']);
    await h.dispose(tester);
  });
}
