"""rules_flags service: load facts, run the server rules, store deduplicated flags, and resolve flags.

Checks (`check_event`, `check_plot`, `check_lot`) run in the worker after sync push, photo verification, plot
onboarding and quality readings; `run_gate_checks` runs the lot/batch rules synchronously for B09's gates.
Every stored flag has `dedupe_key = rule_code:subject_id:hash(discriminator)`, so a re-check updates the open
flag instead of adding one; an open flag a later run no longer raises is closed as `fixed` / `rule_passed`.
A `hold` on a lot sets `lots.gi_eligible = false` with the reason until the hold is resolved.
Serves: Arch §Rules and flags, FR11, FR28, FR50, FR53, FR55–FR57, FR60, FR61, FR67–FR70, PRD §12.2,
Dataflow Stages 0–8, D-006 (server rules are the authority), D-009 (tasks), D-004.
Callers: rules_flags router (list, get, resolve) and tasks (checks); other modules through `__all__` only:
events sync push (B06, `resolve_from_sync`), lots_batches gates (B09, `run_gate_checks`).
tests/unit/test_rules_service.py, tests/integration/test_rules.py.
"""

import hashlib
import logging
import uuid
from collections.abc import Iterable, Sequence
from decimal import Decimal
from typing import Any

from geoalchemy2.shape import to_shape
from pydantic import ValidationError
from shapely.geometry import Point
from sqlalchemy import ColumnElement, Numeric, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, assert_same_fpo
from agritrace.core.enums import EventStatus, EventType, FlagStatus, FlagSubject, Role, Severity
from agritrace.core.errors import (
    FlagNotOpenError,
    ForbiddenError,
    NotFoundError,
    ReasonRequiredError,
    ResolutionForbiddenError,
    ValidationFailedError,
)
from agritrace.core.fieldconfig import features_for
from agritrace.core.schemas import GeoPoint, Page
from agritrace.core.time import utcnow
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot, LotIntake, current_intake
from agritrace.modules.quality import service as quality_service
from agritrace.modules.quality.models import GradeComputation, QualityReading
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Crop, Farmer, GiRegionVersion, InputMaster, Plot, Village
from agritrace.modules.rules_flags import rules
from agritrace.modules.rules_flags.models import Flag
from agritrace.modules.rules_flags.rules.context import (
    BatchContext,
    EventContext,
    FlagCandidate,
    LotContext,
    LotEvent,
    PhotoFacts,
    PlotContext,
    ReadingFacts,
)
from agritrace.modules.rules_flags.rules.event_location import PIN_RADIUS_M
from agritrace.modules.rules_flags.rules.practice_tags import derived_tags
from agritrace.modules.rules_flags.schemas import FlagOut, FlagResolutionEntry, FlagResolveIn

__all__ = ["resolve_from_sync", "run_gate_checks"]

log = logging.getLogger(__name__)

ACTIVE = (FlagStatus.OPEN, FlagStatus.ESCALATED)  # still needs a reviewer; an active hold blocks GI
RESOLUTION_STATUS = {
    "looks_fine": FlagStatus.CLEARED,
    "fixed": FlagStatus.FIXED,
    "escalated": FlagStatus.ESCALATED,
}
RESOLVERS = (Role.FIELD_OFFICER, Role.FPO_ADMIN)
DEAD_EVENTS = (EventStatus.UNDONE, EventStatus.SUPERSEDED)
RULE_PASSED = "rule_passed"
DEFAULT_BUFFER_M = 50.0  # plots without a GI tag or region still get some GPS-drift allowance (FR32)
ADMIN_RULES = {"practice_tag_contradiction"}  # FR56: contradictions go to the FPO Admin whatever the severity
SEVERITY_RANK = {Severity.INFO: 0, Severity.WARN: 1, Severity.HOLD: 2}
HOLD_PREFIX = "flags: "  # marks a gi_hold_reason this module set, so it never clears one B09 set


# --- storing flags --------------------------------------------------------------------------------------


def dedupe_key(candidate: FlagCandidate) -> str:
    """Build the key that makes re-running a rule idempotent.

    Args:
        candidate: the finding.

    Returns:
        `rule_code:subject_id:<12 hex of sha256(discriminator)>`.
    """
    digest = hashlib.sha256(candidate.discriminator.encode()).hexdigest()[:12]
    return f"{candidate.rule_code}:{candidate.subject_id}:{digest}"


