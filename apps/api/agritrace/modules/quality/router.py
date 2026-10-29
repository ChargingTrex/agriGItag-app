"""Quality HTTP routes: Standards Profiles, instruments, quality readings and batch grading (under /v1).

Serves: PRD §6.8 FR42–FR50 (FR52's sensor path uses the same `POST /quality-readings`), Dataflow Stage 5
(drying-end moisture), Stage 7 (intake moisture), Stage 8 (grading and declared vs computed grade),
backend-design.md §1 quality row, D-005 (client id idempotency), D-015, D-020 (/v1, additive).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the mobile app and portal
through the generated clients (D-003).
"""

import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Path, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.quality import service
from agritrace.modules.quality.schemas import (
    GradeOut,
    GradingIn,
    InstrumentIn,
    InstrumentOut,
    ProfileVersionIn,
    ProfileVersionOut,
    QualityReadingIn,
    QualityReadingOut,
    StandardsProfileOut,
)

router = APIRouter(tags=["quality"])

Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]
Staff = Annotated[
    CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER))
]
Recorder = Annotated[
    CurrentUser, Depends(require_role(Role.FARMER, Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN))
]
QcOrAdmin = Annotated[CurrentUser, Depends(require_role(Role.QC_OFFICER, Role.FPO_ADMIN))]
Cursor = Annotated[
    uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
]
Limit = Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")]


def _errors(**by_status: str) -> dict[int | str, dict[str, Any]]:
    """Document error responses of a route with the shared envelope.

    Args:
        **by_status: description per status, keyed `e<status>` (e.g. `e422="implausible_value, ..."`).

    Returns:
        The `responses=` mapping for FastAPI.
    """
    return {int(k[1:]): {"model": ErrorEnvelope, "description": v} for k, v in by_status.items()}


