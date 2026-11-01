"""Integration tests of identity over HTTP on a real PostGIS database (B02 acceptance, executed literally).

Covers: OTP rate limit and lock, unknown phones, farmer session and office PIN step, PIN lock, role guard
(`GET /v1/flags` as a farmer), assist header, consent audit row, refresh rotation and reuse, logout, web
cookie transport, and the SMS enqueue rule around `OTP_DEV_CODE`; round 2 (review B02-r1): PIN hash redacted
in audit, current PIN for a change, super-admin PIN step, cookie-only refresh, stale tokens after a new
sign-in, guessed refresh tokens, `device_in_use`, the OTP daily cap and no device id in consent responses;
B23: `session_expired` after `SESSION_MAX_DAYS`, `POST /v1/devices/{id}/revoke` scoping and audit, and a NUL
in a REST body answering 422 (wave-7 P3).

Serves: B02 acceptance (docs/agents/acceptance/B02.md), FR1, FR14, FR24, FR25, FR41, CLAUDE.md §6,
D-005, D-022, D-024.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack` sets OTP_DEV_CODE=123456).
"""

import asyncio
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from datetime import timedelta
from pathlib import Path
from typing import Annotated, Any

import pytest
from fastapi import Depends
from httpx import ASGITransport, AsyncClient
from sqlalchemy import func, select

