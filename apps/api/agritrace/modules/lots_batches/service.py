"""lots_batches service: lot lifecycle, processor intake, batch merge with shares, and the batch gates.

Gates (Dataflow §4): ready for sale (moisture at or under the profile's `lot_gates.ready_for_sale`),
intake (lot ready), batch merge (lots received at that processor; GI re-check, FR29), grading approval
(FR49: no `declared_above_computed`, no missing required reading), final packing (≤ graded kg), publish
(every earlier gate, second sign-off above `second_signoff_threshold_kg`, no open hold) → `page_builds` row
and `publishing.build_page`. Every gate re-runs the lot/batch rules now (`rules_flags.run_gate_checks`,
D-006: the server is the authority) and blocks on any active `hold` flag of the batch, its lots, their
plots, events or readings, except the GI-only holds in a batch without the GI label (D-041). This module
never writes `lots.gi_hold_reason` (B08 owns lot holds); GI problems
found at merge are recorded on the batch (`gi_block_reasons`).

Serves: PRD §5 (Component Lot, Super Lot / Batch), Dataflow Stages 4–9 and §4, FR9–FR11, FR29, FR30, FR49,
FR56, FR60, FR62, D-005, D-017 (`lot` fields, `second_signoff_threshold_kg`), D-040 (QC officer intake,
processor default, ready gate at intake), D-041 (GI-only holds in non-GI batches), backend-design.md §1–§3.
Callers: `lots_batches.router` (which commits); `publishing.service` and `publishing.router` use `reason`,
`get_batch` and `enqueue_page_build` (rebuild, QR, B10); `events.service` uses `create_intake_from_sync`
(push kind `lot_intake`, it commits).
Functions flush but never commit, except `_refuse`, which commits the refreshed flags before raising.
"""

import asyncio
import itertools
import logging
import uuid
from collections.abc import Callable, Mapping, Sequence
from datetime import date
from decimal import Decimal
from typing import Any

from geoalchemy2.shape import to_shape
from pydantic import ValidationError
from shapely.geometry import Point
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import InstrumentedAttribute

from agritrace.core import fieldconfig, ids, task_names
from agritrace.core.auth import CurrentUser
from agritrace.core.enums import (
    ApprovalStage,
    BatchStatus,
    EventStatus,
    EventType,
    GradeStatus,
    LocationStatus,
    LotStatus,
    ReadingStage,
    Role,
    Severity,
)
from agritrace.core.errors import (
    ClientIdConflictError,
    FieldRequiredError,
    ForbiddenError,
    GateNotMetError,
    GiRegionMissingError,
    NotFoundError,
    ValidationFailedError,
)
from agritrace.core.schemas import GeoPoint, Page, PracticeTags, Quantity, Reconciliation
from agritrace.core.time import utcnow
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.lots_batches import shares
from agritrace.modules.lots_batches.models import (
    Batch,
    BatchApproval,
    BatchShare,
    Lot,
    LotIntake,
    current_intake,
)
from agritrace.modules.lots_batches.schemas import (
    BatchIn,
    BatchOut,
    FlagBrief,
    GiBlockReason,
    IntakeIn,
    IntakeOut,
    LotIn,
    LotOut,
    ShareOut,
)
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.quality import service as quality_service
from agritrace.modules.quality.models import GradeComputation, QualityReading
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Crop, Farmer, Plot, Processor
from agritrace.modules.rules_flags import service as rules_service
from agritrace.modules.rules_flags.models import Flag

__all__ = ["create_intake_from_sync", "enqueue_page_build", "get_batch", "reason"]

log = logging.getLogger(__name__)

LIVE_EVENTS = (EventStatus.SUBMITTED, EventStatus.LOCKED)
INTAKE_ROLES = (Role.QC_OFFICER, Role.FPO_ADMIN)

# DECISION D-041: in a batch without the GI label these two hold codes do not block approve, final packing
#   or publish; they stay open and each approval row records them. Every other hold blocks (fail closed).
#   ADV: FR29's non-GI trace path exists; the hold stays visible; an unclassified hold still blocks.
#   COMPROMISE: a two-code list in code: a new GI-only rule must be added here on purpose (a unit test ties
#     it to the rules' `CODES`); a lot over the yield ceiling can reach a non-GI page while under review.
GI_ONLY_HOLD_CODES = frozenset({"plot_outside_gi_region", "yield_over_ceiling"})


# --- small pure helpers (unit-tested) ------------------------------------------------------------------


def reason(code: str, message: str, **extra: Any) -> dict[str, Any]:
    """Build one unmet-gate reason for `details.reasons`.

    Args:
        code: snake_case reason code, e.g. `declared_above_computed`.
        message: English explanation (apps show their own text per code).
        **extra: context such as ids or quantities; values are made JSON-safe with `str` for UUIDs/Decimals.

    Returns:
        `{"code", "message", **extra}`.
    """
    safe = {k: str(v) if isinstance(v, uuid.UUID | Decimal) else v for k, v in extra.items()}
    return {"code": code, "message": message, **safe}


def _blocks(flag: Flag, gi_label_requested: bool) -> bool:
    """Tell whether an active flag blocks a batch gate (D-041).

    Args:
        flag: an active flag from `run_gate_checks`.
        gi_label_requested: the batch's GI label request.

    Returns:
        True for a hold, unless its code is in `GI_ONLY_HOLD_CODES` and the batch has no GI label request.
    """
    return flag.severity == Severity.HOLD and (gi_label_requested or flag.rule_code not in GI_ONLY_HOLD_CODES)


def hold_reasons(flags: Sequence[Flag], gi_label_requested: bool) -> list[dict[str, Any]]:
    """Turn the blocking hold flags of a gate check into unmet-gate reasons.

    Args:
        flags: active flags from `run_gate_checks` (batch, lots, plots, events, readings).
        gi_label_requested: the batch's GI label request; when False, holds coded in `GI_ONLY_HOLD_CODES`
            do not block (D-041).

    Returns:
        One `open_hold_flag` reason per blocking hold, naming the rule and the flagged row; plot holds such
        as `plot_outside_gi_region` are included in a GI-requested batch (B08 P3: they do not change the
        lot's `gi_eligible`).
    """
    return [
        reason(
            "open_hold_flag",
            "A hold flag must be resolved first (GET /v1/flags).",
            flag_id=f.id,
            rule_code=f.rule_code,
            subject_type=str(f.subject_type),
            subject_id=f.subject_id,
        )
        for f in flags
        if _blocks(f, gi_label_requested)
    ]


