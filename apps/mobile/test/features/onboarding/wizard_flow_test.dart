// The onboarding wizard end to end with fakes: offline save to the outbox, the no-smartphone exit, field-config
//   skips and required fields, the GI preview, the online path and "Another plot"; records taps per step.
// Requirement: PLAN §7.2 M09 acceptance (full wizard offline → farmer + plot + consent + pin (+ boundary) in outbox;
//   declared 1 vs walked 2.4 → mismatch note; stop after step 8 → hasSmartphone=false; disabling plot.soil_type
//   removes that step; "Add another plot"), UserFlows §Onboarding a farmer, D-005, D-006, D-017.
// Callers: flutter test (CI mobile job).

import 'dart:math';

import 'package:agritrace/core/capture/gps_fix.dart' show LocationFix;
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_notifier.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'onboarding_harness.dart';

/// Taps per step on the happy path, filled by the first test and printed for the M09 report.
final _taps = <String, int>{};

/// Taps [finder] (scrolling it into view) and counts it against [step].
Future<void> _tap(WidgetTester tester, String step, Finder finder) async {
  _taps[step] = (_taps[step] ?? 0) + 1;
  await tapOn(tester, finder);
}

/// Sends fixes walking a [sideM] metre square from [insideGi] (four corners) through [f]'s GPS feed.
Future<void> _walkSquare(WidgetTester tester, WizardFixture f, double sideM) async {
  const metresPerDegree = 111320.0;
  final dLat = sideM / metresPerDegree, dLng = sideM / (metresPerDegree * cos(insideGi.lat * pi / 180));
  for (final (lat, lng) in [
    (insideGi.lat, insideGi.lng),
    (insideGi.lat, insideGi.lng + dLng),
    (insideGi.lat + dLat, insideGi.lng + dLng),
    (insideGi.lat + dLat, insideGi.lng),
  ]) {
    f.gps.add(fixAt(lat, lng, 5));
    await tester.pump();
  }
}

/// Fills a draft up to the crop step without the UI (for the tests about later steps).
void _fillToCrop(WizardFixture f, {String phone = '9876543210'}) {
  f.notifier.savePin(fixAt(insideGi.lat, insideGi.lng, 9), lowAccuracy: false);
  f.notifier.edit((d) {
    d.phoneDigits = phone;
    d.consentGivenAt = DateTime.utc(2026, 10, 31, 6);
    d.name = 'Murugan';
    d.step = OnboardingStep.crop;
  });
}

