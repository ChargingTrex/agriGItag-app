"""Sync pull: server-side changes since the phone's cursor, scoped to the caller (`GET /v1/sync/pull`).

Changes come from flags, lots, events (current version), lot intakes and the caller's notifications,
merged in (updated_at, id) order behind one opaque cursor. Evidence photos still `pending_upload` 24 h
after their entry arrived are listed as `photo_pending` on the last page, so the phone asks for fresh
upload URLs (by resending the entry). The device's cursor is recorded in `sync_cursors`.

Serves: FR4, Arch §Offline-first, backend-design.md §3 "GET /v1/sync/pull" and "Photo upload and
confirm" (24 h rule), FR61, FR70 (flag status reaches the farmer), CLAUDE.md §6 (scoped to FPO and role).
Callers: `events.sync_router` (`GET /v1/sync/pull`); tests/unit/test_pull_service.py,
tests/integration/test_bundle_pull.py.
"""

import base64
import binascii
import json
import uuid
from datetime import datetime, timedelta
from typing import Any, Literal

from sqlalchemy import ColumnElement, and_, func, or_, select, true, tuple_
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser
from agritrace.core.enums import FlagSubject, PhotoStatus, Role
from agritrace.core.errors import ValidationFailedError
from agritrace.core.time import utcnow
from agritrace.modules.events import service
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto, SyncCursor
from agritrace.modules.events.schemas import PullChange, PullOut
from agritrace.modules.lots_batches.models import Lot, LotIntake
from agritrace.modules.notifications.models import Notification
from agritrace.modules.registry.models import Farmer, Plot
from agritrace.modules.rules_flags.models import Flag

PHOTO_PENDING_AFTER = timedelta(hours=24)
# shortcut: rows are ordered by `updated_at` (transaction start, not commit), so a writer transaction longer
#   than PULL_SETTLE can commit behind an issued cursor and be skipped. Rows younger than this wait for the
#   next pull. Upgrade to a commit-ordered change sequence (trigger) if a phone ever misses a change.
PULL_SETTLE = timedelta(seconds=30)

Entity = Literal["flag", "lot", "event", "intake", "notification"]
Change = tuple[datetime, uuid.UUID, Entity, dict[str, Any]]


def encode_cursor(at: datetime, row_id: uuid.UUID) -> str:
    """Make the opaque cursor from the last change sent.

    Args:
        at: its `updated_at`.
        row_id: its id.

    Returns:
        URL-safe base64 of `[iso time, id]`, without padding.
    """
    return base64.urlsafe_b64encode(json.dumps([at.isoformat(), str(row_id)]).encode()).decode().rstrip("=")


def decode_cursor(cursor: str) -> tuple[datetime, uuid.UUID]:
    """Read a cursor made by `encode_cursor`.

    Args:
        cursor: the opaque cursor from the previous pull.

    Returns:
        (updated_at, id) of the last change the phone has.

    Raises:
        ValidationFailedError: the cursor was not issued by this endpoint (`validation_error`).
    """
    try:
        at, row_id = json.loads(base64.urlsafe_b64decode(cursor + "=" * (-len(cursor) % 4)))
        parsed = datetime.fromisoformat(at), uuid.UUID(row_id)
    except (binascii.Error, ValueError, TypeError) as e:
        raise ValidationFailedError(details={"cursor": "invalid"}) from e
    if parsed[0].tzinfo is None:
        raise ValidationFailedError(details={"cursor": "invalid"})
    return parsed


def merge_page(changes: list[Change], limit: int) -> tuple[list[Change], bool]:
    """Merge per-table results into one page in (updated_at, id) order.

    Args:
        changes: up to `limit + 1` rows from each table, each after the cursor.
        limit: page size.

    Returns:
        (the first `limit` changes, whether more remain). Each table contributed its first `limit + 1`, so
        the overall first `limit + 1` are all present.
    """
    ordered = sorted(changes, key=lambda c: (c[0], c[1]))
    return ordered[:limit], len(ordered) > limit


def is_photo_pending(status: PhotoStatus, created_at: datetime, now: datetime) -> bool:
    """Decide whether a photo should be re-requested by the phone (backend-design.md §3, 24 h rule).

    Args:
        status: the photo's status.
        created_at: when its entry reached the server.
        now: the current time.

    Returns:
        True when the photo is still `pending_upload` 24 hours or more after it was announced.
    """
    return status == PhotoStatus.PENDING_UPLOAD and now - created_at >= PHOTO_PENDING_AFTER


