"""Events use cases: event versions (create, correct, undo), sync push dispatch, photo confirm, timeline.

One code path writes every event version, whether it arrives in a sync push or through the REST correction
and undo routes: idempotent on the version's client id, `version_no` = max + 1, rules on who may correct or
undo, three clocks stamped, photos registered as `pending_upload` with presigned PUTs, explicit audit rows.

Serves: FR3, FR4 (offline sync), FR6 (farmer undo), FR25 (immutable events, corrections with reason),
FR26 (GPS at submission), FR59 (person vs system entries), FR61 (evidence photos), FR63 (date-ordered
timeline), FR69 (`entered_remotely` in assist mode), Arch §Offline-first, backend-design.md §3 (binding),
plan §13 A3, A4, F1, CLAUDE.md §6 (assist mode recorded), D-005, D-011, D-014; B15: push kinds `farmer`
(D-031) and `assist_session`, per-entry `assist_session_id` (D-032); B16: push kind `lot_intake` (D-040),
assist session per kind (D-042); B21: an entry Postgres refuses (NUL, value out of range) is that entry's
`validation_error`, never the batch's 500 (Q04-1).
Callers: `events.router`, `events.sync_router`, `events.pull_service` (`event_outs`);
tests/unit/test_events_service.py, tests/integration/test_sync.py. No other module calls it yet (`__all__` is
empty).
"""

import asyncio
import dataclasses
import inspect
import logging
import uuid
from collections.abc import Awaitable, Callable, Mapping, Sequence
from contextvars import Token
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Any

from geoalchemy2 import WKTElement
from pydantic import BaseModel, TypeAdapter, ValidationError
from sqlalchemy import func, insert, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.exc import DBAPIError, IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import storage, task_names
from agritrace.core.audit import AUDIT_LOG, AuditContext, reset_audit_context, set_audit_context
from agritrace.core.auth import CurrentUser, assist_session_farmer
from agritrace.core.config import get_settings
from agritrace.core.enums import ChangeKind, EventStatus, PhotoStatus, Role
from agritrace.core.errors import (
    AppError,
    AssistSessionInvalidError,
    ClientIdConflictError,
    ForbiddenError,
    NotFoundError,
    ReasonRequiredError,
    StaleVersionError,
    UndoWindowClosedError,
    ValidationFailedError,
    append_only_error,
    data_error,
)
from agritrace.core.ids import uuid7
from agritrace.core.schemas import ErrorBody, GeoPoint, ThreeClocks, has_nul
from agritrace.core.time import clock_skew, utcnow
from agritrace.modules.events import evidence
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto, SyncCursor, SyncMetric
from agritrace.modules.events.schemas import (
    AnyEventVersion,
    CorrectionIn,
    EventOut,
    EventPhotoOut,
    EventVersionIn,
    PhotoConfirmOut,
    PhotosConfirmIn,
    PhotoUpload,
    SyncEntry,
    SyncPushIn,
    SyncPushOut,
    SyncResult,
    UndoIn,
)
from agritrace.modules.identity import service as identity_service
from agritrace.modules.identity.models import ConsentRecord
from agritrace.modules.lots_batches import service as lots_batches_service
from agritrace.modules.lots_batches.models import Batch, Lot
from agritrace.modules.quality import service as quality_service
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Farmer
from agritrace.modules.rules_flags import service as rules_flags_service

__all__: list[str] = []

log = logging.getLogger(__name__)

# shortcut: limits are constants until B13 field configuration carries them per tenant.
CLOCK_SKEW_LIMIT = timedelta(hours=1)
EVENT_RADIUS_M = 100.0  # FR69 radius around the pin when the plot has no walked boundary
EVENT_BUFFER_M = 50.0  # FR32 GPS-drift buffer
UNDO_WINDOW = timedelta(hours=24)
CORRECTORS = (Role.FIELD_OFFICER, Role.FPO_ADMIN)
CLOCK_SKEW_HINT = "clock_skew"
_VERSION: TypeAdapter[AnyEventVersion] = TypeAdapter(EventVersionIn)


@dataclass
class PendingPhoto:
    """A photo row still waiting for its upload."""

    id: uuid.UUID
    key: str
    content_type: str
    sha256: str
    size_bytes: int
    expires_at: datetime


@dataclass
class Written:
    """What writing one version produced (or found already stored)."""

    version_id: uuid.UUID
    event_id: uuid.UUID
    created: bool
    pending: list[PendingPhoto] = field(default_factory=list)
    hints: list[str] = field(default_factory=list)


class _LostRace(Exception):  # noqa: N818 - control flow, never leaves this module
    """`INSERT … ON CONFLICT DO NOTHING` inserted nothing: a concurrent retry stored the version first."""


# --- pure rules (unit-tested) ---------------------------------------------------------------------------


def validation_details(error: ValidationError) -> list[dict[str, Any]]:
    """Render a pydantic error like the API's `validation_error` details.

    Args:
        error: the validation error.

    Returns:
        One `{loc, msg, type}` per failing field.
    """
    return [{"loc": e["loc"], "msg": e["msg"], "type": e["type"]} for e in error.errors()]


def parse_version(data: Mapping[str, Any]) -> AnyEventVersion:
    """Validate the `data` of an `event_version` entry against the union of event types (D-014).

    Args:
        data: the raw entry data.

    Returns:
        The typed version (variant chosen by `event_type`).

    Raises:
        ValidationFailedError: unknown `event_type`, bad payload or inconsistent fields (422).
    """
    try:
        return _VERSION.validate_python(data)
    except ValidationError as e:
        raise ValidationFailedError(details=validation_details(e)) from e


