// Walked-boundary arithmetic: geodesic area of a GPS ring, acres and cents, and the declared-vs-walked mismatch rule.
// Requirement: FR66 (walked boundary: "computes the walked area and flags a gap with the declared size above a set
//   tolerance"), FR65 (declared size in acres; 100 cents = 1 acre), UserFlows §Onboarding a farmer steps 5-6,
//   Dataflow Stage 0 (System Action: "computes its area and flags a mismatch with declared size").
// Callers: onboarding_notifier.dart (OnboardingDraft.walkedAcres, declaredAcres), boundary_step.dart;
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

/// Whether the walked area differs from the declared size by more than [areaGapLimit] (FR66).
///
/// [declaredAcres] must be above 0 (the stepper's minimum is 1 cent); [walkedAcres] is null when no boundary was
/// walked, which is never a mismatch. Returns the flag; throws nothing.
bool areaMismatch(double declaredAcres, double? walkedAcres) =>
    walkedAcres != null && (walkedAcres - declaredAcres).abs() / declaredAcres > areaGapLimit;
