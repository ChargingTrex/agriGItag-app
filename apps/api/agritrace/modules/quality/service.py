"""Quality service: Standards Profile versions, instruments, quality readings and batch grading.

Serves: PRD §6.8 FR42–FR50 (structured readings, profiles, computed vs declared grade, plausibility and
calibration at entry), FR51 (lab-certified, public note), FR68 (yield parameters), Dataflow Stage 5
(drying-end moisture, ready-for-sale gate), Stage 7 (intake moisture), Stage 8 (grading), D-005 (client id
idempotency), D-015 (profile JSON + one engine), backend-design.md §1 quality row, §3 (sync
`kind=quality_reading` entries call `create_reading`), §4.
Callers: `quality.router`; `quality.profiles.loader` (seed, B12); other modules through `__all__` only
(D-004): events sync push (B06) `create_reading`; rules_flags (B08) `yield_params_for_crop`; lots_batches
(B09) `lot_gate_passes`, `compute_grade_for_batch`; events bundle and publishing (B06, B10)
`latest_profile_version_for_crop`.
"""

import logging
import uuid
from collections.abc import Callable, Mapping, Sequence
from typing import Any, Literal

from geoalchemy2 import WKTElement
from pydantic import ValidationError
from sqlalchemy import func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import Select

from agritrace.core import task_names
from agritrace.core.auth import CurrentUser
from agritrace.core.enums import GradeStatus, ProfileVersionStatus, Role
from agritrace.core.errors import (
    ClientIdConflictError,
    ForbiddenError,
    ImplausibleValueError,
    InstrumentCalibrationExpiredError,
    MoistureTrailViolationError,
    NoPublishedProfileError,
    NotFoundError,
    ProfileIncompleteNotAllowedError,
    SourceNotAllowedError,
    UnitMismatchError,
    UnknownGradeForProfileError,
    UnknownParameterError,
    ValidationFailedError,
)
from agritrace.core.schemas import Page
from agritrace.core.time import utcnow
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot
from agritrace.modules.quality import grade_engine
from agritrace.modules.quality.models import (
    GradeComputation,
    Instrument,
    QualityReading,
    StandardsProfile,
    StandardsProfileVersion,
)
from agritrace.modules.quality.schemas import (
    GradingIn,
    InstrumentIn,
    InstrumentOut,
    QualityReadingIn,
    QualityReadingOut,
    StandardsProfileOut,
    StandardsProfileRules,
    YieldRule,
)
from agritrace.modules.registry.models import Farmer

__all__ = [
    "compute_grade_for_batch",
    "create_reading",
    "latest_profile_version_for_crop",
    "lot_gate_passes",
    "yield_params_for_crop",
]

log = logging.getLogger(__name__)

TRAIL_OVERRIDE_HINT = "moisture_trail_override"


# ---------------------------------------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------------------------------------


async def _page[T](
    session: AsyncSession,
    query: Select[Any],
    id_column: Any,
    cursor: uuid.UUID | None,
    limit: int,
    to_out: Callable[[Any], T],
) -> tuple[list[T], str | None, bool]:
    """Run a keyset-paginated query ordered by id (docs/api/conventions.md, cursor pages).

    Args:
        session: database session.
        query: a select of one ORM entity, already scoped to the caller.
        id_column: the entity's `id` column, used for ordering and the cursor.
        cursor: id of the last item of the previous page, or None for the first page.
        limit: page size.
        to_out: converts a row to its response model.

    Returns:
        `(items, next_cursor, has_more)` for `Page`; `next_cursor` is the last item's id when more rows exist.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    if cursor is not None:
        query = query.where(id_column > cursor)
    rows = list((await session.scalars(query.order_by(id_column).limit(limit + 1))).all())
    more = len(rows) > limit
    items = rows[:limit]
    last_id = getattr(items[-1], "id", None) if more and items else None
    return [to_out(r) for r in items], str(last_id) if last_id else None, more


def _rules(version: StandardsProfileVersion) -> StandardsProfileRules:
    """Parse a stored version's rules JSON.

    Args:
        version: a profile version row.

    Returns:
        The validated rules (stored JSON was validated on write, so this does not fail in practice).

    Raises:
        pydantic.ValidationError: the stored JSON was edited outside the API and is invalid.
    """
    return StandardsProfileRules.model_validate(version.rules)


async def latest_profile_version_for_crop(
    session: AsyncSession, crop_id: uuid.UUID
) -> StandardsProfileVersion | None:
    """Find the profile version currently used for a crop's readings and grades (FR47).

    Args:
        session: database session.
        crop_id: the crop.

    Returns:
        The most recently published version of any of the crop's profiles, or None when none is published.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: one profile per crop in the pilot; a crop with AGMARK and ISO profiles needs a scheme
    #   argument (FR47 "per grade scheme") once a second scheme is published.
    query = (
        select(StandardsProfileVersion)
        .join(StandardsProfile, StandardsProfile.id == StandardsProfileVersion.profile_id)
        .where(
            StandardsProfile.crop_id == crop_id,
            StandardsProfileVersion.status == ProfileVersionStatus.PUBLISHED,
        )
        .order_by(StandardsProfileVersion.published_at.desc(), StandardsProfileVersion.version_no.desc())
        .limit(1)
    )
    return await session.scalar(query)