from agritrace.core.auth import CurrentUser, get_current_user, require_role
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import OrgKind, Role
from agritrace.core.time import utcnow
from agritrace.main import create_app
from agritrace.modules.identity import service
from agritrace.modules.identity.models import AuditLog, Device, Membership, OtpChallenge, User
from agritrace.modules.registry.models import Farmer, Fpo

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
DEV_CODE = "123456"


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (0001 + 0002) once per session.

    Args:
        stack: the running containers (fixture).

    Side effects:
        Runs `alembic upgrade head` (a no-op when test_schema.py already did).
    """
    alembic = Path(sys.executable).parent / "alembic"
    subprocess.run([str(alembic), "upgrade", "head"], cwd=API_DIR, check=True)  # noqa: S603


@pytest.fixture
async def api(migrated: None) -> AsyncIterator[AsyncClient]:
    """In-process client for the real app plus two test-only routes.

    `GET /v1/flags` stands in for the rules_flags route (B08) behind an office-role guard, and
    `GET /v1/_whoami` echoes the resolved caller.

    Args:
        migrated: the migrated database (fixture).

    Returns:
        An async iterator yielding the client.
    """
    app = create_app()

    async def flags(
        user: Annotated[
            CurrentUser, Depends(require_role(Role.FPO_ADMIN, Role.QC_OFFICER, Role.FIELD_OFFICER))
        ],
    ) -> dict[str, str]:
        """Stand-in for `GET /v1/flags`.

        Args:
            user: the caller (office roles only).

        Returns:
            An empty marker body.
        """
        return {"ok": str(user.user_id)}

    async def whoami(user: Annotated[CurrentUser, Depends(get_current_user)]) -> dict[str, Any]:
        """Echo the resolved caller.

        Args:
            user: the caller.

        Returns:
            The caller's ids as strings.
        """
        return {
            "user_id": user.user_id,
            "on_behalf_of_farmer_id": user.on_behalf_of_farmer_id,
            "assist_session_id": user.assist_session_id,
        }

    app.add_api_route("/v1/flags", flags, methods=["GET"])
    app.add_api_route("/v1/_whoami", whoami, methods=["GET"])
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


def _phone() -> str:
    """Draw a fresh Indian mobile number so the 60 s rate limit never spans tests.

    Returns:
        An E.164 number.
    """
    return f"+9197{secrets.randbelow(10**8):08d}"


async def _seed(role: Role, *, super_admin: bool = False) -> dict[str, Any]:
    """Create an FPO, a user with `role` there and (for any role) a farmer record.

    For a farmer user the farmer record is linked to the user; for an office user it is a separate farmer
    of the same FPO, to be assisted.

    Args:
        role: the user's membership role.
        super_admin: the user's super-admin flag.

    Returns:
        `phone`, `user`, `fpo`, `farmer` (ids) for the test.

    Side effects:
        Commits the rows.
    """
    phone = _phone()
    async with get_sessionmaker()() as s:
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        user = User(phone=phone, name="Test user", is_super_admin=super_admin)
        s.add_all([fpo, user])
        await s.flush()
        s.add(Membership(user_id=user.id, fpo_id=fpo.id, role=role))
        farmer_user = user.id if role == Role.FARMER else None
        farmer = Farmer(fpo_id=fpo.id, code=f"F-{secrets.token_hex(3)}", name="Muthu", user_id=farmer_user)
        s.add(farmer)
        await s.commit()
        return {"phone": phone, "user": user.id, "fpo": fpo.id, "farmer": farmer.id}


async def _otp(
    api: AsyncClient, phone: str, device: uuid.UUID | None = None, **headers: str
) -> dict[str, Any]:
    """Request a code and verify it with the dev code.

    Args:
        api: the client.
        phone: the number.
        device: device id; random when omitted.
        **headers: extra request headers (e.g. `X-Client`).

    Returns:
        The verify response body.
    """
    assert (await api.post("/v1/auth/otp/request", json={"phone": phone})).status_code == 204
    body = {"phone": phone, "code": DEV_CODE, "device_id": str(device or uuid.uuid4()), "platform": "android"}
    r = await api.post("/v1/auth/otp/verify", json=body, headers=headers)
    assert r.status_code == 200, r.text
    result: dict[str, Any] = r.json()
    return result


async def _officer_session(api: AsyncClient, seed: dict[str, Any]) -> dict[str, Any]:
    """Sign an office user in: OTP, then choose PIN 2468 at the PIN step.

    Args:
        api: the client.
        seed: output of `_seed`.

    Returns:
        The session body.
    """
    pin_step = await _otp(api, seed["phone"])
    assert pin_step["kind"] == "pin_required"
    auth = {"Authorization": f"Bearer {pin_step['pin_token']}"}
    r = await api.post("/v1/auth/pin/verify", json={"pin": "2468"}, headers=auth)
    assert r.status_code == 200, r.text
    result: dict[str, Any] = r.json()
    return result


def _bearer(session: dict[str, Any], **extra: str) -> dict[str, str]:
    """Build request headers for a session.

    Args:
        session: a session body.
        **extra: more headers.

    Returns:
        Headers with `Authorization: Bearer <access_token>`.
    """
    return {"Authorization": f"Bearer {session['access_token']}"} | extra


async def test_otp_request_twice_within_60_s_is_429(api: AsyncClient) -> None:
    """Acceptance: OTP request 2× in 60 s → 429 `rate_limited`.

    Args:
        api: the client.
    """
    phone = _phone()
    assert (await api.post("/v1/auth/otp/request", json={"phone": phone})).status_code == 204
    r = await api.post("/v1/auth/otp/request", json={"phone": phone})
    assert r.status_code == 429 and r.json()["error"]["code"] == "rate_limited"


async def test_five_wrong_codes_lock_the_challenge(api: AsyncClient) -> None:
    """Acceptance: 5 wrong codes → 409 `otp_locked` (and the right code is refused afterwards).

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    assert (await api.post("/v1/auth/otp/request", json={"phone": seed["phone"]})).status_code == 204
    body = {"phone": seed["phone"], "device_id": str(uuid.uuid4()), "platform": "android"}
    codes = []
    for _ in range(5):
        r = await api.post("/v1/auth/otp/verify", json=body | {"code": "000000"})
        codes.append((r.status_code, r.json()["error"]["code"]))
    assert codes == [(422, "otp_invalid")] * 4 + [(409, "otp_locked")]
    r = await api.post("/v1/auth/otp/verify", json=body | {"code": DEV_CODE})
    assert (r.status_code, r.json()["error"]["code"]) == (409, "otp_locked")