def reconcile(
    harvested: Decimal | None, packed: Decimal | None, received: Decimal | None, used: Decimal | None = None
) -> Reconciliation:
    """Build a lot's quantity chain, harvested ≥ packed ≥ received ≥ used (FR60).

    Args:
        harvested: harvested kg, or None when not recorded.
        packed: on-farm packed kg, or None.
        received: kg received by the processor, or None.
        used: kg used in batches, or None.

    Returns:
        The chain in kg; `in_order` is True when every recorded step is ≤ the recorded one before it
        (missing steps are skipped). B08 raises the `quantity_mismatch` flag; this is the stored snapshot.
    """
    chain = [v for v in (harvested, packed, received, used) if v is not None]

    def kg(v: Decimal | None) -> Quantity | None:
        """Wrap kilograms as a Quantity.

        Args:
            v: kilograms or None.

        Returns:
            The quantity, or None.
        """
        return Quantity(value=v, unit="kg") if v is not None else None

    return Reconciliation(
        harvested=kg(harvested),
        packed=kg(packed),
        received=kg(received),
        used=kg(used),
        in_order=all(a >= b for a, b in itertools.pairwise(chain)),
    )


def _kg(value: Decimal | None) -> Quantity | None:
    """Render a stored kilogram column as a Quantity (FR58).

    Args:
        value: kilograms or None.

    Returns:
        `{value, unit: "kg"}`, or None.
    """
    return Quantity(value=value, unit="kg") if value is not None else None


def flag_briefs(flags: Sequence[Flag]) -> list[FlagBrief]:
    """Render gate-check flags for a response.

    Args:
        flags: active flags.

    Returns:
        Their brief form.
    """
    return [FlagBrief.model_validate(f, from_attributes=True) for f in flags]


def lot_out(lot: Lot) -> LotOut:
    """Render a lot for the API.

    Args:
        lot: the lot row.

    Returns:
        The response model with quantities in kg.
    """
    return LotOut(
        id=lot.id,
        code=lot.code,
        farmer_id=lot.farmer_id,
        plot_id=lot.plot_id,
        crop_id=lot.crop_id,
        season_label=lot.season_label,
        status=lot.status,
        practice_tags=PracticeTags.model_validate(lot.practice_tags) if lot.practice_tags else None,
        harvested=_kg(lot.harvested_kg),
        packed=_kg(lot.packed_kg),
        ready_at=lot.ready_at,
        gi_eligible=lot.gi_eligible,
        gi_hold_reason=lot.gi_hold_reason,
    )


def intake_out(intake: LotIntake, flags: Sequence[Flag] = ()) -> IntakeOut:
    """Render an intake for the API.

    Args:
        intake: the intake row.
        flags: active flags found by this request's gate check.

    Returns:
        The response model.
    """
    return IntakeOut(
        id=intake.id,
        lot_id=intake.lot_id,
        processor_id=intake.processor_id,
        sale_date=intake.sale_date,
        received=Quantity(value=intake.received_kg, unit="kg"),
        price_per_kg=intake.price_per_kg,
        intake_moisture_reading_id=intake.intake_moisture_reading_id,
        accepted_by_user_id=intake.accepted_by_user_id,
        reconciliation=Reconciliation.model_validate(intake.reconciliation)
        if intake.reconciliation
        else None,
        supersedes_intake_id=intake.supersedes_intake_id,
        correction_reason=intake.correction_reason,
        flags=flag_briefs(flags),
    )


# --- shared database helpers ---------------------------------------------------------------------------


async def _refuse(session: AsyncSession, reasons: list[dict[str, Any]]) -> None:
    """Raise the gate error when any reason is unmet.

    Args:
        session: database session.
        reasons: unmet reasons, possibly empty.

    Raises:
        GateNotMetError: `gate_not_met` (409) with `details.reasons` = every reason, when any.

    Side effects:
        Commits before raising, so what the gate has already refreshed stays visible: flags from
        `run_gate_checks` (B08) in `/v1/flags`, and on publish the GI re-check (`gi_verified`,
        `gi_block_reasons`). The change the gate guards (state, approval, build) has not been made yet.
    """
    # DECISION D-033: every lifecycle gate answers one code, 409 `gate_not_met`, listing ALL unmet reasons.
    #   ADV: the portal greys a button and shows every reason at once (P04); one registered code, the
    #     reason codes are data, so a new gate condition is not an API change (D-020).
    #   COMPROMISE: clients switch on `details.reasons[].code`, which OpenAPI does not enumerate; the codes
    #     are listed in docs/adr/D-033.md and the route descriptions.
    if reasons:
        await session.commit()
        raise GateNotMetError(details={"reasons": reasons})


