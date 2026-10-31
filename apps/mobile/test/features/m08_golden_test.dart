// Pixel goldens of the M08 Sell QR and History screens, in Tamil and English at text scale 1.0 and 1.5 on a 360 x 640
// phone (tag `golden`, macOS only, like the M05/M07 goldens).
// Requirement: plan §7.2 M08 ("goldens for Sell and History en/ta at 1.0/1.5"); mobile-design.md §6.
// Callers: flutter test on macOS. Re-record with `flutter test --update-goldens test/features/m08_golden_test.dart` and
//   review the PNGs in test/goldens/m08/.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/event_log/farm_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip (same as M00/M05/M07).
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

void main() {
  for (final (stem, location) in [('f10_sell', '/home/sell'), ('f12_history', '/home/history')]) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        final name = '${stem}_${locale.languageCode}_x$scale';
        testWidgets('golden $name', skip: _skipReason != null, (tester) async {
          final h = FlowHarness();
          await h.start(tester);
          // A ready lot for Sell; one confirmed entry so History shows both "Sent" and "Not sent".
          await h.setLot('lot-1', 'ready_for_sale', kgPacked: 1200);
          await h.db.entriesDao.markConfirmed(await h.saveEntry('harvest', flowNow), flowNow);
          h.go(location);
          tester.view.physicalSize = const Size(360, 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          h.container.read(sessionProvider.notifier).setLocale(locale);
          await tester.pumpAndSettle();
          // Asset images decode on real I/O, which the fake-async test zone never runs by itself.
          final context = tester.element(find.byType(Scaffold).last);
          await tester.runAsync(() async {
            for (final e in FarmEvent.values) {
              await precacheImage(AssetImage(e.asset), context);
            }
          });
          await tester.pumpAndSettle();
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../goldens/m08/$name.png'));
          await h.dispose(tester);
        });
      }
    }
  }
}
