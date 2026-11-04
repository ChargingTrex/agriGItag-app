"""identity service: OTP sign-in, office PIN, refresh rotation, sign-out, assist sessions and consent.

Implements the phone + OTP + PIN session model (D-024). The pure helpers at the top (code and token
hashing, attempt counting, refresh reuse detection) carry the security logic and are unit-tested without a
database; the async functions below apply them to the identity tables.

Serves: FR1 (OTP sign-in), FR14 (roles), FR24 (tenant scoping), FR41 (consent), Arch §Security and privacy
(device-bound session, office PIN, consent with witness), UserFlows §Onboarding a farmer steps 1–2,
UserFlows §Log in once, CLAUDE.md §6 (assist mode recorded), D-005, D-022, D-024; B14 r2 (a farmer rejected
by the FPO gets `account_inactive` after a correct code); B15 (assist sessions arriving by sync push, D-032);
B23 / SEC P1-1, ASVS 3.3.2 (absolute session lifetime `session_expired`, device revocation route).
Callers: identity router (B02); other modules may call the names in `__all__` (D-004);
tests/unit/test_identity_*.py, tests/integration/test_identity.py.
"""

import asyncio
import hashlib
import hmac
import math
import secrets
import uuid
from datetime import UTC, datetime, timedelta
from typing import Any, Literal

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError
from geoalchemy2 import WKTElement
from pydantic import ValidationError
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import task_names
from agritrace.core.audit import AuditContext, set_audit_context, write_audit
from agritrace.core.auth import (
    ACCESS_TTL,
    PIN_TOKEN_TTL,
    SUPER_ADMIN,
    CurrentUser,
    assert_same_fpo,
    issue_access_token,
    issue_pin_token,
    issued_before_sign_in,
)
from agritrace.core.config import get_settings
from agritrace.core.enums import Role, UserStatus
from agritrace.core.errors import (
    AccountInactiveError,
    ConflictError,
    ConsentConflictError,
    DeviceInUseError,
    ForbiddenError,
    NotFoundError,
    OtpExpiredError,
    OtpInvalidError,
    OtpLockedError,
    PinInvalidError,
    PinLockedError,
    RateLimitedError,
    RefreshReusedError,
    SessionExpiredError,
    UnauthorizedError,
    ValidationFailedError,
)
from agritrace.core.ids import uuid7
from agritrace.core.time import utcnow
from agritrace.modules.identity.models import (
    AssistSession,
    ConsentRecord,
    Device,
    Membership,
    OtpChallenge,
    User,
)
from agritrace.modules.identity.schemas import (
    AssistSessionOut,
    AssistStartIn,
    ConsentIn,
    ConsentOut,
    DeviceOut,
    MembershipOut,
    MeOut,
    OtpVerifyIn,
    PinRequiredOut,
    SessionOut,
    UserOut,
)
from agritrace.modules.registry.models import Farmer

__all__ = [
    "end_assist",
    "list_consents",
    "list_devices",
    "logout",
    "me",
    "record_consent",
    "refresh",
    "request_otp",
    "revoke_consent",
    "revoke_device",
    "set_pin",
    "start_assist",
    "start_assist_from_sync",
    "verify_otp",
    "verify_pin",
]

OTP_TTL = timedelta(minutes=5)
OTP_RESEND_AFTER = timedelta(seconds=60)
OTP_CAP_WINDOW = timedelta(hours=24)
OTP_MAX_ATTEMPTS = 5
PIN_MAX_ATTEMPTS = 5
PIN_LOCK = timedelta(minutes=5)
OTP_TEMPLATE = "otp"

Outcome = Literal["ok", "invalid", "expired", "locked"]
RefreshOutcome = Literal["ok", "revoked", "reused", "invalid"]

_hasher = PasswordHasher()  # Argon2id with argon2-cffi's RFC 9106 low-memory defaults


# ---------------------------------------------------------------- pure helpers (unit-tested)


def new_otp_code() -> str:
    """Draw a fresh one-time code.

    Returns:
        Six decimal digits from a CSPRNG, zero-padded (e.g. `004217`).
    """
    return f"{secrets.randbelow(10**6):06d}"


def hash_otp(phone: str, code: str) -> str:
    """Hash a one-time code for storage; the code itself is never stored (FR1).

    Args:
        phone: the E.164 number the code belongs to (binds the hash to it).
        code: the 6-digit code.

    Returns:
        Hex HMAC-SHA256 of `phone:code`, keyed with a key derived from `JWT_SECRET` for this purpose only.

    Raises:
        pydantic.ValidationError: `JWT_SECRET` is not configured.
    """
    # DECISION D-024: OTP codes are hashed with a keyed HMAC, not Argon2.
    #   ADV: a leaked otp_challenges table reveals nothing without the server secret, and the 1 M code
    #     space is too small for a slow hash to matter; no per-guess CPU cost on a public endpoint.
    #   COMPROMISE: rotating JWT_SECRET invalidates codes in flight (they expire within 5 minutes anyway).
    key = hmac.new(get_settings().jwt_secret.encode(), b"agritrace-otp-v1", hashlib.sha256).digest()
    return hmac.new(key, f"{phone}:{code}".encode(), hashlib.sha256).hexdigest()


