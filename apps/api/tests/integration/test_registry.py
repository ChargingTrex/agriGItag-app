"""Integration tests of the registry API and the PostGIS checks on a real database.

Covers every B03 acceptance line: fixture polygon + 150 m buffer with (9.559806, 78.133521) inside, a point
100 m outside → near_edge, Madurai → outside, `map_pin` → needs_review, correction without reason → 422 and
with reason → revision kept, cross-FPO read → 404, FPO admin uploading a region → 403; plus farmer users
rows (F7), approval, idempotent plot resend, `plot_locked`, `reference_versions` bump, `event_within_plot`
and the simplified region size.

Serves: FR24, FR27–FR32, FR53, FR64–FR72, Stage 0, D-005, D-019, docs/agents/acceptance/B03.md.
Callers: pytest (`make test`); needs Docker (PostGIS, Valkey, LocalStack from tests/conftest.py `stack`).
"""

import json
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from shapely import wkt
from sqlalchemy import select, text

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import OrgKind, Role
from agritrace.core.schemas import GeoPoint
from agritrace.main import create_app
from agritrace.modules.identity.models import Membership, User
from agritrace.modules.registry.models import Farmer, Fpo, GiTag, PlotRevision, Village
from agritrace.modules.registry.service import event_within_plot

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
FIXTURE = API_DIR / "agritrace" / "seed" / "fixtures" / "gi_region_fixture.geojson"
REFERENCE = {"lat": 9.559806, "lon": 78.133521, "accuracy_m": 6.2}
NEAR_EDGE = {"lat": 9.55, "lon": 78.300911, "accuracy_m": 5.0}  # ~100 m east of the fixture edge
MADURAI = {"lat": 9.9252, "lon": 78.1198, "accuracy_m": 5.0}
NOW = datetime(2026, 3, 4, 8, 12, tzinfo=UTC).isoformat()


@pytest.fixture(scope="module")
async def ids(stack: None) -> dict[str, Any]:
    """Migrate, then create two FPOs, a super-admin, an admin and officer in FPO A, and a GI tag.

    Args:
        stack: the running containers (fixture).

    Returns:
        Ids by name: fpo_a, fpo_b, super_admin, admin_a, officer_a, admin_b, gi_tag.

    Side effects:
        Runs `alembic upgrade head`; inserts rows (fresh codes and phones, so reruns do not clash).
    """
    alembic = Path(sys.executable).parent / "alembic"
    subprocess.run([str(alembic), "upgrade", "head"], cwd=API_DIR, check=True)  # noqa: S603
    ids: dict[str, Any] = {}
    async with get_sessionmaker()() as s:
        for key in ("fpo_a", "fpo_b"):
            fpo = Fpo(code=f"T{secrets.token_hex(4).upper()}", name=key, kind=OrgKind.FPO)
            s.add(fpo)
            await s.flush()
            ids[key] = fpo.id
        for key, fpo_key, role, super_admin in (
            ("super_admin", "fpo_a", Role.FPO_ADMIN, True),
            ("admin_a", "fpo_a", Role.FPO_ADMIN, False),
            ("officer_a", "fpo_a", Role.FIELD_OFFICER, False),
            ("admin_b", "fpo_b", Role.FPO_ADMIN, False),
        ):
            user = User(phone=f"+9190{secrets.randbelow(10**8):08d}", name=key, is_super_admin=super_admin)
            s.add(user)
            await s.flush()
            s.add(Membership(user_id=user.id, fpo_id=ids[fpo_key], role=role))
            ids[key] = user.id
        tag = GiTag(gi_number=f"T{secrets.token_hex(3)}", name="Test GI")
        s.add(tag)
        await s.flush()
        ids["gi_tag"] = tag.id
        await s.commit()
    return ids


class Caller:
    """Mutable stand-in for `get_current_user`, so one client can act as different users."""

    def __init__(self) -> None:
        """Start with no caller."""
        self.user: CurrentUser | None = None

    def __call__(self) -> CurrentUser:
        """Return the current caller.

        Returns:
            The user set by the test.
        """
        assert self.user is not None
        return self.user


@pytest.fixture
async def api(ids: dict[str, Any]) -> AsyncIterator[tuple[AsyncClient, Caller]]:
    """An in-process client whose caller is chosen per request via `Caller`.

    Args:
        ids: the seeded ids.

    Returns:
        An async iterator yielding (client, caller holder).
    """
    app = create_app()
    caller = Caller()
    app.dependency_overrides[get_current_user] = caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client, caller


