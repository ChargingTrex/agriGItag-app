"""events tables: events, their append-only versions, evidence photos and the sync bookkeeping.

Sync bookkeeping = device cursors, reference-bundle versions and sync metrics.

Serves: PRD §5 (Farming Event, Processing Event, Media), Dataflow Stages 1–9, FR3, FR4, FR6, FR25, FR26,
FR59, FR61, FR63, D-005 (append-only, client ids), D-011 (presigned photo upload), D-014 (one table with
typed JSON payloads), backend-design.md §3 (sync protocol).
Callers: events service, router and tasks (B06, B07), rules_flags (B08), lots_batches (B09), publishing
and reporting (B10) through `models` (D-004), alembic/env.py, migration 0001 (triggers).
"""

import uuid
from datetime import date, datetime
from typing import Any

from geoalchemy2 import Geography
from sqlalchemy import BigInteger, CheckConstraint, ForeignKey, Index, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, SpatialValue, TenantScoped
from agritrace.core.enums import ChangeKind, EventStatus, EventSubject, EventType, PhotoStatus


class Event(Audited, IdTimestamps, TenantScoped, Base):
    """A farm or processing event; its content lives in `event_versions` (Stages 1–9, FR3, FR63, D-014).

    PRD §5 Farming / Processing Event. `id` is client-generated and stable across versions (D-005).
    """

    __tablename__ = "events"
    __table_args__ = (CheckConstraint("(lot_id IS NULL) <> (batch_id IS NULL)", name="one_subject"),)

    subject_type: Mapped[EventSubject] = mapped_column(
        comment="Whether the event belongs to a lot or a batch."
    )
    lot_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("lots.id"), index=True, comment="Component lot (farm events); exactly one of lot/batch."
    )
    batch_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("batches.id"), index=True, comment="Batch (processing events); exactly one of lot/batch."
    )
    plot_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("plots.id"), comment="Plot where a farm event happened (FR69 GPS check)."
    )
    event_type: Mapped[EventType] = mapped_column(comment="Event type; selects the payload schema (D-014).")
    instance_no: Mapped[int] = mapped_column(
        default=1, comment="1-based instance of this type on the subject, e.g. harvest round 2 (FR3)."
    )
    status: Mapped[EventStatus] = mapped_column(
        default=EventStatus.SUBMITTED, comment="Lifecycle (FR25, FR59)."
    )
    # The pointer and the version's event_id reference each other, so this key is added after both tables.
    current_version_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("event_versions.id", use_alter=True), comment="Latest version (denormalised for reads)."
    )
    occurred_on: Mapped[date] = mapped_column(
        comment="Date of the current version, for date-order listing (FR63)."
    )


class EventVersion(IdTimestamps, Base):
    """One immutable version of an event: create, correction, undo or system entry (FR25, FR26, FR59).

    A trigger forbids UPDATE and DELETE; `id` is client-generated (D-005, D-014).
    """

    __tablename__ = "event_versions"
    __table_args__ = (
        UniqueConstraint("event_id", "version_no"),
        # D-014 compromise: payload fields are queried by rules and reports, so the JSONB gets a GIN index.
        Index("ix_event_versions_payload", "payload", postgresql_using="gin"),
    )

    event_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("events.id"), comment="Event this version belongs to."
    )
    version_no: Mapped[int] = mapped_column(comment="1 for the first version; each new one must be max+1.")
    payload: Mapped[dict[str, Any]] = mapped_column(
        comment="Typed per event_type (D-014); every quantity is {value, unit} (FR58)."
    )
    occurred_on: Mapped[date] = mapped_column(comment="Date the activity happened (or started).")
    occurred_end_on: Mapped[date | None] = mapped_column(comment="End date for spans such as drying.")
    device_time: Mapped[datetime] = mapped_column(comment="Phone clock at capture (three clocks).")
    gps_time: Mapped[datetime | None] = mapped_column(comment="GPS fix time at capture, if any.")
    server_received_at: Mapped[datetime] = mapped_column(comment="When the server received it.")
    gps: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326), comment="Device position at submission (FR26); checked by FR69."
    )
    gps_accuracy_m: Mapped[float | None] = mapped_column(comment="GPS accuracy in metres.")
    entered_by_user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id"), comment="Who entered it, taken from the token, never the body."
    )
    on_behalf_of_farmer_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("farmers.id"), comment="Farmer the entry was made for in assist mode (CLAUDE.md §6)."
    )
    assist_session_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("assist_sessions.id"), comment="Assist session in force, if any."
    )
    entered_remotely: Mapped[bool] = mapped_column(
        default=False, comment="True when entered away from the plot (e.g. by phone call)."
    )
    device_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("devices.id"), comment="Capturing device.")
    app_version: Mapped[str | None] = mapped_column(comment="App version that captured it.")
    change_kind: Mapped[ChangeKind] = mapped_column(comment="create, correct, undo or system (FR25, FR59).")
    reason_code: Mapped[str | None] = mapped_column(
        comment="Coded reason, required for correct and undo (FR25)."
    )
    reason_text: Mapped[str | None] = mapped_column(comment="Free-text reason or comment (FR59).")
    supersedes_version_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("event_versions.id"), comment="Version this one replaces, for corrections and undo."
    )
    is_system_generated: Mapped[bool] = mapped_column(
        default=False, comment="True when the platform, not a person, made the entry (FR59)."
    )