def check_owner(entered_by: uuid.UUID, fpo_id: uuid.UUID, user: CurrentUser) -> None:
    """Decide whether a resent client id is the caller's own record (D-005).

    Args:
        entered_by: who stored the existing record.
        fpo_id: its FPO.
        user: the caller resending the id.

    Raises:
        ClientIdConflictError: the id belongs to another user or FPO (`client_id_conflict`, 409).
    """
    if entered_by != user.user_id or fpo_id != user.fpo_id:
        raise ClientIdConflictError(details={"reason": "client id owned by another user"})


def check_version_no(version_no: int, current_max: int | None) -> None:
    """Require the next version number (D-005: concurrent corrections resolve by rejection).

    Args:
        version_no: the version sent.
        current_max: highest stored version of the event, or None for a new event.

    Raises:
        StaleVersionError: `version_no` is not `current_max + 1` (`stale_version`, 409).
    """
    expected = (current_max or 0) + 1
    if version_no != expected:
        raise StaleVersionError(details={"expected_version_no": expected, "sent": version_no})


def check_change(
    change_kind: str,
    user: CurrentUser,
    reason_code: str | None,
    original_by: uuid.UUID,
    original_device_time: datetime,
    at: datetime,
) -> None:
    """Apply who may correct or undo an event (FR6, FR25).

    Args:
        change_kind: `create`, `correct` or `undo`.
        user: the caller.
        reason_code: the version's reason code.
        original_by: who entered version 1.
        original_device_time: device time of version 1.
        at: device time of the undo (phone clock; server now for online undo).

    Raises:
        ForbiddenError: a correction by anyone but a field officer or FPO admin, or an undo by anyone but
            the farmer who entered the event (403).
        ReasonRequiredError: a correction without `reason_code` (422).
        UndoWindowClosedError: an undo more than 24 hours after capture (409).
    """
    if change_kind == "correct":
        if user.role not in CORRECTORS:
            raise ForbiddenError(details={"required_roles": [str(r) for r in CORRECTORS]})
        if not (reason_code and reason_code.strip()):
            raise ReasonRequiredError(details={"field": "reason_code"})
    elif change_kind == "undo":
        if user.role != Role.FARMER or original_by != user.user_id:
            raise ForbiddenError("Only the farmer who entered it can undo an entry.")
        if at - original_device_time > UNDO_WINDOW:
            raise UndoWindowClosedError(details={"window_hours": 24})


def skew_hints(clocks: ThreeClocks) -> list[str]:
    """Hint rules_flags (B08) that the phone clock looks wrong; the entry is stored regardless.

    A device time far in the past of server time is normal for offline entries, so against the server
    clock only a device time in the future counts; against GPS time both directions count.

    Args:
        clocks: the entry's clocks with `server_received_at` set.

    Returns:
        `["clock_skew"]` or an empty list.
    """
    skew = clock_skew(clocks, CLOCK_SKEW_LIMIT)
    return [CLOCK_SKEW_HINT] if skew is not None and (clocks.gps_time or skew > timedelta(0)) else []


def _point(gps: GeoPoint | None) -> WKTElement | None:
    """Convert an API point to a geography value.

    Args:
        gps: the point, or None.

    Returns:
        A WKT element in SRID 4326, or None.
    """
    return WKTElement(f"POINT({gps.lon} {gps.lat})", srid=4326) if gps else None


# --- enqueueing ------------------------------------------------------------------------------------------


async def enqueue(name: str, **kwargs: Any) -> None:
    """Send a Celery task by name after a commit (D-004: no import of other modules' tasks).

    Args:
        name: task name from `core.task_names`.
        **kwargs: task keyword arguments (JSON-safe).

    Side effects:
        Publishes one message. A broker failure is logged, not raised: the data is already committed and
        no retry runs inside the request path (rules sweeps re-check).
    """
    from agritrace.worker import app  # imported late: the worker reads broker settings on import

    try:
        await asyncio.to_thread(app.send_task, name, kwargs=kwargs)
    except Exception:  # noqa: BLE001 - see Side effects
        log.warning("could not enqueue %s %s", name, kwargs, exc_info=True)


# --- writing versions ------------------------------------------------------------------------------------


async def _check_subject(session: AsyncSession, user: CurrentUser, v: AnyEventVersion) -> None:
    """Check the caller may write events on this lot or batch, and that the plot is the lot's (FR24, FR69).

    Args:
        session: database session.
        user: the caller.
        v: the version.

    Raises:
        ForbiddenError: viewers; farmers on batches; an assist session for another farmer, or any assist
            session on a batch event (403, D-042).
        NotFoundError: lot or batch not in the caller's FPO, or a farmer's lot of someone else (404).
        ValidationFailedError: `plot_id` is not the lot's plot, or is set on a batch event (422).
    """
    if user.role == Role.VIEWER:
        raise ForbiddenError(details={"reason": "viewers cannot record events"})
    if v.lot_id is not None:
        lot = await session.get(Lot, v.lot_id)
        if lot is None or lot.fpo_id != user.fpo_id:
            raise NotFoundError(details={"lot_id": str(v.lot_id)})
        if user.role == Role.FARMER:
            owner = await session.scalar(select(Farmer.user_id).where(Farmer.id == lot.farmer_id))
            if owner != user.user_id:
                raise NotFoundError(details={"lot_id": str(v.lot_id)})
        if user.on_behalf_of_farmer_id is not None and lot.farmer_id != user.on_behalf_of_farmer_id:
            raise ForbiddenError("The assist session is for another farmer.")
        plot_ok = v.plot_id in (None, lot.plot_id)  # FR69 checks the GPS fix against this plot
    else:
        if user.role == Role.FARMER:
            raise ForbiddenError(details={"reason": "farmers cannot record batch events"})
        if user.on_behalf_of_farmer_id is not None:  # D-042: a batch belongs to many farmers
            raise ForbiddenError("A batch event cannot be recorded in assist mode.")
        batch = await session.get(Batch, v.batch_id)
        if batch is None or batch.fpo_id != user.fpo_id:
            raise NotFoundError(details={"batch_id": str(v.batch_id)})
        plot_ok = v.plot_id is None
    if not plot_ok:
        raise ValidationFailedError("plot_id must be the lot's plot.", {"plot_id": str(v.plot_id)})


