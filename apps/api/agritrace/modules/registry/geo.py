"""All spatial work of the platform: GI region checks, event-on-plot checks, walked area, outline checks.

PostGIS does the region and plot checks (explicit SQL below, geography in metres); shapely and pyproj do
the in-process parts (GeoJSON validation, geodesic area of a walked boundary).

Serves: FR27–FR32 (GI region, versioned outline, tolerance buffer), FR64–FR67 (pin and walked boundary,
automatic region check), FR69 (event GPS within the plot), FR70 (near-edge review), Stage 0, D-019,
backend-design.md §3 (simplified `gi_region` bundle part ≤ 50 KB).
Callers: registry service (plot create/correct, region upload and read); rules_flags (B08, event GPS
check via `event_within_plot`), events bundle (B07, `simplify_region`), lots_batches GI re-check (B09) —
all through `agritrace.modules.registry.service.__all__` (D-004). tests/unit/test_geo.py,
tests/integration/test_registry.py.
"""

import json
import uuid
from dataclasses import dataclass
from decimal import Decimal
from typing import Any, Literal

import shapely
from pyproj import Geod
from shapely.geometry import MultiPolygon, Polygon, shape
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.errors import GiRegionMissingError, InvalidGeometryError, NotFoundError
from agritrace.core.schemas import GeoPoint

SQ_M_PER_ACRE = Decimal("4046.8564224")  # international acre, exact
WGS84 = Geod(ellps="WGS84")
# Metres per degree of latitude; good enough to turn a simplification tolerance in metres into degrees.
M_PER_DEGREE = 111_320

GeoStatus = Literal["inside", "near_edge", "outside"]


@dataclass(frozen=True, slots=True)
class GeoResult:
    """Where a point lies relative to a GI tag's current region outline."""

    status: GeoStatus
    distance_m: float
    region_version_id: uuid.UUID
    buffer_m: Decimal


# DECISION D-019: the region check uses the latest effective `gi_region_versions` row and its own buffer.
#   ADV: an official or better outline replaces the district/taluk-derived one by inserting a version;
#     no code or schema change, and old checks stay explainable by version id.
#   COMPROMISE: the outline is an approximation (taluk outlines from geoBoundaries / LGD, ODbL-1.0, not the
#     GI registry's own map), so points within the buffer are `near_edge` (reviewed, FR70), never silently
#     confirmed or rejected.
# ST_Covers (not ST_Contains) so a pin exactly on the outline counts as inside; geography keeps metres.
_LOCATE_SQL = text(
    """
    SELECT r.id,
           r.tolerance_buffer_m,
           ST_Covers(r.geom, p.pt) AS covered,
           ST_DWithin(r.geom, p.pt, CAST(r.tolerance_buffer_m AS double precision)) AS within_buffer,
           ST_Distance(r.geom, p.pt) AS distance_m
    FROM gi_region_versions r,
         (SELECT ST_SetSRID(ST_MakePoint(CAST(:lon AS double precision), CAST(:lat AS double precision)),
                            4326)::geography AS pt) p
    WHERE r.gi_tag_id = :gi_tag_id AND r.effective_from <= CURRENT_DATE
    ORDER BY r.version_no DESC
    LIMIT 1
    """
)

# FR69: inside the walked boundary when there is one, else within a radius of the pin; both plus the
# GPS-drift buffer (FR32). ST_DWithin on a polygon is true for any point inside it (distance 0).
_EVENT_ON_PLOT_SQL = text(
    """
    SELECT CASE
             WHEN pl.walked_boundary IS NOT NULL
               THEN ST_DWithin(pl.walked_boundary, p.pt, CAST(:buffer_m AS double precision))
             ELSE ST_DWithin(pl.pin, p.pt, CAST(:radius_m AS double precision)
                                           + CAST(:buffer_m AS double precision))
           END AS on_plot
    FROM plots pl,
         (SELECT ST_SetSRID(ST_MakePoint(CAST(:lon AS double precision), CAST(:lat AS double precision)),
                            4326)::geography AS pt) p
    WHERE pl.id = :plot_id
    """
)

# Douglas-Peucker needs planar geometry, so simplify the geometry cast; precision 6 dp is about 0.1 m.
_SIMPLIFY_SQL = text(
    """
    SELECT ST_AsGeoJSON(
             ST_SimplifyPreserveTopology(geom::geometry, CAST(:tolerance_deg AS double precision)), 6)
    FROM gi_region_versions
    WHERE id = :region_version_id
    """
)