async def _required_rules(
    session: AsyncSession, crop_id: uuid.UUID
) -> tuple[StandardsProfileVersion, StandardsProfileRules]:
    """Load the crop's current profile version, or refuse.

    Args:
        session: database session.
        crop_id: the crop.

    Returns:
        The version and its parsed rules.

    Raises:
        NoPublishedProfileError: the crop has no published profile (`no_published_profile`, 422).
    """
    version = await latest_profile_version_for_crop(session, crop_id)
    if version is None:
        raise NoPublishedProfileError(details={"crop_id": str(crop_id)})
    return version, _rules(version)


async def yield_params_for_crop(session: AsyncSession, crop_id: uuid.UUID) -> YieldRule | None:
    """Return the yield-ceiling parameters of the crop's current profile (FR68), for the B08 yield check.

    Args:
        session: database session.
        crop_id: the crop.

    Returns:
        `ceiling_kg_per_acre`, `warn_margin_pct`, `hold_margin_pct`, or None when no profile is published or
        the profile has no yield rule (the check is then unavailable).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    version = await latest_profile_version_for_crop(session, crop_id)
    return _rules(version).yield_ if version else None


# ---------------------------------------------------------------------------------------------------------
# Standards profiles (FR47)
# ---------------------------------------------------------------------------------------------------------


async def list_profiles(
    session: AsyncSession, crop_id: uuid.UUID | None, cursor: uuid.UUID | None, limit: int
) -> Page[StandardsProfileOut]:
    """List Standards Profiles with their published version number.

    Args:
        session: database session.
        crop_id: only this crop's profiles, when given.
        cursor: pagination cursor (last id of the previous page).
        limit: page size.

    Returns:
        One page of profiles.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(StandardsProfile)
    if crop_id is not None:
        query = query.where(StandardsProfile.crop_id == crop_id)
    profiles, next_cursor, more = await _page(session, query, StandardsProfile.id, cursor, limit, lambda p: p)
    published = dict(
        (
            await session.execute(
                select(StandardsProfileVersion.profile_id, func.max(StandardsProfileVersion.version_no))
                .where(
                    StandardsProfileVersion.profile_id.in_([p.id for p in profiles]),
                    StandardsProfileVersion.status == ProfileVersionStatus.PUBLISHED,
                )
                .group_by(StandardsProfileVersion.profile_id)
            )
        )
        .tuples()
        .all()
    )
    items = [
        StandardsProfileOut(
            id=p.id,
            crop_id=p.crop_id,
            scheme=p.scheme,
            name=p.name,
            standard_ref=p.standard_ref,
            published_version_no=published.get(p.id),
        )
        for p in profiles
    ]
    return Page[StandardsProfileOut](items=items, next_cursor=next_cursor, has_more=more)


async def get_profile_version(
    session: AsyncSession, profile_id: uuid.UUID, version_no: int
) -> StandardsProfileVersion:
    """Load one version of a profile.

    Args:
        session: database session.
        profile_id: the profile.
        version_no: version number.

    Returns:
        The version row.

    Raises:
        NotFoundError: no such version (`not_found`, 404).
    """
    version = await session.scalar(
        select(StandardsProfileVersion).where(
            StandardsProfileVersion.profile_id == profile_id, StandardsProfileVersion.version_no == version_no
        )
    )
    if version is None:
        raise NotFoundError(details={"profile_id": str(profile_id), "version_no": version_no})
    return version


