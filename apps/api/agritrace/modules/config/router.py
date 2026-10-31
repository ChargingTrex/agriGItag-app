"""HTTP routes of the field and feature configuration: `GET /v1/config/fields`, `GET /v1/config/features`.

The tenant comes from the access token (the caller's FPO); responses carry a strong ETag and answer 304 to
a matching `If-None-Match`, so phones and the portal re-download only after a config deploy.

Serves: D-017 (one config for three clients, tenant overrides), FR22, FR23, P08 (templates match
/config/fields), M07/M09/M11 form rendering, backend-design.md §1 config row.
Callers: `agritrace.main.create_app` mounts `router` under `/v1` by discovery (D-004); mobile and portal
through the generated clients. The sync bundle part `fields` (B07) uses `fieldconfig.bundle_part`.
"""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, Query, Request, Response
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.errors import ValidationFailedError
from agritrace.core.fieldconfig import Features, FieldSpec
from agritrace.modules.registry import service as registry

router = APIRouter(prefix="/config", tags=["config"])

Session = Annotated[AsyncSession, Depends(get_session)]
AnyRole = Annotated[CurrentUser, Depends(require_role())]
NOT_MODIFIED: dict[int | str, dict[str, Any]] = {
    304: {"description": "Unchanged since the ETag sent in `If-None-Match`."}
}


def _with_etag(request: Request, body: Any) -> Response:
    """Answer a configuration view with its ETag, or 304 when the client already has it.

    Args:
        request: the request (reads `If-None-Match`).
        body: the JSON-serialisable view.

    Returns:
        304 without body when the tags match, else 200 JSON with `ETag` and `Cache-Control: private,
        no-cache` (per-tenant content; revalidate every time).
    """
    tag = fieldconfig.etag(body)
    headers = {"ETag": tag, "Cache-Control": "private, no-cache"}
    if request.headers.get("if-none-match") == tag:
        return Response(status_code=304, headers=headers)
    return JSONResponse(body, headers=headers)


@router.get(
    "/fields",
    response_model=dict[str, list[FieldSpec]],
    summary="Fields captured by the caller's FPO, by entity",
    responses=NOT_MODIFIED,
)
async def get_fields(
    request: Request,
    session: Session,
    user: AnyRole,
    entity: Annotated[
        str | None, Query(max_length=64, description="One entity, e.g. `farmer`, `plot`, `event_harvest`.")
    ] = None,
) -> Response:
    """Return the enabled fields per entity with the caller's tenant overrides; disabled fields are absent.

    \f
    Args:
        request: the request (ETag).
        session: database session.
        user: the caller (any signed-in role).
        entity: only this entity; all when omitted.

    Returns:
        `{entity: [field, ...]}` with an ETag.

    Raises:
        ValidationFailedError: unknown entity.
    """
    entities = fieldconfig.load().entities
    if entity is not None and entity not in entities:
        raise ValidationFailedError(details={"entity": f"unknown; known: {', '.join(sorted(entities))}"})
    code = await registry.fpo_code(session, user.fpo_id)
    body = {
        e: [f.model_dump() for f in fieldconfig.fields_for(e, code)]
        for e in ([entity] if entity else entities)
    }
    return _with_etag(request, body)


@router.get(
    "/features",
    response_model=Features,
    summary="Feature flags in force for the caller's FPO",
    responses=NOT_MODIFIED,
)
async def get_features(request: Request, session: Session, user: AnyRole) -> Response:
    """Return the feature flags and limits with the caller's tenant overrides.

    \f
    Args:
        request: the request (ETag).
        session: database session.
        user: the caller (any signed-in role).

    Returns:
        The flags with an ETag.
    """
    features = fieldconfig.features_for(await registry.fpo_code(session, user.fpo_id))
    return _with_etag(request, features.model_dump())
