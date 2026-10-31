// Walked-area arithmetic and field-rule parsing of the onboarding wizard.
// Requirement: PLAN §7.2 M09 acceptance ("100 m square → 2.47 acres ± 2 %"; "declared 1 vs walked 2.4 → mismatch
//   note"), FR66, D-017. Callers: flutter test (CI mobile job).

import 'dart:math';

import 'package:agritrace/core/refdata/models/reference.dart' show LonLat;
import 'package:agritrace/features/onboarding_farmer/boundary_area.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corners of a [sideM] x [sideM] metre square on the WGS 84 ellipsoid whose south-west corner is at [lat], [lng]
/// (degrees), using the ellipsoid's metres per degree (not the sphere the code under test uses).
/// Returns the four corners in walking order; throws nothing.
List<LonLat> square(double sideM, {double lat = 9.55, double lng = 78.2}) {
  final phi = lat * pi / 180;
  final mLat = 111132.92 - 559.82 * cos(2 * phi) + 1.175 * cos(4 * phi);
  final mLng = 111412.84 * cos(phi) - 93.5 * cos(3 * phi);
  final dLat = sideM / mLat, dLng = sideM / mLng;
  return [(lng, lat), (lng + dLng, lat), (lng + dLng, lat + dLat), (lng, lat + dLat)];
}

void main() {
  test('a 100 m x 100 m square is 2.47 acres within 2 %', () {
    final acres = geodesicAreaM2(square(100)) / squareMetresPerAcre;
    expect(acres, closeTo(2.47, 2.47 * 0.02));
  });

  test('the ring may be closed or open, in either direction', () {
    final ring = square(100);
    final open = geodesicAreaM2(ring);
    expect(geodesicAreaM2([...ring, ring.first]), closeTo(open, 1e-6));
    expect(geodesicAreaM2(ring.reversed.toList()), closeTo(open, 1e-6));
    expect(geodesicAreaM2(ring.take(2).toList()), 0);
  });

  test('declared 1 acre vs walked 2.4 is a mismatch; 1.15 is not; no walk never is', () {
    expect(areaMismatch(1, 2.4), isTrue);
    expect(areaMismatch(1, 0.7), isTrue);
    expect(areaMismatch(1, 1.15), isFalse);
    expect(areaMismatch(1, 1.2), isFalse, reason: 'exactly 20 % is within the tolerance (server: abs(pct) > 20)');
    expect(areaMismatch(1, null), isFalse);
  });

  test('field rules: absent or disabled fields are off, required is read, no config means all on', () {
    final rules = FieldRules(
      plot: FieldRules.parse('[{"name":"pin","required":true},{"name":"soil_type","enabled":false}]'),
    );
    expect(rules.enabled('plot', 'pin'), isTrue);
    expect(rules.required('plot', 'pin'), isTrue);
    expect(rules.enabled('plot', 'soil_type'), isFalse);
    expect(rules.enabled('plot', 'farming_type'), isFalse);
    expect(rules.enabled('farmer', 'phone'), isTrue, reason: 'farmer config never pulled');
    expect(rules.required('farmer', 'phone'), isFalse);
  });
}