async def add_profile_version(
    session: AsyncSession,
    profile_id: uuid.UUID,
    rules: StandardsProfileRules,
    *,
    status: ProfileVersionStatus,
    allow_incomplete: bool,
    published_by: uuid.UUID | None,
) -> StandardsProfileVersion:
    """Store the next version of a profile; publishing retires the previously published one.

    Args:
        session: database session.
        profile_id: the profile (must exist).
        rules: validated rules JSON.
        status: `draft` or `published`.
        allow_incomplete: permit publishing while grading parameters are still `load_from_standard`.
        published_by: the publishing user; None for the seed loader (system).

    Returns:
        The new version row (flushed, not committed).

    Raises:
        ProfileIncompleteNotAllowedError: publishing with pending parameters without `allow_incomplete`
            (`profile_incomplete_not_allowed`, 422).

    Side effects:
        Inserts the version; sets earlier published versions to `retired`; writes audit rows on flush.
    """
    pending = rules.pending_parameters()
    publish = status == ProfileVersionStatus.PUBLISHED
    if publish and pending and not allow_incomplete:
        raise ProfileIncompleteNotAllowedError(details={"parameters": pending})
    if publish and pending and rules.public_note is None:
        graded = ", ".join(
            p.code.replace("_", " ") for p in rules.parameters if p.role == "grading" and p.limits
        )
        rules = rules.model_copy(update={"public_note": f"Graded on {graded} only — full schedule pending"})
    last = await session.scalar(
        select(func.max(StandardsProfileVersion.version_no)).where(
            StandardsProfileVersion.profile_id == profile_id
        )
    )
    if publish:
        # ORM, not a Core UPDATE, so the audit listener records each retirement (core/audit.py).
        published = select(StandardsProfileVersion).where(
            StandardsProfileVersion.profile_id == profile_id,
            StandardsProfileVersion.status == ProfileVersionStatus.PUBLISHED,
        )
        for old in (await session.scalars(published)).all():
            old.status = ProfileVersionStatus.RETIRED
    version = StandardsProfileVersion(
        profile_id=profile_id,
        version_no=(last or 0) + 1,
        edition=rules.standard.edition,
        clause_ref=rules.standard.clause_ref,
        # Stored with every default spelled out, so the phone bundle needs no knowledge of defaults (D-006).
        rules=rules.model_dump(mode="json", by_alias=True),
        status=status,
        published_at=utcnow() if publish else None,
        published_by=published_by if publish else None,
    )
    session.add(version)
    await session.flush()
    return version


async def create_profile_version(
    session: AsyncSession,
    user: CurrentUser,
    profile_id: uuid.UUID,
    rules: StandardsProfileRules,
    status: ProfileVersionStatus,
    allow_incomplete: bool,
) -> StandardsProfileVersion:
    """Create a profile version on behalf of the compliance team (super-admin only, FR47).

    Args:
        session: database session.
        user: the caller.
        profile_id: the profile.
        rules: validated rules JSON.
        status: `draft` or `published`.
        allow_incomplete: see `add_profile_version`.

    Returns:
        The committed version.

    Raises:
        ForbiddenError: the caller is not a super-admin (`forbidden`, 403).
        NotFoundError: no such profile (`not_found`, 404).
        ProfileIncompleteNotAllowedError: from `add_profile_version`.

    Side effects:
        Commits the new version (and retires the previous published one).
    """
    if not await session.scalar(select(User.is_super_admin).where(User.id == user.user_id)):
        raise ForbiddenError("Only the compliance team (super-admin) edits standards profiles.")
    if await session.get(StandardsProfile, profile_id) is None:
        raise NotFoundError(details={"profile_id": str(profile_id)})
    version = await add_profile_version(
        session,
        profile_id,
        rules,
        status=status,
        allow_incomplete=allow_incomplete,
        published_by=user.user_id,
    )
    await session.commit()
    return version


# ---------------------------------------------------------------------------------------------------------
# Instruments (FR42, FR50)
# ---------------------------------------------------------------------------------------------------------