@router.get(
    "/standards-profiles",
    response_model=Page[StandardsProfileOut],
    summary="List Standards Profiles",
    description="Profiles per crop with the number of the version currently published (FR47).",
)
async def list_standards_profiles(
    session: Session,
    _user: AnyRole,
    crop_id: Annotated[uuid.UUID | None, Query(description="Only this crop's profiles.")] = None,
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[StandardsProfileOut]:
    """List Standards Profiles.

    Args:
        session: database session.
        _user: the caller (any signed-in role).
        crop_id: crop filter.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of profiles.

    Raises:
        UnauthorizedError: no valid token (401).
    """
    return await service.list_profiles(session, crop_id, cursor, limit)


@router.get(
    "/standards-profiles/{profile_id}/versions/{version_no}",
    response_model=ProfileVersionOut,
    summary="Get one Standards Profile version",
    description="The rules JSON of one version (backend-design.md §4) with its edition and status.",
    responses=_errors(e404="`not_found`: no such version."),
)
async def get_standards_profile_version(
    session: Session,
    _user: AnyRole,
    profile_id: Annotated[uuid.UUID, Path(description="Profile id.")],
    version_no: Annotated[int, Path(ge=1, description="Version number.")],
) -> ProfileVersionOut:
    """Read one profile version.

    Args:
        session: database session.
        _user: the caller (any signed-in role).
        profile_id: the profile.
        version_no: the version number.

    Returns:
        The version with its rules.

    Raises:
        UnauthorizedError: no valid token (401).
        NotFoundError: no such version (404).
    """
    version = await service.get_profile_version(session, profile_id, version_no)
    return ProfileVersionOut.model_validate(version, from_attributes=True)


@router.post(
    "/standards-profiles/{profile_id}/versions",
    response_model=ProfileVersionOut,
    status_code=status.HTTP_201_CREATED,
    summary="Create a Standards Profile version (super-admin)",
    description=(
        "Validates the rules JSON (grades, limits, stages, gates, trail rules) and stores the next version. "
        "Publishing retires the previous published version. Publishing while a grading parameter is still "
        "`load_from_standard` needs `allow_incomplete: true` and stamps a `public_note`. Super-admin only."
    ),
    responses=_errors(
        e403="`forbidden`: the caller is not a super-admin.",
        e404="`not_found`: no such profile.",
        e422="`validation_error` (invalid rules JSON) or `profile_incomplete_not_allowed`.",
    ),
)
async def create_standards_profile_version(
    session: Session,
    user: AnyRole,
    profile_id: Annotated[uuid.UUID, Path(description="Profile id.")],
    body: ProfileVersionIn,
) -> ProfileVersionOut:
    """Create a profile version.

    Args:
        session: database session.
        user: the caller; must be a super-admin.
        profile_id: the profile.
        body: rules, status and `allow_incomplete`.

    Returns:
        The created version.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: not a super-admin (403).
        NotFoundError: no such profile (404).
        ProfileIncompleteNotAllowedError: pending parameters without `allow_incomplete` (422).
    """
    version = await service.create_profile_version(
        session, user, profile_id, body.rules, body.status, body.allow_incomplete
    )
    return ProfileVersionOut.model_validate(version, from_attributes=True)


@router.get(
    "/instruments",
    response_model=Page[InstrumentOut],
    summary="List the FPO's instruments",
    description="Moisture meters, colorimeters, hygrometers and scales with their calibration dates (FR42).",
)
async def list_instruments(
    session: Session,
    user: AnyRole,
    active: Annotated[bool | None, Query(description="Only active (true) or inactive (false) ones.")] = None,
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[InstrumentOut]:
    """List instruments of the caller's FPO.

    Args:
        session: database session.
        user: the caller (any signed-in role).
        active: activity filter.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of instruments.

    Raises:
        UnauthorizedError: no valid token (401).
    """
    return await service.list_instruments(session, user, active, cursor, limit)


@router.post(
    "/instruments",
    response_model=InstrumentOut,
    status_code=status.HTTP_201_CREATED,
    summary="Register an instrument",
    description=(
        "Adds an instrument with its calibration dates to the caller's FPO. Readings measured after "
        "`calibration_due_on` are rejected (FR50). QC officer or FPO admin."
    ),
    responses=_errors(e403="`forbidden`: role not allowed.", e422="`validation_error`."),
)
async def create_instrument(session: Session, user: QcOrAdmin, body: InstrumentIn) -> InstrumentOut:
    """Register an instrument.

    Args:
        session: database session.
        user: the caller (QC officer or FPO admin).
        body: the instrument.

    Returns:
        The stored instrument.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: role not allowed (403).
    """
    instrument = await service.create_instrument(session, user, body)
    return InstrumentOut.model_validate(instrument, from_attributes=True)


@router.post(
    "/quality-readings",
    response_model=QualityReadingOut,
    status_code=status.HTTP_201_CREATED,
    summary="Record a quality reading",
    description=(
        "Stores one measured parameter of a lot or batch (FR42). Checked at entry against the crop's "
        "published profile (FR50): `unknown_parameter`, `unit_mismatch`, `implausible_value`, "
        "`source_not_allowed`, `instrument_calibration_expired`, `moisture_trail_violation` (accepted and "
        "flagged when `reason_code` is given). `client_id` is the idempotency key: resending it returns the "
        "stored reading with 200."
    ),
    responses={
        200: {"model": QualityReadingOut, "description": "Already stored with this `client_id` (duplicate)."},
        **_errors(
            e403="`forbidden`: role not allowed (viewers; farmers on batches).",
            e404="`not_found`: lot, batch or instrument not in the caller's FPO.",
            e409="`client_id_conflict`: the id belongs to another user's reading.",
            e422=(
                "`validation_error`, `no_published_profile`, `unknown_parameter`, `unit_mismatch`, "
                "`implausible_value`, `source_not_allowed`, `instrument_calibration_expired`, "
                "`moisture_trail_violation`."
            ),
        ),
    },
)
async def create_quality_reading(
    session: Session, user: Recorder, body: QualityReadingIn, response: Response
) -> QualityReadingOut:
    """Record a reading.

    Args:
        session: database session.
        user: the caller (farmer on own lots, field officer, QC officer, FPO admin).
        body: the reading.
        response: the outgoing response; its status becomes 200 for a duplicate.

    Returns:
        The stored reading.

    Raises:
        AppError: every error listed for `service.create_reading`.
    """
    row, created = await service.create_reading(session, user, body)
    if not created:
        response.status_code = status.HTTP_200_OK
    return service.reading_out(row)


@router.get(
    "/lots/{lot_id}/readings",
    response_model=Page[QualityReadingOut],
    summary="List a lot's quality readings",
    description="Drying-end and intake readings of a lot (its moisture trail, Dataflow Stages 5 and 7).",
    responses=_errors(e404="`not_found`: lot not visible to the caller."),
)
async def list_lot_readings(
    session: Session,
    user: AnyRole,
    lot_id: Annotated[uuid.UUID, Path(description="Lot id.")],
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[QualityReadingOut]:
    """List a lot's readings.

    Args:
        session: database session.
        user: the caller (farmers see only their own lots).
        lot_id: the lot.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of readings.

    Raises:
        UnauthorizedError: no valid token (401).
        NotFoundError: lot not visible (404).
    """
    return await service.list_readings(session, user, "lot", lot_id, cursor, limit)


@router.get(
    "/batches/{batch_id}/readings",
    response_model=Page[QualityReadingOut],
    summary="List a batch's quality readings",
    description="Grading and storage readings recorded on a batch (Dataflow Stage 8).",
    responses=_errors(e403="`forbidden`: farmers.", e404="`not_found`: batch not in the caller's FPO."),
)
async def list_batch_readings(
    session: Session,
    user: Staff,
    batch_id: Annotated[uuid.UUID, Path(description="Batch id.")],
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[QualityReadingOut]:
    """List a batch's readings.

    Args:
        session: database session.
        user: the caller (FPO staff).
        batch_id: the batch.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of readings.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: role not allowed (403).
        NotFoundError: batch not in the caller's FPO (404).
    """
    return await service.list_readings(session, user, "batch", batch_id, cursor, limit)


@router.post(
    "/batches/{batch_id}/grading",
    response_model=GradeOut,
    status_code=status.HTTP_201_CREATED,
    summary="Grade a batch",
    description=(
        "Records any inline readings, then computes the grade from the batch's readings against the "
        "crop's profile (FR48) and compares it with the declared grade (FR49). Status `incomplete` (a "
        "required reading is missing) or `declared_above_computed` blocks the admin's approval (B09). A "
        "declared grade the profile does not know is rejected with `unknown_grade_for_profile`."
    ),
    responses=_errors(
        e403="`forbidden`: role not allowed.",
        e404="`not_found`: batch, or a reading id not on this batch.",
        e422=(
            "`unknown_grade_for_profile`, `no_published_profile`, `validation_error`, or any reading error "
            "of `POST /quality-readings` for an inline reading."
        ),
    ),
)
async def grade_batch(
    session: Session,
    user: QcOrAdmin,
    batch_id: Annotated[uuid.UUID, Path(description="Batch id.")],
    body: GradingIn,
) -> GradeOut:
    """Grade a batch.

    Args:
        session: database session.
        user: the caller (QC officer or FPO admin).
        batch_id: the batch.
        body: declared grade and readings.

    Returns:
        The stored grade computation.

    Raises:
        AppError: every error listed for `service.grade_batch`.
    """
    computation = await service.grade_batch(session, user, batch_id, body)
    return GradeOut.model_validate(computation, from_attributes=True)


@router.get(
    "/batches/{batch_id}/grade",
    response_model=GradeOut,
    summary="Get a batch's latest grade",
    description="The batch's most recent grade computation with its per-parameter breakdown (FR48–FR51).",
    responses=_errors(e403="`forbidden`: farmers.", e404="`not_found`: batch not visible or never graded."),
)
async def get_batch_grade(
    session: Session, user: Staff, batch_id: Annotated[uuid.UUID, Path(description="Batch id.")]
) -> GradeOut:
    """Read a batch's latest grade.

    Args:
        session: database session.
        user: the caller (FPO staff).
        batch_id: the batch.

    Returns:
        The latest grade computation.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: role not allowed (403).
        NotFoundError: batch not visible or never graded (404).
    """
    return GradeOut.model_validate(await service.latest_grade(session, user, batch_id), from_attributes=True)
