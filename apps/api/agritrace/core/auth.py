"""Caller identity, tokens and guards used by every router: `CurrentUser`, `get_current_user`, `require_role`.

Issues and verifies the JWTs of the phone + OTP + PIN session model (D-024): 15-minute access tokens and
5-minute single-purpose `pin_token`s, both HS256 with `JWT_SECRET`. Resolves the caller of each request
from the Bearer access token and the optional `X-Assist-Session` header, and stamps the audit context.

Serves: FR1 (OTP sign-in), FR14 (role-based access), FR24 (tenant isolation), Arch §Security and privacy
("session tied to the device", "officers and admins add a 4-digit PIN"), CLAUDE.md §6 (every call scoped
to the caller's FPO and role; assist mode recorded), backend-design.md §3 (Bearer token,
`X-Assist-Session`), D-024.
Callers: module routers as FastAPI dependencies (`get_current_user`, `require_role`, `assert_same_fpo`);
identity service and router (B02) issue and decode tokens; tests/unit/test_auth.py,
tests/unit/test_identity_*.py, tests/integration/test_identity.py.
"""

import dataclasses
import uuid
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Annotated, Any, Literal

import jwt
from fastapi import Depends, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import DateTime, Uuid, column, select, table
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.audit import AuditContext, set_audit_context
from agritrace.core.config import get_settings
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.errors import AssistSessionInvalidError, ForbiddenError, NotFoundError, UnauthorizedError
from agritrace.core.ids import uuid7
from agritrace.core.time import utcnow

ALGORITHM = "HS256"
ACCESS_TTL = timedelta(minutes=15)
PIN_TOKEN_TTL = timedelta(minutes=5)
# Not a membership role: the `users.is_super_admin` flag, admitted only where a route lists it.
SUPER_ADMIN = "super_admin"
TokenType = Literal["access", "pin"]
# Tolerated clock difference between API containers when checking `iat`/`exp`.
LEEWAY = timedelta(seconds=30)

# identity/models.py owns these tables; core may not import a module (D-004), so these lightweight handles
# name the columns the hot path reads (tests/unit/test_identity_tokens.py keeps them in step).
DEVICES = table(
    "devices",
    column("id", Uuid()),
    column("user_id", Uuid()),
    column("revoked_at", DateTime(timezone=True)),
    column("signed_in_at", DateTime(timezone=True)),
)
ASSIST_SESSIONS = table(
    "assist_sessions",
    column("id", Uuid()),
    column("officer_user_id", Uuid()),
    column("farmer_id", Uuid()),
    column("ended_at", DateTime(timezone=True)),
)

_bearer = HTTPBearer(
    scheme_name="AccessToken",
    auto_error=False,
    description="Access token from `/v1/auth/otp/verify`, `/v1/auth/pin/verify` or `/v1/auth/refresh`.",
)


@dataclass(frozen=True, slots=True)
class CurrentUser:
    """The authenticated caller of one request, resolved from the access token and headers."""

    user_id: uuid.UUID
    fpo_id: uuid.UUID
    role: Role
    on_behalf_of_farmer_id: uuid.UUID | None = None
    assist_session_id: uuid.UUID | None = None
    device_id: uuid.UUID | None = None
    is_super_admin: bool = False


def _encode(claims: dict[str, Any], typ: TokenType, ttl: timedelta, now: datetime | None) -> str:
    """Sign a JWT with the standard claims added.

    Args:
        claims: token-specific claims (`sub`, `dev`, ...), all JSON-safe.
        typ: `access` or `pin`; a token is only accepted where this type is expected.
        ttl: lifetime from `now`.
        now: issue time; defaults to the current UTC time (tests pass a past time to test expiry).

    Returns:
        The compact HS256 JWT.

    Raises:
        pydantic.ValidationError: `JWT_SECRET` is not configured (from `get_settings`).
    """
    issued = now or utcnow()
    body = claims | {"typ": typ, "jti": uuid7().hex, "iat": issued, "exp": issued + ttl}
    return jwt.encode(body, get_settings().jwt_secret, algorithm=ALGORITHM)


def issue_access_token(
    *,
    user_id: uuid.UUID,
    fpo_id: uuid.UUID,
    role: Role,
    device_id: uuid.UUID,
    is_super_admin: bool,
    now: datetime | None = None,
) -> str:
    """Issue a 15-minute access token for one user, FPO membership and device (D-024).

    Args:
        user_id: the signed-in user (`sub`).
        fpo_id: the FPO of the membership in force (`fpo`).
        role: the role in that FPO (`role`).
        device_id: the app installation the session is tied to (`dev`).
        is_super_admin: the user's super-admin flag (`sa`).
        now: issue time; defaults to now.

    Returns:
        The signed access token.

    Raises:
        pydantic.ValidationError: `JWT_SECRET` is not configured.
    """
    claims = {
        "sub": str(user_id),
        "fpo": str(fpo_id),
        "role": role.value,
        "dev": str(device_id),
        "sa": is_super_admin,
    }
    return _encode(claims, "access", ACCESS_TTL, now)


