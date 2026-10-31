// Generates test/fixtures/capture_12mp.jpg: a 4000 × 3000 (12 MP) JPEG shaped like a phone camera file, with
//   EXIF Make/Model/Software, Orientation 6 (portrait), DateTimeOriginal + SubSec + Offset, a GPS block, a
//   MakerNote and an IFD1 thumbnail, so the capture tests can prove what is kept and what is stripped.
// Requirement: PLAN §13 B1/B2 acceptance ("12 MP → ≤ 350 KB, long edge 1600"; "no MakerNote/thumbnail").
// Callers: run once by hand, `dart run test/fixtures/make_capture_fixture.dart` from apps/mobile; the output
//   is committed and read by test/capture/*.
// Content is smooth gradients with a few sharp shapes so the 12 MP file stays under 1 MB in the repo.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

/// Marker bytes inside the fixture's MakerNote; tests assert they are gone after compression.
const makerNoteSentinel = 'AGRITRACE-FIXTURE-MAKERNOTE';

/// Writes the fixture next to this script. Side effect: overwrites test/fixtures/capture_12mp.jpg.
void main() {
  final img = Image(width: 4000, height: 3000);
  for (final p in img) {
    p
      ..r = 60 + p.x * 140 ~/ 4000
      ..g = 90 + p.y * 120 ~/ 3000
      ..b = 40 + (p.x + p.y) * 60 ~/ 7000;
  }
  for (var i = 0; i < 12; i++) {
    fillRect(img, x1: 300 * i, y1: 200 + 180 * i, x2: 300 * i + 260, y2: 360 + 180 * i, color: ColorRgb8(230, 30, 20));
    drawLine(img, x1: 0, y1: 250 * i, x2: 4000, y2: 250 * i + 100, color: ColorRgb8(20, 20, 20), thickness: 4);
  }

  final exif = ExifData();
  exif.imageIfd['Make'] = IfdValueAscii('FixtureCam');
  exif.imageIfd['Model'] = IfdValueAscii('FX-12MP');
  exif.imageIfd['Software'] = IfdValueAscii('fixture-gen 1.0');
  exif.imageIfd['Orientation'] = IfdValueShort(6);
  exif.exifIfd[0x9003] = IfdValueAscii('2026:02:14 09:30:15');
  exif.exifIfd[0x9291] = IfdValueAscii('250');
  exif.exifIfd[0x9011] = IfdValueAscii('+05:30');
  exif.exifIfd[0x927C] = IfdValueUndefined.list(ascii.encode(makerNoteSentinel * 8));
  exif.gpsIfd[0x00] = IfdByteValue.list(Uint8List.fromList([2, 3, 0, 0]));
  exif.gpsIfd[0x01] = IfdValueAscii('N');
  exif.gpsIfd[0x02] = IfdValueRational.data(_be([9, 1, 33, 1, 352, 10]), 3);
  exif.gpsIfd[0x03] = IfdValueAscii('E');
  exif.gpsIfd[0x04] = IfdValueRational.data(_be([78, 1, 8, 1, 7, 1]), 3);
  exif.gpsIfd[0x07] = IfdValueRational.data(_be([4, 1, 0, 1, 15, 1]), 3);
  exif.gpsIfd[0x1D] = IfdValueAscii('2026:02:14');
  exif.thumbnailIfd[0x0103] = IfdValueShort(6);
  exif.thumbnailData = encodeJpg(copyResize(img, width: 160), quality: 60);
  img.exif = exif;

  final out = File('${File.fromUri(Platform.script).parent.path}/capture_12mp.jpg')
    ..writeAsBytesSync(encodeJpg(img, quality: 85, chroma: JpegChroma.yuv420));
  stdout.writeln('${out.path}: ${out.lengthSync()} bytes');
}

/// Big-endian uint32 buffer of [v], for building rational EXIF values. Returns an [InputBuffer].
InputBuffer _be(List<int> v) {
  final b = ByteData(v.length * 4);
  for (var i = 0; i < v.length; i++) {
    b.setUint32(i * 4, v[i]);
  }
  return InputBuffer(b.buffer.asUint8List(), bigEndian: true);
}
