"""Integration tests of the lots_batches API on a real PostGIS database: lot lifecycle, intake, batch, gates.

Serves: B09 acceptance (ready at 11.5 → 409, at 10.9 → ready; intake 100 vs packed 69 → `quantity_mismatch`;
lots {100,200,20} → 31.250/62.500/6.250; ineligible lot + GI requested → `gi_verified=false` with reasons;
approve on `declared_above_computed` → 409; pack 25 on 20 graded → 409; publish before approval → 409
listing reasons; after gates → 202 + `page_builds` row), Dataflow Stages 4–9 and §4, D-033, D-005.
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`). Auth is replaced by
a dependency override; Celery's `send_task` is recorded (`task_always_eager` does not apply to tasks sent by
name).
"""

import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from agritrace.core import task_names
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import InstrumentKind, OrgKind, PinMethod, Role
from agritrace.core.ids import uuid7
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.quality.models import Instrument
from agritrace.modules.quality.profiles.loader import load_profile
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiTag, Plot, Processor

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (a no-op when another test module already did).

    Args:
        stack: the running containers (fixture).

    Raises:
        AssertionError: alembic failed (its output is in the message).

    Side effects:
        Creates every table and trigger up to the latest revision.
    """
    alembic = str(Path(sys.executable).parent / "alembic")
    result = subprocess.run(  # noqa: S603
        [alembic, "upgrade", "head"], cwd=API_DIR, capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stdout + result.stderr


@dataclass
class World:
    """Ids of one freshly seeded FPO, the caller the API sees and the Celery messages sent."""

    fpo: uuid.UUID
    admin: uuid.UUID
    admin2: uuid.UUID
    plot: uuid.UUID
    crop: uuid.UUID
    processor: uuid.UUID
    instrument: uuid.UUID
    caller: CurrentUser
    sent: list[tuple[str, dict[str, Any]]] = field(default_factory=list)
    clock: int = 0

    def act_as(self, user_id: uuid.UUID, role: Role = Role.FPO_ADMIN) -> None:
        """Switch the caller for the next requests.

        Args:
            user_id: the user to act as.
            role: their role in this FPO.

        Side effects:
            Replaces `caller`.
        """
        self.caller = CurrentUser(user_id=user_id, fpo_id=self.fpo, role=role)

    def tick(self) -> str:
        """Return the next measuring time, one minute after the previous one.

        Returns:
            An ISO 8601 timestamp with offset, so later readings are the latest.

        Side effects:
            Advances the clock.
        """
        self.clock += 1
        return f"2026-07-30T09:{self.clock:02d}:00+05:30"


async def _seed() -> dict[str, uuid.UUID]:
    """Insert an FPO with two admins, a farmer, a plot, a GI crop with its profile, a processor and a meter.

    Returns:
        Ids by name.

    Side effects:
        Commits the rows to the test database.
    """
    async with get_sessionmaker()() as s:
        admin = User(phone=f"+9195{secrets.randbelow(10**8):08d}", name="Admin")
        admin2 = User(phone=f"+9194{secrets.randbelow(10**8):08d}", name="Admin 2")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        gi = GiTag(gi_number=f"T{secrets.token_hex(4)}", name="Samba Vathal")
        s.add_all([admin, admin2, fpo, gi])
        await s.flush()
        crop = Crop(
            code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={}, gi_tag_id=gi.id
        )
        farmer = Farmer(fpo_id=fpo.id, code="F-001", name="Muthu")
        processor = Processor(fpo_id=fpo.id, name="Demo processor", kind=OrgKind.COMPANY)
        meter = Instrument(
            fpo_id=fpo.id,
            kind=InstrumentKind.MOISTURE_METER,
            make_model="Meter A",
            serial_no="A-1",
            calibrated_on=date(2026, 1, 1),
            calibration_due_on=date(2026, 12, 31),
        )
        s.add_all([crop, farmer, processor, meter])
        await s.flush()
        plot = Plot(
            id=uuid7(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            code="P-01",
            pin=WKTElement("POINT(77.96 9.58)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
            pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
            declared_area_acres=Decimal("1.5"),
        )
        s.add(plot)
        await s.commit()
        await load_profile(s, crop.id)
        return {
            "fpo": fpo.id,
            "admin": admin.id,
            "admin2": admin2.id,
            "plot": plot.id,
            "crop": crop.id,
            "processor": processor.id,
            "instrument": meter.id,
        }


@pytest.fixture
async def world(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO and an HTTP client whose caller is that FPO's admin.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: replaces the Celery app's `send_task` with a recorder.

    Returns:
        An async iterator yielding the seeded world and the client.

    Side effects:
        Seeds rows; overrides `get_current_user` on a new app instance.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    ids = await _seed()
    w = World(**ids, caller=CurrentUser(user_id=ids["admin"], fpo_id=ids["fpo"], role=Role.FPO_ADMIN))
    monkeypatch.setattr(
        celery_app, "send_task", lambda name, kwargs=None, **_: w.sent.append((name, kwargs or {}))
    )
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client


def _moisture(w: World, value: str, stage: str = "drying_end", **subject: str) -> dict[str, Any]:
    """Build an instrument moisture reading.

    Args:
        w: the seeded world.
        value: percent moisture.
        stage: capture stage.
        **subject: `lot_id=...` or `batch_id=...`.

    Returns:
        The request body.
    """
    return {
        "client_id": str(uuid7()),
        "stage": stage,
        "parameter_code": "moisture",
        "measurement": {"value": value, "unit": "%"},
        "source": "instrument",
        "instrument_id": str(w.instrument),
        "measured_at": w.tick(),
        **subject,
    }


async def _lot(w: World, client: AsyncClient) -> str:
    """Open a lot on the world's plot.

    Args:
        w: the seeded world.
        client: the API client.

    Returns:
        The lot id.
    """
    body = {
        "client_id": str(uuid7()),
        "plot_id": str(w.plot),
        "crop_id": str(w.crop),
        "season_label": "2025-26",
    }
    r = await client.post("/v1/lots", json=body)
    assert r.status_code == 201, r.text
    assert r.json()["code"].startswith("LOT")
    return str(r.json()["id"])


async def _ready_lot(w: World, client: AsyncClient) -> str:
    """Open a lot, record 10.0 % drying-end moisture and mark it ready.

    Args:
        w: the seeded world.
        client: the API client.

    Returns:
        The lot id.
    """
    lot = await _lot(w, client)
    assert (
        await client.post("/v1/quality-readings", json=_moisture(w, "10.0", lot_id=lot))
    ).status_code == 201
    r = await client.post(f"/v1/lots/{lot}/ready")
    assert r.status_code == 200, r.text
    return lot


async def _intake(w: World, client: AsyncClient, lot: str, kg: str) -> dict[str, Any]:
    """Receive a lot at the world's processor.

    Args:
        w: the seeded world.
        client: the API client.
        lot: the lot id.
        kg: received kilograms.

    Returns:
        The intake response body.
    """
    body = {
        "client_id": str(uuid7()),
        "lot_id": lot,
        "processor_id": str(w.processor),
        "sale_date": "2026-07-01",
        "received": {"value": kg, "unit": "kg"},
    }
    r = await client.post("/v1/intakes", json=body)
    assert r.status_code == 201, r.text
    return dict(r.json())


async def _batch(w: World, client: AsyncClient, *kgs: str, gi: bool = False) -> dict[str, Any]:
    """Make one received lot per quantity and merge them into a batch.

    Args:
        w: the seeded world.
        client: the API client.
        *kgs: intake kilograms per lot.
        gi: request the GI label.

    Returns:
        The batch response body.
    """
    lots = [await _ready_lot(w, client) for _ in kgs]
    for lot, kg in zip(lots, kgs, strict=True):
        await _intake(w, client, lot, kg)
    body = {"processor_id": str(w.processor), "gi_label_requested": gi, "lot_ids": lots}
    r = await client.post("/v1/batches", json=body)
    assert r.status_code == 201, r.text
    return dict(r.json())


def _codes(r: Any) -> list[str]:
    """Read the reason codes of a `gate_not_met` answer.

    Args:
        r: the HTTP response.

    Returns:
        Reason codes in order.
    """
    assert r.status_code == 409, r.text
    assert r.json()["error"]["code"] == "gate_not_met"
    return [x["code"] for x in r.json()["error"]["details"]["reasons"]]


async def _graded_batch(w: World, client: AsyncClient, declared: str, value: str) -> str:
    """Make a one-lot batch of 100 kg and grade it with one grading moisture reading.

    Args:
        w: the seeded world.
        client: the API client.
        declared: declared grade.
        value: grading moisture percent.

    Returns:
        The batch id.
    """
    batch = (await _batch(w, client, "100"))["id"]
    reading = _moisture(w, value, stage="grading", batch_id=batch)
    r = await client.post(
        f"/v1/batches/{batch}/grading", json={"declared_grade": declared, "readings": [reading]}
    )
    assert r.status_code == 201, r.text
    return str(batch)


async def test_ready_gate_on_moisture(world: tuple[World, AsyncClient]) -> None:
    """Drying-end 11.5 % → 409 `moisture_gate_failed`; a later 10.9 % → ready_for_sale.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _lot(w, client)
    assert (
        await client.post("/v1/quality-readings", json=_moisture(w, "11.5", lot_id=lot))
    ).status_code == 201
    assert _codes(await client.post(f"/v1/lots/{lot}/ready")) == ["moisture_gate_failed"]
    assert (
        await client.post("/v1/quality-readings", json=_moisture(w, "10.9", lot_id=lot))
    ).status_code == 201
    r = await client.post(f"/v1/lots/{lot}/ready")
    assert r.status_code == 200, r.text
    assert r.json()["status"] == "ready_for_sale" and r.json()["ready_at"] is not None


