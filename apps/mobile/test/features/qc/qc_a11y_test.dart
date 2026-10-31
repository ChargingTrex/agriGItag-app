// Accessibility sweep over every QC screen, each shown as a pushed route in its busiest state, in Tamil and English
//   at text scale 1.0 and 1.5: tap targets >= 56 dp, labelled targets, text contrast, no overflow or exception.
// Requirement: PLAN §7.2 M11 tests ("the accessibility sweep pattern from M07/M09 (56 dp, labels, scale 1.5)"),
//   UserFlows §Design rules "Big targets", mobile-design.md §6 (Semantics, contrast >= 4.5:1, text scale 1.0-1.5).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/core/router/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qc_harness.dart';

/// Minimum tap target of the app (FarmerTokens.minTarget); QC controls are held to the farmer size.
const _tapTarget = MinimumTapTargetGuideline(
  size: Size.square(56),
  link: 'UserFlows §Design rules: buttons are at least 56 dp tall',
);

void main() {
  for (final shot in QcShot.values) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('${shot.name} ${locale.languageCode} x$scale: 56 dp targets, labels, contrast', (tester) async {
          await pumpQc(tester, screenOf(shot), locale: locale, textScale: scale, pushed: true);
          await fillShot(tester, shot);
          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(_tapTarget));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        });
      }
    }
  }
}
