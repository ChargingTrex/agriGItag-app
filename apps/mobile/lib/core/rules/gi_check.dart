// GI region preview: is a pin inside the GI production area, within the tolerance buffer of its edge, or outside?
// Same three outcomes as the server's `registry.geo.locate_point` (PostGIS ST_Covers / ST_DWithin on geography).
// Requirement: FR28, FR32 (tolerance buffer), FR67 (automatic region check, "Location confirmed"), FR70 (near-edge
//   review), D-019 (outline is an approximation, so near-edge is reviewed), D-006 (phone preview, server authority).
// Callers: officer onboarding GI preview (M09), plot screens; test/rules/preview_rules_test.dart.

import 'dart:math';

import '../refdata/models/reference.dart';

/// Where a point lies relative to the GI outline (server `GeoStatus`: inside, near_edge, outside).
enum GiStatus {
  /// Covered by the outline (a point on the outline counts as inside, like ST_Covers).
  inside,

  /// Outside, but within the region's tolerance buffer: shown as a tick, reviewed on the server (FR70).
  nearEdge,

  /// Farther than the buffer from the outline: shown orange.
  outside,
}

/// Mean Earth radius in metres (IUGG).
const _earthRadiusM = 6371008.8;

/// Checks the pin at [lat], [lon] (WGS 84 degrees) against [region] and its buffer.
///
/// Returns the status and the distance to the outline in metres (0 when inside). Throws nothing.
({GiStatus status, double distanceM}) giCheck(GiRegion region, double lat, double lon) {
  // shortcut: equirectangular projection centred on the pin; well under 1 m error within a few km of the edge,
  //   which is all a 50–150 m buffer needs. Upgrade to a geodesic distance if buffers ever reach tens of km.
  const ky = _earthRadiusM * pi / 180; // metres per degree of latitude
  final kx = ky * cos(lat * pi / 180); // metres per degree of longitude at the pin
  var inside = false;
  var nearest = double.infinity;
  for (final polygon in region.polygons) {
    var crossings = 0; // even-odd over all rings, so holes count as outside
    for (final ring in polygon) {
      for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
        final x1 = (ring[j].$1 - lon) * kx, y1 = (ring[j].$2 - lat) * ky;
        final x2 = (ring[i].$1 - lon) * kx, y2 = (ring[i].$2 - lat) * ky;
        if ((y1 > 0) != (y2 > 0) && 0 < x1 - y1 * (x2 - x1) / (y2 - y1)) crossings++;
        nearest = min(nearest, _distanceToSegment(x1, y1, x2, y2));
      }
    }
    inside = inside || crossings.isOdd;
  }
  // Within 1 mm of the outline counts as on it (ST_Covers), whatever the ray test says.
  if (inside || nearest < 0.001) return (status: GiStatus.inside, distanceM: 0);
  return (status: nearest <= region.bufferM ? GiStatus.nearEdge : GiStatus.outside, distanceM: nearest);
}

/// Distance in metres from the origin (the pin) to the segment ([x1], [y1])–([x2], [y2]) in local metres.
///
/// Returns the length of the perpendicular, or of the nearer end when the foot falls outside. Throws nothing.
double _distanceToSegment(double x1, double y1, double x2, double y2) {
  final dx = x2 - x1, dy = y2 - y1;
  final len2 = dx * dx + dy * dy;
  final t = len2 == 0 ? 0.0 : (-(x1 * dx + y1 * dy) / len2).clamp(0.0, 1.0);
  final px = x1 + t * dx, py = y1 + t * dy;
  return sqrt(px * px + py * py);
}
