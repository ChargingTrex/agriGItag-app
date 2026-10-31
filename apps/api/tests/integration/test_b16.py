"""Integration tests of B16 on PostGIS: QC intake by push (D-040), non-GI holds (D-041), assist per kind.

One test per B16 acceptance line (lines 1–7, 9, 10) plus the r1 P2-1 race; lines 8 and 11 (`hold_reasons`,
the OpenAPI check) are in tests/unit/test_b16_logic.py. The seeded `world` (tests/integration/conftest.py)
is one FPO with an admin, a second user, a farmer with a confirmed plot, a GI crop with its profile, one own
processor and a calibrated meter; `act_as` switches the caller's role.
Serves: B16 acceptance, D-040, D-041, D-042, Stage 7, FR9, FR29, FR43, FR68, FR70, CLAUDE.md §6.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack`).
"""

from __future__ import annotations

import asyncio
import secrets
import uuid
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import TYPE_CHECKING, Any

import pytest
from geoalchemy2 import WKTElement
from httpx import AsyncClient
from sqlalchemy import func, select
from test_lots_batches import _codes, _harvest, _intake, _lot, _merge, _moisture, _ready_lot

from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import LocationStatus, OrgKind, PinMethod, Role
from agritrace.core.ids import lot_code, uuid7
from agritrace.core.time import utcnow
from agritrace.modules.identity.models import AssistSession, AuditLog
from agritrace.modules.lots_batches.models import BatchApproval, Lot, LotIntake
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.registry.models import Farmer, Fpo, Plot, Processor
from agritrace.modules.rules_flags import service as rules_service
from agritrace.modules.rules_flags.models import Flag

if TYPE_CHECKING:
    from conftest import World  # tests/integration/conftest.py (type only)

pytestmark = pytest.mark.integration


async def _push(client: AsyncClient, *entries: dict[str, Any]) -> list[dict[str, Any]]:
    """Push entries as the world's current caller.

    Args:
        client: the API client.
        *entries: the entries.

    Returns:
        The per-entry results.
    """
    body = {
        "device_id": str(uuid.uuid4()),
        "app_version": "1.0.3",
        "device_time": datetime.now(UTC).isoformat(),
        "entries": list(entries),
    }
    r = await client.post("/v1/sync/push", json=body)
    assert r.status_code == 200, r.text
    return list(r.json()["results"])


def _intake_entry(lot: str, kg: str = "230", client_id: str | None = None, **data: Any) -> dict[str, Any]:
    """Build a `lot_intake` entry with no `processor_id` unless given.

    Args:
        lot: the lot id.
        kg: received kilograms.
        client_id: the intake id (new when omitted).
        **data: extra `IntakeIn` fields (`processor_id`, `intake_moisture_reading_id`, a correction).

    Returns:
        The entry.
    """
    body = {
        "lot_id": lot,
        "sale_date": date.today().isoformat(),
        "received": {"value": kg, "unit": "kg"},
        **data,
    }
    return {"client_id": client_id or str(uuid7()), "kind": "lot_intake", "data": body}


def _status(results: list[dict[str, Any]]) -> list[str]:
    """Read the statuses of push results.

    Args:
        results: the results.

    Returns:
        Their statuses, with the error code appended for rejections (`rejected:forbidden`).
    """
    return [r["status"] + (f":{r['error']['code']}" if r["status"] == "rejected" else "") for r in results]


async def _intakes(lot: str) -> list[LotIntake]:
    """Load a lot's intake rows.

    Args:
        lot: the lot id.

    Returns:
        The rows.
    """
    async with get_sessionmaker()() as s:
        return list((await s.scalars(select(LotIntake).where(LotIntake.lot_id == uuid.UUID(lot)))).all())


async def _lot_row(lot: str) -> Lot:
    """Load a lot row.

    Args:
        lot: the lot id.

    Returns:
        The row.
    """
    async with get_sessionmaker()() as s:
        row = await s.get(Lot, uuid.UUID(lot))
        assert row is not None
        return row


async def _processor(fpo: uuid.UUID | None) -> uuid.UUID:
    """Insert a processor of an FPO (or shared when None).

    Args:
        fpo: the owning FPO, or None for a shared processor.

    Returns:
        Its id.
    """
    async with get_sessionmaker()() as s:
        row = Processor(fpo_id=fpo, name="Processor", kind=OrgKind.COMPANY)
        s.add(row)
        await s.commit()
        return row.id


