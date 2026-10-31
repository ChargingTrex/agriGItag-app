"""Notifications HTTP route: the caller's own messages (under /v1).

Serves: FR7 (reminders and results the farmer or officer received), backend-design.md §1 notifications row,
docs/api/conventions.md (cursor pages), D-020 (/v1, additive).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); the mobile app and portal
through the generated clients (D-003).
"""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.notifications import service
from agritrace.modules.notifications.schemas import NotificationOut

router = APIRouter(tags=["notifications"])


@router.get(
    "/notifications",
    response_model=Page[NotificationOut],
    summary="List my notifications",
    description="Messages sent to the caller (any role), newest first; secrets in payloads appear as `***`.",
    responses={401: {"model": ErrorEnvelope, "description": "`unauthorized`: no valid access token."}},
)
async def list_my_notifications(
    session: Annotated[AsyncSession, Depends(get_session)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
    cursor: Annotated[
        uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
    ] = None,
    limit: Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")] = 50,
) -> Page[NotificationOut]:
    """List the caller's notifications.

    \f
    Args:
        session: database session.
        user: the caller; in assist mode still the officer, not the farmer.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of notifications.

    Raises:
        UnauthorizedError: no valid token (401).
    """
    return await service.list_mine(session, user.user_id, cursor, limit)
