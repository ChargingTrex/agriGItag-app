// Builds the only EXIF block an evidence photo carries: capture time, GPS and orientation; nothing else.
// Requirement: PLAN §13 B2 (keep EXIF DateTimeOriginal + GPS + orientation; strip thumbnails and maker notes),
//   FR26 (GPS and time recorded with the photo), FR61 (server checks photo time and GPS against the event),
//   UserFlows §The photo is the proof.
// Callers: photo_compressor.dart (inside its isolate); test/capture/photo_compressor_test.dart (EXIF tests).

import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'gps_fix.dart';

/// Tags kept from the source Exif sub-IFD: DateTimeOriginal, OffsetTimeOriginal, SubSecTimeOriginal.
const _keptExifTags = [0x9003, 0x9011, 0x9291];

/// Tags kept from the source GPS IFD: version, lat/lon (+refs), altitude (+ref), GPS time and date,
/// horizontal positioning error.
const _keptGpsTags = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x1D, 0x1F];

/// One TIFF entry ready to write: TIFF [type] code, value [count] and the big-endian value [bytes].
typedef _Entry = ({int type, int count, Uint8List bytes});

/// Rewrites EXIF to the kept set and splices it into an encoded JPEG.
///
/// Why not `ExifData.write` from package:image (4.12.0): it writes sub-IFDs without the 4-byte next-IFD
/// pointer TIFF 6.0 §2 requires, so strict readers (the server's EXIF check, Android ExifInterface) can
/// misread the GPS block. Reading with package:image is fine; this class only writes.
class ExifRewriter {
  /// Creates the rewriter (stateless). Throws nothing.
  const ExifRewriter();

  /// Builds the TIFF body of the new EXIF block (big-endian) from [source], keeping only the allowed tags.
  ///
  /// [source] is the EXIF read from the camera file (may be empty). [capturedAt] fills DateTimeOriginal when
  /// [source] has none, and OffsetTimeOriginal when [source] has none (the phone's zone, which the camera's
  /// local DateTimeOriginal also uses), so the server's FR61 time check never sees a zoneless time. [fix], when given, replaces any source GPS
  /// block (the camera plugin writes none; FR26 wants the event-time fix). Orientation is always written as 1
  /// because the compressor bakes rotation into the pixels. Everything else (MakerNote, IFD1 thumbnail, Make,
  /// Model, Software, …) is dropped by construction. Returns the TIFF bytes; throws nothing.
  Uint8List buildTiff(ExifData source, {DateTime? capturedAt, LocationFix? fix}) {
    final exif = <int, _Entry>{
      for (final tag in _keptExifTags)
        if (source.exifIfd[tag] case final v?) tag: _copy(v),
    };
    if (capturedAt != null) {
      exif.putIfAbsent(0x9003, () => _ascii(_exifDateTime(capturedAt)));
      exif.putIfAbsent(0x9011, () => _ascii(_offset(capturedAt.timeZoneOffset)));
    }
    final gps = fix != null
        ? _gpsFrom(fix)
        : <int, _Entry>{
            for (final tag in _keptGpsTags)
              if (source.gpsIfd[tag] case final v?) tag: _copy(v),
          };
    return _tiff(exif, gps);
  }

  /// Inserts an APP1 "Exif" segment holding [tiff] into [jpeg] (which must carry no APP1 of its own): after
  /// the JFIF APP0 segment when there is one (JFIF wants APP0 first; Exif readers scan markers), else right
  /// after SOI. Returns the new JPEG bytes. Throws [FormatException] when [jpeg] does not start with SOI.
  Uint8List splice(Uint8List jpeg, Uint8List tiff) {
    if (jpeg.length < 6 || jpeg[0] != 0xFF || jpeg[1] != 0xD8) throw const FormatException('not a JPEG');
    final at = jpeg[2] == 0xFF && jpeg[3] == 0xE0 ? 4 + (jpeg[4] << 8 | jpeg[5]) : 2;
    final segLen = 2 + 6 + tiff.length;
    return (BytesBuilder(copy: false)
          ..add(jpeg.sublist(0, at))
          ..add([0xFF, 0xE1, segLen >> 8, segLen & 0xFF])
          ..add(ascii.encode('Exif'))
          ..add([0, 0])
          ..add(tiff)
          ..add(jpeg.sublist(at)))
        .takeBytes();
  }

  /// GPS IFD entries for [fix]: lat/lon as degrees-minutes-seconds, altitude when known, UTC time and date of
  /// the fix, horizontal error in metres. Returns tag → entry; throws nothing.
  Map<int, _Entry> _gpsFrom(LocationFix fix) {
    final t = fix.gpsTime.toUtc();
    final alt = fix.altitudeM;
    return {
      0x00: (type: 1, count: 4, bytes: Uint8List.fromList([2, 3, 0, 0])),
      0x01: _ascii(fix.lat >= 0 ? 'N' : 'S'),
      0x02: _rationals(_dms(fix.lat.abs())),
      0x03: _ascii(fix.lng >= 0 ? 'E' : 'W'),
      0x04: _rationals(_dms(fix.lng.abs())),
      if (alt != null) 0x05: (type: 1, count: 1, bytes: Uint8List.fromList([alt < 0 ? 1 : 0])),
      if (alt != null) 0x06: _rationals([((alt.abs() * 100).round(), 100)]),
      0x07: _rationals([(t.hour, 1), (t.minute, 1), (t.second * 1000 + t.millisecond, 1000)]),
      0x1D: _ascii('${t.year}:${_pad2(t.month)}:${_pad2(t.day)}'),
      0x1F: _rationals([((fix.accuracyM * 100).round(), 100)]),
    };
  }

