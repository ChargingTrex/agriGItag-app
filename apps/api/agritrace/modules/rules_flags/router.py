"""Flags HTTP routes: list, read and resolve the findings of the server rules (under /v1).

Serves: FR70 (manual review only on flags: outcome, method, reason), FR11/FR28/FR56/FR68/FR69 (what is
flagged), backend-design §1 rules_flags row, docs/api/conventions.md (cursor pages), D-020 (/v1, additive).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); portal P02 (flags and plot
review) and the officer app M10 through the generated clients (D-003).
"""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import SUPER_ADMIN, CurrentUser, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import FlagStatus, Role, Severity
from agritrace.core.schemas import ErrorEnvelope, Page
from agritrace.modules.rules_flags import service
from agritrace.modules.rules_flags.schemas import FlagOut, FlagResolveIn

router = APIRouter(tags=["flags"])
Session = Annotated[AsyncSession, Depends(get_session)]
Reader = Annotated[
    CurrentUser,
    Depends(require_role(Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER, SUPER_ADMIN)),
]
Resolver = Annotated[CurrentUser, Depends(require_role(*service.RESOLVERS))]
E401 = {"model": ErrorEnvelope, "description": "`unauthorized`: no valid access token."}
E404 = {"model": ErrorEnvelope, "description": "`not_found`: no such flag, or it belongs to another FPO."}


@router.get(
    "/flags",
    response_model=Page[FlagOut],
    summary="List flags",
    description=(
        "Rule findings of one FPO (default: the caller's; any FPO for a super-admin), newest first. "
        "Filter by `assignee` (role expected to review), `status`, `severity`; `hold` flags keep a lot out "
        "of GI-labelled batches until an FPO admin resolves them."
    ),
    responses={
        401: E401,
        403: {"model": ErrorEnvelope, "description": "`forbidden`: farmers use sync pull."},
    },
)
async def list_flags(
    session: Session,
    user: Reader,
    fpo_id: Annotated[uuid.UUID | None, Query(description="FPO to list; default the caller's.")] = None,
    assignee: Annotated[Role | None, Query(description="Only flags assigned to this role.")] = None,
    status: Annotated[FlagStatus | None, Query(description="Only flags in this status.")] = None,
    severity: Annotated[Severity | None, Query(description="Only flags of this severity.")] = None,
    cursor: Annotated[
        uuid.UUID | None, Query(description="`next_cursor` of the previous page; omit for the first page.")
    ] = None,
    limit: Annotated[int, Query(ge=1, le=200, description="Page size, 1–200.")] = 50,
) -> Page[FlagOut]:
    """List flags.

    \f
    Args:
        session: database session.
        user: the caller.
        fpo_id: FPO filter.
        assignee: assigned-role filter.
        status: status filter.
        severity: severity filter.
        cursor: pagination cursor.
        limit: page size.

    Returns:
        One page of flags.

    Raises:
        NotFoundError: another FPO without super-admin rights (404).
    """
    return await service.list_flags(
        session,
        user,
        fpo_id=fpo_id,
        assigned_role=assignee,
        status=status,
        severity=severity,
        cursor=cursor,
        limit=limit,
    )


@router.get(
    "/flags/{flag_id}",
    response_model=FlagOut,
    summary="Read a flag",
    description="One rule finding with the inputs and limits behind it (`details`) and its review state.",
    responses={401: E401, 404: E404},
)
async def get_flag(session: Session, user: Reader, flag_id: uuid.UUID) -> FlagOut:
    """Read one flag.

    \f
    Args:
        session: database session.
        user: the caller.
        flag_id: the flag.

    Returns:
        The flag.

    Raises:
        NotFoundError: unknown flag or another FPO's (404).
    """
    return await service.get_flag(session, user, flag_id)


@router.post(
    "/flags/{flag_id}/resolve",
    response_model=FlagOut,
    summary="Resolve a flag",
    description=(
        "Records the review outcome (FR70): `looks_fine` → cleared, `fixed` → fixed, `escalated` → handed to "
        "the FPO admin. A coded `reason_code` is required. Field officers resolve info and warn flags; only "
        "an FPO admin resolves a `hold` or an escalated flag. Clearing the last hold of a lot makes it "
        "eligible for GI batches again. A later rule run reopens the flag when the problem comes back worse "
        "(higher severity); at the same severity a `looks_fine` decision stands. Open and escalated flags "
        "whose rule no longer fires are closed by the system as `fixed` / `rule_passed`."
    ),
    responses={
        401: E401,
        403: {
            "model": ErrorEnvelope,
            "description": "`forbidden`: role is not field_officer or fpo_admin; `resolution_forbidden`: a "
            "field officer on a hold or escalated flag.",
        },
        404: E404,
        409: {"model": ErrorEnvelope, "description": "`flag_not_open`: already cleared or fixed."},
        422: {
            "model": ErrorEnvelope,
            "description": "`reason_required`: no `reason_code`; `validation_error`.",
        },
    },
)
async def resolve_flag(session: Session, user: Resolver, flag_id: uuid.UUID, body: FlagResolveIn) -> FlagOut:
    """Resolve a flag and commit.

    \f
    Args:
        session: database session.
        user: the caller (field officer or FPO admin).
        flag_id: the flag.
        body: outcome, reason code and note.

    Returns:
        The resolved flag.

    Raises:
        NotFoundError: unknown flag or another FPO's (404).
        FlagNotOpenError: already resolved (409).
        ResolutionForbiddenError: officer on a hold or escalated flag (403).
        ReasonRequiredError: no reason code (422).
    """
    flag = await service.resolve_flag(session, user, flag_id, body)
    await session.commit()
    return FlagOut.model_validate(flag)
