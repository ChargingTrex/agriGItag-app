"""Integration tests of reference bundles and sync pull on PostGIS + LocalStack.

Serves: B07 acceptance (matching `If-None-Match` → 304; `standards` carries the full profile rules; pull
after a new flag returns exactly that flag; simplified GI outline ≤ 50 KB for the fixture), the 24 h
`photo_pending` rule, `sync_cursors` per device, presigned variant URLs (B06 review P3), per-part `since`
(TODO F1). backend-design.md §3, PLAN §13 C2/C3, D-006, D-016.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack`). The caller is injected by a
dependency override. Seeded rows are backdated, because pull serves only rows older than
`pull_service.PULL_SETTLE`.
"""

import asyncio
import hashlib
import json
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from io import BytesIO
from pathlib import Path
from typing import Any

import httpx
import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient
from PIL import Image

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import FlagSubject, OrgKind, PinMethod, Role, Severity
from agritrace.core.ids import lot_code, uuid7
from agritrace.modules.events.models import EvidencePhoto, SyncCursor
from agritrace.modules.events.schemas import BundlePart
from agritrace.modules.identity.models import Device, User
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.quality.profiles.loader import load_profile
from agritrace.modules.registry import geo
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiRegionVersion, GiTag, Plot
from agritrace.modules.rules_flags.models import Flag

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
REGION_FIXTURE = API_DIR / "agritrace" / "seed" / "fixtures" / "gi_region_fixture.geojson"
LAT, LON = 9.5598, 78.1335
LONG_AGO = datetime.now(UTC) - timedelta(minutes=10)


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (a no-op when another module already did).

    Args:
        stack: the running containers (fixture).

    Raises:
        AssertionError: alembic failed.
    """
    alembic = str(Path(sys.executable).parent / "alembic")
    result = subprocess.run(  # noqa: S603
        [alembic, "upgrade", "head"], cwd=API_DIR, capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stdout + result.stderr


@dataclass
class World:
    """One seeded FPO: a farmer and a neighbour, each with plot and lot, the farmer's device, a GI crop."""

    fpo: uuid.UUID
    farmer_user: uuid.UUID
    device: uuid.UUID
    crop: uuid.UUID
    lot: uuid.UUID
    plot: uuid.UUID
    neighbour_lot: uuid.UUID
    caller: CurrentUser


async def _seed() -> dict[str, uuid.UUID]:
    """Insert the world, backdated 10 minutes; the crop has a GI tag with the fixture region and a profile.

    Returns:
        Ids by name.

    Side effects:
        Commits rows (fresh codes and phones, so reruns do not clash).
    """
    async with get_sessionmaker()() as s:
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Bundle FPO", kind=OrgKind.FPO)
        tag = GiTag(gi_number=f"B{secrets.token_hex(3)}", name="Test GI")
        s.add_all([fpo, tag])
        await s.flush()
        crop = Crop(
            code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", gi_tag_id=tag.id, event_schema={}
        )
        outline = geo.parse_multipolygon(json.loads(REGION_FIXTURE.read_text())["features"][0]["geometry"])
        region = GiRegionVersion(
            gi_tag_id=tag.id,
            version_no=0,
            geom=WKTElement(outline.wkt, srid=4326),
            tolerance_buffer_m=Decimal(100),
            source_ref="fixture",
            licence="CC0-1.0",
            confidence="fixture",
            effective_from=date(2026, 1, 1),
        )
        s.add_all([crop, region])
        await s.flush()
        ids = {"fpo": fpo.id, "crop": crop.id}
        for prefix in ("", "neighbour_"):
            user = User(phone=f"+9196{secrets.randbelow(10**8):08d}", name=prefix or "farmer")
            s.add(user)
            await s.flush()
            farmer = Farmer(fpo_id=fpo.id, code=f"F-{prefix or 'own'}", name="F", user_id=user.id)
            s.add(farmer)
            await s.flush()
            plot = Plot(
                id=uuid7(),
                fpo_id=fpo.id,
                farmer_id=farmer.id,
                code="P-01",
                pin=WKTElement(f"POINT({LON} {LAT})", srid=4326),
                pin_method=PinMethod.LIVE_GPS,
                pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
                pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
                declared_area_acres=Decimal("1.5"),
            )
            s.add(plot)
            await s.flush()
            lot = Lot(
                fpo_id=fpo.id,
                farmer_id=farmer.id,
                plot_id=plot.id,
                crop_id=crop.id,
                season_label="2025-26",
                code=lot_code(),
                created_at=LONG_AGO,
                updated_at=LONG_AGO,
            )
            s.add(lot)
            await s.flush()
            ids[f"{prefix}lot"] = lot.id
            if not prefix:
                device = Device(user_id=user.id, platform="android")
                s.add(device)
                await s.flush()
                ids |= {"farmer_user": user.id, "plot": plot.id, "device": device.id}
        await s.commit()
        await load_profile(s, crop.id)
        return ids


