// Makes the camera file light: long edge 1600 px, JPEG q80 stepping down until ≤ 350 KB, EXIF reduced to
//   time + GPS + orientation, a ~10 KB thumbnail, SHA-256 of the stored bytes, and the quality verdict.
// Requirement: PLAN §13 B1 (1600 px, q≈80 stepping down to ≤ 350 KB) and B2 (EXIF kept set), Arch
//   §Offline-first ("Photos made light": ~300 KB, originals not kept), FR3, FR26, FR61, UserFlows §The photo
//   is the proof, mobile-design.md §3 (keep ~10 KB thumbnail after upload).
// Callers: M07 event capture (after CameraCapture.take; stores the result in the Media table and deletes the
//   camera original); test/capture/photo_compressor_test.dart.

import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

import 'capture_constants.dart';
import 'exif_rewriter.dart';
import 'gps_fix.dart';
import 'photo_quality_check.dart';

/// Result of [PhotoCompressor.compress]: the stored evidence photo, its thumbnail and what M07 writes into
/// the Media table (bytes, sha256, width, height, thumbPath).
class CompressedPhoto {
  /// Creates the result; see the fields for each value. Throws nothing.
  const CompressedPhoto({
    required this.path,
    required this.bytes,
    required this.width,
    required this.height,
    required this.sha256,
    required this.thumbPath,
    required this.jpegQuality,
    required this.quality,
  });

  /// Path of the written evidence JPEG (`<source>_1600.jpg`).
  final String path;

  /// The evidence JPEG bytes, exactly as written to [path] and uploaded (D-011).
  final Uint8List bytes;

  /// Width in pixels after orientation is applied.
  final int width;

  /// Height in pixels after orientation is applied.
  final int height;

  /// SHA-256 of [bytes], lowercase hex; sent with the upload and checked by the server.
  final String sha256;

  /// Path of the ~10 KB thumbnail JPEG (`<source>_thumb.jpg`) kept after the full photo is purged.
  final String thumbPath;

  /// JPEG quality the ladder settled on (80 when the first try fit).
  final int jpegQuality;

  /// Brightness/blur verdict; M07 offers "Take again?" unless [PhotoQuality.ok].
  final PhotoQuality quality;
}

/// Compresses camera files in a background isolate.
class PhotoCompressor {
  /// Creates the compressor (stateless). Throws nothing.
  const PhotoCompressor();

  /// Compresses the JPEG at [source] in a background isolate (`compute`), so the UI thread never decodes.
  ///
  /// [capturedAt] fills DateTimeOriginal when the camera wrote none; [fix] becomes the GPS block (FR26).
  /// [maxBytes] is the size limit (PLAN §13 B1: 350 KB; tests lower it to exercise the ladder).
  /// Returns the [CompressedPhoto]. Side effects: writes `<source>_1600.jpg` and `<source>_thumb.jpg` next to
  /// [source]; leaves [source] in place for the caller to delete.
  /// Throws: [FileSystemException] if [source] cannot be read or the outputs written; [FormatException] if
  /// [source] is not a decodable JPEG.
  ///
  /// DECISION D-011: one file sized for a single presigned PUT (≤ 350 KB, ~300 KB typical).
  ///   ADV: a whole-file retry costs at most ~350 KB on weak 4G; no resumable upload code on the phone.
  ///   COMPROMISE: the ladder stops at q40; a pathological scene can end above 350 KB and is still saved
  ///   (evidence is never dropped for size; the PUT just takes longer).
  Future<CompressedPhoto> compress(
    File source, {
    DateTime? capturedAt,
    LocationFix? fix,
    int maxBytes = kPhotoMaxBytes,
  }) => compute(_compress, (source.path, capturedAt, fix, maxBytes));

  /// Isolate body of [compress]; [job] is (source path, capturedAt, fix, maxBytes). Returns the result.
  /// Side effects and throws as for [compress].
  static CompressedPhoto _compress((String, DateTime?, LocationFix?, int) job) {
    final (path, capturedAt, fix, maxBytes) = job;
    final input = File(path).readAsBytesSync();
    final info = JpegDecoder().startDecode(input);
    if (info == null) throw FormatException('not a JPEG', path);
    // DCT-domain downscale while decoding: a 12 MP frame decodes at 1/2 (≈ 3 MP) instead of full size.
    var scale = 1;
    while (scale < 8 && max(info.width, info.height) ~/ (scale * 2) >= kPhotoLongEdgePx) {
      scale *= 2;
    }
    final decoded = decodeJpg(input, scale: scale);
    if (decoded == null) throw FormatException('not a JPEG', path);

    // decodeJpg applies the EXIF orientation (and drops the tag), so pixels are upright; Orientation is written as 1.
    final photo = _fit(decoded, kPhotoLongEdgePx)
      ..exif = ExifData()
      ..iccProfile = null;
    const rewriter = ExifRewriter();
    final tiff = rewriter.buildTiff(decoded.exif, capturedAt: capturedAt, fix: fix);
    late Uint8List bytes;
    late int q;
    for (q in kJpegQualityLadder) {
      bytes = rewriter.splice(encodeJpg(photo, quality: q, chroma: JpegChroma.yuv420), tiff);
      if (bytes.length <= maxBytes) break;
    }

    final stem = path.replaceFirst(RegExp(r'\.[^./\\]*$'), '');
    final outPath = '${stem}_1600.jpg';
    final thumbPath = '${stem}_thumb.jpg';
    File(outPath).writeAsBytesSync(bytes, flush: true);
    File(thumbPath).writeAsBytesSync(encodeJpg(_fit(photo, kThumbLongEdgePx), quality: kThumbQuality), flush: true);

    return CompressedPhoto(
      path: outPath,
      bytes: bytes,
      width: photo.width,
      height: photo.height,
      sha256: sha256.convert(bytes).toString(),
      thumbPath: thumbPath,
      jpegQuality: q,
      quality: const PhotoQualityCheck().check(photo),
    );
  }

  /// Resizes the upright [src] so its long edge is [longEdge] px (never upscales). Returns a new image;
  /// throws nothing.
  static Image _fit(Image src, int longEdge) {
    final target = min(longEdge, max(src.width, src.height));
    return src.width >= src.height
        ? copyResize(src, width: target, interpolation: Interpolation.average)
        : copyResize(src, height: target, interpolation: Interpolation.average);
  }
}