def assignee(severity: Severity, rule_code: str) -> Role:
    """Pick the role that reviews a flag (FR70).

    Args:
        severity: the flag's severity.
        rule_code: the rule that raised it.

    Returns:
        `fpo_admin` for a hold (it keeps a lot out of GI batches) and for practice-tag contradictions (FR56
        "flagged for the FPO Admin"), else `field_officer`.
    """
    # shortcut: the admin-reviewed rule list is code; make it configurable when B13 adds per-rule settings.
    admin = severity == Severity.HOLD or rule_code in ADMIN_RULES
    return Role.FPO_ADMIN if admin else Role.FIELD_OFFICER


def reopens(flag: Flag, candidate: FlagCandidate) -> bool:
    """Tell whether a closed flag must open again because its rule fired again.

    Args:
        flag: the stored flag, closed (cleared, fixed, or escalated-and-resolved).
        candidate: the new finding with the same `dedupe_key`.

    Returns:
        True when the system closed it (`rule_passed`: the problem is back), or when the new severity is
        higher than the one the reviewer closed (e.g. a looked-fine warn is now a hold). False when a
        reviewer closed it and the severity is the same or lower.
    """
    worse = SEVERITY_RANK[candidate.severity] > SEVERITY_RANK[flag.severity]
    return flag.resolution_reason_code == RULE_PASSED or worse


async def store_flags(
    session: AsyncSession,
    fpo_id: uuid.UUID,
    candidates: Sequence[FlagCandidate],
    subjects: Iterable[uuid.UUID],
    codes: Iterable[str],
) -> None:
    """Upsert the candidates as flags and close the active flags of this run's scope it no longer raised.

    Args:
        session: database session (flushed, not committed).
        fpo_id: owning FPO of every subject.
        candidates: what the rules found.
        subjects: every subject the run looked at.
        codes: every rule code the run's rules can raise.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts new flags; refreshes severity, details and (while open) the assignee of active ones; reopens
        closed ones per `reopens` (a reviewer's `looks_fine` at the same severity stays closed); sets active
        flags in scope that were not raised to `fixed` with reason `rule_passed` (escalated ones too).
        All through the ORM, so `audit_log` rows are written.
    """
    by_key = {dedupe_key(c): c for c in candidates}
    found = select(Flag).where(Flag.dedupe_key.in_(list(by_key))) if by_key else None
    existing = {f.dedupe_key: f for f in (await session.scalars(found)).all()} if found is not None else {}
    now = utcnow()
    for key, c in by_key.items():
        flag = existing.get(key)
        if flag is None:
            flag = Flag(
                fpo_id=fpo_id,
                subject_type=c.subject_type,
                subject_id=c.subject_id,
                rule_code=c.rule_code,
                severity=c.severity,
                details=c.details,
                dedupe_key=key,
                status=FlagStatus.OPEN,
                assigned_role=assignee(c.severity, c.rule_code),
                raised_at=now,
            )
            try:
                async with session.begin_nested():
                    session.add(flag)
            except IntegrityError:
                # D-009 allows a task to run twice at once; the other run inserted the same key first.
                log.info("flag %s already inserted by a concurrent check", key)
        elif flag.status in ACTIVE:
            flag.severity, flag.details = c.severity, c.details
            if flag.status == FlagStatus.OPEN:
                flag.assigned_role = assignee(c.severity, c.rule_code)
        elif reopens(flag, c):
            flag.status, flag.severity, flag.details = FlagStatus.OPEN, c.severity, c.details
            flag.assigned_role, flag.raised_at = assignee(c.severity, c.rule_code), now
            flag.resolved_by = flag.resolved_at = flag.resolution_reason_code = flag.resolution_note = None
    stale = select(Flag).where(
        Flag.subject_id.in_(set(subjects)),
        Flag.rule_code.in_(set(codes)),
        Flag.status.in_(ACTIVE),
        Flag.dedupe_key.not_in(list(by_key)),
    )
    for flag in (await session.scalars(stale)).all():
        flag.status, flag.resolution_reason_code, flag.resolved_at = FlagStatus.FIXED, RULE_PASSED, now
    await session.flush()