def _as(caller: Caller, ids: dict[str, Any], who: str, fpo: str, role: Role) -> None:
    """Switch the caller.

    Args:
        caller: the holder.
        ids: the seeded ids.
        who: key of the user id in `ids`.
        fpo: key of the FPO id in `ids`.
        role: role to act in.
    """
    caller.user = CurrentUser(user_id=ids[who], fpo_id=ids[fpo], role=role)


async def _region(client: AsyncClient, caller: Caller, ids: dict[str, Any]) -> dict[str, Any]:
    """Upload the fixture outline as super-admin with a 150 m buffer.

    Args:
        client: API client.
        caller: caller holder.
        ids: the seeded ids.

    Returns:
        The created region version.
    """
    _as(caller, ids, "super_admin", "fpo_a", Role.FPO_ADMIN)
    geometry = json.loads(FIXTURE.read_text())["features"][0]["geometry"]
    body = {"geometry": geometry, "tolerance_buffer_m": 150, "source_ref": "fixture", "licence": "CC0-1.0"}
    response = await client.post(f"/v1/gi-tags/{ids['gi_tag']}/region-versions", json=body)
    assert response.status_code == 201, response.text
    result: dict[str, Any] = response.json()
    return result


async def _farmer(
    client: AsyncClient, caller: Caller, ids: dict[str, Any], fpo: str = "fpo_a", **extra: Any
) -> dict[str, Any]:
    """Onboard a farmer as that FPO's admin.

    Args:
        client: API client.
        caller: caller holder.
        ids: the seeded ids.
        fpo: `fpo_a` or `fpo_b`.
        **extra: more body fields.

    Returns:
        The created farmer.
    """
    _as(caller, ids, "admin_a" if fpo == "fpo_a" else "admin_b", fpo, Role.FPO_ADMIN)
    response = await client.post("/v1/farmers", json={"name": "Muthu", **extra})
    assert response.status_code == 201, response.text
    result: dict[str, Any] = response.json()
    return result


def _plot(farmer_id: str, ids: dict[str, Any], pin: dict[str, float], **extra: Any) -> dict[str, Any]:
    """Build a plot body.

    Args:
        farmer_id: owner.
        ids: the seeded ids.
        pin: pin coordinates.
        **extra: overrides.

    Returns:
        Request body.
    """
    return {
        "client_id": str(uuid.uuid4()),
        "farmer_id": farmer_id,
        "gi_tag_id": str(ids["gi_tag"]),
        "pin": pin,
        "device_time": NOW,
        "declared_area": {"value": "1.5", "unit": "acre"},
        **extra,
    }


