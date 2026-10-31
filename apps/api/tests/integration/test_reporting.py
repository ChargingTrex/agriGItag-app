"""Integration tests of the reporting API on PostGIS + Valkey: dashboard, farmer table, audit, scans, stubs.

Serves: B11 acceptance (completeness = lots with all mandatory events ÷ lots; 100 scans/min → 429; CSV row
per version with `entered_by`, `assist_session_id`; partner → 501) and one test per dashboard section
(stage tiles, flags + batches, land area, finished goods + scans, sync health, farmer table, audit log),
FR13, FR20, FR21, FR58, D-037, D-038, D-039.
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`). Auth is replaced by
a dependency override; rows are seeded with the ORM; `migrated` comes from tests/integration/conftest.py.
"""

import csv
import io
import secrets
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal

import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import (
    BatchStatus,
    ChangeKind,
    EventStatus,
    EventSubject,
    EventType,
    FlagStatus,
    FlagSubject,
    LocationStatus,
    LotStatus,
    OrgKind,
    PinMethod,
    Role,
    Severity,
)
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion, SyncMetric
from agritrace.modules.identity.models import AssistSession, Device, Membership, User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot
from agritrace.modules.registry.models import Crop, Farmer, Fpo, Plot, Processor, Village
from agritrace.modules.reporting import service
from agritrace.modules.reporting.models import ScanEvent
from agritrace.modules.rules_flags.models import Flag

pytestmark = pytest.mark.integration

NOW = datetime.now(UTC)


@dataclass
class World:
    """Ids of one seeded FPO (plus a second FPO for isolation checks) and the caller the API sees."""

    fpo: uuid.UUID
    other_fpo: uuid.UUID
    admin: uuid.UUID
    village_a: uuid.UUID
    village_b: uuid.UUID
    farmer_a: uuid.UUID
    lot_complete: uuid.UUID
    lot_other: uuid.UUID
    batch: uuid.UUID
    batch_code: str
    assist: uuid.UUID
    caller: CurrentUser


