"""Unit tests of the role guard and the missing-token path of `get_current_user`.

Serves: FR14 (role-based access), CLAUDE.md §6 (every call scoped to role). Token and assist-header
behaviour is in tests/unit/test_identity_tokens.py; the full role matrix in test_identity_schemas.py.
Callers: pytest (`make test-unit`).
"""

import uuid

import pytest

from agritrace.core.auth import CurrentUser, get_current_user, require_role
from agritrace.core.enums import Role
from agritrace.core.errors import ForbiddenError, UnauthorizedError


def _user(role: Role) -> CurrentUser:
    """Build a caller with the given role.

    Args:
        role: the caller's role.

    Returns:
        A `CurrentUser` in a random FPO.
    """
    return CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=role)


async def test_no_bearer_token_is_unauthorized() -> None:
    """A request without `Authorization: Bearer` is refused with `unauthorized` before any DB read."""
    with pytest.raises(UnauthorizedError):
        await get_current_user(session=None, credentials=None)  # type: ignore[arg-type]


async def test_require_role_admits_listed_roles_only() -> None:
    """A listed role passes through; any other role is `forbidden`; no roles listed admits everyone."""
    admin = _user(Role.FPO_ADMIN)
    guard = require_role(Role.FPO_ADMIN, Role.FIELD_OFFICER)
    assert await guard(admin) is admin
    with pytest.raises(ForbiddenError) as err:
        await guard(_user(Role.FARMER))
    assert err.value.details == {"required_roles": ["fpo_admin", "field_officer"]}
    viewer = _user(Role.VIEWER)
    assert await require_role()(viewer) is viewer
