"""Integration tests of the lots_batches API on a real PostGIS database: lot lifecycle, intake, batch, gates.

Serves: B09 acceptance (ready at 11.5 → 409, at 10.9 → ready; intake 100 vs packed 69 → `quantity_mismatch`;
lots {100,200,20} → 31.250/62.500/6.250; ineligible lot + GI requested → `gi_verified=false` with reasons;
approve on `declared_above_computed` → 409; pack 25 on 20 graded → 409; publish before approval → 409
listing reasons; after gates → 202 + `page_builds` row; r2: intake correction before batching),
Dataflow Stages 4–9 and §4, D-033, D-005.
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`); the seeded `world`
fixture lives in tests/integration/conftest.py. Auth is replaced by
a dependency override; Celery's `send_task` is recorded (`task_always_eager` does not apply to tasks sent by
name).
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from decimal import Decimal
from typing import TYPE_CHECKING, Any

import pytest
from httpx import AsyncClient
from sqlalchemy import select

from agritrace.core import task_names
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import (
    ChangeKind,
    EventSubject,
    EventType,
)
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.publishing.models import PageBuild

if TYPE_CHECKING:
    from conftest import World  # tests/integration/conftest.py (type only)

pytestmark = pytest.mark.integration


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


async def _intake(w: World, client: AsyncClient, lot: str, kg: str, **correction: str) -> dict[str, Any]:
    """Receive a lot at the world's processor, or correct its intake.

    Args:
        w: the seeded world.
        client: the API client.
        lot: the lot id.
        kg: received kilograms.
        **correction: `supersedes_intake_id` and `correction_reason` for a correction.

    Returns:
        The intake response body.
    """
    body = {
        "client_id": str(uuid7()),
        "lot_id": lot,
        "processor_id": str(w.processor),
        "sale_date": "2026-07-01",
        "received": {"value": kg, "unit": "kg"},
        **correction,
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
    return await _merge(w, client, lots, gi=gi)


async def _merge(w: World, client: AsyncClient, lots: list[str], gi: bool = False) -> dict[str, Any]:
    """Merge received lots into a batch.

    Args:
        w: the seeded world.
        client: the API client.
        lots: lot ids.
        gi: request the GI label.

    Returns:
        The batch response body.
    """
    body = {
        "client_id": str(uuid7()),
        "processor_id": str(w.processor),
        "gi_label_requested": gi,
        "lot_ids": lots,
    }
    r = await client.post("/v1/batches", json=body)
    assert r.status_code == 201, r.text
    return dict(r.json())


async def _harvest(w: World, lot: str, kg: int) -> None:
    """Store a live harvest event with a kg quantity on a lot (as a sync push would).

    Args:
        w: the seeded world.
        lot: the lot id.
        kg: harvested kilograms.

    Side effects:
        Commits one event and its first version.
    """
    now = datetime(2026, 3, 4, tzinfo=UTC)
    async with get_sessionmaker()() as s:
        event = Event(
            id=uuid7(),
            fpo_id=w.fpo,
            subject_type=EventSubject.LOT,
            lot_id=uuid.UUID(lot),
            plot_id=w.plot,
            event_type=EventType.HARVEST,
            occurred_on=now.date(),
        )
        s.add(event)
        await s.flush()
        version = EventVersion(
            id=uuid7(),
            event_id=event.id,
            version_no=1,
            payload={"quantity": {"value": kg, "unit": "kg"}},
            occurred_on=now.date(),
            device_time=now,
            server_received_at=now,
            entered_by_user_id=w.admin,
            change_kind=ChangeKind.CREATE,
        )
        s.add(version)
        await s.flush()
        event.current_version_id = version.id
        await s.commit()


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
    """A real yield hold (2,000 kg on 1.5 acres, hold above 1,950 kg) in a GI-requested batch.

    The batch is created with `gi_verified=false`, `lot_on_hold` for the lot and `hold_flag`
    `yield_over_ceiling`; B08 sets the hold itself, the plot is confirmed so it is not the blocker.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    await _harvest(w, lot, 2000)
    intake = await _intake(w, client, lot, "50")
    assert ("yield_over_ceiling", "hold") in {(f["rule_code"], f["severity"]) for f in intake["flags"]}
    batch = await _merge(w, client, [lot], gi=True)
    assert batch["gi_verified"] is False
    reasons = {(x["lot_id"], x["reason"], x["detail"]) for x in batch["gi_block_reasons"]}
    assert any(r[:2] == (lot, "lot_on_hold") for r in reasons), reasons
    assert (None, "hold_flag", "yield_over_ceiling") in reasons


async def test_intake_correction_before_batching(world: tuple[World, AsyncClient]) -> None:
    """Intake 100 kg corrected to 95 kg: the batch uses 95; correcting after batching → `lot_already_batched`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    first = await _intake(w, client, lot, "100")
    fix = {"supersedes_intake_id": first["id"], "correction_reason": "scale misread"}
    second = await _intake(w, client, lot, "95", **fix)
    assert second["supersedes_intake_id"] == first["id"]
    batch = await _merge(w, client, [lot])
    assert Decimal(batch["total_received"]["value"]) == Decimal(95)
    assert Decimal(batch["shares"][0]["contributed"]["value"]) == Decimal(95)
    again = {**fix, "supersedes_intake_id": second["id"]}
    body = {
        "client_id": str(uuid7()),
        "lot_id": lot,
        "processor_id": str(w.processor),
        "sale_date": "2026-07-01",
        "received": {"value": "90", "unit": "kg"},
        **again,
    }
    assert _codes(await client.post("/v1/intakes", json=body)) == ["lot_already_batched"]


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