async def test_unknown_phone_is_otp_invalid_and_creates_no_user(api: AsyncClient) -> None:
    """An unregistered number gets 204 on request and `otp_invalid` on verify, even with the dev code.

    Args:
        api: the client.
    """
    phone = _phone()
    assert (await api.post("/v1/auth/otp/request", json={"phone": phone})).status_code == 204
    body = {"phone": phone, "code": DEV_CODE, "device_id": str(uuid.uuid4()), "platform": "android"}
    r = await api.post("/v1/auth/otp/verify", json=body)
    assert (r.status_code, r.json()["error"]["code"]) == (422, "otp_invalid")
    async with get_sessionmaker()() as s:
        assert await s.scalar(select(func.count()).select_from(User).where(User.phone == phone)) == 0


async def test_dev_code_sends_no_sms_and_real_codes_do(
    api: AsyncClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    """With `OTP_DEV_CODE` set no SMS task is enqueued; without it one `otp` SMS goes to the user.

    Args:
        api: the client.
        monkeypatch: pytest's patcher.
    """
    sent: list[tuple[uuid.UUID, str]] = []

    async def record(user: User, code: str) -> None:
        """Capture the enqueue instead of publishing to the broker.

        Args:
            user: recipient.
            code: the code.
        """
        sent.append((user.id, code))

    monkeypatch.setattr(service, "_send_otp_sms", record)
    seed = await _seed(Role.FARMER)
    assert (await api.post("/v1/auth/otp/request", json={"phone": seed["phone"]})).status_code == 204
    assert sent == []
    monkeypatch.setattr(get_settings(), "otp_dev_code", None)
    other = await _seed(Role.FARMER)
    assert (await api.post("/v1/auth/otp/request", json={"phone": other["phone"]})).status_code == 204
    [(user_id, code)] = sent
    assert user_id == other["user"] and len(code) == 6 and code.isdigit()


async def test_farmer_gets_a_session_and_me(api: AsyncClient) -> None:
    """A farmer's verify returns `kind: session` with roles and FPO; `GET /v1/me` shows the membership.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    assert session["kind"] == "session" and session["roles"] == ["farmer"] and session["expires_in"] == 900
    assert session["fpo_id"] == str(seed["fpo"]) and session["refresh_token"]
    me = (await api.get("/v1/me", headers=_bearer(session))).json()
    assert me["user"]["id"] == str(seed["user"])
    assert me["memberships"] == [{"fpo_id": str(seed["fpo"]), "role": "farmer"}]


async def test_office_role_gets_pin_step_then_pin_lock(api: AsyncClient) -> None:
    """Officer: pin_required (no refresh, role or FPO) → first PIN chosen → later 5 wrong PINs lock.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FIELD_OFFICER)
    session = await _officer_session(api, seed)
    assert session["roles"] == ["field_officer"]
    await api.post("/v1/auth/logout", headers=_bearer(session))
    # A second sign-in (new number avoids the 60 s limit) reuses the PIN chosen above.
    async with get_sessionmaker()() as s:
        user = await s.get(User, seed["user"])
        assert user is not None
        user.phone = _phone()
        await s.commit()
        phone = user.phone
    pin_step = await _otp(api, phone)
    assert set(pin_step) == {"kind", "pin_token", "expires_in", "pin_set"} and pin_step["pin_set"] is True
    auth = {"Authorization": f"Bearer {pin_step['pin_token']}"}
    results = []
    for _ in range(5):
        r = await api.post("/v1/auth/pin/verify", json={"pin": "0000"}, headers=auth)
        results.append((r.status_code, r.json()["error"]["code"]))
    assert results == [(422, "pin_invalid")] * 4 + [(409, "pin_locked")]
    r = await api.post("/v1/auth/pin/verify", json={"pin": "2468"}, headers=auth)
    assert (r.status_code, r.json()["error"]["code"]) == (409, "pin_locked")


