// Test-wide setup run by `flutter test` before every test file in test/.
// Requirement: plan §7.2 M00 (FarmerButton golden at 56/64 dp in en and ta) and M05 (goldens en+ta).
// Callers: the flutter_test bootstrap (by file name convention).

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Largest share of differing pixels accepted by golden comparisons (0.5 %).
///
/// Goldens are recorded on macOS and checked on Linux CI, whose font rasterisers anti-alias glyph edges
/// differently; a size or layout regression changes far more than 0.5 % of the pixels.
const goldenTolerance = 0.005;

/// Wraps every test file: loads the Tamil and icon fonts and installs the tolerant golden comparator.
///
/// [testMain] is the test file's `main`. Returns when it completes. Throws [FileSystemException] when a
/// font file is missing (a broken checkout, or FLUTTER_ROOT not set because the tests were not started
/// by `flutter test`).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // flutter_test renders every font as boxes unless loaded here. Tamil and the icons are what the farmer
  // reads, so goldens show them for real; Latin text stays as the deterministic test-font boxes.
  final sdkFonts = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  await _loadFont('NotoSansTamil', 'assets/fonts/NotoSansTamil-sub.ttf');
  await _loadFont('MaterialIcons', '$sdkFonts/MaterialIcons-Regular.otf');

  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(current.basedir.resolve('flutter_test_config.dart'));
  }
  await testMain();
}

/// Registers the font file at [path] under [family] for this test isolate.
/// Returns when loaded. Throws [FileSystemException] when [path] does not exist.
Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

/// [LocalFileComparator] that passes when at most [goldenTolerance] of the pixels differ.
class _TolerantComparator extends LocalFileComparator {
  /// Creates a comparator whose golden paths resolve relative to [testFile]'s directory.
  _TolerantComparator(super.testFile);

  /// Compares [imageBytes] with the golden at [golden].
  ///
  /// Returns true when the images match within [goldenTolerance]. Throws [FlutterError] with the diff
  /// report (and writes failure images next to the test) otherwise.
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
