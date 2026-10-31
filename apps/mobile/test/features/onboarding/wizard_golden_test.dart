// Pixel goldens of the onboarding consent, location (GPS ring with "Save anyway") and crop (GI tick) steps, in
//   English and Tamil at text scale 1.0 and 1.5 on a 360 x 640 dp phone (tag `golden`, macOS only for now).
// Requirement: PLAN §7.2 M09 tests ("goldens for consent, location and crop steps (en/ta x 1.0/1.5, macOS-tagged)"),
//   UserFlows §Design rules ("Big targets", "Language first", "Colour plus shape").
// Callers: flutter test on macOS (developers); skipped on Linux CI until re-recorded there (Q01).
// Re-record with `flutter test --update-goldens test/features/onboarding/wizard_golden_test.dart` and review the PNGs.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'onboarding_harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip (same as M05/M06).
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// One golden per step x locale x text scale (3 x 2 x 2 = 12).
void main() {
  if (_skipReason != null) debugPrint('wizard_golden_test: SKIPPED ($_skipReason)');
  for (final step in [OnboardingStep.consent, OnboardingStep.location, OnboardingStep.crop]) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        final name = '${step.name}_${locale.languageCode}_x$scale';
        testWidgets('onboarding $name golden', skip: _skipReason != null, (tester) async {
          final f = await pumpWizard(tester, locale: locale, textScale: scale);
          await showStep(tester, f, step);
          if (step == OnboardingStep.location) {
            await tapOn(tester, button(locale == tamil ? 'வயலில் நிற்கிறேன்' : 'In field'));
            f.gps.add(fixAt(insideGi.lat, insideGi.lng, 35));
            await tester.pump(const Duration(seconds: 61));
            await tester.pumpAndSettle();
          }
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../goldens/onboarding/$name.png'));
        });
      }
    }
  }
}