async def _existing(session: AsyncSession, user: CurrentUser, version_id: uuid.UUID) -> Written | None:
    """Find a version already stored under this client id and re-arm its pending photo uploads.

    Args:
        session: database session.
        user: the caller.
        version_id: the client id.

    Returns:
        The duplicate (with photos still `pending_upload`), or None when nothing is stored.

    Raises:
        ClientIdConflictError: the id is another user's or FPO's version.

    Side effects:
        Moves `upload_url_expires_at` of pending photos 15 minutes ahead (an allowed column).
    """
    row = await session.get(EventVersion, version_id)
    if row is None:
        return None
    event = await session.get(Event, row.event_id)
    assert event is not None  # FK
    check_owner(row.entered_by_user_id, event.fpo_id, user)
    query = select(EvidencePhoto).where(
        EvidencePhoto.event_version_id == version_id, EvidencePhoto.status == PhotoStatus.PENDING_UPLOAD
    )
    expires = utcnow() + evidence.UPLOAD_TTL
    pending = []
    for photo in await session.scalars(query):
        photo.upload_url_expires_at = expires
        pending.append(
            PendingPhoto(
                photo.id, photo.object_key, photo.content_type, photo.sha256_client, photo.size_bytes, expires
            )
        )
    return Written(row.id, row.event_id, created=False, pending=pending)


async def _entered_remotely(session: AsyncSession, user: CurrentUser, v: AnyEventVersion) -> bool:
    """Tell whether an officer in assist mode entered the event away from the plot (FR69).

    Args:
        session: database session.
        user: the caller.
        v: the version.

    Returns:
        True only in assist mode, with a plot and a GPS fix outside the plot's radius plus buffer.

    Raises:
        NotFoundError: the plot does not exist (from `event_within_plot`).
    """
    if user.assist_session_id is None or v.plot_id is None or v.gps is None:
        return False
    return not await registry_service.event_within_plot(
        session, v.gps, v.plot_id, EVENT_RADIUS_M, EVENT_BUFFER_M
    )