async def _other_fpo() -> uuid.UUID:
    """Insert another FPO.

    Returns:
        Its id.
    """
    async with get_sessionmaker()() as s:
        row = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Other FPO", kind=OrgKind.FPO)
        s.add(row)
        await s.commit()
        return row.id


async def test_qc_push_receives_lot_idempotently(world: tuple[World, AsyncClient]) -> None:
    """Line 1: QC push [reading R, lot_intake I] → 2 accepted, one row, lot received; resend → duplicates.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _lot(w, client)
    assert (
        await client.post("/v1/quality-readings", json=_moisture(w, "10.5", lot_id=lot))
    ).status_code == 201
    assert (await client.post(f"/v1/lots/{lot}/ready")).status_code == 200
    async with get_sessionmaker()() as s:
        row = await s.get(Lot, uuid.UUID(lot))
        assert row is not None
        row.packed_kg = Decimal(200)
        await s.commit()
    w.act_as(w.admin2, Role.QC_OFFICER)
    reading = _moisture(w, "10.5", stage="intake", lot_id=lot)
    r_entry = {"client_id": reading.pop("client_id"), "kind": "quality_reading", "data": reading}
    i_entry = _intake_entry(lot, intake_moisture_reading_id=r_entry["client_id"])
    assert _status(await _push(client, r_entry, i_entry)) == ["accepted", "accepted"]
    [intake] = await _intakes(lot)
    assert (str(intake.id), intake.processor_id, intake.accepted_by_user_id) == (
        i_entry["client_id"],
        w.processor,
        w.admin2,
    )
    assert (await _lot_row(lot)).status == "received"
    async with get_sessionmaker()() as s:
        query = select(Flag.rule_code).where(Flag.subject_id == uuid.UUID(lot), Flag.status == "open")
        assert "quantity_mismatch" in set((await s.scalars(query)).all())
    assert _status(await _push(client, r_entry, i_entry)) == ["duplicate", "duplicate"]
    assert len(await _intakes(lot)) == 1


async def test_processor_default_and_scope(world: tuple[World, AsyncClient]) -> None:
    """Line 2: no processor, two or zero own → field_required; own/shared → accepted; foreign → not_found.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lots = [await _ready_lot(w, client) for _ in range(5)]
    second = await _processor(w.fpo)
    shared = await _processor(None)
    other = await _other_fpo()
    foreign = await _processor(other)
    w.act_as(w.admin2, Role.QC_OFFICER)
    [two] = await _push(client, _intake_entry(lots[0]))
    assert two["status"] == "rejected" and two["error"]["code"] == "field_required"
    assert two["error"]["details"]["field"] == "processor_id"
    results = await _push(
        client,
        _intake_entry(lots[1], processor_id=str(w.processor)),
        _intake_entry(lots[2], processor_id=str(shared)),
        _intake_entry(lots[3], processor_id=str(foreign)),
    )
    assert _status(results) == ["accepted", "accepted", "rejected:not_found"]
    assert [(await _intakes(lot))[0].processor_id for lot in lots[1:3]] == [w.processor, shared]
    async with get_sessionmaker()() as s:  # the FPO now owns no processor
        for pid in (w.processor, second):
            row = await s.get(Processor, pid)
            assert row is not None
            row.fpo_id = other
        await s.commit()
    [zero] = await _push(client, _intake_entry(lots[4]))
    assert zero["status"] == "rejected" and zero["error"]["code"] == "field_required"
    assert zero["error"]["details"]["field"] == "processor_id"


async def test_concurrent_identical_lot_intakes(world: tuple[World, AsyncClient]) -> None:
    """Review P2-1: two identical `lot_intake` pushes at once → one `accepted`, one `duplicate`, one row.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    w.act_as(w.admin2, Role.QC_OFFICER)
    entry = _intake_entry(lot)
    pushes = await asyncio.gather(_push(client, entry), _push(client, entry))
    assert sorted(r[0]["status"] for r in pushes) == ["accepted", "duplicate"]
    assert len(await _intakes(lot)) == 1


async def test_open_lot_passes_the_ready_gate_at_intake(world: tuple[World, AsyncClient]) -> None:
    """Line 3: open lot at 10.9 % → received with `ready_at`; 11.5 % or none → gate refusal, lot unchanged.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    good, wet, dry_unknown = [await _lot(w, client) for _ in range(3)]
    for lot, value in ((good, "10.9"), (wet, "11.5")):
        assert (
            await client.post("/v1/quality-readings", json=_moisture(w, value, lot_id=lot))
        ).status_code == 201
    w.act_as(w.admin2, Role.QC_OFFICER)
    results = await _push(client, _intake_entry(good), _intake_entry(wet), _intake_entry(dry_unknown))
    assert _status(results) == ["accepted", "rejected:gate_not_met", "rejected:gate_not_met"]
    for r in results[1:]:
        assert [x["code"] for x in r["error"]["details"]["reasons"]] == ["moisture_gate_failed"]
    received = await _lot_row(good)
    assert received.status == "received" and received.ready_at is not None
    for lot in (wet, dry_unknown):
        row = await _lot_row(lot)
        assert (row.status, row.ready_at, await _intakes(lot)) == ("open", None, [])