async def list_instruments(
    session: AsyncSession, user: CurrentUser, active: bool | None, cursor: uuid.UUID | None, limit: int
) -> Page[InstrumentOut]:
    """List the caller's FPO's instruments.

    Args:
        session: database session.
        user: the caller (scopes to their FPO).
        active: only active (True) or inactive (False) ones, when given.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of instruments.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(Instrument).where(Instrument.fpo_id == user.fpo_id)
    if active is not None:
        query = query.where(Instrument.active == active)
    items, next_cursor, more = await _page(
        session,
        query,
        Instrument.id,
        cursor,
        limit,
        lambda i: InstrumentOut.model_validate(i, from_attributes=True),
    )
    return Page[InstrumentOut](items=items, next_cursor=next_cursor, has_more=more)


async def create_instrument(session: AsyncSession, user: CurrentUser, data: InstrumentIn) -> Instrument:
    """Register an instrument for the caller's FPO.

    Args:
        session: database session.
        user: the caller.
        data: instrument details and calibration dates.

    Returns:
        The committed instrument.

    Raises:
        sqlalchemy.exc.IntegrityError: `calibration_cert_photo_id` names no photo.

    Side effects:
        Commits the instrument and its audit row.
    """
    instrument = Instrument(fpo_id=user.fpo_id, **data.model_dump())
    session.add(instrument)
    await session.commit()
    return instrument


# ---------------------------------------------------------------------------------------------------------
# Readings (FR42–FR46, FR50)
# ---------------------------------------------------------------------------------------------------------


async def _load_lot(session: AsyncSession, user: CurrentUser, lot_id: uuid.UUID) -> Lot:
    """Load a lot the caller may see: same FPO; a farmer only their own lots.

    Args:
        session: database session.
        user: the caller.
        lot_id: the lot.

    Returns:
        The lot.

    Raises:
        NotFoundError: no such lot in the caller's FPO, or a farmer asking for another farmer's lot (404).
    """
    lot = await session.get(Lot, lot_id)
    if lot is None or lot.fpo_id != user.fpo_id:
        raise NotFoundError(details={"lot_id": str(lot_id)})
    if user.role == Role.FARMER:
        owner = await session.scalar(select(Farmer.user_id).where(Farmer.id == lot.farmer_id))
        if owner != user.user_id:
            raise NotFoundError(details={"lot_id": str(lot_id)})
    return lot


async def _load_batch(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> Batch:
    """Load a batch of the caller's FPO; farmers have no batch access.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.

    Returns:
        The batch.

    Raises:
        ForbiddenError: the caller is a farmer (`forbidden`, 403).
        NotFoundError: no such batch in the caller's FPO (404).
    """
    if user.role == Role.FARMER:
        raise ForbiddenError(details={"batch_id": str(batch_id)})
    batch = await session.get(Batch, batch_id)
    if batch is None or batch.fpo_id != user.fpo_id:
        raise NotFoundError(details={"batch_id": str(batch_id)})
    return batch


def _engine_reading(row: QualityReading) -> grade_engine.Reading:
    """Convert a stored reading to the engine's input.

    Args:
        row: the reading row.

    Returns:
        The engine reading.
    """
    return grade_engine.Reading(
        id=row.id,
        parameter_code=row.parameter_code,
        value=row.value,
        unit=row.unit,
        stage=row.stage,
        source=row.source,
        measured_at=row.measured_at,
        lab_nabl_no=row.lab_nabl_no,
    )


def reading_out(row: QualityReading) -> QualityReadingOut:
    """Render a stored reading for the API.

    Args:
        row: the reading row.

    Returns:
        The response model, with value and unit as one `measurement`.
    """
    fields = {name: getattr(row, name) for name in QualityReadingOut.model_fields if name != "measurement"}
    return QualityReadingOut.model_validate({**fields, "measurement": {"value": row.value, "unit": row.unit}})


def _raise_violation(violations: Sequence[grade_engine.Violation], details: dict[str, Any]) -> None:
    """Raise the API error of the first violation, listing all of them in `details`.

    Args:
        violations: non-empty list from `grade_engine.check_plausibility`.
        details: extra context (parameter limits) merged into the error details.

    Raises:
        UnknownParameterError: `unknown_parameter` (422).
        UnitMismatchError: `unit_mismatch` (422).
        ImplausibleValueError: `implausible_value` (422).
        SourceNotAllowedError: `source_not_allowed` (422).
    """
    first = violations[0]
    info = {**details, "violations": [v.model_dump() for v in violations]}
    match first.code:
        case "unknown_parameter":
            raise UnknownParameterError(first.message, info)
        case "unit_mismatch":
            raise UnitMismatchError(first.message, info)
        case "implausible_value":
            raise ImplausibleValueError(first.message, info)
        case _:
            raise SourceNotAllowedError(first.message, info)


def _parse_reading(data: QualityReadingIn | Mapping[str, Any]) -> QualityReadingIn:
    """Accept a validated request body or the raw `data` of a sync entry (B06 cannot import schemas).

    Args:
        data: the reading.

    Returns:
        The validated reading.

    Raises:
        ValidationFailedError: the raw data does not match `QualityReadingIn` (`validation_error`, 422).
    """
    if isinstance(data, QualityReadingIn):
        return data
    try:
        return QualityReadingIn.model_validate(data)
    except ValidationError as e:
        details = [{"loc": err["loc"], "msg": err["msg"], "type": err["type"]} for err in e.errors()]
        raise ValidationFailedError(details=details) from e


def _same_owner(row: QualityReading, user: CurrentUser) -> QualityReading:
    """Return a reading resent with the same client id, when it is the caller's own (D-005).

    Args:
        row: the stored reading with that id.
        user: the caller.

    Returns:
        The stored reading, unchanged.

    Raises:
        ClientIdConflictError: the id belongs to another user's or FPO's reading (`client_id_conflict`, 409).
    """
    if row.fpo_id != user.fpo_id or row.measured_by_user_id != user.user_id:
        raise ClientIdConflictError(details={"client_id": str(row.id)})
    return row


async def _prior_readings(session: AsyncSession, data: QualityReadingIn) -> list[grade_engine.Reading]:
    """Load the readings a trail rule compares with: the lot's, or the batch's and its component lots'.

    Args:
        session: database session.
        data: the incoming reading.

    Returns:
        Earlier readings of the same parameter, as engine readings.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(QualityReading).where(QualityReading.parameter_code == data.parameter_code)
    if data.lot_id is not None:
        query = query.where(QualityReading.lot_id == data.lot_id)
    else:
        lots = select(BatchShare.lot_id).where(BatchShare.batch_id == data.batch_id)
        query = query.where(or_(QualityReading.batch_id == data.batch_id, QualityReading.lot_id.in_(lots)))
    return [_engine_reading(r) for r in (await session.scalars(query)).all()]


