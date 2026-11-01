"""Request and response bodies of the identity endpoints (sign-in, tokens, me, assist sessions, consent).

Serves: FR1 (OTP sign-in), FR14 (roles), FR41 (consent), Arch §Security and privacy (PIN for office
roles, consent with recording and witness), UserFlows §Onboarding a farmer steps 1–2, UserFlows §Log in
once, CLAUDE.md §6 (assist mode recorded), D-005 (client ids), D-024 (session model).
Callers: identity router and service only (D-004: other modules never import a module's schemas);
the OpenAPI document (`make openapi`) and the generated Dart/TS clients.
"""

import uuid
from datetime import datetime
from typing import Annotated, Literal

from pydantic import AwareDatetime, BaseModel, Field

from agritrace.core.enums import ConsentType, Role
from agritrace.core.schemas import ClientRef, GeoPoint

E164 = r"^\+[1-9][0-9]{7,14}$"


class OtpRequestIn(BaseModel):
    """Ask for a one-time code by SMS."""

    phone: str = Field(pattern=E164, description="Mobile number in E.164 form, e.g. `+919876543210`.")


class OtpVerifyIn(BaseModel):
    """Trade the SMS code for a session (farmers) or a `pin_token` (office roles)."""

    phone: str = Field(pattern=E164, description="The number the code was sent to, E.164.")
    code: str = Field(pattern=r"^[0-9]{6}$", description="The 6-digit code from the SMS.")
    device_id: uuid.UUID = Field(
        description="UUID the app generated once per installation; the session is tied to it (D-005)."
    )
    platform: Literal["android", "ios", "web"] = Field(description="Client platform of this device.")
    app_version: str | None = Field(None, max_length=32, description="App version, e.g. `1.0.3`.")


class SessionOut(BaseModel):
    """A signed-in session: short-lived access token plus the device's refresh token."""

    kind: Literal["session"] = Field(description="Discriminator: a full session.")
    access_token: str = Field(description="JWT for `Authorization: Bearer`; expires after `expires_in` s.")
    refresh_token: str | None = Field(
        description="Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients "
        "(`X-Client: web`), which receive it as an httpOnly cookie instead (D-022)."
    )
    expires_in: int = Field(description="Access token lifetime in seconds (900).")
    roles: list[str] = Field(
        description="Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, "
        "`fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag."
    )
    fpo_id: uuid.UUID = Field(description="FPO the session is scoped to (the user's first membership).")


class PinRequiredOut(BaseModel):
    """The OTP passed for an office role; the PIN step must follow before any session is released."""

    kind: Literal["pin_required"] = Field(description="Discriminator: PIN step next.")
    pin_token: str = Field(
        description="Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO."
    )
    expires_in: int = Field(description="Pin token lifetime in seconds (300).")
    pin_set: bool = Field(
        description="False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN."
    )


OtpVerifyOut = Annotated[
    SessionOut | PinRequiredOut,
    Field(discriminator="kind", description="`session` for farmers, `pin_required` for office roles."),
]


class PinIn(BaseModel):
    """A 4-digit office PIN."""

    pin: str = Field(pattern=r"^[0-9]{4}$", description="Exactly 4 digits.")


class PinChangeIn(PinIn):
    """Set the office PIN (first time) or change it (the current PIN is then required)."""

    current_pin: str | None = Field(
        None, pattern=r"^[0-9]{4}$", description="The PIN in force; required when a PIN is already set."
    )


class RefreshIn(BaseModel):
    """Rotate the refresh token. Web clients omit the body field and send the httpOnly cookie."""

    refresh_token: str | None = Field(
        None, max_length=200, description="The current refresh token; omit when the cookie carries it (web)."
    )


class DeviceRevokeIn(BaseModel):
    """Sign a lost or stolen device out (B23); the body may be omitted."""

    reason: str | None = Field(
        None, max_length=500, description="Why the device is signed out (e.g. `phone lost`); audited."
    )