async def test_farmer_on_flags_is_403(api: AsyncClient) -> None:
    """Acceptance: farmer on `GET /flags` → 403 `forbidden` (test-only stand-in route, same guard).

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    r = await api.get("/v1/flags", headers=_bearer(session))
    assert (r.status_code, r.json()["error"]["code"]) == (403, "forbidden")


async def test_assist_header_sets_on_behalf_of_and_consent_audit_row(api: AsyncClient) -> None:
    """Acceptance: assist header sets `on_behalf_of_farmer_id`; consent writes audit row with actor=officer.

    Also: the consent is idempotent by client id, a closed assist session is refused, and revoke writes
    `revoked_at` only.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FIELD_OFFICER)
    session = await _officer_session(api, seed)
    assist_id = uuid.uuid4()
    r = await api.post(
        "/v1/assist/start",
        json={"client_id": str(assist_id), "farmer_id": str(seed["farmer"])},
        headers=_bearer(session),
    )
    assert r.status_code == 201, r.text
    assisted = _bearer(session, **{"X-Assist-Session": str(assist_id)})
    who = (await api.get("/v1/_whoami", headers=assisted)).json()
    assert who["on_behalf_of_farmer_id"] == str(seed["farmer"]) and who["assist_session_id"] == str(assist_id)

    consent_id = uuid.uuid4()
    body = {
        "client_id": str(consent_id),
        "farmer_id": str(seed["farmer"]),
        "consent_type": "data_collection",
        "consent_version": "v1-ta",
        "recording_ref": "consent/v1-ta.mp3",
        "given_at": "2026-03-04T08:12:10+05:30",
    }
    first = await api.post("/v1/consents", json=body, headers=assisted)
    assert first.status_code == 201, first.text
    assert first.json()["witnessed_by_user_id"] == str(seed["user"])
    again = await api.post("/v1/consents", json=body, headers=assisted)
    assert again.json() == first.json()
    async with get_sessionmaker()() as s:
        rows = (
            await s.scalars(
                select(AuditLog).where(
                    AuditLog.entity_type == "consent_records", AuditLog.entity_id == consent_id
                )
            )
        ).all()
    assert len(rows) == 1
    assert (rows[0].actor_user_id, rows[0].on_behalf_of_farmer_id) == (seed["user"], seed["farmer"])
    assert rows[0].assist_session_id == assist_id and rows[0].action == "create"

    officer_alone = await api.post(
        "/v1/consents", json=body | {"client_id": str(uuid.uuid4())}, headers=_bearer(session)
    )
    assert officer_alone.status_code == 403
    revoked = await api.post(f"/v1/consents/{consent_id}/revoke", headers=assisted)
    assert revoked.status_code == 200 and revoked.json()["revoked_at"] is not None
    listed = (await api.get(f"/v1/farmers/{seed['farmer']}/consents", headers=_bearer(session))).json()
    assert [c["id"] for c in listed["items"]] == [str(consent_id)]

    await api.post("/v1/assist/end", json={"assist_session_id": str(assist_id)}, headers=_bearer(session))
    r = await api.get("/v1/_whoami", headers=assisted)
    assert (r.status_code, r.json()["error"]["code"]) == (403, "assist_session_invalid")


