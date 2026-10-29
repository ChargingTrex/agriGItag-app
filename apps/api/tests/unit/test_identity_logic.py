"""Unit tests of the identity service's pure security helpers (no database).

Covers OTP code generation and hashing, OTP and PIN attempt counting and locks, PIN hashing, refresh token
format, rotation and reuse detection, and the roles a session carries.

Serves: FR1 (OTP sign-in), Arch §Security (office PIN), D-024 (refresh rotation and reuse detection).
Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import Iterator
from datetime import timedelta

import pytest

from agritrace.core.config import get_settings
from agritrace.core.enums import Role
from agritrace.core.time import utcnow
from agritrace.modules.identity import service
from agritrace.modules.identity.models import Membership, User

NOW = utcnow()


@pytest.fixture(autouse=True)
def secret(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Configure a JWT secret (the OTP HMAC key) for each test.

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


def test_otp_codes_are_six_digits() -> None:
    """Codes are 6 decimal digits, zero-padded."""
    codes = {service.new_otp_code() for _ in range(200)}
    assert all(len(c) == 6 and c.isdigit() for c in codes) and len(codes) > 150


def test_otp_hash_is_keyed_bound_to_the_phone_and_never_the_code() -> None:
    """Same input, same hash; another phone or another secret gives another hash; the code is not in it."""
    h = service.hash_otp("+919876543210", "123456")
    assert h == service.hash_otp("+919876543210", "123456") and "123456" not in h
    assert h != service.hash_otp("+919876543211", "123456")
    get_settings().jwt_secret = "another-secret-another-secret-xx"
    assert h != service.hash_otp("+919876543210", "123456")


def test_otp_attempts_lock_on_the_fifth_wrong_code() -> None:
    """Four wrong codes are `invalid`, the fifth `locked`; a locked challenge refuses even the right code."""
    expires, attempts, outcomes = NOW + timedelta(minutes=5), 0, []
    for _ in range(5):
        outcome, attempts = service.otp_outcome(attempts, expires, NOW, matches=False)
        outcomes.append(outcome)
    assert outcomes == ["invalid"] * 4 + ["locked"] and attempts == 5
    assert service.otp_outcome(attempts, expires, NOW, matches=True) == ("locked", 5)


def test_otp_expiry_and_success() -> None:
    """A right code within 5 minutes is `ok` without counting; after expiry it is `expired`."""
    expires = NOW + timedelta(minutes=5)
    assert service.otp_outcome(2, expires, NOW, matches=True) == ("ok", 2)
    assert service.otp_outcome(0, expires, expires, matches=True) == ("expired", 0)


def test_pin_locks_for_five_minutes_after_five_wrong_and_resets_on_success() -> None:
    """Fifth wrong PIN locks for 5 minutes; while locked the right PIN fails; afterwards a match resets."""
    attempts, locked_until = 0, None
    for i in range(1, 5):
        outcome, attempts, locked_until = service.pin_outcome(attempts, locked_until, NOW, matches=False)
        assert (outcome, attempts, locked_until) == ("invalid", i, None)
    outcome, attempts, locked_until = service.pin_outcome(attempts, locked_until, NOW, matches=False)
    assert (outcome, attempts, locked_until) == ("locked", 0, NOW + timedelta(minutes=5))
    assert (
        service.pin_outcome(attempts, locked_until, NOW + timedelta(minutes=4), matches=True)[0] == "locked"
    )
    assert service.pin_outcome(attempts, locked_until, NOW + timedelta(minutes=5), matches=True) == (
        "ok",
        0,
        None,
    )


def test_pin_hash_is_argon2id_and_verifies() -> None:
    """The stored PIN is an Argon2id hash; right PIN matches, wrong PIN and garbage hash do not."""
    h = service.hash_pin("4321")
    assert h.startswith("$argon2id$") and "4321" not in h
    assert service.pin_matches(h, "4321") and not service.pin_matches(h, "1234")
    assert not service.pin_matches("not-a-hash", "4321")


def test_refresh_token_names_its_device_and_is_stored_hashed() -> None:
    """The token is `<device_id>.<secret>`; malformed tokens yield no device; only a SHA-256 is stored."""
    device = uuid.uuid4()
    token = service.new_refresh_token(device)
    assert service.refresh_device_id(token) == device
    assert service.refresh_device_id("garbage") is None and service.refresh_device_id("x.y") is None
    assert len(service.hash_refresh(token)) == 64 and token not in service.hash_refresh(token)


def test_refresh_rotation_and_reuse_detection() -> None:
    """Current token ok; after rotation the old one is `reused`; a signed-out device answers `revoked`."""
    device = uuid.uuid4()
    first = service.new_refresh_token(device)
    stored = service.hash_refresh(first)
    assert service.refresh_outcome(stored, False, first) == "ok"
    second = service.new_refresh_token(device)  # rotation: the device now stores the second hash
    stored = service.hash_refresh(second)
    assert service.refresh_outcome(stored, False, second) == "ok"
    assert service.refresh_outcome(stored, False, first) == "reused"
    assert service.refresh_outcome(None, True, second) == "revoked"
    assert service.refresh_outcome(stored, True, second) == "revoked"


def test_roles_of_adds_super_admin_flag() -> None:
    """A session's roles are the membership role plus `super_admin` when flagged."""
    membership = Membership(role=Role.FPO_ADMIN, fpo_id=uuid.uuid4(), user_id=uuid.uuid4())
    assert service.roles_of(User(is_super_admin=False), membership) == ["fpo_admin"]
    assert service.roles_of(User(is_super_admin=True), membership) == ["fpo_admin", "super_admin"]
