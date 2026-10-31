// Widget tests per screen state of the M07 farmer screens: home (task card, fallback, assist bar), deep links (F17),
// unknown routes, lot picker, no lot, field configuration (D-017: hidden fields, required fields, YAML labels), yield
// preview, drying reminder, camera refused.
// Requirement: plan §7.2 M07; UserFlows §Farmer home screen, §Each farm event, §When things go wrong; D-017.
// Callers: flutter test (CI mobile job).

import 'dart:convert';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/enum_wire_names.dart';
import 'package:agritrace/features/event_log/farm_event.dart';
import 'package:agritrace/features/event_log/choose_event_screen.dart';
import 'package:agritrace/features/event_log/event_log_controller.dart';
import 'package:agritrace/core/router/placeholder_screen.dart';
import 'package:agritrace/features/sell/sell_screen.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  testWidgets('home: next task card with "14 Feb" opens the event on its lot, 3 (+1) taps with two lots', (
    tester,
  ) async {
    final h = FlowHarness();
    await h.db
        .into(h.db.tasks)
        .insert(
          TasksCompanion.insert(
            taskId: 't1',
            farmerId: 'farmer-1',
            lotId: const Value('lot-1'),
            eventType: 'harvest',
            dueDate: DateTime(2026, 2, 14),
            promptId: 'remind_harvest',
            source: 'schedule',
          ),
        );
    // Two active lots: without the task's lot the flow would ask "Which field?" first (D-043).
    await h.start(tester, lots: 2);
    h.taps = 0;
    expect(find.text('Next: Harvest, by 14 Feb'), findsOneWidget);
    expect(find.text('To do'), findsOneWidget);
    for (final label in ['Log', 'Sell', 'Money', 'My farm', 'History', 'Call officer']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await h.tap(tester, find.text('Harvest'));
    expect(h.path, '/log/harvest');
    expect(find.text('Which field?'), findsNothing);
    expect(find.text('How many bags?'), findsOneWidget);

    // Logging the harvest completes the task, so the card falls back.
    await h.tap(tester, find.text('Next'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect(h.path, '/home/saved');
    expect(h.taps, 4, reason: 'from home: task card, Next (the +1 extra choice), shutter, tick');
    expect((await h.saved('harvest')).single.lotId, 'lot-1');
    await h.tap(tester, find.text('Home'));
    expect(find.text('Nothing due now. Log what you did today.'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('home: fallback card, grey cloud while entries wait, Sell opens the Sell screen', (tester) async {
    final h = FlowHarness(pending: 3);
    await h.start(tester);
    expect(find.text('Nothing due now. Log what you did today.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    await h.tap(tester, find.text('Log event'));
    expect(find.byType(ChooseEventScreen), findsOneWidget);
    h.go('/home');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Sell'));
    expect(find.byType(SellScreen), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('assist mode: bar on the home screen, entry recorded with assistMode', (tester) async {
    final h = FlowHarness(overrides: [assistFarmerProvider.overrideWithValue((farmerId: 'farmer-1', name: 'Murugan'))]);
    await h.start(tester);
    expect(find.text('Logging for: Murugan'), findsOneWidget);
    h.go('/log/sowing');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect((await h.saved('sowing')).single.assistMode, isTrue);
    await h.dispose(tester);
  });

  testWidgets('deep links: /log/<unknown> → event grid; unknown path → farmer-friendly page', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/intake');
    expect(h.path, '/log');
    expect(find.byType(ChooseEventScreen), findsOneWidget);
    h.go('/home/nothing-here');
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text('This page is not here.'), findsOneWidget);
    expect(find.textContaining('Page Not Found'), findsNothing);
    await h.tap(tester, find.text('Home'));
    expect(h.path, '/home');
    // A confirm screen without a photo is never shown.
    h.go('/log/harvest/confirm');
    await tester.pumpAndSettle();
    expect(h.path, '/log/harvest');
    await h.dispose(tester);
  });

  testWidgets('two active lots → field picker (one more tap); no lot → call officer', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/sowing', lots: 2);
    expect(find.text('Which field?'), findsOneWidget);
    await h.tap(tester, find.text('Field 2'));
    // Field 2 has no history, so sowing is out of order there.
    expect(find.text('Did you already prepare the land?'), findsOneWidget);
    await h.tap(tester, find.text('No'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect((await h.saved('sowing')).single.lotId, 'lot-2');

    await (h.db.update(h.db.lots)).write(const LotsCompanion(status: Value('closed')));
    h.go('/log/sowing');
    await tester.pumpAndSettle();
    expect(find.text('No crop is registered for you yet. Call your field officer.'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('field config: disabled harvest fields skip the stepper; YAML label shown', (tester) async {
    final h = FlowHarness();
    await h.setFieldConfig('event_packing', [field('quantity'), field('bags', required: true, label: 'Sacks')]);
    await h.setFieldConfig('event_harvest', [field('unrelated')]);
    await h.start(tester, location: '/log/packing');
    expect(find.text('Sacks'), findsOneWidget, reason: 'unit label from the YAML');
    h.go('/log/harvest');
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget, reason: 'quantity and bags disabled: straight to the camera');
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect((await h.saved('harvest')).single.payloadJson, '{}');
    await h.dispose(tester);
  });

  testWidgets('field config: a required field without a value disables the tick; required variety hides the packet', (
    tester,
  ) async {
    final h = FlowHarness();
    // Land preparation fills the area from the plot; without the plot row it is missing.
    await h.setFieldConfig('event_land_preparation', [field('cultivated_area', required: true)]);
    await h.setFieldConfig('event_nursery', [field('seed_variety', required: true)]);
    await h.start(tester, location: '/log/nursery');
    expect(find.text('Seed packet'), findsNothing);
    expect(find.text('K2'), findsOneWidget);
    await h.db.delete(h.db.plots).go();
    h.go('/log/land_preparation');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Take photo'));
    final tick = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Correct'), matching: find.bySubtype<FilledButton>()),
    );
    expect(tick.onPressed, isNull);
    await h.dispose(tester);
  });

  testWidgets('harvest yield preview: orange "will be reviewed" above 30 % of the ceiling, never blocks', (
    tester,
  ) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/harvest');
    expect(find.text('Much more than usual. The officer will review it.'), findsNothing);
    // 1 acre, ceiling 1000 kg, 195 kg already: 24 bags → 1395 kg (+39.5 %).
    for (var i = 0; i < 23; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    expect(find.text('Much more than usual. The officer will review it.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('drying start sets a reminder task; drying done closes it', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/drying');
    await h.tap(tester, find.text('Start drying'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    final task = (await h.db.select(h.db.tasks).get()).single;
    expect((task.eventType, task.done, task.dueDate), ('drying', false, flowNow.add(const Duration(days: 7))));

    h.go('/log/drying');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Drying done'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect((await h.db.select(h.db.tasks).getSingle()).done, isTrue);
    await h.dispose(tester);
  });

  testWidgets('camera refused → one sentence + "Try again", never an error code', (tester) async {
    final h = FlowHarness(cameraDenied: true);
    await h.start(tester, location: '/log/sowing');
    expect(find.text('The camera is off. Allow the camera, then try again.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Take photo'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('sowing saved screen offers "Again" for a second round (instance 3)', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/log/sowing');
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    await h.tap(tester, find.text('Again'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect([for (final e in await h.saved('sowing')) e.instanceNo], [2, 3]);
    await h.dispose(tester);
  });

  testWidgets('from home through Log → grid: 4 taps (+1 extra), one more than the task card', (tester) async {
    final h = FlowHarness();
    await h.start(tester);
    h.taps = 0;
    await h.tap(tester, find.text('Log'));
    await h.tap(tester, find.text('Sowing'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect(h.path, '/home/saved');
    expect(h.taps, 4, reason: 'Log, event card, shutter, tick (sowing has no extra choice)');
    await h.dispose(tester);
  });

  testWidgets('fertiliser with an empty input list: Next, saved as bags', (tester) async {
    final h = FlowHarness();
    await h.start(tester, location: '/home');
    await h.db.refBundlesDao.upsert(
      RefBundlesCompanion.insert(
        bundleType: 'inputs',
        version: 2,
        etag: 'e2',
        fetchedAt: flowNow,
        bodyJson: '{"inputs": []}',
      ),
    );
    h.go('/log/input_application');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await h.tap(tester, find.text('Next'));
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    expect(jsonDecode((await h.saved('input_application')).single.payloadJson), {
      'quantity': {'value': 2, 'unit': 'bag'},
    });
    await h.dispose(tester);
  });

  test('every farm event wire name is one M02 pushes as an event version', () {
    expect(FarmEvent.values.map((e) => e.wireName), everyElement(isIn(eventTypes)));
  });
}
