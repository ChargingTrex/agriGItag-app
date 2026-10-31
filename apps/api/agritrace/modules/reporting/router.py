"""reporting HTTP routes: FPO dashboard, per-farmer table, audit log search, batch audit CSV, public scans.

Serves: FR13 (FPO dashboard), FR20 (scan analytics), FR21 (audit export and viewer), FR58 (units, CSV unit
column), plan §7.1 B11, plan §7.3 P06, backend-design.md §1 reporting row, D-020 (/v1, additive), D-037,
D-038, D-039, CLAUDE.md §6 (every route but the public scan is scoped to the caller's FPO and role).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the portal dashboard and
audit viewer (P05, P06) through the generated client (D-003); the public batch page (B10) posts scans.
"""

import uuid
from typing import Annotated, Any

from fastapi import APIRouter, Depends, Header, Path, Query, Request, Response, status
from fastapi.responses import JSONResponse
from pydantic import AwareDatetime
from sqlalchemy import ColumnElement
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, assert_same_fpo, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.identity.models import AuditLog
from agritrace.modules.registry import service as registry_service
from agritrace.modules.reporting import service
from agritrace.modules.reporting.schemas import AuditRow, Dashboard, FarmerRow

router = APIRouter(tags=["reporting"])

Session = Annotated[AsyncSession, Depends(get_session)]
Staff = Annotated[
    CurrentUser, Depends(require_role(Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER))
]
Admin = Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]
Auditor = Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN, Role.VIEWER))]
FpoId = Annotated[uuid.UUID, Path(description="FPO id; must be the caller's FPO.")]
CropId = Annotated[uuid.UUID | None, Query(description="Only lots of this crop.")]
District = Annotated[str | None, Query(max_length=120, description="Only farmers whose village is in it.")]
Block = Annotated[str | None, Query(max_length=120, description="Only farmers whose village is in it.")]
VillageId = Annotated[uuid.UUID | None, Query(description="Only farmers of this village.")]
Cursor = Annotated[
    uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
]
Limit = Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")]
CROCKFORD_CODE = (
    r"^[0-9A-HJKMNP-TV-Za-hjkmnp-tv-z]{12}$"  # batch code alphabet (core.ids.CROCKFORD), any case
)
SCOPE: dict[int | str, dict[str, Any]] = {
    401: {"model": ErrorEnvelope, "description": "`unauthorized`."},
    403: {"model": ErrorEnvelope, "description": "`forbidden`: role not allowed."},
    404: {"model": ErrorEnvelope, "description": "`not_found`: another FPO's id."},
}


@router.get(
    "/dashboard/fpo/{fpo_id}",
    response_model=Dashboard,
    summary="FPO dashboard",
    description="Completeness (lots with every mandatory event ÷ lots), stage-progress tiles, active flags "
    "by severity, batches by status, Land Area Analytics, Finished Goods, public scans and sync health (last "
    "7 days). `crop_id`, `district`, `block` and `village_id` narrow completeness and the stage tiles; the "
    "place filters also narrow land area. Office roles of the FPO only. No phones or locations (D-037).",
    responses=SCOPE,
)
async def get_dashboard(
    fpo_id: FpoId,
    session: Session,
    user: Staff,
    crop_id: CropId = None,
    district: District = None,
    block: Block = None,
    village_id: VillageId = None,
) -> Dashboard:
    """Build the dashboard of the caller's FPO.

    \f
    Args:
        fpo_id: the FPO.
        session: database session.
        user: the caller.
        crop_id: crop filter.
        district: district filter.
        block: block filter.
        village_id: village filter.

    Returns:
        The dashboard.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: a farmer (403).
        NotFoundError: another FPO's id (404).
    """
    assert_same_fpo(user, fpo_id)
    return await service.dashboard(session, fpo_id, service.Filters(crop_id, district, block, village_id))


@router.get(
    "/dashboard/fpo/{fpo_id}/farmers",
    response_model=Page[FarmerRow],
    summary="Per-farmer dashboard table",
    description="Farmers of the FPO with plot areas and lot completeness, in onboarding order. Place filters "
    "narrow the farmers, `crop_id` the lots counted. `?fields=` returns only the named item fields "
    "(conventions.md); unknown or tenant-disabled names → 422 `validation_error`.",
    responses={**SCOPE, 422: {"model": ErrorEnvelope, "description": "`validation_error`: bad `fields`."}},
)
async def list_dashboard_farmers(
    fpo_id: FpoId,
    session: Session,
    user: Staff,
    crop_id: CropId = None,
    district: District = None,
    block: Block = None,
    village_id: VillageId = None,
    cursor: Cursor = None,
    limit: Limit = 50,
    fields: Annotated[
        str | None,
        Query(max_length=500, description="Comma-separated item fields to return, e.g. `id,name,lots`."),
    ] = None,
) -> Page[FarmerRow] | Response:
    """List the per-farmer rows of the caller's FPO.

    \f
    Args:
        fpo_id: the FPO.
        session: database session.
        user: the caller.
        crop_id: crop filter for the lot counts.
        district: district filter.
        block: block filter.
        village_id: village filter.
        cursor: pagination cursor.
        limit: page size.
        fields: item fields to keep.

    Returns:
        One page; with `fields`, a JSON response whose items hold only those keys.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: a farmer (403).
        NotFoundError: another FPO's id (404).
        ValidationFailedError: unknown `fields` name (422).
    """
    assert_same_fpo(user, fpo_id)
    keep = fields and registry_service.parse_fields(fields, await service.farmer_fields(session, fpo_id))
    filters = service.Filters(crop_id, district, block, village_id)
    page = await service.farmer_rows(session, fpo_id, filters, cursor, limit)
    if not keep:
        return page
    include: dict[str, Any] = {"items": {"__all__": keep}, "next_cursor": True, "has_more": True}
    return JSONResponse(page.model_dump(mode="json", include=include))