def issue_pin_token(*, user_id: uuid.UUID, device_id: uuid.UUID, now: datetime | None = None) -> str:
    """Issue the 5-minute `pin_token` an office user trades for a session at `POST /v1/auth/pin/verify`.

    It carries the user and device only: no role, FPO or refresh token is released before the PIN passes
    (P00 contract, D-024).

    Args:
        user_id: the user who passed the OTP step (`sub`).
        device_id: the device the session will be tied to (`dev`).
        now: issue time; defaults to now.

    Returns:
        The signed pin token.

    Raises:
        pydantic.ValidationError: `JWT_SECRET` is not configured.
    """
    # DECISION D-024: the PIN step uses its own token type (`typ=pin`), not a restricted access token.
    #   ADV: `decode_token` refuses it everywhere except `/v1/auth/pin/verify`, and it carries no role,
    #     FPO or refresh token, so nothing usable is released before the PIN (P00 contract).
    #   COMPROMISE: one more token type to test; it is replayable for its 5 minutes until the PIN passes
    #     (then `devices.signed_in_at` moves past its `iat`).
    return _encode({"sub": str(user_id), "dev": str(device_id)}, "pin", PIN_TOKEN_TTL, now)


def decode_token(token: str, typ: TokenType) -> dict[str, Any]:
    """Verify a token's signature, expiry and type.

    Args:
        token: the compact JWT from the `Authorization: Bearer` header.
        typ: the type this route accepts; a `pin_token` is never a session token and vice versa.

    Returns:
        The verified claims.

    Raises:
        UnauthorizedError: bad signature, malformed, expired, missing claims or the wrong token type.
    """
    try:
        claims: dict[str, Any] = jwt.decode(
            token,
            get_settings().jwt_secret,
            algorithms=[ALGORITHM],
            leeway=LEEWAY,
            options={"require": ["exp", "iat", "jti", "sub", "typ", "dev"]},
        )
    except jwt.InvalidTokenError as e:
        raise UnauthorizedError(details={"reason": type(e).__name__}) from e
    if claims["typ"] != typ:
        raise UnauthorizedError(details={"reason": "wrong_token_type"})
    return claims


def user_from_claims(claims: dict[str, Any]) -> CurrentUser:
    """Build the caller from verified access-token claims.

    Args:
        claims: output of `decode_token(token, "access")`.

    Returns:
        The caller without assist fields.

    Raises:
        UnauthorizedError: a claim is missing or not a valid UUID / role.
    """
    try:
        return CurrentUser(
            user_id=uuid.UUID(claims["sub"]),
            fpo_id=uuid.UUID(claims["fpo"]),
            role=Role(claims["role"]),
            device_id=uuid.UUID(claims["dev"]),
            is_super_admin=bool(claims.get("sa", False)),
        )
    except (KeyError, ValueError) as e:
        raise UnauthorizedError(details={"reason": "bad_claims"}) from e


def issued_before_sign_in(issued_at: int, signed_in_at: datetime | None) -> bool:
    """Tell whether a token predates the device's latest sign-in (so a sign-out it outlived still holds).

    Args:
        issued_at: the token's `iat` (whole seconds since the epoch).
        signed_in_at: `devices.signed_in_at`, or None when never stamped.

    Returns:
        True when `iat < floor(signed_in_at)`; `iat` has whole-second precision, hence the floor.
    """
    return signed_in_at is not None and issued_at < int(signed_in_at.timestamp())


async def _device_active(
    session: AsyncSession, device_id: uuid.UUID, user_id: uuid.UUID, issued_at: int
) -> bool:
    """Check that the token's device is still signed in for this user, by this sign-in.

    Args:
        session: the request's database session.
        device_id: the token's `dev` claim.
        user_id: the token's `sub` claim.
        issued_at: the token's `iat` claim.

    Returns:
        True when the device row exists, belongs to the user, is not revoked, and the token was issued
        at or after the device's latest sign-in (a token revoked by logout stays dead after a new sign-in).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(DEVICES.c.signed_in_at).where(
        DEVICES.c.id == device_id, DEVICES.c.user_id == user_id, DEVICES.c.revoked_at.is_(None)
    )
    row = (await session.execute(query)).first()
    return row is not None and not issued_before_sign_in(issued_at, row.signed_in_at)


async def _assist_farmer(
    session: AsyncSession, assist_session_id: uuid.UUID, officer_user_id: uuid.UUID
) -> uuid.UUID | None:
    """Find the farmer of an open assist session started by this officer.

    Args:
        session: the request's database session.
        assist_session_id: value of the `X-Assist-Session` header.
        officer_user_id: the caller.

    Returns:
        The assisted farmer's id, or None when the session is unknown, someone else's or ended.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(ASSIST_SESSIONS.c.farmer_id).where(
        ASSIST_SESSIONS.c.id == assist_session_id,
        ASSIST_SESSIONS.c.officer_user_id == officer_user_id,
        ASSIST_SESSIONS.c.ended_at.is_(None),
    )
    farmer_id: uuid.UUID | None = (await session.execute(query)).scalar()
    return farmer_id