async def test_logout_revokes_refresh(api: AsyncClient) -> None:
    """Acceptance: logout revokes refresh → 401 (and the access token stops working too).

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    assert (await api.post("/v1/auth/logout", headers=_bearer(session))).status_code == 204
    r = await api.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "unauthorized")
    assert (await api.get("/v1/me", headers=_bearer(session))).status_code == 401


async def test_refresh_rotates_and_reuse_revokes_the_device(api: AsyncClient) -> None:
    """A refresh rotates the token; replaying the old one is `refresh_reused` and kills the new one too.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    first = await _otp(api, seed["phone"])
    second = (await api.post("/v1/auth/refresh", json={"refresh_token": first["refresh_token"]})).json()
    assert second["kind"] == "session" and second["refresh_token"] != first["refresh_token"]
    r = await api.post("/v1/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "refresh_reused")
    r = await api.post("/v1/auth/refresh", json={"refresh_token": second["refresh_token"]})
    assert r.status_code == 401


async def test_web_client_gets_the_refresh_token_as_an_httponly_cookie(api: AsyncClient) -> None:
    """`X-Client: web`: body refresh token is null, the cookie is httpOnly/Secure/Strict and refresh reads it.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    assert (await api.post("/v1/auth/otp/request", json={"phone": seed["phone"]})).status_code == 204
    body = {"phone": seed["phone"], "code": DEV_CODE, "device_id": str(uuid.uuid4()), "platform": "web"}
    r = await api.post("/v1/auth/otp/verify", json=body, headers={"X-Client": "web"})
    assert r.json()["refresh_token"] is None
    cookie = r.headers["set-cookie"]
    flags = cookie.lower()
    assert (
        "httponly" in flags and "secure" in flags and "samesite=strict" in flags and "path=/v1/auth" in flags
    )
    token = cookie.split(";")[0].split("=", 1)[1]
    r = await api.post(
        "/v1/auth/refresh", json={}, headers={"X-Client": "web", "Cookie": f"agritrace_refresh={token}"}
    )
    assert r.status_code == 200 and r.json()["refresh_token"] is None


# ---------------------------------------------------------------- review B02-r1 fixes (round 2)


async def _new_phone(user_id: uuid.UUID) -> str:
    """Give a user a fresh number so a second sign-in in the same test is not rate-limited.

    Args:
        user_id: the user.

    Returns:
        The new E.164 number.

    Side effects:
        Commits the change.
    """
    async with get_sessionmaker()() as s:
        user = await s.get(User, user_id)
        assert user is not None
        user.phone = _phone()
        await s.commit()
        return user.phone


async def test_pin_hash_never_reaches_the_audit_log(api: AsyncClient) -> None:
    """R1: after choosing and changing a PIN, no `audit_log` diff holds an Argon2 hash.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FPO_ADMIN)
    session = await _officer_session(api, seed)
    r = await api.post("/v1/auth/pin", json={"pin": "1357", "current_pin": "2468"}, headers=_bearer(session))
    assert r.status_code == 204, r.text
    async with get_sessionmaker()() as s:
        query = select(AuditLog.diff).where(
            AuditLog.entity_type == "users", AuditLog.entity_id == seed["user"]
        )
        diffs = (await s.scalars(query)).all()
    assert any(d.get("pin_hash") == "[redacted]" for d in diffs)
    assert all("$argon2" not in str(d) for d in diffs)


async def test_pin_change_requires_the_current_pin(api: AsyncClient) -> None:
    """R6: `POST /v1/auth/pin` without or with a wrong current PIN is `pin_invalid`.

    Args:
        api: the client.
    """
    seed = await _seed(Role.QC_OFFICER)
    session = await _officer_session(api, seed)
    for body in ({"pin": "1357"}, {"pin": "1357", "current_pin": "0000"}):
        r = await api.post("/v1/auth/pin", json=body, headers=_bearer(session))
        assert (r.status_code, r.json()["error"]["code"]) == (422, "pin_invalid")


async def test_super_admin_with_farmer_membership_takes_the_pin_step(api: AsyncClient) -> None:
    """R7: a super-admin never gets a session from the OTP alone.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER, super_admin=True)
    assert (await _otp(api, seed["phone"]))["kind"] == "pin_required"


async def test_cookie_refresh_without_x_client_stays_in_the_cookie(api: AsyncClient) -> None:
    """R2: a cookie-sourced refresh answers through the cookie even when `X-Client` is missing.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    cookie = {"Cookie": f"agritrace_refresh={session['refresh_token']}"}
    r = await api.post("/v1/auth/refresh", json={}, headers=cookie)
    assert r.status_code == 200 and r.json()["refresh_token"] is None
    assert "agritrace_refresh=" in r.headers["set-cookie"]