@pytest.fixture
async def world(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO; the caller is its farmer on their device.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: silences Celery's `send_task` (tasks are run by hand where needed).

    Returns:
        An async iterator yielding the world and an HTTP client.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    monkeypatch.setattr(celery_app, "send_task", lambda *_, **__: None)

    ids = await _seed()
    caller = CurrentUser(
        user_id=ids["farmer_user"], fpo_id=ids["fpo"], role=Role.FARMER, device_id=ids["device"]
    )
    w = World(caller=caller, **ids)
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client


async def test_matching_if_none_match_is_304(world: tuple[World, AsyncClient]) -> None:
    """Every listed part downloads with the manifest's ETag; sending it back answers 304 without a body.

    Args:
        world: seeded FPO and client (fixture).
    """
    _, client = world
    manifest = (await client.get("/v1/sync/bundle")).json()["parts"]
    assert set(manifest) == {p.value for p in BundlePart}
    for part, entry in manifest.items():
        first = await client.get(f"/v1/sync/bundle/{part}")
        assert first.status_code == 200 and first.headers["etag"] == entry["etag"], part
        again = await client.get(f"/v1/sync/bundle/{part}", headers={"If-None-Match": entry["etag"]})
        assert again.status_code == 304 and again.content == b"", part
    stale = await client.get("/v1/sync/bundle/crops", headers={"If-None-Match": '"stale"'})
    assert stale.status_code == 200
    assert (await client.get("/v1/sync/bundle/nonsense")).status_code == 422


async def test_standards_part_carries_full_rules(world: tuple[World, AsyncClient]) -> None:
    """`standards.profiles[crop_id]` is the published version's whole rules JSON (D-006, M03 contract).

    Args:
        world: seeded FPO and client (fixture).
    """
    from sqlalchemy import select

    from agritrace.modules.quality.models import StandardsProfile, StandardsProfileVersion

    w, client = world
    body = (await client.get("/v1/sync/bundle/standards")).json()
    async with get_sessionmaker()() as s:
        rules = await s.scalar(
            select(StandardsProfileVersion.rules)
            .join(StandardsProfile, StandardsProfile.id == StandardsProfileVersion.profile_id)
            .where(StandardsProfile.crop_id == w.crop)
        )
    assert body["profiles"][str(w.crop)] == rules
    assert {"grades", "fail_grade", "parameters", "lot_gates", "trail_rules"} <= set(rules)


async def test_gi_region_is_simplified_under_50_kb(world: tuple[World, AsyncClient]) -> None:
    """The fixture outline arrives as GeoJSON ≤ 50 KB with its buffer and provenance (PLAN §13 C3).

    Args:
        world: seeded FPO and client (fixture).
    """
    _, client = world
    response = await client.get("/v1/sync/bundle/gi_region")
    assert response.status_code == 200 and len(response.content) <= 50 * 1024
    body = response.json()
    assert body["geometry"]["type"] in ("Polygon", "MultiPolygon")
    assert body["tolerance_buffer_m"] > 0 and body["licence"] and body["source_ref"]


async def test_reference_returns_changed_parts_then_304(world: tuple[World, AsyncClient]) -> None:
    """Holding every current version → 304; after a new plot, only `plots` comes back (per-part `since`).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    manifest = (await client.get("/v1/sync/bundle")).json()["parts"]
    since = ",".join(f"{p}:{v['version']}" for p, v in manifest.items())
    assert (await client.get("/v1/sync/reference", params={"since": since})).status_code == 304
    async with get_sessionmaker()() as s:
        farmer_id = (await s.get(Plot, w.plot)).farmer_id  # type: ignore[union-attr]
        s.add(
            Plot(
                id=uuid7(),
                fpo_id=w.fpo,
                farmer_id=farmer_id,
                code="P-02",
                pin=WKTElement(f"POINT({LON} {LAT})", srid=4326),
                pin_method=PinMethod.LIVE_GPS,
                pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
                pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
                declared_area_acres=Decimal("2"),
            )
        )
        await s.commit()
    changed = (await client.get("/v1/sync/reference", params={"since": since})).json()["parts"]
    assert list(changed) == ["plots"]
    assert [p["code"] for p in changed["plots"]["body"]["plots"]] == ["P-01", "P-02"]
    assert (await client.get("/v1/sync/reference", params={"since": "plots"})).status_code == 422


async def _drain(client: AsyncClient, cursor: str | None = None) -> tuple[list[dict[str, Any]], str | None]:
    """Pull every page.

    Args:
        client: the HTTP client.
        cursor: where to start.

    Returns:
        (all changes, the last `next_cursor`).
    """
    changes: list[dict[str, Any]] = []
    while True:
        params = {"cursor": cursor} if cursor else {}
        page = (await client.get("/v1/sync/pull", params=params)).json()
        changes += page["changes"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            return changes, cursor


async def test_pull_after_new_flag_returns_exactly_that_flag(world: tuple[World, AsyncClient]) -> None:
    """After draining, a new flag on the farmer's lot is the only change; the neighbour's flag stays hidden.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    first, cursor = await _drain(client)
    assert [(c["entity"], c["data"]["id"]) for c in first] == [("lot", str(w.lot))]
    raised = datetime.now(UTC) - timedelta(minutes=5)  # newer than the lot, older than PULL_SETTLE
    async with get_sessionmaker()() as s:
        flags = [
            Flag(
                fpo_id=w.fpo,
                subject_type=FlagSubject.LOT,
                subject_id=lot,
                rule_code="quantity_mismatch",
                severity=Severity.WARN,
                dedupe_key=f"quantity_mismatch:{lot}:{secrets.token_hex(4)}",
                raised_at=raised,
                created_at=raised,
                updated_at=raised,
            )
            for lot in (w.lot, w.neighbour_lot)
        ]
        s.add_all(flags)
        await s.commit()
    second, _ = await _drain(client, cursor)
    assert [(c["entity"], c["op"], c["data"]["id"]) for c in second] == [("flag", "upsert", str(flags[0].id))]
    async with get_sessionmaker()() as s:
        stored = await s.get(SyncCursor, w.device)
    assert stored is not None and stored.last_pull_cursor is not None


def _jpeg() -> bytes:
    """Make a small JPEG.

    Returns:
        JPEG bytes.
    """
    buf = BytesIO()
    Image.new("RGB", (640, 480), "darkred").save(buf, "JPEG")
    return buf.getvalue()


async def test_photo_pending_after_24_hours_and_presigned_variants(world: tuple[World, AsyncClient]) -> None:
    """A photo still `pending_upload` 25 h after its entry is listed as `photo_pending`; a fresh one is not.

    Also: after upload and variants, the timeline's `thumb_url` is a presigned GET that LocalStack serves.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    body = _jpeg()
    fresh, old = uuid7(), uuid7()
    photo = {
        "sha256": hashlib.sha256(body).hexdigest(),
        "size_bytes": len(body),
        "content_type": "image/jpeg",
    }
    entry = {
        "client_id": str(uuid7()),
        "kind": "event_version",
        "data": {
            "event_id": str(uuid7()),
            "version_no": 1,
            "subject_type": "lot",
            "lot_id": str(w.lot),
            "event_type": "harvest",
            "instance_no": 1,
            "occurred_on": "2026-03-04",
            "payload": {"quantity": {"value": 195, "unit": "kg"}, "bags": 13},
            "clocks": {"device_time": datetime.now(UTC).isoformat()},
            "photos": [{"client_id": str(fresh), **photo}],
        },
    }
    envelope = {"device_id": str(w.device), "app_version": "1", "device_time": datetime.now(UTC).isoformat()}
    result = (await client.post("/v1/sync/push", json=envelope | {"entries": [entry]})).json()["results"][0]
    assert result["status"] == "accepted"
    async with get_sessionmaker()() as s:
        template = await s.get(EvidencePhoto, fresh)
        assert template is not None
        s.add(
            EvidencePhoto(
                id=old,
                event_version_id=template.event_version_id,
                bucket=template.bucket,
                object_key=template.object_key.replace(str(fresh), str(old)),
                content_type="image/jpeg",
                size_bytes=len(body),
                sha256_client=photo["sha256"],
                created_at=datetime.now(UTC) - timedelta(hours=25),
            )
        )
        await s.commit()
    changes, _ = await _drain(client)
    pending = [c["data"]["id"] for c in changes if c["entity"] == "photo_pending"]
    assert pending == [str(old)]

    upload = result["photo_uploads"][0]
    assert httpx.put(upload["url"], content=body, headers=upload["headers"]).status_code == 200
    await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(fresh)}]})
    from agritrace.modules.events import tasks  # lazy: the worker module reads settings on import

    assert await asyncio.to_thread(tasks.verify_photo, str(fresh)) in ("verified", "exif_mismatch")
    assert await asyncio.to_thread(tasks.make_variants, str(fresh)) is not None
    timeline = (await client.get(f"/v1/lots/{w.lot}/events")).json()["items"]
    variants = next(p["variants"] for e in timeline for p in e["photos"] if p["id"] == str(fresh))
    assert "X-Amz-Signature" in variants["thumb_url"]
    assert httpx.get(variants["thumb_url"]).status_code == 200