async def _unused_code(
    session: AsyncSession, column: InstrumentedAttribute[Any], make: Callable[[], str]
) -> str:
    """Draw codes until one is not used yet (lot `LOT…`, batch, super-lot).

    Args:
        session: database session.
        column: the UNIQUE code column.
        make: code generator from `core.ids`.

    Returns:
        A code no row holds at the time of the check.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: check-then-insert; two writers drawing the same code in the same instant get a 500 from the
    #   UNIQUE index (32 random bits, ~1 % at 10,000 lots). Retry on IntegrityError if that is ever seen.
    code = make()
    while await session.scalar(select(func.count()).where(column == code)):
        code = make()
    return code


async def _lot_in_scope(
    session: AsyncSession, user: CurrentUser, lot_id: uuid.UUID, lock: bool = False
) -> Lot:
    """Load a lot the caller may see: same FPO; a farmer only their own.

    Args:
        session: database session.
        user: the caller.
        lot_id: the lot.
        lock: take a row lock (`SELECT … FOR UPDATE`) until the transaction ends, before a status check
            that a concurrent request could race.

    Returns:
        The lot.

    Raises:
        NotFoundError: no such lot in the caller's FPO, or another farmer's lot (404).
    """
    lot = await session.get(Lot, lot_id, with_for_update=lock)
    if lot is None or lot.fpo_id != user.fpo_id:
        raise NotFoundError(details={"lot_id": str(lot_id)})
    if user.role == Role.FARMER:
        owner = await session.scalar(select(Farmer.user_id).where(Farmer.id == lot.farmer_id))
        if owner != user.user_id:
            raise NotFoundError(details={"lot_id": str(lot_id)})
    return lot


async def _batch_in_scope(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> Batch:
    """Load a batch of the caller's FPO (routes already keep farmers out).

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.

    Returns:
        The batch.

    Raises:
        NotFoundError: no such batch in the caller's FPO (404).
    """
    batch = await session.get(Batch, batch_id)
    if batch is None or batch.fpo_id != user.fpo_id:
        raise NotFoundError(details={"batch_id": str(batch_id)})
    return batch


async def _page(
    session: AsyncSession, query: Any, id_column: Any, cursor: uuid.UUID | None, limit: int
) -> tuple[list[Any], str | None, bool]:
    """Run a keyset page ordered by id (docs/api/conventions.md).

    Args:
        session: database session.
        query: select of one entity, already scoped.
        id_column: the entity's id column.
        cursor: last id of the previous page, or None.
        limit: page size.

    Returns:
        `(rows, next_cursor, has_more)`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    if cursor is not None:
        query = query.where(id_column > cursor)
    rows = list((await session.scalars(query.order_by(id_column).limit(limit + 1))).all())
    more = len(rows) > limit
    rows = rows[:limit]
    return rows, str(rows[-1].id) if more else None, more


def _approval(batch: Batch, stage: ApprovalStage, user: CurrentUser, flags: Sequence[Flag]) -> BatchApproval:
    """Record a human decision at a batch gate (Dataflow §4); the table is append-only (D-033).

    Args:
        batch: the batch.
        stage: the gate.
        user: the approving admin.
        flags: active flags at the time; every one that did not block is kept as approved-over (warns,
            infos and, in a batch without the GI label, the GI-only holds, D-041).

    Returns:
        The new (unflushed) approval row.
    """
    pending = sorted({f.rule_code for f in flags if not _blocks(f, batch.gi_label_requested)})
    return BatchApproval(
        batch_id=batch.id,
        stage=stage,
        approved_by=user.user_id,
        approved_at=utcnow(),
        blocked_reasons=pending or None,
    )


async def _needs_second_signoff(session: AsyncSession, batch: Batch) -> bool:
    """Tell whether a batch is above the FPO's second sign-off threshold (D-017 feature flag).

    Args:
        session: database session.
        batch: the batch.

    Returns:
        True when `total_received_kg` exceeds `second_signoff_threshold_kg` for the batch's FPO.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: judged against today's threshold, not the one in force at creation; store a flag on the
    #   batch if tenants start changing the threshold mid-season.
    features = fieldconfig.features_for(await registry_service.fpo_code(session, batch.fpo_id))
    return (batch.total_received_kg or 0) > features.second_signoff_threshold_kg


async def batch_out(session: AsyncSession, batch: Batch, flags: Sequence[Flag] = ()) -> BatchOut:
    """Render a batch with its shares for the API.

    Args:
        session: database session.
        batch: the batch row.
        flags: active flags found by this request's gate check.

    Returns:
        The response model.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    rows = (await session.scalars(select(BatchShare).where(BatchShare.batch_id == batch.id))).all()
    return BatchOut(
        id=batch.id,
        code=batch.code,
        superlot_code=batch.superlot_code,
        crop_id=batch.crop_id,
        processor_id=batch.processor_id,
        status=batch.status,
        gi_label_requested=batch.gi_label_requested,
        gi_verified=batch.gi_verified,
        gi_block_reasons=[GiBlockReason.model_validate(r) for r in batch.gi_block_reasons or []],
        total_received=_kg(batch.total_received_kg),
        graded=_kg(batch.graded_kg),
        packed=_kg(batch.packed_kg),
        computed_grade=batch.computed_grade,
        standards_profile_version_id=batch.standards_profile_version_id,
        pack_date=batch.pack_date,
        best_before_date=batch.best_before_date,
        current_build_no=batch.current_build_no,
        created_by=batch.created_by,
        second_signoff_required=await _needs_second_signoff(session, batch),
        second_signoff_by=batch.second_signoff_by,
        shares=[
            ShareOut(
                lot_id=s.lot_id,
                farmer_id=s.farmer_id,
                contributed=Quantity(value=s.kg_contributed, unit="kg"),
                share_pct=s.share_pct,
            )
            for s in sorted(rows, key=lambda s: -s.share_pct)
        ],
        flags=flag_briefs(flags),
    )


# --- lots ----------------------------------------------------------------------------------------------