async def test_old_access_token_stays_dead_after_signing_in_again(api: AsyncClient) -> None:
    """R3: logout, then sign in again on the same device within 15 minutes: the old access token is 401.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    device = uuid.uuid4()
    first = await _otp(api, seed["phone"], device)
    assert (await api.post("/v1/auth/logout", headers=_bearer(first))).status_code == 204
    await asyncio.sleep(1.1)  # `iat` has whole-second precision
    second = await _otp(api, await _new_phone(seed["user"]), device)
    assert (await api.get("/v1/me", headers=_bearer(second))).status_code == 200
    assert (await api.get("/v1/me", headers=_bearer(first))).status_code == 401


async def test_guessed_refresh_token_does_not_sign_the_device_out(api: AsyncClient) -> None:
    """R4a: `<device id>.<anything>` is a plain 401 and the real session keeps working.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    device = uuid.uuid4()
    session = await _otp(api, seed["phone"], device)
    r = await api.post("/v1/auth/refresh", json={"refresh_token": f"{device}.guessed"})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "unauthorized")
    r = await api.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]})
    assert r.status_code == 200


async def test_active_device_of_another_user_is_device_in_use(api: AsyncClient) -> None:
    """R4b: signing in on a device id that is signed in for someone else is 409 `device_in_use`.

    Args:
        api: the client.
    """
    owner, intruder = await _seed(Role.FARMER), await _seed(Role.FARMER)
    device = uuid.uuid4()
    session = await _otp(api, owner["phone"], device)
    assert (await api.post("/v1/auth/otp/request", json={"phone": intruder["phone"]})).status_code == 204
    body = {"phone": intruder["phone"], "code": DEV_CODE, "device_id": str(device), "platform": "android"}
    r = await api.post("/v1/auth/otp/verify", json=body)
    assert (r.status_code, r.json()["error"]["code"]) == (409, "device_in_use")
    assert (await api.get("/v1/me", headers=_bearer(session))).status_code == 200


async def test_otp_daily_cap(api: AsyncClient) -> None:
    """R5: after `OTP_DAILY_CAP` codes in 24 hours the next request is 429 with `retry_after_s`.

    Args:
        api: the client.
    """
    phone = _phone()
    cap = get_settings().otp_daily_cap
    async with get_sessionmaker()() as s:
        for hours in range(cap):
            created = utcnow() - timedelta(hours=hours + 1)
            s.add(OtpChallenge(phone=phone, code_hash="x", expires_at=created, created_at=created))
        await s.commit()
    r = await api.post("/v1/auth/otp/request", json={"phone": phone})
    assert (r.status_code, r.json()["error"]["code"]) == (429, "rate_limited")
    assert r.json()["error"]["details"]["retry_after_s"] > 60


async def test_consent_response_carries_no_device_id(api: AsyncClient) -> None:
    """R4: consent responses (visible to farmers and viewers) never expose a device id.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    body = {
        "client_id": str(uuid.uuid4()),
        "farmer_id": str(seed["farmer"]),
        "consent_type": "public_name",
        "consent_version": "v1-ta",
        "given_at": "2026-03-04T08:12:10+05:30",
    }
    r = await api.post("/v1/consents", json=body, headers=_bearer(session))
    assert r.status_code == 201 and "device_id" not in r.json()


# ---------------------------------------------------------------- B23 (SEC P1-1) and wave-7 P3 (B21)


async def _age_sign_in(refresh_token: str, days: int) -> uuid.UUID:
    """Move a device's last sign-in back in time.

    Args:
        refresh_token: a refresh token of the device (its prefix names the device).
        days: how many days ago the sign-in happened.

    Returns:
        The device id.

    Side effects:
        Commits the new `signed_in_at`.
    """
    device_id = service.refresh_device_id(refresh_token)
    assert device_id is not None
    async with get_sessionmaker()() as s:
        device = await s.get(Device, device_id)
        assert device is not None
        device.signed_in_at = utcnow() - timedelta(days=days)
        await s.commit()
    return device_id


async def test_refresh_after_session_max_days_is_session_expired(api: AsyncClient) -> None:
    """B23: a sign-in 31 days old refreshes to 401 `session_expired` and revokes the device; 29 days is fine.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    old = await _otp(api, seed["phone"])
    device_id = await _age_sign_in(old["refresh_token"], 31)
    r = await api.post("/v1/auth/refresh", json={"refresh_token": old["refresh_token"]})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "session_expired")
    async with get_sessionmaker()() as s:
        device = await s.get(Device, device_id)
    assert device is not None and device.revoked_at is not None and device.refresh_token_hash is None

    recent = await _otp(api, await _new_phone(seed["user"]))
    await _age_sign_in(recent["refresh_token"], 29)
    r = await api.post("/v1/auth/refresh", json={"refresh_token": recent["refresh_token"]})
    assert r.status_code == 200 and r.json()["kind"] == "session"


