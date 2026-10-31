"""HTTP routes of the registry: FPOs, processors, villages, farmers, plots, crops, GI regions, inputs.

Also (B13) master data CSV imports with dry run and templates, and the flag-gated ID document and producer
group routes (404 `feature_disabled` while the tenant's flag is off, D-017).
Each route checks the role, calls one service function, commits, and (for plots) enqueues the plot rules.

Serves: Stage 0 (onboarding), FR14 (roles), FR24 (tenant scoping), FR27–FR32, FR53–FR56, FR64–FR72,
backend-design.md §1 registry row, D-020 (`/v1`, additive), PLAN "Gap analysis" (Master data uploads,
ID capture, SHG groups), D-017.
Callers: `agritrace.main.create_app` mounts `router` under `/v1` by discovery (D-004); the mobile app and
portal through the generated clients.
"""

import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, File, Path, Query, Response, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.auth import SUPER_ADMIN, CurrentUser, get_current_user, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import FarmerStatus, Role
from agritrace.core.errors import FeatureDisabledError
from agritrace.core.schemas import Page
from agritrace.modules.registry import imports, service
from agritrace.modules.registry.schemas import (
    CropOut,
    FarmerIn,
    FarmerOut,
    FarmerPatch,
    FpoIn,
    FpoOut,
    GiRegionOut,
    GiRegionVersionIn,
    GiRegionVersionOut,
    IdDocumentIn,
    IdDocumentUpload,
    ImportReport,
    InputIn,
    InputOut,
    PlotCorrection,
    PlotIn,
    PlotOut,
    ProcessorIn,
    ProcessorOut,
    ProducerGroupIn,
    ProducerGroupOut,
    VillageOut,
)

router = APIRouter(tags=["registry"])

Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]
Admin = Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]
Staff = Annotated[CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.FPO_ADMIN))]
PlotCapturer = Annotated[CurrentUser, Depends(require_role(Role.FARMER, Role.FIELD_OFFICER, Role.FPO_ADMIN))]
Cursor = Annotated[str | None, Query(description="Cursor from the previous page's `next_cursor`.")]
Limit = Annotated[int, Query(ge=1, le=200, description="Page size (1–200).")]
FarmerId = Annotated[uuid.UUID, Path(description="Farmer id.")]
PlotId = Annotated[uuid.UUID, Path(description="Plot id (client-generated, D-005).")]
GiTagId = Annotated[uuid.UUID, Path(description="GI tag id.")]
SuperAdmin = Annotated[CurrentUser, Depends(require_role(SUPER_ADMIN))]
DryRun = Annotated[bool, Query(description="True: validate and report only; nothing is written.")]
CsvFile = Annotated[
    UploadFile, File(description="CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows.")
]


def _feature(flag: str) -> Any:
    """Build a route dependency that hides the route while a feature flag is off for the caller's FPO.

    Args:
        flag: a `Features` field name, e.g. `id_document_capture`.

    Returns:
        `Depends(gate)`, for a route's `dependencies=[...]` (resolved before the role check and the body).
    """

    async def gate(session: Session, user: Annotated[CurrentUser, Depends(get_current_user)]) -> None:
        """Check the flag.

        Args:
            session: database session.
            user: the caller.

        Raises:
            FeatureDisabledError: the flag is off for the caller's FPO (404 `feature_disabled`).
        """
        # DECISION D-017: a switched-off feature answers 404, as if the route did not exist.
        #   ADV: clients and scanners learn nothing about features the FPO does not use.
        #   COMPROMISE: one FPO-code read per call; the flag is per FPO, not per user.
        if not getattr(fieldconfig.features_for(await service.fpo_code(session, user.fpo_id)), flag):
            raise FeatureDisabledError(details={"feature": flag})

    return Depends(gate)


async def _finish(session: AsyncSession, report: ImportReport) -> ImportReport:
    """End an import: commit the whole file, or roll everything back for a dry run.

    Args:
        session: database session holding the imported rows.
        report: the row-level report.

    Returns:
        The report unchanged.

    Side effects:
        COMMIT or ROLLBACK of the request's transaction.
    """
    if report.dry_run:
        await session.rollback()
    else:
        await session.commit()
    return report


