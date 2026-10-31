"""lots_batches HTTP routes: lots, ready gate, intakes, batches and the grading / packing / publish gates.

Serves: Dataflow Stages 4–9 and §4 (approval gates), FR9–FR11, FR29, FR49, FR60, FR62, D-005 (client ids),
D-020 (/v1, additive), D-033 (gates answer 409 `gate_not_met` listing every reason), D-040 (intake by a QC
officer or FPO admin), D-041 (GI-only holds in non-GI batches), backend-design.md §1 lots_batches row.
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the mobile app (M07, M11)
and the portal (P03, P04) through the generated clients (D-003). The lot QR uses `publishing.service.qr_png`
(B10).
"""

import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Path, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import BatchStatus, LotStatus, Role
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.lots_batches import service
from agritrace.modules.lots_batches.schemas import (
    BatchIn,
    BatchOut,
    FinalPackingIn,
    GradingApproveIn,
    IntakeIn,
    IntakeOut,
    LotIn,
    LotOut,
    PublishOut,
)
from agritrace.modules.publishing import service as publishing_service

router = APIRouter(tags=["lots_batches"])

Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]
LotKeeper = Annotated[CurrentUser, Depends(require_role(Role.FARMER, Role.FIELD_OFFICER, Role.FPO_ADMIN))]
Staff = Annotated[
    CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER))
]
Admin = Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]
Receiver = Annotated[CurrentUser, Depends(require_role(Role.QC_OFFICER, Role.FPO_ADMIN))]
LotId = Annotated[uuid.UUID, Path(description="Lot id.")]
BatchId = Annotated[uuid.UUID, Path(description="Batch id.")]
Cursor = Annotated[
    uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
]
Limit = Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")]
GATE = "`gate_not_met`: `details.reasons[]` lists every unmet condition as `{code, message, ...}`: "


def _errors(**by_status: str) -> dict[int | str, dict[str, Any]]:
    """Document error responses of a route with the shared envelope.

    Args:
        **by_status: description per status, keyed `e<status>`.

    Returns:
        The `responses=` mapping for FastAPI.
    """
    return {int(k[1:]): {"model": ErrorEnvelope, "description": v} for k, v in by_status.items()}


@router.post(
    "/lots",
    response_model=LotOut,
    status_code=status.HTTP_201_CREATED,
    summary="Open a lot (idempotent on client_id)",
    description="Opens a season lot on a plot; fields per the tenant's `lot` field configuration (D-017).",
    responses={
        200: {"model": LotOut, "description": "The lot already existed with this client_id."},
        **_errors(
            e404="`not_found`: plot or crop.",
            e409="`client_id_conflict`.",
            e422="`field_required` or `validation_error`.",
        ),
    },
)
async def create_lot(body: LotIn, response: Response, session: Session, user: LotKeeper) -> LotOut:
    """Open a lot; a resend answers 200 with the stored lot.

    \f
    Args:
        body: the lot.
        response: used to answer 200 for a resend.
        session: database session.
        user: the caller.

    Returns:
        The lot.

    Raises:
        NotFoundError: plot or crop out of scope (404).
        ClientIdConflictError: id used by another FPO's lot or another plot's (409).
        FieldRequiredError: a required field is missing (422).

    Side effects:
        Commits the lot.
    """
    lot, created = await service.create_lot(session, user, body)
    await session.commit()
    if not created:
        response.status_code = status.HTTP_200_OK
    return service.lot_out(lot)


