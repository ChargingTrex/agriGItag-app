// Accessibility sweep over every M10 screen state, reached through the real router as a field officer: 56 dp tap
//   targets, labelled tap targets, text contrast and no overflow, on the smallest phone (360 x 640) in Tamil and English
//   at 1.0x and 1.5x (the M07/M09 sweep pattern).
// Requirement: UserFlows §Design rules ("Big targets ... at least 56 dp"; officer screens follow the rules "where they
//   can"); mobile-design.md §6; plan §7.2 M10 tests.
// Callers: flutter test (CI mobile job).

import 'package:agritrace/core/router/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart';
import 'officer_fixtures.dart';

/// Farmer minimum tap target (FarmerTokens.minTarget), as in the M05/M07 sweeps.
const _tapTarget = MinimumTapTargetGuideline(
  size: Size.square(56),
  link: 'docs/source/AgriTrace — User Flows.md §Design rules "Big targets"',
);

/// One screen state: its [name], where it [start]s and the English taps that [drive] the app there (after the flags
/// are seeded).
typedef _State = ({String name, String start, List<String> drive});

/// Every M10 screen state; `assist` states first tap Murugan on the officer home.
const List<_State> _states = [
  (name: 'officer home', start: '/officer', drive: []),
  (name: 'assisted farmer home', start: '/officer', drive: ['Murugan']),
  (name: 'assisted event grid', start: '/officer', drive: ['Murugan', 'Log']),
  (name: 'moisture: meters', start: '/officer', drive: ['Murugan', 'Moisture']),
  (
    name: 'moisture: past-due meter',
    start: '/officer',
    drive: ['Murugan', 'Moisture', 'Old meter, calibrated to 10 Feb'],
  ),
  (name: 'moisture: number pad', start: '/officer', drive: ['Murugan', 'Moisture', 'Wile 55, calibrated to 1 Mar']),
  (name: 'flags list', start: '/officer/flags', drive: []),
  (name: 'flag detail (warn)', start: '/officer/flags/$warnFlag', drive: []),
  (name: 'flag detail (hold)', start: '/officer/flags/$holdFlag', drive: []),
  (name: 'flag fix it', start: '/officer/flags/$warnFlag', drive: ['Fix it']),
];

void main() {
  for (final s in _states) {
    for (final locale in [tamil, english]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('${s.name} ${locale.languageCode} x$scale: 56 dp targets, labels, contrast', (tester) async {
          final semantics = tester.ensureSemantics();
          final h = FlowHarness();
          await startOfficer(tester, h, location: s.start);
          await h.seedFlags();
          await tester.pumpAndSettle();
          for (final label in s.drive) {
            await h.tap(tester, find.text(label).first);
          }
          tester.view.physicalSize = const Size(360, 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          h.container.read(sessionProvider.notifier).setLocale(locale);
          // An overflow at 1.5x on 360 x 640 throws here and fails the test.
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(_tapTarget));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await h.dispose(tester);
          semantics.dispose();
        });
      }
    }
  }
}
