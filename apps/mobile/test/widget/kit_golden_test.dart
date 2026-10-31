// Widget-kit pixel goldens: every widget in ta and en, at text scale 1.0 and 1.5, on 360x640 and 412x915
//   (tag `golden`, macOS only for now, like farmer_button_golden_test.dart).
// Requirement: plan §7.2 M05 acceptance "goldens en+ta x scale 1.0/1.5 x 360x640/412x915"; mobile-design.md
//   §6 (contrast >= 4.5:1 in goldens, checked by textContrastGuideline in kit_test.dart).
// Callers: flutter test on macOS (developers); skipped on the Linux CI runner until re-recorded there.
// Re-record with `flutter test --update-goldens test/widget/kit_golden_test.dart` and review the PNGs.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/core/router/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kit_harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip (same as M00).
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// One golden per widget x locale x text scale x screen size (11 x 2 x 2 x 2 = 88).
void main() {
  if (_skipReason != null) debugPrint('kit_golden_test: SKIPPED ($_skipReason)');
  for (final sample in kitSamples) {
    for (final locale in [english, tamil]) {
      for (final textScale in textScales) {
        for (final size in screenSizes) {
          final stem =
              '${sample.name}_${locale.languageCode}_x${textScale}_${size.width.toInt()}x${size.height.toInt()}';
          testWidgets('golden $stem', skip: _skipReason != null, (tester) async {
            await pumpSample(tester, sample, locale: locale, size: size, textScale: textScale);
            await expectLater(find.byType(MaterialApp), matchesGoldenFile('../goldens/kit/$stem.png'));
          });
        }
      }
    }
  }
}
