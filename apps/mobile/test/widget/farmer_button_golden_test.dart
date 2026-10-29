// FarmerButton pixel goldens at 56 dp and 64 dp, in English and Tamil (tag `golden`, macOS only for now).
// Requirement: plan §7.2 M00 acceptance "FarmerButton golden at 56/64 dp"; M05 goldens en+ta.
// Callers: flutter test on macOS (developers); skipped on the Linux CI runner until re-recorded there.
// Re-record with `flutter test --update-goldens test/widget/farmer_button_golden_test.dart` and review the PNGs.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/widgets/farmer_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'farmer_button_harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip.
/// CoreText (macOS) and FreeType (Linux) anti-alias glyph edges differently, and raising the 0.5 %
/// tolerance instead would stop the goldens catching real size regressions.
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// One golden per locale x size.
void main() {
  if (_skipReason != null) debugPrint('farmer_button_golden_test: SKIPPED ($_skipReason)');
  for (final locale in [english, tamil]) {
    for (final prominent in [false, true]) {
      final height = prominent ? 64 : 56;
      testWidgets('FarmerButton ${locale.languageCode} $height dp golden', skip: _skipReason != null, (tester) async {
        await pumpFarmerButton(tester, locale, prominent: prominent);
        await expectLater(
          find.byType(FarmerButton),
          matchesGoldenFile('../goldens/farmer_button_${locale.languageCode}_$height.png'),
        );
      });
    }
  }
}