async def _add_version(
    session: AsyncSession,
    user: CurrentUser,
    version_id: uuid.UUID,
    v: AnyEventVersion,
    action: str,
    app_version: str | None,
) -> Written:
    """Insert one event version (and its event on version 1, its photos and audit row); no commit.

    Args:
        session: database session.
        user: the caller; `entered_by` and assist fields come from here, never the body.
        version_id: the version's client id.
        v: the validated version.
        action: audit action, e.g. `sync.push`, `event.correct`.
        app_version: app version from the push envelope, if any.

    Returns:
        What was written, or the duplicate found.

    Raises:
        ClientIdConflictError: version, event or photo id owned by someone else.
        ForbiddenError | NotFoundError: from `_check_subject` and `check_change`.
        StaleVersionError: `version_no` is not max + 1 (or version 1 of an existing event).
        ValidationFailedError: a later version changes event type or subject.
        ReasonRequiredError | UndoWindowClosedError: from `check_change`.
        _LostRace: a concurrent request stored the same version id first.

    Side effects:
        Inserts `events` (ORM, audited) on version 1; `event_versions` and `evidence_photos` with Core
        `INSERT` plus an explicit `audit_log` row (the ORM listener does not see Core statements).
    """
    if (duplicate := await _existing(session, user, version_id)) is not None:
        return duplicate
    await _check_subject(session, user, v)
    now = utcnow()
    event = await session.get(Event, v.event_id, with_for_update=True)
    if event is not None and event.fpo_id != user.fpo_id:
        raise ClientIdConflictError(details={"event_id": str(v.event_id)})
    supersedes = None
    if v.version_no == 1:
        check_version_no(1, None if event is None else 1)
        event = Event(
            id=v.event_id,
            fpo_id=user.fpo_id,
            subject_type=v.subject_type,
            lot_id=v.lot_id,
            batch_id=v.batch_id,
            plot_id=v.plot_id,
            event_type=v.event_type,
            instance_no=v.instance_no,
            occurred_on=v.occurred_on,
        )
        session.add(event)
        await session.flush()
    else:
        if event is None:
            raise NotFoundError(details={"event_id": str(v.event_id)})
        if (event.event_type, event.lot_id, event.batch_id) != (v.event_type, v.lot_id, v.batch_id):
            raise ValidationFailedError("A correction cannot change the event type or subject.")
        current_max = await session.scalar(
            select(func.max(EventVersion.version_no)).where(EventVersion.event_id == event.id)
        )
        check_version_no(v.version_no, current_max)
        first = await session.scalar(
            select(EventVersion).where(EventVersion.event_id == event.id, EventVersion.version_no == 1)
        )
        assert first is not None  # every event is created with version 1
        check_change(
            v.change_kind,
            user,
            v.reason_code,
            first.entered_by_user_id,
            first.device_time,
            v.clocks.device_time,
        )
        supersedes = event.current_version_id
    photo_ids = [p.client_id for p in v.photos]
    if photo_ids and await session.scalar(select(func.count()).where(EvidencePhoto.id.in_(photo_ids))):
        raise ClientIdConflictError(details={"photo_ids": [str(i) for i in photo_ids]})
    remote = await _entered_remotely(session, user, v)

    # DECISION D-005: the phone's id is the primary key; `ON CONFLICT (id) DO NOTHING` + re-read makes a
    #   retry return the original result.
    #   ADV: idempotent sync without an idempotency table.
    #   COMPROMISE: Core insert bypasses the audit listener, so the audit row is written below by hand.
    stmt = (
        pg_insert(EventVersion)
        .values(
            id=version_id,
            event_id=v.event_id,
            version_no=v.version_no,
            payload=v.payload.model_dump(mode="json", exclude_none=True),
            occurred_on=v.occurred_on,
            occurred_end_on=v.occurred_end_on,
            device_time=v.clocks.device_time,
            gps_time=v.clocks.gps_time,
            server_received_at=now,
            gps=_point(v.gps),
            gps_accuracy_m=v.gps.accuracy_m if v.gps else None,
            entered_by_user_id=user.user_id,
            on_behalf_of_farmer_id=user.on_behalf_of_farmer_id,
            assist_session_id=user.assist_session_id,
            entered_remotely=remote,
            device_id=user.device_id,
            app_version=app_version,
            change_kind=ChangeKind(v.change_kind),
            reason_code=v.reason_code,
            reason_text=v.reason_text,
            supersedes_version_id=supersedes,
            is_system_generated=False,
        )
        .on_conflict_do_nothing(index_elements=["id"])
        .returning(EventVersion.id)
    )
    if (await session.execute(stmt)).scalar_one_or_none() is None:
        raise _LostRace()
    event.current_version_id = version_id
    event.occurred_on = v.occurred_on
    event.status = EventStatus.UNDONE if v.change_kind == "undo" else EventStatus.SUBMITTED

    expires = now + evidence.UPLOAD_TTL
    pending = [
        PendingPhoto(
            p.client_id,
            evidence.object_key(user.fpo_id, v.occurred_on.year, v.event_id, p.client_id, p.content_type),
            p.content_type,
            p.sha256,
            p.size_bytes,
            expires,
        )
        for p in v.photos
    ]
    if v.photos:
        await session.execute(
            insert(EvidencePhoto),
            [
                {
                    "id": p.client_id,
                    "event_version_id": version_id,
                    "bucket": get_settings().s3_bucket_evidence,
                    "object_key": row.key,
                    "content_type": p.content_type,
                    "size_bytes": p.size_bytes,
                    "sha256_client": p.sha256,
                    "status": PhotoStatus.PENDING_UPLOAD,
                    "upload_url_expires_at": expires,
                }
                for p, row in zip(v.photos, pending, strict=True)
            ],
        )
    await session.execute(
        insert(AUDIT_LOG).values(
            id=uuid7(),
            at=now,
            actor_user_id=user.user_id,
            on_behalf_of_farmer_id=user.on_behalf_of_farmer_id,
            assist_session_id=user.assist_session_id,
            device_id=user.device_id,
            gps=f"SRID=4326;POINT({v.gps.lon} {v.gps.lat})" if v.gps else None,
            action=action,
            entity_type="event_versions",
            entity_id=version_id,
            # shortcut: request_id is not copied (the audit context has no public getter); add one in core
            #   when the audit export (B10) needs to join push requests.
            diff={
                "event_id": str(v.event_id),
                "event_type": v.event_type.value,
                "version_no": v.version_no,
                "change_kind": v.change_kind,
                # B20: the audit search shows why a correction or undo was made (P06); creates carry none.
                **{k: r for k, r in (("reason_code", v.reason_code), ("reason_text", v.reason_text)) if r},
                # The phone-declared EXIF lives here, append-only; the verify task fills the photo's
                # exif_* columns with what it reads, so both are kept and neither is overwritten.
                "photos": [p.model_dump(mode="json", exclude={"sha256", "size_bytes"}) for p in v.photos],
            },
        )
    )
    clocks = v.clocks.model_copy(update={"server_received_at": now})
    return Written(version_id, v.event_id, created=True, pending=pending, hints=skew_hints(clocks))


async def write_version(
    session: AsyncSession,
    user: CurrentUser,
    version_id: uuid.UUID,
    v: AnyEventVersion,
    action: str,
    app_version: str | None = None,
) -> Written:
    """Write one event version in its own transaction; a lost race with the same client id is a duplicate.

    Args:
        session: database session (committed or rolled back here).
        user: the caller.
        version_id: the version's client id.
        v: the validated version.
        action: audit action.
        app_version: app version from the push envelope, if any.

    Returns:
        What was written, or the duplicate found.

    Raises:
        AppError: every error of `_add_version`; `stale_version` when another version took the number and
            this client id is not stored; `append_only_violation` (SQLSTATE 23001).

    Side effects:
        Commits the version, its event, photos and audit rows, or rolls everything back.
    """
    try:
        written = await _add_version(session, user, version_id, v, action, app_version)
        await session.commit()
    except (IntegrityError, _LostRace, StaleVersionError) as e:
        # A retry overlapping the first send (2G) can lose at the version-number check or the insert;
        # when the same client id is stored by then, it is a duplicate, not a conflict (plan §13 A3).
        await session.rollback()
        if (mapped := append_only_error(e)) is not None:
            raise mapped from e
        found = await _existing(session, user, version_id)
        if found is None:
            if isinstance(e, StaleVersionError):
                raise
            raise StaleVersionError(details={"event_id": str(v.event_id), "sent": v.version_no}) from e
        await session.commit()
        written = found
    return written