@router.get("/fpos", response_model=list[FpoOut], summary="List FPOs (super-admin: all; others: own)")
async def list_fpos(session: Session, user: AnyRole) -> list[FpoOut]:
    """List FPOs visible to the caller.

    \f
    Args:
        session: database session.
        user: the caller.

    Returns:
        All FPOs for a super-admin, else the caller's own.
    """
    return await service.list_fpos(session, user)


@router.post("/fpos", response_model=FpoOut, status_code=status.HTTP_201_CREATED, summary="Create an FPO")
async def create_fpo(body: FpoIn, session: Session, user: AnyRole) -> FpoOut:
    """Create an FPO (super-admin only).

    \f
    Args:
        body: the FPO.
        session: database session.
        user: the caller.

    Returns:
        The stored FPO.

    Raises:
        ForbiddenError: not a super-admin.
        ConflictError: code already used.
    """
    out = await service.create_fpo(session, user, body)
    await session.commit()
    return out


@router.get("/processors", response_model=list[ProcessorOut], summary="List processors")
async def list_processors(session: Session, user: AnyRole) -> list[ProcessorOut]:
    """List the FPO's processors and shared ones.

    \f
    Args:
        session: database session.
        user: the caller.

    Returns:
        Processors ordered by name.
    """
    return await service.list_processors(session, user)


@router.post(
    "/processors",
    response_model=ProcessorOut,
    status_code=status.HTTP_201_CREATED,
    summary="Register a processor",
)
async def create_processor(body: ProcessorIn, session: Session, user: Admin) -> ProcessorOut:
    """Register a processor for the caller's FPO (FPO admin).

    \f
    Args:
        body: the processor.
        session: database session.
        user: the caller.

    Returns:
        The stored processor.
    """
    out = await service.create_processor(session, user, body)
    await session.commit()
    return out


@router.get("/villages", response_model=Page[VillageOut], summary="Search the village directory")
async def list_villages(
    session: Session,
    _user: AnyRole,
    cursor: Cursor = None,
    limit: Limit = 50,
    district: Annotated[str | None, Query(max_length=120, description="District name (exact).")] = None,
    block: Annotated[str | None, Query(max_length=120, description="Block name (exact).")] = None,
    q: Annotated[str | None, Query(max_length=120, description="Part of the village name.")] = None,
) -> Page[VillageOut]:
    """Search villages for the onboarding picker (FR53).

    \f
    Args:
        session: database session.
        _user: the caller (any signed-in role).
        cursor: cursor from the previous page.
        limit: page size.
        district: district filter.
        block: block filter.
        q: name search.

    Returns:
        One page ordered by name.

    Raises:
        ValidationFailedError: invalid cursor.
    """
    return await service.list_villages(session, district, block, q, cursor, limit)


@router.get("/farmers", response_model=Page[FarmerOut], summary="List the FPO's farmers")
async def list_farmers(
    session: Session,
    user: AnyRole,
    cursor: Cursor = None,
    limit: Limit = 50,
    farmer_status: Annotated[FarmerStatus | None, Query(alias="status", description="Status filter.")] = None,
) -> Page[FarmerOut]:
    """List farmers of the caller's FPO (a farmer sees only themself).

    \f
    Args:
        session: database session.
        user: the caller.
        cursor: cursor from the previous page.
        limit: page size.
        farmer_status: status filter.

    Returns:
        One page in onboarding order.

    Raises:
        ValidationFailedError: invalid cursor.
    """
    return await service.list_farmers(session, user, farmer_status, cursor, limit)


@router.post(
    "/farmers", response_model=FarmerOut, status_code=status.HTTP_201_CREATED, summary="Onboard a farmer"
)
async def create_farmer(body: FarmerIn, session: Session, user: Staff) -> FarmerOut:
    """Onboard a farmer, pending approval (field officer or FPO admin).

    \f
    Args:
        body: the farmer.
        session: database session.
        user: the caller.

    Returns:
        The stored farmer.

    Raises:
        FarmerPhoneTakenError: phone already used by a farmer of this FPO.
        ValidationFailedError: unknown village.
    """
    out = await service.create_farmer(session, user, body)
    await session.commit()
    return out