def otp_request_wait(recent: list[datetime], now: datetime, daily_cap: int) -> int | None:
    """Decide whether a phone may get another code now.

    Args:
        recent: `created_at` of the phone's challenges in the last 24 hours, newest first (at most
            `daily_cap` of them are needed).
        now: the current time.
        daily_cap: most codes per phone per rolling 24 hours (`OTP_DAILY_CAP`).

    Returns:
        None when a code may be sent; otherwise the seconds to wait (`retry_after_s`), at least 1: until 60 s
        after the newest code, or until the oldest of the last `daily_cap` codes leaves the 24-hour window.
    """
    waits = []
    if recent and now - recent[0] < OTP_RESEND_AFTER:
        waits.append(recent[0] + OTP_RESEND_AFTER - now)
    if len(recent) >= daily_cap:
        waits.append(recent[daily_cap - 1] + OTP_CAP_WINDOW - now)
    return max(1, math.ceil(max(waits).total_seconds())) if waits else None


def otp_outcome(attempts: int, expires_at: datetime, now: datetime, matches: bool) -> tuple[Outcome, int]:
    """Judge one OTP attempt against its challenge.

    Args:
        attempts: wrong guesses recorded so far on the challenge.
        expires_at: when the challenge expires.
        now: the current time.
        matches: whether the submitted code (and account) matched.

    Returns:
        `(outcome, attempts_after)`. A locked challenge stays locked; an expired one is `expired`; a wrong
        guess counts, and the guess that reaches `OTP_MAX_ATTEMPTS` already answers `locked`.
    """
    if attempts >= OTP_MAX_ATTEMPTS:
        return "locked", attempts
    if now >= expires_at:
        return "expired", attempts
    if matches:
        return "ok", attempts
    attempts += 1
    return ("locked" if attempts >= OTP_MAX_ATTEMPTS else "invalid"), attempts


def pin_outcome(
    attempts: int, locked_until: datetime | None, now: datetime, matches: bool
) -> tuple[Outcome, int, datetime | None]:
    """Judge one PIN attempt.

    Args:
        attempts: wrong PINs since the last success or lock.
        locked_until: end of the current lock, if any.
        now: the current time.
        matches: whether the submitted PIN matched the stored hash.

    Returns:
        `(outcome, attempts_after, locked_until_after)`. While locked: `locked`, unchanged. A match resets
        the counter. The wrong PIN that reaches `PIN_MAX_ATTEMPTS` answers `locked` and locks for
        `PIN_LOCK`, resetting the counter for the next window.
    """
    if locked_until is not None and now < locked_until:
        return "locked", attempts, locked_until
    if matches:
        return "ok", 0, None
    attempts += 1
    if attempts >= PIN_MAX_ATTEMPTS:
        return "locked", 0, now + PIN_LOCK
    return "invalid", attempts, None


def hash_pin(pin: str) -> str:
    """Hash an office PIN with Argon2id.

    Args:
        pin: the 4-digit PIN.

    Returns:
        The encoded Argon2id hash (salt and parameters included).
    """
    return _hasher.hash(pin)


def pin_matches(pin_hash: str, pin: str) -> bool:
    """Check a PIN against its stored Argon2id hash.

    Args:
        pin_hash: the stored hash.
        pin: the submitted PIN.

    Returns:
        True on a match; False on a mismatch or an unreadable hash.
    """
    try:
        return _hasher.verify(pin_hash, pin)
    except (VerificationError, InvalidHashError):
        return False


def new_refresh_token(device_id: uuid.UUID) -> str:
    """Draw a refresh token for a device.

    Args:
        device_id: the device the token belongs to (its prefix, so the server can find the device row).

    Returns:
        `<device_id>.<43 url-safe chars>` (256 random bits after the dot).
    """
    return f"{device_id}.{secrets.token_urlsafe(32)}"


def hash_refresh(token: str) -> str:
    """Hash a refresh token for storage on `devices.refresh_token_hash`.

    Args:
        token: the full refresh token.

    Returns:
        Hex SHA-256 (the token has 256 random bits, so a fast hash is enough).
    """
    return hashlib.sha256(token.encode()).hexdigest()


def refresh_device_id(token: str) -> uuid.UUID | None:
    """Read the device id prefix of a refresh token.

    Args:
        token: a refresh token as presented by the client.

    Returns:
        The device id, or None when the token is malformed.
    """
    prefix, dot, _ = token.partition(".")
    try:
        return uuid.UUID(prefix) if dot else None
    except ValueError:
        return None


def refresh_outcome(
    stored_hash: str | None, previous_hash: str | None, revoked: bool, presented: str
) -> RefreshOutcome:
    """Classify a presented refresh token against the device's current and previous hashes.

    Args:
        stored_hash: the device's current refresh hash, or None when signed out.
        previous_hash: the hash rotated out by the last refresh, or None.
        revoked: whether the device is revoked.
        presented: the token the client sent.

    Returns:
        `ok` for the current token; `revoked` when the device is signed out; `reused` for the token rotated
        out last (someone else may hold a copy); `invalid` for anything else (a guess built from a known
        device id must not be able to sign the device out).
    """
    if revoked or stored_hash is None:
        return "revoked"
    presented_hash = hash_refresh(presented)
    if hmac.compare_digest(stored_hash, presented_hash):
        return "ok"
    if previous_hash is not None and hmac.compare_digest(previous_hash, presented_hash):
        return "reused"
    return "invalid"


