/**
 * Bounding boxes for the plot map: of a GeoJSON geometry, and of the GI area plus the plot pin.
 * Serves: plan §13 D3 (cache map tiles for the FPO area), FR28 (GI region outline). Called by:
 * src/features/members/PlotMap.tsx.
 */

/** `[west, south, east, north]` in degrees (the order MapLibre's `bounds` and `maxBounds` take). */
export type BBox = [number, number, number, number];

/**
 * Computes the bounding box of any GeoJSON geometry (Point to MultiPolygon) from its nested coordinates.
 * @param geometry A GeoJSON geometry object as served by `GET /v1/gi-tags/{id}/region`.
 * @param padDeg Degrees added on every side (about 11 km per 0.1°), so pins near the edge keep context.
 * @returns The padded box, or null when the geometry has no coordinates.
 */
export function bbox(geometry: Record<string, unknown>, padDeg = 0): BBox | null {
  const box: BBox = [Infinity, Infinity, -Infinity, -Infinity];
  /**
   * Visits nested coordinate arrays and widens `box` for each `[lon, lat]` pair.
   * @param node A coordinate array at any depth.
   */
  const visit = (node: unknown): void => {
    if (!Array.isArray(node)) return;
    const [lon, lat] = node as unknown[];
    if (typeof lon === 'number' && typeof lat === 'number') {
      box[0] = Math.min(box[0], lon);
      box[1] = Math.min(box[1], lat);
      box[2] = Math.max(box[2], lon);
      box[3] = Math.max(box[3], lat);
      return;
    }
    node.forEach(visit);
  };
  visit(geometry['coordinates']);
  if (box[0] === Infinity) return null;
  return [box[0] - padDeg, box[1] - padDeg, box[2] + padDeg, box[3] + padDeg];
}

/**
 * The area the plot map may show and load tiles for: the GI region's box widened to include the plot pin,
 * then padded, so a plot far outside the region (the ones reviewers open from a flag, FR70) stays on screen.
 * @param pin Plot pin, WGS84.
 * @param pin.lat Latitude.
 * @param pin.lon Longitude.
 * @param region GI region geometry, or null when none is loaded (then the map is not limited).
 * @param padDeg Degrees added on every side.
 * @returns `[west, south, east, north]`, or null without a region.
 */
export function plotArea(
  pin: { lat: number; lon: number },
  region: Record<string, unknown> | null,
  padDeg: number,
): BBox | null {
  return region ? bbox({ coordinates: [region['coordinates'], [pin.lon, pin.lat]] }, padDeg) : null;
}