async def _seed() -> dict[str, uuid.UUID | str]:
    """Insert two FPOs; FPO A gets 2 villages, 2 farmers, 2 plots, 3 lots, events, 2 batches, flags, scans.

    Lot 1 (open) has land preparation, sowing and harvest, plus a corrected harvest (version 2, assist
    session); lot 2 (ready for sale) has land preparation and sowing and an undone harvest; lot 3 (drying)
    has nothing. The crop's mandatory types are land preparation, sowing and harvest, so 1 of 3 lots is
    complete. FPO B has one complete lot that must never show up in A's numbers.

    Returns:
        Ids by name.

    Side effects:
        Commits the rows to the test database.
    """
    async with get_sessionmaker()() as s:
        admin = User(phone=f"+9193{secrets.randbelow(10**8):08d}", name="Admin")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="A", kind=OrgKind.FPO)
        other = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="B", kind=OrgKind.FPO)
        tag = secrets.token_hex(3)
        va = Village(name_en=f"Alpha {tag}", block=f"B1-{tag}", district="Virudhunagar", state="Tamil Nadu")
        vb = Village(name_en=f"Beta {tag}", block=f"B2-{tag}", district="Virudhunagar", state="Tamil Nadu")
        s.add_all([admin, fpo, other, va, vb])
        await s.flush()
        crop = Crop(
            code=f"CHILLI_{secrets.token_hex(4)}",
            name_en="Samba Vathal",
            event_schema={"mandatory": ["land_preparation", "sowing", "harvest"]},
        )
        device = Device(id=uuid7(), user_id=admin.id, platform="android")
        fa = Farmer(fpo_id=fpo.id, code="F-001", name="Muthu", village_id=va.id)
        fb = Farmer(fpo_id=fpo.id, code="F-002", name="Lakshmi", village_id=vb.id)
        fx = Farmer(fpo_id=other.id, code="F-900", name="Other")
        proc = Processor(fpo_id=fpo.id, name="Processor", kind=OrgKind.COMPANY)
        s.add_all(
            [crop, device, fa, fb, fx, proc, Membership(user_id=admin.id, fpo_id=fpo.id, role=Role.FPO_ADMIN)]
        )
        await s.flush()

        def plot(farmer: Farmer, declared: str, walked: str | None, where: LocationStatus) -> Plot:
            """Build a plot (pin in Virudhunagar)."""
            return Plot(
                id=uuid7(),
                fpo_id=farmer.fpo_id,
                farmer_id=farmer.id,
                code="P-01",
                pin=WKTElement("POINT(77.96 9.58)", srid=4326),
                pin_method=PinMethod.LIVE_GPS,
                pin_device_time=NOW,
                pin_server_received_at=NOW,
                declared_area_acres=Decimal(declared),
                walked_area_acres=Decimal(walked) if walked else None,
                location_status=where,
            )

        pa, pb, px = (
            plot(fa, "1.5", "1.2", LocationStatus.CONFIRMED),
            plot(fb, "2", None, LocationStatus.OUTSIDE),
            plot(fx, "9", None, LocationStatus.CONFIRMED),
        )
        s.add_all([pa, pb, px])
        await s.flush()

        def lot(farmer: Farmer, p: Plot, status: LotStatus) -> Lot:
            """Build a lot of the crop."""
            code = f"LOT{secrets.token_hex(4).upper()}"
            return Lot(
                fpo_id=farmer.fpo_id,
                farmer_id=farmer.id,
                plot_id=p.id,
                crop_id=crop.id,
                season_label="S",
                code=code,
                status=status,
            )

        l1, l2, l3, lx = (
            lot(fa, pa, LotStatus.OPEN),
            lot(fa, pa, LotStatus.READY_FOR_SALE),
            lot(fb, pb, LotStatus.DRYING),
            lot(fx, px, LotStatus.OPEN),
        )
        s.add_all([l1, l2, l3, lx])
        await s.flush()

        def event(target: Lot, kind: EventType, status: EventStatus = EventStatus.SUBMITTED) -> Event:
            """Build a lot event dated 1 March."""
            return Event(
                id=uuid7(),
                fpo_id=target.fpo_id,
                subject_type=EventSubject.LOT,
                lot_id=target.id,
                event_type=kind,
                status=status,
                occurred_on=date(2026, 3, 1),
            )

        harvest = event(l1, EventType.HARVEST)
        events = [
            event(l1, EventType.LAND_PREPARATION),
            event(l1, EventType.SOWING),
            harvest,
            event(l2, EventType.LAND_PREPARATION),
            event(l2, EventType.SOWING),
            event(l2, EventType.HARVEST, EventStatus.UNDONE),
            event(lx, EventType.LAND_PREPARATION),
            event(lx, EventType.SOWING),
            event(lx, EventType.HARVEST),
        ]
        assist = AssistSession(id=uuid7(), officer_user_id=admin.id, farmer_id=fa.id, started_at=NOW)
        s.add_all([*events, assist])
        await s.flush()
        for e in events[:3]:
            s.add(
                EventVersion(
                    id=uuid7(),
                    event_id=e.id,
                    version_no=1,
                    payload={"quantity": {"value": "100", "unit": "kg"}},
                    occurred_on=date(2026, 3, 1),
                    device_time=NOW,
                    server_received_at=NOW,
                    entered_by_user_id=admin.id,
                    change_kind=ChangeKind.CREATE,
                )
            )
        await s.flush()
        s.add(
            EventVersion(
                id=uuid7(),
                event_id=harvest.id,
                version_no=2,
                payload={"quantity": {"value": "95", "unit": "kg"}},
                occurred_on=date(2026, 3, 1),
                device_time=NOW,
                server_received_at=NOW,
                entered_by_user_id=admin.id,
                on_behalf_of_farmer_id=fa.id,
                assist_session_id=assist.id,
                change_kind=ChangeKind.CORRECT,
                reason_code="wrong_weight",
            )
        )
        batch_code = secrets.token_hex(6).upper()
        packed = Batch(
            fpo_id=fpo.id,
            crop_id=crop.id,
            processor_id=proc.id,
            code=batch_code,
            status=BatchStatus.PACKED,
            packed_kg=Decimal("20"),
            pack_date=date(2026, 4, 1),
            created_by=admin.id,
        )
        created = Batch(
            fpo_id=fpo.id,
            crop_id=crop.id,
            processor_id=proc.id,
            code=secrets.token_hex(6).upper(),
            created_by=admin.id,
        )
        s.add_all([packed, created])
        await s.flush()
        s.add(
            BatchShare(
                batch_id=packed.id,
                lot_id=l1.id,
                kg_contributed=Decimal("20"),
                share_pct=Decimal("100"),
                farmer_id=fa.id,
            )
        )
        s.add_all(
            [
                Flag(
                    fpo_id=fpo.id,
                    subject_type=FlagSubject.LOT,
                    subject_id=l1.id,
                    rule_code="r1",
                    severity=Severity.HOLD,
                    dedupe_key=uuid.uuid4().hex,
                    raised_at=NOW,
                ),
                Flag(
                    fpo_id=fpo.id,
                    subject_type=FlagSubject.LOT,
                    subject_id=l1.id,
                    rule_code="r2",
                    severity=Severity.WARN,
                    dedupe_key=uuid.uuid4().hex,
                    raised_at=NOW,
                    status=FlagStatus.CLEARED,
                ),
                Flag(
                    fpo_id=other.id,
                    subject_type=FlagSubject.LOT,
                    subject_id=lx.id,
                    rule_code="r3",
                    severity=Severity.WARN,
                    dedupe_key=uuid.uuid4().hex,
                    raised_at=NOW,
                ),
                ScanEvent(batch_code=batch_code, scanned_at=NOW),
                ScanEvent(batch_code=batch_code, scanned_at=NOW - timedelta(days=30)),
                SyncMetric(
                    device_id=device.id,
                    entry_client_id=uuid7(),
                    saved_at=NOW - timedelta(seconds=10),
                    acked_at=NOW,
                    photo_upload_ms=3000,
                    failures=1,
                    network_type="2g",
                ),
                SyncMetric(
                    device_id=device.id,
                    entry_client_id=uuid7(),
                    saved_at=NOW - timedelta(seconds=2),
                    acked_at=NOW,
                    failures=0,
                    network_type="2g",
                ),
                SyncMetric(
                    device_id=device.id,
                    entry_client_id=uuid7(),
                    saved_at=NOW - timedelta(days=9),
                    acked_at=NOW,
                    failures=5,
                    network_type="lte",
                ),
            ]
        )
        await s.commit()
        return {
            "fpo": fpo.id,
            "other_fpo": other.id,
            "admin": admin.id,
            "village_a": va.id,
            "village_b": vb.id,
            "farmer_a": fa.id,
            "lot_complete": l1.id,
            "lot_other": lx.id,
            "batch": packed.id,
            "batch_code": batch_code,
            "assist": assist.id,
        }


