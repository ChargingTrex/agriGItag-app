// Widget tests of each QC screen state: scan (unknown code, pick-lot fallback with open/drying lots, empty list), code lookup, intake
//   (exact 5 % stays green, moisture within the limit, field config hides and requires, no meter, implausible value),
//   grading (missing → grey, visual moisture refused, out of range, no standard, Bluetooth row disabled), batch list
//   (no signal → sentence + Try again, empty), packing (graded weight unknown, required by config).
// Requirement: PLAN §7.2 M11 tests ("widget tests for each screen state"); UserFlows §Selling to the FPO, §Grade a
//   batch; FR44, FR50; D-017, D-036.
// Callers: flutter test (CI mobile job).

import 'dart:convert';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/features/qc_grading/batch_list_screen.dart';
import 'package:agritrace/features/qc_grading/grading_screen.dart';
import 'package:agritrace/features/qc_home/qc_common.dart';
import 'package:agritrace/features/qc_intake/intake_screen.dart';
import 'package:agritrace/features/qc_intake/scan_screen.dart';
import 'package:agritrace/features/sell/sell_qr.dart';
import 'package:agritrace/features/qc_packing/packing_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qc_harness.dart';

/// The stored lot as the lot card shows it.
const _lot = QcLot(lotId: lotId, farmerId: farmerId, farmerName: 'Murugan', packedKg: 200, cropId: cropId);

