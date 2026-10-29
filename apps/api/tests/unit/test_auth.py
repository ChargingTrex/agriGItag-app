"""Unit tests of the auth placeholder and the role guard.

Serves: FR14 (role-based access), CLAUDE.md §6 (every call scoped to role). B02 replaces the placeholder
body of `get_current_user`; the role-guard tests stay valid.
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


async def test_placeholder_refuses_everyone() -> None:
    """Until B02 wires JWT, every guarded route answers 401 `unauthorized`."""
    with pytest.raises(UnauthorizedError):
        await get_current_user()


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