@pytest.fixture
async def world(migrated: None) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO and an HTTP client whose caller is that FPO's admin.

    Args:
        migrated: the migrated database (fixture).

    Returns:
        An async iterator yielding the seeded world and the client.

    Side effects:
        Seeds rows; overrides `get_current_user` on a new app instance.
    """
    from agritrace.main import create_app

    ids = await _seed()
    caller = CurrentUser(user_id=ids["admin"], fpo_id=ids["fpo"], role=Role.FPO_ADMIN)  # type: ignore[arg-type]
    w = World(**ids, caller=caller)  # type: ignore[arg-type]
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client


async def _dashboard(w: World, client: AsyncClient, **params: str) -> dict:
    """Fetch the dashboard of the world's FPO.

    Args:
        w: the seeded world.
        client: the API client.
        **params: filters.

    Returns:
        The JSON body.
    """
    r = await client.get(f"/v1/dashboard/fpo/{w.fpo}", params=params)
    assert r.status_code == 200, r.text
    return r.json()


async def test_completeness_is_lots_with_all_mandatory_events_over_lots(
    world: tuple[World, AsyncClient],
) -> None:
    """Acceptance: 1 of 3 lots has every mandatory live event (an undone harvest does not count) → 33.3 %."""
    w, client = world
    body = await _dashboard(w, client)
    assert body["completeness"] == {"lots": 3, "complete_lots": 1, "complete": {"value": "33.3", "unit": "%"}}
    village_b = await _dashboard(w, client, village_id=str(w.village_b))
    assert village_b["completeness"]["lots"] == 1 and village_b["completeness"]["complete_lots"] == 0


async def test_stage_tiles(world: tuple[World, AsyncClient]) -> None:
    """Lot 1 is harvesting (in progress), lot 2 passed the ready gate (sowing done), lot 3 has not started."""
    w, client = world
    tiles = {t["stage"]: t for t in (await _dashboard(w, client))["stages"]}
    assert [t for t in tiles] == [s.value for s in service.STAGES]
    assert tiles["harvest"] == {"stage": "harvest", "done": 0, "in_progress": 1, "not_started": 2}
    assert tiles["sowing"] == {"stage": "sowing", "done": 2, "in_progress": 0, "not_started": 1}
    assert tiles["nursery"]["not_started"] == 3


async def test_flags_and_batches(world: tuple[World, AsyncClient]) -> None:
    """Only active flags of this FPO count; every batch status is present."""
    w, client = world
    body = await _dashboard(w, client)
    assert body["flags"] == {"info": 0, "warn": 0, "hold": 1}
    assert body["batches"] == {"created": 1, "graded": 0, "packed": 1, "published": 0}


async def test_land_area(world: tuple[World, AsyncClient]) -> None:
    """3.5 acres declared, 1.2 walked vs 1.5 declared, 1.5 GI-confirmed (42.9 %); FPO B's 9 acres excluded."""
    w, client = world
    area = (await _dashboard(w, client))["land_area"]
    assert area["total"]["declared_area"] == {"value": "3.500", "unit": "acre"}
    assert area["total"]["walked_area"]["value"] == "1.200"
    assert area["total"]["walked_declared_area"]["value"] == "1.500"
    assert area["total"]["gi_confirmed_share"] == {"value": "42.9", "unit": "%"}
    assert [v["plots"] for v in area["by_village"]] == [1, 1] and len(area["by_block"]) == 2
    assert "pin" not in str(area) and "boundary" not in str(area)