class UserOut(BaseModel):
    """The signed-in user's own profile."""

    id: uuid.UUID = Field(description="User id.")
    phone: str = Field(description="The user's own mobile number, E.164.")
    name: str = Field(description="Display name in English script.")
    name_local: str | None = Field(description="Display name in the local script (Tamil).")
    lang: str = Field(description="Preferred UI language: `ta` or `en`.")
    is_super_admin: bool = Field(description="Platform compliance team flag.")


class MembershipOut(BaseModel):
    """One role in one FPO."""

    fpo_id: uuid.UUID = Field(description="The FPO.")
    role: Role = Field(description="Role inside that FPO.")


class DeviceOut(BaseModel):
    """The device this session is tied to."""

    id: uuid.UUID = Field(description="Device id generated by the app.")
    platform: str = Field(description="`android`, `ios` or `web`.")
    app_version: str | None = Field(description="App version last reported.")
    last_seen_at: datetime | None = Field(description="Last sign-in or token refresh from it.")
    signed_in_at: datetime | None = Field(
        None, description="Last OTP/PIN sign-in; the session ends `SESSION_MAX_DAYS` after it."
    )
    revoked_at: datetime | None = Field(None, description="When it was signed out; null while signed in.")


class MeOut(BaseModel):
    """Who is signed in, where, and on which device."""

    user: UserOut = Field(description="The user.")
    memberships: list[MembershipOut] = Field(description="Every FPO role of the user, oldest first.")
    device: DeviceOut | None = Field(description="The device of this session; null if it was deleted.")


class AssistStartIn(ClientRef):
    """Start entering data on a farmer's behalf; `client_id` becomes the assist session id (D-005)."""

    farmer_id: uuid.UUID = Field(description="Farmer being assisted; must be in the officer's FPO.")
    started_at: AwareDatetime | None = Field(
        None, description="Device time the session started (offline start); defaults to server time."
    )
    started_gps: GeoPoint | None = Field(None, description="Where the session started, if a fix was taken.")


class AssistEndIn(BaseModel):
    """Close an assist session."""

    assist_session_id: uuid.UUID = Field(description="The session to end (its client id).")


class AssistSessionOut(BaseModel):
    """An assist session; send its `id` as `X-Assist-Session` on every request made for the farmer."""

    id: uuid.UUID = Field(description="Assist session id (the client id it was started with).")
    officer_user_id: uuid.UUID = Field(description="Field officer doing the entries.")
    farmer_id: uuid.UUID = Field(description="Farmer being assisted.")
    started_at: datetime = Field(description="When the session started.")
    ended_at: datetime | None = Field(description="When it ended; null while open.")


class ConsentIn(ClientRef):
    """Record a farmer's consent; resending the same `client_id` returns the stored record (D-005)."""

    farmer_id: uuid.UUID = Field(description="Farmer who consents (the caller, or the assisted farmer).")
    consent_type: ConsentType = Field(description="What is consented to.")
    consent_version: str = Field(
        min_length=1, max_length=32, description="Version of the consent text played, e.g. `v1-ta`."
    )
    recording_ref: str | None = Field(
        None, max_length=512, description="Object key of the consent recording played or captured, if any."
    )
    given_at: AwareDatetime = Field(description="When the farmer agreed (device clock), ISO 8601.")


class ConsentOut(BaseModel):
    """A stored consent record."""

    id: uuid.UUID = Field(description="Consent id (the client id it was recorded with).")
    farmer_id: uuid.UUID = Field(description="Farmer who consented.")
    consent_type: ConsentType = Field(description="What was consented to.")
    consent_version: str = Field(description="Version of the consent text.")
    recording_ref: str | None = Field(description="Object key of the recording, if any.")
    witnessed_by_user_id: uuid.UUID | None = Field(description="Officer who witnessed it (assist mode).")
    given_at: datetime = Field(description="When consent was given.")
    revoked_at: datetime | None = Field(description="When it was withdrawn; null while in force.")