@router.get(
    "/audit-log",
    response_model=Page[AuditRow],
    summary="Search the audit log",
    description="Audit rows about the caller's FPO's records (D-039), newest first, filtered by actor, "
    "entity and time. Diffs are returned as stored except that secret columns read `[redacted]` and "
    "location, boundary and land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, "
    "`gps`, `started_gps`, `boundary`) read `[hidden]`; device ids and the row's GPS are not listed. "
    "FPO admin only.",
    responses={401: SCOPE[401], 403: SCOPE[403]},
)
async def search_audit_log(
    session: Session,
    user: Admin,
    actor_user_id: Annotated[uuid.UUID | None, Query(description="Only changes by this user.")] = None,
    entity_type: Annotated[
        str | None, Query(max_length=64, description="Only this table, e.g. `farmers`, `event_versions`.")
    ] = None,
    entity_id: Annotated[uuid.UUID | None, Query(description="Only this record.")] = None,
    since: Annotated[
        AwareDatetime | None, Query(alias="from", description="Rows at or after (ISO 8601).")
    ] = None,
    until: Annotated[AwareDatetime | None, Query(alias="to", description="Rows before (ISO 8601).")] = None,
    cursor: Cursor = None,
    limit: Limit = 50,
) -> Page[AuditRow]:
    """Search the audit log of the caller's FPO.

    \f
    Args:
        session: database session.
        user: the caller (FPO admin).
        actor_user_id: actor filter.
        entity_type: table filter.
        entity_id: record filter.
        since: inclusive lower time bound.
        until: exclusive upper time bound.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of audit rows.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: not an FPO admin (403).
    """
    where: list[ColumnElement[bool]] = []
    if actor_user_id is not None:
        where.append(AuditLog.actor_user_id == actor_user_id)
    if entity_type is not None:
        where.append(AuditLog.entity_type == entity_type)
    if entity_id is not None:
        where.append(AuditLog.entity_id == entity_id)
    if since is not None:
        where.append(AuditLog.at >= since)
    if until is not None:
        where.append(AuditLog.at < until)
    return await service.audit_rows(session, user.fpo_id, where, cursor, limit)


@router.get(
    "/batches/{batch_id}/audit-export.csv",
    response_class=Response,
    summary="Download a batch's audit trail as CSV",
    description="One row per version of every event of the batch and of its component lots, with "
    "`entered_by`, `entered_by_name`, `assist_session_id`, the reason and a `quantity` + `unit` pair (FR58); "
    "cells that start with `=`, `+`, `-` or `@` get a `'` prefix. FPO admin or viewer.",
    responses={
        200: {"content": {"text/csv": {}}, "description": "UTF-8 CSV with a header row."},
        **SCOPE,
    },
)
async def export_batch_audit(
    batch_id: Annotated[uuid.UUID, Path(description="Batch id.")], session: Session, user: Auditor
) -> Response:
    """Export the audit trail of one batch.

    \f
    Args:
        batch_id: the batch.
        session: database session.
        user: the caller.

    Returns:
        The CSV as an attachment named `audit-<batch code>.csv`.

    Raises:
        UnauthorizedError: no valid token (401).
        ForbiddenError: role not allowed (403).
        NotFoundError: no such batch in the caller's FPO (404).
    """
    code, body = await service.audit_csv(session, user.fpo_id, batch_id)
    headers = {"Content-Disposition": f'attachment; filename="audit-{code}.csv"'}
    return Response(body, media_type="text/csv; charset=utf-8", headers=headers)


@router.post(
    "/public/scans",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Count a public page scan (no sign-in)",
    description="Called by the public batch page when it opens. No body and no sign-in, so a static page "
    "can send it with `navigator.sendBeacon` without a CORS preflight (D-038). Stores the batch code, the "
    "time and a hash of the User-Agent; the IP address is never stored. `batch_code` must be a "
    "12-character Crockford base32 code. More than 100 scans per minute from one address, or more than 10 "
    "of codes no batch has, → 429 `rate_limited` with `details.retry_after_s`. While Valkey is down scans "
    "are not counted (204).",
    responses={
        422: {"model": ErrorEnvelope, "description": "`validation_error`: bad batch code."},
        429: {"model": ErrorEnvelope, "description": "`rate_limited`."},
    },
)
async def post_scan(
    request: Request,
    session: Session,
    batch_code: Annotated[str, Query(pattern=CROCKFORD_CODE, description="Scanned batch code.")],
    user_agent: Annotated[str | None, Header(include_in_schema=False)] = None,
) -> Response:
    """Count one scan.

    \f
    Args:
        request: the request, for the client address.
        session: database session.
        batch_code: the scanned code.
        user_agent: the `User-Agent` header.

    Returns:
        204 No Content.

    Raises:
        RateLimitedError: over 100 scans (or 10 of unknown codes) this minute from this address (429).
        ValidationFailedError: bad batch code (422).

    Side effects:
        Inserts one `scan_events` row and commits; one Valkey counter update.
    """
    # Behind the load balancer set FORWARDED_ALLOW_IPS=<LB subnet> (never `*`: a spoofed X-Forwarded-For
    #   would bypass the limit) so `client.host` is the browser's address.
    client_ip = request.client.host if request.client else "unknown"
    await service.record_scan(session, batch_code, user_agent, client_ip)
    await session.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