async def _sync_lot_hold(session: AsyncSession, lot: Lot) -> None:
    """Keep `lots.gi_eligible` in step with the lot's active hold flags (FR68, FR70).

    Args:
        session: database session (autoflush makes pending flag changes visible to the query).
        lot: the lot.

    Side effects:
        As `apply_hold` with the lot's active hold codes.
    """
    query = select(Flag.rule_code).where(
        Flag.subject_id == lot.id, Flag.severity == Severity.HOLD, Flag.status.in_(ACTIVE)
    )
    apply_hold(lot, sorted(set((await session.scalars(query)).all())))


def apply_hold(lot: Lot, holds: Sequence[str]) -> None:
    """Set a lot's GI eligibility from the rule codes of its active holds, leaving other modules' holds alone.

    Args:
        lot: the lot.
        holds: rule codes of its active hold flags (sorted), possibly empty.

    Side effects:
        With holds: `gi_eligible = false`, and `gi_hold_reason = "flags: <codes>"` unless another module (B09)
        owns the reason, which is kept. Without holds: only a reason this module set is cleared, and then
        `gi_eligible` is restored.
    """
    ours = lot.gi_hold_reason is None or lot.gi_hold_reason.startswith(HOLD_PREFIX)
    if holds:
        lot.gi_eligible = False
        if ours:
            lot.gi_hold_reason = HOLD_PREFIX + ", ".join(holds)
    elif ours and lot.gi_hold_reason is not None:
        lot.gi_eligible, lot.gi_hold_reason = True, None


async def _active(session: AsyncSession, subjects: Iterable[uuid.UUID]) -> list[Flag]:
    """Load the active flags of some subjects.

    Args:
        session: database session.
        subjects: subject ids.

    Returns:
        Open or escalated flags on them, newest first.
    """
    query = select(Flag).where(Flag.subject_id.in_(set(subjects)), Flag.status.in_(ACTIVE))
    return list((await session.scalars(query.order_by(Flag.id.desc()))).all())


# --- loading facts --------------------------------------------------------------------------------------


def _point(value: Any) -> GeoPoint | None:
    """Read a stored geography(POINT).

    Args:
        value: the column value, or None.

    Returns:
        The point, or None when nothing was stored.
    """
    if value is None:
        return None
    shape = to_shape(value)
    assert isinstance(shape, Point)  # the columns are geography(POINT)
    return GeoPoint(lat=shape.y, lon=shape.x)


async def _region(session: AsyncSession, gi_tag_id: uuid.UUID | None) -> GiRegionVersion | None:
    """Find the GI tag's region version effective today (same choice as `registry.geo.locate_point`).

    Args:
        session: database session.
        gi_tag_id: the plot's GI tag, or None.

    Returns:
        The latest effective version, or None.
    """
    if gi_tag_id is None:
        return None
    query = (
        select(GiRegionVersion)
        .where(GiRegionVersion.gi_tag_id == gi_tag_id, GiRegionVersion.effective_from <= func.current_date())
        .order_by(GiRegionVersion.version_no.desc())
        .limit(1)
    )
    return await session.scalar(query)


async def _overrides(session: AsyncSession, where: ColumnElement[bool]) -> tuple[ReadingFacts, ...]:
    """Load the readings accepted with a reason code (trail overrides) of a lot or batch.

    Args:
        session: database session.
        where: `QualityReading.lot_id == …` or `QualityReading.batch_id == …`.

    Returns:
        Their facts, oldest first.
    """
    query = select(QualityReading).where(where, QualityReading.reason_code.is_not(None))
    rows = (await session.scalars(query.order_by(QualityReading.measured_at))).all()
    return tuple(
        ReadingFacts(r.id, r.parameter_code, str(r.stage), r.value, r.reason_code or "") for r in rows
    )