def _window(
    model: Any, after: tuple[datetime, uuid.UUID] | None, bound: ColumnElement[datetime], limit: int
) -> Any:
    """Build the changed-rows SELECT for one table.

    Args:
        model: the mapped class (has `updated_at` and `id`).
        after: the cursor position, or None for everything.
        bound: newest `updated_at` served (SQL `now() − PULL_SETTLE`).
        limit: page size.

    Returns:
        SELECT of rows after the cursor and not newer than `bound`, oldest first, `limit + 1` rows.
    """
    query = select(model).where(model.updated_at <= bound)
    if after is not None:
        query = query.where(tuple_(model.updated_at, model.id) > tuple_(*after))
    return query.order_by(model.updated_at, model.id).limit(limit + 1)


def _lot_json(lot: Lot) -> dict[str, Any]:
    """Serialise a lot for the phone (lean).

    Args:
        lot: the lot row.

    Returns:
        Lot fields the farmer and officer screens show; quantities in kg.
    """
    return {
        "id": lot.id,
        "farmer_id": lot.farmer_id,
        "plot_id": lot.plot_id,
        "crop_id": lot.crop_id,
        "season_label": lot.season_label,
        "code": lot.code,
        "status": lot.status,
        "practice_tags": lot.practice_tags,
        "harvested_kg": lot.harvested_kg,
        "packed_kg": lot.packed_kg,
        "ready_at": lot.ready_at,
        "gi_eligible": lot.gi_eligible,
        "gi_hold_reason": lot.gi_hold_reason,
    }


def _intake_json(intake: LotIntake) -> dict[str, Any]:
    """Serialise a lot intake (sale to the processor) for the phone.

    Args:
        intake: the intake row.

    Returns:
        Intake fields; quantities in kg, price in rupees per kg.
    """
    return {
        "id": intake.id,
        "lot_id": intake.lot_id,
        "processor_id": intake.processor_id,
        "sale_date": intake.sale_date,
        "received_kg": intake.received_kg,
        "price_per_kg": intake.price_per_kg,
        "reconciliation": intake.reconciliation,
        "yield_check": intake.yield_check,
        "supersedes_intake_id": intake.supersedes_intake_id,
    }


def _flag_json(flag: Flag) -> dict[str, Any]:
    """Serialise a flag for the phone.

    Args:
        flag: the flag row.

    Returns:
        Flag fields without `dedupe_key` (internal).
    """
    return {
        "id": flag.id,
        "subject_type": flag.subject_type,
        "subject_id": flag.subject_id,
        "rule_code": flag.rule_code,
        "severity": flag.severity,
        "details": flag.details,
        "status": flag.status,
        "assigned_role": flag.assigned_role,
        "raised_at": flag.raised_at,
        "resolution_reason_code": flag.resolution_reason_code,
        "resolved_at": flag.resolved_at,
    }


def _notification_json(note: Notification) -> dict[str, Any]:
    """Serialise one of the caller's notifications.

    Args:
        note: the notification row.

    Returns:
        Template key, language, variables and delivery status.
    """
    return {
        "id": note.id,
        "template_key": note.template_key,
        "lang": note.lang,
        "payload": note.payload,
        "channel": note.channel,
        "status": note.status,
        "created_at": note.created_at,
    }