async def test_finished_goods_and_scans(world: tuple[World, AsyncClient]) -> None:
    """The packed batch lists 20 kg packed and remaining and its 2 scans; 1 scan in the last 7 days."""
    w, client = world
    body = await _dashboard(w, client)
    goods = body["finished_goods"]
    assert goods["batches"] == 1 and goods["packed"] == {"value": "20.000", "unit": "kg"}
    assert goods["items"][0]["code"] == w.batch_code
    assert goods["items"][0]["remaining"] == {"value": "20.000", "unit": "kg"}
    assert goods["items"][0]["scans"] == 2
    assert body["scans"] == {"total": 2, "last_7_days": 1}


async def test_sync_health(world: tuple[World, AsyncClient]) -> None:
    """Two 2G entries this week (2 s and 10 s to ack, one failed attempt); the 9-day-old LTE row is out."""
    w, client = world
    rows = (await _dashboard(w, client))["sync_health"]
    assert len(rows) == 1 and rows[0]["network_type"] == "2g" and rows[0]["entries"] == 2
    assert rows[0]["save_to_ack_p50"] == {"value": "6000", "unit": "ms"}
    assert rows[0]["failure_rate"] == {"value": "33.3", "unit": "%"}


async def test_farmer_table_pages_and_fields(world: tuple[World, AsyncClient]) -> None:
    """Two farmers over two pages; `?fields=` trims items; an unknown field → 422; another FPO → 404."""
    w, client = world
    url = f"/v1/dashboard/fpo/{w.fpo}/farmers"
    first = (await client.get(url, params={"limit": 1})).json()
    assert first["has_more"] and first["items"][0]["code"] == "F-001"
    assert first["items"][0]["lots"] == 2 and first["items"][0]["lots_complete"] == 1
    assert first["items"][0]["declared_area"] == {"value": "1.500", "unit": "acre"}
    second = (await client.get(url, params={"cursor": first["next_cursor"]})).json()
    assert not second["has_more"] and second["items"][0]["code"] == "F-002"
    lean = (await client.get(url, params={"fields": "code,lots"})).json()
    assert lean["items"][0] == {"code": "F-001", "lots": 2}
    assert (await client.get(url, params={"fields": "phone"})).status_code == 422
    assert (await client.get(f"/v1/dashboard/fpo/{w.other_fpo}/farmers")).status_code == 404