async def locate_point(session: AsyncSession, point: GeoPoint, gi_tag_id: uuid.UUID) -> GeoResult:
    """Check a point against the GI tag's current region outline and its tolerance buffer (FR28, FR32, FR67).

    Args:
        session: open database session.
        point: WGS84 point (accuracy is not used here; rules_flags judges GPS quality).
        gi_tag_id: GI tag whose latest effective region version applies.

    Returns:
        `inside` when the outline covers the point; `near_edge` when not covered but within
        `tolerance_buffer_m`; else `outside`. `distance_m` is 0 inside, else metres to the outline.

    Raises:
        GiRegionMissingError: the tag has no region version effective today (`gi_region_missing`).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    row = (
        await session.execute(_LOCATE_SQL, {"lon": point.lon, "lat": point.lat, "gi_tag_id": gi_tag_id})
    ).one_or_none()
    if row is None:
        raise GiRegionMissingError(details={"gi_tag_id": str(gi_tag_id)})
    status: GeoStatus = "inside" if row.covered else "near_edge" if row.within_buffer else "outside"
    return GeoResult(
        status=status,
        distance_m=float(row.distance_m),
        region_version_id=row.id,
        buffer_m=Decimal(row.tolerance_buffer_m),
    )


async def event_within_plot(
    session: AsyncSession, point: GeoPoint, plot_id: uuid.UUID, radius_m: float, buffer_m: float
) -> bool:
    """Tell whether an event's GPS fix lies on its plot (FR69).

    Args:
        session: open database session.
        point: the event's GPS fix.
        plot_id: plot the event is recorded against.
        radius_m: allowed distance from the pin when the plot has no walked boundary.
        buffer_m: GPS-drift buffer added in both cases (the GI tag's tolerance, FR32).

    Returns:
        True when inside the walked boundary (+ buffer), or within `radius_m + buffer_m` of the pin.

    Raises:
        NotFoundError: no plot with that id (`not_found`).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    params = {
        "lon": point.lon,
        "lat": point.lat,
        "plot_id": plot_id,
        "radius_m": radius_m,
        "buffer_m": buffer_m,
    }
    on_plot = (await session.execute(_EVENT_ON_PLOT_SQL, params)).scalar_one_or_none()
    if on_plot is None:
        raise NotFoundError(details={"plot_id": str(plot_id)})
    return bool(on_plot)


async def simplify_region(
    session: AsyncSession, region_version_id: uuid.UUID, tolerance_m: float = 50
) -> dict[str, Any]:
    """Return a region outline simplified for phones and the portal (bundle part `gi_region`, ≤ 50 KB).

    Args:
        session: open database session.
        region_version_id: `gi_region_versions.id` to simplify.
        tolerance_m: Douglas-Peucker tolerance in metres (converted to degrees at the latitude rate;
            slightly finer east-west at 9° N, about 49.4 m for 50 m, which is harmless).

    Returns:
        GeoJSON geometry dict (MultiPolygon or Polygon), coordinates rounded to 6 decimal places.

    Raises:
        NotFoundError: no region version with that id (`not_found`).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    params = {"region_version_id": region_version_id, "tolerance_deg": tolerance_m / M_PER_DEGREE}
    geojson = (await session.execute(_SIMPLIFY_SQL, params)).scalar_one_or_none()
    if geojson is None:
        raise NotFoundError(details={"region_version_id": str(region_version_id)})
    result: dict[str, Any] = json.loads(geojson)
    return result


def _checked(geom: Polygon | MultiPolygon) -> None:
    """Reject an empty, invalid or out-of-range outline.

    Args:
        geom: the parsed outline.

    Raises:
        InvalidGeometryError: empty, not valid by OGC rules (reason in `details`), or outside WGS84 ranges.
    """
    if geom.is_empty:
        raise InvalidGeometryError(details={"reason": "empty geometry"})
    if not geom.is_valid:
        raise InvalidGeometryError(details={"reason": shapely.is_valid_reason(geom)})
    min_lon, min_lat, max_lon, max_lat = geom.bounds
    if min_lon < -180 or max_lon > 180 or min_lat < -90 or max_lat > 90:
        raise InvalidGeometryError(details={"reason": "coordinates must be [lon, lat] in WGS84 degrees"})


def parse_polygon(geojson: dict[str, Any]) -> Polygon:
    """Parse and validate a walked boundary given as a GeoJSON Polygon (FR66).

    Args:
        geojson: `{"type": "Polygon", "coordinates": [[[lon, lat], ...]]}`.

    Returns:
        The shapely polygon.

    Raises:
        InvalidGeometryError: not a Polygon, unparseable, empty, self-intersecting or out of range.
    """
    geom = _shape(geojson)
    if not isinstance(geom, Polygon):
        raise InvalidGeometryError(details={"reason": f"expected Polygon, got {geom.geom_type}"})
    _checked(geom)
    return geom


def parse_multipolygon(geojson: dict[str, Any]) -> MultiPolygon:
    """Parse and validate a GI region outline given as a GeoJSON MultiPolygon (FR27, FR31).

    Args:
        geojson: `{"type": "MultiPolygon", "coordinates": [[[[lon, lat], ...]]]}`.

    Returns:
        The shapely multipolygon.

    Raises:
        InvalidGeometryError: not a MultiPolygon, unparseable, empty, invalid or out of range.
    """
    geom = _shape(geojson)
    if not isinstance(geom, MultiPolygon):
        raise InvalidGeometryError(details={"reason": f"expected MultiPolygon, got {geom.geom_type}"})
    _checked(geom)
    return geom


def _shape(geojson: dict[str, Any]) -> Any:
    """Build a shapely geometry from a GeoJSON geometry mapping.

    Args:
        geojson: a GeoJSON geometry object.

    Returns:
        The shapely geometry.

    Raises:
        InvalidGeometryError: the mapping cannot be parsed (unclosed ring, too few points, bad nesting).
    """
    try:
        return shape(geojson)
    except (ValueError, TypeError, KeyError, AttributeError, shapely.errors.GEOSException) as e:
        raise InvalidGeometryError(details={"reason": str(e)}) from e


def walked_area_acres(polygon_geojson: dict[str, Any]) -> Decimal:
    """Geodesic area of a walked boundary on the WGS84 ellipsoid, in acres (FR66).

    Args:
        polygon_geojson: GeoJSON Polygon in [lon, lat].

    Returns:
        Area in acres, rounded to 0.001 acre (about 4 m²); ring direction does not matter.

    Raises:
        InvalidGeometryError: from `parse_polygon`.
    """
    area_m2, _perimeter = WGS84.geometry_area_perimeter(parse_polygon(polygon_geojson))
    return (Decimal(abs(area_m2)) / SQ_M_PER_ACRE).quantize(Decimal("0.001"))
