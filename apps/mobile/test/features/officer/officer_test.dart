// M10 widget tests per screen state and the scripted assist flow: officer home (visits, farmers, flags count), assist
//   mode (assist bar on every screen; `assist_session` entry first, then the event with `assistMode`,
//   `assist_session_id` and `enteredRemotely`; End assist and Back call `POST /assist/end`), flags (list, detail,
//   "Fix it" → correction version + reason, "Looks fine", holds admin-only) and the moisture reading (past-due meter
//   blocked, `quality_reading` entry).
// Requirement: plan §7.2 M10 acceptance; docs/agents/acceptance/M10.md (incl. the D-032 line); UserFlows §Field officer
//   flows; FR69, FR70; CLAUDE.md §6.
// Callers: flutter test (CI mobile job).

import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/features/officer_assist/assist_controller.dart';
import 'package:agritrace/features/officer_moisture/moisture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart';
import 'officer_fixtures.dart';

/// The assist bar text for the seeded farmer.
const _bar = 'Logging for: Murugan';

/// The button labelled [label] (FilledButton.icon builds a private subclass, so match by supertype). Throws nothing.
Finder _button(String label) => find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>());

/// The `onPressed` of the button labelled [label] (null = disabled). [tester] reads the widget.
VoidCallback? _onPressed(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(_button(label)).onPressed;

/// Taps Murugan on the officer home (assist mode starts) and settles. [tester] and [h] as in the tests.
Future<void> _assistMurugan(WidgetTester tester, FlowHarness h) => h.tap(tester, find.text('Murugan').first);

void main() {
  testWidgets('officer home: visits by village, every farmer, no-phone marker, flags count, Add farmer', (
    tester,
  ) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await h.seedFlags();
    await tester.pumpAndSettle();
    expect(find.text('Field officer'), findsOneWidget);
    expect(find.text("Today's visits"), findsOneWidget);
    // Murugan has a harvest due today: once under the visits, once under all farmers.
    expect(find.text('Murugan'), findsNWidgets(2));
    expect(find.text('Selvi'), findsOneWidget);
    expect(find.text('No phone'), findsOneWidget);
    expect(find.text('Aruppukottai'), findsOneWidget);
    // Open and escalated flags; the cleared one is not counted.
    expect(find.text('Flags to clear: 3'), findsOneWidget);
    expect(find.text(_bar), findsNothing);
    await h.tap(tester, find.text('Add farmer'));
    expect(h.path, '/officer/onboard');
    await h.dispose(tester);
  });

  testWidgets('scripted assist flow: assist_session then the event, session id in the payload, End assist', (
    tester,
  ) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    h.taps = 0;
    await _assistMurugan(tester, h);
    expect(h.path, '/assist/farmer-1');
    expect(find.text(_bar), findsOneWidget);
    final session = h.container.read(assistProvider)!;
    // Log → Sowing → shutter → tick, all under the assist bar.
    await h.tap(tester, find.text('Log'));
    expect(h.path, '/assist/farmer-1/log');
    expect(find.text(_bar), findsOneWidget);
    await h.tap(tester, find.text('Sowing'));
    expect(find.text(_bar), findsOneWidget);
    await h.tap(tester, find.text('Take photo'));
    expect(h.path, '/assist/farmer-1/log/sowing/confirm');
    expect(find.text(_bar), findsOneWidget);
    await h.tap(tester, find.text('Correct'));
    expect(h.path, '/assist/farmer-1/saved');
    expect(find.text(_bar), findsOneWidget);
    // The server lets only the farmer undo their own entry, so assist mode offers no Undo.
    expect(find.text('Undo'), findsNothing);
    expect(h.taps, 5);

    final start = (await queued(h, 'assist_session')).single;
    expect(start.entryId, session.sessionId);
    expect(start.farmerId, 'farmer-1');
    expect(start.assistMode, isTrue);
    expect(payloadOf(start), {
      'farmer_id': 'farmer-1',
      'started_at': flowNow.toUtc().toIso8601String(),
      'started_gps': {'lat': 9.5501, 'lon': 78.2002, 'accuracy_m': 8.0},
    });
    final sowing = (await queued(h, 'sowing')).single;
    expect(sowing.assistMode, isTrue);
    expect(sowing.farmerId, 'farmer-1');
    expect(payloadOf(sowing)['assist_session_id'], session.sessionId);
    // About 25 m from the pin: on the plot.
    expect(sowing.enteredRemotely, isFalse);
    // D-032 order: the session is queued before the entry that names it.
    expect(await queuedTypes(h), ['assist_session', 'sowing']);

    await h.tap(tester, find.text('Home'));
    expect(h.path, '/assist/farmer-1');
    await h.tap(tester, find.text('End assist'));
    expect(h.path, '/officer');
    expect(find.text(_bar), findsNothing);
    expect(h.container.read(assistProvider), isNull);
    final end = h.api.requests.where((r) => r.path.endsWith('/v1/assist/end')).single;
    expect(end.data, {'assist_session_id': session.sessionId});
    await h.dispose(tester);
  });

  testWidgets('3 km from the plot pin → enteredRemotely', (tester) async {
    // 0.027° of latitude north of the pin is about 3.0 km.
    final far = LocationFix(lat: 9.577, lng: 78.2, accuracyM: 8, gpsTime: DateTime.utc(2026, 2, 14, 4));
    final h = FlowHarness(fixes: [far]);
    await startOfficer(tester, h);
    await _assistMurugan(tester, h);
    h.go('/assist/farmer-1/log/sowing');
    await tester.pumpAndSettle();
    await h.tap(tester, find.text('Take photo'));
    await h.tap(tester, find.text('Correct'));
    final sowing = (await queued(h, 'sowing')).single;
    expect((sowing.assistMode, sowing.enteredRemotely, sowing.lat), (true, true, 9.577));
    await h.dispose(tester);
  });

  test('enteredRemotely: 150 m (radius + buffer) is the edge; no plot or no fix is never remote', () {
    final plot = Plot(
      plotId: 'p',
      farmerId: 'f',
      pinLat: 9.55,
      pinLng: 78.2,
      pinAccuracyM: 5,
      pinMethod: 'gps',
      declaredArea: 1,
      areaUnit: 'acre',
      giStatus: 'inside',
      locked: false,
      version: 1,
    );
    LocationFix north(double metres) =>
        LocationFix(lat: 9.55 + metres / 111320, lng: 78.2, accuracyM: 5, gpsTime: DateTime.utc(2026));
    expect(enteredRemotely(plot, north(140)), isFalse);
    expect(enteredRemotely(plot, north(160)), isTrue);
    expect(enteredRemotely(null, north(3000)), isFalse);
    expect(enteredRemotely(plot, null), isFalse);
  });

  testWidgets('assist bar on every assisted screen; Back on the farmer home ends assist mode', (tester) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await _assistMurugan(tester, h);
    for (final path in [
      '/assist/farmer-1',
      '/assist/farmer-1/log',
      '/assist/farmer-1/log/harvest',
      '/assist/farmer-1/sell',
      '/assist/farmer-1/moisture',
      '/settings',
    ]) {
      h.go(path);
      await tester.pumpAndSettle();
      expect(find.text(_bar), findsOneWidget, reason: path);
    }
    h.go('/assist/farmer-1');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(h.path, '/officer');
    expect(find.text(_bar), findsNothing);
    expect(h.api.requests.where((r) => r.path.endsWith('/v1/assist/end')), hasLength(1));
    // Without a running session the assist scope is closed: no entry can be made there outside assist mode.
    h.go('/assist/farmer-1/log/sowing');
    await tester.pumpAndSettle();
    expect(h.path, '/officer');
    await h.dispose(tester);
  });

  testWidgets('flags list: holds first, glyph + word, cleared flags hidden', (tester) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await h.seedFlags();
    h.go('/officer/flags');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(3));
    final titles = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title! as Text).data).toList();
    expect(titles.first, 'Field outside the GI region');
    expect(titles, containsAll(['Harvest above the yield limit', 'Logged away from the field']));
    expect(find.text('Hold · Murugan'), findsOneWidget);
    expect(find.text('Check · Murugan'), findsNWidgets(2));
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    await h.dispose(tester);
  });

  testWidgets('"Fix it" on a warn: corrected bags, mandatory reason, correction version + flag_resolution', (
    tester,
  ) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    final harvest = await h.seedFlags();
    h.go('/officer/flags/$warnFlag');
    await tester.pumpAndSettle();
    expect(find.text('harvested: 650 kg'), findsOneWidget);
    expect(find.text('Murugan · Harvest'), findsOneWidget);
    await h.tap(tester, find.text('Fix it'));
    expect(_onPressed(tester, 'Save'), isNull, reason: 'reason is mandatory');
    // 13 bags in the seeded harvest → 10.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
    }
    await h.tap(tester, find.text('Field visit'));
    await h.tap(tester, _button('Save'));
    expect(h.path, '/officer/flags');
    expect(find.text('Saved.'), findsOneWidget);

    final fix = (await queued(h, 'harvest')).single;
    expect((fix.rootId, fix.version, fix.supersedesEntryId), (harvest.rootId, 2, harvest.entryId));
    expect((fix.reasonCode, fix.assistMode, fix.lotId, fix.instanceNo), ('field_visit', false, 'lot-1', 1));
    expect(payloadOf(fix), {
      'quantity': {'value': 500, 'unit': 'kg'},
      'bags': 10,
      'occurred_on': '2026-02-10',
    });
    final resolution = (await queued(h, 'flag_resolution')).single;
    expect(payloadOf(resolution), {'flag_id': warnFlag, 'resolution': 'fixed', 'reason_code': 'field_visit'});
    expect(await queuedTypes(h), ['harvest', 'flag_resolution']);
    // The resolved flag leaves the list until the pull brings the server's status.
    expect(find.text('Harvest above the yield limit'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(2));
    await h.dispose(tester);
  });

  testWidgets('hold: admin-only line, "Fix it" writes the correction only', (tester) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await h.seedFlags();
    h.go('/officer/flags/$holdFlag');
    await tester.pumpAndSettle();
    expect(find.text('Hold'), findsOneWidget);
    expect(find.text('Only the FPO admin can clear this flag.'), findsOneWidget);
    expect(find.text('Looks fine'), findsNothing);
    expect(find.text('Escalate'), findsNothing);
    await h.tap(tester, find.text('Fix it'));
    await h.tap(tester, find.text('Entry mistake'));
    await h.tap(tester, _button('Save'));
    expect(await queuedTypes(h), ['harvest']);
    expect((await queued(h, 'harvest')).single.reasonCode, 'entry_mistake');
    await h.dispose(tester);
  });

  testWidgets('entry not on this phone: "Fix it" disabled with the reason; "Looks fine" resolves', (tester) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await h.seedFlags();
    h.go('/officer/flags/$remoteFlag');
    await tester.pumpAndSettle();
    expect(_onPressed(tester, 'Fix it'), isNull);
    expect(find.text('This entry is not on this phone, so it cannot be fixed here.'), findsOneWidget);
    await h.tap(tester, find.text('Looks fine'));
    await h.tap(tester, find.text('Photo checked'));
    await h.tap(tester, _button('Save'));
    final resolution = (await queued(h, 'flag_resolution')).single;
    expect(payloadOf(resolution), {'flag_id': remoteFlag, 'resolution': 'looks_fine', 'reason_code': 'photo_checked'});
    expect(resolution.assistMode, isFalse);
    await h.dispose(tester);
  });

  testWidgets('moisture: a past-due meter is blocked; an in-date one saves a quality_reading', (tester) async {
    final h = FlowHarness();
    await startOfficer(tester, h);
    await _assistMurugan(tester, h);
    final session = h.container.read(assistProvider)!;
    await h.tap(tester, find.text('Moisture'));
    expect(h.path, '/assist/farmer-1/moisture');
    expect(find.text(_bar), findsOneWidget);
    await h.tap(tester, find.text('Old meter, calibrated to 10 Feb'));
    expect(find.text("This meter's calibration ended on 10 Feb. Use a meter calibrated on time."), findsOneWidget);
    expect(find.text('Reading on the meter'), findsNothing);
    expect(_button('Save'), findsNothing);
    await h.tap(tester, find.text('Wile 55, calibrated to 1 Mar'));
    for (final key in ['1', '0', '.', '5']) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }
    await h.tap(tester, _button('Save'));
    expect(h.path, '/assist/farmer-1');
    final reading = (await queued(h, 'quality_reading')).single;
    expect((reading.lotId, reading.assistMode, reading.farmerId), ('lot-1', true, 'farmer-1'));
    expect(payloadOf(reading), {
      'lot_id': 'lot-1',
      'stage': 'drying_end',
      'parameter_code': 'moisture',
      'measurement': {'value': '10.5', 'unit': '%'},
      'source': 'instrument',
      'instrument_id': goodMeter,
      'measured_at': flowNow.toUtc().toIso8601String(),
      'device_time': flowNow.toUtc().toIso8601String(),
      'assist_session_id': session.sessionId,
    });
    final lot = await (h.db.select(h.db.lots)..where((l) => l.lotId.equals('lot-1'))).getSingle();
    expect(lot.lastMoisture, 10.5);
    await h.dispose(tester);
  });

  test('calibrationExpired: the due day itself is still in date', () {
    final due = DateTime(2026, 2, 14);
    expect(calibrationExpired(due, DateTime(2026, 2, 14, 23, 59)), isFalse);
    expect(calibrationExpired(due, DateTime(2026, 2, 15, 0, 1)), isTrue);
  });
}
