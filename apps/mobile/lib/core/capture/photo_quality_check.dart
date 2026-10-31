// Basic on-phone check that a photo is bright and sharp enough to be evidence.
// Requirement: UserFlows §When things go wrong ("Photo too dark or blurry": "Photo is not clear. Take again?";
//   basic brightness and blur check on the phone before saving), UserFlows §The photo is the proof, FR3.
// Callers: photo_compressor.dart (runs it on the resized image inside its isolate; M07 reads
//   CompressedPhoto.quality); test/capture/photo_quality_check_test.dart.

import 'dart:typed_data';

import 'package:image/image.dart';

import 'capture_constants.dart';

/// Verdict of [PhotoQualityCheck.check].
enum PhotoQuality {
  /// Good enough to save.
  ok,

  /// Mean brightness below [kMinMeanLuminance].
  tooDark,

  /// Laplacian variance below [kMinLaplacianVariance].
  tooBlurry,
}

/// Brightness and blur check over a small grey copy of the photo; thresholds live in capture_constants.dart.
class PhotoQualityCheck {
  /// Creates the check (stateless). Throws nothing.
  const PhotoQualityCheck();

  /// Classifies [photo]: [PhotoQuality.tooDark] first (a dark frame also looks flat), then
  /// [PhotoQuality.tooBlurry], else [PhotoQuality.ok]. Returns the verdict; throws nothing.
  PhotoQuality check(Image photo) {
    final (mean, variance) = measure(photo);
    if (mean < kMinMeanLuminance) return PhotoQuality.tooDark;
    if (variance < kMinLaplacianVariance) return PhotoQuality.tooBlurry;
    return PhotoQuality.ok;
  }

  /// Downscales [photo] to [kQualityLongEdgePx] on the long edge and measures it.
  ///
  /// Returns (mean luminance 0–255, variance of the 4-neighbour Laplacian of luminance); tests and Q01
  /// calibration print these. Throws nothing.
  (double, double) measure(Image photo) {
    final small = photo.width >= photo.height
        ? copyResize(photo, width: kQualityLongEdgePx, interpolation: Interpolation.average)
        : copyResize(photo, height: kQualityLongEdgePx, interpolation: Interpolation.average);
    final w = small.width, h = small.height;
    final lum = Float64List(w * h);
    var sum = 0.0;
    for (final p in small) {
      final l = p.luminanceNormalized.toDouble() * 255;
      lum[p.y * w + p.x] = l;
      sum += l;
    }
    var lapSum = 0.0, lapSq = 0.0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final i = y * w + x;
        final lap = lum[i - 1] + lum[i + 1] + lum[i - w] + lum[i + w] - 4 * lum[i];
        lapSum += lap;
        lapSq += lap * lap;
      }
    }
    final n = (w - 2) * (h - 2);
    final lapMean = lapSum / n;
    return (sum / (w * h), lapSq / n - lapMean * lapMean);
  }
}