async def test_intake_above_packed_raises_quantity_mismatch(world: tuple[World, AsyncClient]) -> None:
    """Received 100 kg from a lot packed at 69 kg: chain out of order and a `quantity_mismatch` flag.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    async with get_sessionmaker()() as s:
        row = await s.get(Lot, uuid.UUID(lot))
        assert row is not None
        row.packed_kg = Decimal(69)
        await s.commit()
    out = await _intake(w, client, lot, "100")
    assert out["reconciliation"]["in_order"] is False
    assert "quantity_mismatch" in {f["rule_code"] for f in out["flags"]}
    assert (await client.get(f"/v1/lots/{lot}")).json()["status"] == "received"


async def test_reference_batch_shares(world: tuple[World, AsyncClient]) -> None:
    """Lots of 100, 200 and 20 kg → shares 31.250 / 62.500 / 6.250 %, total 320 kg.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    batch = await _batch(w, client, "100", "200", "20")
    assert sorted(Decimal(s["share_pct"]) for s in batch["shares"]) == [
        Decimal("6.250"),
        Decimal("31.250"),
        Decimal("62.500"),
    ]
    assert Decimal(batch["total_received"]["value"]) == Decimal(320)
    assert batch["total_received"]["unit"] == "kg"
    assert len(batch["code"]) == 12 and batch["superlot_code"].startswith("COMBO_LOT_")
    assert batch["second_signoff_required"] is False


