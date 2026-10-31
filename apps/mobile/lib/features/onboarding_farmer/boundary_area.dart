// Walked-boundary arithmetic: geodesic area of a GPS ring, acres and cents, and the declared-vs-walked mismatch rule.
// Requirement: FR66 (walked boundary: "computes the walked area and flags a gap with the declared size above a set
//   tolerance"), FR65 (declared size in acres; 100 cents = 1 acre), UserFlows §Onboarding a farmer steps 5-6,
//   Dataflow Stage 0 (System Action: "computes its area and flags a mismatch with declared size").
// Callers: onboarding_notifier.dart (OnboardingDraft.walkedAcres, walkCrosses, declaredAcres), boundary_step.dart;
//   test/features/onboarding/boundary_area_test.dart.

import 'dart:math';

import '../../core/refdata/models/reference.dart' show LonLat;

/// Square metres in one international acre.
const squareMetresPerAcre = 4046.8564224;

/// Cents in one acre (UserFlows §Onboarding step 5: 100 cents = 1 acre).
const centsPerAcre = 100;

/// Largest walked-vs-declared gap, as a fraction of the declared size, that is not flagged (server
/// `AREA_GAP_LIMIT_PCT` = 20 %, registry/service.py `area_gap`).
const areaGapLimit = 0.20;

/// WGS 84 equatorial radius in metres, the sphere Turf.js and most GIS tools use for this formula.
const _earthRadiusM = 6378137.0;

/// Area in square metres of the ring [points] (lon/lat degrees, open or closed) on the WGS 84 sphere.
///
/// Spherical-excess formula of Chamberlain & Duquette ("Some algorithms for polygons on a sphere", JPL 2007), the
/// one Turf.js `area` uses. Returns 0 for fewer than 3 points. Throws nothing.
///
/// shortcut: sphere, not the ellipsoid PostGIS `ST_Area(geography)` uses on the server; about 0.3 % apart at the
///   pilot's latitude, far inside the 20 % mismatch tolerance. The server value is the one stored.
double geodesicAreaM2(List<LonLat> points) {
  if (points.length < 3) return 0;
  double rad(double degrees) => degrees * pi / 180;
  var sum = 0.0;
  for (var i = 0; i < points.length; i++) {
    final (lon1, lat1) = points[i];
    final (lon2, lat2) = points[(i + 1) % points.length];
    sum += (rad(lon2) - rad(lon1)) * (2 + sin(rad(lat1)) + sin(rad(lat2)));
  }
  return (sum * _earthRadiusM * _earthRadiusM / 2).abs();
}

/// Whether the ring [points] (lon/lat degrees, open or closed) is a simple polygon: no two edges cross or touch
/// except neighbours at their shared corner, and no edge doubles back over the previous one.
///
/// The server refuses a polygon that is not valid (registry/geo.py `_checked`) and with it the whole plot entry,
/// so the wizard leaves such a walk out. Repeated identical fixes are ignored. Checks every pair of edges in plain
/// lon/lat: O(n²), fine for walks of a few hundred points. Returns false for fewer than 3 distinct points.
/// Throws nothing.
bool ringIsSimple(List<LonLat> points) {
  final p = <LonLat>[];
  for (final q in points) {
    if (p.isEmpty || p.last != q) p.add(q);
  }
  if (p.length > 1 && p.first == p.last) p.removeLast();
  final n = p.length;
  if (n < 3) return false;
  for (var i = 0; i < n; i++) {
    final (a, b, c) = (p[i], p[(i + 1) % n], p[(i + 2) % n]);
    // Neighbouring edges a-b and b-c: invalid only when c turns straight back over a-b (a spike).
    if (_cross(a, b, c) == 0 && (a.$1 - b.$1) * (c.$1 - b.$1) + (a.$2 - b.$2) * (c.$2 - b.$2) > 0) return false;
    for (var j = i + 2; j < n; j++) {
      if (i == 0 && j == n - 1) continue; // the closing edge neighbours the first one
      if (_segmentsMeet(a, b, p[j], p[(j + 1) % n])) return false;
    }
  }
  return true;
}

/// Cross product of o→a and o→b: > 0 left turn, < 0 right turn, 0 collinear. Throws nothing.
double _cross(LonLat o, LonLat a, LonLat b) => (a.$1 - o.$1) * (b.$2 - o.$2) - (a.$2 - o.$2) * (b.$1 - o.$1);

/// Whether the collinear point [q] lies within the bounding box of segment [a]-[b]. Throws nothing.
bool _within(LonLat a, LonLat b, LonLat q) =>
    min(a.$1, b.$1) <= q.$1 && q.$1 <= max(a.$1, b.$1) && min(a.$2, b.$2) <= q.$2 && q.$2 <= max(a.$2, b.$2);

/// Whether segments [a]-[b] and [c]-[d] cross or touch (endpoints included). Throws nothing.
bool _segmentsMeet(LonLat a, LonLat b, LonLat c, LonLat d) {
  final d1 = _cross(c, d, a), d2 = _cross(c, d, b), d3 = _cross(a, b, c), d4 = _cross(a, b, d);
  if (d1 * d2 < 0 && d3 * d4 < 0) return true;
  return (d1 == 0 && _within(c, d, a)) ||
      (d2 == 0 && _within(c, d, b)) ||
      (d3 == 0 && _within(a, b, c)) ||
      (d4 == 0 && _within(a, b, d));
}

/// Whether the walked area differs from the declared size by more than [areaGapLimit] (FR66).
///
/// [declaredAcres] must be above 0 (the stepper's minimum is 1 cent); [walkedAcres] is null when no boundary was
/// walked, which is never a mismatch. Returns the flag; throws nothing.
bool areaMismatch(double declaredAcres, double? walkedAcres) =>
    walkedAcres != null && (walkedAcres - declaredAcres).abs() / declaredAcres > areaGapLimit;
