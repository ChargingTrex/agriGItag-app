"""publishing HTTP routes: rebuild a public page, list builds, QR image, label sheet, dev page proxy.

Serves: FR12 (QR), FR15-FR17 (page rebuilt after a correction, versioned builds), FR62 (labels), D-007,
D-020 (/v1, additive), D-033 (gates answer 409 `gate_not_met`), backend-design.md §1 publishing row.
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the portal (P04) through the
generated client (D-003); browsers for `GET /v1/public/batches/{code}` in development.
"""

import asyncio
import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Path, Query, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.lots_batches import service as lots_service
from agritrace.modules.publishing import service
from agritrace.modules.publishing.schemas import BuildOut

router = APIRouter(tags=["publishing"])

Session = Annotated[AsyncSession, Depends(get_session)]
Staff = Annotated[
    CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER))
]
Admin = Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]
BatchId = Annotated[uuid.UUID, Path(description="Batch id.")]
# The code becomes part of an S3 key: only the 12-character Crockford base32 batch code is accepted.
BatchCode = Annotated[
    str, Path(pattern=r"^[0-9A-HJKMNP-TV-Z]{12}$", description="Batch code, e.g. FGP8T4033HM7.")
]
NOT_FOUND: dict[int | str, dict[str, Any]] = {
    404: {"model": ErrorEnvelope, "description": "`not_found`: no such batch in your FPO."}
}


def _gate(reasons: str) -> dict[int | str, dict[str, Any]]:
    """Document the 404 and the gate 409 of a route.

    Args:
        reasons: the reason codes the route can list.

    Returns:
        The `responses=` mapping for FastAPI.
    """
    return {
        **NOT_FOUND,
        409: {"model": ErrorEnvelope, "description": f"`gate_not_met` with `details.reasons[]`: {reasons}."},
    }


@router.post(
    "/batches/{batch_id}/rebuild",
    response_model=BuildOut,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Rebuild the public page of a published batch",
    description=(
        "Queues a new build (`build_no` + 1) after a correction; earlier builds and their S3 object "
        "versions are kept. Poll `GET /batches/{id}/builds` for `built` or `failed`."
    ),
    responses=_gate("`not_published`"),
)
async def rebuild(batch_id: BatchId, session: Session, user: Admin) -> BuildOut:
    """Queue a rebuild.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the FPO admin.

    Returns:
        The queued build.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: the batch is not published (409).

    Side effects:
        Commits the build row, then enqueues `publishing.build_page`.
    """
    build = await service.rebuild(session, user, batch_id)
    await session.commit()
    await lots_service.enqueue_page_build(build)
    return service.build_out(build)


@router.get(
    "/batches/{batch_id}/builds",
    response_model=Page[BuildOut],
    summary="List the public page builds of a batch",
    description="Oldest first. A `failed` build carries `error` (`public_record_invalid` with field paths).",
    responses=NOT_FOUND,
)
async def list_builds(
    batch_id: BatchId,
    session: Session,
    user: Staff,
    cursor: Annotated[
        uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
    ] = None,
    limit: Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")] = 50,
) -> Page[BuildOut]:
    """List builds.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the caller.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of builds.

    Raises:
        NotFoundError: out of scope (404).
    """
    return await service.list_builds(session, user, batch_id, cursor, limit)


@router.get(
    "/batches/{batch_id}/qr.png",
    response_class=Response,
    summary="QR code of the batch's public page",
    description="PNG encoding `{PUBLIC_BASE_URL}/b/<code>` (FR12).",
    responses={200: {"content": {"image/png": {}}, "description": "The QR image."}, **NOT_FOUND},
)
async def batch_qr(batch_id: BatchId, session: Session, user: Staff) -> Response:
    """Return the batch QR image.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the caller.

    Returns:
        The PNG.

    Raises:
        NotFoundError: out of scope (404).
    """
    batch = await lots_service.get_batch(session, user, batch_id)
    return Response(service.qr_png(service.public_url(batch.code)), media_type="image/png")


@router.get(
    "/batches/{batch_id}/labels.pdf",
    response_class=Response,
    summary="Printable pack labels of a packed batch",
    description="A4 sheet of 8 labels: QR, product, batch, net kg, pack and best-before dates, FSSAI (FR62).",
    responses={
        200: {"content": {"application/pdf": {}}, "description": "The label sheet."},
        **_gate("`final_packing_missing`"),
    },
)
async def batch_labels(batch_id: BatchId, session: Session, user: Staff) -> Response:
    """Return the label sheet.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the caller.

    Returns:
        The PDF.

    Raises:
        NotFoundError: out of scope (404).
        GateNotMetError: no pack date yet (409).
    """
    return Response(await service.labels(session, user, batch_id), media_type="application/pdf")


@router.get(
    "/public/batches/{code}",
    response_class=Response,
    summary="Latest public page of a batch (development proxy)",
    description=(
        "No sign-in. Serves `batches/<code>/index.html` from public-pages so the portal preview and "
        "testers can open a page without the CDN. 404 in production, where the CDN serves the bucket."
    ),
    responses={
        200: {"content": {"text/html": {}}, "description": "The page."},
        404: {"model": ErrorEnvelope, "description": "`not_found`: no page built for this code."},
    },
)
async def public_page(code: BatchCode) -> Response:
    """Serve the latest built page.

    \f
    Args:
        code: the batch code.

    Returns:
        The HTML with the object's Cache-Control.

    Raises:
        NotFoundError: production, or no page yet (404).
    """
    body, cache = await asyncio.to_thread(service.page_html, code)
    return Response(body, media_type="text/html; charset=utf-8", headers={"Cache-Control": cache})
