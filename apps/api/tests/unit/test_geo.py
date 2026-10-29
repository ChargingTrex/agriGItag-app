"""Unit tests of the in-process geometry helpers and the non-official GI region test fixture.

Serves: FR27 (MultiPolygon outlines), FR66 (walked area), FR32 (fixture geometry for the 150 m buffer
cases in tests/integration/test_registry.py), D-019.
Callers: pytest (`make test-unit`).
"""

import json
import math
from decimal import Decimal
from pathlib import Path

import pytest
from pyproj import Geod
from shapely.geometry import Point, shape

from agritrace.core.errors import InvalidGeometryError
from agritrace.modules.registry.geo import parse_multipolygon, parse_polygon, walked_area_acres

FIXTURE = Path(__file__).parents[2] / "agritrace" / "seed" / "fixtures" / "gi_region_fixture.geojson"
REFERENCE = (9.559806, 78.133521)  # lat, lon from the acceptance test
MADURAI = (9.9252, 78.1198)
NEAR_EDGE = (9.55, 78.300911)  # about 100 m east of the fixture's east edge (meridian 78.30)


def _square(lat: float, lon: float, side_m: float) -> dict[str, object]:
    """Build a GeoJSON square of `side_m` metres with its south-west corner at (lat, lon).

    Args:
        lat: latitude of the south-west corner.
        lon: longitude of the south-west corner.
        side_m: side length in metres.

    Returns:
        GeoJSON Polygon.
    """
    dlat = side_m / 110_574
    dlon = side_m / (111_320 * math.cos(math.radians(lat)))
    ring = [[lon, lat], [lon + dlon, lat], [lon + dlon, lat + dlat], [lon, lat + dlat], [lon, lat]]
    return {"type": "Polygon", "coordinates": [ring]}


def test_walked_area_of_100m_square_is_about_2_47_acres() -> None:
    """A 100 m × 100 m square is 10,000 m² = 2.471 acres (± 2 %), in either ring direction."""
    square = _square(*REFERENCE, 100)
    area = walked_area_acres(square)
    assert abs(area - Decimal("2.471")) / Decimal("2.471") < Decimal("0.02")
    reversed_square = {"type": "Polygon", "coordinates": [square["coordinates"][0][::-1]]}  # type: ignore[index]
    assert walked_area_acres(reversed_square) == area


@pytest.mark.parametrize(
    ("geojson", "reason"),
    [
        (
            {"type": "Polygon", "coordinates": [[[78, 9], [78.1, 9], [78.1, 9.1], [78, 9]]]},
            "expected MultiPolygon",
        ),
        (  # bow-tie: the ring crosses itself
            {
                "type": "MultiPolygon",
                "coordinates": [[[[78, 9], [78.1, 9.1], [78.1, 9], [78, 9.1], [78, 9]]]],
            },
            "Self-intersection",
        ),
        ({"type": "MultiPolygon", "coordinates": [[[[9, 78], [9.1, 78], [9.1, 278], [9, 78]]]]}, "WGS84"),
        ({"type": "MultiPolygon", "coordinates": [[[[78, 9], [78.1, 9]]]]}, ""),  # too few points
    ],
)
def test_multipolygon_validation_rejects_bad_outlines(geojson: dict[str, object], reason: str) -> None:
    """Wrong type, self-intersection, out-of-range and degenerate rings raise `invalid_geometry`.

    Args:
        geojson: the bad outline.
        reason: text expected in `details.reason`.
    """
    with pytest.raises(InvalidGeometryError) as caught:
        parse_multipolygon(geojson)
    assert caught.value.code == "invalid_geometry"
    assert reason in caught.value.details["reason"]


def test_valid_outlines_parse() -> None:
    """The fixture parses as a MultiPolygon and a square as a Polygon; a MultiPolygon is not a Polygon."""
    fixture = json.loads(FIXTURE.read_text())["features"][0]["geometry"]
    assert parse_multipolygon(fixture).geom_type == "MultiPolygon"
    assert parse_polygon(_square(*REFERENCE, 50)).geom_type == "Polygon"
    with pytest.raises(InvalidGeometryError):
        parse_polygon(fixture)


def test_fixture_is_labelled_small_and_places_the_acceptance_points() -> None:
    """The fixture says it is non-official, stays under 50 KB, and sets up inside / near-edge / outside.

    PostGIS decides these in the integration test; this checks the fixture itself with shapely and pyproj.
    """
    doc = json.loads(FIXTURE.read_text())
    props = doc["features"][0]["properties"]
    assert props["official"] is False and "NON-OFFICIAL" in props["label"]
    assert FIXTURE.stat().st_size < 50_000
    outline = shape(doc["features"][0]["geometry"])
    assert outline.covers(Point(REFERENCE[1], REFERENCE[0]))
    assert not outline.covers(Point(MADURAI[1], MADURAI[0]))
    assert not outline.covers(Point(NEAR_EDGE[1], NEAR_EDGE[0]))
    _, _, edge_distance_m = Geod(ellps="WGS84").inv(78.30, NEAR_EDGE[0], NEAR_EDGE[1], NEAR_EDGE[0])
    assert 95 < edge_distance_m < 105  # inside the 150 m buffer
