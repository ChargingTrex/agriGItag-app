"""Unit tests of the registry's pure rules and of the routes' checks that run before any database access.

Covers: declared-vs-walked gap (FR66), acres/cents, location status (FR64, FR67), address formatting
without repeated parts (PRD §12.2, FR53), cursor pagination, field descriptions in the OpenAPI contract,
`reason_required` on a correction without reason (FR71) and 403 for an FPO admin uploading a GI region
(FR31) — the last two with a stand-in session, so they run without Docker.
Callers: pytest (`make test-unit`).
"""

import uuid
from decimal import Decimal
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import LocationStatus, PinMethod, Role
from agritrace.core.errors import ValidationFailedError
from agritrace.core.schemas import Address, Quantity
from agritrace.main import create_app
from agritrace.modules.registry.geo import GeoResult
from agritrace.modules.registry.schemas import format_address
from agritrace.modules.registry.service import (
    _page,
    area_gap,
    decode_cursor,
    encode_cursor,
    location_status,
    to_acres,
)

FPO = uuid.uuid4()


@pytest.mark.parametrize(
    ("declared", "walked", "pct", "exceeds"),
    [
        ("1.000", None, None, False),
        ("1.000", "1.200", "20.0", False),  # exactly 20 % is tolerated
        ("1.000", "1.201", "20.1", True),
        ("2.000", "1.500", "-25.0", True),
        ("2.000", "1.900", "-5.0", False),
    ],
)
def test_area_gap_flags_more_than_20_percent(
    declared: str, walked: str | None, pct: str | None, exceeds: bool
) -> None:
    """The walked area may differ from the declared size by up to 20 % either way (FR66).

    Args:
        declared: declared acres.
        walked: walked acres or None.
        pct: expected gap percent or None.
        exceeds: expected flag.
    """
    got = area_gap(Decimal(declared), None if walked is None else Decimal(walked))
    assert got == (None if pct is None else Decimal(pct), exceeds)


def test_to_acres_accepts_acres_and_cents_only() -> None:
    """100 cents = 1 acre; other units and zero are refused."""
    assert to_acres(Quantity(value=Decimal("150"), unit="cents")) == Decimal("1.500")
    assert to_acres(Quantity(value=Decimal("2.5"), unit="acre")) == Decimal("2.500")
    for bad in (Quantity(value=Decimal("1"), unit="ha"), Quantity(value=Decimal("0"), unit="acre")):
        with pytest.raises(ValidationFailedError):
            to_acres(bad)


def _geo(status: str) -> GeoResult:
    """Build a region check result.

    Args:
        status: inside, near_edge or outside.

    Returns:
        A result with dummy distance and version.
    """
    return GeoResult(status=status, distance_m=0.0, region_version_id=uuid.uuid4(), buffer_m=Decimal(150))  # type: ignore[arg-type]


def test_location_status_mapping() -> None:
    """Live pin: inside→confirmed, near_edge, outside; unreviewed map pin or no region→needs_review."""
    live = PinMethod.LIVE_GPS
    assert location_status(_geo("inside"), live, reviewed=False) == LocationStatus.CONFIRMED
    assert location_status(_geo("near_edge"), live, reviewed=False) == LocationStatus.NEAR_EDGE
    assert location_status(_geo("outside"), live, reviewed=False) == LocationStatus.OUTSIDE
    assert location_status(None, live, reviewed=False) == LocationStatus.NEEDS_REVIEW
    assert location_status(_geo("inside"), PinMethod.MAP_PIN, reviewed=False) == LocationStatus.NEEDS_REVIEW
    assert location_status(_geo("inside"), PinMethod.MAP_PIN, reviewed=True) == LocationStatus.CONFIRMED


def test_address_line_has_no_repeated_segment() -> None:
    """The PRD sample's "Tiruchuli, Tiruchuli" cannot happen: equal parts show once (FR53)."""
    address = Address(
        village="P Thottiyangulam", block="Tiruchuli", taluk="tiruchuli ", district="Virudhunagar"
    )
    assert format_address(address) == "P Thottiyangulam, Tiruchuli, Virudhunagar"
    assert format_address(
        {"village": "Tiruchuli", "taluk": "Tiruchuli", "state": "Tamil Nadu", "pin": "626129"}
    ) == ("Tiruchuli, Tamil Nadu, 626129")
    assert format_address(None) == ""