def roles_of(user: User, membership: Membership) -> list[str]:
    """List the roles a session carries.

    Args:
        user: the signed-in user.
        membership: the membership in force.

    Returns:
        The membership role, plus `super_admin` when the user holds that flag.
    """
    return [membership.role.value] + ([SUPER_ADMIN] if user.is_super_admin else [])


def needs_pin(user: User, membership: Membership) -> bool:
    """Tell whether a sign-in must pass the PIN step.

    Args:
        user: the user who passed the OTP.
        membership: the membership the session will be scoped to.

    Returns:
        True for every office role and for super-admins whatever their membership; False for farmers only.
    """
    return membership.role != Role.FARMER or user.is_super_admin


# ---------------------------------------------------------------- sign-in


async def _account(
    session: AsyncSession, *, phone: str | None = None, user_id: uuid.UUID | None = None, lock: bool = False
) -> tuple[User, Membership] | None:
    """Find an active user and the membership a session is scoped to.

    Args:
        session: database session.
        phone: look up by E.164 phone ...
        user_id: ... or by user id (exactly one of the two).
        lock: take a row lock on the user (PIN attempts must not race).

    Returns:
        `(user, membership)`, or None when the user is unknown, suspended or has no membership.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: a user in several FPOs signs in to the oldest membership; add an FPO switch (a token per
    #   membership) when the first multi-FPO officer appears.
    query = (
        select(User, Membership)
        .join(Membership, Membership.user_id == User.id)
        .where(User.status == UserStatus.ACTIVE)
        .order_by(Membership.created_at, Membership.id)
        .limit(1)
    )
    query = query.where(User.phone == phone) if phone is not None else query.where(User.id == user_id)
    if lock:
        query = query.with_for_update(of=User)
    row = (await session.execute(query)).first()
    return (row[0], row[1]) if row else None


async def _send_otp_sms(user: User, code: str) -> None:
    """Enqueue the OTP SMS on the notifications worker by task name (D-004: no notifications import).

    Args:
        user: the recipient (its id and language go to the task; the task resolves the phone).
        code: the code to send.

    Raises:
        kombu.exceptions.OperationalError: the broker (Valkey) is unreachable.

    Side effects:
        Publishes one `notifications.send` message with template `otp`.
    """
    from agritrace.worker import app  # lazy: the worker reads settings at import; export_openapi has none

    kwargs = {
        "user_id": str(user.id),
        "template_key": OTP_TEMPLATE,
        "channel": "sms",
        "lang": user.lang,
        "payload": {"code": code},
    }
    await asyncio.to_thread(app.send_task, task_names.NOTIFICATIONS_SEND, kwargs=kwargs)


async def request_otp(session: AsyncSession, phone: str) -> None:
    """Create an OTP challenge for a phone and send the code by SMS.

    Unknown phones get a challenge too (no SMS), so the answer never reveals whether a number is
    registered. Any known phone gets the SMS, also one without an active membership (B14: a rejected
    farmer), so `verify_otp` can answer `account_inactive` after a correct code.

    Args:
        session: database session.
        phone: E.164 number.

    Raises:
        RateLimitedError: a code was requested for this phone less than 60 s ago, or `OTP_DAILY_CAP` codes
            in the last 24 hours (`rate_limited`, 429, `details.retry_after_s`).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
        kombu.exceptions.OperationalError: the SMS task could not be enqueued.

    Side effects:
        Inserts one `otp_challenges` row (hash only) and commits; enqueues `notifications.send` for a
        known phone unless `OTP_DEV_CODE` is set (dev: that code is used and no SMS is sent).
    """
    # shortcut: two simultaneous requests can both pass this check; a unique partial index or an advisory
    #   lock would close it if SMS cost from that race ever matters.
    settings, now = get_settings(), utcnow()
    recent = await session.scalars(
        select(OtpChallenge.created_at)
        .where(OtpChallenge.phone == phone, OtpChallenge.created_at > now - OTP_CAP_WINDOW)
        .order_by(OtpChallenge.created_at.desc())
        .limit(settings.otp_daily_cap)
    )
    wait = otp_request_wait(list(recent), now, settings.otp_daily_cap)
    if wait is not None:
        raise RateLimitedError(details={"retry_after_s": wait})
    dev_code = settings.otp_dev_code
    code = dev_code or new_otp_code()
    session.add(OtpChallenge(phone=phone, code_hash=hash_otp(phone, code), expires_at=utcnow() + OTP_TTL))
    user = await session.scalar(select(User).where(User.phone == phone))
    await session.commit()
    if user is not None and dev_code is None:
        await _send_otp_sms(user, code)


async def _bind_device(session: AsyncSession, user_id: uuid.UUID, body: OtpVerifyIn) -> Device:
    """Tie the app installation to the user, signed out until a session is opened on it.

    Args:
        session: database session.
        user_id: the user who passed the OTP step.
        body: the verify request (device id, platform, app version).

    Returns:
        The device row (new, or rebound from a user who signed out on it: a shared family phone).

    Raises:
        DeviceInUseError: the device is signed in for another user (`device_in_use`, 409); knowing a
            device id must not let someone sign its owner out.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts or updates the `devices` row (not committed); drops its old refresh token, so earlier
        sessions on this device end.
    """
    device = await session.get(Device, body.device_id, with_for_update=True)
    if device is None:
        device = Device(id=body.device_id, user_id=user_id, platform=body.platform)
        session.add(device)
    elif device.user_id != user_id and device.revoked_at is None:
        raise DeviceInUseError()
    device.user_id, device.platform, device.app_version = user_id, body.platform, body.app_version
    device.refresh_token_hash, device.previous_refresh_token_hash, device.revoked_at = None, None, utcnow()
    return device


async def _open_session(
    session: AsyncSession, user: User, membership: Membership, device: Device, *, sign_in: bool
) -> SessionOut:
    """Issue an access token and a fresh refresh token on a device.

    Args:
        session: database session.
        user: the signed-in user.
        membership: the membership the session is scoped to.
        device: the device row the session is tied to.
        sign_in: True after an OTP/PIN sign-in (stamps `signed_in_at`, so tokens issued before it, e.g.
            ones killed by an earlier logout, stay dead); False for a refresh (keeps the rotated-out hash
            as `previous_refresh_token_hash` for reuse detection).

    Returns:
        The session body (refresh token included; the router moves it to a cookie for web clients).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Stores the new refresh hash, clears `revoked_at`, stamps `last_seen_at` (and `signed_in_at` on a
        sign-in); commits.
    """
    refresh_token, now = new_refresh_token(device.id), utcnow()
    device.previous_refresh_token_hash = None if sign_in else device.refresh_token_hash
    device.refresh_token_hash, device.revoked_at, device.last_seen_at = hash_refresh(refresh_token), None, now
    if sign_in:
        device.signed_in_at = now
    await session.commit()
    access = issue_access_token(
        user_id=user.id,
        fpo_id=membership.fpo_id,
        role=membership.role,
        device_id=device.id,
        is_super_admin=user.is_super_admin,
    )
    return SessionOut(
        kind="session",
        access_token=access,
        refresh_token=refresh_token,
        expires_in=int(ACCESS_TTL.total_seconds()),
        roles=roles_of(user, membership),
        fpo_id=membership.fpo_id,
    )


async def verify_otp(session: AsyncSession, body: OtpVerifyIn) -> SessionOut | PinRequiredOut:
    """Check the code; open a session for farmers, or hand office roles a `pin_token` (D-024).

    Args:
        session: database session.
        body: phone, code and the device to tie the session to.

    Returns:
        `SessionOut` for farmers; `PinRequiredOut` for field officers, QC officers, admins, viewers and
        every super-admin.

    Raises:
        OtpInvalidError: wrong code, no open challenge, or an unknown phone (same answer).
        AccountInactiveError: the code matched, but the user is suspended or has no membership left
            (`account_inactive`, 403; never before the code check, D-024).
        OtpExpiredError: the challenge is older than 5 minutes.
        OtpLockedError: 5 wrong codes on this challenge.
        DeviceInUseError: the device is signed in for another user.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Counts the attempt or consumes the challenge (also for `account_inactive`); binds the device; on a
        farmer session stores the refresh hash. Commits.
    """
    newest = (
        select(OtpChallenge)
        .where(OtpChallenge.phone == body.phone)
        .order_by(OtpChallenge.created_at.desc())
        .limit(1)
        .with_for_update()
    )
    challenge = (await session.execute(newest)).scalar()
    if challenge is None or challenge.consumed_at is not None:
        raise OtpInvalidError()
    # Look the user and account up whatever the code, so known and unknown phones cost the same.
    known = await session.scalar(select(User.id).where(User.phone == body.phone))
    account = await _account(session, phone=body.phone)
    code_ok = hmac.compare_digest(challenge.code_hash, hash_otp(body.phone, body.code))
    outcome, challenge.attempts = otp_outcome(
        challenge.attempts, challenge.expires_at, utcnow(), code_ok and known is not None
    )
    if outcome != "ok":
        await session.commit()  # keep the counted attempt
    if outcome == "locked":
        raise OtpLockedError()
    if outcome == "expired":
        raise OtpExpiredError()
    if outcome == "invalid":
        raise OtpInvalidError()
    challenge.consumed_at = utcnow()
    if account is None:
        # DECISION D-024: the inactive-account answer comes only after a correct code (B14 r2).
        #   ADV: a rejected farmer learns why sign-in fails; a phone number alone still reveals nothing.
        #   COMPROMISE: such accounts now get an SMS code (cost), so the answer is reachable at all.
        await session.commit()
        raise AccountInactiveError()
    user, membership = account
    device = await _bind_device(session, user.id, body)
    if not needs_pin(user, membership):
        return await _open_session(session, user, membership, device, sign_in=True)
    await session.commit()
    return PinRequiredOut(
        kind="pin_required",
        pin_token=issue_pin_token(user_id=user.id, device_id=device.id),
        expires_in=int(PIN_TOKEN_TTL.total_seconds()),
        pin_set=user.pin_hash is not None,
    )


async def _check_pin(session: AsyncSession, user: User, pin: str, now: datetime) -> None:
    """Verify an office PIN under the 5-tries lockout.

    Args:
        session: database session (the caller holds the user row lock).
        user: the user, with a PIN set.
        pin: the 4 digits entered.
        now: the current time.

    Raises:
        PinInvalidError: wrong PIN (`details.attempts_left`).
        PinLockedError: 5 wrong PINs; locked for 5 minutes (`details.locked_until`).

    Side effects:
        Updates the counter and lock (audited) and commits them before raising; on success resets them
        (not committed).
    """
    assert user.pin_hash is not None
    locked = user.pin_locked_until is not None and now < user.pin_locked_until
    matches = not locked and await asyncio.to_thread(pin_matches, user.pin_hash, pin)
    outcome, user.pin_attempts, user.pin_locked_until = pin_outcome(
        user.pin_attempts, user.pin_locked_until, now, matches
    )
    if outcome == "locked":
        until = user.pin_locked_until
        await session.commit()
        raise PinLockedError(details={"locked_until": until.isoformat() if until else None})
    if outcome != "ok":
        await session.commit()
        raise PinInvalidError(details={"attempts_left": PIN_MAX_ATTEMPTS - user.pin_attempts})


async def verify_pin(
    session: AsyncSession, user_id: uuid.UUID, device_id: uuid.UUID, issued_at: int, pin: str
) -> SessionOut:
    """Trade a `pin_token` plus the PIN for a session; the first PIN ever sent becomes the PIN.

    Args:
        session: database session.
        user_id: the pin token's `sub`.
        device_id: the pin token's `dev`.
        issued_at: the pin token's `iat`; a token older than the device's last sign-in is spent.
        pin: the 4 digits entered.

    Returns:
        The session on the device bound at the OTP step.

    Raises:
        UnauthorizedError: the user can no longer sign in, the device was rebound or is unknown, or the
            pin token was already used for a sign-in.
        PinInvalidError: wrong PIN (`details.attempts_left`).
        PinLockedError: 5 wrong PINs; locked for 5 minutes (`details.locked_until`).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Updates the user's PIN counter, lock or (first time) hash, which writes `audit_log` rows (the hash
        redacted); opens the session (refresh hash and `signed_in_at` on the device). Commits.
    """
    set_audit_context(AuditContext(actor_user_id=user_id, device_id=device_id, request_id=str(uuid7())))
    account = await _account(session, user_id=user_id, lock=True)
    device = await session.get(Device, device_id, with_for_update=True)
    if account is None or device is None or device.user_id != user_id:
        raise UnauthorizedError()
    if issued_before_sign_in(issued_at, device.signed_in_at):
        raise UnauthorizedError(details={"reason": "pin_token_used"})
    user, membership = account
    # DECISION D-024: an office user's first PIN is chosen at the PIN step, right after a passed OTP.
    #   ADV: no session (and no refresh token) exists before a PIN, as the P00 contract requires.
    #   COMPROMISE: whoever passes the first OTP chooses the PIN; same trust as the OTP itself.
    # shortcut: the first OTP sets the PIN (accepted for the pilot, review B02-r1 P2-6); upgrade to an
    #   admin-issued initial PIN for office users (B03/P01).
    if user.pin_hash is None:
        user.pin_hash = await asyncio.to_thread(hash_pin, pin)
    else:
        await _check_pin(session, user, pin, utcnow())
    return await _open_session(session, user, membership, device, sign_in=True)


async def set_pin(session: AsyncSession, caller: CurrentUser, pin: str, current_pin: str | None) -> None:
    """Set or change the caller's office PIN; changing it needs the current PIN.

    Args:
        session: database session.
        caller: a signed-in office user (the router admits office roles only).
        pin: the new 4 digits.
        current_pin: the PIN in force; required when one is set, ignored on the first set.

    Raises:
        UnauthorizedError: the user row is gone.
        PinInvalidError: `current_pin` is missing or wrong (a wrong one counts toward the lock).
        PinLockedError: 5 wrong PINs; locked for 5 minutes.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Stores the new hash and clears the counter and lock (audited, hash redacted); commits.
    """
    user = await session.get(User, caller.user_id, with_for_update=True)
    if user is None:
        raise UnauthorizedError()
    if user.pin_hash is not None:
        if current_pin is None:
            raise PinInvalidError("The current PIN is required.", details={"current_pin": "required"})
        await _check_pin(session, user, current_pin, utcnow())
    user.pin_hash = await asyncio.to_thread(hash_pin, pin)
    user.pin_attempts, user.pin_locked_until = 0, None
    await session.commit()


def _sign_out(device: Device) -> None:
    """Revoke a device and forget its refresh tokens.

    Args:
        device: the device row.

    Side effects:
        Sets `revoked_at`; clears the current and previous refresh hashes (not committed).
    """
    device.refresh_token_hash, device.previous_refresh_token_hash, device.revoked_at = None, None, utcnow()


async def refresh(session: AsyncSession, token: str) -> SessionOut:
    """Rotate a device's refresh token and issue a new access token.

    Args:
        session: database session.
        token: the refresh token presented (body or cookie).

    Returns:
        A new session on the same device; the presented token is no longer valid.

    Raises:
        UnauthorizedError: malformed or unknown token, unknown or signed-out device, or the user can no
            longer sign in. An unknown token for a known device changes nothing.
        RefreshReusedError: the token this device rotated out last (`refresh_reused`, 401); the device is
            signed out so neither copy works any more.
        SessionExpiredError: the current token, but the device's last OTP/PIN sign-in is older than
            `SESSION_MAX_DAYS` (`session_expired`, 401); the device is signed out.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Stores the new refresh hash, or revokes the device on reuse or an expired sign-in. Commits.
    """
    device_id = refresh_device_id(token)
    device = await session.get(Device, device_id, with_for_update=True) if device_id else None
    if device is None:
        raise UnauthorizedError()
    outcome = refresh_outcome(
        device.refresh_token_hash, device.previous_refresh_token_hash, device.revoked_at is not None, token
    )
    account = await _account(session, user_id=device.user_id) if outcome == "ok" else None
    # DECISION D-024 (amended 2026-11-02, B23): a sign-in lives at most SESSION_MAX_DAYS (staff, 30) or
    #   SESSION_MAX_DAYS_FARMER (farmer sessions, 90), however often it refreshes; checked only for the
    #   current token, so a guessed one still changes nothing. A device never stamped with `signed_in_at`
    #   (rows older than migration 0002) counts as expired: fail closed. Super-admins get the staff limit.
    #   ADV: ASVS 3.3.2 L1 for staff; a lost phone is signed out within the limit even if nobody revokes it.
    #   COMPROMISE: farmers deviate from ASVS 3.3.2 (90 > 30 days, UserFlows "log in once"; pending FPO/user
    #     confirmation) and still repeat the SMS code once or twice a season.
    settings = get_settings()
    farmer = account is not None and account[1].role == Role.FARMER and not account[0].is_super_admin
    max_age = timedelta(days=settings.session_max_days_farmer if farmer else settings.session_max_days)
    expired = outcome == "ok" and (device.signed_in_at is None or utcnow() - device.signed_in_at > max_age)
    if outcome in ("reused", "ok") and (account is None or expired):
        _sign_out(device)
        await session.commit()
    if outcome == "reused":
        raise RefreshReusedError()
    if expired:
        raise SessionExpiredError()
    if account is None:
        raise UnauthorizedError()
    return await _open_session(session, *account, device, sign_in=False)


async def logout(session: AsyncSession, caller: CurrentUser) -> None:
    """Sign the caller's device out: its refresh token and access tokens stop working.

    Args:
        session: database session.
        caller: the signed-in caller.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets `devices.revoked_at` and clears the refresh hash; commits.
    """
    device = await session.get(Device, caller.device_id)
    if device is not None:
        _sign_out(device)
        await session.commit()


async def _check_device_owner(session: AsyncSession, caller: CurrentUser, user_id: uuid.UUID) -> None:
    """Allow device reads and revocation for the user themself, or an FPO admin of one of their FPOs.

    Args:
        session: database session.
        caller: the signed-in caller.
        user_id: the user whose devices are concerned.

    Raises:
        NotFoundError: the user holds no membership in the caller's FPO (checked before the role, so no other
            tenant's id is confirmed).
        ForbiddenError: another member and the caller is not an FPO admin.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    if user_id == caller.user_id:
        return
    member = select(Membership.id).where(Membership.user_id == user_id, Membership.fpo_id == caller.fpo_id)
    if await session.scalar(member.limit(1)) is None:
        raise NotFoundError()
    if caller.role != Role.FPO_ADMIN:
        raise ForbiddenError()


