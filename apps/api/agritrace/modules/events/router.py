"""Events HTTP routes: lot timeline, corrections and undo (under /v1); also mounts the sync routes.

Serves: FR6 (farmer undo within 24 h), FR25 (corrections with reason as new versions), FR59, FR63 (event
instances in date order), backend-design.md §1 events row, D-005, D-014, D-020.
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the portal and mobile app
through the generated clients (D-003).
"""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Path
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.schemas import Page
from agritrace.modules.events import service, sync_router
from agritrace.modules.events.schemas import CorrectionIn, EventOut, SyncResult, UndoIn
from agritrace.modules.events.sync_router import errors

router = APIRouter(tags=["events"])
router.include_router(sync_router.router)

Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]
Corrector = Annotated[CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.FPO_ADMIN))]
Farmer = Annotated[CurrentUser, Depends(require_role(Role.FARMER))]
EventId = Annotated[uuid.UUID, Path(description="Event id (the client id it was created with).")]


@router.get(
    "/lots/{lot_id}/events",
    response_model=Page[EventOut],
    summary="List a lot's events",
    description=(
        "Every event of the lot with its latest version, ordered by `occurred_on`, then `instance_no` "
        "(FR63). Undone events stay listed with status `undone`. A lot has a few dozen events at most, so "
        "the whole list is one page (`has_more` false)."
    ),
    responses=errors(e404="`not_found`: lot not in your FPO (farmers: not your lot)."),
)
async def list_lot_events(
    session: Session,
    user: AnyRole,
    lot_id: Annotated[uuid.UUID, Path(description="Lot id.")],
) -> Page[EventOut]:
    """List a lot's events.

    Args:
        session: database session.
        user: the caller.
        lot_id: the lot.

    Returns:
        One page holding every event.

    Raises:
        NotFoundError: lot outside the caller's scope.
    """
    # shortcut: one page and no `?fields=`; add the cursor when a lot can exceed ~200 events.
    items = await service.list_lot_events(session, user, lot_id)
    return Page[EventOut](items=items, next_cursor=None, has_more=False)


@router.post(
    "/events/{event_id}/versions",
    response_model=SyncResult,
    summary="Correct an event",
    description=(
        "Adds a correction version (field officer or FPO admin only; farmers get 403 `forbidden`). The "
        "body is a sync `event_version` entry: `data.change_kind` must be `correct`, `data.version_no` the "
        "current max + 1 (else 409 `stale_version`), `data.reason_code` is required (422 "
        "`reason_required`). The earlier version stays stored (append-only, FR25). Resending the same "
        "`client_id` answers `duplicate`."
    ),
    responses=errors(
        e403="`forbidden`: not a field officer or FPO admin.",
        e404="`not_found`: event, lot, batch or plot not in your FPO.",
        e409="`stale_version`, `client_id_conflict`.",
        e422="`validation_error`, `reason_required`.",
    ),
)
async def correct_event(
    session: Session, user: Corrector, event_id: EventId, body: CorrectionIn
) -> SyncResult:
    """Correct an event.

    Args:
        session: database session.
        user: a field officer or FPO admin.
        event_id: the event.
        body: the correction.

    Returns:
        `accepted` or `duplicate`, with upload URLs for new photos.

    Raises:
        AppError: every error of `service.correct_event`.
    """
    return await service.correct_event(session, user, event_id, body)


@router.post(
    "/events/{event_id}/undo",
    response_model=SyncResult,
    summary="Undo an own entry",
    description=(
        "A farmer undoes an event they entered, within 24 hours of its capture (device time); later → 409 "
        "`undo_window_closed` (ask the field officer for a correction). Adds a version with "
        "`change_kind=undo`; the event's status becomes `undone`. `version_no` must be the current max + 1."
    ),
    responses=errors(
        e403="`forbidden`: not a farmer, or not your entry.",
        e404="`not_found`: event not in your FPO.",
        e409="`undo_window_closed`, `stale_version`, `client_id_conflict`.",
    ),
)
async def undo_event(session: Session, user: Farmer, event_id: EventId, body: UndoIn) -> SyncResult:
    """Undo an event.

    Args:
        session: database session.
        user: the farmer.
        event_id: the event.
        body: the undo.

    Returns:
        `accepted` or `duplicate`.

    Raises:
        AppError: every error of `service.undo_event`.
    """
    return await service.undo_event(session, user, event_id, body)
