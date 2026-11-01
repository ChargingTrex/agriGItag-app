"""identity HTTP routes: OTP sign-in, PIN, refresh, sign-out, device revoke, me, assist, consent (`/v1`).

Serves: FR1 (OTP sign-in), FR14 (roles), FR41 (consent), Arch §Security and privacy, UserFlows §Onboarding
a farmer steps 1–2, UserFlows §Log in once, CLAUDE.md §6 (assist mode), D-005, D-020, D-022, D-024;
B23 / SEC P1-1 (`POST /v1/devices/{device_id}/revoke`, `GET /v1/users/{user_id}/devices`, `session_expired`).
Callers: `agritrace.main` mounts `router` under `/v1` by discovery; the mobile app and portal through the
generated clients; tests/integration/test_identity.py.
"""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, Request, Response
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser, decode_token, get_current_user, require_role
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.errors import UnauthorizedError
from agritrace.core.schemas import Page
from agritrace.modules.identity import service
from agritrace.modules.identity.schemas import (
    AssistEndIn,
    AssistSessionOut,
    AssistStartIn,
    ConsentIn,
    ConsentOut,
    DeviceOut,
    DeviceRevokeIn,
    MeOut,
    OtpRequestIn,
    OtpVerifyIn,
    OtpVerifyOut,
    PinChangeIn,
    PinIn,
    RefreshIn,
    SessionOut,
)

router = APIRouter(tags=["identity"])

Session = Annotated[AsyncSession, Depends(get_session)]
Caller = Annotated[CurrentUser, Depends(get_current_user)]
OFFICE_ROLES = (Role.FIELD_OFFICER, Role.QC_OFFICER, Role.FPO_ADMIN, Role.VIEWER)

REFRESH_COOKIE = "agritrace_refresh"
REFRESH_COOKIE_PATH = "/v1/auth"
_pin_bearer = HTTPBearer(
    scheme_name="PinToken", auto_error=False, description="The `pin_token` from `POST /v1/auth/otp/verify`."
)


def _is_web(request: Request) -> bool:
    """Tell whether the caller is the browser portal.

    Args:
        request: the incoming request.

    Returns:
        True when the request carries `X-Client: web`.
    """
    return request.headers.get("x-client", "").lower() == "web"


def _deliver(web: bool, response: Response, session_out: SessionOut) -> SessionOut:
    """Hand the refresh token to the client the safe way for its platform.

    Args:
        web: deliver by cookie: the request carries `X-Client: web`, or its refresh token came from the
            cookie (a cookie token never moves into a body that page scripts can read).
        response: the outgoing response, which gets the cookie for web clients.
        session_out: the session issued by the service.

    Returns:
        The session body; for web delivery `refresh_token` is null because the cookie carries it.

    Side effects:
        For web delivery, sets the `agritrace_refresh` cookie.
    """
    # DECISION D-022: the portal shares the API's origin, so its refresh token is an httpOnly,
    #   Secure, SameSite=Strict cookie scoped to /v1/auth; mobile keeps the body token.
    #   ADV: page scripts never see the refresh token (no XSS theft); no CORS; Strict blocks CSRF.
    #   COMPROMISE: two transports to test; the cookie is a browser-session cookie (closing the browser
    #     means OTP + PIN again), which suits shared office PCs.
    if not web or session_out.refresh_token is None:
        return session_out
    response.set_cookie(
        REFRESH_COOKIE,
        session_out.refresh_token,
        httponly=True,
        secure=True,
        samesite="strict",
        path=REFRESH_COOKIE_PATH,
    )
    return session_out.model_copy(update={"refresh_token": None})