async def create_lot(session: AsyncSession, user: CurrentUser, data: LotIn) -> tuple[Lot, bool]:
    """Open a season lot on a plot (Stage 4); resending the same `client_id` returns the stored lot (D-005).

    Args:
        session: database session.
        user: the caller (farmer for their own plot; field officer or FPO admin for the FPO's plots).
        data: the lot.

    Returns:
        `(lot, created)`; `created` is False for a resend.

    Raises:
        ClientIdConflictError: the id belongs to another FPO's lot or to a lot on another plot (409).
        FieldRequiredError: a field the tenant requires is missing (`field_required`, 422).
        NotFoundError: plot or crop not found in the caller's scope, or a farmer resending another
            farmer's lot id (404).

    Side effects:
        Adds the lot (status `open`, GI-eligible until a hold) and flushes; audit row on flush.
    """
    existing = await session.get(Lot, data.client_id)
    if existing is not None:
        if existing.fpo_id != user.fpo_id or existing.plot_id != data.plot_id:
            raise ClientIdConflictError(details={"client_id": str(data.client_id)})
        return await _lot_in_scope(session, user, existing.id), False
    # DECISION D-017: the tenant's `fields/lot.yaml` decides which lot fields are required or dropped.
    #   ADV: an FPO that does not track seasons or practice tags turns them off without a deployment.
    #   COMPROMISE: `season_label` is NOT NULL in the table, so a tenant without seasons stores "".
    fields = fieldconfig.validate_payload(
        "lot", await registry_service.fpo_code(session, user.fpo_id), data.model_dump(mode="json")
    )
    plot = await session.get(Plot, data.plot_id)
    if plot is None or plot.fpo_id != user.fpo_id:
        raise NotFoundError(details={"plot_id": str(data.plot_id)})
    if user.role == Role.FARMER:
        owner = await session.scalar(select(Farmer.user_id).where(Farmer.id == plot.farmer_id))
        if owner != user.user_id:
            raise NotFoundError(details={"plot_id": str(data.plot_id)})
    if await session.get(Crop, data.crop_id) is None:
        raise NotFoundError(details={"crop_id": str(data.crop_id)})
    lot = Lot(
        id=data.client_id,
        fpo_id=user.fpo_id,
        farmer_id=plot.farmer_id,
        plot_id=plot.id,
        crop_id=data.crop_id,
        season_label=fields.get("season_label") or "",
        code=await _unused_code(session, Lot.code, ids.lot_code),
        status=LotStatus.OPEN,
        practice_tags=PracticeTags(declared=fields.get("practice_tags_declared") or []).model_dump(
            mode="json"
        ),
        # Eligible until a hold says otherwise: B08 sets it false on a hold flag, and the batch merge
        # re-checks the plot against the GI region anyway (FR29).
        gi_eligible=True,
    )
    session.add(lot)
    await session.flush()
    return lot, True


async def list_lots(
    session: AsyncSession,
    user: CurrentUser,
    status: LotStatus | None,
    farmer_id: uuid.UUID | None,
    cursor: uuid.UUID | None,
    limit: int,
) -> Page[LotOut]:
    """List the caller's lots (farmer) or the FPO's lots (other roles), e.g. ready lots for a batch (P03).

    Args:
        session: database session.
        user: the caller.
        status: only lots in this state, when given.
        farmer_id: only this farmer's lots, when given.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of lots, oldest id first.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(Lot).where(Lot.fpo_id == user.fpo_id)
    if user.role == Role.FARMER:
        query = query.join(Farmer, Farmer.id == Lot.farmer_id).where(Farmer.user_id == user.user_id)
    if status is not None:
        query = query.where(Lot.status == status)
    if farmer_id is not None:
        query = query.where(Lot.farmer_id == farmer_id)
    rows, next_cursor, more = await _page(session, query, Lot.id, cursor, limit)
    return Page[LotOut](items=[lot_out(r) for r in rows], next_cursor=next_cursor, has_more=more)


async def get_lot(session: AsyncSession, user: CurrentUser, lot_id: uuid.UUID) -> Lot:
    """Read one lot in the caller's scope.

    Args:
        session: database session.
        user: the caller.
        lot_id: the lot.

    Returns:
        The lot.

    Raises:
        NotFoundError: not in the caller's scope (404).
    """
    return await _lot_in_scope(session, user, lot_id)


async def mark_ready(session: AsyncSession, user: CurrentUser, lot_id: uuid.UUID) -> Lot:
    """Mark a lot ready for sale once its drying-end moisture meets the profile gate (Stage 5, 3a gate).

    Args:
        session: database session.
        user: the caller (the farmer, a field officer or an admin).
        lot_id: the lot.

    Returns:
        The lot, now `ready_for_sale` (unchanged when it already was).

    Raises:
        NotFoundError: not in the caller's scope (404).
        GateNotMetError: `gate_not_met` (409) with reason `lot_status` (already sold or batched) or
            `moisture_gate_failed` (latest drying-end moisture missing or above the limit, e.g. 11.5 > 11.0).

    Side effects:
        Sets `status` and `ready_at`; flushes.
    """
    lot = await _lot_in_scope(session, user, lot_id)
    if lot.status == LotStatus.READY_FOR_SALE:
        return lot
    reasons = []
    if lot.status not in (LotStatus.OPEN, LotStatus.DRYING):
        reasons.append(
            reason("lot_status", "Only an open or drying lot can be marked ready.", status=lot.status)
        )
    elif not await quality_service.lot_gate_passes(session, lot.id):
        reasons.append(
            reason(
                "moisture_gate_failed",
                "The latest drying-end moisture reading is missing or above the ready-for-sale limit.",
                gate="ready_for_sale",
            )
        )
    await _refuse(session, reasons)
    lot.status, lot.ready_at = LotStatus.READY_FOR_SALE, utcnow()
    await session.flush()
    return lot


# --- intake --------------------------------------------------------------------------------------------


async def _farm_kg(session: AsyncSession, lot_id: uuid.UUID) -> dict[EventType, Decimal]:
    """Sum the kg quantities of a lot's live harvest and packing events.

    Args:
        session: database session.
        lot_id: the lot.

    Returns:
        Kilograms by event type; a type without any kg quantity is absent.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = (
        select(Event.event_type, EventVersion.payload)
        .join(EventVersion, EventVersion.id == Event.current_version_id)
        .where(
            Event.lot_id == lot_id,
            Event.event_type.in_([EventType.HARVEST, EventType.PACKING]),
            Event.status.in_(LIVE_EVENTS),
        )
    )
    out: dict[EventType, Decimal] = {}
    for event_type, payload in (await session.execute(query)).tuples():
        q = payload.get("quantity") or {}
        # shortcut: only kg counts (the payloads document kg); same rule as rules_flags `_kg`.
        if q.get("unit") == "kg":
            out[event_type] = out.get(event_type, Decimal(0)) + Decimal(str(q["value"]))
    return out


