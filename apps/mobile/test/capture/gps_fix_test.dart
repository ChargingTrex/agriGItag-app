// Tests for GpsFix.waitForAccuracy with a fake location source and fake_async's clock.
// Requirement: UserFlows §Weak GPS (green at ≤ 20 m; "Save anyway" after 60 s, saved with its accuracy and
//   flagged), M04 acceptance "ring turns green at 15 m" and "'Save anyway' at 60 s → low_accuracy".
// Callers: `flutter test test/capture`.

import 'dart:async';

import 'package:agritrace/core/capture/clocks.dart';
import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fix with accuracy [m] metres at a fixed GPS time.
LocationFix at(double m) => LocationFix(lat: 9.56, lng: 78.13, accuracyM: m, gpsTime: DateTime.utc(2026, 2, 14, 4));

void main() {
  test('reaches green at 15 m and returns ok with the best fix', () {
    fakeAsync((fa) {
      final src = StreamController<LocationFix>();
      GpsResult? r;
      GpsFix(source: () => src.stream).waitForAccuracy().then((v) => r = v);
      src
        ..add(at(50))
        ..add(at(30));
      fa.elapse(const Duration(seconds: 5));
      expect(r, isNull);
      src.add(at(15));
      fa.flushMicrotasks();
      expect(r!.best!.accuracyM, 15);
      expect(r!.lowAccuracy, isFalse);
      expect(r!.locationStatus, 'ok');
      expect(src.hasListener, isFalse, reason: 'GPS released once good');
    });
  });

  test('after 60 s returns the best weak fix with lowAccuracy ("Save anyway")', () {
    fakeAsync((fa) {
      final src = StreamController<LocationFix>();
      GpsResult? r;
      GpsFix(source: () => src.stream).waitForAccuracy().then((v) => r = v);
      src
        ..add(at(80))
        ..add(at(45))
        ..add(at(60));
      fa.elapse(const Duration(seconds: 59));
      expect(r, isNull);
      fa.elapse(const Duration(seconds: 1));
      expect(r!.best!.accuracyM, 45);
      expect(r!.lowAccuracy, isTrue);
      expect(r!.locationStatus, 'low_accuracy');
    });
  });

  test('no fix at all (permission refused: source ends) → none', () {
    fakeAsync((fa) {
      GpsResult? r;
      GpsFix(source: () => const Stream.empty()).waitForAccuracy().then((v) => r = v);
      fa.flushMicrotasks();
      expect(r!.best, isNull);
      expect(r!.locationStatus, 'none');
    });
  });

  test('Clocks keeps device time and GPS time apart', () {
    final c = Clocks.stamp(fix: at(10), now: () => DateTime.utc(2025, 1, 1));
    expect(c.deviceTime, DateTime.utc(2025, 1, 1));
    expect(c.gpsTime, DateTime.utc(2026, 2, 14, 4));
    expect(Clocks.stamp(now: () => DateTime.utc(2025)).gpsTime, isNull);
  });
}
