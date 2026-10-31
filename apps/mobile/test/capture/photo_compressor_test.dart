// Tests for PhotoCompressor and ExifRewriter on the bundled 12 MP fixture: size, long edge, stable SHA-256,
//   quality ladder, thumbnail, and the EXIF kept/stripped sets at byte level.
// Requirement: PLAN §13 B1 (1600 px, q≈80 stepping down to ≤ 350 KB), B2 (keep DateTimeOriginal + GPS +
//   orientation; no MakerNote/thumbnail), M04 acceptance rows 1–2, FR26, FR61.
// Callers: `flutter test test/capture`.

import 'dart:io';
import 'dart:typed_data';

import 'package:agritrace/core/capture/capture_constants.dart';
import 'package:agritrace/core/capture/exif_rewriter.dart';
import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:agritrace/core/capture/photo_compressor.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

import '../fixtures/make_capture_fixture.dart' show makerNoteSentinel;

/// Number of times [needle] occurs in [hay].
int count(Uint8List hay, List<int> needle) {
  var n = 0;
  for (var i = 0; i + needle.length <= hay.length; i++) {
    var j = 0;
    while (j < needle.length && hay[i + j] == needle[j]) {
      j++;
    }
    if (j == needle.length) n++;
  }
  return n;
}

void main() {
  late Directory dir;
  late Directory outDir;
  late File source;
  final fix = LocationFix(
    lat: 9.559806,
    lng: 78.133521,
    accuracyM: 12.5,
    gpsTime: DateTime.utc(2026, 2, 14, 4, 0, 16, 500),
    altitudeM: 101.2,
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('m04_compress');
    // The camera's file sits in a purgeable cache folder; outputs must go to app storage instead.
    final cache = Directory('${dir.path}/cache')..createSync();
    source = File('test/fixtures/capture_12mp.jpg').copySync('${cache.path}/IMG_0001.jpg');
    outDir = Directory('${dir.path}/support/media');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('12 MP fixture → ≤ 350 KB, long edge 1600, stable sha256, ~10 KB thumbnail', () async {
    final sw = Stopwatch()..start();
    final a = await const PhotoCompressor().compress(source, outDir: outDir, fix: fix);
    final ms = sw.elapsedMilliseconds;
    final b = await const PhotoCompressor().compress(source, outDir: outDir, fix: fix);
    // Recorded in docs/agents/reports/M04.md.
    // ignore: avoid_print
    print(
      'compress: in ${source.lengthSync()} B → out ${a.bytes.length} B q${a.jpegQuality} '
      '${a.width}x${a.height}, thumb ${File(a.thumbPath).lengthSync()} B, $ms ms, quality ${a.quality.name}',
    );

    expect(a.bytes.length, lessThanOrEqualTo(kPhotoMaxBytes));
    // Orientation 6 (portrait) is baked in: 3000 x 4000 displayed → 1200 x 1600.
    expect((a.width, a.height), (1200, 1600));
    expect(decodeJpg(a.bytes)!.height, 1600);
    expect(File(a.path).readAsBytesSync(), a.bytes);
    expect(a.sha256, sha256.convert(a.bytes).toString());
    expect(b.sha256, a.sha256, reason: 'same input must give the same bytes');
    expect(File(a.thumbPath).lengthSync(), lessThan(16 * 1024));
  });

  test('both outputs land in outDir (created if missing), never beside the camera file', () async {
    final r = await const PhotoCompressor().compress(source, outDir: outDir);
    expect(r.path, '${outDir.path}/IMG_0001_1600.jpg');
    expect(r.thumbPath, '${outDir.path}/IMG_0001_thumb.jpg');
    expect(File(r.path).existsSync() && File(r.thumbPath).existsSync(), isTrue);
    expect(source.parent.listSync().map((e) => e.path), [source.path]);
  });

  test('ladder steps quality down until the photo fits', () async {
    final first = await const PhotoCompressor().compress(source, outDir: outDir);
    expect(first.jpegQuality, 80);
    final smaller = await const PhotoCompressor().compress(source, outDir: outDir, maxBytes: first.bytes.length - 1);
    expect(smaller.jpegQuality, lessThan(80));
    expect(smaller.bytes.length, lessThan(first.bytes.length));
  });

  test('EXIF keeps time, GPS and orientation only; MakerNote, thumbnail, make/model/software are gone', () async {
    final src = source.readAsBytesSync();
    expect(count(src, makerNoteSentinel.codeUnits), greaterThan(0), reason: 'fixture must carry a MakerNote');
    expect(count(src, [0xFF, 0xD8, 0xFF]), 2, reason: 'fixture must carry an IFD1 thumbnail');

    final out = (await const PhotoCompressor().compress(source, outDir: outDir, fix: fix)).bytes;

    // Byte level: no maker note payload, no second embedded JPEG (thumbnail), no device strings.
    expect(count(out, makerNoteSentinel.codeUnits), 0);
    expect(count(out, [0xFF, 0xD8, 0xFF]), 1);
    for (final s in ['FixtureCam', 'FX-12MP', 'fixture-gen']) {
      expect(count(out, s.codeUnits), 0, reason: s);
    }
    expect(count(out, [0x92, 0x7C]), 0, reason: 'no MakerNote tag id');

    // Parse the APP1 TIFF directly: decodeJpg would apply and drop the Orientation tag.
    // Marker order: SOI, JFIF APP0, then APP1 Exif.
    expect(out.sublist(0, 4), [0xFF, 0xD8, 0xFF, 0xE0]);
    final app1At = 4 + (out[4] << 8 | out[5]);
    expect(out.sublist(app1At, app1At + 2), [0xFF, 0xE1]);
    final exif = ExifData.fromInputBuffer(InputBuffer(out.sublist(app1At + 10), bigEndian: true));
    expect(exif.imageIfd.keys.toSet(), {0x0112, 0x8769, 0x8825});
    expect(exif.imageIfd[0x0112]!.toInt(), 1);
    expect(exif.exifIfd.keys.toSet(), {0x9003, 0x9011, 0x9291});
    expect(exif.exifIfd[0x9003].toString(), '2026:02:14 09:30:15');
    expect(exif.exifIfd[0x9011].toString(), '+05:30');
    expect(exif.directories.containsKey('ifd1'), isFalse);
    final gps = exif.gpsIfd;
    expect(gps.keys.toSet(), {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x1D, 0x1F});
    double deg(IfdValue v) => v.toDouble(0) + v.toDouble(1) / 60 + v.toDouble(2) / 3600;
    expect(deg(gps[0x02]!), closeTo(9.559806, 1e-6));
    expect(deg(gps[0x04]!), closeTo(78.133521, 1e-6));
    expect(gps[0x01].toString(), 'N');
    expect(gps[0x1D].toString(), '2026:02:14');
    expect(gps[0x1F]!.toDouble(), 12.5);
  });

  test('without a fix the source GPS block is kept; without source time capturedAt is written', () {
    const rw = ExifRewriter();
    final kept = decodeJpg(source.readAsBytesSync())!.exif;
    final tiff = rw.buildTiff(kept);
    final back = ExifData.fromInputBuffer(InputBuffer(tiff, bigEndian: true));
    expect(back.gpsIfd[0x01].toString(), 'N');
    expect(back.gpsIfd[0x02]!.toDouble(0), 9);

    final fresh = ExifData.fromInputBuffer(
      InputBuffer(rw.buildTiff(ExifData(), capturedAt: DateTime(2026, 3, 1, 7, 5, 9)), bigEndian: true),
    );
    expect(fresh.exifIfd[0x9003].toString(), '2026:03:01 07:05:09');
    expect(fresh.directories['ifd0']!.sub.keys, isNot(contains('gps')));

    // Camera wrote the local time but no offset: the offset comes from capturedAt, the time stays the camera's.
    final noOffset = ExifData()..exifIfd[0x9003] = IfdValueAscii('2026:02:14 09:30:15');
    final filled = ExifData.fromInputBuffer(
      InputBuffer(rw.buildTiff(noOffset, capturedAt: DateTime.utc(2026, 2, 14, 4, 0, 15)), bigEndian: true),
    );
    expect(filled.exifIfd[0x9003].toString(), '2026:02:14 09:30:15');
    expect(filled.exifIfd[0x9011].toString(), '+00:00');
  });

  test('TIFF sub-IFDs end with a zero next-IFD pointer (TIFF 6.0 §2)', () {
    final tiff = const ExifRewriter().buildTiff(ExifData(), capturedAt: DateTime(2026), fix: fix);
    final bd = ByteData.sublistView(tiff);
    for (final pointerTag in [0x8769, 0x8825]) {
      // Find the pointer entry in IFD0 (starts at 8) and read the sub-IFD's next pointer.
      final n0 = bd.getUint16(8);
      final e = List.generate(n0, (i) => 10 + 12 * i).firstWhere((o) => bd.getUint16(o) == pointerTag);
      final at = bd.getUint32(e + 8);
      expect(bd.getUint32(at + 2 + 12 * bd.getUint16(at)), 0);
    }
  });
}