@router.get("/farmers/{farmer_id}", response_model=FarmerOut, summary="Read a farmer")
async def get_farmer(farmer_id: FarmerId, session: Session, user: AnyRole) -> FarmerOut:
    """Read one farmer of the caller's FPO.

    \f
    Args:
        farmer_id: farmer id.
        session: database session.
        user: the caller.

    Returns:
        The farmer.

    Raises:
        NotFoundError: missing or out of scope (never 403).
    """
    return await service.get_farmer(session, user, farmer_id)


@router.patch("/farmers/{farmer_id}", response_model=FarmerOut, summary="Change a farmer's profile")
async def update_farmer(farmer_id: FarmerId, body: FarmerPatch, session: Session, user: Staff) -> FarmerOut:
    """Change a farmer's profile (field officer or FPO admin).

    \f
    Args:
        farmer_id: farmer id.
        body: the changes.
        session: database session.
        user: the caller.

    Returns:
        The updated farmer.

    Raises:
        NotFoundError: missing or out of scope.
        ValidationFailedError: unknown village.
    """
    out = await service.update_farmer(session, user, farmer_id, body)
    await session.commit()
    return out


@router.post("/farmers/{farmer_id}/approve", response_model=FarmerOut, summary="Approve a pending farmer")
async def approve_farmer(farmer_id: FarmerId, session: Session, user: Admin) -> FarmerOut:
    """Approve a pending farmer as a genuine member (FPO admin).

    \f
    Args:
        farmer_id: farmer id.
        session: database session.
        user: the caller.

    Returns:
        The active farmer.

    Raises:
        NotFoundError: missing or out of scope.
        FarmerNotPendingError: not pending.
    """
    out = await service.approve_farmer(session, user, farmer_id)
    await session.commit()
    return out


@router.post(
    "/plots",
    response_model=PlotOut,
    status_code=status.HTTP_201_CREATED,
    summary="Register a plot (idempotent on client_id)",
    responses={200: {"model": PlotOut, "description": "The plot already existed with this client_id."}},
)
async def create_plot(body: PlotIn, response: Response, session: Session, user: PlotCapturer) -> PlotOut:
    """Register a plot and run the GI region check; a resend returns 200 with the stored plot.

    \f
    Args:
        body: the plot.
        response: used to answer 200 for a resend.
        session: database session.
        user: the caller.

    Returns:
        The plot with its region check.

    Raises:
        NotFoundError: farmer out of scope.
        ClientIdConflictError: id used by another FPO's or farmer's plot.
        PlotLockedError: id exists with a different pin or size.
        ValidationFailedError: bad size unit.
        InvalidGeometryError: bad walked boundary.

    Side effects:
        Enqueues `rules.check_plot` after commit when the plot is new.
    """
    out, created = await service.create_plot(session, user, body)
    await session.commit()
    if created:
        await service.enqueue_plot_check(out.id)
    else:
        response.status_code = status.HTTP_200_OK
    return out


@router.get("/plots/{plot_id}", response_model=PlotOut, summary="Read a plot")
async def get_plot(plot_id: PlotId, session: Session, user: AnyRole) -> PlotOut:
    """Read one plot of the caller's FPO.

    \f
    Args:
        plot_id: plot id.
        session: database session.
        user: the caller.

    Returns:
        The plot.

    Raises:
        NotFoundError: missing or out of scope.
    """
    return await service.get_plot(session, user, plot_id)


@router.post("/plots/{plot_id}/correct", response_model=PlotOut, summary="Correct a plot with a reason")
async def correct_plot(plot_id: PlotId, body: PlotCorrection, session: Session, user: Admin) -> PlotOut:
    """Correct an onboarded plot (FPO admin), keeping the old state as a revision.

    \f
    Args:
        plot_id: plot id.
        body: changes and reason.
        session: database session.
        user: the caller.

    Returns:
        The corrected plot with the re-run region check.

    Raises:
        ReasonRequiredError: no reason code.
        NotFoundError: missing or out of scope.
        ValidationFailedError: bad size unit.
        InvalidGeometryError: bad walked boundary.

    Side effects:
        Enqueues `rules.check_plot` after commit.
    """
    out = await service.correct_plot(session, user, plot_id, body)
    await session.commit()
    await service.enqueue_plot_check(out.id)
    return out