  /// Splits [deg] (non-negative) into degrees, minutes and seconds with 1/10000 s resolution (~3 mm).
  /// Returns three (numerator, denominator) pairs; throws nothing.
  List<(int, int)> _dms(double deg) {
    final d = deg.floor();
    final m = ((deg - d) * 60).floor();
    final s = ((deg - d) * 3600 - m * 60) * 10000;
    return [(d, 1), (m, 1), (s.round(), 10000)];
  }

  /// Serialises IFD0 (Orientation = 1, Exif and GPS pointers) followed by the [exif] and [gps] sub-IFDs,
  /// each with its next-IFD pointer and its out-of-line values. Empty sub-IFDs are omitted.
  /// Returns big-endian TIFF bytes; throws nothing.
  Uint8List _tiff(Map<int, _Entry> exif, Map<int, _Entry> gps) {
    final ifd0 = <int, _Entry>{0x0112: _short(1)};
    if (exif.isNotEmpty) ifd0[0x8769] = _long(0);
    if (gps.isNotEmpty) ifd0[0x8825] = _long(0);
    final exifAt = 8 + _size(ifd0);
    final gpsAt = exifAt + (exif.isEmpty ? 0 : _size(exif));
    if (exif.isNotEmpty) ifd0[0x8769] = _long(exifAt);
    if (gps.isNotEmpty) ifd0[0x8825] = _long(gpsAt);

    final out = OutputBuffer(bigEndian: true)
      ..writeUint16(0x4D4D)
      ..writeUint16(0x002A)
      ..writeUint32(8);
    _writeIfd(out, ifd0, 8);
    if (exif.isNotEmpty) _writeIfd(out, exif, exifAt);
    if (gps.isNotEmpty) _writeIfd(out, gps, gpsAt);
    return out.getBytes();
  }

  /// Bytes one IFD of [ifd] occupies: count, 12-byte entries, next pointer, then out-of-line values padded to
  /// even length. Returns the size; throws nothing.
  int _size(Map<int, _Entry> ifd) =>
      2 + 12 * ifd.length + 4 + ifd.values.fold(0, (n, e) => n + (e.bytes.length > 4 ? _even(e.bytes.length) : 0));

  /// Writes [ifd] (tags ascending, as TIFF requires) at absolute offset [at] into [out], next pointer 0
  /// (no chained IFD; sub-IFDs are reached by pointer), then its out-of-line values.
  /// Side effect: appends to [out]. Throws nothing.
  void _writeIfd(OutputBuffer out, Map<int, _Entry> ifd, int at) {
    final tags = ifd.keys.toList()..sort();
    var dataAt = at + 2 + 12 * tags.length + 4;
    out.writeUint16(tags.length);
    for (final tag in tags) {
      final e = ifd[tag]!;
      out
        ..writeUint16(tag)
        ..writeUint16(e.type)
        ..writeUint32(e.count);
      if (e.bytes.length <= 4) {
        out.writeBytes(Uint8List(4)..setAll(0, e.bytes));
      } else {
        out.writeUint32(dataAt);
        dataAt += _even(e.bytes.length);
      }
    }
    out.writeUint32(0);
    for (final tag in tags) {
      final b = ifd[tag]!.bytes;
      if (b.length > 4) out.writeBytes(Uint8List(_even(b.length))..setAll(0, b));
    }
  }

  /// Copies a value read by package:image into an entry, re-serialised big-endian. Returns the entry.
  /// [v] is the source value. Throws nothing.
  _Entry _copy(IfdValue v) {
    final out = OutputBuffer(bigEndian: true);
    v.write(out);
    return (type: v.type.index, count: v.length, bytes: out.getBytes());
  }

  /// ASCII entry for [s] with its NUL terminator. Returns the entry; throws nothing.
  _Entry _ascii(String s) => (type: 2, count: s.length + 1, bytes: Uint8List.fromList([...ascii.encode(s), 0]));

  /// RATIONAL entry from (numerator, denominator) pairs [r]. Returns the entry; throws nothing.
  _Entry _rationals(List<(int, int)> r) {
    final out = OutputBuffer(bigEndian: true);
    for (final (n, d) in r) {
      out
        ..writeUint32(n)
        ..writeUint32(d);
    }
    return (type: 5, count: r.length, bytes: out.getBytes());
  }

  /// SHORT entry for [v]. Returns the entry; throws nothing.
  _Entry _short(int v) => (type: 3, count: 1, bytes: Uint8List.fromList([v >> 8, v & 0xFF]));

  /// LONG entry for [v]. Returns the entry; throws nothing.
  _Entry _long(int v) => (type: 4, count: 1, bytes: Uint8List(4)..buffer.asByteData().setUint32(0, v));

  /// Rounds [n] up to an even byte count (TIFF word alignment). Returns it; throws nothing.
  int _even(int n) => n + n % 2;

  /// Formats [t] as EXIF "YYYY:MM:DD HH:MM:SS" in its own (local) time. Returns the string; throws nothing.
  String _exifDateTime(DateTime t) =>
      '${t.year}:${_pad2(t.month)}:${_pad2(t.day)} ${_pad2(t.hour)}:${_pad2(t.minute)}:${_pad2(t.second)}';

  /// Formats [o] as an EXIF offset such as "+05:30". Returns the string; throws nothing.
  String _offset(Duration o) => '${o.isNegative ? '-' : '+'}${_pad2(o.inHours.abs())}:${_pad2(o.inMinutes.abs() % 60)}';

  /// Zero-pads [n] to two digits. Returns the string; throws nothing.
  String _pad2(int n) => n.toString().padLeft(2, '0');
}