async def create_intake(
    session: AsyncSession, user: CurrentUser, data: IntakeIn
) -> tuple[LotIntake, list[Flag], bool]:
    """Record a processor receiving a ready lot, or correct its intake, and run the lot rules now.

    Serves Stage 7, FR9, FR60, FR11, D-040. A correction (`supersedes_intake_id` + `correction_reason`) adds
    a new row that replaces the lot's current intake (D-033: append-only, corrections add rows); it is
    refused once the lot is in a batch. A first intake of an `open` or `drying` lot runs the ready gate
    (`mark_ready`) in the same transaction, after every other check.

    Args:
        session: database session.
        user: the accepting QC officer or FPO admin (a correction: FPO admin only).
        data: the intake; without `processor_id` the FPO's only own processor is used.

    Returns:
        `(intake, active flags on the lot, created)`; a resend returns the stored intake, no flags, False.

    Raises:
        ForbiddenError: `forbidden` (403): the caller is not a QC officer or FPO admin, or a QC officer sends
            a correction.
        FieldRequiredError: `field_required` (422, `details.field` = `processor_id`): no `processor_id` and
            the FPO has zero or several own processors.
        ClientIdConflictError: the id belongs to another FPO's intake or to an intake of another lot (409).
        NotFoundError: lot, processor, superseded intake or intake moisture reading (parameter `moisture`,
            stage `intake`, on this lot) not found (404).
        GateNotMetError: `gate_not_met` (409): `moisture_gate_failed` (first intake of an open/drying lot
            whose latest drying-end moisture is missing or above the limit), `lot_not_ready` (first intake of
            a lot in any other state but `ready_for_sale`), `lot_already_batched` (correction after batching),
            `intake_not_current` (the intake to correct was already corrected, or the lot is not `received`).

    Side effects:
        Locks the lot row (`SELECT … FOR UPDATE`) so a double submit cannot record two intakes; may set the
        lot `ready_for_sale` with `ready_at` (ready gate); fills `lots.harvested_kg` / `packed_kg` from the
        lot's events, sets the lot `received`, inserts the intake with its reconciliation snapshot, flushes,
        then `run_gate_checks` (B08).
    """
    if user.role not in INTAKE_ROLES:
        raise ForbiddenError(details={"required_roles": [str(r) for r in INTAKE_ROLES]})
    if data.supersedes_intake_id is not None and user.role != Role.FPO_ADMIN:
        raise ForbiddenError(
            "Only an FPO admin can correct an intake.", {"required_roles": [str(Role.FPO_ADMIN)]}
        )
    existing = await session.get(LotIntake, data.client_id)
    if existing is not None:
        if existing.fpo_id != user.fpo_id or existing.lot_id != data.lot_id:
            raise ClientIdConflictError(details={"client_id": str(data.client_id)})
        return existing, [], False
    lot = await _lot_in_scope(session, user, data.lot_id, lock=True)
    if data.processor_id is None:
        # DECISION D-040: an intake without `processor_id` goes to the FPO's only own processor.
        #   ADV: the QC phone sends no processor and needs no picker while an FPO has one processor.
        #   COMPROMISE: an FPO with zero or several own processors gets `field_required` until QC mode has a
        #     processor picker (TODO.md); shared processors (`fpo_id` null) are never picked by default.
        own = (await session.scalars(select(Processor).where(Processor.fpo_id == user.fpo_id).limit(2))).all()
        if len(own) != 1:
            raise FieldRequiredError(details={"field": "processor_id", "entity": "lot_intake"})
        processor = own[0]
    else:
        named = await session.get(Processor, data.processor_id)
        if named is None or named.fpo_id not in (None, user.fpo_id):
            raise NotFoundError(details={"processor_id": str(data.processor_id)})
        processor = named
    if data.intake_moisture_reading_id is not None:
        reading = await session.get(QualityReading, data.intake_moisture_reading_id)
        if reading is None or (reading.lot_id, reading.parameter_code, reading.stage) != (
            lot.id,
            "moisture",
            ReadingStage.INTAKE,
        ):
            raise NotFoundError(details={"intake_moisture_reading_id": str(data.intake_moisture_reading_id)})
    if data.supersedes_intake_id is not None:
        prior = await session.get(LotIntake, data.supersedes_intake_id)
        if prior is None or prior.fpo_id != user.fpo_id or prior.lot_id != lot.id:
            raise NotFoundError(details={"supersedes_intake_id": str(data.supersedes_intake_id)})
        if lot.status == LotStatus.BATCHED:
            # Shares are append-only and already printed: the ops procedure in docs/adr/D-033.md applies.
            msg = "The lot is already in a batch; void the batch and re-create it (D-033)."
            await _refuse(session, [reason("lot_already_batched", msg)])
        newer = await session.scalar(select(func.count()).where(LotIntake.supersedes_intake_id == prior.id))
        if newer or lot.status != LotStatus.RECEIVED:
            msg = "Only the lot's current intake can be corrected."
            await _refuse(session, [reason("intake_not_current", msg, status=lot.status)])
    elif lot.status in (LotStatus.OPEN, LotStatus.DRYING):
        # DECISION D-040: the first intake of an open or drying lot runs the ready gate here.
        #   ADV: no phone calls POST /v1/lots/{id}/ready, so a phone intake would always be `lot_not_ready`;
        #     the same moisture gate runs at the moment it matters (D-006: the server decides).
        #   COMPROMISE: the server shows a packed lot as `open` until it is received.
        await mark_ready(session, user, lot.id)
    elif lot.status != LotStatus.READY_FOR_SALE:
        # shortcut: one intake per lot; a lot sold to two processors needs partial-sale support (product).
        await _refuse(session, [reason("lot_not_ready", "The lot is not ready for sale.", status=lot.status)])
    farm = await _farm_kg(session, lot.id)
    lot.harvested_kg = farm.get(EventType.HARVEST, lot.harvested_kg)
    lot.packed_kg = farm.get(EventType.PACKING, lot.packed_kg)
    lot.status = LotStatus.RECEIVED
    received = data.received.value
    intake = LotIntake(
        id=data.client_id,
        fpo_id=user.fpo_id,
        lot_id=lot.id,
        processor_id=processor.id,
        sale_date=data.sale_date,
        received_kg=received,
        # shortcut: tenant requiredness of `price_per_kg` (lot.yaml, stage intake) is not enforced here;
        #   wire fieldconfig when a tenant makes it required.
        price_per_kg=data.price_per_kg,
        intake_moisture_reading_id=data.intake_moisture_reading_id,
        accepted_by_user_id=user.user_id,
        reconciliation=reconcile(lot.harvested_kg, lot.packed_kg, received).model_dump(mode="json"),
        supersedes_intake_id=data.supersedes_intake_id,
        correction_reason=data.correction_reason,
    )
    session.add(intake)
    await session.flush()
    flags = await rules_service.run_gate_checks(session, lot_id=lot.id)
    return intake, flags, True