async def test_lot_intake_roles_and_corrections(world: tuple[World, AsyncClient]) -> None:
    """Line 4: farmer, field officer, viewer → forbidden; QC correction → forbidden, admin one → accepted.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot = await _ready_lot(w, client)
    for role in (Role.FARMER, Role.FIELD_OFFICER, Role.VIEWER):
        w.act_as(w.admin2, role)
        assert _status(await _push(client, _intake_entry(lot))) == ["rejected:forbidden"]
    w.act_as(w.admin2, Role.QC_OFFICER)
    first = _intake_entry(lot)
    assert _status(await _push(client, first)) == ["accepted"]
    fix = {"supersedes_intake_id": first["client_id"], "correction_reason": "scale misread"}
    correction = _intake_entry(lot, "220", **fix)
    assert _status(await _push(client, correction)) == ["rejected:forbidden"]
    w.act_as(w.admin)
    assert _status(await _push(client, correction)) == ["accepted"]
    assert len(await _intakes(lot)) == 2


async def test_rest_intake_open_to_qc_officer(world: tuple[World, AsyncClient]) -> None:
    """Line 5: `POST /v1/intakes` by a QC officer → 201, by a field officer → 403 (B09 admin tests unchanged).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot, other = await _ready_lot(w, client), await _ready_lot(w, client)
    w.act_as(w.admin2, Role.QC_OFFICER)
    out = await _intake(w, client, lot, "100")
    assert out["accepted_by_user_id"] == str(w.admin2)
    w.act_as(w.admin2, Role.FIELD_OFFICER)
    body = {
        "client_id": str(uuid7()),
        "lot_id": other,
        "sale_date": "2026-07-01",
        "received": {"value": 1, "unit": "kg"},
    }
    r = await client.post("/v1/intakes", json=body)
    assert r.status_code == 403 and r.json()["error"]["code"] == "forbidden"


