// Tests for PhotoQualityCheck: a sharp, a blurred and a dark variant generated here are classified correctly.
// Requirement: UserFlows §When things go wrong ("Photo too dark or blurry"), M04 acceptance "blurry rejected".
// Callers: `flutter test test/capture`.

import 'dart:math';

import 'package:agritrace/core/capture/photo_quality_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

void main() {
  // A field-like scene: random coloured blocks with hard edges and fine grain, 1600 x 1200.
  final rnd = Random(4);
  final sharp = Image(width: 1600, height: 1200);
  for (var y = 0; y < 1200; y += 40) {
    for (var x = 0; x < 1600; x += 40) {
      fillRect(
        sharp,
        x1: x,
        y1: y,
        x2: x + 39,
        y2: y + 39,
        color: ColorRgb8(60 + rnd.nextInt(180), 60 + rnd.nextInt(180), 40 + rnd.nextInt(150)),
      );
    }
  }
  final blurred = gaussianBlur(sharp.clone(), radius: 12);
  final dark = adjustColor(sharp.clone(), brightness: 0.12);
  const check = PhotoQualityCheck();

  test('sharp, blurred and dark variants are classified', () {
    for (final (name, img) in [('sharp', sharp), ('blurred', blurred), ('dark', dark)]) {
      final (mean, variance) = check.measure(img);
      // Recorded in docs/agents/reports/M04.md (threshold calibration evidence).
      // ignore: avoid_print
      print('$name: mean ${mean.toStringAsFixed(1)}, laplacian variance ${variance.toStringAsFixed(1)}');
    }
    expect(check.check(sharp), PhotoQuality.ok);
    expect(check.check(blurred), PhotoQuality.tooBlurry);
    expect(check.check(dark), PhotoQuality.tooDark);
  });
}
