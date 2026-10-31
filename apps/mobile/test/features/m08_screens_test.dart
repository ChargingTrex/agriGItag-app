// M08 screens through the real router: the Sell QR payload (decoded the way M11 decodes it), Money cards, History with
// the 24-hour Undo on both sides of the boundary, and Settings (language flips strings and the next voice prompt,
// Wi-Fi-only photos default off, the 7-day unsent warning, Send now).
// Requirement: plan §7.2 M08 acceptance (QR `{lotId, farmerId, packedKg, sig}` scans in M11; undo at 24 h − 1 min
//   works, + 1 min absent; language toggle flips strings + next voice prompt); PLAN §13 B5; UserFlows §Selling to the
//   FPO, §When things go wrong (Wrong entry), §Design rules.
// Callers: flutter test (CI mobile job).

import 'dart:convert';

import 'package:agritrace/core/db/daos/entries_dao.dart' show undoEntryType;
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/sell/sell_qr.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../auth/harness.dart' show playedClips;
import '../db/db_fixtures.dart';
import 'harness.dart';

/// The payload of the Sell QR on screen, decoded as M11 decodes it. Fails when there is no QR or it does not verify.
SellQr shownQr(WidgetTester tester) {
  final key = tester.widget<QrImageView>(find.byType(QrImageView)).key! as ValueKey<String>;
  return SellQr.decode(key.value)!;
}