async def create_intake_from_sync(
    session: AsyncSession, user: CurrentUser, data: Mapping[str, Any]
) -> tuple[LotIntake, list[Flag], bool]:
    """Record an intake from the raw `data` of a sync push `lot_intake` entry (D-040).

    Events may not import `schemas` (D-004); same pattern as `registry.service.create_plot_from_sync`.

    Args:
        session: database session.
        user: the caller (QC officer or FPO admin).
        data: the entry data, shaped like `IntakeIn` (with `client_id` = the entry's client id).

    Returns:
        Same as `create_intake`.

    Raises:
        ValidationFailedError: the data does not match `IntakeIn` (`validation_error`, 422, with details).
        AppError: every error of `create_intake` (`forbidden`, `field_required`, `client_id_conflict`,
            `not_found`, `gate_not_met`).

    Side effects:
        Same as `create_intake`; the caller commits.
    """
    try:
        body = IntakeIn.model_validate(data)
    except ValidationError as e:
        details = [{"loc": err["loc"], "msg": err["msg"], "type": err["type"]} for err in e.errors()]
        raise ValidationFailedError(details=details) from e
    return await create_intake(session, user, body)


# --- batches -------------------------------------------------------------------------------------------


async def _gi_check(session: AsyncSession, batch: Batch, lots: Sequence[Lot], flags: Sequence[Flag]) -> None:
    """Re-validate GI for every component lot and store the verdict on the batch (FR29, FR30).

    A lot passes when it is GI-eligible (no B08 hold), its plot's location is `confirmed` and the plot pin
    is not outside today's region version; any active hold flag in scope (lot, plot, events, readings,
    batch) also blocks.

    Args:
        session: database session.
        batch: the batch; nothing is checked unless `gi_label_requested`.
        lots: its component lots.
        flags: active flags from `run_gate_checks` on the batch.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets `batch.gi_verified` and `batch.gi_block_reasons`.
    """
    found: list[GiBlockReason] = []
    crop = await session.get(Crop, batch.crop_id)
    gi_tag_id = crop.gi_tag_id if crop else None
    if not batch.gi_label_requested:
        pass
    elif gi_tag_id is None:
        found.append(GiBlockReason(reason="crop_has_no_gi_tag"))
    else:
        for lot in lots:
            if not lot.gi_eligible:
                found.append(GiBlockReason(lot_id=lot.id, reason="lot_on_hold", detail=lot.gi_hold_reason))
            plot = await session.get(Plot, lot.plot_id)
            assert plot is not None  # foreign key
            if plot.location_status != LocationStatus.CONFIRMED:
                found.append(GiBlockReason(lot_id=lot.id, reason=f"plot_location_{plot.location_status}"))
                continue
            pin = to_shape(plot.pin)
            assert isinstance(pin, Point)  # geography(POINT)
            try:
                where = await registry_service.locate_point(
                    session, GeoPoint(lat=pin.y, lon=pin.x), gi_tag_id
                )
            except GiRegionMissingError:
                found.append(GiBlockReason(reason="gi_region_missing"))
                break
            if where.status == "outside":
                found.append(
                    GiBlockReason(
                        lot_id=lot.id, reason="plot_outside_gi_region", detail=f"{where.distance_m:.0f} m"
                    )
                )
        found += [
            GiBlockReason(reason="hold_flag", detail=f.rule_code)
            for f in flags
            if f.severity == Severity.HOLD
        ]
    batch.gi_verified = batch.gi_label_requested and not found
    batch.gi_block_reasons = [r.model_dump(mode="json") for r in found]


