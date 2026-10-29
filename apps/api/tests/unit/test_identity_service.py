"""Unit tests of identity service and router paths with an in-memory stand-in for the DB session.

Covers the review B02-r1 fixes: cookie-sourced refresh answered by cookie only (R2), tokens older than the
device's last sign-in refused (R3), no device sign-out from a guessed token or a rebind (R4), PIN change
needs the current PIN (R6), pin token single use (P3-4).

Serves: FR1, Arch §Security, D-022, D-024. Integration counterparts: tests/integration/test_identity.py.
Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import Iterator
from datetime import timedelta
from types import SimpleNamespace
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace.core import auth
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.errors import (
    DeviceInUseError,
    PinInvalidError,
    PinLockedError,
    RefreshReusedError,
    UnauthorizedError,
)
from agritrace.core.time import utcnow
from agritrace.main import create_app
from agritrace.modules.identity import service
from agritrace.modules.identity.models import Device, User
from agritrace.modules.identity.schemas import OtpVerifyIn, SessionOut

OWNER, OTHER, DEVICE = uuid.uuid4(), uuid.uuid4(), uuid.uuid4()


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


class FakeSession:
    """Just enough of `AsyncSession` for the code paths under test: `get`, `add`, `commit`, `execute`."""

    def __init__(self, *objects: Any, row: Any = None) -> None:
        """Hold the objects `get` returns.

        Args:
            *objects: ORM objects, looked up by `(type, id)`.
            row: what `execute(...).first()` returns.
        """
        self.objects = {(type(o), o.id): o for o in objects}
        self.row = row
        self.commits = 0

    async def get(self, model: type, key: uuid.UUID, **_: Any) -> Any:
        """Look an object up.

        Args:
            model: the ORM class.
            key: the primary key.
            **_: `with_for_update` and friends (ignored).

        Returns:
            The object or None.
        """
        return self.objects.get((model, key))

    def add(self, obj: Any) -> None:
        """Remember a new object.

        Args:
            obj: the ORM object.
        """
        self.objects[(type(obj), obj.id)] = obj

    async def commit(self) -> None:
        """Count commits."""
        self.commits += 1

    async def execute(self, _query: Any) -> Any:
        """Answer any query with the configured row.

        Args:
            _query: the statement (ignored).

        Returns:
            An object whose `first()` returns `row`.
        """
        return SimpleNamespace(first=lambda: self.row)


def _device(user_id: uuid.UUID, *, active: bool) -> Device:
    """Build a device row.

    Args:
        user_id: owner.
        active: signed in (no `revoked_at`).

    Returns:
        A transient `Device`.
    """
    return Device(
        id=DEVICE,
        user_id=user_id,
        platform="android",
        revoked_at=None if active else utcnow() - timedelta(days=1),
    )


def _verify(device_id: uuid.UUID = DEVICE) -> OtpVerifyIn:
    """Build an OTP verify body for the device.

    Args:
        device_id: the device.

    Returns:
        The body.
    """
    return OtpVerifyIn(phone="+919800000003", code="123456", device_id=device_id, platform="android")


async def test_device_active_for_another_user_is_not_rebound() -> None:
    """R4b: passing your own OTP on someone's active device id is `device_in_use`, and the owner stays in."""
    device = _device(OWNER, active=True)
    with pytest.raises(DeviceInUseError):
        await service._bind_device(FakeSession(device), OTHER, _verify())  # type: ignore[arg-type]
    assert device.user_id == OWNER and device.revoked_at is None


async def test_signed_out_device_may_switch_user_and_own_device_rebinds() -> None:
    """A shared phone signed out by its last user may sign another user in; the owner may sign in again."""
    signed_out = _device(OWNER, active=False)
    bound = await service._bind_device(FakeSession(signed_out), OTHER, _verify())  # type: ignore[arg-type]
    assert bound.user_id == OTHER and bound.refresh_token_hash is None
    mine = _device(OWNER, active=True)
    assert (await service._bind_device(FakeSession(mine), OWNER, _verify())).user_id == OWNER  # type: ignore[arg-type]


async def test_guessed_refresh_token_changes_nothing_and_previous_one_revokes() -> None:
    """R4a: a token built from a known device id is a plain 401; the rotated-out one is reuse and revokes."""
    current, previous = service.new_refresh_token(DEVICE), service.new_refresh_token(DEVICE)
    device = _device(OWNER, active=True)
    device.refresh_token_hash = service.hash_refresh(current)
    device.previous_refresh_token_hash = service.hash_refresh(previous)
    session = FakeSession(device)
    with pytest.raises(UnauthorizedError):
        await service.refresh(session, f"{DEVICE}.guessed")  # type: ignore[arg-type]
    assert device.revoked_at is None and session.commits == 0
    with pytest.raises(RefreshReusedError):
        await service.refresh(session, previous)  # type: ignore[arg-type]
    assert device.revoked_at is not None and device.refresh_token_hash is None and session.commits == 1


def test_tokens_issued_before_the_last_sign_in_are_stale() -> None:
    """R3: `iat < floor(signed_in_at)` is stale; the same second or later is fine; never stamped is fine."""
    signed_in = utcnow().replace(microsecond=700_000)
    second = int(signed_in.timestamp())
    assert auth.issued_before_sign_in(second - 1, signed_in)
    assert not auth.issued_before_sign_in(second, signed_in)
    assert not auth.issued_before_sign_in(second - 1, None)