async def _held_lots(w: World, client: AsyncClient) -> tuple[list[str], list[uuid.UUID]]:
    """Make two received lots: one on a plot outside the GI region (plot hold), one over the yield ceiling.

    Args:
        w: the seeded world.
        client: the API client.

    Returns:
        `(lot ids, hold flag ids)`.
    """
    async with get_sessionmaker()() as s:
        farmer = await s.scalar(select(Farmer.id).where(Farmer.fpo_id == w.fpo))
        plot = Plot(
            id=uuid7(),
            fpo_id=w.fpo,
            farmer_id=farmer,
            code=f"P-{secrets.token_hex(2)}",
            pin=WKTElement("POINT(80.27 13.08)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
            pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
            declared_area_acres=Decimal("1.5"),
            location_status=LocationStatus.OUTSIDE,
        )
        s.add(plot)
        await s.commit()
        assert "plot_outside_gi_region" in await rules_service.check_plot(s, plot.id)
    body = {
        "client_id": str(uuid7()),
        "plot_id": str(plot.id),
        "crop_id": str(w.crop),
        "season_label": "2025-26",
    }
    r = await client.post("/v1/lots", json=body)
    assert r.status_code == 201, r.text
    outside = str(r.json()["id"])
    assert (
        await client.post("/v1/quality-readings", json=_moisture(w, "10.0", lot_id=outside))
    ).status_code == 201
    assert (await client.post(f"/v1/lots/{outside}/ready")).status_code == 200
    over = await _ready_lot(w, client)
    await _harvest(w, over, 2000)  # 2,000 kg on 1.5 acres: above the 30 % hold margin
    await _intake(w, client, outside, "50")
    await _intake(w, client, over, "50")
    async with get_sessionmaker()() as s:
        holds = (
            await s.scalars(
                select(Flag.id).where(
                    Flag.subject_id.in_([plot.id, uuid.UUID(over)]),
                    Flag.rule_code.in_(["plot_outside_gi_region", "yield_over_ceiling"]),
                    Flag.severity == "hold",
                    Flag.status == "open",
                )
            )
        ).all()
    assert len(holds) == 2
    return [outside, over], list(holds)


async def test_non_gi_batch_publishes_over_gi_only_holds(world: tuple[World, AsyncClient]) -> None:
    """Line 6: non-GI batch with both GI-only holds → approve, pack, publish pass; holds open and recorded.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lots, holds = await _held_lots(w, client)
    batch = (await _merge(w, client, lots, gi=False))["id"]
    reading = _moisture(w, "10.5", stage="grading", batch_id=batch)
    grading = {"declared_grade": "Standard", "readings": [reading]}
    assert (await client.post(f"/v1/batches/{batch}/grading", json=grading)).status_code == 201
    r = await client.post(
        f"/v1/batches/{batch}/grading/approve", json={"graded": {"value": 100, "unit": "kg"}}
    )
    assert r.status_code == 200, r.text
    packing = {
        "packed": {"value": 90, "unit": "kg"},
        "pack_date": "2026-08-01",
        "best_before_date": "2027-07-31",
    }
    assert (await client.post(f"/v1/batches/{batch}/final-packing", json=packing)).status_code == 200
    r = await client.post(f"/v1/batches/{batch}/publish")
    assert r.status_code == 202, r.text
    out = (await client.get(f"/v1/batches/{batch}")).json()
    assert (out["gi_verified"], out["gi_block_reasons"]) == (False, [])
    async with get_sessionmaker()() as s:
        approvals = (
            await s.scalars(select(BatchApproval).where(BatchApproval.batch_id == uuid.UUID(batch)))
        ).all()
        builds = await s.scalar(select(func.count()).where(PageBuild.batch_id == uuid.UUID(batch)))
        statuses = (await s.scalars(select(Flag.status).where(Flag.id.in_(holds)))).all()
    assert builds == 1
    by_stage = {str(a.stage): set(a.blocked_reasons or []) for a in approvals}
    for stage in ("grading", "final_packing", "publish"):
        assert {"plot_outside_gi_region", "yield_over_ceiling"} <= by_stage[stage], by_stage
    assert [str(x) for x in statuses] == ["open", "open"]


async def test_gi_batch_still_blocked_by_gi_only_holds(world: tuple[World, AsyncClient]) -> None:
    """Line 7: the same holds in a GI-requested batch → publish 409 `open_hold_flag` each; GI not verified.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lots, _ = await _held_lots(w, client)
    batch = (await _merge(w, client, lots, gi=True))["id"]
    r = await client.post(f"/v1/batches/{batch}/publish")
    assert "open_hold_flag" in _codes(r)
    held = {x["rule_code"] for x in r.json()["error"]["details"]["reasons"] if x["code"] == "open_hold_flag"}
    assert held == {"plot_outside_gi_region", "yield_over_ceiling"}
    out = (await client.get(f"/v1/batches/{batch}")).json()
    assert out["gi_verified"] is False and out["gi_block_reasons"]


async def _session_for_world_farmer(w: World) -> tuple[uuid.UUID, uuid.UUID, str]:
    """Start an assist session of `admin2` (as field officer) for the world's farmer A; add farmer B's lot.

    Args:
        w: the seeded world.

    Returns:
        `(session id, farmer A id, farmer B's lot id)`.
    """
    async with get_sessionmaker()() as s:
        farmer_a = await s.scalar(select(Farmer.id).where(Farmer.fpo_id == w.fpo))
        assert farmer_a is not None
        farmer_b = Farmer(fpo_id=w.fpo, code=f"F-{secrets.token_hex(3)}", name="Ravi")
        s.add(farmer_b)
        await s.flush()
        plot_b = Plot(
            id=uuid7(),
            fpo_id=w.fpo,
            farmer_id=farmer_b.id,
            code="P-B",
            pin=WKTElement("POINT(77.96 9.58)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
            pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
            declared_area_acres=Decimal("1.5"),
            location_status=LocationStatus.CONFIRMED,
        )
        session_id = uuid7()
        s.add_all(
            [
                plot_b,
                AssistSession(
                    id=session_id, officer_user_id=w.admin2, farmer_id=farmer_a, started_at=utcnow()
                ),
            ]
        )
        await s.flush()
        lot_b = Lot(
            id=uuid7(),
            fpo_id=w.fpo,
            farmer_id=farmer_b.id,
            plot_id=plot_b.id,
            crop_id=w.crop,
            season_label="2025-26",
            code=lot_code(),
            status="open",
            gi_eligible=True,
        )
        s.add(lot_b)
        await s.commit()
    return session_id, farmer_a, str(lot_b.id)


async def test_assist_session_checked_on_lot_readings_refused_on_batches(
    world: tuple[World, AsyncClient],
) -> None:
    """Line 9: session S (farmer A): A's lot reading accepted, S/A audited; B lot, batch reading/event → 403.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    lot_a = await _lot(w, client)
    batch_lot = await _ready_lot(w, client)
    await _intake(w, client, batch_lot, "100")
    batch = (await _merge(w, client, [batch_lot]))["id"]
    session_id, farmer_a, lot_b = await _session_for_world_farmer(w)
    w.act_as(w.admin2, Role.FIELD_OFFICER)

    def reading_entry(**subject: str) -> dict[str, Any]:
        """Build a moisture reading entry in session S.

        Args:
            **subject: `lot_id=...` or `batch_id=...`.

        Returns:
            The entry.
        """
        stage = "grading" if "batch_id" in subject else "drying_end"
        data = _moisture(w, "10.5", stage=stage, **subject)
        return {
            "client_id": data.pop("client_id"),
            "kind": "quality_reading",
            "data": data,
            "assist_session_id": str(session_id),
        }

    event = {
        "event_id": str(uuid7()),
        "version_no": 1,
        "subject_type": "batch",
        "batch_id": batch,
        "event_type": "grading",
        "instance_no": 1,
        "occurred_on": "2026-08-01",
        "payload": {},
        "clocks": {"device_time": datetime.now(UTC).isoformat()},
    }
    ok = reading_entry(lot_id=lot_a)
    results = await _push(
        client,
        ok,
        reading_entry(lot_id=lot_b),
        reading_entry(batch_id=batch),
        {
            "client_id": str(uuid7()),
            "kind": "event_version",
            "data": event,
            "assist_session_id": str(session_id),
        },
    )
    assert _status(results) == ["accepted", "rejected:forbidden", "rejected:forbidden", "rejected:forbidden"]
    async with get_sessionmaker()() as s:
        [row] = (
            await s.scalars(
                select(AuditLog).where(
                    AuditLog.entity_type == "quality_readings",
                    AuditLog.entity_id == uuid.UUID(ok["client_id"]),
                    AuditLog.action == "create",
                )
            )
        ).all()
    assert (row.assist_session_id, row.on_behalf_of_farmer_id) == (session_id, farmer_a)


async def test_flag_resolution_ignores_assist_session(world: tuple[World, AsyncClient]) -> None:
    """Line 10: `flag_resolution` with session S or an unknown session → accepted, audit rows without assist.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    flags = []
    for _ in range(2):
        lot = await _ready_lot(w, client)
        async with get_sessionmaker()() as s:
            row = await s.get(Lot, uuid.UUID(lot))
            assert row is not None
            row.packed_kg = Decimal(69)
            await s.commit()
        out = await _intake(w, client, lot, "100")
        flags += [f["id"] for f in out["flags"] if f["rule_code"] == "quantity_mismatch"]
    assert len(flags) == 2
    session_id, _, _ = await _session_for_world_farmer(w)
    w.act_as(w.admin2, Role.FIELD_OFFICER)
    entries = [
        {
            "client_id": str(uuid7()),
            "kind": "flag_resolution",
            "data": {"flag_id": flag, "resolution": "looks_fine", "reason_code": "field_visit"},
            "assist_session_id": str(sid),
        }
        for flag, sid in zip(flags, (session_id, uuid.uuid4()), strict=True)
    ]
    assert _status(await _push(client, *entries)) == ["accepted", "accepted"]
    async with get_sessionmaker()() as s:
        rows = (
            await s.scalars(
                select(AuditLog).where(
                    AuditLog.entity_type == "flags",
                    AuditLog.entity_id.in_([uuid.UUID(f) for f in flags]),
                    AuditLog.action == "update",
                )
            )
        ).all()
    assert rows and all((r.on_behalf_of_farmer_id, r.assist_session_id) == (None, None) for r in rows)