async def get_current_user(
    session: Annotated[AsyncSession, Depends(get_session)],
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    x_assist_session: Annotated[
        uuid.UUID | None,
        Header(description="Open assist session id (field officer entering data for a farmer)."),
    ] = None,
    x_request_id: Annotated[
        str | None, Header(max_length=64, description="Client request id, copied to audit rows.")
    ] = None,
) -> CurrentUser:
    """Resolve the caller from the Bearer access token and `X-Assist-Session`, and set the audit context.

    Args:
        session: the request's database session (shared with the route through FastAPI's dependency cache).
        credentials: the parsed `Authorization: Bearer` header, or None when absent.
        x_assist_session: the assist session the officer is working in, if any.
        x_request_id: the client's request id, if sent; otherwise a UUIDv7 is generated.

    Returns:
        The caller; in assist mode with `on_behalf_of_farmer_id` and `assist_session_id` set.

    Raises:
        UnauthorizedError: no token, an invalid or expired token, a `pin_token`, or a signed-out device.
        AssistSessionInvalidError: `X-Assist-Session` is not an open session of this caller.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        One indexed read of `devices` (plus one of `assist_sessions` in assist mode); sets the audit
        context (`core.audit.set_audit_context`) for the rest of the request. The context is overwritten by
        every authenticated request and never reset: routes without a caller write no audited rows.
    """
    if credentials is None:
        raise UnauthorizedError()
    claims = decode_token(credentials.credentials, "access")
    user = user_from_claims(claims)
    assert user.device_id is not None  # always set by user_from_claims
    # DECISION D-024: every request reads its device row (revoked? token older than the last sign-in?).
    #   ADV: logout and refresh-reuse revocation take effect on the very next request, not after 15 min.
    #   COMPROMISE: one primary-key read per request; TODO(B02 follow-up): cache revocations in Valkey if
    #     it shows up in p95 latency.
    if not await _device_active(session, user.device_id, user.user_id, int(claims["iat"])):
        raise UnauthorizedError("This device has been signed out.", details={"reason": "device_revoked"})
    if x_assist_session is not None:
        farmer_id = await _assist_farmer(session, x_assist_session, user.user_id)
        if farmer_id is None:
            raise AssistSessionInvalidError(details={"assist_session_id": str(x_assist_session)})
        user = dataclasses.replace(user, on_behalf_of_farmer_id=farmer_id, assist_session_id=x_assist_session)
    set_audit_context(
        AuditContext(
            actor_user_id=user.user_id,
            on_behalf_of_farmer_id=user.on_behalf_of_farmer_id,
            assist_session_id=user.assist_session_id,
            device_id=user.device_id,
            request_id=x_request_id or str(uuid7()),
        )
    )
    return user


def require_role(*roles: Role | Literal["super_admin"]) -> Callable[[CurrentUser], Awaitable[CurrentUser]]:
    """Build a dependency that admits only callers holding one of `roles` in their FPO.

    Usage: `user: Annotated[CurrentUser, Depends(require_role(Role.FPO_ADMIN))]`. List `"super_admin"`
    (`SUPER_ADMIN`) to admit users whose `is_super_admin` flag is set; the flag grants nothing elsewhere.

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
        allowed = user.role in roles or (user.is_super_admin and SUPER_ADMIN in roles)
        if roles and not allowed:
            raise ForbiddenError(details={"required_roles": [str(r) for r in roles]})
        return user

    return dependency


def assert_same_fpo(user: CurrentUser, fpo_id: uuid.UUID) -> None:
    """Refuse access to another FPO's data (FR24).

    Args:
        user: the caller.
        fpo_id: the FPO that owns the requested record.

    Raises:
        NotFoundError: the record belongs to another FPO (404, so other tenants' ids are not confirmed).
    """
    if fpo_id != user.fpo_id:
        raise NotFoundError()
