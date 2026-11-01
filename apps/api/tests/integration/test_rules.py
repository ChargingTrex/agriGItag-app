"""Integration tests of the server rules on PostGIS, the shared GI cases and flag resolution.

Covers off-plot events, the reference lot's flag set, yield holds, checks racing an intake, a photo verdict
and a reviewer (B19), and resolving over HTTP and sync push.

Serves: B15 acceptance (D-030 reference set, old flag closed); B08 acceptance (600 m off plot →
`event_off_plot` warn, re-check no dup; 1,150/1,250/1,350 kg → none/warn/hold + `gi_eligible=false`),
backend-design §5 expected flags (inline fixture until B12 seeds the reference batch), D-006 (`gi_check`
cases of tests/fixtures/rule_cases.json through `locate_point`), FR70, B19 (QA issue B16-1).
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`).
"""

import asyncio
import contextlib
import json
import math
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient
from shapely.geometry import shape
from sqlalchemy import insert, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import (
    ChangeKind,
    EventStatus,
    EventSubject,
    EventType,
    FlagStatus,
    FlagSubject,
    InputCategory,
    LocationStatus,
    OrgKind,
    PhotoStatus,
    PinMethod,
    Role,
    Severity,
)
from agritrace.core.errors import FlagNotOpenError
from agritrace.core.ids import batch_code, lot_code, uuid7
from agritrace.core.schemas import GeoPoint
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot, LotIntake
from agritrace.modules.quality.profiles.loader import load_profile
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import (
    Crop,
    Farmer,
    Fpo,
    GiRegionVersion,
    GiTag,
    InputMaster,
    Plot,
    Processor,
)
from agritrace.modules.rules_flags import service
from agritrace.modules.rules_flags.models import Flag
from agritrace.modules.rules_flags.rules.context import FlagCandidate
from agritrace.modules.rules_flags.schemas import FlagResolveIn

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
CASES = json.loads((API_DIR / "tests" / "fixtures" / "rule_cases.json").read_text())
PIN = (9.55, 78.2)  # inside the fixture octagon
DEG_PER_M = 1 / (111194.93 * math.cos(math.radians(PIN[0])))
NOW = datetime(2026, 3, 4, 8, 0, tzinfo=UTC)


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
    """Ids of a freshly seeded FPO with one plot and one lot declared Inorganic + IPM."""

    fpo: uuid.UUID
    officer: uuid.UUID
    admin: uuid.UUID
    farmer: uuid.UUID
    plot: uuid.UUID
    lot: uuid.UUID
    crop: uuid.UUID
    processor: uuid.UUID
    inputs: list[uuid.UUID]


def _region(gi_tag_id: uuid.UUID, geometry: dict[str, Any], buffer_m: float) -> GiRegionVersion:
    """Make a region version effective since 2020.

    Args:
        gi_tag_id: the GI tag.
        geometry: GeoJSON MultiPolygon.
        buffer_m: tolerance buffer in metres.

    Returns:
        The unsaved row.
    """
    return GiRegionVersion(
        gi_tag_id=gi_tag_id,
        version_no=1,
        geom=WKTElement(shape(geometry).wkt, srid=4326),
        tolerance_buffer_m=Decimal(str(buffer_m)),
        taluks=["Tiruchuli", "Aruppukottai"],
        source_ref="tests/fixtures/rule_cases.json (non-official octagon)",
        licence="CC0-1.0",
        confidence="fixture",
        effective_from=date(2020, 1, 1),
    )