void main() {
  group('scan', () {
    testWidgets('an unknown code says it is not on this phone', (tester) async {
      final f = await pumpQc(tester, const ScanScreen());
      f.scanned = 'LOT0EF81415';
      await tapOn(tester, find.text('Fake scan'));
      expect(find.text('This lot is not on this phone. Sync and scan again.'), findsOneWidget);
      expect(find.byType(IntakeScreen), findsNothing);
    });

    testWidgets('Back from the intake shows a paused camera, so a QR still in view does not reopen it', (tester) async {
      final f = await pumpQc(tester, const ScanScreen());
      f.scanned = lotQr;
      await tapOn(tester, find.text('Fake scan'));
      expect(find.byType(IntakeScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Fake scan'), findsNothing);
      await tapOn(tester, find.byIcon(Icons.qr_code_scanner));
      expect(find.text('Fake scan'), findsOneWidget);
    });

    testWidgets('"Pick lot" lists the ready lots; a tap opens the intake check', (tester) async {
      await pumpQc(tester, const ScanScreen());
      await tapOn(tester, button('Pick lot'));
      expect(find.text('Tap the lot to receive.'), findsOneWidget);
      await tapOn(tester, find.text('Murugan'));
      expect(find.byType(IntakeScreen), findsOneWidget);
      expect(find.text('200 kg'), findsOneWidget);
    });

    testWidgets('"Pick lot" also lists open and drying lots (the QC phone never sees ready_for_sale)', (tester) async {
      final f = await pumpQc(tester, const ScanScreen());
      await (f.db.update(f.db.lots)).write(const LotsCompanion(status: Value('open')));
      await f.db
          .into(f.db.lots)
          .insert(
            LotsCompanion.insert(
              lotId: 'lot-2',
              plotId: 'plot-1',
              farmerId: farmerId,
              cropId: cropId,
              season: '2026-rabi',
              status: 'drying',
              kgPacked: const Value(150),
              updatedAt: DateTime.utc(2026, 10, 31),
            ),
          );
      await tapOn(tester, button('Pick lot'));
      expect(find.text('Packed: 150 kg'), findsOneWidget);
      expect(find.text('Packed: 200 kg'), findsOneWidget);
    });

    testWidgets('no ready lot → one sentence', (tester) async {
      final f = await pumpQc(tester, const ScanScreen());
      await (f.db.update(f.db.lots)).write(const LotsCompanion(status: Value('received')));
      await tapOn(tester, button('Pick lot'));
      expect(find.text('No lot on this phone is ready to sell. Sync and try again.'), findsOneWidget);
    });
  });

  group('resolveLot', () {
    testWidgets('QR of a stored lot, bare id, QR of a lot not pulled yet, lot code', (tester) async {
      final f = await pumpQc(tester, const SizedBox());
      final stored = (await tester.runAsync(() => resolveLot(f.db, lotQr)))!;
      expect([stored.farmerName, stored.packedKg, stored.cropId, stored.unverified], ['Murugan', 200, cropId, false]);
      expect((await tester.runAsync(() => resolveLot(f.db, lotId)))!.lotId, lotId);
      final other = {
        'lotId': 'other',
        'farmerId': 'f-9',
        'packedKg': 75.5,
        'sig': SellQr(lotId: 'other', farmerId: 'f-9', packedKg: 75.5).sig,
      };
      final fromQr = (await tester.runAsync(() => resolveLot(f.db, jsonEncode(other))))!;
      expect(
        [fromQr.lotId, fromQr.farmerId, fromQr.farmerName, fromQr.packedKg, fromQr.cropId, fromQr.unverified],
        ['other', 'f-9', null, 75.5, null, true],
      );
      // Forged: the packed weight raised after the QR was made, so the M08 checksum no longer matches.
      final forged = jsonEncode({...other, 'packedKg': 95.5});
      expect(await tester.runAsync(() => resolveLot(f.db, forged)), isNull);
      expect(SellQr.decode(forged), isNull);
      // A stored lot with a wrong checksum is refused too, rather than trusted by id.
      expect(await tester.runAsync(() => resolveLot(f.db, jsonEncode({...other, 'lotId': lotId}))), isNull);
      expect(await tester.runAsync(() => resolveLot(f.db, 'LOT0EF81415')), isNull);
      expect(await tester.runAsync(() => resolveLot(f.db, jsonEncode({'lotId': 'other'}))), isNull);
      expect(await tester.runAsync(() => resolveLot(f.db, '42')), isNull);
    });
  });

  group('intake', () {
    testWidgets('exactly 5 % apart stays green; 10.9 % is within the limit', (tester) async {
      await pumpQc(tester, const IntakeScreen(lot: _lot));
      await typeDigits(tester, '210');
      expect(find.text('Weight matches the packed quantity.'), findsOneWidget);
      await tapOn(tester, tile('Moisture'));
      await typeDigits(tester, '10.9');
      expect(find.text('Moisture is within the 11 % limit.'), findsOneWidget);
    });

    testWidgets('an unverified lot (QR only) gets no weight check against the QR packed weight', (tester) async {
      const qrOnly = QcLot(lotId: 'other', farmerId: 'f-9', packedKg: 200, unverified: true);
      await pumpQc(tester, const IntakeScreen(lot: qrOnly));
      expect(find.textContaining('Not on this phone yet'), findsOneWidget);
      for (final weight in ['200', '0']) {
        // 200 would be a tick and 2000 an orange line if the forgeable QR weight were trusted (D-035).
        await typeDigits(tester, weight);
        expect(find.text('Weight matches the packed quantity.'), findsNothing);
        expect(find.textContaining('more than 5 % apart'), findsNothing);
      }
    });

    testWidgets('field config: price hidden, moisture reading required', (tester) async {
      await pumpQc(
        tester,
        const IntakeScreen(lot: _lot),
        fieldConfig: {
          'event_intake': [
            {'name': 'received', 'required': true, 'enabled': true},
            {'name': 'moisture_reading_id', 'required': true, 'enabled': true},
          ],
        },
      );
      expect(find.text('Price per kg'), findsNothing);
      await typeDigits(tester, '200');
      expect(find.text('Enter Moisture to save.'), findsOneWidget);
      expect(enabled(tester, 'Save'), isFalse);
    });

    testWidgets('no meter on the phone → sentence; Bluetooth row is disabled "Coming soon"', (tester) async {
      await pumpQc(tester, const IntakeScreen(lot: _lot), instruments: false);
      expect(find.text('No meter on this phone. Ask the FPO admin to register one.'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      final ble = tester.widget<ListTile>(
        find.ancestor(of: find.text('Instrument (Bluetooth)'), matching: find.byType(ListTile)),
      );
      expect(ble.onTap, isNull);
    });

    testWidgets('an implausible moisture blocks Save with the range', (tester) async {
      await pumpQc(tester, const IntakeScreen(lot: _lot));
      await tapOn(tester, tile('Moisture'));
      await typeDigits(tester, '150');
      await tapOn(tester, find.text('Delmhorst G-7'));
      expect(find.text('Outside 0 to 100 %: check the reading.'), findsWidgets);
      expect(enabled(tester, 'Save'), isFalse);
    });
  });

  group('grading', () {
    testWidgets('missing moisture → grey preview; a source per reading; out of range blocks', (tester) async {
      await pumpQc(tester, const GradingScreen(batch: toGrade));
      await tapOn(tester, tileOf('extraneous_matter'));
      await typeDigits(tester, '1');
      expect(find.text('No grade yet. Missing: Moisture'), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Icons.hourglass_empty)).color, pendingGlyph.color);
      expect(find.text('Pick the instrument to save the reading.'), findsOneWidget);
      await tapOn(tester, sourceOf('visual'));
      // Moisture offers no "Visual" (FR44) and keeps its own source: the visual pick above was for extraneous matter.
      await tapOn(tester, tileOf('moisture'));
      expect(sourceOf('visual'), findsNothing);
      await typeDigits(tester, '10');
      expect(find.text('Pick the instrument to save the reading.'), findsOneWidget);
      expect(enabled(tester, 'Save'), isFalse);
      await tapOn(tester, sourceOf(meterId));
      expect(find.text('Grade: Special'), findsOneWidget);
      await typeDigits(tester, '00'); // 1000 %
      expect(find.text('Outside 0 to 100 %: check the reading.'), findsWidgets);
      expect(enabled(tester, 'Save'), isFalse);
    });

    testWidgets('no standard on the phone → one sentence', (tester) async {
      await pumpQc(tester, const GradingScreen(batch: toGrade), standards: false);
      expect(find.text('The grading standard is not on this phone. Sync first.'), findsOneWidget);
    });
  });

  group('instruments', () {
    testWidgets('meters come from the API, are cached, and stay when offline', (tester) async {
      var online = true;
      final f = await pumpQc(
        tester,
        const IntakeScreen(lot: _lot),
        instruments: false,
        fetchInstruments: () async {
          if (!online) throw DioException(requestOptions: RequestOptions(path: '/v1/instruments'));
          return [
            InstrumentsCompanion.insert(
              instrumentId: 'm-1',
              kind: 'moisture_meter',
              label: 'Wile 55 SN-9',
              calibrationDueDate: DateTime(2099, 1, 1),
            ),
          ];
        },
      );
      expect(find.text('Wile 55 SN-9'), findsOneWidget);
      online = false;
      f.container.invalidate(qcInstrumentsProvider);
      await tester.pumpAndSettle();
      expect(find.text('Wile 55 SN-9'), findsOneWidget);
      expect((await tester.runAsync(() => f.db.select(f.db.instruments).get()))!.single.instrumentId, 'm-1');
    });
  });

  group('batch list', () {
    testWidgets('no signal → sentence and Try again', (tester) async {
      await pumpQc(tester, const BatchListScreen(), batches: null);
      expect(find.text('No signal. Batches need the internet.'), findsOneWidget);
      expect(enabled(tester, 'Try again'), isTrue);
    });

    testWidgets('lists the batches with their next step; "To pack" opens packing at the graded weight', (tester) async {
      await pumpQc(tester, const BatchListScreen());
      expect(find.text('To grade'), findsOneWidget);
      expect(find.text('To pack'), findsOneWidget);
      await tapOn(tester, find.text('Batch HQ2K9P7M4X1A: 200 kg'));
      expect(find.text('Graded: 180 kg'), findsOneWidget);
    });

    testWidgets('no batch waiting → sentence', (tester) async {
      await pumpQc(tester, const BatchListScreen(), batches: const []);
      expect(find.text('No batch is waiting for grading or packing.'), findsOneWidget);
    });
  });

  group('packing', () {
    testWidgets('graded weight unknown blocks Save', (tester) async {
      await pumpQc(tester, const PackingScreen(batch: toGrade, gradedKg: null));
      await typeDigits(tester, '100');
      expect(find.text('Graded weight unknown. Grade the batch first.'), findsOneWidget);
      expect(enabled(tester, 'Save'), isFalse);
    });

    testWidgets('field config: packed weight required, price hidden', (tester) async {
      await pumpQc(
        tester,
        const PackingScreen(batch: toPack, gradedKg: '180'),
        fieldConfig: {
          'event_final_packing': [
            {'name': 'quantity', 'required': true, 'enabled': true},
            {'name': 'packs', 'required': false, 'enabled': true},
          ],
        },
      );
      expect(find.text('Average price per kg'), findsNothing);
      await tapOn(tester, tile('Packs'));
      await typeDigits(tester, '10');
      expect(find.text('Enter Packed weight to save.'), findsOneWidget);
      expect(enabled(tester, 'Save'), isFalse);
    });
  });
}