# DECISION D-020: every route here is under /v1 (prefix added by agritrace.main); changes stay additive.
#   ADV: last season's apps keep signing in.  COMPROMISE: deprecated fields linger for a season.
@router.post("/auth/otp/request", status_code=204, responses={429: {"description": "`rate_limited`."}})
async def otp_request(body: OtpRequestIn, session: Session) -> None:
    """Send a 6-digit sign-in code by SMS (valid 5 minutes; one request per phone per 60 s).

    The answer is the same for registered and unknown numbers.

    Args:
        body: the phone number.
        session: database session.

    Raises:
        RateLimitedError: a code was requested for this phone less than 60 s ago.

    Side effects:
        Stores a hashed challenge; enqueues the SMS (not with `OTP_DEV_CODE` set, dev only).
    """
    await service.request_otp(session, body.phone)


@router.post(
    "/auth/otp/verify",
    response_model=OtpVerifyOut,
    responses={
        409: {"description": "`otp_locked` after 5 wrong codes."},
        422: {"description": "`otp_invalid`, `otp_expired` or `validation_error`."},
    },
)
async def otp_verify(
    body: OtpVerifyIn, request: Request, response: Response, session: Session
) -> OtpVerifyOut:
    """Trade the SMS code for a session (farmers) or a `pin_token` (office roles, D-024).

    Args:
        body: phone, code and device details.
        request: the incoming request (`X-Client: web` selects the cookie transport).
        response: the outgoing response (refresh cookie for web).
        session: database session.

    Returns:
        `{kind: "session", ...}` or `{kind: "pin_required", pin_token, expires_in, pin_set}`.

    Raises:
        OtpInvalidError: wrong code, or a phone that cannot sign in.
        OtpExpiredError: the code is older than 5 minutes.
        OtpLockedError: 5 wrong codes.
    """
    result = await service.verify_otp(session, body)
    return _deliver(_is_web(request), response, result) if isinstance(result, SessionOut) else result


@router.post(
    "/auth/pin/verify",
    response_model=SessionOut,
    responses={
        401: {"description": "Missing, expired or wrong-type pin token."},
        409: {"description": "`pin_locked` for 5 minutes after 5 wrong PINs."},
        422: {"description": "`pin_invalid`."},
    },
)
async def pin_verify(
    body: PinIn,
    request: Request,
    response: Response,
    session: Session,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_pin_bearer)],
) -> SessionOut:
    """Trade the `pin_token` (as Bearer) and the 4-digit PIN for a full session.

    On an office user's first sign-in (`pin_set: false`) the PIN sent here becomes their PIN.

    Args:
        body: the PIN.
        request: the incoming request (`X-Client: web` selects the cookie transport).
        response: the outgoing response (refresh cookie for web).
        session: database session.
        credentials: `Authorization: Bearer <pin_token>`.

    Returns:
        The session.

    Raises:
        UnauthorizedError: no pin token, an access/expired/forged token in its place, or a pin token
            already used for a sign-in.
        PinInvalidError: wrong PIN.
        PinLockedError: 5 wrong PINs.
    """
    if credentials is None:
        raise UnauthorizedError()
    claims = decode_token(credentials.credentials, "pin")
    user_id, device_id = uuid.UUID(claims["sub"]), uuid.UUID(claims["dev"])
    result = await service.verify_pin(session, user_id, device_id, int(claims["iat"]), body.pin)
    return _deliver(_is_web(request), response, result)


@router.post(
    "/auth/pin",
    status_code=204,
    responses={
        409: {"description": "`pin_locked` after 5 wrong current PINs."},
        422: {"description": "`pin_invalid`: current PIN missing or wrong."},
    },
)
async def pin_set(
    body: PinChangeIn, session: Session, user: Annotated[CurrentUser, Depends(require_role(*OFFICE_ROLES))]
) -> None:
    """Set or change the caller's 4-digit PIN (office roles); a change needs the current PIN.

    Args:
        body: the new PIN and, when one is set, the current PIN.
        session: database session.
        user: the signed-in office user.

    Raises:
        UnauthorizedError: not signed in.
        ForbiddenError: farmers have no PIN.
        PinInvalidError: the current PIN is missing or wrong.
        PinLockedError: 5 wrong current PINs.

    Side effects:
        Stores the Argon2id hash and clears any PIN lock.
    """
    await service.set_pin(session, user, body.pin, body.current_pin)