async def _event_context(session: AsyncSession, event: Event, version: EventVersion) -> EventContext:
    """Collect the facts of one event version, including the PostGIS on-plot test (FR69).

    Args:
        session: database session.
        event: the event.
        version: its current version.

    Returns:
        The event context.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    point, on_plot, buffer_m = _point(version.gps), None, DEFAULT_BUFFER_M
    plot = await session.get(Plot, event.plot_id) if event.plot_id else None
    if point is not None and plot is not None:
        region = await _region(session, plot.gi_tag_id)
        buffer_m = float(region.tolerance_buffer_m) if region else DEFAULT_BUFFER_M
        on_plot = await registry_service.event_within_plot(session, point, plot.id, PIN_RADIUS_M, buffer_m)
    query = select(EvidencePhoto).where(EvidencePhoto.event_version_id == version.id)
    photos = (await session.scalars(query)).all()
    return EventContext(
        event_id=event.id,
        occurred_on=version.occurred_on,
        occurred_end_on=version.occurred_end_on,
        device_time=version.device_time,
        gps_time=version.gps_time,
        server_received_at=version.server_received_at,
        gps_accuracy_m=version.gps_accuracy_m,
        on_plot=on_plot,
        pin_radius_m=PIN_RADIUS_M,
        buffer_m=buffer_m,
        photos=tuple(PhotoFacts(p.id, p.status, p.exif_taken_at) for p in photos),
    )


def _kg(event_type: EventType) -> ColumnElement[Decimal | None]:
    """Sum, in SQL, the `quantity` of one event type's live payloads (for `_lot_context`'s aggregate query).

    Args:
        event_type: harvest or packing.

    Returns:
        A `sum(...) FILTER (...)` column: total kilograms, NULL when no such event carries a quantity in kg.
    """
    # shortcut: only unit `kg` counts (the payloads document kg); convert quintals once a form offers them.
    quantity = EventVersion.payload["quantity"]
    kg = quantity["value"].astext.cast(Numeric)
    return func.sum(kg).filter(Event.event_type == event_type, quantity["unit"].astext == "kg")


async def _lot_context(session: AsyncSession, lot: Lot) -> LotContext:
    """Collect a lot's events, inputs, quantities, yield rule and trail overrides.

    Args:
        session: database session.
        lot: the lot.

    Returns:
        The lot context.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    crop = await session.get(Crop, lot.crop_id)
    plot = await session.get(Plot, lot.plot_id)
    # Only the columns the lot rules read (kg sums in SQL): no ORM rows or payload JSON per event (B22).
    live = (Event.lot_id == lot.id, Event.status.not_in(DEAD_EVENTS))
    current = (EventVersion, EventVersion.id == Event.current_version_id)
    query = select(Event.id, Event.event_type, Event.occurred_on, EventVersion.payload["input_id"].astext)
    rows = (await session.execute(query.join(*current).where(*live))).all()
    sums = select(_kg(EventType.HARVEST), _kg(EventType.PACKING)).join(*current).where(*live)
    harvest_kg, packing_kg = (await session.execute(sums)).one()
    input_ids = {uuid.UUID(i) for _, t, _, i in rows if t == EventType.INPUT_APPLICATION and i}
    categories = (
        (await session.scalars(select(InputMaster.category).where(InputMaster.id.in_(input_ids)))).all()
        if input_ids
        else []
    )
    received = select(func.sum(LotIntake.received_kg)).where(LotIntake.lot_id == lot.id, current_intake())
    used = select(func.sum(BatchShare.kg_contributed)).where(BatchShare.lot_id == lot.id)
    rule = await quality_service.yield_params_for_crop(session, lot.crop_id)
    harvested = harvest_kg or lot.harvested_kg
    limits = (
        (
            Decimal(str(rule.ceiling_kg_per_acre)),
            Decimal(str(rule.warn_margin_pct)),
            Decimal(str(rule.hold_margin_pct)),
        )
        if rule
        else None
    )
    return LotContext(
        lot_id=lot.id,
        event_schema=crop.event_schema if crop else {},
        events=tuple(LotEvent(event_id, str(t), on) for event_id, t, on, _ in rows),
        declared_tags=tuple((lot.practice_tags or {}).get("declared") or ()),
        input_categories=tuple(str(c) for c in categories),
        has_pest_event=any(t == EventType.PROBLEM for _, t, _, _ in rows),
        harvested_kg=harvested,
        packed_kg=packing_kg or lot.packed_kg,
        received_kg=await session.scalar(received),
        used_kg=await session.scalar(used),
        declared_acres=plot.declared_area_acres if plot else None,
        yield_limits=limits,
        yield_outcome=(
            await quality_service.yield_outcome_for_crop(
                session, lot.crop_id, harvested, plot.declared_area_acres
            )
            if harvested is not None and plot is not None
            else None
        ),
        trail_overrides=await _overrides(session, QualityReading.lot_id == lot.id),
    )