async def _finish(client_id: uuid.UUID, written: Written) -> SyncResult:
    """Build the result of a committed version and start the follow-up work.

    Args:
        client_id: the entry's client id.
        written: what was written.

    Returns:
        `accepted` or `duplicate` with the presigned uploads still owed.

    Raises:
        ValueError: a stored SHA-256 is malformed (cannot happen: validated at entry).

    Side effects:
        A new version without photos enqueues `rules.check_event` (with hints such as `clock_skew`); with
        photos, `events.verify_photo` enqueues it after upload.
    """
    uploads: list[PhotoUpload] = [
        evidence.upload_instruction(p.id, p.key, p.content_type, p.sha256, p.size_bytes, p.expires_at)
        for p in written.pending
    ]
    if written.created and not written.pending:
        await enqueue(
            task_names.RULES_CHECK_EVENT,
            event_id=str(written.event_id),
            version_id=str(written.version_id),
            hints=written.hints,
        )
    status = "accepted" if written.created else "duplicate"
    return SyncResult(client_id=client_id, status=status, server_id=written.version_id, photo_uploads=uploads)


# --- sync push -------------------------------------------------------------------------------------------


async def _push_event_version(
    session: AsyncSession, user: CurrentUser, entry: SyncEntry, app_version: str
) -> SyncResult:
    """Handle `kind=event_version`.

    Args:
        session: database session.
        user: the caller.
        entry: the entry; its `client_id` is the version id.
        app_version: from the envelope.

    Returns:
        The entry result.

    Raises:
        AppError: validation and every error of `write_version`.
    """
    version = parse_version(entry.data)
    written = await write_version(session, user, entry.client_id, version, "sync.push", app_version)
    return await _finish(entry.client_id, written)


async def _push_reading(session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str) -> SyncResult:
    """Handle `kind=quality_reading` with quality's own service (it commits).

    Args:
        session: database session.
        user: the caller.
        entry: the entry; its `client_id` is the reading id.
        _: app version (unused).

    Returns:
        The entry result.

    Raises:
        AppError: every error of `quality.service.create_reading`.
    """
    row, created = await quality_service.create_reading(
        session, user, {**entry.data, "client_id": str(entry.client_id)}
    )
    return SyncResult(
        client_id=entry.client_id, status="accepted" if created else "duplicate", server_id=row.id
    )


async def _push_plot(session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str) -> SyncResult:
    """Handle `kind=plot` with registry's service, then commit and enqueue `rules.check_plot`.

    Args:
        session: database session.
        user: the caller.
        entry: the entry; its `client_id` is the plot id.
        _: app version (unused).

    Returns:
        The entry result.

    Raises:
        AppError: every error of `registry.service.create_plot_from_sync`.

    Side effects:
        Commits the plot; enqueues the plot check for a new plot.
    """
    plot, created = await registry_service.create_plot_from_sync(
        session, user, {**entry.data, "client_id": str(entry.client_id)}
    )
    await session.commit()
    if created:
        await registry_service.enqueue_plot_check(plot.id)
    return SyncResult(
        client_id=entry.client_id, status="accepted" if created else "duplicate", server_id=plot.id
    )


def _consent_body(data: Mapping[str, Any]) -> BaseModel:
    """Validate consent data with identity's own request model.

    D-004 forbids importing `identity.schemas`, so the model is taken from `record_consent`'s signature:
    one schema, no copy. TODO(B02): give identity a dict-accepting entry like quality's `create_reading`.

    Args:
        data: the entry data with `client_id`.

    Returns:
        The validated `ConsentIn`.

    Raises:
        ValidationFailedError: the data does not match (422).
    """
    model: type[BaseModel] = inspect.signature(identity_service.record_consent).parameters["body"].annotation
    try:
        return model.model_validate(data)
    except ValidationError as e:
        raise ValidationFailedError(details=validation_details(e)) from e


async def _push_consent(session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str) -> SyncResult:
    """Handle `kind=consent` with identity's `record_consent` (it commits).

    Args:
        session: database session.
        user: the caller.
        entry: the entry; its `client_id` is the consent id.
        _: app version (unused).

    Returns:
        The entry result.

    Raises:
        AppError: validation and every error of `identity.service.record_consent`.
    """
    existed = await session.get(ConsentRecord, entry.client_id) is not None
    body = _consent_body({**entry.data, "client_id": str(entry.client_id)})
    out = await identity_service.record_consent(session, user, body)  # type: ignore[arg-type]
    return SyncResult(
        client_id=entry.client_id, status="duplicate" if existed else "accepted", server_id=out.id
    )


async def _push_flag_resolution(
    session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str
) -> SyncResult:
    """Handle `kind=flag_resolution` with rules_flags' `resolve_from_sync` (it commits).

    Args:
        session: database session.
        user: the caller.
        entry: the entry; `data` is `{flag_id, resolution, reason_code, note}`.
        _: app version (unused).

    Returns:
        `accepted` (resolved now) or `duplicate` (the same resolution was already stored); `server_id` is
        the flag id.

    Raises:
        AppError: every error of `rules_flags.service.resolve_from_sync` (validation, not found, forbidden,
            `flag_not_open`, `resolution_forbidden`, `reason_required`).
    """
    flag_id, resolved = await rules_flags_service.resolve_from_sync(session, user, entry.data)
    status = "accepted" if resolved else "duplicate"
    return SyncResult(client_id=entry.client_id, status=status, server_id=flag_id)