async def _check_instrument(
    session: AsyncSession, user: CurrentUser, data: QualityReadingIn
) -> Instrument | None:
    """Check the instrument named by a reading: same FPO, active, calibrated on the measuring day (FR50).

    Args:
        session: database session.
        user: the caller.
        data: the incoming reading.

    Returns:
        The instrument, or None when the reading names none.

    Raises:
        NotFoundError: the instrument is not in the caller's FPO (404).
        ValidationFailedError: the instrument is inactive (`validation_error`, 422).
        InstrumentCalibrationExpiredError: no due date, or measured after it (422).
    """
    if data.instrument_id is None:
        return None
    instrument = await session.get(Instrument, data.instrument_id)
    if instrument is None or instrument.fpo_id != user.fpo_id:
        raise NotFoundError(details={"instrument_id": str(data.instrument_id)})
    if not instrument.active:
        raise ValidationFailedError("The instrument is inactive.", {"instrument_id": str(instrument.id)})
    due = instrument.calibration_due_on
    # Judged on the measuring day, not the sync day: a reading taken offline before expiry stays valid.
    if due is None or data.measured_at.date() > due:
        raise InstrumentCalibrationExpiredError(
            details={
                "instrument_id": str(instrument.id),
                "calibration_due_on": due.isoformat() if due else None,
                "measured_on": data.measured_at.date().isoformat(),
            }
        )
    return instrument


def _photo_ids(data: QualityReadingIn) -> list[str]:
    """List the photo ids a reading references.

    Args:
        data: the reading.

    Returns:
        The certificate and evidence photo ids that are set, as strings.
    """
    return [str(i) for i in (data.certificate_photo_id, data.evidence_photo_id) if i is not None]