async def _batch_lots(session: AsyncSession, batch: Batch) -> list[Lot]:
    """Load a batch's component lots.

    Args:
        session: database session.
        batch: the batch.

    Returns:
        The lots with a share in it.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(Lot).join(BatchShare, BatchShare.lot_id == Lot.id).where(BatchShare.batch_id == batch.id)
    return list((await session.scalars(query)).all())


async def create_batch(
    session: AsyncSession, user: CurrentUser, data: BatchIn
) -> tuple[Batch, list[Flag], bool]:
    """Merge received lots into a batch with shares, re-check GI and run the rules (Stage 7, FR9, FR29, FR60).

    Args:
        session: database session.
        user: the FPO admin (the first sign-off).
        data: client id, processor, GI request and the lots.

    Returns:
        `(batch, active flags on the batch and its lots, created)`; resending the same `client_id` returns
        the stored batch, no flags, False (D-005).

    Raises:
        ClientIdConflictError: the id belongs to another FPO's batch or one at another processor (409).
        NotFoundError: a lot or the processor not found in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) listing `lot_not_received` (wrong state),
            `lot_not_received_by_processor` (no intake at this processor), `mixed_crops`, `lot_quantity_zero`.

    Side effects:
        Locks the lot rows (`SELECT … FOR UPDATE`, in id order) so two concurrent merges cannot both batch a
        lot; inserts the batch (id = `client_id`, new batch and super-lot codes), its shares (sum exactly
        100.000 %) from the lots' current intakes and an `intake` approval; sets the lots `batched`; flushes;
        `run_gate_checks` on the batch; sets the GI verdict.
    """
    existing = await session.get(Batch, data.client_id)
    if existing is not None:
        if existing.fpo_id != user.fpo_id or existing.processor_id != data.processor_id:
            raise ClientIdConflictError(details={"client_id": str(data.client_id)})
        return existing, [], False
    wanted = data.lot_ids
    query = select(Lot).where(Lot.id.in_(wanted), Lot.fpo_id == user.fpo_id).order_by(Lot.id)
    found = (await session.scalars(query.with_for_update())).all()
    lots = {lot.id: lot for lot in found}
    if missing := [str(i) for i in wanted if i not in lots]:
        raise NotFoundError(details={"lot_ids": missing})
    processor = await session.get(Processor, data.processor_id)
    if processor is None or processor.fpo_id not in (None, user.fpo_id):
        raise NotFoundError(details={"processor_id": str(data.processor_id)})
    delivered: dict[uuid.UUID, Decimal] = dict(
        (
            await session.execute(
                select(LotIntake.lot_id, func.sum(LotIntake.received_kg))
                .where(LotIntake.lot_id.in_(wanted), LotIntake.processor_id == processor.id, current_intake())
                .group_by(LotIntake.lot_id)
            )
        )
        .tuples()
        .all()
    )
    reasons = []
    for lot in lots.values():
        if lot.status != LotStatus.RECEIVED:
            reasons.append(
                reason(
                    "lot_not_received",
                    "The lot has no intake yet or is already batched.",
                    lot_id=lot.id,
                    status=lot.status,
                )
            )
        elif lot.id not in delivered:
            reasons.append(
                reason(
                    "lot_not_received_by_processor",
                    "The lot was received by another processor.",
                    lot_id=lot.id,
                )
            )
    if len({lot.crop_id for lot in lots.values()}) > 1:
        reasons.append(reason("mixed_crops", "Every lot of a batch must be the same crop."))
    await _refuse(session, reasons)

    # Architect-Gate 2026-10-31 §1: shares and the batch total come from the same intakes, so B15's
    #   `batch_quantity_unattributed` (Σ shares vs received) compares like with like.
    kg = {lot_id: delivered[lot_id] for lot_id in wanted}
    if zero := [str(i) for i, v in kg.items() if v <= 0]:
        await _refuse(
            session, [reason("lot_quantity_zero", "Each lot must contribute more than 0 kg.", lot_ids=zero)]
        )
    pct = shares.split(kg)
    batch = Batch(
        id=data.client_id,
        fpo_id=user.fpo_id,
        crop_id=lots[wanted[0]].crop_id,
        processor_id=processor.id,
        code=await _unused_code(session, Batch.code, ids.batch_code),
        superlot_code=await _unused_code(session, Batch.superlot_code, ids.superlot_code),
        status=BatchStatus.CREATED,
        gi_label_requested=data.gi_label_requested,
        total_received_kg=sum(kg.values(), Decimal(0)),
        created_by=user.user_id,
    )
    session.add(batch)
    await session.flush()
    for lot_id, value in kg.items():
        session.add(
            BatchShare(
                batch_id=batch.id,
                lot_id=lot_id,
                kg_contributed=value,
                share_pct=pct[lot_id],
                farmer_id=lots[lot_id].farmer_id,
            )
        )
        lots[lot_id].status = LotStatus.BATCHED
    await session.flush()
    flags = await rules_service.run_gate_checks(session, batch_id=batch.id)
    session.add(_approval(batch, ApprovalStage.INTAKE, user, flags))
    await _gi_check(session, batch, list(lots.values()), flags)
    await session.flush()
    return batch, flags, True


async def list_batches(
    session: AsyncSession, user: CurrentUser, status: BatchStatus | None, cursor: uuid.UUID | None, limit: int
) -> Page[BatchOut]:
    """List the FPO's batches.

    Args:
        session: database session.
        user: the caller.
        status: only batches in this state, when given.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of batches, oldest id first.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(Batch).where(Batch.fpo_id == user.fpo_id)
    if status is not None:
        query = query.where(Batch.status == status)
    rows, next_cursor, more = await _page(session, query, Batch.id, cursor, limit)
    items = [await batch_out(session, b) for b in rows]
    return Page[BatchOut](items=items, next_cursor=next_cursor, has_more=more)