async def _push_farmer(session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str) -> SyncResult:
    """Handle `kind=farmer` with registry's service, then commit (D-031).

    Args:
        session: database session.
        user: the caller, with no assist context (`push` clears it for this kind).
        entry: the entry; its `client_id` is the farmer id.
        _: app version (unused).

    Returns:
        `accepted` (stored `pending` now) or `duplicate` (this FPO already has the id).

    Raises:
        AppError: every error of `registry.service.create_farmer_from_sync` (`forbidden`, `validation_error`,
            `client_id_conflict`, `farmer_phone_taken`, `field_required`).
        sqlalchemy.exc.IntegrityError: the retry after a lost race fails on a constraint again.

    Side effects:
        Commits the farmer and its `users` / `memberships` / `audit_log` rows. On a lost insert race (the
        same id or phone committed by a concurrent request) rolls back and runs once more.
    """
    # DECISION D-031: offline onboarding is a push kind idempotent on the phone's farmer id, like plots.
    #   ADV: one outbox path (batching, retry, per-entry result); consent and plot entries keep the id.
    #   COMPROMISE: one more kind in the server, both clients and the spec; a rejected farmer leaves its
    #     consent and plot entries rejected too, for the officer to fix.
    data = {**entry.data, "client_id": str(entry.client_id)}
    try:
        farmer, created = await registry_service.create_farmer_from_sync(session, user, data)
        await session.commit()
    except IntegrityError:
        # The online POST with the same id (or phone) committed first; the second run sees its row and
        # answers duplicate, client_id_conflict or farmer_phone_taken instead of a 500.
        await session.rollback()
        farmer, created = await registry_service.create_farmer_from_sync(session, user, data)
        await session.commit()
    return SyncResult(
        client_id=entry.client_id, status="accepted" if created else "duplicate", server_id=farmer.id
    )


async def _push_assist_session(
    session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str
) -> SyncResult:
    """Handle `kind=assist_session` with identity's `start_assist` (it commits; D-032).

    Args:
        session: database session.
        user: the caller.
        entry: the entry; its `client_id` is the session id.
        _: app version (unused).

    Returns:
        `accepted` (session stored now) or `duplicate` (this officer already started it for this farmer).

    Raises:
        AppError: every error of `identity.service.start_assist_from_sync` (`forbidden`, `validation_error`,
            `not_found`, `conflict`).

    Side effects:
        A new session inserts an `assist_sessions` row and commits through `start_assist`; that table is
        not `Audited`, so no `audit_log` row is written (the row itself records officer, farmer and start).
    """
    row, created = await identity_service.start_assist_from_sync(
        session, user, {**entry.data, "client_id": str(entry.client_id)}
    )
    return SyncResult(
        client_id=entry.client_id, status="accepted" if created else "duplicate", server_id=row.id
    )


async def _push_lot_intake(session: AsyncSession, user: CurrentUser, entry: SyncEntry, _: str) -> SyncResult:
    """Handle `kind=lot_intake` with lots_batches' `create_intake_from_sync`, then commit (D-040).

    Args:
        session: database session.
        user: the caller, with no assist context (`_entry_caller` clears it for this kind).
        entry: the entry; its `client_id` is the intake id, `data` is `IntakeIn` without `client_id`.
        _: app version (unused).

    Returns:
        `accepted` (lot received now) or `duplicate` (this FPO already has the intake id for this lot);
        `server_id` is the intake id.

    Raises:
        AppError: every error of `lots_batches.service.create_intake_from_sync` (`validation_error`,
            `forbidden`, `field_required`, `client_id_conflict`, `not_found`, `gate_not_met`).

    Side effects:
        Commits the intake, the lot's new state and the flags the lot rules refreshed.
    """
    # DECISION D-040: the QC phone receives a lot through a push kind backed by the intake service.
    #   ADV: one intake record (shares, reconciliation, public page read `lot_intakes`), offline intake at
    #     the collection centre, the house push-kind pattern; the server re-runs weight, moisture and rules.
    #   COMPROMISE: one more kind in the server, the spec and both clients; an `intake` event version stays
    #     a timeline note that receives nothing.
    intake, _flags, created = await lots_batches_service.create_intake_from_sync(
        session, user, {**entry.data, "client_id": str(entry.client_id)}
    )
    await session.commit()
    return SyncResult(
        client_id=entry.client_id, status="accepted" if created else "duplicate", server_id=intake.id
    )


Handler = Callable[[AsyncSession, CurrentUser, SyncEntry, str], Awaitable[SyncResult]]
HANDLERS: dict[str, Handler] = {
    "event_version": _push_event_version,
    "quality_reading": _push_reading,
    "plot": _push_plot,
    "consent": _push_consent,
    "flag_resolution": _push_flag_resolution,
    "farmer": _push_farmer,
    "assist_session": _push_assist_session,
    "lot_intake": _push_lot_intake,
}


NO_ASSIST_KINDS = frozenset({"farmer", "flag_resolution", "assist_session", "lot_intake"})


def _rejected(client_id: uuid.UUID, error: AppError) -> SyncResult:
    """Build a rejected entry result.

    Args:
        client_id: the entry's client id.
        error: why.

    Returns:
        `rejected` with the error code, message and details.
    """
    body = ErrorBody(code=error.code, message=error.detail_message, details=error.details)
    return SyncResult(client_id=client_id, status="rejected", error=body)