@router.post(
    "/auth/refresh",
    response_model=SessionOut,
    responses={
        401: {
            "description": "`unauthorized` (signed out), `refresh_reused` (device revoked) or "
            "`session_expired` (sign-in older than `SESSION_MAX_DAYS`, device revoked)."
        }
    },
)
async def refresh(body: RefreshIn, request: Request, response: Response, session: Session) -> SessionOut:
    """Rotate the refresh token and get a new 15-minute access token.

    Mobile sends `refresh_token` in the body; the portal (`X-Client: web`) relies on the httpOnly cookie.
    A token read from the cookie is always answered through the cookie. Presenting the token rotated out
    last signs the device out (`refresh_reused`).

    Args:
        body: the refresh token (mobile) or nothing (web).
        request: the incoming request (cookie and `X-Client`).
        response: the outgoing response (new cookie for web).
        session: database session.

    Returns:
        A new session; the old refresh token is now invalid.

    Raises:
        UnauthorizedError: no or unknown token, signed-out device.
        RefreshReusedError: reuse of a rotated token.
        SessionExpiredError: the device's sign-in is older than `SESSION_MAX_DAYS` (device signed out).
    """
    from_cookie = body.refresh_token is None
    token = request.cookies.get(REFRESH_COOKIE) if from_cookie else body.refresh_token
    if not token:
        raise UnauthorizedError()
    return _deliver(_is_web(request) or from_cookie, response, await service.refresh(session, token))


@router.post("/auth/logout", status_code=204)
async def logout(user: Caller, response: Response, session: Session) -> None:
    """Sign this device out: its refresh token and access tokens stop working.

    Args:
        user: the signed-in caller.
        response: the outgoing response (the web refresh cookie is cleared).
        session: database session.

    Raises:
        UnauthorizedError: not signed in.

    Side effects:
        Revokes the device; deletes the refresh cookie.
    """
    await service.logout(session, user)
    response.delete_cookie(
        REFRESH_COOKIE, path=REFRESH_COOKIE_PATH, secure=True, httponly=True, samesite="strict"
    )


@router.post(
    "/devices/{device_id}/revoke",
    status_code=204,
    responses={
        403: {"description": "`forbidden`: another member's device and the caller is not an FPO admin."},
        404: {"description": "`not_found`: unknown device, or its user is outside the caller's FPO."},
    },
)
async def device_revoke(
    device_id: uuid.UUID, user: Caller, session: Session, body: DeviceRevokeIn | None = None
) -> None:
    """Sign a lost or stolen device out: the user's own device, or (FPO admin) any member's device.

    Afterwards its access tokens and its refresh token answer 401. Revoking a signed-out device again is
    a no-op that is still audited.

    Args:
        device_id: the device.
        user: the caller (the device's user, or an FPO admin of the device user's FPO).
        session: database session.
        body: optional reason, kept in the audit trail.

    Raises:
        UnauthorizedError: not signed in.
        ForbiddenError: another member's device and the caller is not an FPO admin.
        NotFoundError: unknown device, or outside the caller's FPO.

    Side effects:
        Revokes the device; writes the `device.revoke` audit row.
    """
    await service.revoke_device(session, user, device_id, body.reason if body else None)


@router.get(
    "/users/{user_id}/devices",
    response_model=list[DeviceOut],
    responses={
        403: {"description": "`forbidden`: another member and the caller is not an FPO admin."},
        404: {"description": "`not_found`: the user is outside the caller's FPO."},
    },
)
async def device_list(user_id: uuid.UUID, user: Caller, session: Session) -> list[DeviceOut]:
    """List a user's devices (signed out ones included), newest first, to pick the one to revoke.

    Args:
        user_id: the user.
        user: the caller (the user themself, or an FPO admin of the user's FPO).
        session: database session.

    Returns:
        The user's devices.

    Raises:
        UnauthorizedError: not signed in.
        ForbiddenError: another member and the caller is not an FPO admin.
        NotFoundError: the user is outside the caller's FPO.
    """
    # shortcut: one unpaged list; a user has a handful of phones (each reinstall adds one); page it if a
    #   user ever collects dozens.
    return await service.list_devices(session, user, user_id)