async def _changes(
    session: AsyncSession,
    user: CurrentUser,
    after: tuple[datetime, uuid.UUID] | None,
    bound: ColumnElement[datetime],
    limit: int,
) -> list[Change]:
    """Collect up to `limit + 1` changes per table inside the caller's scope.

    Args:
        session: database session.
        user: the caller (farmer: own lots and plots; other roles: the FPO).
        after: the cursor position.
        bound: newest `updated_at` served.
        limit: page size.

    Returns:
        Unordered changes as (updated_at, id, entity, data).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    fpo = user.fpo_id
    farmer = user.role == Role.FARMER
    own_farmers = select(Farmer.id).where(Farmer.user_id == user.user_id, Farmer.fpo_id == fpo)
    own_lots = select(Lot.id).where(Lot.farmer_id.in_(own_farmers))
    own_plots = select(Plot.id).where(Plot.farmer_id.in_(own_farmers))
    own_events = select(Event.id).where(Event.lot_id.in_(own_lots))
    flag_scope = or_(
        and_(Flag.subject_type == FlagSubject.LOT, Flag.subject_id.in_(own_lots)),
        and_(Flag.subject_type == FlagSubject.PLOT, Flag.subject_id.in_(own_plots)),
        and_(Flag.subject_type == FlagSubject.EVENT, Flag.subject_id.in_(own_events)),
    )
    out: list[Change] = []

    query = _window(Lot, after, bound, limit).where(
        Lot.fpo_id == fpo, Lot.farmer_id.in_(own_farmers) if farmer else true()
    )
    out += [(r.updated_at, r.id, "lot", _lot_json(r)) for r in await session.scalars(query)]

    query = _window(LotIntake, after, bound, limit).where(
        LotIntake.fpo_id == fpo, LotIntake.lot_id.in_(own_lots) if farmer else true()
    )
    out += [(r.updated_at, r.id, "intake", _intake_json(r)) for r in await session.scalars(query)]

    query = _window(Flag, after, bound, limit).where(Flag.fpo_id == fpo, flag_scope if farmer else true())
    out += [(r.updated_at, r.id, "flag", _flag_json(r)) for r in await session.scalars(query)]

    query = _window(Notification, after, bound, limit).where(Notification.user_id == user.user_id)
    out += [(r.updated_at, r.id, "notification", _notification_json(r)) for r in await session.scalars(query)]

    events = list(
        await session.scalars(
            _window(Event, after, bound, limit).where(
                Event.fpo_id == fpo,
                Event.current_version_id.is_not(None),
                Event.lot_id.in_(own_lots) if farmer else true(),
            )
        )
    )
    versions = {
        v.id: v
        for v in await session.scalars(
            select(EventVersion).where(EventVersion.id.in_([e.current_version_id for e in events]))
        )
    }
    pairs = [(e, versions[e.current_version_id]) for e in events if e.current_version_id in versions]
    shaped = await service.event_outs(session, pairs)
    out += [
        (e.updated_at, e.id, "event", o.model_dump() | {"subject_type": e.subject_type, "lot_id": e.lot_id})
        for (e, _), o in zip(pairs, shaped, strict=True)
    ]
    return out


async def _pending_photos(
    session: AsyncSession, user: CurrentUser, now: datetime, limit: int
) -> list[PullChange]:
    """List the caller's photos still not uploaded 24 h after their entry arrived.

    Args:
        session: database session.
        user: the caller; only photos of versions they entered (their phone holds the files).
        now: the current time.
        limit: most photos to list.

    Returns:
        `photo_pending` changes, oldest first.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # Oldest first, so photos still inside their 24 h are the ones cut by `limit`; `is_photo_pending` is the
    # one place the rule lives.
    query = (
        select(EvidencePhoto, EventVersion.event_id)
        .join(EventVersion, EventVersion.id == EvidencePhoto.event_version_id)
        .where(
            EventVersion.entered_by_user_id == user.user_id,
            EvidencePhoto.status == PhotoStatus.PENDING_UPLOAD,
        )
        .order_by(EvidencePhoto.created_at, EvidencePhoto.id)
        .limit(limit)
    )
    return [
        PullChange(
            entity="photo_pending",
            op="upsert",
            data={
                "id": p.id,
                "event_id": event_id,
                "event_version_id": p.event_version_id,
                "status": p.status,
            },
        )
        for p, event_id in (await session.execute(query)).all()
        if is_photo_pending(p.status, p.created_at, now)
    ]


async def pull(session: AsyncSession, user: CurrentUser, cursor: str | None, limit: int) -> PullOut:
    """Return one page of changes after the cursor and remember the device's position.

    Args:
        session: database session (committed here).
        user: the caller.
        cursor: the `next_cursor` of the previous pull, or None for everything.
        limit: page size (1–200).

    Returns:
        Changes in (updated_at, id) order; on the last page also every `photo_pending` photo.

    Raises:
        ValidationFailedError: the cursor is invalid.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Upserts `sync_cursors` for the token's device (when the token names one) and commits.
    """
    after = decode_cursor(cursor) if cursor else None
    now = utcnow()
    # The bound uses the database clock, the same clock that stamps `updated_at` (review B07-r1 P3-4).
    page, has_more = merge_page(await _changes(session, user, after, func.now() - PULL_SETTLE, limit), limit)
    changes = [PullChange(entity=entity, op="upsert", data=data) for _, _, entity, data in page]
    if not has_more:
        changes += await _pending_photos(session, user, now, limit)
    next_cursor = encode_cursor(page[-1][0], page[-1][1]) if page else cursor
    if user.device_id is not None:
        await session.execute(
            pg_insert(SyncCursor)
            .values(device_id=user.device_id, last_pull_cursor=next_cursor)
            .on_conflict_do_update(
                index_elements=[SyncCursor.device_id],
                set_={"last_pull_cursor": next_cursor, "updated_at": func.now()},
            )
        )
        await session.commit()
    return PullOut(changes=changes, next_cursor=next_cursor, has_more=has_more)
