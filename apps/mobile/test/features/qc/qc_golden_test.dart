// Pixel goldens of the QC intake check (230 vs 200 kg and 11.5 % moisture, both orange) and the grading form (grade
//   preview with the standard and edition), in English and Tamil at text scale 1.0 and 1.5 on a 360 x 640 dp phone
//   (tag `golden`, macOS only for now).
// Requirement: PLAN §7.2 M11 tests ("goldens for two screens en/ta at 1.0/1.5"), UserFlows §Design rules ("Colour
//   plus shape", "Language first", "Big targets").
// Callers: flutter test on macOS (developers); skipped on Linux CI until re-recorded there (Q01).
// Re-record with `flutter test --update-goldens test/features/qc/qc_golden_test.dart` and review the PNGs.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/core/router/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qc_harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip (same as M05/M06/M09).
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// One golden per screen x locale x text scale (2 x 2 x 2 = 8).
void main() {
  if (_skipReason != null) debugPrint('qc_golden_test: SKIPPED ($_skipReason)');
  for (final shot in [QcShot.intake, QcShot.grading]) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        final name = '${shot.name}_${locale.languageCode}_x$scale';
        testWidgets('qc $name golden', skip: _skipReason != null, (tester) async {
          await pumpQc(tester, screenOf(shot), locale: locale, textScale: scale);
          await fillShot(tester, shot);
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../goldens/qc/$name.png'));
        });
      }
    }
  }
}
