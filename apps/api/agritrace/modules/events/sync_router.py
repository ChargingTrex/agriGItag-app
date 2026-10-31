"""Sync HTTP routes: `POST /v1/sync/push` and `POST /v1/sync/photos/confirm` (under /v1).

Serves: FR4 (offline-first sync), FR61 (evidence upload confirm), Arch §Offline-first, backend-design.md §3
(binding protocol), plan §13 A3 (client-UUID idempotency), A4 (≤ 50 entries or 256 KB), B3 (presigned
PUT + SHA-256), F1 (`metrics[]`), D-005, D-011, D-020.
Callers: `events.router` includes `router` (module discovery mounts only `router.py`, D-004); the mobile
app's sync engine (M02) through the generated Dart client.
"""

from collections.abc import Callable, Coroutine
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Request, Response
from fastapi.routing import APIRoute
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.errors import PayloadTooLargeError
from agritrace.core.schemas import ErrorEnvelope
from agritrace.modules.events import service
from agritrace.modules.events.schemas import (
    MAX_ENTRIES,
    PhotoConfirmOut,
    PhotosConfirmIn,
    SyncPushIn,
    SyncPushOut,
)

MAX_PUSH_BYTES = 256 * 1024
Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]


class CappedRoute(APIRoute):
    """Route that refuses bodies over 256 KB before FastAPI parses them (plan §13 A4)."""

    def get_route_handler(self) -> Callable[[Request], Coroutine[Any, Any, Response]]:
        """Wrap FastAPI's handler with the size check.

        Returns:
            The wrapped request handler.
        """
        handler = super().get_route_handler()

        async def capped(request: Request) -> Response:
            """Check the size, then run the normal handler (parsing, dependencies, endpoint).

            Args:
                request: the incoming request.

            Returns:
                The endpoint's response.

            Raises:
                PayloadTooLargeError: `Content-Length` or the body is over `MAX_PUSH_BYTES` (413), also for a
                    body that is not JSON.
            """
            # shortcut: a chunked body without Content-Length is read before it is measured; the load
            #   balancer caps request size in prod (TODO, infra).
            declared = int(request.headers.get("content-length") or 0)
            if declared > MAX_PUSH_BYTES or len(await request.body()) > MAX_PUSH_BYTES:
                raise PayloadTooLargeError(details={"max_bytes": MAX_PUSH_BYTES, "max_entries": MAX_ENTRIES})
            return await handler(request)

        return capped


router = APIRouter(tags=["events"], route_class=CappedRoute)


def errors(**by_status: str) -> dict[int | str, dict[str, Any]]:
    """Document error responses of a route with the shared envelope (also used by `events.router`).

    Args:
        **by_status: description per status, keyed `e<status>`.

    Returns:
        The `responses=` mapping for FastAPI.
    """
    return {int(k[1:]): {"model": ErrorEnvelope, "description": v} for k, v in by_status.items()}


@router.post(
    "/sync/push",
    response_model=SyncPushOut,
    summary="Push offline entries",
    description=(
        "Sends up to 50 entries (and at most 256 KB) captured offline, in capture order. Kinds: "
        "`event_version` (body `EventVersionIn`, the same as `CorrectionIn.data`), `quality_reading`, "
        "`plot`, `consent`; `flag_resolution` is rejected with `not_implemented_pilot` in the pilot. Each "
        "entry is its own transaction and gets its own result: `accepted`, `duplicate` (same `client_id` "
        "already stored by you; returns the original `server_id` and fresh upload URLs for photos not yet "
        "uploaded) or `rejected` with an error (`validation_error`, `client_id_conflict`, `stale_version`, "
        "`forbidden`, `not_found`, `reason_required`, `undo_window_closed`, ...). The response is 200 "
        "whenever the envelope parses. Photos are never in the push: each photo gets one presigned PUT "
        "(15 minutes, `Content-Type` and `x-amz-checksum-sha256` must be sent as given), then "
        "`POST /v1/sync/photos/confirm`. `metrics[]` rows are stored for the sync-health dashboard."
    ),
    responses=errors(
        e413="`payload_too_large`: body over 256 KB.",
        e422="`validation_error`: the envelope does not parse, or more than 50 entries.",
    ),
)
async def sync_push(session: Session, user: AnyRole, body: SyncPushIn) -> SyncPushOut:
    """Process a sync push.

    Args:
        session: database session.
        user: the caller (any signed-in role; each kind checks its own roles).
        body: the envelope (its size was checked by `CappedRoute`).

    Returns:
        Per-entry results.
    """
    return await service.push(session, user, body)


@router.post(
    "/sync/photos/confirm",
    response_model=list[PhotoConfirmOut],
    summary="Confirm uploaded photos",
    description=(
        "Call after each presigned PUT succeeded. For each photo the server checks storage: `received` "
        "means the object is there (its version id is stored and verification of SHA-256 and EXIF time/GPS "
        "is queued), `missing` means upload again (ask for fresh URLs by resending the entry) and confirm "
        "again. Unknown ids and photos of entries someone else pushed also answer `missing`. Bodies over "
        "256 KB → 413 `payload_too_large`."
    ),
)
async def sync_photos_confirm(
    session: Session, user: AnyRole, body: PhotosConfirmIn
) -> list[PhotoConfirmOut]:
    """Confirm photos.

    Args:
        session: database session.
        user: the caller.
        body: the photo ids.

    Returns:
        One status per photo, same order.
    """
    return await service.confirm_photos(session, user, body)
