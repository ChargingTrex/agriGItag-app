"""Unit tests of the JWTs and `get_current_user`, without a database (DB lookups are monkeypatched).

Covers access-token round trip and expiry, the `pin_token` never acting as a session token (function and
HTTP level), revoked devices, the `X-Assist-Session` header and the audit context it sets.

Serves: FR1, FR14, CLAUDE.md §6 (assist mode recorded), D-024 (token lifetimes, pin_token).
Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import Iterator
from datetime import timedelta
from typing import Any

import jwt
import pytest
from fastapi.security import HTTPAuthorizationCredentials
from httpx import ASGITransport, AsyncClient

from agritrace.core import auth
from agritrace.core.audit import _context
from agritrace.core.config import get_settings
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.errors import AssistSessionInvalidError, UnauthorizedError
from agritrace.core.time import utcnow
from agritrace.main import create_app
from agritrace.modules.identity.models import AssistSession, Device

USER, FPO, DEVICE, FARMER, ASSIST = (uuid.uuid4() for _ in range(5))


@pytest.fixture(autouse=True)
def secret(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Configure a JWT secret for each test.

    Args:
        monkeypatch: pytest's environment patcher.

    Returns:
        An iterator yielding once while the setting is active.

    Side effects:
        Sets JWT_SECRET, clears the cached settings before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test-secret-of-at-least-32-bytes!")
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def _access(**overrides: Any) -> str:
    """Issue an access token for the test user.

    Args:
        **overrides: keyword arguments for `issue_access_token`.

    Returns:
        The token.
    """
    args: dict[str, Any] = {
        "user_id": USER,
        "fpo_id": FPO,
        "role": Role.FIELD_OFFICER,
        "device_id": DEVICE,
        "is_super_admin": False,
    }
    return auth.issue_access_token(**(args | overrides))


def _bearer(token: str) -> HTTPAuthorizationCredentials:
    """Wrap a token like FastAPI's `HTTPBearer` does.

    Args:
        token: the JWT.

    Returns:
        The parsed credentials.
    """
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)


def _db(
    monkeypatch: pytest.MonkeyPatch, *, device_active: bool = True, farmer: uuid.UUID | None = None
) -> None:
    """Replace the two DB lookups of `get_current_user`.

    Args:
        monkeypatch: pytest's patcher.
        device_active: what the device-revocation check answers.
        farmer: what the assist-session lookup answers.

    Side effects:
        Patches `auth._device_active` and `auth._assist_farmer` for the test.
    """

    async def device(*_: object) -> bool:
        """Answer the device check.

        Args:
            *_: session, device id, user id (ignored).

        Returns:
            `device_active`.
        """
        return device_active

    async def assist(*_: object) -> uuid.UUID | None:
        """Answer the assist lookup.

        Args:
            *_: session, assist id, officer id (ignored).

        Returns:
            `farmer`.
        """
        return farmer

    monkeypatch.setattr(auth, "_device_active", device)
    monkeypatch.setattr(auth, "_assist_farmer", assist)


def test_access_token_round_trip_carries_the_contract_claims() -> None:
    """`sub`, `fpo`, `role`, `dev`, `jti`, 15-minute expiry, HS256, typ=access."""
    token = _access(is_super_admin=True)
    assert jwt.get_unverified_header(token)["alg"] == "HS256"
    claims = auth.decode_token(token, "access")
    assert (claims["sub"], claims["fpo"], claims["role"], claims["dev"]) == (
        str(USER),
        str(FPO),
        "field_officer",
        str(DEVICE),
    )
    assert claims["exp"] - claims["iat"] == 15 * 60 and claims["jti"] and claims["typ"] == "access"
    user = auth.user_from_claims(claims)
    assert (user.user_id, user.fpo_id, user.role, user.device_id, user.is_super_admin) == (
        USER,
        FPO,
        Role.FIELD_OFFICER,
        DEVICE,
        True,
    )


def test_expired_forged_and_garbage_tokens_are_unauthorized() -> None:
    """Expired (issued 16 minutes ago), signed with another secret, or not a JWT: all 401."""
    expired = _access(now=utcnow() - timedelta(minutes=16))
    forged = jwt.encode({"sub": str(USER), "typ": "access"}, "another-secret-another-secret-xx", "HS256")
    for token in (expired, forged, "not-a-jwt"):
        with pytest.raises(UnauthorizedError):
            auth.decode_token(token, "access")


def test_pin_token_has_no_role_or_fpo_and_is_not_a_session_token() -> None:
    """The pin token carries only user and device, lives 5 minutes, and is refused as an access token."""
    pin = auth.issue_pin_token(user_id=USER, device_id=DEVICE)
    claims = auth.decode_token(pin, "pin")
    assert "role" not in claims and "fpo" not in claims and claims["exp"] - claims["iat"] == 300
    with pytest.raises(UnauthorizedError) as err:
        auth.decode_token(pin, "access")
    assert err.value.details == {"reason": "wrong_token_type"}
    with pytest.raises(UnauthorizedError):
        auth.decode_token(_access(), "pin")


async def test_get_current_user_refuses_a_pin_token(monkeypatch: pytest.MonkeyPatch) -> None:
    """A pin token in `Authorization` never resolves to a caller.

    Args:
        monkeypatch: pytest's patcher.
    """
    _db(monkeypatch)
    with pytest.raises(UnauthorizedError):
        await auth.get_current_user(None, _bearer(auth.issue_pin_token(user_id=USER, device_id=DEVICE)))  # type: ignore[arg-type]


async def test_revoked_device_is_unauthorized(monkeypatch: pytest.MonkeyPatch) -> None:
    """A valid access token from a signed-out device is refused (logout takes effect within one request).

    Args:
        monkeypatch: pytest's patcher.
    """
    _db(monkeypatch, device_active=False)
    with pytest.raises(UnauthorizedError) as err:
        await auth.get_current_user(None, _bearer(_access()))  # type: ignore[arg-type]
    assert err.value.details == {"reason": "device_revoked"}


async def test_assist_header_sets_on_behalf_of_and_the_audit_context(monkeypatch: pytest.MonkeyPatch) -> None:
    """An open assist session of the officer fills both caller fields and the audit context.

    Args:
        monkeypatch: pytest's patcher.
    """
    _db(monkeypatch, farmer=FARMER)
    user = await auth.get_current_user(None, _bearer(_access()), ASSIST, "req-7")  # type: ignore[arg-type]
    assert (user.on_behalf_of_farmer_id, user.assist_session_id) == (FARMER, ASSIST)
    ctx = _context.get()
    assert ctx is not None
    assert (ctx.actor_user_id, ctx.on_behalf_of_farmer_id, ctx.assist_session_id) == (USER, FARMER, ASSIST)
    assert (ctx.device_id, ctx.request_id) == (DEVICE, "req-7")
    _context.set(None)  # leave no actor behind for later tests


async def test_closed_or_foreign_assist_session_is_refused(monkeypatch: pytest.MonkeyPatch) -> None:
    """An assist id that is not an open session of this officer is `assist_session_invalid`.

    Args:
        monkeypatch: pytest's patcher.
    """
    _db(monkeypatch, farmer=None)
    with pytest.raises(AssistSessionInvalidError):
        await auth.get_current_user(None, _bearer(_access()), ASSIST)  # type: ignore[arg-type]


def test_core_table_handles_match_the_identity_models() -> None:
    """core.auth reads `devices` and `assist_sessions` through handles naming real model columns."""
    assert set(auth.DEVICES.columns.keys()) <= set(Device.__table__.columns.keys())
    assert set(auth.ASSIST_SESSIONS.columns.keys()) <= set(AssistSession.__table__.columns.keys())


async def test_http_pin_verify_refuses_an_access_token_and_me_refuses_a_pin_token() -> None:
    """Over HTTP: `/v1/auth/pin/verify` wants a pin token; `/v1/me` wants an access token (both 401)."""
    app = create_app()

    async def no_session() -> None:
        """Stand in for the DB session; neither request gets far enough to use it.

        Returns:
            None.
        """

    app.dependency_overrides[get_session] = no_session
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        access = {"Authorization": f"Bearer {_access()}"}
        pin = {"Authorization": f"Bearer {auth.issue_pin_token(user_id=USER, device_id=DEVICE)}"}
        r1 = await c.post("/v1/auth/pin/verify", json={"pin": "1234"}, headers=access)
        r2 = await c.get("/v1/me", headers=pin)
        r3 = await c.post("/v1/auth/pin/verify", json={"pin": "1234"})
    for r in (r1, r2, r3):
        assert r.status_code == 401 and r.json()["error"]["code"] == "unauthorized"