async def test_audit_log_search_is_fpo_scoped(world: tuple[World, AsyncClient]) -> None:
    """The lot's create row is found by entity; FPO B's lot rows never appear; user rows are not listed."""
    w, client = world
    rows = (await client.get("/v1/audit-log", params={"entity_id": str(w.lot_complete)})).json()["items"]
    assert [r["action"] for r in rows] == ["create"] and rows[0]["entity_type"] == "lots"
    assert "device_id" not in rows[0] and "gps" not in rows[0]
    assert (await client.get("/v1/audit-log", params={"entity_id": str(w.lot_other)})).json()["items"] == []
    by_type = (await client.get("/v1/audit-log", params={"entity_type": "users", "limit": 200})).json()
    assert by_type["items"] == []


async def test_csv_row_per_version_with_entered_by_and_assist_session(
    world: tuple[World, AsyncClient],
) -> None:
    """Acceptance: one CSV row per event version, with `entered_by` and `assist_session_id`."""
    w, client = world
    r = await client.get(f"/v1/batches/{w.batch}/audit-export.csv")
    assert r.status_code == 200 and r.headers["content-type"].startswith("text/csv")
    rows = list(csv.DictReader(io.StringIO(r.text)))
    assert len(rows) == 4  # land preparation, sowing, harvest v1 and its correction v2
    assert all(row["entered_by"] == str(w.admin) and row["unit"] == "kg" for row in rows)
    correction = next(row for row in rows if row["version_no"] == "2")
    assert correction["assist_session_id"] == str(w.assist) and correction["quantity"] == "95"
    assert correction["change_kind"] == "correct" and correction["reason_code"] == "wrong_weight"
    w.caller = CurrentUser(user_id=w.admin, fpo_id=w.other_fpo, role=Role.FPO_ADMIN)
    assert (await client.get(f"/v1/batches/{w.batch}/audit-export.csv")).status_code == 404


async def test_100_scans_per_minute_then_429(
    world: tuple[World, AsyncClient], monkeypatch: pytest.MonkeyPatch
) -> None:
    """Acceptance: 100 scans in one minute from one address → 204; the 101st → 429 `rate_limited`."""
    w, client = world
    frozen = datetime(2030, 1, 1, tzinfo=UTC) + timedelta(minutes=secrets.randbelow(10**6))  # fresh window
    monkeypatch.setattr(service, "utcnow", lambda: frozen)
    for _ in range(100):
        assert (await client.post("/v1/public/scans", params={"batch_code": w.batch_code})).status_code == 204
    over = await client.post("/v1/public/scans", params={"batch_code": w.batch_code})
    assert over.status_code == 429 and over.json()["error"]["code"] == "rate_limited"
    monkeypatch.setattr(service, "utcnow", lambda: NOW)
    assert (await _dashboard(w, client))["scans"]["total"] == 102


async def test_partner_returns_501(world: tuple[World, AsyncClient]) -> None:
    """Acceptance: the partner and storage-monitoring stubs answer 501 `not_implemented_pilot`."""
    _, client = world
    stubs = (("GET", "/v1/partner/batches/X"), ("POST", "/v1/partner/benefits"), ("POST", "/v1/probes"))
    for method, path in stubs:
        r = await client.request(method, path)
        assert r.status_code == 501 and r.json()["error"]["code"] == "not_implemented_pilot"
