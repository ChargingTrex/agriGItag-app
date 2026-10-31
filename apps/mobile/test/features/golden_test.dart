// Pixel goldens of the M07 farmer screens F03 home, F04 choose event, F07 confirm and F08 saved, in Tamil and English at
// text scale 1.0 and 1.5 on a 360 x 640 phone (tag `golden`, macOS only, like the M05 kit goldens).
// Requirement: plan §7.2 M07 ("goldens for F03, F04, F07, F08 (en/ta × 1.0/1.5)"); mobile-design.md §6.
// Callers: flutter test on macOS. Re-record with `flutter test --update-goldens test/features/golden_test.dart` and
//   review the PNGs in test/goldens/m07/.
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
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip (same as M00/M05).
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// The four screens: golden stem, start location and the English taps that reach it.
final screens = <(String, String, List<String>)>[
  ('f03_home', '/home', []),
  ('f04_choose', '/log', []),
  ('f07_confirm', '/log/harvest', ['Next', 'Take photo']),
  ('f08_saved', '/log/harvest', ['Next', 'Take photo', 'Correct']),
];

void main() {
  for (final (stem, start, taps) in screens) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        final name = '${stem}_${locale.languageCode}_x$scale';
        testWidgets('golden $name', skip: _skipReason != null, (tester) async {
          // pending: 2 shows the grey cloud of "Saved. Will send when signal comes." on F08.
          final h = FlowHarness(pending: 2);
          await h.start(tester, location: start);
          for (final t in taps) {
            await h.tap(tester, find.text(t));
          }
          tester.view.physicalSize = const Size(360, 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          h.container.read(sessionProvider.notifier).setLocale(locale);
          await tester.pumpAndSettle();
          // Asset images decode on real I/O, which the fake-async test zone never runs by itself.
          final context = tester.element(find.byType(Scaffold).last);
          await tester.runAsync(() async {
            for (final e in [...FarmEvent.values.map((e) => e.asset), 'assets/images/events/product.webp']) {
              await precacheImage(AssetImage(e), context);
            }
          });
          await tester.pumpAndSettle();
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../goldens/m07/$name.png'));
          await h.dispose(tester);
        });
      }
    }
  }
}