@pytest.fixture
async def world(migrated: None) -> World:
    """Seed an FPO, people, a GI region, a plot at `PIN` (1 acre), organic inputs, a lot and the profile.

    Args:
        migrated: the migrated database (fixture).

    Returns:
        The seeded ids.
    """
    async with get_sessionmaker()() as s:
        officer = User(phone=f"+9195{secrets.randbelow(10**8):08d}", name="Officer")
        admin = User(phone=f"+9194{secrets.randbelow(10**8):08d}", name="Admin")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        tag = GiTag(gi_number=f"T{secrets.token_hex(4)}", name="Samba Vathal")
        s.add_all([officer, admin, fpo, tag])
        await s.flush()
        crop = Crop(
            code=f"CHILLI_{secrets.token_hex(4)}",
            name_en="Samba Vathal",
            gi_tag_id=tag.id,
            event_schema=CASES["event_order"]["event_schema"],
        )
        region = CASES["gi_check"]["region"]
        farmer = Farmer(fpo_id=fpo.id, code="F-001", name="Selvi")
        processor = Processor(fpo_id=fpo.id, name="Demo processor", kind=OrgKind.COMPANY)
        inputs = [
            InputMaster(name_en=n, category=c, unit="kg")
            for n, c in [
                ("Organic Fertilizer Gold", InputCategory.ORGANIC_FERTILIZER),
                ("Azospirillum", InputCategory.BIO_FERTILIZER),
            ]
        ]
        s.add_all([crop, farmer, processor, _region(tag.id, region["geometry"], 150), *inputs])
        await s.flush()
        plot = Plot(
            id=uuid7(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            code="P-01",
            gi_tag_id=tag.id,
            pin=WKTElement(f"POINT({PIN[1]} {PIN[0]})", srid=4326),
            pin_accuracy_m=5.0,
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=NOW,
            pin_server_received_at=NOW,
            declared_area_acres=Decimal(1),
            location_status=LocationStatus.CONFIRMED,
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
            practice_tags={"declared": ["inorganic", "ipm"], "derived": [], "contradiction": False},
        )
        s.add(lot)
        await s.commit()
        await load_profile(s, crop.id)
        return World(
            fpo.id,
            officer.id,
            admin.id,
            farmer.id,
            plot.id,
            lot.id,
            crop.id,
            processor.id,
            [i.id for i in inputs],
        )


async def _event(
    s: AsyncSession,
    w: World,
    kind: EventType,
    on: str,
    payload: dict[str, Any] | None = None,
    gps: tuple[float, float] | None = None,
) -> uuid.UUID:
    """Store a submitted farm event of the world's lot with one version.

    Args:
        s: session (committed here).
        w: the world.
        kind: event type.
        on: ISO date it happened.
        payload: version payload.
        gps: (lat, lon) of the fix, if any.

    Returns:
        The event id.
    """
    day = date.fromisoformat(on)
    event = Event(
        id=uuid7(),
        fpo_id=w.fpo,
        subject_type=EventSubject.LOT,
        lot_id=w.lot,
        plot_id=w.plot,
        event_type=kind,
        occurred_on=day,
    )
    s.add(event)
    await s.flush()
    version = EventVersion(
        id=uuid7(),
        event_id=event.id,
        version_no=1,
        payload=payload or {},
        occurred_on=day,
        device_time=datetime.combine(day, datetime.min.time(), UTC),
        server_received_at=NOW,
        gps=WKTElement(f"POINT({gps[1]} {gps[0]})", srid=4326) if gps else None,
        gps_accuracy_m=6.0 if gps else None,
        entered_by_user_id=w.officer,
        change_kind=ChangeKind.CREATE,
    )
    s.add(version)
    await s.flush()
    event.current_version_id = version.id
    await s.commit()
    return event.id


async def _correct(s: AsyncSession, w: World, event_id: uuid.UUID, payload: dict[str, Any]) -> None:
    """Append a correction version to an event and point the event at it (append-only, FR25).

    Args:
        s: session (committed here).
        w: the world.
        event_id: the event.
        payload: the corrected payload.
    """
    event = await s.get(Event, event_id)
    assert event is not None and event.current_version_id is not None
    previous = await s.get(EventVersion, event.current_version_id)
    assert previous is not None
    version = EventVersion(
        id=uuid7(),
        event_id=event_id,
        version_no=previous.version_no + 1,
        payload=payload,
        occurred_on=previous.occurred_on,
        device_time=previous.device_time,
        server_received_at=NOW,
        entered_by_user_id=w.officer,
        change_kind=ChangeKind.CORRECT,
        reason_code="wrong_quantity",
        supersedes_version_id=previous.id,
    )
    s.add(version)
    await s.flush()
    event.current_version_id = version.id
    await s.commit()


async def _flags(s: AsyncSession, subject: uuid.UUID, code: str) -> list[Flag]:
    """Load every flag of one rule on one subject.

    Args:
        s: session.
        subject: subject id.
        code: rule code.

    Returns:
        The flags.
    """
    query = select(Flag).where(Flag.subject_id == subject, Flag.rule_code == code)
    return list((await s.scalars(query)).all())


async def test_event_600_m_off_plot_is_a_warn_and_recheck_does_not_duplicate(world: World) -> None:
    """GPS 600 m east of a pin-only plot (200 m radius + 150 m buffer) → one warn, checked twice.

    Args:
        world: the seeded FPO.
    """
    async with get_sessionmaker()() as s:
        off = await _event(s, world, EventType.SOWING, "2025-10-20", gps=(PIN[0], PIN[1] + 600 * DEG_PER_M))
        near = await _event(s, world, EventType.SOWING, "2025-10-21", gps=(PIN[0], PIN[1] + 100 * DEG_PER_M))
        await service.check_event(s, off)
        await service.check_event(s, off)
        await service.check_event(s, near)
        [flag] = await _flags(s, off, "event_off_plot")
        assert (flag.severity, flag.assigned_role) == (Severity.WARN, Role.FIELD_OFFICER)
        assert await _flags(s, near, "event_off_plot") == []


async def test_reference_lot_flag_set(world: World) -> None:
    """Inline stand-in for the B12 seed (backend-design §5): the PRD §12 problems raise exactly their flags.

    Nursery before ploughing, organic inputs only, Inorganic + IPM declared without a pest event, packed 69 kg
    but 100 kg used, no harvest quantity, and a batch of 100 kg received (fully attributed) graded to 20 kg.
    B15 (D-030): the batch raises `grading_loss_high`, and a `batch_quantity_unattributed` flag stored by the
    B08 rule before the split is closed `rule_passed` by this check.

    Args:
        world: the seeded FPO.
    """
    async with get_sessionmaker()() as s:
        await _event(s, world, EventType.NURSERY, "2025-09-05")
        await _event(s, world, EventType.LAND_PREPARATION, "2025-09-30")
        await _event(s, world, EventType.SOWING, "2025-10-20")
        for input_id in world.inputs:
            payload = {"input_id": str(input_id), "quantity": {"value": 25, "unit": "kg"}}
            await _event(s, world, EventType.INPUT_APPLICATION, "2025-12-05", payload)
        await _event(s, world, EventType.HARVEST, "2026-02-14")
        await _event(s, world, EventType.DRYING, "2026-03-01")
        await _event(s, world, EventType.PACKING, "2026-03-10", {"quantity": {"value": 69, "unit": "kg"}})
        batch = Batch(
            fpo_id=world.fpo,
            crop_id=world.crop,
            processor_id=world.processor,
            code=batch_code(),
            created_by=world.officer,
            total_received_kg=Decimal(100),
            graded_kg=Decimal(20),
        )
        s.add(batch)
        await s.flush()
        s.add(
            BatchShare(
                batch_id=batch.id,
                lot_id=world.lot,
                kg_contributed=Decimal(100),
                share_pct=100,
                farmer_id=world.farmer,
            )
        )
        old = FlagCandidate(FlagSubject.BATCH, batch.id, "batch_quantity_unattributed", Severity.WARN)
        await service.store_flags(s, world.fpo, [old], {batch.id}, {old.rule_code})
        await s.commit()
        flags = await service.run_gate_checks(s, batch_id=batch.id)
        await s.commit()
        [stale] = await _flags(s, batch.id, "batch_quantity_unattributed")
        assert (stale.status, stale.resolution_reason_code) == (FlagStatus.FIXED, "rule_passed")
        assert sorted(f.rule_code for f in flags) == [
            "grading_loss_high",
            "ipm_without_pest_event",
            "practice_tag_contradiction",
            "quantity_mismatch",
            "yield_check_unavailable",
        ]
        lot = await s.get(Lot, world.lot)
        assert lot is not None and lot.practice_tags == {
            "declared": ["inorganic", "ipm"],
            "derived": ["organic"],
            "contradiction": True,
        }


@pytest.mark.parametrize(("kg", "severity"), [(1150, None), (1250, Severity.WARN), (1350, Severity.HOLD)])
async def test_yield_on_one_acre_and_hold_clears_gi(world: World, kg: int, severity: Severity | None) -> None:
    """1,150 / 1,250 / 1,350 kg on 1 acre → none / warn / hold; a hold unsets `gi_eligible` until resolved.

    Args:
        world: the seeded FPO.
        kg: harvested kilograms.
        severity: expected `yield_over_ceiling` severity, or None.
    """
    async with get_sessionmaker()() as s:
        await _event(s, world, EventType.HARVEST, "2026-02-14", {"quantity": {"value": kg, "unit": "kg"}})
        await service.check_lot(s, world.lot)
        flags = await _flags(s, world.lot, "yield_over_ceiling")
        assert [f.severity for f in flags] == ([severity] if severity else [])
        lot = await s.get(Lot, world.lot)
        assert lot is not None
        await s.refresh(lot)
        if severity == Severity.HOLD:
            assert (lot.gi_eligible, lot.gi_hold_reason) == (False, "flags: yield_over_ceiling")
            admin = CurrentUser(world.admin, world.fpo, Role.FPO_ADMIN)
            body = FlagResolveIn(resolution="looks_fine", reason_code="land_record_checked")
            await service.resolve_flag(s, admin, flags[0].id, body)
            await s.commit()
            assert (lot.gi_eligible, lot.gi_hold_reason) == (True, None)


async def test_hold_comes_back_after_auto_close(world: World) -> None:
    """1,350 → 1,150 → 1,350 kg: the auto-closed hold comes back and GI is blocked again (review P1-1).

    Hold first; then closed `rule_passed` with `gi_eligible` restored; then the same flag is a hold again.

    Args:
        world: the seeded FPO.
    """
    async with get_sessionmaker()() as s:
        harvest = await _event(
            s, world, EventType.HARVEST, "2026-02-14", {"quantity": {"value": 1350, "unit": "kg"}}
        )
        lot = await s.get(Lot, world.lot)
        assert lot is not None
        steps = [
            (1350, FlagStatus.OPEN, False),
            (1150, FlagStatus.FIXED, True),
            (1350, FlagStatus.OPEN, False),
        ]
        for i, (kg, status, eligible) in enumerate(steps):
            if i:
                await _correct(s, world, harvest, {"quantity": {"value": kg, "unit": "kg"}})
            await service.check_lot(s, world.lot)
            [flag] = await _flags(s, world.lot, "yield_over_ceiling")
            await s.refresh(flag)
            await s.refresh(lot)
            assert (flag.status, flag.severity, lot.gi_eligible) == (status, Severity.HOLD, eligible)
        assert (flag.resolution_reason_code, lot.gi_hold_reason) == (None, "flags: yield_over_ceiling")


async def test_lot_rules_see_all_history_of_a_1500_event_lot(world: World) -> None:
    """1,350 one-kg harvests sum to a hold; a drying dated before them all is out of order (B22 projection).

    The lot also has an organic input (declared Inorganic → contradiction), an undone 500 kg harvest and a
    harvest in quintals, which the kg sum must both leave out.

    Args:
        world: the seeded FPO.
    """
    async with get_sessionmaker()() as s:
        for kind, on in [
            (EventType.LAND_PREPARATION, "2025-09-01"),
            (EventType.NURSERY, "2025-09-01"),
            (EventType.SOWING, "2025-09-02"),
        ]:
            await _event(s, world, kind, on)
        await _event(s, world, EventType.INPUT_APPLICATION, "2025-09-03", {"input_id": str(world.inputs[0])})
        drying = await _event(s, world, EventType.DRYING, "2025-09-05")
        undone = await _event(
            s, world, EventType.HARVEST, "2025-10-01", {"quantity": {"value": 500, "unit": "kg"}}
        )
        await s.execute(update(Event).where(Event.id == undone).values(status=EventStatus.UNDONE))
        payloads = [{"quantity": {"value": 1, "unit": "kg"}}] * 1350 + [
            {"quantity": {"value": 9, "unit": "q"}}
        ]
        events, versions = [], []
        for i, payload in enumerate(payloads):
            day, eid = date(2025, 9, 10) + timedelta(days=i // 10), uuid7()
            events.append(
                dict(id=eid, fpo_id=world.fpo, subject_type=EventSubject.LOT, lot_id=world.lot,
                     plot_id=world.plot, event_type=EventType.HARVEST, occurred_on=day)
            )  # fmt: skip
            versions.append(
                dict(id=uuid7(), event_id=eid, version_no=1, payload=payload, occurred_on=day,
                     device_time=NOW, server_received_at=NOW, entered_by_user_id=world.officer,
                     change_kind=ChangeKind.CREATE)
            )  # fmt: skip
        await s.execute(insert(Event), events)
        await s.execute(insert(EventVersion), versions)
        await s.execute(
            update(Event)
            .where(Event.id.in_([e["id"] for e in events]))
            .values(current_version_id=select(EventVersion.id).where(EventVersion.event_id == Event.id))
        )
        await s.commit()
        assert len(await service.check_lot(s, world.lot)) > 0
        [hold] = await _flags(s, world.lot, "yield_over_ceiling")
        assert (hold.severity, hold.details["harvested_kg"]) == (Severity.HOLD, "1350")
        [order] = await _flags(s, drying, "event_out_of_order")
        assert order.details["missing"] == ["harvest"]
        out_of_order = select(Flag).where(Flag.rule_code == "event_out_of_order", Flag.subject_id != drying)
        assert (await s.scalars(out_of_order.where(Flag.fpo_id == world.fpo))).all() == []
        assert await _flags(s, world.lot, "practice_tag_contradiction") != []


def _pause_first(
    monkeypatch: pytest.MonkeyPatch, name: str, seconds: float
) -> tuple[asyncio.Event, asyncio.Event]:
    """Make the first call of a service fact loader pause after it read, as a slow worker would.

    Args:
        monkeypatch: pytest fixture.
        name: `_lot_context` or `_event_context` in the rules service.
        seconds: longest pause; a run that holds the lock the other session waits for times out here.

    Returns:
        `(read, release)`: set when the first call has read its facts; set it to end the pause early.
    """
    read, release = asyncio.Event(), asyncio.Event()
    original = getattr(service, name)

    async def paused(*args: Any) -> Any:
        """Call the real loader; on the first call wait for `release` (at most `seconds`).

        Args:
            *args: the loader's arguments.

        Returns:
            The real context.
        """
        ctx = await original(*args)
        if not read.is_set():
            read.set()
            with contextlib.suppress(TimeoutError):
                await asyncio.wait_for(release.wait(), seconds)
        return ctx

    monkeypatch.setattr(service, name, paused)
    return read, release


async def _check_lot_alone(lot_id: uuid.UUID) -> None:
    """Run `rules.check_lot` in its own session, as the worker does.

    Args:
        lot_id: the lot.
    """
    async with get_sessionmaker()() as a:
        await service.check_lot(a, lot_id)


async def test_stale_check_cannot_close_a_flag_committed_after_it_read(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    """B16-1: a lot check that read the facts before an intake committed leaves the intake's flag open.

    Check A reads the lot (packed 100 kg, no intake) and waits up to 2 s for session B, which records a 130 kg
    intake, runs the gate checks (`quantity_mismatch` warn) and commits; then A stores its flags. With the lot
    lock B waits for A instead, so either way the flag must end open.

    Args:
        world: the seeded FPO.
        monkeypatch: pytest fixture (pauses A after its first context read).
    """
    async with get_sessionmaker()() as s:
        await _event(s, world, EventType.PACKING, "2026-03-10", {"quantity": {"value": 100, "unit": "kg"}})
    read, committed = _pause_first(monkeypatch, "_lot_context", 2)
    task = asyncio.create_task(_check_lot_alone(world.lot))
    await read.wait()
    async with get_sessionmaker()() as b:
        intake = LotIntake(
            id=uuid7(),
            fpo_id=world.fpo,
            lot_id=world.lot,
            processor_id=world.processor,
            sale_date=date(2026, 3, 12),
            received_kg=Decimal(130),
            accepted_by_user_id=world.admin,
        )
        b.add(intake)
        await b.flush()
        await service.run_gate_checks(b, lot_id=world.lot)
        await b.commit()
    committed.set()
    await task
    async with get_sessionmaker()() as s:
        [flag] = await _flags(s, world.lot, "quantity_mismatch")
        assert (flag.status, flag.resolution_reason_code) == (FlagStatus.OPEN, None)


async def test_reviewer_and_check_of_one_lot_do_not_deadlock(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    """B19-r1 P1-1: a reviewer resolving a lot hold while a check of the lot runs waits; no deadlock.

    Hold at 1,350 kg, corrected to 1,150 kg; check A pauses after reading the lot (holding the lot lock) while
    the admin resolves the hold `fixed` in another session. A closes the hold first (`rule_passed`), so the
    reviewer gets 409 `flag_not_open` instead of a deadlock or an overwrite.

    Args:
        world: the seeded FPO.
        monkeypatch: pytest fixture (pauses A after its first context read).
    """
    async with get_sessionmaker()() as s:
        harvest = await _event(
            s, world, EventType.HARVEST, "2026-02-14", {"quantity": {"value": 1350, "unit": "kg"}}
        )
        await service.check_lot(s, world.lot)
        [hold] = await _flags(s, world.lot, "yield_over_ceiling")
        await _correct(s, world, harvest, {"quantity": {"value": 1150, "unit": "kg"}})
    read, _ = _pause_first(monkeypatch, "_lot_context", 0.5)
    task = asyncio.create_task(_check_lot_alone(world.lot))
    await read.wait()

    async def review() -> None:
        """Resolve the hold as the FPO admin in its own session and commit."""
        async with get_sessionmaker()() as r:
            admin = CurrentUser(world.admin, world.fpo, Role.FPO_ADMIN)
            body = FlagResolveIn(resolution="fixed", reason_code="land_record_checked")
            await service.resolve_flag(r, admin, hold.id, body)
            await r.commit()

    checked, reviewed = await asyncio.gather(task, review(), return_exceptions=True)
    assert checked is None and isinstance(reviewed, FlagNotOpenError)
    async with get_sessionmaker()() as s:
        [flag] = await _flags(s, world.lot, "yield_over_ceiling")
        assert (flag.status, flag.resolution_reason_code) == (FlagStatus.FIXED, "rule_passed")


async def test_stale_event_check_cannot_close_a_fresh_photo_flag(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    """B19-r1 P2-2: two `check_event` runs of one event (one per photo) cannot close each other's flag.

    Run A reads the event while its photo is `uploaded` and pauses up to 2 s; session B marks the photo
    `checksum_mismatch`, commits and runs `check_event` (`photo_checksum_mismatch` warn). With the event lock
    B's run waits for A, so the flag must end open.

    Args:
        world: the seeded FPO.
        monkeypatch: pytest fixture (pauses A after its first context read).
    """
    async with get_sessionmaker()() as s:
        event_id = await _event(s, world, EventType.SOWING, "2025-10-20")
        event = await s.get(Event, event_id)
        assert event is not None
        photo = EvidencePhoto(
            id=uuid7(),
            event_version_id=event.current_version_id,
            bucket="evidence",
            object_key=f"test/{uuid.uuid4()}.webp",
            content_type="image/webp",
            size_bytes=1000,
            sha256_client="0" * 64,
            status=PhotoStatus.UPLOADED,
        )
        s.add(photo)
        await s.commit()
    read, committed = _pause_first(monkeypatch, "_event_context", 2)

    async def run_a() -> None:
        """Run `rules.check_event` in its own session, as the worker does."""
        async with get_sessionmaker()() as a:
            await service.check_event(a, event_id)

    task = asyncio.create_task(run_a())
    await read.wait()
    async with get_sessionmaker()() as b:
        stored = await b.get(EvidencePhoto, photo.id)
        assert stored is not None
        stored.status = PhotoStatus.CHECKSUM_MISMATCH
        await b.commit()
        await service.check_event(b, event_id)
    committed.set()
    await task
    async with get_sessionmaker()() as s:
        [flag] = await _flags(s, event_id, "photo_checksum_mismatch")
        assert (flag.status, flag.resolution_reason_code) == (FlagStatus.OPEN, None)


@pytest.mark.parametrize("case", CASES["gi_check"]["cases"], ids=lambda c: c["name"])
async def test_gi_check_shared_case(migrated: None, case: dict[str, Any]) -> None:
    """The phone's GI preview cases give the same status (and distance) through PostGIS `locate_point`.

    Args:
        migrated: the migrated database (fixture).
        case: one `gi_check` case of tests/fixtures/rule_cases.json.
    """
    geometry = case.get("geometry") or CASES["gi_check"]["region"]["geometry"]
    async with get_sessionmaker()() as s:
        tag = GiTag(gi_number=f"T{secrets.token_hex(4)}", name="fixture")
        s.add(tag)
        await s.flush()
        s.add(_region(tag.id, geometry, case["buffer_m"]))
        await s.commit()
        result = await registry_service.locate_point(s, GeoPoint(lat=case["lat"], lon=case["lon"]), tag.id)
    assert result.status == case["status"]
    if "distance_m" in case:
        assert result.distance_m == pytest.approx(case["distance_m"], abs=case["tolerance_m"])
    if "min_distance_m" in case:
        assert result.distance_m > case["min_distance_m"]


@pytest.fixture
async def http(world: World) -> AsyncIterator[tuple[AsyncClient, dict[str, CurrentUser]]]:
    """HTTP client whose caller can be switched between the world's officer and admin.

    Args:
        world: the seeded FPO.

    Returns:
        An async iterator yielding the client and a one-key dict holding the current caller.
    """
    from agritrace.main import create_app

    caller = {"user": CurrentUser(world.officer, world.fpo, Role.FIELD_OFFICER)}
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: caller["user"]
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c, caller


async def test_resolve_over_http_and_sync(
    world: World, http: tuple[AsyncClient, dict[str, CurrentUser]]
) -> None:
    """Officer: hold → 403, warn without reason → 422, warn → 200; push → accepted, duplicate.

    Args:
        world: the seeded FPO.
        http: client and switchable caller.
    """
    client, caller = http
    async with get_sessionmaker()() as s:
        await _event(s, world, EventType.HARVEST, "2026-02-14", {"quantity": {"value": 1350, "unit": "kg"}})
        organic = {"input_id": str(world.inputs[0]), "quantity": {"value": 25, "unit": "kg"}}
        await _event(s, world, EventType.INPUT_APPLICATION, "2025-12-05", organic)
        await service.check_lot(s, world.lot)
        [hold] = await _flags(s, world.lot, "yield_over_ceiling")
        [warn] = await _flags(s, world.lot, "practice_tag_contradiction")
        [ipm] = await _flags(s, world.lot, "ipm_without_pest_event")
    r = await client.get("/v1/flags", params={"severity": "hold"})
    assert [f["id"] for f in r.json()["items"]] == [str(hold.id)]
    reason = {"resolution": "looks_fine", "reason_code": "land_record_checked"}
    r = await client.post(f"/v1/flags/{hold.id}/resolve", json=reason)
    assert (r.status_code, r.json()["error"]["code"]) == (403, "resolution_forbidden")
    r = await client.post(f"/v1/flags/{warn.id}/resolve", json={"resolution": "fixed"})
    assert (r.status_code, r.json()["error"]["code"]) == (422, "reason_required")
    r = await client.post(f"/v1/flags/{warn.id}/resolve", json={**reason, "resolution": "fixed"})
    assert (r.status_code, r.json()["status"]) == (200, "fixed")
    entry = {"client_id": str(uuid7()), "kind": "flag_resolution", "data": {"flag_id": str(ipm.id), **reason}}
    push = {
        "device_id": str(uuid.uuid4()),
        "app_version": "1.0.0",
        "device_time": NOW.isoformat(),
        "entries": [entry],
    }
    statuses = [
        (await client.post("/v1/sync/push", json=push)).json()["results"][0]["status"] for _ in range(2)
    ]
    assert statuses == ["accepted", "duplicate"]
