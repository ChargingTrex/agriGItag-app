"""identity tables: users, memberships, OTP challenges, devices, assist sessions, consents, audit log.

Serves: FR1 (OTP sign-in), FR14 (roles), FR24 (tenant scoping), FR25 (audit trail), FR41 (consent),
CLAUDE.md §6 (assist mode recorded), Dataflow Stage 0 (onboarding) and Stage 11 (audit), D-005, D-012.
Callers: identity service and router (B02), other modules' services through `models` (D-004),
`core.audit` (writes `audit_log` through a lightweight table handle), alembic/env.py, migration 0001.
"""

import uuid
from datetime import datetime
from typing import Any

from geoalchemy2 import Geography
from sqlalchemy import ForeignKey, Index, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, SpatialValue, TenantScoped
from agritrace.core.enums import ConsentType, Role, UserStatus


class User(Audited, IdTimestamps, Base):
    """A person who signs in with a phone OTP: farmer, field officer, QC officer, admin or viewer (FR1)."""

    __tablename__ = "users"

    phone: Mapped[str] = mapped_column(
        unique=True, comment="Mobile number in E.164 form, e.g. +919876543210."
    )
    name: Mapped[str] = mapped_column(comment="Display name in English script.")
    name_local: Mapped[str | None] = mapped_column(comment="Display name in the local script (Tamil), FR5.")
    lang: Mapped[str] = mapped_column(default="ta", comment="Preferred UI language code: `ta` or `en` (FR5).")
    is_super_admin: Mapped[bool] = mapped_column(
        default=False, comment="Platform compliance team; may edit GI regions and standards (FR31, FR47)."
    )
    status: Mapped[UserStatus] = mapped_column(
        default=UserStatus.ACTIVE, comment="active may sign in; suspended may not."
    )


class Membership(Audited, IdTimestamps, TenantScoped, Base):
    """A user's role in one FPO; a user may belong to several FPOs (FR14, FR24)."""

    __tablename__ = "memberships"
    __table_args__ = (UniqueConstraint("user_id", "fpo_id"),)

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="The member.")
    role: Mapped[Role] = mapped_column(comment="Role inside this FPO (FR14).")


class OtpChallenge(IdTimestamps, Base):
    """One OTP sent to a phone; only a hash of the code is kept (FR1)."""

    __tablename__ = "otp_challenges"

    phone: Mapped[str] = mapped_column(index=True, comment="Phone the code was sent to, E.164.")
    code_hash: Mapped[str] = mapped_column(
        comment="Hash of the one-time code; the code itself is never stored."
    )
    expires_at: Mapped[datetime] = mapped_column(comment="After this instant the code is refused.")
    attempts: Mapped[int] = mapped_column(default=0, comment="Wrong guesses so far; capped by B02.")
    consumed_at: Mapped[datetime | None] = mapped_column(comment="When the code was used; null while open.")


class Device(IdTimestamps, Base):
    """An app installation of a user; `id` is the device id the app generates (D-005, FR4)."""

    __tablename__ = "devices"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, comment="Signed-in user.")
    platform: Mapped[str] = mapped_column(comment="`android`, `ios` or `web`.")
    app_version: Mapped[str | None] = mapped_column(comment="App version last reported, e.g. 1.0.3.")
    refresh_token_hash: Mapped[str | None] = mapped_column(comment="Hash of the current refresh token.")
    last_seen_at: Mapped[datetime | None] = mapped_column(comment="Last authenticated request from it.")
    revoked_at: Mapped[datetime | None] = mapped_column(comment="When sign-out or an admin revoked it.")


class AssistSession(IdTimestamps, Base):
    """A field officer entering data on a farmer's behalf; `id` is client-generated (CLAUDE.md §6, D-005)."""

    __tablename__ = "assist_sessions"

    officer_user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id"), comment="Field officer or admin doing the entry."
    )
    farmer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("farmers.id"), index=True, comment="Farmer being assisted."
    )
    started_at: Mapped[datetime] = mapped_column(comment="Session start (device clock).")
    ended_at: Mapped[datetime | None] = mapped_column(comment="Session end; null while open.")
    started_gps: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326, spatial_index=False), comment="Where the session started (WGS84)."
    )


class ConsentRecord(Audited, IdTimestamps, Base):
    """A farmer's consent, append-only except `revoked_at`; `id` is client-generated (FR41, D-005)."""

    __tablename__ = "consent_records"

    farmer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("farmers.id"), index=True, comment="Farmer who consented."
    )
    consent_type: Mapped[ConsentType] = mapped_column(comment="What was consented to.")
    consent_version: Mapped[str] = mapped_column(comment="Version of the consent text shown, e.g. v1-ta.")
    recording_ref: Mapped[str | None] = mapped_column(
        comment="Object key of an audio/photo recording of the consent, if captured."
    )
    witnessed_by_user_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Officer who witnessed it (assisted capture)."
    )
    given_at: Mapped[datetime] = mapped_column(comment="When consent was given (device clock).")
    device_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("devices.id"), comment="Device that captured it."
    )
    revoked_at: Mapped[datetime | None] = mapped_column(
        comment="When it was withdrawn; the only column the append-only trigger lets change."
    )


class AuditLog(IdTimestamps, Base):
    """One change to an audited row, with who, for whom, from where (FR25, FR59, Stage 11).

    Written only by `core.audit`; a trigger forbids UPDATE and DELETE (D-005).
    """

    __tablename__ = "audit_log"
    __table_args__ = (Index("ix_audit_log_entity", "entity_type", "entity_id"),)

    # No foreign keys: the log must accept every row it is given and outlive what it describes.
    at: Mapped[datetime] = mapped_column(comment="When the change was flushed (API clock, UTC).")
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(
        comment="User who made the change; null for system jobs."
    )
    on_behalf_of_farmer_id: Mapped[uuid.UUID | None] = mapped_column(
        comment="Farmer the actor entered data for (assist mode)."
    )
    assist_session_id: Mapped[uuid.UUID | None] = mapped_column(comment="Assist session in force, if any.")
    device_id: Mapped[uuid.UUID | None] = mapped_column(comment="Device the request came from, if any.")
    gps: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326, spatial_index=False),
        comment="Device position sent with the request, if any.",
    )
    action: Mapped[str] = mapped_column(comment="`create`, `update` or `delete`.")
    entity_type: Mapped[str] = mapped_column(comment="Table name of the changed row.")
    entity_id: Mapped[uuid.UUID | None] = mapped_column(comment="Primary key of the changed row.")
    diff: Mapped[dict[str, Any]] = mapped_column(
        comment="create/delete: column values; update: {column: [old, new]} for changed columns."
    )
    request_id: Mapped[str | None] = mapped_column(comment="Request id for correlating with API logs.")
