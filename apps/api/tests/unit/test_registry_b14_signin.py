"""Unit tests of the B14 round-2 sign-in rules for a rejected farmer (review B14-r1 P2-R), no Docker.

Covers: `request_otp` sends the code to any known phone, also without an active membership; `verify_otp`
answers `otp_invalid` for a wrong code on an inactive account and for an unknown phone (nothing leaks
before the code check, D-024), and `account_inactive` (403) only after the right code.
Serves: docs/agents/reviews/B14-r1.md P2-R, FR1, D-024, Stage 0 approval.
Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import Iterator
from datetime import timedelta
from types import SimpleNamespace
from typing import Any

import pytest

from agritrace.core.config import get_settings
from agritrace.core.errors import AccountInactiveError, OtpInvalidError
from agritrace.core.time import utcnow
from agritrace.modules.identity import service
from agritrace.modules.identity.models import OtpChallenge, User
from agritrace.modules.identity.schemas import OtpVerifyIn

PHONE = "+919876543210"
CODE = "123456"


@pytest.fixture(autouse=True)
def settings(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Configure a JWT secret and no dev OTP code for each test.

    Args:
        monkeypatch: pytest's environment patcher.

    Returns:
        An iterator yielding once while the settings are active.

    Side effects:
        Sets JWT_SECRET, removes OTP_DEV_CODE, clears the cached settings before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test-secret-of-at-least-32-bytes!")
    monkeypatch.delenv("OTP_DEV_CODE", raising=False)
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


class _Session:
    """Stand-in session: `scalar` answers `known`, `execute` answers the challenge, `scalars` no rows."""

    def __init__(self, known: Any, challenge: OtpChallenge | None = None) -> None:
        """Set the answers.

        Args:
            known: what `scalar` returns (the user row or its id; None for an unknown phone).
            challenge: the newest OTP challenge.
        """
        self.known, self.challenge, self.commits = known, challenge, 0
        self.added: list[Any] = []

    async def scalar(self, *_: Any) -> Any:
        """Answer the user lookup by phone.

        Args:
            *_: the statement (ignored).

        Returns:
            The configured user or id.
        """
        return self.known

    async def scalars(self, *_: Any) -> list[Any]:
        """Answer the recent-challenges query.

        Args:
            *_: the statement (ignored).

        Returns:
            No rows.
        """
        return []

    async def execute(self, *_: Any) -> Any:
        """Answer the newest-challenge query.

        Args:
            *_: the statement (ignored).

        Returns:
            An object whose `scalar()` is the challenge.
        """
        return SimpleNamespace(scalar=lambda: self.challenge)

    def add(self, obj: Any) -> None:
        """Remember a new row.

        Args:
            obj: the ORM object.
        """
        self.added.append(obj)

    async def commit(self) -> None:
        """Count commits."""
        self.commits += 1


async def _no_account(*_: Any, **__: Any) -> None:
    """Stand in for `_account` of a user with no membership left.

    Args:
        *_: ignored.
        **__: ignored.
    """


def _challenge() -> OtpChallenge:
    """Build an open challenge for `CODE`.

    Returns:
        A transient `OtpChallenge` valid for 5 minutes.
    """
    return OtpChallenge(
        phone=PHONE, code_hash=service.hash_otp(PHONE, CODE), expires_at=utcnow() + timedelta(minutes=5),
        attempts=0, consumed_at=None,
    )  # fmt: skip


def _verify(code: str) -> OtpVerifyIn:
    """Build a verify request.

    Args:
        code: the code typed.

    Returns:
        The request body.
    """
    return OtpVerifyIn(phone=PHONE, code=code, device_id=uuid.uuid4(), platform="android")


async def test_request_otp_sends_to_a_known_phone_without_membership(monkeypatch: pytest.MonkeyPatch) -> None:
    """A rejected farmer (user row, no membership) still gets the SMS, so `account_inactive` is reachable.

    Args:
        monkeypatch: pytest's patcher.
    """
    sent: list[Any] = []

    async def send(user: User, code: str) -> None:
        """Record the SMS.

        Args:
            user: recipient.
            code: the code.
        """
        sent.append((user, code))

    monkeypatch.setattr(service, "_send_otp_sms", send)
    monkeypatch.setattr(service, "_account", _no_account)
    user = User(id=uuid.uuid4(), phone=PHONE)
    await service.request_otp(_Session(user), PHONE)  # type: ignore[arg-type]
    assert [u for u, _ in sent] == [user]
    sent.clear()
    await service.request_otp(_Session(None), PHONE)  # type: ignore[arg-type]
    assert sent == []  # unknown phone: challenge stored, no SMS


async def test_wrong_code_on_inactive_account_is_otp_invalid(monkeypatch: pytest.MonkeyPatch) -> None:
    """Wrong code first: the same `otp_invalid` as for anyone; the attempt is counted.

    Args:
        monkeypatch: pytest's patcher.
    """
    monkeypatch.setattr(service, "_account", _no_account)
    challenge = _challenge()
    with pytest.raises(OtpInvalidError):
        await service.verify_otp(_Session(uuid.uuid4(), challenge), _verify("000000"))  # type: ignore[arg-type]
    assert challenge.attempts == 1 and challenge.consumed_at is None


async def test_right_code_on_inactive_account_is_account_inactive(monkeypatch: pytest.MonkeyPatch) -> None:
    """Right code: 403 `account_inactive`, and the challenge is spent.

    Args:
        monkeypatch: pytest's patcher.
    """
    monkeypatch.setattr(service, "_account", _no_account)
    challenge = _challenge()
    session = _Session(uuid.uuid4(), challenge)
    with pytest.raises(AccountInactiveError) as err:
        await service.verify_otp(session, _verify(CODE))  # type: ignore[arg-type]
    assert err.value.status == 403 and err.value.code == "account_inactive"
    assert challenge.consumed_at is not None and session.commits == 1


async def test_right_code_on_unknown_phone_is_otp_invalid(monkeypatch: pytest.MonkeyPatch) -> None:
    """No user row: even the right code (dev setups) answers `otp_invalid`, never `account_inactive`.

    Args:
        monkeypatch: pytest's patcher.
    """
    monkeypatch.setattr(service, "_account", _no_account)
    with pytest.raises(OtpInvalidError):
        await service.verify_otp(_Session(None, _challenge()), _verify(CODE))  # type: ignore[arg-type]