async def list_devices(session: AsyncSession, caller: CurrentUser, user_id: uuid.UUID) -> list[DeviceOut]:
    """List a user's devices, newest first, so the one to revoke can be picked (D-024, B23 r2).

    Args:
        session: database session.
        caller: the user themself, or an FPO admin of one of the user's FPOs.
        user_id: the user.

    Returns:
        Every device row of the user, signed out ones included, newest first.

    Raises:
        NotFoundError: the user is outside the caller's FPO.
        ForbiddenError: another member and the caller is not an FPO admin.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    await _check_device_owner(session, caller, user_id)
    rows = await session.scalars(
        select(Device).where(Device.user_id == user_id).order_by(Device.created_at.desc(), Device.id)
    )
    return [DeviceOut.model_validate(d, from_attributes=True) for d in rows]


async def revoke_device(
    session: AsyncSession, caller: CurrentUser, device_id: uuid.UUID, reason: str | None
) -> None:
    """Sign a lost or stolen device out: its user's own call, or an FPO admin's for a member (D-024, B23).

    Args:
        session: database session.
        caller: the signed-in caller.
        device_id: the device to sign out.
        reason: why, for the audit trail; optional.

    Raises:
        NotFoundError: unknown device, or its user holds no membership in the caller's FPO.
        ForbiddenError: another member's device and the caller is not an FPO admin.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets `revoked_at` and clears the refresh hashes (unless already revoked), so the device's next
        request and refresh are 401; inserts an `audit_log` row `device.revoke`; commits.
    """
    device = await session.get(Device, device_id, with_for_update=True)
    if device is None:
        raise NotFoundError()
    await _check_device_owner(session, caller, device.user_id)
    if device.revoked_at is None:
        _sign_out(device)
    # Device is not `Audited` (refresh rotation would flood the log), so this action writes its own row.
    diff = {"user_id": str(device.user_id), "reason": reason}
    await write_audit(session, caller, "device.revoke", "devices", device.id, diff)
    await session.commit()


async def me(session: AsyncSession, caller: CurrentUser) -> MeOut:
    """Describe the caller: profile, every membership and the session's device.

    Args:
        session: database session.
        caller: the signed-in caller.

    Returns:
        The caller's user, memberships (oldest first) and device.

    Raises:
        UnauthorizedError: the user row is gone.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    user = await session.get(User, caller.user_id)
    if user is None:
        raise UnauthorizedError()
    rows = await session.scalars(
        select(Membership).where(Membership.user_id == user.id).order_by(Membership.created_at, Membership.id)
    )
    device = await session.get(Device, caller.device_id)
    return MeOut(
        user=UserOut.model_validate(user, from_attributes=True),
        memberships=[MembershipOut(fpo_id=m.fpo_id, role=m.role) for m in rows],
        device=DeviceOut.model_validate(device, from_attributes=True) if device else None,
    )