void main() {
  testWidgets('full wizard offline: farmer, consent and plot (pin + boundary) land in the outbox', (tester) async {
    final f = await pumpWizard(tester);

    // Step 1: number on the keypad.
    for (final digit in '9876543210'.split('')) {
      await _tap(tester, 'a start', find.text(digit));
    }
    await _tap(tester, 'a start', button('Next'));
    // Step 2: the consent clip plays by itself; the farmer taps "I agree".
    // The consent clip plays in Tamil on an English screen (UserFlows step 2); "I agree" waited for its end.
    expect(f.player.played, contains('assets/audio/ta/onboardConsentMessage.ogg'));
    await _tap(tester, 'b consent', button('I agree'));
    // Step 3: photo, name (the only text box), language.
    expect(enabled(tester, 'Next'), isFalse, reason: 'name is core: Next waits for it');
    await _tap(tester, 'c who', button('Take photo'));
    _taps['c who'] = _taps['c who']! + 1;
    await tester.enterText(find.byType(TextField), 'Murugan');
    await _tap(tester, 'c who', find.text('தமிழ்'));
    await _tap(tester, 'c who', button('Next'));
    // Step 4: "In field", then the ring fills; a 12 m fix saves the pin by itself.
    await _tap(tester, 'd location', button('In field'));
    f.gps.add(fixAt(insideGi.lat, insideGi.lng, 35));
    await tester.pump();
    f.gps.add(fixAt(insideGi.lat, insideGi.lng, 12));
    await tester.pumpAndSettle();
    expect(find.text('Location saved (12 m).'), findsOneWidget);
    await _tap(tester, 'd location', button('Next'));
    // Step 5: 1 acre (the default) and a survey number.
    await tester.enterText(find.byType(TextField), '245/3B');
    _taps['e land size'] = 1;
    await _tap(tester, 'e land size', button('Next'));
    // Step 6: walk a ~2.4-acre square against the declared 1 acre.
    await _tap(tester, 'f boundary', button('Start walking'));
    await _walkSquare(tester, f, 98.6);
    await _tap(tester, 'f boundary', button('Stop'));
    expect(find.textContaining('differ by more than 20 %'), findsOneWidget);
    expect(find.text('Declared: 1.00 acres'), findsOneWidget);
    expect(find.textContaining('Walked: 2.4'), findsOneWidget);
    await _tap(tester, 'f boundary', button('Next'));
    // Step 7: farming type and water source; then the soil step (enabled with no config).
    await _tap(tester, 'g water', find.text('Irrigated'));
    await _tap(tester, 'g water', find.text('Borewell'));
    await _tap(tester, 'g water', button('Next'));
    await _tap(tester, 'g2 soil', find.text('Red soil'));
    await _tap(tester, 'g2 soil', button('Next'));
    // Step 8: crop card → instant GI tick; "Farmer's phone" saves and goes on.
    await _tap(tester, 'h crop', find.text('Samba Vathal'));
    expect(find.text('Inside the GI area'), findsOneWidget);
    await _tap(tester, 'h crop', button("Farmer's phone"));
    // Step 9: QR with the number only, voice tour.
    expect(f.draft.step, OnboardingStep.handoff);
    expect(find.byKey(const ValueKey('agritrace://auth?phone=%2B919876543210')), findsOneWidget);
    await _tap(tester, 'i handoff', button('Voice tour'));
    expect(f.player.played.last, 'assets/audio/en/onboardTour.ogg');
    await _tap(tester, 'i handoff', button('Next'));
    expect(find.text('Murugan: 1 field saved'), findsOneWidget);

    final farmers = await f.db.select(f.db.farmers).get();
    expect(farmers, hasLength(1));
    expect(farmers.single.hasSmartphone, isTrue);
    expect(farmers.single.language, 'ta');
    expect(farmers.single.photoPath, fakePhotoPath);
    final entries = await savedEntries(f.db);
    expect(entries.keys, unorderedEquals(['farmer', 'assist_session', 'consent', 'plot']));
    final farmerId = farmers.single.farmerId;
    expect(entries['farmer']!.single.entryId, farmerId, reason: 'D-031: the farmer entry id is the farmer id');
    expect(entries.values.expand((e) => e).every((e) => e.farmerId == farmerId && e.assistMode), isTrue);
    expect(payloadOf(entries['farmer']!.single), {
      'name': 'Murugan',
      'phone': '+919876543210',
      'lang': 'ta',
      'no_smartphone': false,
    });
    final consent = payloadOf(entries['consent']!.single);
    expect(consent['consent_type'], 'data_collection');
    expect(consent['consent_version'], 'v1-ta');
    expect(consent['farmer_id'], farmerId);
    // D-032: one assist session, named by the consent and the plot.
    final session = entries['assist_session']!.single;
    expect(payloadOf(session)['farmer_id'], farmerId);
    expect(payloadOf(session)['started_gps'], {'lat': insideGi.lat, 'lon': insideGi.lng, 'accuracy_m': 12.0});
    expect(consent['assist_session_id'], session.entryId);
    expect(payloadOf(entries['plot']!.single)['assist_session_id'], session.entryId);
    expect(payloadOf(entries['farmer']!.single).containsKey('assist_session_id'), isFalse);
    final plot = entries['plot']!.single;
    expect(plot.plotId, plot.entryId, reason: 'D-005: the entry id is the plot client_id');
    expect((plot.lat, plot.accuracyM, plot.locationStatus), (insideGi.lat, 12.0, LocationStatus.ok));
    expect(plot.gpsTime, isNotNull);
    final data = payloadOf(plot);
    expect(data['declared_area'], {'value': 1, 'unit': 'acre'});
    expect(data['land_record_ref'], '245/3B');
    expect(data['pin'], {'lat': insideGi.lat, 'lon': insideGi.lng, 'accuracy_m': 12.0});
    expect(data['pin_method'], 'live_gps');
    expect((data['walked_boundary'] as Map)['type'], 'Polygon');
    expect(((data['walked_boundary'] as Map)['coordinates'] as List).single, hasLength(5), reason: 'closed ring');
    expect(
      (data['farming_type'], data['irrigation_source'], data['soil_type'], data['gi_tag_id']),
      ('irrigated', 'borewell', 'red', 'gi-883'),
    );
    final outbox = await (f.db.select(f.db.outbox)..orderBy([(o) => OrderingTerm(expression: o.seq)])).get();
    expect(outbox.map((o) => o.kind).toSet(), {OutboxKind.entry});
    final typeOf = {for (final e in entries.values.expand((e) => e)) e.entryId: e.entryType};
    expect(
      [for (final o in outbox) typeOf[o.refId]],
      ['farmer', 'assist_session', 'consent', 'plot'],
      reason: 'D-032 order: farmer (offline) -> assist_session -> the entries that name it',
    );

    debugPrint('M09 taps per step: $_taps');
  });

  testWidgets('"No smartphone" after step 8 saves hasSmartphone=false and skips the handoff', (tester) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button('No smartphone'));
    expect(f.draft.step, OnboardingStep.summary);
    expect((await f.db.select(f.db.farmers).getSingle()).hasSmartphone, isFalse);
    expect(payloadOf((await savedEntries(f.db))['farmer']!.single)['no_smartphone'], isTrue);
  });

  testWidgets('a farmer without a phone number can only leave step 8 with "No smartphone"', (tester) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f, phone: '');
    await tester.pumpAndSettle();
    expect(button("Farmer's phone"), findsNothing);
    await tapOn(tester, button('No smartphone'));
    expect(payloadOf((await savedEntries(f.db))['farmer']!.single).containsKey('phone'), isFalse);
  });

  testWidgets('disabling plot.soil_type (and the boundary walk) removes those steps', (tester) async {
    final allPlot = ['client_id', 'farmer_id', 'pin', 'device_time', 'declared_area', 'farming_type'];
    final f = await pumpWizard(
      tester,
      fieldConfig: {
        'plot': [
          for (final name in allPlot) {'name': name, 'required': false},
        ],
        'features': {'boundary_walk': false},
      },
    );
    expect(f.draft.steps, isNot(contains(OnboardingStep.soil)));
    expect(f.draft.steps, isNot(contains(OnboardingStep.boundary)));
    f.notifier.edit((d) => d.step = OnboardingStep.water);
    await tester.pumpAndSettle();
    expect(find.text('Borewell'), findsNothing, reason: 'irrigation_source disabled');
    await tapOn(tester, button('Next'));
    expect(f.draft.step, OnboardingStep.crop);
  });

  testWidgets('a field marked required blocks Next until filled', (tester) async {
    final f = await pumpWizard(
      tester,
      fieldConfig: {
        'farmer': [
          {'name': 'name', 'required': true},
          {'name': 'phone', 'required': true},
        ],
        'plot': [
          {'name': 'farming_type', 'required': true},
        ],
      },
    );
    expect(enabled(tester, 'Next'), isFalse, reason: 'phone required and empty');
    f.notifier.edit((d) => d.phoneDigits = '9876543210');
    await tester.pump();
    expect(enabled(tester, 'Next'), isTrue);
    f.notifier.edit((d) => d.step = OnboardingStep.water);
    await tester.pumpAndSettle();
    expect(enabled(tester, 'Next'), isFalse);
    await tapOn(tester, find.text('Rainfed'));
    expect(enabled(tester, 'Next'), isTrue);
  });

  testWidgets('GI preview: inside the outline shows the tick, outside or no outline shows "Needs review"', (
    tester,
  ) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Samba Vathal'));
    expect(find.text('Inside the GI area'), findsOneWidget);
    f.notifier.savePin(fixAt(outsideGi.lat, outsideGi.lng, 9), lowAccuracy: false);
    await tester.pumpAndSettle();
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Inside the GI area'), findsNothing);
  });

  testWidgets('GI preview without a downloaded outline is "Needs review"', (tester) async {
    final f = await pumpWizard(tester, region: false);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, find.text('Samba Vathal'));
    expect(find.text('Needs review'), findsOneWidget);
  });

  testWidgets('online: the server farmer id is used and no farmer entry is queued', (tester) async {
    final sent = <Map<String, Object?>>[];
    final f = await pumpWizard(
      tester,
      creator: (clientId, body) async {
        sent.add({...body, 'minted': clientId});
        return 'srv-farmer-1';
      },
    );
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button("Farmer's phone"));
    expect(sent.single['phone'], '+919876543210');
    expect(sent.single.containsKey('client_id'), isFalse, reason: 'TODO(B15): FarmerIn forbids it until B15');
    expect(sent.single['minted'], isNotNull, reason: 'D-031: the id is minted before the online try');
    final entries = await savedEntries(f.db);
    expect(entries.keys, unorderedEquals(['assist_session', 'consent', 'plot']));
    expect(payloadOf(entries['assist_session']!.single)['farmer_id'], 'srv-farmer-1');
    expect(payloadOf(entries['plot']!.single)['farmer_id'], 'srv-farmer-1');
    expect((await f.db.select(f.db.farmers).getSingle()).farmerId, 'srv-farmer-1');
  });

  testWidgets('a server refusal keeps the draft, says why and writes nothing', (tester) async {
    final f = await pumpWizard(
      tester,
      creator: (_, _) async => throw DioException(
        requestOptions: RequestOptions(path: '/v1/farmers'),
        response: Response(
          requestOptions: RequestOptions(path: '/v1/farmers'),
          statusCode: 409,
          data: {
            'error': {'code': 'farmer_phone_taken', 'message': 'taken'},
          },
        ),
      ),
    );
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button("Farmer's phone"));
    expect(find.text('This number is already registered.'), findsOneWidget);
    expect(f.draft.step, OnboardingStep.crop);
    expect(await savedEntries(f.db), isEmpty);
    expect(await f.db.select(f.db.farmers).get(), isEmpty);
  });

  testWidgets('"Another plot" runs steps 4-8 again and saves only a second plot', (tester) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button('No smartphone'));
    await tapOn(tester, button('Another plot'));
    expect(f.draft.step, OnboardingStep.location);
    expect(f.draft.steps.first, OnboardingStep.location);
    expect(f.draft.pin, isNull);
    f.notifier.savePin(fixAt(insideGi.lat + 0.001, insideGi.lng, 30), lowAccuracy: true);
    f.notifier.edit((d) {
      d.areaUnit = 'cent';
      d.areaValue = 50;
      d.step = OnboardingStep.crop;
    });
    await tester.pumpAndSettle();
    await tapOn(tester, button('Save'));
    expect(find.text('Murugan: 2 fields saved'), findsOneWidget);
    final entries = await savedEntries(f.db);
    expect(entries['plot'], hasLength(2));
    expect(entries['farmer'], hasLength(1));
    expect(entries['consent'], hasLength(1));
    expect(entries['assist_session'], hasLength(1));
    final second = entries['plot']!.firstWhere((e) => e.locationStatus == LocationStatus.lowAccuracy);
    expect(payloadOf(second)['declared_area'], {'value': 50, 'unit': 'cent'});
    expect(payloadOf(second)['assist_session_id'], entries['assist_session']!.single.entryId, reason: 'same session');
  });

  testWidgets('after "Farmer\'s phone", a second plot goes to the summary, not to the handoff again', (tester) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button("Farmer's phone"));
    expect(f.draft.step, OnboardingStep.handoff);
    await tapOn(tester, button('Next'));
    await tapOn(tester, button('Another plot'));
    f.notifier.savePin(fixAt(insideGi.lat, insideGi.lng, 9), lowAccuracy: false);
    f.notifier.edit((d) => d.step = OnboardingStep.crop);
    await tester.pumpAndSettle();
    await tapOn(tester, button('Save'));
    expect(f.draft.step, OnboardingStep.summary);
  });

  testWidgets('a walk whose shape crosses itself is left out: pin and size are kept, "Walk again" is offered', (
    tester,
  ) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    f.notifier.edit((d) => d.step = OnboardingStep.boundary);
    await tester.pumpAndSettle();
    await tapOn(tester, button('Start walking'));
    // A figure 8: two loops joined where the path crosses itself.
    const m = 1 / 111320.0;
    for (final (dx, dy) in [(0, 0), (60, 60), (120, 0), (120, 60), (60, 0), (0, 60)]) {
      f.gps.add(fixAt(insideGi.lat + dy * m, insideGi.lng + dx * m, 5));
      await tester.pump();
    }
    await tapOn(tester, button('Stop'));
    expect(find.textContaining('crosses itself'), findsOneWidget);
    expect(button('Walk again'), findsOneWidget);
    expect(f.player.played.last, 'assets/audio/en/onboardBoundaryCrosses.ogg');
    expect(f.draft.walkedAcres, isNull);
    f.notifier.edit((d) => d.step = OnboardingStep.crop);
    await tester.pumpAndSettle();
    await tapOn(tester, button('No smartphone'));
    final data = payloadOf((await savedEntries(f.db))['plot']!.single);
    expect(data.containsKey('walked_boundary'), isFalse);
    expect(data['pin'], isNotNull);
    expect(data['declared_area'], {'value': 1, 'unit': 'acre'});
  });

  testWidgets('location off or refused: the GPS stream ends, "In field" comes back with "Turn on location"', (
    tester,
  ) async {
    // What GpsFix yields when permission is refused or location is off: a stream that ends with no fix.
    final f = await pumpWizard(tester, gpsSource: () => const Stream<LocationFix>.empty());
    f.notifier.edit((d) => d.step = OnboardingStep.location);
    await tester.pumpAndSettle();
    await tapOn(tester, button('In field'));
    expect(button('In field'), findsOneWidget);
    expect(find.text('No location. Turn on location and tap again.'), findsOneWidget);
    expect(f.player.played.last, 'assets/audio/en/onboardLocationOff.ogg');
  });

  testWidgets('back from "Another plot" returns to the summary, never to the saved steps', (tester) async {
    final f = await pumpWizard(tester);
    _fillToCrop(f);
    await tester.pumpAndSettle();
    await tapOn(tester, button('No smartphone'));
    await tapOn(tester, button('Another plot'));
    f.notifier.back();
    expect(f.draft.step, OnboardingStep.summary);
  });
}