async def test_region_upload_check_and_bundle_size(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Admin upload → 403; super-admin upload versions; GET region is simplified and ≤ 50 KB.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    geometry = json.loads(FIXTURE.read_text())["features"][0]["geometry"]
    body = {"geometry": geometry, "tolerance_buffer_m": 150, "source_ref": "fixture", "licence": "CC0-1.0"}
    denied = await client.post(f"/v1/gi-tags/{ids['gi_tag']}/region-versions", json=body)
    assert denied.status_code == 403
    first = await _region(client, caller, ids)
    second = await _region(client, caller, ids)
    assert second["version_no"] == first["version_no"] + 1
    bad = {
        **body,
        "geometry": {
            "type": "MultiPolygon",
            "coordinates": [[[[78, 9], [78.1, 9.1], [78.1, 9], [78, 9.1], [78, 9]]]],
        },
    }
    assert (await client.post(f"/v1/gi-tags/{ids['gi_tag']}/region-versions", json=bad)).json()["error"][
        "code"
    ] == "invalid_geometry"
    region = await client.get(f"/v1/gi-tags/{ids['gi_tag']}/region")
    assert region.status_code == 200
    assert region.json()["version"]["version_no"] == second["version_no"]
    assert len(json.dumps(region.json()["geometry"])) <= 50_000


async def test_plot_region_statuses(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """Inside → confirmed; 100 m outside → near_edge; Madurai → outside; map pin → needs_review.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    await _region(client, caller, ids)
    farmer = await _farmer(client, caller, ids)
    _as(caller, ids, "officer_a", "fpo_a", Role.FIELD_OFFICER)
    cases = [
        (REFERENCE, "live_gps", "confirmed", "inside"),
        (NEAR_EDGE, "live_gps", "near_edge", "near_edge"),
        (MADURAI, "live_gps", "outside", "outside"),
        (REFERENCE, "map_pin", "needs_review", "inside"),
    ]
    for pin, method, expected, geo_status in cases:
        response = await client.post("/v1/plots", json=_plot(farmer["id"], ids, pin, pin_method=method))
        assert response.status_code == 201, response.text
        plot = response.json()
        assert plot["location_status"] == expected, (pin, plot)
        assert plot["region_check"]["status"] == geo_status
    assert plot["location_method_label"] == "Map pin"


async def test_plot_idempotency_lock_walked_gap_and_reference_bump(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Resend → 200 same plot; changed pin → plot_locked; walked gap flagged; plots part version bumps.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    farmer = await _farmer(client, caller, ids)
    lon, lat = REFERENCE["lon"], REFERENCE["lat"]
    d = 0.0009  # about 100 m: a ~1 ha square, ≈ 2.4 acres walked vs 1.5 declared → gap > 20 %
    walked = {
        "type": "Polygon",
        "coordinates": [[[lon, lat], [lon + d, lat], [lon + d, lat + d], [lon, lat + d], [lon, lat]]],
    }
    body = _plot(farmer["id"], ids, REFERENCE, walked_boundary=walked)
    async with get_sessionmaker()() as s:
        before = await s.scalar(text("SELECT max(version) FROM reference_versions WHERE part = 'plots'"))
    created = await client.post("/v1/plots", json=body)
    assert created.status_code == 201, created.text
    assert created.json()["area_gap_exceeds"] is True
    assert created.json()["location_method_label"] == "Boundary walked"
    again = await client.post("/v1/plots", json=body)
    assert again.status_code == 200 and again.json()["id"] == created.json()["id"]
    moved = await client.post("/v1/plots", json={**body, "pin": NEAR_EDGE})
    assert moved.status_code == 409 and moved.json()["error"]["code"] == "plot_locked"
    async with get_sessionmaker()() as s:
        after = await s.scalar(text("SELECT max(version) FROM reference_versions WHERE part = 'plots'"))
        on_plot = await event_within_plot(
            s, GeoPoint(lat=lat + d / 2, lon=lon + d / 2), uuid.UUID(created.json()["id"]), 100, 150
        )
        off_plot = await event_within_plot(
            s, GeoPoint(lat=lat + 0.01, lon=lon), uuid.UUID(created.json()["id"]), 100, 150
        )
    assert after is not None and (before is None or after > before)
    assert on_plot is True and off_plot is False


async def test_plot_correction_needs_reason_and_keeps_revision(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """No reason → 422 reason_required; with reason → revision 2 and the old pin in plot_revisions.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    await _region(client, caller, ids)
    farmer = await _farmer(client, caller, ids)
    plot = (await client.post("/v1/plots", json=_plot(farmer["id"], ids, NEAR_EDGE))).json()
    no_reason = await client.post(f"/v1/plots/{plot['id']}/correct", json={"pin": REFERENCE})
    assert no_reason.status_code == 422 and no_reason.json()["error"]["code"] == "reason_required"
    fixed = await client.post(
        f"/v1/plots/{plot['id']}/correct",
        json={"pin": REFERENCE, "reason_code": "gps_drift", "gi_tag_id": str(ids["gi_tag"])},
    )
    assert fixed.status_code == 200, fixed.text
    assert fixed.json()["revision_no"] == 2 and fixed.json()["location_status"] == "confirmed"
    async with get_sessionmaker()() as s:
        revision = await s.scalar(select(PlotRevision).where(PlotRevision.plot_id == uuid.UUID(plot["id"])))
    assert revision is not None and revision.revision_no == 1 and revision.reason_code == "gps_drift"
    old_pin = wkt.loads(revision.snapshot["pin"])
    assert (old_pin.x, old_pin.y) == pytest.approx((NEAR_EDGE["lon"], NEAR_EDGE["lat"]))


async def test_farmers_scope_users_row_and_approval(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Phone → users row + membership (F7); FPO A cannot see FPO B's farmer (404); approve once.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    phone = f"+9198{secrets.randbelow(10**8):08d}"
    farmer = await _farmer(client, caller, ids, phone=phone, no_smartphone=True)
    async with get_sessionmaker()() as s:
        user = await s.scalar(select(User).where(User.phone == phone))
        assert user is not None and farmer["user_id"] == str(user.id)
        role = await s.scalar(select(Membership.role).where(Membership.user_id == user.id))
        assert role == Role.FARMER
    duplicate = await client.post("/v1/farmers", json={"name": "Other", "phone": phone})
    assert duplicate.status_code == 409 and duplicate.json()["error"]["code"] == "farmer_phone_taken"

    other = await _farmer(client, caller, ids, fpo="fpo_b")
    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    assert (await client.get(f"/v1/farmers/{other['id']}")).status_code == 404
    _as(caller, ids, "admin_a", "fpo_a", Role.FARMER)  # a farmer of FPO A
    assert (await client.get(f"/v1/farmers/{other['id']}")).status_code == 404

    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    approved = await client.post(f"/v1/farmers/{farmer['id']}/approve")
    assert approved.status_code == 200 and approved.json()["status"] == "active"
    assert approved.json()["approved_by"] == str(ids["admin_a"])
    again = await client.post(f"/v1/farmers/{farmer['id']}/approve")
    assert again.status_code == 409 and again.json()["error"]["code"] == "farmer_not_pending"
    async with get_sessionmaker()() as s:
        stored = await s.get(Farmer, uuid.UUID(farmer["id"]))
        assert stored is not None and stored.approved_at is not None
        audited = await s.scalar(
            text("SELECT count(*) FROM audit_log WHERE entity_id = :id AND action = 'update'"),
            {"id": stored.id},
        )
    assert audited and audited >= 1


async def test_masters_fpos_processors_inputs_villages_crops(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Super-admin creates FPOs; others see only their own; processors, inputs, villages and crops list.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    fpo = {"code": f"T{secrets.token_hex(4).upper()}", "name": "New FPO"}
    assert (await client.post("/v1/fpos", json=fpo)).status_code == 403
    assert [f["id"] for f in (await client.get("/v1/fpos")).json()] == [str(ids["fpo_a"])]
    _as(caller, ids, "super_admin", "fpo_a", Role.FPO_ADMIN)
    assert (await client.post("/v1/fpos", json=fpo)).status_code == 201
    assert len((await client.get("/v1/fpos")).json()) >= 3

    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    address = {"village": "Tiruchuli", "taluk": "Tiruchuli", "district": "Virudhunagar"}
    processor = await client.post("/v1/processors", json={"name": "Mill", "address": address})
    assert processor.status_code == 201 and processor.json()["address_line"] == "Tiruchuli, Virudhunagar"
    assert processor.json()["id"] in [p["id"] for p in (await client.get("/v1/processors")).json()]

    item = {"name_en": "Panjakavya", "category": "organic_fertilizer", "unit": "l"}
    assert (await client.post("/v1/inputs", json={**item, "global_entry": True})).status_code == 403
    created = await client.post("/v1/inputs", json=item)
    assert created.status_code == 201 and created.json()["fpo_id"] == str(ids["fpo_a"])
    _as(caller, ids, "admin_b", "fpo_b", Role.FPO_ADMIN)
    assert created.json()["id"] not in [i["id"] for i in (await client.get("/v1/inputs")).json()]

    district = f"D{secrets.token_hex(3)}"
    async with get_sessionmaker()() as s:
        for name in ("Alpha", "Beta", "Gamma"):
            s.add(Village(name_en=name, district=district, state="Tamil Nadu", taluk="Tiruchuli"))
        await s.commit()
    first = (await client.get("/v1/villages", params={"district": district, "limit": 2})).json()
    assert [v["name_en"] for v in first["items"]] == ["Alpha", "Beta"] and first["has_more"] is True
    rest = await client.get(
        "/v1/villages", params={"district": district, "limit": 2, "cursor": first["next_cursor"]}
    )
    assert [v["name_en"] for v in rest.json()["items"]] == ["Gamma"] and rest.json()["has_more"] is False
    assert (await client.get("/v1/villages", params={"cursor": "garbage"})).status_code == 422
    assert (await client.get("/v1/crops")).status_code == 200