# ---------------------------------------------------------------- assist sessions


async def _farmer_in_fpo(session: AsyncSession, caller: CurrentUser, farmer_id: uuid.UUID) -> Farmer:
    """Load a farmer of the caller's FPO.

    Args:
        session: database session.
        caller: the signed-in caller.
        farmer_id: the farmer.

    Returns:
        The farmer row.

    Raises:
        NotFoundError: unknown farmer, another FPO's farmer, or (for a farmer caller) someone else.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    farmer = await session.get(Farmer, farmer_id)
    if farmer is None:
        raise NotFoundError()
    assert_same_fpo(caller, farmer.fpo_id)
    if caller.role == Role.FARMER and farmer.user_id != caller.user_id:
        raise NotFoundError()
    return farmer


async def start_assist(session: AsyncSession, caller: CurrentUser, body: AssistStartIn) -> AssistSessionOut:
    """Open an assist session for a farmer of the officer's FPO; idempotent by `client_id` (D-005).

    Args:
        session: database session.
        caller: the field officer.
        body: client id, farmer, optional device start time and position.

    Returns:
        The new or already stored session.

    Raises:
        NotFoundError: the farmer is not in the officer's FPO.
        ConflictError: the client id is already used for another officer or farmer.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts an `assist_sessions` row and commits (nothing when the id already exists).
    """
    await _farmer_in_fpo(session, caller, body.farmer_id)
    # DECISION D-005: the phone's client_id is the assist session id, so a retried start is a no-op.
    #   ADV: an officer can start a session offline and sync it later without duplicates.
    #   COMPROMISE: an id that already belongs to another officer or farmer must be refused.
    row = await session.get(AssistSession, body.client_id)
    if row is None:
        gps = body.started_gps
        row = AssistSession(
            id=body.client_id,
            officer_user_id=caller.user_id,
            farmer_id=body.farmer_id,
            started_at=body.started_at.astimezone(UTC) if body.started_at else utcnow(),
            started_gps=WKTElement(f"POINT({gps.lon} {gps.lat})", srid=4326) if gps else None,
        )
        session.add(row)
        await session.commit()
    elif (row.officer_user_id, row.farmer_id) != (caller.user_id, body.farmer_id):
        raise ConflictError(details={"client_id": str(body.client_id)})
    return AssistSessionOut.model_validate(row, from_attributes=True)


async def start_assist_from_sync(
    session: AsyncSession, caller: CurrentUser, data: dict[str, Any]
) -> tuple[AssistSessionOut, bool]:
    """Open an assist session from the raw `data` of a sync push `assist_session` entry (D-032).

    Args:
        session: database session.
        caller: the field officer.
        data: `AssistStartIn` fields with `client_id` = the entry's client id (the session id).

    Returns:
        (the session, True if stored now / False if it already existed).

    Raises:
        ForbiddenError: the caller is not a field officer (the same rule as `POST /assist/start`).
        ValidationFailedError: the data does not match `AssistStartIn` (422).
        NotFoundError: the farmer is not in the officer's FPO.
        ConflictError: the id is already used for another officer or farmer.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        As `start_assist` (inserts and commits).
    """
    if caller.role != Role.FIELD_OFFICER:
        raise ForbiddenError(details={"reason": "assist sessions are started by a field officer"})
    try:
        body = AssistStartIn.model_validate(data)
    except ValidationError as e:
        details = [{"loc": err["loc"], "msg": err["msg"], "type": err["type"]} for err in e.errors()]
        raise ValidationFailedError(details=details) from e
    created = await session.get(AssistSession, body.client_id) is None
    return await start_assist(session, caller, body), created


async def end_assist(
    session: AsyncSession, caller: CurrentUser, assist_session_id: uuid.UUID
) -> AssistSessionOut:
    """Close the officer's assist session; ending an ended session returns it unchanged.

    Args:
        session: database session.
        caller: the field officer.
        assist_session_id: the session to close.

    Returns:
        The session with `ended_at` set.

    Raises:
        NotFoundError: no such session of this officer.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets `ended_at` and commits; later requests with this `X-Assist-Session` get 403.
    """
    row = await session.get(AssistSession, assist_session_id)
    if row is None or row.officer_user_id != caller.user_id:
        raise NotFoundError()
    if row.ended_at is None:
        row.ended_at = utcnow()
        await session.commit()
    return AssistSessionOut.model_validate(row, from_attributes=True)


# ---------------------------------------------------------------- consent


def _consent_out(row: ConsentRecord) -> ConsentOut:
    """Render a consent row.

    Args:
        row: the stored consent.

    Returns:
        Its API representation.
    """
    return ConsentOut.model_validate(row, from_attributes=True)


def _check_writer(caller: CurrentUser, farmer_id: uuid.UUID) -> None:
    """Allow consent writes by the farmer or by an officer assisting that farmer.

    Args:
        caller: the signed-in caller.
        farmer_id: the farmer the consent belongs to.

    Raises:
        ForbiddenError: an officer outside assist mode, or assisting a different farmer.
    """
    if caller.assist_session_id is not None:
        if caller.on_behalf_of_farmer_id != farmer_id:
            raise ForbiddenError("The assist session is for another farmer.")
    elif caller.role != Role.FARMER:
        raise ForbiddenError("Consent is recorded by the farmer, or by an officer in assist mode.")


async def record_consent(session: AsyncSession, caller: CurrentUser, body: ConsentIn) -> ConsentOut:
    """Store a farmer's consent; idempotent by `client_id` (D-005).

    Args:
        session: database session.
        caller: the farmer, or a field officer in assist mode for that farmer.
        body: the consent.

    Returns:
        The stored consent (the earlier one when the same body is resent).

    Raises:
        ForbiddenError: the caller may not record consent for this farmer.
        NotFoundError: the farmer is not in the caller's FPO (or is not the caller).
        ConsentConflictError: the client id is stored with a different farmer, type or version.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts a `consent_records` row and commits; the audit listener writes its `audit_log` row with
        the officer as actor and the farmer as `on_behalf_of_farmer_id` in assist mode.
    """
    _check_writer(caller, body.farmer_id)
    await _farmer_in_fpo(session, caller, body.farmer_id)
    row = await session.get(ConsentRecord, body.client_id)
    if row is None:
        row = ConsentRecord(
            id=body.client_id,
            farmer_id=body.farmer_id,
            consent_type=body.consent_type,
            consent_version=body.consent_version,
            recording_ref=body.recording_ref,
            witnessed_by_user_id=caller.user_id if caller.assist_session_id else None,
            given_at=body.given_at.astimezone(UTC),  # stored and returned in UTC (conventions.md)
            device_id=caller.device_id,
        )
        session.add(row)
        try:
            await session.commit()
        except IntegrityError:  # the same client id raced in from a retry; read the winner
            await session.rollback()
            row = await session.get(ConsentRecord, body.client_id)
            if row is None:
                raise
    stored = (row.farmer_id, row.consent_type, row.consent_version)
    if stored != (body.farmer_id, body.consent_type, body.consent_version):
        raise ConsentConflictError(details={"client_id": str(body.client_id)})
    return _consent_out(row)


async def list_consents(session: AsyncSession, caller: CurrentUser, farmer_id: uuid.UUID) -> list[ConsentOut]:
    """List a farmer's consents, revoked ones included, oldest first.

    Args:
        session: database session.
        caller: the farmer themself, or any role of the same FPO.
        farmer_id: the farmer.

    Returns:
        Every consent record of the farmer.

    Raises:
        NotFoundError: the farmer is not in the caller's FPO (or is not the calling farmer).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    await _farmer_in_fpo(session, caller, farmer_id)
    rows = await session.scalars(
        select(ConsentRecord)
        .where(ConsentRecord.farmer_id == farmer_id)
        .order_by(ConsentRecord.given_at, ConsentRecord.id)
    )
    return [_consent_out(r) for r in rows]


async def revoke_consent(session: AsyncSession, caller: CurrentUser, consent_id: uuid.UUID) -> ConsentOut:
    """Withdraw a consent: only `revoked_at` is written (the table is otherwise append-only, D-005).

    Args:
        session: database session.
        caller: the farmer, or a field officer in assist mode for that farmer.
        consent_id: the consent to withdraw.

    Returns:
        The consent with `revoked_at` set (unchanged if it was already revoked).

    Raises:
        NotFoundError: unknown consent or a farmer outside the caller's scope.
        ForbiddenError: the caller may not act for this farmer.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets `revoked_at` and commits (one audited update).
    """
    row = await session.get(ConsentRecord, consent_id)
    if row is None:
        raise NotFoundError()
    await _farmer_in_fpo(session, caller, row.farmer_id)
    _check_writer(caller, row.farmer_id)
    if row.revoked_at is None:
        row.revoked_at = utcnow()
        await session.commit()
    return _consent_out(row)