async def get_batch(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> Batch:
    """Read one batch of the caller's FPO.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.

    Returns:
        The batch.

    Raises:
        NotFoundError: not in the caller's FPO (404).
    """
    return await _batch_in_scope(session, user, batch_id)


async def second_signoff(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> Batch:
    """Record the second admin sign-off a batch above the threshold needs (Dataflow §4 gate 2).

    Args:
        session: database session.
        user: an FPO admin other than the batch's creator.
        batch_id: the batch.

    Returns:
        The batch (unchanged when already signed off).

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409), reason `same_approver` when the creator signs again.

    Side effects:
        Sets `second_signoff_by` and adds an `intake` approval; flushes.
    """
    batch = await _batch_in_scope(session, user, batch_id)
    if batch.second_signoff_by is not None:
        return batch
    if user.user_id == batch.created_by:
        await _refuse(session, [reason("same_approver", "The second sign-off must come from another admin.")])
    batch.second_signoff_by = user.user_id
    session.add(_approval(batch, ApprovalStage.INTAKE, user, ()))
    await session.flush()
    return batch


async def approve_grading(
    session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID, graded_kg: Decimal
) -> tuple[Batch, list[Flag]]:
    """Approve the batch's latest grade computation (Stage 8, FR48, FR49).

    Args:
        session: database session.
        user: the approving FPO admin.
        batch_id: the batch.
        graded_kg: graded quantity in kg, the ceiling for final packing.

    Returns:
        `(batch, active flags)`; the batch is now `graded`.

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) listing every unmet reason: `batch_status` (already
            approved), `not_graded`, `grade_incomplete` (required reading missing),
            `declared_above_computed`, `open_hold_flag`.

    Side effects:
        `run_gate_checks` on the batch; on success sets status, graded kg, grade and profile version and
        adds a `grading` approval; flushes.
    """
    batch = await _batch_in_scope(session, user, batch_id)
    # shortcut: approves the latest stored computation instead of re-running the engine (that would record
    #   the admin as `declared_by`); readings added after grading need a new POST /grading by QC first.
    grade = await session.scalar(
        select(GradeComputation)
        .where(GradeComputation.batch_id == batch.id)
        .order_by(GradeComputation.computed_at.desc())
        .limit(1)
    )
    flags = await rules_service.run_gate_checks(session, batch_id=batch.id)
    reasons = []
    if batch.status != BatchStatus.CREATED:
        reasons.append(reason("batch_status", "Grading is already approved.", status=batch.status))
    if grade is None:
        reasons.append(reason("not_graded", "No grade computed yet (POST /v1/batches/{id}/grading)."))
    elif grade.status == GradeStatus.INCOMPLETE:
        missing = sorted(
            c for c, p in (grade.per_parameter or {}).items() if (p or {}).get("outcome") == "missing"
        )
        reasons.append(
            reason("grade_incomplete", "A required quality reading is missing.", parameters=missing)
        )
    elif grade.status == GradeStatus.DECLARED_ABOVE_COMPUTED:
        reasons.append(
            reason(
                "declared_above_computed",
                "The declared grade is above the computed one: correct the readings, re-test or lower it.",
                declared=grade.declared_grade,
                computed=grade.computed_grade,
            )
        )
    await _refuse(session, reasons + hold_reasons(flags, batch.gi_label_requested))
    assert grade is not None  # no reasons implies a computation
    batch.status, batch.graded_kg = BatchStatus.GRADED, graded_kg
    batch.computed_grade, batch.standards_profile_version_id = grade.computed_grade, grade.profile_version_id
    session.add(_approval(batch, ApprovalStage.GRADING, user, flags))
    await session.flush()
    return batch, flags


async def final_packing(
    session: AsyncSession,
    user: CurrentUser,
    batch_id: uuid.UUID,
    packed_kg: Decimal,
    pack_date: date,
    best_before_date: date,
) -> tuple[Batch, list[Flag]]:
    """Sign off final (retail) packing, never more than was graded (Stage 9, FR62).

    Args:
        session: database session.
        user: the approving FPO admin.
        batch_id: the batch.
        packed_kg: kilograms in final packs.
        pack_date: pack date.
        best_before_date: best-before date, not before `pack_date`.

    Returns:
        `(batch, active flags)`; the batch is now `packed`.

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) listing `grading_not_approved`, `packed_above_graded`
            (e.g. 25 kg on 20 kg graded), `open_hold_flag`.

    Side effects:
        `run_gate_checks`; on success sets packed kg, dates and status and adds a `final_packing` approval.
    """
    batch = await _batch_in_scope(session, user, batch_id)
    flags = await rules_service.run_gate_checks(session, batch_id=batch.id)
    reasons = []
    if batch.status != BatchStatus.GRADED:
        reasons.append(
            reason(
                "grading_not_approved", "Final packing needs an approved grading, once.", status=batch.status
            )
        )
    elif packed_kg > (batch.graded_kg or 0):
        reasons.append(
            reason(
                "packed_above_graded",
                "Packed quantity is above the graded quantity.",
                packed_kg=packed_kg,
                graded_kg=batch.graded_kg,
            )
        )
    await _refuse(session, reasons + hold_reasons(flags, batch.gi_label_requested))
    batch.packed_kg, batch.pack_date, batch.best_before_date = packed_kg, pack_date, best_before_date
    batch.status = BatchStatus.PACKED
    session.add(_approval(batch, ApprovalStage.FINAL_PACKING, user, flags))
    await session.flush()
    return batch, flags


async def publish(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> PageBuild:
    """Final sign-off: publish the batch's public page once every gate is met (Stage 9 → 10, D-007).

    Args:
        session: database session.
        user: the approving FPO admin.
        batch_id: the batch.

    Returns:
        The queued `page_builds` row (flushed).

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) listing every unmet reason: `already_published`,
            `grading_not_approved`, `final_packing_missing`, `second_signoff_missing`, `open_hold_flag`.

    Side effects:
        `run_gate_checks` and the GI re-check (GI is never a publish blocker: a blocked batch is published
        without the GI badge, FR29); on success status `published`, `current_build_no` + 1, a `publish`
        approval and a `page_builds` row (status `queued`, trigger `publish`); flushes.
    """
    batch = await _batch_in_scope(session, user, batch_id)
    flags = await rules_service.run_gate_checks(session, batch_id=batch.id)
    await _gi_check(session, batch, await _batch_lots(session, batch), flags)
    reasons = []
    if batch.status == BatchStatus.PUBLISHED:
        reasons.append(reason("already_published", "Already published; use POST /v1/batches/{id}/rebuild."))
    if batch.status == BatchStatus.CREATED:
        reasons.append(reason("grading_not_approved", "The grading has not been approved."))
    if batch.status in (BatchStatus.CREATED, BatchStatus.GRADED):
        reasons.append(reason("final_packing_missing", "Final packing has not been signed off."))
    if batch.second_signoff_by is None and await _needs_second_signoff(session, batch):
        reasons.append(reason("second_signoff_missing", "A second admin must sign off this batch."))
    await _refuse(session, reasons + hold_reasons(flags, batch.gi_label_requested))
    batch.status, batch.current_build_no = BatchStatus.PUBLISHED, batch.current_build_no + 1
    build = PageBuild(
        batch_id=batch.id,
        build_no=batch.current_build_no,
        generation=batch.current_build_no,
        snapshot={},  # the build task (B10) writes the privacy-filtered snapshot it renders
        status="queued",
        trigger="publish",
    )
    session.add_all([build, _approval(batch, ApprovalStage.PUBLISH, user, flags)])
    await session.flush()
    return build


async def enqueue_page_build(build: PageBuild) -> None:
    """Ask the worker to build the public page (`publishing.build_page`, B10) after the commit.

    Args:
        build: the committed `page_builds` row.

    Side effects:
        Publishes one Celery message by task name (D-004) with kwargs `{batch_id, page_build_id, build_no}`.
        A broker failure is logged, not raised: the row stays `queued` and `POST /v1/batches/{id}/rebuild`
        (B10) can retry.
    """
    from agritrace.worker import app as celery_app  # late: importing the worker reads the settings

    kwargs = {"batch_id": str(build.batch_id), "page_build_id": str(build.id), "build_no": build.build_no}
    try:
        await asyncio.to_thread(celery_app.send_task, task_names.PUBLISHING_BUILD_PAGE, kwargs=kwargs)
    except Exception:  # noqa: BLE001 - see Side effects
        log.warning(
            "could not enqueue %s for build %s", task_names.PUBLISHING_BUILD_PAGE, build.id, exc_info=True
        )