@router.get("/lots", response_model=Page[LotOut], summary="List lots")
async def list_lots(
    session: Session,
    user: AnyRole,
    lot_status: Annotated[
        LotStatus | None, Query(alias="status", description="Only lots in this state.")
    ] = None,
    farmer_id: Annotated[uuid.UUID | None, Query(description="Only this farmer's lots.")] = None,
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[LotOut]:
    """List lots: a farmer's own, or the FPO's for other roles (e.g. `?status=received` for P03).

    \f
    Args:
        session: database session.
        user: the caller.
        lot_status: state filter.
        farmer_id: farmer filter.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of lots.

    Raises:
        UnauthorizedError: no valid token (401).
    """
    return await service.list_lots(session, user, lot_status, farmer_id, cursor, limit)


@router.get(
    "/lots/{lot_id}", response_model=LotOut, summary="Read a lot", responses=_errors(e404="`not_found`.")
)
async def get_lot(lot_id: LotId, session: Session, user: AnyRole) -> LotOut:
    """Read one lot in the caller's scope.

    \f
    Args:
        lot_id: the lot.
        session: database session.
        user: the caller.

    Returns:
        The lot.

    Raises:
        NotFoundError: out of scope (404).
    """
    return service.lot_out(await service.get_lot(session, user, lot_id))


@router.get(
    "/lots/{lot_id}/qr",
    response_class=Response,
    summary="QR code of a lot",
    description="PNG encoding the lot code (e.g. `LOT0EF81415`) for the bag tag scanned at intake.",
    responses={
        200: {"content": {"image/png": {}}, "description": "The QR image."},
        **_errors(e404="`not_found`."),
    },
)
async def lot_qr(lot_id: LotId, session: Session, user: AnyRole) -> Response:
    """Return the lot QR image.

    \f
    Args:
        lot_id: the lot.
        session: database session.
        user: the caller.

    Returns:
        The PNG.

    Raises:
        NotFoundError: out of scope (404).
    """
    lot = await service.get_lot(session, user, lot_id)
    return Response(publishing_service.qr_png(lot.code), media_type="image/png")


@router.post(
    "/lots/{lot_id}/ready",
    response_model=LotOut,
    summary="Mark a lot ready for sale (moisture gate)",
    description="Passes when the latest drying-end moisture reading meets `lot_gates.ready_for_sale`.",
    responses=_errors(e404="`not_found`.", e409=GATE + "`lot_status`, `moisture_gate_failed`."),
)
async def mark_ready(lot_id: LotId, session: Session, user: LotKeeper) -> LotOut:
    """Mark a lot ready for sale.

    \f
    Args:
        lot_id: the lot.
        session: database session.
        user: the caller.

    Returns:
        The lot, `ready_for_sale`.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: moisture gate or lot state (409).

    Side effects:
        Commits the new state.
    """
    lot = await service.mark_ready(session, user, lot_id)
    await session.commit()
    return service.lot_out(lot)


@router.post(
    "/intakes",
    response_model=IntakeOut,
    status_code=status.HTTP_201_CREATED,
    summary="Receive a lot at the processor (idempotent on client_id)",
    description=(
        "Stage 7 intake of a lot by a QC officer or FPO admin (D-040; the QC phone sends the same body as "
        "push kind `lot_intake`). The lot is `ready_for_sale`, or `open`/`drying` and passes the ready gate "
        "here (latest drying-end moisture at or under the limit). Without `processor_id` the FPO's only own "
        "processor receives it. Runs the lot rules synchronously and returns the active "
        "flags (e.g. `quantity_mismatch` when 100 kg are received from a lot packed at 69 kg). To correct a "
        "wrong intake before the lot is batched (FPO admin only), send a new intake with "
        "`supersedes_intake_id` and `correction_reason`; the new row becomes the lot's current intake "
        "(D-033)."
    ),
    responses={
        200: {"model": IntakeOut, "description": "The intake already existed with this client_id."},
        **_errors(
            e403="`forbidden`: not a QC officer or FPO admin, or a correction by a QC officer.",
            e404="`not_found`: lot, processor, superseded intake or moisture reading.",
            e409="`client_id_conflict`, or "
            + GATE
            + "`moisture_gate_failed`, `lot_not_ready`, `lot_already_batched`, `intake_not_current`.",
            e422="`field_required` (`processor_id`: the FPO has zero or several own processors), "
            "`validation_error`.",
        ),
    },
)
async def create_intake(body: IntakeIn, response: Response, session: Session, user: Receiver) -> IntakeOut:
    """Record an intake; a resend answers 200 with the stored intake.

    \f
    Args:
        body: the intake.
        response: used to answer 200 for a resend.
        session: database session.
        user: the QC officer or FPO admin.

    Returns:
        The intake with its reconciliation and flags.

    Raises:
        ForbiddenError: a correction by a QC officer (403).
        FieldRequiredError: no `processor_id` and not exactly one own processor (422).
        NotFoundError: lot, processor or reading out of scope (404).
        ClientIdConflictError: id used by another FPO (409).
        GateNotMetError: lot not ready, moisture gate failed (409).

    Side effects:
        Commits the intake, the lot changes and the refreshed flags.
    """
    intake, flags, created = await service.create_intake(session, user, body)
    await session.commit()
    if not created:
        response.status_code = status.HTTP_200_OK
    return service.intake_out(intake, flags)


@router.post(
    "/batches",
    response_model=BatchOut,
    status_code=status.HTTP_201_CREATED,
    summary="Merge received lots into a batch (idempotent on client_id)",
    description=(
        "Creates the batch and super-lot codes and the lot shares (half-even to 3 dp, residual to the "
        "largest; sum 100.000). With `gi_label_requested` every lot is re-checked against the GI region "
        "(FR29): `gi_verified=false` with `gi_block_reasons` when any fails; the batch is still created."
    ),
    responses={
        200: {"model": BatchOut, "description": "The batch already existed with this client_id."},
        **_errors(
            e404="`not_found`: lot or processor.",
            e409="`client_id_conflict`, or "
            + GATE
            + "`lot_not_received`, `lot_not_received_by_processor`, `mixed_crops`, `lot_quantity_zero`.",
            e422="`validation_error` (repeated lot).",
        ),
    },
)
async def create_batch(body: BatchIn, response: Response, session: Session, user: Admin) -> BatchOut:
    """Create a batch; a resend answers 200 with the stored batch.

    \f
    Args:
        body: client id, processor, GI request and lot ids.
        response: used to answer 200 for a resend.
        session: database session.
        user: the FPO admin.

    Returns:
        The batch with shares, GI verdict and active flags.

    Raises:
        NotFoundError: lot or processor out of scope (404).
        ClientIdConflictError: id used by another FPO's batch or another processor's (409).
        GateNotMetError: a lot is not ready to merge (409).

    Side effects:
        Commits the batch, shares, approval, lot states and refreshed flags.
    """
    batch, flags, created = await service.create_batch(session, user, body)
    await session.commit()
    if not created:
        response.status_code = status.HTTP_200_OK
    return await service.batch_out(session, batch, flags)


@router.get("/batches", response_model=Page[BatchOut], summary="List batches")
async def list_batches(
    session: Session,
    user: Staff,
    batch_status: Annotated[
        BatchStatus | None, Query(alias="status", description="Only batches in this state.")
    ] = None,
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[BatchOut]:
    """List the FPO's batches.

    \f
    Args:
        session: database session.
        user: the caller (not farmers).
        batch_status: state filter.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of batches.

    Raises:
        ForbiddenError: a farmer (403).
    """
    return await service.list_batches(session, user, batch_status, cursor, limit)


@router.get(
    "/batches/{batch_id}",
    response_model=BatchOut,
    summary="Read a batch",
    responses=_errors(e404="`not_found`."),
)
async def get_batch(batch_id: BatchId, session: Session, user: Staff) -> BatchOut:
    """Read one batch.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the caller (not farmers).

    Returns:
        The batch.

    Raises:
        NotFoundError: out of scope (404).
        ForbiddenError: a farmer (403).
    """
    return await service.batch_out(session, await service.get_batch(session, user, batch_id))


@router.post(
    "/batches/{batch_id}/second-signoff",
    response_model=BatchOut,
    summary="Second admin sign-off of a large batch",
    description="Needed before publishing when `second_signoff_required` (`second_signoff_threshold_kg`).",
    responses=_errors(e404="`not_found`.", e409=GATE + "`same_approver`."),
)
async def second_signoff(batch_id: BatchId, session: Session, user: Admin) -> BatchOut:
    """Record the second sign-off.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: an FPO admin other than the creator.

    Returns:
        The batch.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: the creator signing twice (409).

    Side effects:
        Commits the sign-off and its approval row.
    """
    batch = await service.second_signoff(session, user, batch_id)
    await session.commit()
    return await service.batch_out(session, batch)


@router.post(
    "/batches/{batch_id}/grading/approve",
    response_model=BatchOut,
    summary="Approve the batch grading",
    description=(
        "Approves the latest grade of `POST /batches/{id}/grading`; graded kg caps final packing. In a batch "
        "without the GI label, GI-only holds (`plot_outside_gi_region`, `yield_over_ceiling`) do not block; "
        "they stay open and are recorded on the approval (D-041)."
    ),
    responses=_errors(
        e404="`not_found`.",
        e409=GATE + "`batch_status`, `not_graded`, `grade_incomplete`, `declared_above_computed`, "
        "`open_hold_flag`.",
        e422="`validation_error` (unit not kg).",
    ),
)
async def approve_grading(
    batch_id: BatchId, body: GradingApproveIn, session: Session, user: Admin
) -> BatchOut:
    """Approve grading.

    \f
    Args:
        batch_id: the batch.
        body: graded quantity.
        session: database session.
        user: the FPO admin.

    Returns:
        The batch, `graded`.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: unmet reasons (409).

    Side effects:
        Commits the approval, batch changes and refreshed flags.
    """
    batch, flags = await service.approve_grading(session, user, batch_id, body.graded.value)
    await session.commit()
    return await service.batch_out(session, batch, flags)


@router.post(
    "/batches/{batch_id}/final-packing",
    response_model=BatchOut,
    summary="Sign off final packing",
    description=(
        "Packed kg may not exceed graded kg. In a batch without the GI label, GI-only holds "
        "(`plot_outside_gi_region`, `yield_over_ceiling`) do not block; they stay open and are recorded on "
        "the approval (D-041)."
    ),
    responses=_errors(
        e404="`not_found`.",
        e409=GATE + "`grading_not_approved`, `packed_above_graded`, `open_hold_flag`.",
        e422="`validation_error` (unit not kg, best before earlier than pack date).",
    ),
)
async def final_packing(batch_id: BatchId, body: FinalPackingIn, session: Session, user: Admin) -> BatchOut:
    """Sign off final packing.

    \f
    Args:
        batch_id: the batch.
        body: packed kg and label dates.
        session: database session.
        user: the FPO admin.

    Returns:
        The batch, `packed`.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: unmet reasons (409).

    Side effects:
        Commits the approval, batch changes and refreshed flags.
    """
    batch, flags = await service.final_packing(
        session, user, batch_id, body.packed.value, body.pack_date, body.best_before_date
    )
    await session.commit()
    return await service.batch_out(session, batch, flags)


@router.post(
    "/batches/{batch_id}/publish",
    response_model=PublishOut,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Publish the public page (final sign-off)",
    description=(
        "Lists every unmet gate at once; when all are met, queues a page build (`page_builds`, "
        "`publishing.build_page`) and answers 202. A GI-blocked batch is published without the GI badge. "
        "In a batch without the GI label, GI-only holds (`plot_outside_gi_region`, `yield_over_ceiling`) "
        "do not block; they stay open and are recorded on the approval (D-041)."
    ),
    responses=_errors(
        e404="`not_found`.",
        e409=GATE + "`already_published`, `grading_not_approved`, `final_packing_missing`, "
        "`second_signoff_missing`, `open_hold_flag`.",
    ),
)
async def publish(batch_id: BatchId, session: Session, user: Admin) -> PublishOut:
    """Publish a batch.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the FPO admin.

    Returns:
        The queued build.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: unmet reasons (409).

    Side effects:
        Commits the batch, approval and build row, then enqueues `publishing.build_page`.
    """
    build = await service.publish(session, user, batch_id)
    batch = await service.get_batch(session, user, batch_id)
    await session.commit()
    await service.enqueue_page_build(build)
    return PublishOut(
        batch_id=batch.id,
        code=batch.code,
        build_no=build.build_no,
        page_build_id=build.id,
        status=build.status,
    )