def _enqueue_trail_override(row: QualityReading) -> None:
    """Ask rules_flags to raise the flag for an accepted trail override (FR50 "override with reason → flag").

    Args:
        row: the committed reading.

    Side effects:
        Sends task `rules.check_lot` by name (D-004) with hint `moisture_trail_override`. A broker failure is
        logged, not raised: the reading is already stored and its `reason_code` keeps the evidence.
    """
    from agritrace.worker import app  # imported late: the worker module reads broker settings on import

    kwargs = {
        "lot_id": str(row.lot_id) if row.lot_id else None,
        "batch_id": str(row.batch_id) if row.batch_id else None,
        "reading_id": str(row.id),
        "hint": TRAIL_OVERRIDE_HINT,
    }
    try:
        app.send_task(task_names.RULES_CHECK_LOT, kwargs=kwargs)
    except Exception:  # noqa: BLE001 - the stored reading must not fail because the broker is down
        # shortcut: a lost enqueue is not retried; B08's lot check should sweep readings with reason_code.
        log.exception("could not enqueue %s for reading %s", task_names.RULES_CHECK_LOT, row.id)


async def create_reading(
    session: AsyncSession, current_user: CurrentUser, data: QualityReadingIn | Mapping[str, Any]
) -> tuple[QualityReading, bool]:
    """Validate and store one quality reading; resending the same `client_id` returns the stored one (D-005).

    Order of checks: role and subject scope, published profile, plausibility (unknown parameter, unit, range,
    source), instrument calibration, trail rule. Also the sync push's handler for `kind=quality_reading`.

    Args:
        session: database session (committed here: one reading, one transaction, as in sync push §3).
        current_user: the caller; becomes `measured_by_user_id`.
        data: the reading, as the API model or the raw sync `data` dict.

    Returns:
        `(reading, created)`; `created` is False when the client id was already stored by the caller.

    Raises:
        ValidationFailedError: malformed data, inactive instrument or unknown photo id (`validation_error`).
        ForbiddenError: viewers, and farmers on batches (403).
        NotFoundError: lot, batch or instrument not in the caller's FPO (404).
        ClientIdConflictError: the client id belongs to someone else's reading (409).
        NoPublishedProfileError: the crop has no published profile (422).
        UnknownParameterError: `unknown_parameter` (422).
        UnitMismatchError: `unit_mismatch` (422).
        ImplausibleValueError: `implausible_value` (422).
        SourceNotAllowedError: `source_not_allowed` (422).
        InstrumentCalibrationExpiredError: `instrument_calibration_expired` (422).
        MoistureTrailViolationError: `moisture_trail_violation` without an accepted `reason_code` (422).

    Side effects:
        Inserts the reading and its audit row, commits and re-reads it; on an accepted trail override,
        enqueues `rules.check_lot` with hint `moisture_trail_override` after the commit.
    """
    data = _parse_reading(data)
    if current_user.role == Role.VIEWER:
        raise ForbiddenError(details={"required_roles": [r for r in Role if r != Role.VIEWER]})
    existing = await session.get(QualityReading, data.client_id)
    if existing is not None:
        return _same_owner(existing, current_user), False

    if data.lot_id is not None:
        crop_id = (await _load_lot(session, current_user, data.lot_id)).crop_id
    else:
        assert data.batch_id is not None  # QualityReadingIn guarantees exactly one subject
        crop_id = (await _load_batch(session, current_user, data.batch_id)).crop_id
    version, rules = await _required_rules(session, crop_id)

    reading = grade_engine.Reading(
        parameter_code=data.parameter_code,
        value=data.measurement.value,
        unit=data.measurement.unit,
        stage=data.stage,
        source=data.source,
        measured_at=data.measured_at,
        lab_nabl_no=data.lab_nabl_no,
    )
    if violations := grade_engine.check_plausibility(rules, reading):
        p = rules.parameter(data.parameter_code)
        limits = p.model_dump(mode="json", include={"unit", "plausible", "sources_allowed"}) if p else {}
        _raise_violation(violations, limits)
    instrument = await _check_instrument(session, current_user, data)
    trail = grade_engine.check_trail(rules, await _prior_readings(session, data), reading)
    if trail is not None and not (trail.overridable and data.reason_code):
        raise MoistureTrailViolationError(
            trail.message, {**trail.model_dump(), "reason_code_accepted": trail.overridable}
        )

    row = QualityReading(
        id=data.client_id,
        fpo_id=current_user.fpo_id,
        lot_id=data.lot_id,
        batch_id=data.batch_id,
        stage=data.stage,
        parameter_code=data.parameter_code,
        value=data.measurement.value,
        unit=data.measurement.unit,
        method_ref=data.method_ref,
        source=data.source,
        instrument_id=data.instrument_id,
        calibration_due_on_at_time=instrument.calibration_due_on if instrument else None,
        lab_name=data.lab_name,
        lab_nabl_no=data.lab_nabl_no,
        sample_id=data.sample_id,
        certificate_photo_id=data.certificate_photo_id,
        evidence_photo_id=data.evidence_photo_id,
        measured_by_user_id=current_user.user_id,
        measured_at=data.measured_at,
        device_time=data.device_time,
        gps_time=data.gps_time,
        server_received_at=utcnow(),
        gps=WKTElement(f"POINT({data.gps.lon} {data.gps.lat})", srid=4326) if data.gps else None,
        reason_code=data.reason_code,
        profile_version_id=version.id,
    )
    session.add(row)
    try:
        await session.commit()
    except IntegrityError as e:
        # A concurrent retry with the same client id won the insert: answer as a duplicate (D-005).
        await session.rollback()
        existing = await session.get(QualityReading, data.client_id)
        if existing is None:
            # Lot, batch and instrument were checked above, so the failing reference is a photo id that
            # does not exist (yet); quality does not import the events models to pre-check it (D-004).
            raise ValidationFailedError("Unknown photo id.", {"photo_ids": _photo_ids(data)}) from e
        return _same_owner(existing, current_user), False
    await session.refresh(row)  # return what the database stored (UTC times), same as a duplicate resend
    if trail is not None:
        _enqueue_trail_override(row)
    return row, True