async def _check_lot(session: AsyncSession, lot: Lot) -> set[uuid.UUID]:
    """Run the lot rules, store their flags, update the lot's practice tags and GI hold.

    Args:
        session: database session (flushed, not committed).
        lot: the lot.

    Returns:
        Every subject in the lot's scope (lot, its plot, its events, its readings), for `_active`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Flags as in `store_flags`; `lots.practice_tags` {declared, derived, contradiction}; `_sync_lot_hold`.
    """
    ctx = await _lot_context(session, lot)
    candidates = rules.run_all(rules.LOT_RULES, ctx)
    events = (await session.scalars(select(Event.id).where(Event.lot_id == lot.id))).all()
    readings = (await session.scalars(select(QualityReading.id).where(QualityReading.lot_id == lot.id))).all()
    subjects = {lot.id, *events, *readings}
    await store_flags(session, lot.fpo_id, candidates, subjects, rules.codes(rules.LOT_RULES))
    lot.practice_tags = {
        "declared": list(ctx.declared_tags),
        "derived": sorted(derived_tags(ctx.input_categories)),
        "contradiction": any(c.rule_code == "practice_tag_contradiction" for c in candidates),
    }
    await _sync_lot_hold(session, lot)
    return subjects | {lot.plot_id}


async def _check_batch(session: AsyncSession, batch: Batch) -> set[uuid.UUID]:
    """Run the batch rules (grading loss limit from the FPO's `features_for`, D-030) and store their flags.

    Args:
        session: database session (flushed, not committed).
        batch: the batch.

    Returns:
        The batch and its readings' ids.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    shares = select(func.sum(BatchShare.kg_contributed)).where(BatchShare.batch_id == batch.id)
    latest = (
        select(GradeComputation)
        .where(GradeComputation.batch_id == batch.id)
        .order_by(GradeComputation.computed_at.desc())
        .limit(1)
    )
    grade = await session.scalar(latest)
    per_parameter = grade.per_parameter if grade else {}
    ctx = BatchContext(
        batch_id=batch.id,
        shares_kg=await session.scalar(shares),
        batch_kg=batch.packed_kg or batch.graded_kg,
        received_kg=batch.total_received_kg,
        grading_loss_warn_pct=features_for(
            await registry_service.fpo_code(session, batch.fpo_id)
        ).grading_loss_warn_pct,
        profile_incomplete=tuple(
            code for code, r in per_parameter.items() if (r or {}).get("outcome") == "profile_incomplete"
        ),
        trail_overrides=await _overrides(session, QualityReading.batch_id == batch.id),
    )
    candidates = rules.run_all(rules.BATCH_RULES, ctx)
    query = select(QualityReading.id).where(QualityReading.batch_id == batch.id)
    subjects = {batch.id, *(await session.scalars(query)).all()}
    await store_flags(session, batch.fpo_id, candidates, subjects, rules.codes(rules.BATCH_RULES))
    return subjects


# --- checks (tasks and gates) ---------------------------------------------------------------------------


async def run_gate_checks(
    session: AsyncSession, lot_id: uuid.UUID | None = None, batch_id: uuid.UUID | None = None
) -> list[Flag]:
    """Re-run the lot and batch rules now and return what is still open, for B09's gates (Dataflow §4).

    Args:
        session: database session; flushed, not committed (the caller's transaction decides).
        lot_id: a lot to check.
        batch_id: a batch to check, with every lot that has a share in it.

    Returns:
        Active (open or escalated) flags on the checked lots, batch, their plots, events and readings;
        the caller decides which block (holds always do).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Locks the batch row, then each lot row in id order (`FOR NO KEY UPDATE`, until the caller's
        transaction ends) before reading its facts; then as `_check_lot` and `_check_batch`.
    """
    # Checks of one lot/batch run one at a time: `store_flags` closes what its run did not raise, so a run
    #   that read the facts before another check committed a flag would close that flag (B16-1). After the
    #   lock, READ COMMITTED reads see every check committed before it (`populate_existing`: cached rows too).
    #   `key_share` (FOR NO KEY UPDATE) still lets inserts that point at the row (events, intakes) through.
    # Lock order: (event →) batch → lots by id → flags; anything that writes a flag then a lot must lock the
    #   lot first (resolve_flag).
    subjects: set[uuid.UUID] = set()
    lot_ids = [lot_id] if lot_id else []
    batch = (
        await session.get(Batch, batch_id, with_for_update={"key_share": True}, populate_existing=True)
        if batch_id
        else None
    )
    if batch is not None:
        subjects |= await _check_batch(session, batch)
        query = select(BatchShare.lot_id).where(BatchShare.batch_id == batch.id)
        lot_ids += (await session.scalars(query)).all()
    for lid in sorted(set(lot_ids)):  # id order, as `create_batch` locks lots, so two checks cannot deadlock
        if (
            lot := await session.get(Lot, lid, with_for_update={"key_share": True}, populate_existing=True)
        ) is not None:
            subjects |= await _check_lot(session, lot)
    return await _active(session, subjects)


async def check_lot(
    session: AsyncSession,
    lot_id: uuid.UUID | None = None,
    batch_id: uuid.UUID | None = None,
    reading_id: uuid.UUID | None = None,
    hint: str | None = None,
) -> list[str]:
    """Task body of `rules.check_lot`: run the lot/batch rules and commit (sweeps trail overrides too).

    Args:
        session: database session (committed here).
        lot_id: the lot, if any.
        batch_id: the batch, if any.
        reading_id: the reading that triggered the check (logged; every override of the lot is swept).
        hint: why it was enqueued, e.g. `moisture_trail_override` (logged).

    Returns:
        Rule codes of the active flags in scope.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        As `run_gate_checks`, then commit.
    """
    log.info("check_lot lot=%s batch=%s reading=%s hint=%s", lot_id, batch_id, reading_id, hint)
    flags = await run_gate_checks(session, lot_id, batch_id)
    await session.commit()
    return sorted({f.rule_code for f in flags})


async def check_event(session: AsyncSession, event_id: uuid.UUID) -> list[str]:
    """Task body of `rules.check_event`: event rules, then the rules of its lot or batch; commit.

    Args:
        session: database session (committed here).
        event_id: the event (its current version is checked).

    Returns:
        Rule codes of the active flags in scope; empty when the event does not exist.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Locks the event row (`FOR NO KEY UPDATE`); flags of the event (closed when the event was undone),
        then `run_gate_checks` on its lot/batch.
    """
    # Runs of one event (one per verified photo) wait for each other, as `run_gate_checks` does per lot.
    event = await session.get(Event, event_id, with_for_update={"key_share": True})
    if event is None:
        log.warning("check_event: no event %s", event_id)
        return []
    version = await session.get(EventVersion, event.current_version_id) if event.current_version_id else None
    candidates: list[FlagCandidate] = []
    if version is not None and event.status not in DEAD_EVENTS:
        candidates = rules.run_all(rules.EVENT_RULES, await _event_context(session, event, version))
    await store_flags(session, event.fpo_id, candidates, {event.id}, rules.codes(rules.EVENT_RULES))
    flags = await run_gate_checks(session, event.lot_id, event.batch_id)
    flags += [f for f in await _active(session, {event.id}) if f not in flags]
    await session.commit()
    return sorted({f.rule_code for f in flags})


async def check_plot(session: AsyncSession, plot_id: uuid.UUID) -> list[str]:
    """Task body of `rules.check_plot`: the plot review reasons (FR28, FR53, FR64–FR67, FR70); commit.

    Args:
        session: database session (committed here).
        plot_id: the plot.

    Returns:
        Rule codes of the plot's active flags; empty when the plot does not exist.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Flags as in `store_flags`, then commit.
    """
    plot = await session.get(Plot, plot_id)
    if plot is None:
        log.warning("check_plot: no plot %s", plot_id)
        return []
    farmer = await session.get(Farmer, plot.farmer_id)
    village = await session.get(Village, farmer.village_id) if farmer and farmer.village_id else None
    region = await _region(session, plot.gi_tag_id)
    ctx = PlotContext(
        plot_id=plot.id,
        pin_method=plot.pin_method,
        location_status=plot.location_status,
        declared_acres=plot.declared_area_acres,
        review_outcome=plot.review_outcome,
        pin_accuracy_m=plot.pin_accuracy_m,
        walked_acres=plot.walked_area_acres,
        taluk=village.taluk if village else None,
        region_taluks=tuple(region.taluks) if region and region.taluks else None,
    )
    candidates = rules.run_all(rules.PLOT_RULES, ctx)
    await store_flags(session, plot.fpo_id, candidates, {plot.id}, rules.codes(rules.PLOT_RULES))
    flags = await _active(session, {plot.id})
    await session.commit()
    return sorted({f.rule_code for f in flags})


# --- flags API and resolution ---------------------------------------------------------------------------


def check_resolution(role: Role, flag: Flag, body: FlagResolveIn) -> None:
    """Decide whether a caller may resolve a flag this way (FR70).

    Args:
        role: the caller's role in the flag's FPO.
        flag: the flag.
        body: the requested outcome.

    Raises:
        ForbiddenError: the role is not field_officer or fpo_admin (403 `forbidden`).
        FlagNotOpenError: the flag is already cleared or fixed (409 `flag_not_open`).
        ResolutionForbiddenError: a field officer on a hold or an escalated flag (403 `resolution_forbidden`).
        ReasonRequiredError: no `reason_code` (422 `reason_required`).
    """
    if role not in RESOLVERS:
        raise ForbiddenError(details={"required_roles": [str(r) for r in RESOLVERS]})
    if flag.status not in ACTIVE:
        raise FlagNotOpenError(details={"status": str(flag.status)})
    if role != Role.FPO_ADMIN and (flag.severity == Severity.HOLD or flag.status == FlagStatus.ESCALATED):
        raise ResolutionForbiddenError(details={"severity": str(flag.severity), "status": str(flag.status)})
    if not (body.reason_code and body.reason_code.strip()):
        raise ReasonRequiredError(details={"field": "reason_code"})


async def _scoped_flag(session: AsyncSession, user: CurrentUser, flag_id: uuid.UUID) -> Flag:
    """Load a flag the caller may see.

    Args:
        session: database session.
        user: the caller (a super-admin sees every FPO).
        flag_id: the flag.

    Returns:
        The flag.

    Raises:
        NotFoundError: no such flag, or it belongs to another FPO (404 `not_found`).
    """
    flag = await session.get(Flag, flag_id)
    if flag is None:
        raise NotFoundError(details={"flag_id": str(flag_id)})
    if not user.is_super_admin:
        assert_same_fpo(user, flag.fpo_id)
    return flag


async def resolve_flag(
    session: AsyncSession, user: CurrentUser, flag_id: uuid.UUID, body: FlagResolveIn
) -> Flag:
    """Record a reviewer's outcome on a flag (FR70).

    Args:
        session: database session (flushed; the router or `resolve_from_sync` commits).
        user: the caller.
        flag_id: the flag.
        body: outcome, reason code and note.

    Returns:
        The updated flag.

    Raises:
        NotFoundError: unknown flag or another FPO's (404).
        ForbiddenError, FlagNotOpenError, ResolutionForbiddenError, ReasonRequiredError: from
            `check_resolution`.

    Side effects:
        A lot flag first locks the lot row (`FOR NO KEY UPDATE`, until the transaction ends) and re-reads
        the flag; sets status, resolver, reason, note and time (audited); `escalated` reassigns to fpo_admin;
        a lot flag re-syncs the lot's GI hold (`_sync_lot_hold`).
    """
    flag = await _scoped_flag(session, user, flag_id)
    # Lot row, then flag rows, as `run_gate_checks`: the reverse order deadlocks with a running check.
    lot = None
    if flag.subject_type == FlagSubject.LOT:
        lot = await session.get(
            Lot, flag.subject_id, with_for_update={"key_share": True}, populate_existing=True
        )
        await session.refresh(flag)  # a check may have closed it before we got the lock
    check_resolution(user.role, flag, body)
    flag.status = RESOLUTION_STATUS[body.resolution]
    flag.resolution_reason_code = (body.reason_code or "").strip()
    flag.resolution_note, flag.resolved_by, flag.resolved_at = body.note, user.user_id, utcnow()
    if flag.status == FlagStatus.ESCALATED:
        flag.assigned_role = Role.FPO_ADMIN
    if lot is not None:
        await _sync_lot_hold(session, lot)
    await session.flush()
    return flag


async def resolve_from_sync(
    session: AsyncSession, current_user: CurrentUser, data: dict[str, Any]
) -> tuple[uuid.UUID, bool]:
    """Resolve a flag from a `flag_resolution` sync push entry (backend-design §3), then commit.

    Args:
        session: database session (committed here, like every other push kind).
        current_user: the caller from the token (never from the body).
        data: the entry's `data`: `{flag_id, resolution, reason_code, note}`.

    Returns:
        (flag id, True when resolved now; False when this same resolution by this user was already stored,
        i.e. a retried push).

    Raises:
        ValidationFailedError: `data` does not match `FlagResolutionEntry` (422 `validation_error`).
        NotFoundError, ForbiddenError, FlagNotOpenError, ResolutionForbiddenError, ReasonRequiredError: from
            `resolve_flag`.

    Side effects:
        As `resolve_flag`, then commit.
    """
    try:
        entry = FlagResolutionEntry.model_validate(data)
    except ValidationError as e:
        details = [{"loc": x["loc"], "msg": x["msg"], "type": x["type"]} for x in e.errors()]
        raise ValidationFailedError(details=details) from e
    flag = await _scoped_flag(session, current_user, entry.flag_id)
    if (
        flag.status == RESOLUTION_STATUS[entry.resolution]
        and flag.resolved_by == current_user.user_id
        and flag.resolution_reason_code == (entry.reason_code or "").strip()
    ):
        return flag.id, False
    await resolve_flag(session, current_user, entry.flag_id, entry)
    await session.commit()
    return flag.id, True


async def list_flags(
    session: AsyncSession,
    user: CurrentUser,
    *,
    fpo_id: uuid.UUID | None,
    assigned_role: Role | None,
    status: FlagStatus | None,
    severity: Severity | None,
    cursor: uuid.UUID | None,
    limit: int,
) -> Page[FlagOut]:
    """List an FPO's flags, newest first, with optional filters.

    Args:
        session: database session.
        user: the caller.
        fpo_id: FPO to list; defaults to the caller's (another FPO only for a super-admin).
        assigned_role: only flags assigned to this role.
        status: only flags in this status.
        severity: only flags of this severity.
        cursor: id of the last flag of the previous page.
        limit: page size.

    Returns:
        One page of flags.

    Raises:
        NotFoundError: `fpo_id` is another FPO and the caller is not a super-admin (404).
    """
    fpo = fpo_id or user.fpo_id
    if not user.is_super_admin:
        assert_same_fpo(user, fpo)
    query = select(Flag).where(Flag.fpo_id == fpo)
    for column, value in (
        (Flag.assigned_role, assigned_role),
        (Flag.status, status),
        (Flag.severity, severity),
    ):
        if value is not None:
            query = query.where(column == value)
    if cursor is not None:
        query = query.where(Flag.id < cursor)
    rows = list((await session.scalars(query.order_by(Flag.id.desc()).limit(limit + 1))).all())
    more = len(rows) > limit
    items = [FlagOut.model_validate(r) for r in rows[:limit]]
    return Page[FlagOut](items=items, next_cursor=str(items[-1].id) if more else None, has_more=more)


async def get_flag(session: AsyncSession, user: CurrentUser, flag_id: uuid.UUID) -> FlagOut:
    """Read one flag.

    Args:
        session: database session.
        user: the caller.
        flag_id: the flag.

    Returns:
        The flag.

    Raises:
        NotFoundError: unknown flag or another FPO's (404).
    """
    return FlagOut.model_validate(await _scoped_flag(session, user, flag_id))