class EvidencePhoto(IdTimestamps, Base):
    """An evidence photo written once to the evidence bucket (FR3, FR61, D-011).

    `id` is client-generated (D-005). A trigger allows UPDATE only of the upload and verification columns
    and forbids DELETE.
    """

    __tablename__ = "evidence_photos"

    event_version_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("event_versions.id"), index=True, comment="Event version it documents, if any."
    )
    # evidence_photos <-> quality_readings reference each other, so this key is added after both tables.
    quality_reading_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("quality_readings.id", use_alter=True), index=True, comment="Quality reading it documents."
    )
    bucket: Mapped[str] = mapped_column(comment="Object-storage bucket, normally `evidence`.")
    object_key: Mapped[str] = mapped_column(
        unique=True,
        comment="evidence/{fpo_id}/{yyyy}/{event_id}/{photo_id}.jpg; never a temporary path (FR61).",
    )
    s3_version_id: Mapped[str | None] = mapped_column(comment="Object version id stored on confirm (FR61).")
    content_type: Mapped[str] = mapped_column(
        comment="MIME type bound into the presigned PUT, e.g. image/jpeg."
    )
    size_bytes: Mapped[int] = mapped_column(BigInteger, comment="Size in bytes declared by the phone.")
    sha256_client: Mapped[str] = mapped_column(
        comment="SHA-256 (hex) computed on the phone, bound to the PUT."
    )
    sha256_server: Mapped[str | None] = mapped_column(comment="SHA-256 (hex) recomputed by the verify task.")
    exif_taken_at: Mapped[datetime | None] = mapped_column(comment="EXIF capture time (FR61 metadata check).")
    exif_gps: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326, spatial_index=False), comment="EXIF GPS position, if present (FR61)."
    )
    status: Mapped[PhotoStatus] = mapped_column(
        default=PhotoStatus.PENDING_UPLOAD, comment="Upload and verification state."
    )
    variants: Mapped[dict[str, Any] | None] = mapped_column(
        comment="{thumb_url, medium_url, jpeg_url, width, height} written by the variants task."
    )
    upload_url_expires_at: Mapped[datetime | None] = mapped_column(comment="Expiry of the presigned PUT URL.")
    uploaded_at: Mapped[datetime | None] = mapped_column(comment="When confirm saw the object in storage.")
    verified_at: Mapped[datetime | None] = mapped_column(comment="When checksum and EXIF were verified.")


class SyncCursor(Base):
    """Per-device sync position for `GET /v1/sync/pull` (FR4, backend-design.md §3)."""

    __tablename__ = "sync_cursors"

    device_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("devices.id"), primary_key=True, comment="Device this cursor belongs to."
    )
    last_pull_cursor: Mapped[str | None] = mapped_column(comment="Opaque cursor returned by the last pull.")
    last_push_at: Mapped[datetime | None] = mapped_column(comment="When the device last pushed entries.")
    # Keyed by device, so this table takes the timestamps but not the id of `IdTimestamps`.
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), comment="When the row was inserted (database clock, UTC)."
    )
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(),
        onupdate=func.now(),
        comment="When the row was last changed (database clock, UTC).",
    )


class ReferenceVersion(IdTimestamps, Base):
    """Version of one offline reference-bundle part per FPO (FR4, backend-design.md §3, plan §13 C2).

    Bumped by database triggers on the tables that feed the part (migration 0001).
    """

    __tablename__ = "reference_versions"
    # One row per (part, FPO); the global row has fpo_id NULL, so NULLs must collide too (Postgres 15+).
    __table_args__ = (UniqueConstraint("part", "fpo_id", postgresql_nulls_not_distinct=True),)

    part: Mapped[str] = mapped_column(
        comment="Bundle part: plots, crops, inputs, standards, gi_region, villages."
    )
    fpo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("fpos.id"), comment="FPO the part version is for; null for global data."
    )
    version: Mapped[int] = mapped_column(
        BigInteger, comment="Value from sequence reference_version_seq, so one `since` compares all parts."
    )


class SyncMetric(IdTimestamps, Base):
    """Per-entry sync timing reported by phones, for the offline-sync benchmarks (FR4, plan §13)."""

    __tablename__ = "sync_metrics"

    device_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("devices.id"), index=True, comment="Reporting device."
    )
    entry_client_id: Mapped[uuid.UUID] = mapped_column(comment="Client id of the entry measured.")
    saved_at: Mapped[datetime] = mapped_column(comment="When the entry was saved on the phone.")
    acked_at: Mapped[datetime | None] = mapped_column(comment="When the server acknowledged it.")
    photo_upload_ms: Mapped[int | None] = mapped_column(comment="Total photo upload time in milliseconds.")
    failures: Mapped[int] = mapped_column(default=0, comment="Failed send attempts before success.")
    network_type: Mapped[str | None] = mapped_column(comment="Network at send time, e.g. 2g, 3g, lte, wifi.")
    app_version: Mapped[str | None] = mapped_column(comment="App version that reported it.")