async def list_readings(
    session: AsyncSession,
    user: CurrentUser,
    subject: Literal["lot", "batch"],
    subject_id: uuid.UUID,
    cursor: uuid.UUID | None,
    limit: int,
) -> Page[QualityReadingOut]:
    """List the readings recorded on a lot or a batch.

    Args:
        session: database session.
        user: the caller.
        subject: `lot` or `batch`.
        subject_id: its id.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of readings, oldest client id first.

    Raises:
        NotFoundError: the lot or batch is not visible to the caller (404).
        ForbiddenError: a farmer asking for a batch (403).
    """
    if subject == "lot":
        await _load_lot(session, user, subject_id)
        query = select(QualityReading).where(QualityReading.lot_id == subject_id)
    else:
        await _load_batch(session, user, subject_id)
        query = select(QualityReading).where(QualityReading.batch_id == subject_id)
    items, next_cursor, more = await _page(session, query, QualityReading.id, cursor, limit, reading_out)
    return Page[QualityReadingOut](items=items, next_cursor=next_cursor, has_more=more)


async def lot_gate_passes(session: AsyncSession, lot_id: uuid.UUID, gate: str = "ready_for_sale") -> bool:
    """Tell whether a lot's readings pass a profile lot gate, e.g. ready for sale (Dataflow Stage 5).

    Args:
        session: database session (the caller has already scoped the lot to its FPO).
        lot_id: the lot.
        gate: gate name in the profile's `lot_gates`.

    Returns:
        False when the lot does not exist or its crop has no published profile (nothing can vouch for it);
        otherwise `grade_engine.lot_gate` on the lot's readings.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    lot = await session.get(Lot, lot_id)
    version = await latest_profile_version_for_crop(session, lot.crop_id) if lot else None
    if version is None:
        return False
    rows = (await session.scalars(select(QualityReading).where(QualityReading.lot_id == lot_id))).all()
    return grade_engine.lot_gate(_rules(version), gate, [_engine_reading(r) for r in rows])


# ---------------------------------------------------------------------------------------------------------
# Grading (FR48, FR49, FR51; Dataflow Stage 8)
# ---------------------------------------------------------------------------------------------------------


def _check_declared(rules: StandardsProfileRules, declared: str | None) -> None:
    """Reject a declared grade the profile does not know (FR49), e.g. "A" for AGMARK chilli.

    Args:
        rules: the profile rules.
        declared: the declared grade, or None.

    Raises:
        UnknownGradeForProfileError: `unknown_grade_for_profile` (422), with the valid grades in `details`.
    """
    if declared is not None and grade_engine.rank(rules, declared) is None:
        raise UnknownGradeForProfileError(
            details={"declared": declared, "grades": [*rules.grades, rules.fail_grade]}
        )


async def compute_grade_for_batch(
    session: AsyncSession,
    current_user: CurrentUser,
    batch_id: uuid.UUID,
    declared_grade: str | None,
    reading_ids: Sequence[uuid.UUID] | None = None,
) -> GradeComputation:
    """Run the engine on a batch's readings and store the result (FR48, FR49); B09 re-runs it at approval.

    Args:
        session: database session.
        current_user: the caller; becomes `declared_by` when a grade is declared.
        batch_id: the batch.
        declared_grade: grade the QC officer declares, or None to compute only.
        reading_ids: readings of the batch to use; None uses all of them.

    Returns:
        The committed computation: status `incomplete` (a required reading is missing),
        `declared_above_computed` (FR49 blocks approval) or `ok`.

    Raises:
        ForbiddenError: a farmer (403).
        NotFoundError: batch not in the caller's FPO, or a reading id not on this batch (404).
        NoPublishedProfileError: the crop has no published profile (422).
        UnknownGradeForProfileError: the declared grade is not in the profile (422).

    Side effects:
        Inserts a `grade_computations` row and commits. The batch row itself is not touched (B09 owns it).
    """
    batch = await _load_batch(session, current_user, batch_id)
    version, rules = await _required_rules(session, batch.crop_id)
    _check_declared(rules, declared_grade)
    query = select(QualityReading).where(QualityReading.batch_id == batch.id)
    if reading_ids is not None:
        query = query.where(QualityReading.id.in_(reading_ids))
    rows = (await session.scalars(query)).all()
    if reading_ids is not None and (missing := set(reading_ids) - {r.id for r in rows}):
        raise NotFoundError("Reading not on this batch.", {"reading_ids": sorted(str(i) for i in missing)})
    result = grade_engine.compute(rules, [_engine_reading(r) for r in rows])
    status = GradeStatus.INCOMPLETE if result.status == "incomplete" else GradeStatus.OK
    verdict = (
        grade_engine.declared_vs_computed(rules, declared_grade, result.grade) if declared_grade else "ok"
    )
    if status == GradeStatus.OK and verdict == "declared_above_computed":
        status = GradeStatus.DECLARED_ABOVE_COMPUTED
    computation = GradeComputation(
        batch_id=batch.id,
        profile_version_id=version.id,
        computed_grade=result.grade,
        declared_grade=declared_grade,
        declared_by=current_user.user_id if declared_grade else None,
        per_parameter={code: p.model_dump(mode="json") for code, p in result.per_parameter.items()},
        status=status,
        lab_certified=result.lab_certified,
        computed_at=utcnow(),
    )
    session.add(computation)
    await session.commit()
    return computation


async def grade_batch(
    session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID, data: GradingIn
) -> GradeComputation:
    """Handle `POST /batches/{id}/grading`: record inline readings, then compute and store the grade.

    The declared grade is checked before any reading is stored, so a bad grade stores nothing. Inline
    readings are committed one by one (as in sync push); a later failing one leaves the earlier ones stored,
    and a retry with the same client ids is a no-op for those.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.
        data: declared grade, reading ids and inline readings.

    Returns:
        The committed computation (see `compute_grade_for_batch`).

    Raises:
        UnknownGradeForProfileError: the declared grade is not in the profile (422).
        AppError: any error of `create_reading` for an inline reading, or of `compute_grade_for_batch`.

    Side effects:
        Inserts readings and the computation; may enqueue `rules.check_lot` (trail override).
    """
    batch = await _load_batch(session, user, batch_id)
    _check_declared((await _required_rules(session, batch.crop_id))[1], data.declared_grade)
    inline_ids: list[uuid.UUID] = []
    for reading in data.readings:
        row, _ = await create_reading(
            session, user, reading.model_copy(update={"batch_id": batch_id, "lot_id": None})
        )
        inline_ids.append(row.id)
    ids = None if data.reading_ids is None else [*data.reading_ids, *inline_ids]
    return await compute_grade_for_batch(session, user, batch_id, data.declared_grade, ids)


async def latest_grade(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> GradeComputation:
    """Load the most recent grade computation of a batch.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.

    Returns:
        The latest computation.

    Raises:
        ForbiddenError: a farmer (403).
        NotFoundError: batch not visible, or never graded (404).
    """
    await _load_batch(session, user, batch_id)
    row = await session.scalar(
        select(GradeComputation)
        .where(GradeComputation.batch_id == batch_id)
        .order_by(GradeComputation.computed_at.desc())
        .limit(1)
    )
    if row is None:
        raise NotFoundError("The batch has not been graded yet.", {"batch_id": str(batch_id)})
    return row
