// Scripted QC flow through the UI: scan → lot card → intake (230 vs 200 orange, 11.5 % orange, expired meter
//   refused) → save; batch list → grading (4 readings → grade + standard edition, declared above computed) → save →
//   packing (above graded refused, then saved). Every saved payload is checked field for field against the server
//   schemas in packages/openapi/openapi.json, and the event wire form against the M02 push builder.
// Requirement: PLAN §7.2 M11 acceptance ("scan → lot; 230 vs 200 → orange; 11.5 → orange; 4 readings → grade +
//   standard edition") and tests ("a scripted flow test asserting the saved payloads match the server schemas");
//   UserFlows §Selling to the FPO, §Grade a batch; FR42, FR49, FR50; D-005, D-014, D-034.
// Callers: flutter test (CI mobile job).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/sync/outbox_processor.dart';
import 'package:agritrace/features/qc_home/qc_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qc_harness.dart';

/// Component schemas of the committed OpenAPI document (the server's Pydantic models).
final _schemas =
    ((jsonDecode(File('../../packages/openapi/openapi.json').readAsStringSync()) as Map)['components']
            as Map)['schemas']
        as Map;

/// Asserts that [payload] uses only fields of server schema [name] and carries all its required fields except
/// [sentElsewhere] (e.g. `client_id`, which travels as the push entry id). Throws a test failure otherwise.
void expectSchema(Map<String, Object?> payload, String name, {Set<String> sentElsewhere = const {}}) {
  final schema = _schemas[name] as Map;
  final props = (schema['properties'] as Map).keys.toSet();
  final required = {...(schema['required'] as List? ?? const [])}..removeAll(sentElsewhere);
  expect(props.containsAll(payload.keys), isTrue, reason: '$name has no ${payload.keys.toSet().difference(props)}');
  expect(
    payload.keys.toSet().containsAll(required),
    isTrue,
    reason: '$name needs ${required.difference(payload.keys.toSet())}',
  );
}

/// Asserts that [q] is a server `Quantity` with [unit] and decimal-text value [value]. Throws a test failure otherwise.
void expectQuantity(Object? q, String value, String unit) {
  expectSchema((q! as Map).cast<String, Object?>(), 'Quantity-Input');
  expect(q, {'value': value, 'unit': unit});
}