async def test_device_revoke_is_scoped_and_audited(api: AsyncClient) -> None:
    """B23: an FPO admin revokes a member's device (refresh 401, audit row); other FPO 404; farmer 403.

    Args:
        api: the client.
    """
    admin = await _seed(Role.FPO_ADMIN)
    admin_session = await _officer_session(api, admin)
    member_phone = _phone()
    async with get_sessionmaker()() as s:
        member = User(phone=member_phone, name="Member")
        s.add(member)
        await s.flush()
        s.add(Membership(user_id=member.id, fpo_id=admin["fpo"], role=Role.FARMER))
        await s.commit()
    member_session = await _otp(api, member_phone)
    member_device = service.refresh_device_id(member_session["refresh_token"])
    outsider = await _seed(Role.FARMER)
    outsider_session = await _otp(api, outsider["phone"])
    outsider_device = service.refresh_device_id(outsider_session["refresh_token"])
    admin_device = service.refresh_device_id(admin_session["refresh_token"])

    r = await api.post(f"/v1/devices/{admin_device}/revoke", headers=_bearer(member_session))
    assert (r.status_code, r.json()["error"]["code"]) == (403, "forbidden")
    r = await api.post(f"/v1/devices/{outsider_device}/revoke", headers=_bearer(admin_session))
    assert (r.status_code, r.json()["error"]["code"]) == (404, "not_found")

    revoke = f"/v1/devices/{member_device}/revoke"
    r = await api.post(revoke, json={"reason": "phone lost"}, headers=_bearer(admin_session))
    assert r.status_code == 204, r.text
    r = await api.post("/v1/auth/refresh", json={"refresh_token": member_session["refresh_token"]})
    assert (r.status_code, r.json()["error"]["code"]) == (401, "unauthorized")
    async with get_sessionmaker()() as s:
        query = select(AuditLog).where(AuditLog.entity_type == "devices", AuditLog.entity_id == member_device)
        row = (await s.scalars(query)).one()
    assert (row.action, row.actor_user_id) == ("device.revoke", admin["user"])
    assert row.diff["reason"] == "phone lost"

    # The device's own user may revoke it too, without a body (e.g. from another phone).
    own = await api.post(f"/v1/devices/{outsider_device}/revoke", headers=_bearer(outsider_session))
    assert own.status_code == 204
    r = await api.post("/v1/auth/refresh", json={"refresh_token": outsider_session["refresh_token"]})
    assert r.status_code == 401


async def test_nul_in_a_rest_body_is_validation_error_not_500(api: AsyncClient) -> None:
    """Wave-7 P3 (B21): a NUL Postgres refuses (SQLSTATE 22021) in a plain REST body is 422, not 500.

    Args:
        api: the client.
    """
    seed = await _seed(Role.FARMER)
    session = await _otp(api, seed["phone"])
    body = {
        "client_id": str(uuid.uuid4()),
        "farmer_id": str(seed["farmer"]),
        "consent_type": "public_name",
        "consent_version": "v1\x00ta",
        "given_at": "2026-03-04T08:12:10+05:30",
    }
    r = await api.post("/v1/consents", json=body, headers=_bearer(session))
    assert (r.status_code, r.json()["error"]["code"]) == (422, "validation_error")
    assert r.json()["error"]["details"][0]["type"] == "db_data_error"