async def test_device_check_refuses_a_token_from_before_a_new_sign_in() -> None:
    """R3: logout, sign in again within 15 min: the old access token (older `iat`) is still refused."""
    signed_in = utcnow()
    row = SimpleNamespace(signed_in_at=signed_in)
    old_iat = int(signed_in.timestamp()) - 60
    session = FakeSession(row=row)
    assert not await auth._device_active(session, DEVICE, OWNER, old_iat)  # type: ignore[arg-type]
    assert await auth._device_active(session, DEVICE, OWNER, int(signed_in.timestamp()) + 1)  # type: ignore[arg-type]
    assert not await auth._device_active(FakeSession(row=None), DEVICE, OWNER, old_iat)  # type: ignore[arg-type]


async def test_pin_change_needs_the_current_pin() -> None:
    """R6: with a PIN set, a missing or wrong current PIN is `pin_invalid`; the right one changes it."""
    user = User(id=OWNER, pin_hash=service.hash_pin("2468"), pin_attempts=0, pin_locked_until=None)
    caller = CurrentUser(user_id=OWNER, fpo_id=uuid.uuid4(), role=Role.FPO_ADMIN, device_id=DEVICE)
    session = FakeSession(user)
    with pytest.raises(PinInvalidError):
        await service.set_pin(session, caller, "1357", None)  # type: ignore[arg-type]
    assert user.pin_attempts == 0  # a missing field is not a guess
    with pytest.raises(PinInvalidError):
        await service.set_pin(session, caller, "1357", "0000")  # type: ignore[arg-type]
    assert user.pin_attempts == 1
    await service.set_pin(session, caller, "1357", "2468")  # type: ignore[arg-type]
    assert service.pin_matches(user.pin_hash, "1357") and user.pin_attempts == 0


async def test_pin_change_locks_after_five_wrong_current_pins() -> None:
    """R6: the current-PIN check shares the 5-tries lock."""
    user = User(id=OWNER, pin_hash=service.hash_pin("2468"), pin_attempts=4, pin_locked_until=None)
    caller = CurrentUser(user_id=OWNER, fpo_id=uuid.uuid4(), role=Role.FPO_ADMIN, device_id=DEVICE)
    with pytest.raises(PinLockedError):
        await service.set_pin(FakeSession(user), caller, "1357", "0000")  # type: ignore[arg-type]
    assert user.pin_locked_until is not None


async def test_first_pin_set_needs_no_current_pin() -> None:
    """With no PIN yet, `POST /v1/auth/pin` sets one without `current_pin`."""
    user = User(id=OWNER, pin_hash=None, pin_attempts=0, pin_locked_until=None)
    caller = CurrentUser(user_id=OWNER, fpo_id=uuid.uuid4(), role=Role.QC_OFFICER, device_id=DEVICE)
    await service.set_pin(FakeSession(user), caller, "1357", None)  # type: ignore[arg-type]
    assert user.pin_hash is not None and service.pin_matches(user.pin_hash, "1357")


async def test_used_pin_token_is_refused(monkeypatch: pytest.MonkeyPatch) -> None:
    """P3-4: a pin token issued before the device's last sign-in cannot open another session.

    Args:
        monkeypatch: pytest's patcher.
    """
    device = _device(OWNER, active=True)
    device.signed_in_at = utcnow()
    user = User(id=OWNER, pin_hash=service.hash_pin("2468"), is_super_admin=False)

    async def account(*_: Any, **__: Any) -> tuple[User, Any]:
        """Return the officer's account.

        Args:
            *_: ignored.
            **__: ignored.

        Returns:
            The user and a stand-in membership.
        """
        return user, SimpleNamespace(role=Role.FPO_ADMIN, fpo_id=uuid.uuid4())

    monkeypatch.setattr(service, "_account", account)
    stale_iat = int(device.signed_in_at.timestamp()) - 10
    with pytest.raises(UnauthorizedError) as err:
        await service.verify_pin(FakeSession(device), OWNER, DEVICE, stale_iat, "2468")  # type: ignore[arg-type]
    assert err.value.details == {"reason": "pin_token_used"}


async def test_cookie_refresh_is_answered_by_cookie_only(monkeypatch: pytest.MonkeyPatch) -> None:
    """R2: a refresh token read from the cookie never comes back in the body, even without `X-Client: web`.

    Args:
        monkeypatch: pytest's patcher.
    """
    seen: list[str] = []

    async def fake_refresh(_session: Any, token: str) -> SessionOut:
        """Stand in for the DB rotation.

        Args:
            _session: ignored.
            token: the token the router read.

        Returns:
            A session carrying a new refresh token.
        """
        seen.append(token)
        return SessionOut(
            kind="session",
            access_token="a",
            refresh_token="new",
            expires_in=900,
            roles=["fpo_admin"],
            fpo_id=OWNER,
        )

    async def no_session() -> None:
        """Stand in for the DB session (unused).

        Returns:
            None.
        """

    monkeypatch.setattr(service, "refresh", fake_refresh)
    app = create_app()
    app.dependency_overrides[get_session] = no_session
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        by_cookie = await c.post("/v1/auth/refresh", json={}, headers={"Cookie": "agritrace_refresh=old"})
        by_body = await c.post("/v1/auth/refresh", json={"refresh_token": "mobile-old"})
    assert seen == ["old", "mobile-old"]
    assert (
        by_cookie.json()["refresh_token"] is None
        and "agritrace_refresh=new" in by_cookie.headers["set-cookie"]
    )
    assert by_body.json()["refresh_token"] == "new" and "set-cookie" not in by_body.headers