void main() {
  testWidgets('intake: scan → lot card → 230 vs 200 orange, 11.5 % orange, expired meter refused, saved payloads', (
    tester,
  ) async {
    final f = await pumpQc(tester, const QcHomeScreen());
    var taps = 0;
    Future<void> tap(Finder finder) async {
      taps++;
      await tapOn(tester, finder);
    }

    await tap(button('Receive lot'));
    f.scanned = lotQr;
    await tapOn(tester, find.text('Fake scan')); // the camera, not a tap of the officer
    // scan → lot: the card shows the farmer and packed weight.
    expect(find.text('Murugan'), findsOneWidget);
    expect(find.text('200 kg'), findsOneWidget);

    for (final d in '230'.split('')) {
      await tap(find.widgetWithText(FilledButton, d).last);
    }
    expect(find.text('230 kg received but 200 kg packed: more than 5 % apart.'), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.radio_button_unchecked).first).color,
      const Color(0xFFB45309),
      reason: 'orange circle (StatusGlyph.todo)',
    );

    await tap(tile('Moisture'));
    for (final d in '11.5'.split('')) {
      await tap(find.widgetWithText(FilledButton, d).last);
    }
    expect(find.text('Moisture 11.5 % is above the 11 % limit.'), findsOneWidget);
    expect(find.text('Pick the instrument to save the reading.'), findsWidgets);
    expect(enabled(tester, 'Save'), isFalse);

    // The meter past its calibration is shown with the reason and cannot be picked.
    expect(find.text('Calibration expired 14 Feb. Use another meter.'), findsOneWidget);
    await tapOn(tester, find.text('Old meter'));
    expect(enabled(tester, 'Save'), isFalse);
    await tap(find.text('Delmhorst G-7'));
    expect(enabled(tester, 'Save'), isTrue);
    await tap(button('Save'));
    expect(find.text('Saved. It is sent when there is signal.'), findsOneWidget);
    debugPrint('M11 taps: intake $taps (Receive lot, 3 digits, moisture tile, 4 keys, meter, Save)');

    final saved = await savedEntries(f.db);
    final reading = saved['quality_reading']!.single, intake = saved['intake']!.single;
    final r = payloadOf(reading), i = payloadOf(intake);
    expectSchema(r, 'QualityReadingIn', sentElsewhere: {'client_id'});
    expect(r['lot_id'], lotId);
    expect(r['stage'], 'intake');
    expect(r['parameter_code'], 'moisture');
    expectQuantity(r['measurement'], '11.5', '%');
    expect(r['source'], 'instrument');
    expect(r['instrument_id'], meterId);
    expect(r['method_ref'], 'AGMARK Sch. IV moisture method');
    expect(DateTime.parse(r['measured_at']! as String).isUtc, isTrue);
    expectSchema(i, 'IntakePayload');
    expectQuantity(i['received'], '230', 'kg');
    expect(i['moisture_reading_id'], reading.entryId);
    for (final e in [reading, intake]) {
      expect(e.enteredByUserId, 'qc-1');
      expect(e.lotId, lotId);
      expect(e.farmerId, farmerId);
      expect(e.gpsTime, isNull);
      expect(e.deviceTime, e.createdAt);
      expect(e.undoDeadline, e.createdAt);
    }
    // Both queued, the reading first (the intake names it).
    final outbox = await f.db.select(f.db.outbox).get();
    expect([for (final o in outbox) o.refId], [reading.entryId, intake.entryId]);
    // The push builder sends the reading as `quality_reading` and the intake as a lot event version.
    final rw = (await entryToWire(f.db, reading))!, iw = (await entryToWire(f.db, intake))!;
    expect(rw['kind'], 'quality_reading');
    final event = iw['data']! as Map;
    expect(
      [iw['kind'], event['event_type'], event['subject_type'], event['lot_id']],
      ['event_version', 'intake', 'lot', lotId],
    );
    expectSchema((event['payload']! as Map).cast(), 'IntakePayload');
  });

  testWidgets('batch: 4 readings → grade + standard edition, declared above computed, pack above graded refused', (
    tester,
  ) async {
    // The event_grading config as served from apps/api/config/fields/event_grading.yaml (declared grade required).
    final f = await pumpQc(
      tester,
      const QcHomeScreen(),
      fieldConfig: {
        'event_grading': [
          {'name': 'quantity', 'required': false, 'enabled': true},
          {'name': 'declared_grade', 'required': true, 'enabled': true},
        ],
      },
    );
    await tapOn(tester, button('Grade batch'));
    await tapOn(tester, find.text('Batch FGP8T4033HM7: 320 kg'));
    // Missing readings → grey preview listing them.
    expect(find.text('No grade yet. Missing: Moisture'), findsOneWidget);

    await tapOn(tester, find.text('Delmhorst G-7'));
    for (final (label, value) in [
      ('Moisture', '10.5'),
      ('extraneous matter', '1'),
      ('unripe marked fruits', '2'),
      ('broken fruits', '3'),
    ]) {
      await tapOn(tester, tile(label));
      await typeDigits(tester, value);
    }
    expect(find.text('Grade: Standard'), findsOneWidget);
    expect(
      find.text('AGMARK Grading and Marking Rules — Dry Chillies and Capsicums, edition LOAD_FROM_STANDARD'),
      findsOneWidget,
    );
    await tapOn(tester, tile('Graded weight'));
    await typeDigits(tester, '180');
    expect(enabled(tester, 'Save'), isFalse, reason: 'declared grade is required (D-017)');
    await tapOn(tester, find.text('Special'));
    expect(find.text('Declared Special is above the computed Standard. The admin cannot approve it.'), findsOneWidget);
    await tapOn(tester, button('Save'));

    final saved = await savedEntries(f.db);
    final readings = saved['quality_reading']!, grading = saved['grading']!.single;
    expect(
      [for (final r in readings) payloadOf(r)['parameter_code']],
      ['moisture', 'extraneous_matter', 'unripe_marked_fruits', 'broken_fruits'],
    );
    for (final r in readings) {
      final p = payloadOf(r);
      expectSchema(p, 'QualityReadingIn', sentElsewhere: {'client_id'});
      expect(
        [p['batch_id'], p['lot_id'], p['stage'], p['source'], p['instrument_id']],
        [toGrade.id, null, 'grading', 'instrument', meterId],
      );
      expect(r.lotId, isNull);
    }
    expectQuantity(payloadOf(readings.first)['measurement'], '10.5', '%');
    final gw = (await entryToWire(f.db, grading))!['data']! as Map;
    expect(
      [gw['event_type'], gw['subject_type'], gw['batch_id'], gw['lot_id']],
      ['grading', 'batch', toGrade.id, null],
    );
    final gp = (gw['payload']! as Map).cast<String, Object?>();
    expectSchema(gp, 'GradingPayload');
    expectQuantity(gp['quantity'], '180', 'kg');
    expect(gp['declared_grade'], 'Special');

    // On to packing, capped by the 180 kg just graded.
    await tapOn(tester, button('Pack'));
    expect(find.text('Graded: 180 kg'), findsOneWidget);
    await typeDigits(tester, '200');
    expect(find.text('200 kg is more than the 180 kg graded. Check the weight.'), findsWidgets);
    expect(enabled(tester, 'Save'), isFalse);
    await tapOn(tester, find.bySemanticsLabel('Delete'));
    await tapOn(tester, find.bySemanticsLabel('Delete'));
    await tapOn(tester, find.bySemanticsLabel('Delete'));
    await typeDigits(tester, '175');
    await tapOn(tester, tile('Packs'));
    await typeDigits(tester, '700');
    await tapOn(tester, button('Save'));
    final packing = (await savedEntries(f.db))['final_packing']!.single;
    final pw = (await entryToWire(f.db, packing))!['data']! as Map;
    expect([pw['subject_type'], pw['batch_id']], ['batch', toGrade.id]);
    final pp = (pw['payload']! as Map).cast<String, Object?>();
    expectSchema(pp, 'FinalPackingPayload');
    expectQuantity(pp['quantity'], '175', 'kg');
    expect(pp['packs'], 700);
    expect(pp.containsKey('pack_size'), isFalse, reason: 'left empty, so not sent');
  });
}
