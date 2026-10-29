"""Caller identity and role guard used by every router: `CurrentUser`, `get_current_user`, `require_role`.

Serves: FR1 (OTP sign-in), FR14 (role-based access), FR24 (tenant isolation), CLAUDE.md §6 (every call
scoped to the caller's FPO and role; assist mode recorded), backend-design.md §3 (Bearer token,
`X-Device-Id`, `X-Assist-Session`).
Callers: module routers (B03+) as FastAPI dependencies; identity (B02) replaces the body of
`get_current_user` with JWT verification and fills the audit context. tests/unit/test_auth.py.

PLACEHOLDER until B02: `get_current_user` always raises `unauthorized`, so every guarded route answers
401. Only its body changes in B02; the signatures below are the contract routers code against.
"""

import uuid
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from typing import Annotated

from fastapi import Depends

from agritrace.core.enums import Role
from agritrace.core.errors import ForbiddenError, UnauthorizedError


@dataclass(frozen=True, slots=True)
class CurrentUser:
    """The authenticated caller of one request, resolved from the access token and headers."""

    user_id: uuid.UUID
    fpo_id: uuid.UUID
    role: Role
    on_behalf_of_farmer_id: uuid.UUID | None = None
    assist_session_id: uuid.UUID | None = None
    device_id: uuid.UUID | None = None


async def get_current_user() -> CurrentUser:
    """Resolve the caller from the Bearer token, `X-Device-Id` and `X-Assist-Session` headers.

    Placeholder: B02 implements JWT verification here (and sets `core.audit.set_audit_context`).

    Returns:
        Never returns until B02 lands.

    Raises:
        UnauthorizedError: always (`unauthorized`, 401), because no token can be verified yet.
    """
    raise UnauthorizedError("Sign-in is not available yet (identity work package B02).")


def require_role(*roles: Role) -> Callable[[CurrentUser], Awaitable[CurrentUser]]:
    """Build a dependency that admits only callers holding one of `roles` in their FPO.

    Usage: `user: Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]`.

    Args:
        *roles: the roles allowed on the route; none given means any signed-in role.

    Returns:
        An async dependency returning the `CurrentUser`.
    """

    async def dependency(user: Annotated[CurrentUser, Depends(get_current_user)]) -> CurrentUser:
        """Check the caller's role.

        Args:
            user: the caller resolved by `get_current_user`.

        Returns:
            The same caller when the role is allowed.

        Raises:
            UnauthorizedError: from `get_current_user` (no valid token).
            ForbiddenError: the caller's role is not in `roles` (`forbidden`, 403).
        """
        if roles and user.role not in roles:
            raise ForbiddenError(details={"required_roles": [str(r) for r in roles]})
        return user

    return dependency