@router.get("/crops", response_model=list[CropOut], summary="List crops")
async def list_crops(session: Session, _user: AnyRole) -> list[CropOut]:
    """List active crops.

    \f
    Args:
        session: database session.
        _user: the caller (any signed-in role).

    Returns:
        Active crops.
    """
    return await service.list_crops(session)


@router.get(
    "/gi-tags/{gi_tag_id}/region", response_model=GiRegionOut, summary="Current GI region (simplified)"
)
async def get_region(gi_tag_id: GiTagId, session: Session, _user: AnyRole) -> GiRegionOut:
    """Return the GI tag's region in effect today, simplified.

    \f
    Args:
        gi_tag_id: GI tag id.
        session: database session.
        _user: the caller (any signed-in role).

    Returns:
        Version metadata and outline.

    Raises:
        GiRegionMissingError: no region loaded.
    """
    return await service.get_region(session, gi_tag_id)


@router.post(
    "/gi-tags/{gi_tag_id}/region-versions",
    response_model=GiRegionVersionOut,
    status_code=status.HTTP_201_CREATED,
    summary="Upload a GI region version (super-admin)",
)
async def create_region_version(
    gi_tag_id: GiTagId, body: GiRegionVersionIn, session: Session, user: AnyRole
) -> GiRegionVersionOut:
    """Store a new region outline version (super-admin only; FPO admins get 403, FR31).

    \f
    Args:
        gi_tag_id: GI tag id.
        body: outline and provenance.
        session: database session.
        user: the caller.

    Returns:
        The stored version's metadata.

    Raises:
        ForbiddenError: not a super-admin.
        NotFoundError: no such GI tag.
        InvalidGeometryError: invalid outline.
    """
    out = await service.create_region_version(session, user, gi_tag_id, body)
    await session.commit()
    return out


@router.get("/inputs", response_model=list[InputOut], summary="List the input master list")
async def list_inputs(session: Session, user: AnyRole) -> list[InputOut]:
    """List active inputs: global plus the caller's FPO's own.

    \f
    Args:
        session: database session.
        user: the caller.

    Returns:
        Inputs by category and name.
    """
    return await service.list_inputs(session, user)


@router.post("/inputs", response_model=InputOut, status_code=status.HTTP_201_CREATED, summary="Add an input")
async def create_input(body: InputIn, session: Session, user: AnyRole) -> InputOut:
    """Add an input to the FPO's list (FPO admin) or the global list (super-admin).

    \f
    Args:
        body: the input.
        session: database session.
        user: the caller.

    Returns:
        The stored input.

    Raises:
        ForbiddenError: global entry by a non-super-admin.
    """
    out = await service.create_input(session, user, body)
    await session.commit()
    return out


# --- B13: master data imports (PLAN "Gap analysis": Master data uploads) --------------------------------


@router.post("/imports/farmers", response_model=ImportReport, summary="Import farmers from CSV")
async def import_farmers(
    file: CsvFile, session: Session, user: Admin, dry_run: DryRun = False
) -> ImportReport:
    """Import farmers (FPO admin): pending approval, same rules as onboarding; one transaction per file.

    \f
    Args:
        file: the CSV.
        session: database session.
        user: the caller.
        dry_run: report only.

    Returns:
        Accepted count and rejected rows `{row, code, field}`.

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.
    """
    report = await imports.import_farmers(session, user, await file.read(imports.MAX_BYTES + 1), dry_run)
    return await _finish(session, report)


@router.post(
    "/imports/villages", response_model=ImportReport, summary="Import villages from CSV (super-admin)"
)
async def import_villages(
    file: CsvFile, session: Session, _user: SuperAdmin, dry_run: DryRun = False
) -> ImportReport:
    """Import villages into the global directory (super-admin); key `lgd_code`; one transaction per file.

    \f
    Args:
        file: the CSV.
        session: database session.
        _user: the caller (super-admin).
        dry_run: report only.

    Returns:
        Accepted count and rejected rows `{row, code, field}`.

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.
    """
    report = await imports.import_villages(session, await file.read(imports.MAX_BYTES + 1), dry_run)
    return await _finish(session, report)