def test_cursor_round_trip_and_paging() -> None:
    """Cursors round-trip, garbage is a validation error, and a page knows whether more follow."""
    cursor = encode_cursor(["Tiruchuli", "018f0000-0000-7000-8000-000000000000"])
    assert decode_cursor(cursor, 2) == ["Tiruchuli", "018f0000-0000-7000-8000-000000000000"]
    for bad in ("not-base64!", encode_cursor(["only-one"])):
        with pytest.raises(ValidationFailedError):
            decode_cursor(bad, 2)
    items, next_cursor, has_more = _page([1, 2, 3], 2, lambda n: [str(n)])
    assert (items, has_more) == ([1, 2], True) and next_cursor and decode_cursor(next_cursor, 1) == ["2"]
    assert _page([1, 2], 2, lambda n: [str(n)]) == ([1, 2], None, False)


def test_every_registry_field_and_parameter_is_described() -> None:
    """OpenAPI: every registry path is present and every schema property and parameter has a description."""
    spec = create_app().openapi()
    expected = {
        "/v1/fpos",
        "/v1/processors",
        "/v1/villages",
        "/v1/farmers",
        "/v1/farmers/{farmer_id}",
        "/v1/farmers/{farmer_id}/approve",
        "/v1/plots",
        "/v1/plots/{plot_id}",
        "/v1/plots/{plot_id}/correct",
        "/v1/crops",
        "/v1/gi-tags/{gi_tag_id}/region",
        "/v1/gi-tags/{gi_tag_id}/region-versions",
        "/v1/inputs",
    }
    assert expected <= set(spec["paths"])
    undocumented = [
        f"{name}.{field}"
        for name, schema in spec["components"]["schemas"].items()
        for field, prop in schema.get("properties", {}).items()
        if "description" not in prop
    ]
    undocumented += [
        f"{path} {p['name']}"
        for path in expected
        for op in spec["paths"][path].values()
        for p in op.get("parameters", [])
        if not p.get("description")
    ]
    assert undocumented == []


class _NoSuperAdmin:
    """Stand-in session: every scalar query answers False (the caller is not a super-admin)."""

    async def scalar(self, *_: Any) -> bool:
        """Answer any scalar query.

        Args:
            *_: the statement (ignored).

        Returns:
            False.
        """
        return False


def _client(role: Role) -> AsyncClient:
    """Build an in-process client whose caller has `role` and whose session is `_NoSuperAdmin`.

    Args:
        role: the caller's role.

    Returns:
        HTTP client for the app.
    """
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: CurrentUser(
        user_id=uuid.uuid4(), fpo_id=FPO, role=role
    )
    app.dependency_overrides[get_session] = _NoSuperAdmin
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test")


async def test_correction_without_reason_is_422_reason_required() -> None:
    """An FPO admin correction with no reason code is refused before anything is read or written (FR71)."""
    async with _client(Role.FPO_ADMIN) as client:
        response = await client.post(f"/v1/plots/{uuid.uuid4()}/correct", json={"reason_text": "moved"})
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "reason_required"


async def test_field_officer_cannot_correct_a_plot() -> None:
    """Only the FPO admin corrects plots (FR71)."""
    async with _client(Role.FIELD_OFFICER) as client:
        response = await client.post(f"/v1/plots/{uuid.uuid4()}/correct", json={"reason_code": "gps_drift"})
    assert response.status_code == 403


async def test_fpo_admin_uploading_a_region_is_403() -> None:
    """GI regions are a legal fact edited only by the compliance team (FR31)."""
    body = {
        "geometry": {"type": "MultiPolygon", "coordinates": [[[[78, 9], [78.1, 9], [78.1, 9.1], [78, 9]]]]},
        "tolerance_buffer_m": 150,
        "source_ref": "test",
        "licence": "CC0-1.0",
    }
    async with _client(Role.FPO_ADMIN) as client:
        response = await client.post(f"/v1/gi-tags/{uuid.uuid4()}/region-versions", json=body)
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "forbidden"