void main() {
  group('SellQr', () {
    const qr = SellQr(lotId: '0190a1b2-c3d4-7e5f-8a9b-0c1d2e3f4a5b', farmerId: 'f-9', packedKg: 1200.04);

    test('encodes compact JSON {lotId, farmerId, packedKg, sig} and decodes it back', () {
      final text = qr.encode();
      final m = jsonDecode(text) as Map<String, dynamic>;
      expect(m.keys, ['lotId', 'farmerId', 'packedKg', 'sig']);
      expect(m['packedKg'], 1200.0);
      // 8 bytes base64url without padding = 11 characters.
      expect(m['sig'], hasLength(11));
      expect(text, isNot(contains(' ')));
      final back = SellQr.decode(text)!;
      expect((back.lotId, back.farmerId, back.packedKg), (qr.lotId, 'f-9', 1200.0));
    });

    test('refuses a changed field, a wrong sig, non-JSON and missing keys', () {
      final m = jsonDecode(qr.encode()) as Map<String, dynamic>;
      expect(SellQr.decode(jsonEncode({...m, 'packedKg': 1300.0})), isNull);
      expect(SellQr.decode(jsonEncode({...m, 'sig': 'AAAAAAAAAAA'})), isNull);
      expect(SellQr.decode('agritrace://auth?phone=1'), isNull);
      expect(SellQr.decode(jsonEncode({'lotId': 'x'})), isNull);
      expect(SellQr.decode('[1,2]'), isNull);
      // A value finer than the sig covers decodes as the signed one-decimal value.
      expect(SellQr.decode(jsonEncode({...m, 'packedKg': 1200.04}))!.packedKg, 1200.0);
    });
  });

  group('Sell', () {
    testWidgets('one ready lot: 1 tap from home shows its QR, field, packed kg (offline packing) and code', (
      tester,
    ) async {
      final h = FlowHarness();
      await h.start(tester);
      // Packing logged offline: the server's packed kg is still 0, the phone's packing entry says 300 kg.
      await h.setLot('lot-1', 'ready_for_sale');
      await h.saveEntry('packing', flowNow, payload: '{"quantity":{"value":300,"unit":"kg"},"bags":6}');
      await h.tap(tester, find.text('Sell'));
      final qr = shownQr(tester);
      expect((qr.lotId, qr.farmerId, qr.packedKg), ('lot-1', 'farmer-1', 300.0));
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('300 kg'), findsOneWidget);
      expect(find.text('Show this code at the collection centre.'), findsOneWidget);
      expect(h.taps, 1);
      await h.dispose(tester);
    });

    testWidgets('two ready lots: pick the field, then the QR carries the server packed kg', (tester) async {
      final h = FlowHarness();
      await h.start(tester, lots: 2);
      await h.setLot('lot-1', 'ready_for_sale', kgPacked: 50);
      await h.setLot('lot-2', 'ready_for_sale', kgPacked: 120000.5);
      h.go('/home/sell');
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsNothing);
      expect(find.text("Which field's crop are you selling?"), findsOneWidget);
      await h.tap(tester, find.text('Field 2'));
      expect(shownQr(tester).lotId, 'lot-2');
      expect(shownQr(tester).packedKg, 120000.5);
      expect(find.text('1,20,000.5 kg'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('nothing ready: one sentence, no QR', (tester) async {
      final h = FlowHarness();
      await h.start(tester, location: '/home/sell');
      expect(find.text('Nothing is ready to sell yet. Log packing first.'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
      await h.dispose(tester);
    });
  });

  testWidgets('Money: one card per lot with status word and packed kg', (tester) async {
    final h = FlowHarness();
    await h.start(tester, lots: 2);
    await h.setLot('lot-2', 'received', kgPacked: 300);
    h.go('/home/money');
    await tester.pumpAndSettle();
    expect(find.text('Field 1'), findsOneWidget);
    expect(find.text('Growing'), findsOneWidget);
    expect(find.text('Field 2'), findsOneWidget);
    expect(find.text('Received by FPO'), findsOneWidget);
    expect(find.text('Packed: 300 kg'), findsOneWidget);
    // The open lot has packed nothing: no "Packed" line for it.
    expect(find.textContaining('Packed:'), findsOneWidget);
    await h.dispose(tester);
  });

  group('History', () {
    testWidgets('shows only the signed-in user\'s entries, never ones the server marked undone (D-029)', (
      tester,
    ) async {
      final h = FlowHarness();
      await h.start(tester, withHistory: false);
      // Another user of this shared phone logged a harvest; the server undid this user's problem entry.
      final other = entryAt(
        at: flowNow,
      ).copyWith(entryType: const Value('harvest'), enteredByUserId: const Value('user-2'));
      await h.db.entriesDao.save(other, const []);
      final undone = await h.saveEntry('problem', flowNow);
      await (h.db.update(
        h.db.entries,
      )..where((e) => e.entryId.equals(undone))).write(const EntriesCompanion(status: Value(EntryStatus.undone)));
      await h.saveEntry('drying', flowNow);
      h.go('/home/history');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Drying'), findsOneWidget);
      // A typed link to the other user's entry finds nothing to undo either.
      h.go('/home/history/${other.entryId.value}');
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('lists standing entries newest first with "14 Feb" dates and status words', (tester) async {
      final h = FlowHarness();
      await h.start(tester);
      final sent = await h.saveEntry('harvest', flowNow);
      await h.db.entriesDao.markConfirmed(sent, flowNow);
      final undone = await h.saveEntry('problem', flowNow.subtract(const Duration(hours: 1)));
      await h.db.entriesDao.undo(undone, now: flowNow);
      await h.tap(tester, find.text('History'));
      final titles = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title! as Text).data).toList();
      // The undone problem is gone; harvest of 14 Feb first, then the seeded 10 Feb history, last logged (drying) first.
      expect(titles.take(2), ['Harvest', 'Drying']);
      expect(titles, isNot(contains('Problem')));
      expect(titles, hasLength(6));
      expect(find.text('14 Feb'), findsOneWidget);
      expect(find.text('10 Feb'), findsNWidgets(5));
      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('Not sent'), findsNWidgets(5));
      await h.dispose(tester);
    });

    for (final (name, offset, undoable) in [
      ('24 h − 1 min: Undo works', const Duration(hours: 23, minutes: 59), true),
      ('24 h + 1 min: Undo is absent', const Duration(hours: 24, minutes: 1), false),
    ]) {
      testWidgets('entry detail at $name', (tester) async {
        final h = FlowHarness();
        await h.start(tester);
        await h.setLot('lot-1', 'ready_for_sale');
        final id = await h.saveEntry('packing', flowNow, payload: '{"quantity":{"value":300,"unit":"kg"},"bags":6}');
        h.now = flowNow.add(offset);
        h.go('/home/history');
        await tester.pumpAndSettle();
        await h.tap(tester, find.text('Packing'));
        expect(find.text('Packing, 14 Feb.'), findsOneWidget);
        if (!undoable) {
          expect(find.text('Undo'), findsNothing);
          expect(find.text('Only the field officer can correct this now.'), findsOneWidget);
          await h.dispose(tester);
          return;
        }
        await h.tap(tester, find.text('Undo'));
        expect(h.path, '/home/history');
        expect(find.text('Packing'), findsNothing);
        final rows = await (h.db.select(h.db.entries)..where((e) => e.rootId.equals(id))).get();
        expect(
          {for (final r in rows) r.entryType: r.status},
          {'packing': EntryStatus.undone, undoEntryType: EntryStatus.saved},
        );
        expect(rows.firstWhere((r) => r.entryType == undoEntryType).deviceTime, h.now);
        expect(h.kicks, 1);
        // The lot this packing made ready goes back to open (preview), so Sell no longer offers it.
        final lot = await (h.db.select(h.db.lots)..where((l) => l.lotId.equals('lot-1'))).getSingle();
        expect(lot.status, 'open');
        await h.dispose(tester);
      });
    }
  });

  group('Settings', () {
    testWidgets('language button flips the strings and the next voice prompt', (tester) async {
      final h = FlowHarness();
      await h.start(tester, location: '/settings');
      playedClips.clear();
      await tester.tap(find.text('Voice tour'));
      await tester.pumpAndSettle();
      expect(playedClips, ['assets/audio/en/onboardTour.ogg']);

      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      expect(find.text('அமைப்புகள்'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(h.container.read(sessionProvider).locale, tamil);

      await tester.tap(find.text('குரல் வழிகாட்டி'));
      await tester.pumpAndSettle();
      expect(playedClips.last, 'assets/audio/ta/onboardTour.ogg');
      await h.dispose(tester);
    });

    testWidgets('Photos on Wi-Fi only: off by default, the switch stores it for the sync engine', (tester) async {
      final h = FlowHarness();
      await h.start(tester, location: '/settings');
      // Settings has two switches since M12 (Reminders); this test is about the Wi-Fi one.
      final tile = find.widgetWithText(SwitchListTile, 'Photos on Wi-Fi only');
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
      expect((await h.db.sessionDao.read())!.wifiOnlyPhotos, isFalse);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect((await h.db.sessionDao.read())!.wifiOnlyPhotos, isTrue);
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      await h.dispose(tester);
    });

    for (final (name, age, warned) in [
      ('waiting 6 days 23 h: the plain reminder', const Duration(days: 6, hours: 23), false),
      ('waiting 7 days: red triangle and the spoken warning', const Duration(days: 7), true),
    ]) {
      testWidgets('unsent entries $name; Send now kicks a send', (tester) async {
        final h = FlowHarness();
        await h.start(tester, withHistory: false);
        await h.saveEntry('harvest', flowNow.subtract(age));
        h.go('/settings');
        await tester.pumpAndSettle();
        final warning = find.text(
          'Some entries have waited more than 7 days. Get signal to send them, or call your officer.',
        );
        expect(warning, warned ? findsOneWidget : findsNothing);
        expect(find.text('Needs attention'), warned ? findsOneWidget : findsNothing);
        expect(
          find.text('Entries not sent yet: 1. They stay on this phone; get signal to send them.'),
          warned ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.text('Send now'));
        expect(h.kicks, 1);
        await h.dispose(tester);
      });
    }
  });
}