@router.get("/me", response_model=MeOut)
async def me(user: Caller, session: Session) -> MeOut:
    """Return the signed-in user, their FPO memberships and this session's device.

    Args:
        user: the signed-in caller.
        session: database session.

    Returns:
        Profile, memberships and device.

    Raises:
        UnauthorizedError: not signed in.
    """
    return await service.me(session, user)


@router.post("/assist/start", response_model=AssistSessionOut, status_code=201)
async def assist_start(
    body: AssistStartIn,
    session: Session,
    user: Annotated[CurrentUser, Depends(require_role(Role.FIELD_OFFICER))],
) -> AssistSessionOut:
    """Start entering data for a farmer; send the returned `id` as `X-Assist-Session` afterwards.

    Idempotent by `client_id`: a retry returns the stored session.

    Args:
        body: client id, farmer, optional start time and position.
        session: database session.
        user: the field officer.

    Returns:
        The assist session.

    Raises:
        ForbiddenError: not a field officer.
        NotFoundError: the farmer is not in the officer's FPO.
        ConflictError: the client id belongs to another officer's or farmer's session.
    """
    return await service.start_assist(session, user, body)


@router.post("/assist/end", response_model=AssistSessionOut)
async def assist_end(
    body: AssistEndIn,
    session: Session,
    user: Annotated[CurrentUser, Depends(require_role(Role.FIELD_OFFICER))],
) -> AssistSessionOut:
    """End an assist session (idempotent).

    Args:
        body: the session id.
        session: database session.
        user: the field officer.

    Returns:
        The ended session.

    Raises:
        ForbiddenError: not a field officer.
        NotFoundError: not this officer's session.
    """
    return await service.end_assist(session, user, body.assist_session_id)


@router.post("/consents", response_model=ConsentOut, status_code=201)
async def consent_create(body: ConsentIn, user: Caller, session: Session) -> ConsentOut:
    """Record a farmer's consent (the farmer, or an officer in assist mode); idempotent by `client_id`.

    Args:
        body: the consent.
        user: the caller.
        session: database session.

    Returns:
        The stored consent.

    Raises:
        ForbiddenError: an officer outside assist mode for this farmer.
        NotFoundError: the farmer is outside the caller's scope.
        ConsentConflictError: the client id holds a different consent.
    """
    return await service.record_consent(session, user, body)


@router.get("/farmers/{farmer_id}/consents", response_model=Page[ConsentOut])
async def consent_list(farmer_id: uuid.UUID, user: Caller, session: Session) -> Page[ConsentOut]:
    """List a farmer's consents (revoked included), oldest first.

    Args:
        farmer_id: the farmer.
        user: the farmer themself or any role in the same FPO.
        session: database session.

    Returns:
        One page holding every consent of the farmer.

    Raises:
        NotFoundError: the farmer is outside the caller's scope.
    """
    # shortcut: a farmer has a handful of consents (3 types x text versions), so one page holds all of
    #   them; add cursor paging (conventions.md) if versions ever multiply.
    items = await service.list_consents(session, user, farmer_id)
    return Page[ConsentOut](items=items, next_cursor=None, has_more=False)


@router.post("/consents/{consent_id}/revoke", response_model=ConsentOut)
async def consent_revoke(consent_id: uuid.UUID, user: Caller, session: Session) -> ConsentOut:
    """Withdraw a consent (sets `revoked_at` only; the record itself is kept).

    Args:
        consent_id: the consent.
        user: the farmer, or an officer in assist mode for that farmer.
        session: database session.

    Returns:
        The consent with `revoked_at` set.

    Raises:
        NotFoundError: unknown consent or outside the caller's scope.
        ForbiddenError: an officer outside assist mode for this farmer.
    """
    return await service.revoke_consent(session, user, consent_id)
