"""Sync HTTP routes under /v1: push, photo confirm, pull, reference bundles and their per-part delta.

Serves: FR4 (offline-first sync), FR61 (evidence upload confirm), Arch §Offline-first (incl. "Reference data
travels to the phone"), backend-design.md §3 (binding protocol), plan §13 A3 (client-UUID idempotency), A4
(≤ 50 entries or 256 KB), B3 (presigned PUT + SHA-256), C2 (bundles, per-part `since`, ETag/304), C3, F1
(`metrics[]`), D-005, D-011, D-016, D-020.
Callers: `events.router` includes `router` (module discovery mounts only `router.py`, D-004); the mobile
app's sync engine (M02) through the generated Dart client.
"""

from collections.abc import Callable, Coroutine
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Path, Query, Request, Response
from fastapi.responses import JSONResponse
from fastapi.routing import APIRoute
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.errors import PayloadTooLargeError
from agritrace.core.schemas import ErrorEnvelope
from agritrace.modules.events import bundle_service, pull_service, service
from agritrace.modules.events.schemas import (
    MAX_ENTRIES,
    BundleManifest,
    BundlePart,
    PhotoConfirmOut,
    PhotosConfirmIn,
    PullOut,
    ReferenceOut,
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
        "`plot`, `consent`, `flag_resolution` (same rules as `POST /v1/flags/{id}/resolve`). Each "
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


NOT_MODIFIED: dict[int | str, dict[str, Any]] = {304: {"description": "Unchanged; keep your copy."}}
# Per-user content: devices may keep it but must revalidate every time.
PRIVATE_REVALIDATE = "private, no-cache"


def etag_matches(if_none_match: str | None, etag: str) -> bool:
    """Check an `If-None-Match` header against a strong ETag (RFC 9110 §13.1.2, weak comparison).

    Args:
        if_none_match: the header value: `*`, or a comma-separated list of tags; None when absent.
        etag: the current quoted ETag.

    Returns:
        True when the client already holds this representation.
    """
    tags = [t.strip().removeprefix("W/") for t in (if_none_match or "").split(",")]
    return "*" in tags or etag in tags


@router.get(
    "/sync/bundle",
    response_model=BundleManifest,
    summary="List reference-bundle parts",
    description=(
        "Every offline reference part available to you with its `version` and strong `etag`: `plots` (yours, "
        "or the FPO's for officers), `crops` (with `event_schema {mandatory, tracks}`), `inputs` (global + "
        "FPO), `standards` (full profile rules per crop), `gi_region` (simplified outline ≤ 50 KB + buffer; "
        "absent while none is in effect), `farmer_profile`, `villages` (the FPO's district), `fields` "
        "(field configuration), `prompts`, `images` (product-picture URLs) and `calendar`. Download a part "
        "with `GET /v1/sync/bundle/{part}`; later ask `GET /v1/sync/reference?since=` for changes only."
    ),
)
async def sync_bundle(session: Session, user: AnyRole) -> BundleManifest:
    """List the caller's bundle parts.

    Args:
        session: database session.
        user: the caller (any signed-in role).

    Returns:
        The manifest.
    """
    return await bundle_service.manifest(session, user)


@router.get(
    "/sync/bundle/{part}",
    response_model=dict[str, Any],
    summary="Download one reference-bundle part",
    description=(
        'The part body in the shape the app parses (docs/api/conventions.md "Reference bundles"). Sends a '
        "strong `ETag`; send it back in `If-None-Match` to get 304 without a body. Unknown part → 422."
    ),
    responses=NOT_MODIFIED
    | errors(e404="`gi_region_missing`: `gi_region` asked while no region is in effect."),
)
async def sync_bundle_part(
    request: Request,
    session: Session,
    user: AnyRole,
    part: Annotated[BundlePart, Path(description="Part name, as listed by `GET /v1/sync/bundle`.")],
) -> Response:
    """Download one part, or 304 when the caller's copy is current.

    Args:
        request: the request (reads `If-None-Match`).
        session: database session.
        user: the caller.
        part: the part.

    Returns:
        200 JSON with `ETag`, or 304.

    Raises:
        GiRegionMissingError: `gi_region` while no region version is in effect.
    """
    body = await bundle_service.part_body(session, user, part)
    etag = fieldconfig.etag(body)
    headers = {"ETag": etag, "Cache-Control": PRIVATE_REVALIDATE}
    if etag_matches(request.headers.get("if-none-match"), etag):
        return Response(status_code=304, headers=headers)
    return JSONResponse(body, headers=headers)


@router.get(
    "/sync/reference",
    response_model=ReferenceOut,
    summary="Changed reference-bundle parts",
    description=(
        "Delta sync (plan §13 C2). `since` lists the part versions you hold as `<part>:<version>` joined by "
        "commas, e.g. `plots:41,crops:7,fields:90210`. Answers the parts whose version differs from yours, "
        "each compared on its own, with body, version and etag; parts you do not list are new to you and "
        "included. 304 when nothing changed. A malformed `since` → 422 `validation_error`."
    ),
    responses=NOT_MODIFIED | errors(e422="`validation_error`: `since` is not `<part>:<version>,...`."),
)
async def sync_reference(
    session: Session,
    user: AnyRole,
    since: Annotated[
        str | None,
        Query(max_length=1000, description="Part versions you hold: `<part>:<version>,...`; omit for all."),
    ] = None,
) -> Response:
    """Return changed parts, or 304.

    Args:
        session: database session.
        user: the caller.
        since: the held versions.

    Returns:
        200 JSON `ReferenceOut`, or 304 when no part changed.

    Raises:
        ValidationFailedError: malformed `since`.
    """
    out = await bundle_service.reference(session, user, since)
    if not out.parts:
        return Response(status_code=304)
    return JSONResponse(out.model_dump(mode="json"), headers={"Cache-Control": PRIVATE_REVALIDATE})


@router.get(
    "/sync/pull",
    response_model=PullOut,
    summary="Pull server-side changes",
    description=(
        "Changes since `cursor`, oldest first: `flag`, `lot`, `event` (current version, e.g. after an "
        "officer correction; photo variant URLs are presigned for 1 hour), `intake`, `notification` (yours) "
        "and, on the last page, `photo_pending` (photos still not uploaded 24 h after their entry: resend "
        "the entry to get fresh upload URLs). Farmers see their own lots, plots and events; other roles the "
        "whole FPO. Every change is an `upsert` by `id`. Store `next_cursor` and call again while "
        "`has_more`. Changes appear "
        "about 30 s after they are written. An invalid cursor → 422 `validation_error`."
    ),
    responses=errors(e422="`validation_error`: invalid cursor or limit."),
)
async def sync_pull(
    session: Session,
    user: AnyRole,
    cursor: Annotated[
        str | None,
        Query(max_length=200, description="`next_cursor` of your previous pull; omit the first time."),
    ] = None,
    limit: Annotated[int, Query(ge=1, le=200, description="Most changes per page.")] = 200,
) -> PullOut:
    """Pull one page of changes.

    Args:
        session: database session.
        user: the caller.
        cursor: the previous cursor.
        limit: page size.

    Returns:
        The page.

    Raises:
        ValidationFailedError: invalid cursor.
    """
    return await pull_service.pull(session, user, cursor, limit)