async def _entry_caller(session: AsyncSession, user: CurrentUser, entry: SyncEntry) -> CurrentUser | None:
    """Work out the caller for one entry when its assist context differs from the request's (D-031, D-032).

    Args:
        session: database session.
        user: the caller of the request (assist context from `X-Assist-Session`, if sent).
        entry: the entry.

    Returns:
        The caller with the entry's assist context (none for the kinds in `NO_ASSIST_KINDS`, the session's
        farmer for an entry with `assist_session_id`), or None when the request's caller applies.

    Raises:
        AssistSessionInvalidError: `entry.assist_session_id` is not one of the caller's sessions.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # DECISION D-042: these kinds are the officer's own task (D-031 for `farmer`): assist context is dropped
    #   with no session lookup, whether it comes from the entry or from the header.
    #   ADV: audit rows never name a farmer the record does not belong to; M10 may attach the session to
    #     every assisted entry without spurious offline rejections.
    #   COMPROMISE: the field is silently ignored on these kinds, so a phone bug there goes unnoticed.
    if entry.kind in NO_ASSIST_KINDS:
        return dataclasses.replace(user, on_behalf_of_farmer_id=None, assist_session_id=None)
    if entry.assist_session_id is None:
        return None
    farmer_id = await assist_session_farmer(session, entry.assist_session_id, user.user_id)
    if farmer_id is None:
        raise AssistSessionInvalidError(details={"assist_session_id": str(entry.assist_session_id)})
    return dataclasses.replace(
        user, on_behalf_of_farmer_id=farmer_id, assist_session_id=entry.assist_session_id
    )


def _stamp_audit(caller: CurrentUser) -> Token[AuditContext | None]:
    """Make the audit context carry this entry's assist fields, keeping the request's actor, device and id.

    Args:
        caller: the entry's caller from `_entry_caller`.

    Returns:
        The token that restores the request's audit context (`reset_audit_context`).

    Side effects:
        Sets the audit context variable twice (the first set only reads the request's context back).
    """
    token = set_audit_context(AuditContext())
    previous = token.old_value
    if not isinstance(previous, AuditContext):  # no request context (e.g. called outside a request)
        previous = AuditContext(actor_user_id=caller.user_id, device_id=caller.device_id)
    set_audit_context(
        dataclasses.replace(
            previous,
            on_behalf_of_farmer_id=caller.on_behalf_of_farmer_id,
            assist_session_id=caller.assist_session_id,
        )
    )
    return token


async def push(session: AsyncSession, user: CurrentUser, body: SyncPushIn) -> SyncPushOut:
    """Process a sync push: each entry in order, each in its own transaction (backend-design.md §3).

    Args:
        session: database session.
        user: the caller.
        body: the envelope (limits already checked).

    Returns:
        Server time and one result per entry.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: unexpected database failures other than append-only and data errors,
            which reject only their entry (entries before it stay committed; the phone's retry turns them
            into duplicates).

    Side effects:
        Commits each accepted entry; stores `metrics[]` in `sync_metrics` and the device's last push time.
        Sets the audit context per entry with its own assist context and restores the request's after it.
    """
    # DECISION D-032: assist context travels with each entry (`assist_session_id`), not with the request.
    #   ADV: one push mixes farmers; sessions minted offline work; CLAUDE.md §6 holds for offline entries.
    #   COMPROMISE: one session read per assisted entry; ended sessions are accepted on this path only.
    results = []
    for entry in body.entries:
        token = None
        try:
            if has_nul(entry.data):
                msg = "NUL (\\u0000) is not allowed"
                raise ValidationFailedError(details=[{"loc": ["data"], "msg": msg, "type": "string_nul"}])
            caller = await _entry_caller(session, user, entry)
            token = _stamp_audit(caller) if caller else None
            results.append(await HANDLERS[entry.kind](session, caller or user, entry, body.app_version))
        except AppError as e:
            await session.rollback()
            results.append(_rejected(entry.client_id, e))
        except DBAPIError as e:
            await session.rollback()
            if (mapped := append_only_error(e) or data_error(e)) is None:
                raise
            results.append(_rejected(entry.client_id, mapped))
        finally:
            if token is not None:
                reset_audit_context(token)
    await _store_metrics(session, user, body)
    return SyncPushOut(server_time=utcnow(), results=results)


async def _store_metrics(session: AsyncSession, user: CurrentUser, body: SyncPushIn) -> None:
    """Store the phone's telemetry rows and the device's last push time (plan §13 F1).

    Args:
        session: database session.
        user: the caller; the token's device is recorded (not the body's `device_id`).
        body: the envelope.

    Side effects:
        Inserts `sync_metrics` rows, upserts `sync_cursors.last_push_at`, commits.
    """
    if user.device_id is None:
        return
    if body.metrics:
        rows = [
            {"id": uuid7(), "device_id": user.device_id, "app_version": body.app_version, **m.model_dump()}
            for m in body.metrics
        ]
        await session.execute(insert(SyncMetric), rows)
    now = utcnow()
    await session.execute(
        pg_insert(SyncCursor)
        .values(device_id=user.device_id, last_push_at=now)
        .on_conflict_do_update(index_elements=["device_id"], set_={"last_push_at": now, "updated_at": now})
    )
    await session.commit()


# --- photos, corrections, undo, timeline ---------------------------------------------------------------


async def confirm_photos(
    session: AsyncSession, user: CurrentUser, body: PhotosConfirmIn
) -> list[PhotoConfirmOut]:
    """Confirm uploaded photos: HEAD each object, record it and queue verification (D-011, FR61).

    Args:
        session: database session.
        user: the caller.
        body: the photo ids.

    Returns:
        `received` (stored, or already confirmed) or `missing` (no object, unknown id, or a photo of an
        entry someone else pushed).

    Raises:
        botocore.exceptions.ClientError: storage errors other than not-found.

    Side effects:
        Sets `s3_version_id`, `status=uploaded`, `uploaded_at`; commits; enqueues `events.verify_photo`.
    """
    prefix = f"evidence/{user.fpo_id}/"
    out, queued = [], []
    for ref in body.photos:
        photo = await session.get(EvidencePhoto, ref.client_id)
        version = (
            await session.get(EventVersion, photo.event_version_id)
            if photo and photo.event_version_id
            else None
        )
        # Only the user who pushed the entry (the uploading phone) confirms its photos.
        if (
            photo is None
            or version is None
            or version.entered_by_user_id != user.user_id
            or not photo.object_key.startswith(prefix)
        ):
            out.append(PhotoConfirmOut(client_id=ref.client_id, status="missing"))
            continue
        if photo.status == PhotoStatus.PENDING_UPLOAD:
            meta = await asyncio.to_thread(storage.head, photo.object_key)
            if meta is None:
                out.append(PhotoConfirmOut(client_id=ref.client_id, status="missing"))
                continue
            photo.s3_version_id = meta.get("VersionId")
            photo.status = PhotoStatus.UPLOADED
            photo.uploaded_at = utcnow()
            queued.append(photo.id)
        out.append(PhotoConfirmOut(client_id=ref.client_id, status="received"))
    await session.commit()
    for photo_id in queued:
        await enqueue(task_names.EVENTS_VERIFY_PHOTO, photo_id=str(photo_id))
    return out


async def correct_event(
    session: AsyncSession, user: CurrentUser, event_id: uuid.UUID, body: CorrectionIn
) -> SyncResult:
    """Add a correction version (field officer or FPO admin, with reason; FR25).

    Args:
        session: database session.
        user: the caller.
        event_id: event from the path.
        body: the new version.

    Returns:
        `accepted` or `duplicate`, with photo uploads.

    Raises:
        ValidationFailedError: `data.event_id` differs from the path or `change_kind` is not `correct`.
        AppError: every error of `write_version`.
    """
    if body.data.event_id != event_id or body.data.change_kind != "correct":
        raise ValidationFailedError("data.event_id must match the path and change_kind must be `correct`.")
    written = await write_version(session, user, body.client_id, body.data, "event.correct")
    return await _finish(body.client_id, written)


async def undo_event(
    session: AsyncSession, user: CurrentUser, event_id: uuid.UUID, body: UndoIn
) -> SyncResult:
    """Undo an own entry within 24 hours: a new version copying the current one, status `undone` (FR6).

    Args:
        session: database session.
        user: the caller (the farmer who entered the event).
        event_id: event from the path.
        body: undo version id, number, reason, clocks.

    Returns:
        `accepted` or `duplicate`.

    Raises:
        NotFoundError: no such event in the caller's FPO.
        AppError: every error of `write_version` (403 not the farmer's own, 409 `undo_window_closed`,
            409 `stale_version`).
    """
    event = await session.get(Event, event_id)
    if event is None or event.fpo_id != user.fpo_id or event.current_version_id is None:
        raise NotFoundError(details={"event_id": str(event_id)})
    current = await session.get(EventVersion, event.current_version_id)
    assert current is not None  # FK
    version = parse_version(
        {
            "event_id": event_id,
            "version_no": body.version_no,
            "change_kind": "undo",
            "subject_type": event.subject_type,
            "lot_id": event.lot_id,
            "batch_id": event.batch_id,
            "plot_id": event.plot_id,
            "event_type": event.event_type,
            "instance_no": event.instance_no,
            "occurred_on": current.occurred_on,
            "occurred_end_on": current.occurred_end_on,
            "payload": current.payload,
            "clocks": body.clocks or ThreeClocks(device_time=utcnow()),
            "reason_code": body.reason_code,
            "reason_text": body.reason_text,
        }
    )
    written = await write_version(session, user, body.client_id, version, "event.undo")
    return await _finish(body.client_id, written)


async def list_lot_events(session: AsyncSession, user: CurrentUser, lot_id: uuid.UUID) -> list[EventOut]:
    """List a lot's events with their latest versions, in date order (FR63).

    Args:
        session: database session.
        user: the caller.
        lot_id: the lot.

    Returns:
        Events ordered by `occurred_on`, `instance_no`.

    Raises:
        NotFoundError: lot not in the caller's FPO, or a farmer's request for someone else's lot.
    """
    lot = await session.get(Lot, lot_id)
    if lot is None or lot.fpo_id != user.fpo_id:
        raise NotFoundError(details={"lot_id": str(lot_id)})
    if user.role == Role.FARMER:
        owner = await session.scalar(select(Farmer.user_id).where(Farmer.id == lot.farmer_id))
        if owner != user.user_id:
            raise NotFoundError(details={"lot_id": str(lot_id)})
    rows = (
        (
            await session.execute(
                select(Event, EventVersion)
                .join(EventVersion, EventVersion.id == Event.current_version_id)
                .where(Event.lot_id == lot_id)
                .order_by(Event.occurred_on, Event.instance_no, Event.id)
            )
        )
        .tuples()
        .all()
    )
    return await event_outs(session, rows)


async def event_outs(session: AsyncSession, rows: Sequence[tuple[Event, EventVersion]]) -> list[EventOut]:
    """Shape events with their current versions and photos for the timeline and `/sync/pull` (B07).

    Args:
        session: database session.
        rows: (event, its current version) pairs, in the order to return.

    Returns:
        One `EventOut` per row; photo variant URLs are presigned GETs (the evidence bucket is private).
    """
    photos: dict[uuid.UUID, list[EventPhotoOut]] = {}
    query = select(EvidencePhoto).where(EvidencePhoto.event_version_id.in_([v.id for _, v in rows]))
    for p in await session.scalars(query):
        assert p.event_version_id is not None
        photos.setdefault(p.event_version_id, []).append(
            EventPhotoOut(id=p.id, status=p.status, variants=evidence.signed_variants(p.variants))
        )
    return [
        EventOut(
            id=e.id,
            event_type=e.event_type,
            instance_no=e.instance_no,
            status=e.status,
            occurred_on=e.occurred_on,
            occurred_end_on=v.occurred_end_on,
            version_no=v.version_no,
            change_kind=v.change_kind,
            payload=v.payload,
            entered_by_user_id=v.entered_by_user_id,
            on_behalf_of_farmer_id=v.on_behalf_of_farmer_id,
            is_system_generated=v.is_system_generated,
            reason_code=v.reason_code,
            photos=photos.get(v.id, []),
        )
        for e, v in rows
    ]