@router.post("/imports/inputs", response_model=ImportReport, summary="Import inputs from CSV")
async def import_inputs(
    file: CsvFile, session: Session, user: Admin, dry_run: DryRun = False
) -> ImportReport:
    """Import inputs into the FPO's list (FPO admin); key name + manufacturer; one transaction per file.

    \f
    Args:
        file: the CSV.
        session: database session.
        user: the caller.
        dry_run: report only.

    Returns:
        Accepted count and rejected rows `{row, code, field}`.

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.
    """
    report = await imports.import_inputs(session, user, await file.read(imports.MAX_BYTES + 1), dry_run)
    return await _finish(session, report)


@router.get(
    "/imports/{kind}/template.csv",
    response_class=Response,
    summary="CSV template for an import",
    responses={200: {"content": {"text/csv": {}}, "description": "One header line from the field config."}},
)
async def import_template(
    kind: Annotated[imports.Kind, Path(description="farmers, villages or inputs.")],
    session: Session,
    user: AnyRole,
) -> Response:
    """Download the import template: the tenant's enabled CSV columns from /v1/config/fields (D-017).

    \f
    Args:
        kind: farmers, villages or inputs.
        session: database session.
        user: the caller.

    Returns:
        `text/csv` attachment `<kind>-template.csv`.
    """
    body = imports.template_csv(kind, await service.fpo_code(session, user.fpo_id))
    headers = {"Content-Disposition": f'attachment; filename="{kind}-template.csv"'}
    return Response(body, media_type="text/csv; charset=utf-8", headers=headers)


# --- B13: flag-gated routes (D-017) --------------------------------------------------------------------


@router.post(
    "/farmers/{farmer_id}/id-documents",
    response_model=IdDocumentUpload,
    status_code=status.HTTP_201_CREATED,
    summary="Start an ID document upload (flag id_document_capture)",
    dependencies=[_feature("id_document_capture")],
)
async def create_id_document(
    farmer_id: FarmerId, body: IdDocumentIn, session: Session, user: Staff
) -> IdDocumentUpload:
    """Record an ID document under the farmer's consent and get a presigned PUT into the id-docs bucket.

    404 `feature_disabled` while the FPO's `id_document_capture` flag is off.

    \f
    Args:
        farmer_id: farmer id.
        body: document type, consent, image type and SHA-256.
        session: database session.
        user: the caller (field officer or FPO admin).

    Returns:
        Document id and upload instructions.

    Raises:
        FeatureDisabledError: flag off.
        NotFoundError: farmer missing or out of scope.
        ValidationFailedError: no active data_collection consent of this farmer.
    """
    out = await service.create_id_document(session, user, farmer_id, body)
    await session.commit()
    return out


@router.get(
    "/producer-groups",
    response_model=list[ProducerGroupOut],
    summary="List producer groups (flag producer_groups)",
    dependencies=[_feature("producer_groups")],
)
async def list_producer_groups(session: Session, user: AnyRole) -> list[ProducerGroupOut]:
    """List the FPO's producer groups; 404 `feature_disabled` while the flag is off.

    \f
    Args:
        session: database session.
        user: the caller.

    Returns:
        Groups by name.

    Raises:
        FeatureDisabledError: flag off.
    """
    return await service.list_producer_groups(session, user)


@router.post(
    "/producer-groups",
    response_model=ProducerGroupOut,
    status_code=status.HTTP_201_CREATED,
    summary="Create a producer group (flag producer_groups)",
    dependencies=[_feature("producer_groups")],
)
async def create_producer_group(body: ProducerGroupIn, session: Session, user: Admin) -> ProducerGroupOut:
    """Create a producer group (FPO admin); 404 `feature_disabled` while the flag is off.

    \f
    Args:
        body: the group.
        session: database session.
        user: the caller.

    Returns:
        The stored group.

    Raises:
        FeatureDisabledError: flag off.
    """
    out = await service.create_producer_group(session, user, body)
    await session.commit()
    return out
