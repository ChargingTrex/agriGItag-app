// Accessibility sweep over every onboarding step, each shown as a pushed route in Tamil and English at text scale
//   1.0 and 1.5: tap targets >= 56 dp (farmer taps; officer controls are held to the same size), labelled targets,
//   text contrast, no overflow.
// Requirement: PLAN §7.2 M09 tests ("accessibility sweep over all steps pushed as routes"), UserFlows §Design rules
//   "Big targets", mobile-design.md §6 (Semantics, contrast >= 4.5:1, text scale 1.0-1.5).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_notifier.dart' show OnboardingStep;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'onboarding_harness.dart';

/// Farmer minimum tap target (FarmerTokens.minTarget).
const _farmerTapTarget = MinimumTapTargetGuideline(
  size: Size.square(56),
  link: 'UserFlows §Design rules: buttons are at least 56 dp tall',
);

void main() {
  for (final step in OnboardingStep.values) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('${step.name} ${locale.languageCode} x$scale: 56 dp targets, labels, contrast', (tester) async {
          final f = await pumpWizard(tester, locale: locale, textScale: scale, pushed: true);
          await showStep(tester, f, step);
          if (step == OnboardingStep.location) {
            // The ring state, after "Save anyway" appears (the step's busiest screen).
            await tapOn(tester, button(locale == tamil ? 'வயலில் நிற்கிறேன்' : 'In field'));
            f.gps.add(fixAt(insideGi.lat, insideGi.lng, 35));
            await tester.pump(const Duration(seconds: 61));
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(_farmerTapTarget));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        });
      }
    }
  }
}