async def test_ineligible_lot_blocks_gi(world: tuple[World, AsyncClient]) -> None:
    """A lot on hold in a GI-requested batch → batch created, `gi_verified=false` with `lot_on_hold`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    await _intake(w, client, lot, "50")
    async with get_sessionmaker()() as s:
        row = await s.get(Lot, uuid.UUID(lot))
        assert row is not None
        row.gi_eligible, row.gi_hold_reason = False, "flags: yield_over_ceiling"
        await s.commit()
    body = {"processor_id": str(w.processor), "gi_label_requested": True, "lot_ids": [lot]}
    r = await client.post("/v1/batches", json=body)
    assert r.status_code == 201, r.text
    assert r.json()["gi_verified"] is False
    reasons = {(x["lot_id"], x["reason"]) for x in r.json()["gi_block_reasons"]}
    assert (lot, "lot_on_hold") in reasons


async def test_approve_refused_on_declared_above_computed(world: tuple[World, AsyncClient]) -> None:
    """Declared Special with 10.5 % moisture (computed Standard) → approve 409 `declared_above_computed`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    batch = await _graded_batch(w, client, "Special", "10.5")
    r = await client.post(
        f"/v1/batches/{batch}/grading/approve", json={"graded": {"value": 90, "unit": "kg"}}
    )
    assert _codes(r) == ["declared_above_computed"]


async def test_packing_capped_by_graded_then_publish(world: tuple[World, AsyncClient]) -> None:
    """Publish before approval → 409 listing reasons; pack 25 on 20 graded → 409; after gates → 202 + build.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    batch = await _graded_batch(w, client, "Standard", "10.5")
    assert _codes(await client.post(f"/v1/batches/{batch}/publish")) == [
        "grading_not_approved",
        "final_packing_missing",
    ]
    r = await client.post(
        f"/v1/batches/{batch}/grading/approve", json={"graded": {"value": 20, "unit": "kg"}}
    )
    assert r.status_code == 200, r.text
    assert r.json()["status"] == "graded" and r.json()["computed_grade"] == "Standard"
    packing = {
        "packed": {"value": 25, "unit": "kg"},
        "pack_date": "2026-08-01",
        "best_before_date": "2027-07-31",
    }
    assert _codes(await client.post(f"/v1/batches/{batch}/final-packing", json=packing)) == [
        "packed_above_graded"
    ]
    packing["packed"] = {"value": 20, "unit": "kg"}
    r = await client.post(f"/v1/batches/{batch}/final-packing", json=packing)
    assert r.status_code == 200, r.text

    r = await client.post(f"/v1/batches/{batch}/publish")
    assert r.status_code == 202, r.text
    assert r.json()["build_no"] == 1 and r.json()["status"] == "queued"
    async with get_sessionmaker()() as s:
        builds = (await s.scalars(select(PageBuild).where(PageBuild.batch_id == uuid.UUID(batch)))).all()
    assert [(b.build_no, b.trigger, b.status) for b in builds] == [(1, "publish", "queued")]
    assert w.sent[-1][0] == task_names.PUBLISHING_BUILD_PAGE
    assert w.sent[-1][1]["page_build_id"] == str(builds[0].id)
    assert _codes(await client.post(f"/v1/batches/{batch}/publish")) == ["already_published"]


async def test_large_batch_needs_a_second_admin(world: tuple[World, AsyncClient]) -> None:
    """1,500 kg is above the default 1,000 kg threshold: the creator cannot sign twice; another admin can.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    batch = await _batch(w, client, "1500")
    assert batch["second_signoff_required"] is True
    assert "second_signoff_missing" in _codes(await client.post(f"/v1/batches/{batch['id']}/publish"))
    assert _codes(await client.post(f"/v1/batches/{batch['id']}/second-signoff")) == ["same_approver"]
    w.act_as(w.admin2)
    r = await client.post(f"/v1/batches/{batch['id']}/second-signoff")
    assert r.status_code == 200, r.text
    assert r.json()["second_signoff_by"] == str(w.admin2)
