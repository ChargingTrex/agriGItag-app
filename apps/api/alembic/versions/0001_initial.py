"""Initial schema: every table of backend-design.md §2, PostGIS, append-only and reference triggers.

Serves: D-012 (schema-first: one initial migration before module work packages start), D-005 (append-only
event versions, evidence photos, audit log and consents), D-014, D-019, FR25, FR61, FR4 (reference bundles,
backend-design.md §3). Callers: `alembic upgrade` / `alembic downgrade` (apps/api/alembic.ini);
tests/integration/test_schema.py.

The create_table / create_index calls mirror the models in agritrace/modules/*/models.py exactly, so
`alembic check` reports no drift; the raw SQL at the end (functions, triggers, sequence) is invisible to
autogenerate. Geography columns are created with `spatial_index=False` and their GiST indexes are created
explicitly, so each index is created once.

Revision ID: 0001
Revises:
Create Date: 2026-10-29
"""

from collections.abc import Sequence
from typing import Any

import sqlalchemy as sa
from alembic import op
from geoalchemy2 import Geography
from sqlalchemy.dialects import postgresql

# DECISION D-012: one initial migration creates every table before the module work packages start.
#   ADV: no Alembic head conflicts between parallel workers; reviewers see the whole model at once.
#   COMPROMISE: some columns stay unused in the pilot; later schema changes are small follow-up revisions
#     reviewed centrally.
revision: str = "0001"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# DECISION D-005: the database itself refuses UPDATE and DELETE on records that must never change, so no
#   code path (ORM, raw SQL, a future module, a console session) can rewrite history.
#   ADV: farm events, evidence, audit rows and consents are tamper-evident for GI and certification audits.
#   COMPROMISE: corrections need new rows (event versions); test clean-up must drop or truncate tables.
# `forbid_change()` takes, as trigger arguments, the columns an UPDATE may still change; with none, every
# UPDATE is refused. DELETE is always refused. The error is SQLSTATE 23001 (restrict_violation) with the
# message `append_only_violation`, which the API maps to the registered error of the same code.
FORBID_CHANGE = """
CREATE FUNCTION forbid_change() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND TG_NARGS > 0 AND (to_jsonb(OLD) - TG_ARGV) = (to_jsonb(NEW) - TG_ARGV) THEN
        RETURN NEW;
    END IF;
    RAISE EXCEPTION 'append_only_violation'
        USING ERRCODE = 'restrict_violation',
              DETAIL = format('%s on %s is not allowed', TG_OP, TG_TABLE_NAME),
              HINT = 'Add a new version instead of changing or deleting this row.';
END
$$
"""

# Table -> columns an UPDATE may change.
APPEND_ONLY: dict[str, tuple[str, ...]] = {
    "event_versions": (),
    "audit_log": (),
    # A photo row is written when the entry is pushed, before the bytes exist. The confirm, verify and
    # variants steps (D-011, FR61) then record what they learn about the stored object; the evidence itself
    # (bucket, object_key, sha256_client, size, links to event version or reading) never changes.
    # upload_url_expires_at changes when an expired presigned URL is re-issued for the same object key.
    "evidence_photos": (
        "sha256_server",
        "exif_taken_at",
        "exif_gps",
        "status",
        "variants",
        "s3_version_id",
        "upload_url_expires_at",
        "uploaded_at",
        "verified_at",
        "updated_at",
    ),
    # A consent is never edited, only withdrawn (FR41).
    "consent_records": ("revoked_at", "updated_at"),
}

# Every change to a table feeding an offline reference bundle bumps that part's version for the row's FPO
# (fpo_id NULL for global rows) to the next value of one sequence, so `GET /v1/sync/reference?since=<n>`
# compares a single number across parts (backend-design.md §3). Trigger-inserted rows get a random UUID id.
BUMP_REFERENCE_VERSION = """
CREATE FUNCTION bump_reference_version() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    row_data jsonb;
BEGIN
    IF TG_OP = 'DELETE' THEN
        row_data := to_jsonb(OLD);
    ELSE
        row_data := to_jsonb(NEW);
    END IF;
    INSERT INTO reference_versions (id, part, fpo_id, version)
    VALUES (gen_random_uuid(), TG_ARGV[0], (row_data ->> 'fpo_id')::uuid, nextval('reference_version_seq'))
    ON CONFLICT ON CONSTRAINT uq_reference_versions_part
    DO UPDATE SET version = EXCLUDED.version, updated_at = now();
    RETURN NULL;
END
$$
"""

# Table -> bundle part name.
REFERENCE_PARTS: dict[str, str] = {
    "plots": "plots",
    "crops": "crops",
    "inputs_master": "inputs",
    "standards_profile_versions": "standards",
    "gi_region_versions": "gi_region",
    "villages": "villages",
}

# Created with use_alter: each pair of tables references the other.
LATE_FOREIGN_KEYS = (
    ("fk_events_current_version_id_event_versions", "events"),
    ("fk_evidence_photos_quality_reading_id_quality_readings", "evidence_photos"),
)


def _id() -> sa.Column[Any]:
    """Build the primary-key column of `core.db.IdTimestamps` (frozen here as of this revision).

    Returns:
        A new `id UUID NOT NULL` column; the primary key itself is declared per table.
    """
    return sa.Column(
        "id",
        sa.Uuid(),
        nullable=False,
        comment="Primary key, UUIDv7; from the phone for offline-captured rows (D-005), else the API.",
    )


def _timestamps() -> tuple[sa.Column[Any], sa.Column[Any]]:
    """Build the `created_at` / `updated_at` columns of `core.db.IdTimestamps` (frozen as of this revision).

    Returns:
        Two new `timestamptz NOT NULL DEFAULT now()` columns.
    """
    return (
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
            comment="When the row was inserted (database clock, UTC).",
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
            comment="When the row was last changed (database clock, UTC).",
        ),
    )


def upgrade() -> None:
    """Create PostGIS, every table and index, then the triggers.

    Side effects:
        Creates the postgis extension (if missing), 39 tables with their indexes and constraints, the
        sequence `reference_version_seq`, functions `forbid_change` and `bump_reference_version`, and their
        triggers.
    """
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis")
    op.create_table(
        "audit_log",
        _id(),
        sa.Column(
            "at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When the change was flushed (API clock, UTC).",
        ),
        sa.Column(
            "actor_user_id",
            sa.Uuid(),
            nullable=True,
            comment="User who made the change; null for system jobs.",
        ),
        sa.Column(
            "on_behalf_of_farmer_id",
            sa.Uuid(),
            nullable=True,
            comment="Farmer the actor entered data for (assist mode).",
        ),
        sa.Column("assist_session_id", sa.Uuid(), nullable=True, comment="Assist session in force, if any."),
        sa.Column("device_id", sa.Uuid(), nullable=True, comment="Device the request came from, if any."),
        sa.Column(
            "gps",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="Device position sent with the request, if any.",
        ),
        sa.Column("action", sa.Text(), nullable=False, comment="`create`, `update` or `delete`."),
        sa.Column("entity_type", sa.Text(), nullable=False, comment="Table name of the changed row."),
        sa.Column("entity_id", sa.Uuid(), nullable=True, comment="Primary key of the changed row."),
        sa.Column(
            "diff",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="create/delete: column values; update: {column: [old, new]} for changed columns.",
        ),
        sa.Column(
            "request_id", sa.Text(), nullable=True, comment="Request id for correlating with API logs."
        ),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_audit_log")),
    )
    op.create_index("ix_audit_log_entity", "audit_log", ["entity_type", "entity_id"], unique=False)
    op.create_table(
        "fpos",
        _id(),
        sa.Column(
            "code",
            sa.Text(),
            nullable=False,
            comment="Short stable code, e.g. VIRUDHAI_SCFC_VINOBA_BHAVA_FPO.",
        ),
        sa.Column("name", sa.Text(), nullable=False, comment="Registered name."),
        sa.Column(
            "kind",
            sa.Enum(
                "fpo", "company", "coop", name="orgkind", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="Legal form: fpo, company or coop.",
        ),
        sa.Column(
            "address",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Structured address {village, block, district, state, pin} (core.schemas.Address, FR53).",
        ),
        sa.Column(
            "fssai_no",
            sa.Text(),
            nullable=True,
            comment="FSSAI licence number shown on the public page (FR62).",
        ),
        sa.Column(
            "gi_authorised_user_no",
            sa.Text(),
            nullable=True,
            comment="GI authorised-user registration number of the FPO (FR62).",
        ),
        sa.Column(
            "public_show_farmer_names",
            sa.Boolean(),
            nullable=False,
            comment="Whether public pages may show farmer names (still subject to consent).",
        ),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_fpos")),
        sa.UniqueConstraint("code", name=op.f("uq_fpos_code")),
    )
    op.create_table(
        "gi_tags",
        _id(),
        sa.Column("gi_number", sa.Text(), nullable=False, comment="GI application number, e.g. 883."),
        sa.Column("name", sa.Text(), nullable=False, comment="Registered GI name in English."),
        sa.Column("name_local", sa.Text(), nullable=True, comment="GI name in the local script."),
        sa.Column("registry_ref", sa.Text(), nullable=True, comment="Certificate / GI Journal reference."),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_gi_tags")),
        sa.UniqueConstraint("gi_number", name=op.f("uq_gi_tags_gi_number")),
    )
    op.create_table(
        "otp_challenges",
        _id(),
        sa.Column("phone", sa.Text(), nullable=False, comment="Phone the code was sent to, E.164."),
        sa.Column(
            "code_hash",
            sa.Text(),
            nullable=False,
            comment="Hash of the one-time code; the code itself is never stored.",
        ),
        sa.Column(
            "expires_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="After this instant the code is refused.",
        ),
        sa.Column("attempts", sa.Integer(), nullable=False, comment="Wrong guesses so far; capped by B02."),
        sa.Column(
            "consumed_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When the code was used; null while open.",
        ),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_otp_challenges")),
    )
    op.create_index(op.f("ix_otp_challenges_phone"), "otp_challenges", ["phone"], unique=False)
    op.create_table(
        "scan_events",
        _id(),
        sa.Column("batch_code", sa.Text(), nullable=False, comment="Batch code from the scanned URL."),
        sa.Column(
            "scanned_at", sa.DateTime(timezone=True), nullable=False, comment="When the page was opened."
        ),
        sa.Column(
            "approx_location",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="Coarse location (city level), if known.",
        ),
        sa.Column(
            "user_agent_hash",
            sa.Text(),
            nullable=True,
            comment="Hash of the user agent, to count unique viewers.",
        ),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_scan_events")),
    )
    op.create_index(op.f("ix_scan_events_batch_code"), "scan_events", ["batch_code"], unique=False)
    op.create_table(
        "users",
        _id(),
        sa.Column(
            "phone", sa.Text(), nullable=False, comment="Mobile number in E.164 form, e.g. +919876543210."
        ),
        sa.Column("name", sa.Text(), nullable=False, comment="Display name in English script."),
        sa.Column(
            "name_local", sa.Text(), nullable=True, comment="Display name in the local script (Tamil), FR5."
        ),
        sa.Column(
            "lang", sa.Text(), nullable=False, comment="Preferred UI language code: `ta` or `en` (FR5)."
        ),
        sa.Column(
            "is_super_admin",
            sa.Boolean(),
            nullable=False,
            comment="Platform compliance team; may edit GI regions and standards (FR31, FR47).",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "active", "suspended", name="userstatus", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="active may sign in; suspended may not.",
        ),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_users")),
        sa.UniqueConstraint("phone", name=op.f("uq_users_phone")),
    )
    op.create_table(
        "villages",
        _id(),
        sa.Column("lgd_code", sa.Text(), nullable=True, comment="Local Government Directory village code."),
        sa.Column("name_en", sa.Text(), nullable=False, comment="Village name in English."),
        sa.Column("name_local", sa.Text(), nullable=True, comment="Village name in the local script (FR5)."),
        sa.Column("block", sa.Text(), nullable=True, comment="Development block."),
        sa.Column("taluk", sa.Text(), nullable=True, comment="Taluk (sub-district); second GI check (FR53)."),
        sa.Column("district", sa.Text(), nullable=False, comment="District."),
        sa.Column("state", sa.Text(), nullable=False, comment="State."),
        sa.Column("pincode", sa.Text(), nullable=True, comment="Six-digit PIN code."),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_villages")),
        sa.UniqueConstraint("lgd_code", name=op.f("uq_villages_lgd_code")),
    )
    op.create_table(
        "crops",
        _id(),
        sa.Column("code", sa.Text(), nullable=False, comment="Stable crop code, e.g. SAMBA_VATHAL."),
        sa.Column("name_en", sa.Text(), nullable=False, comment="Crop name in English."),
        sa.Column("name_local", sa.Text(), nullable=True, comment="Crop name in the local script."),
        sa.Column("lang", sa.Text(), nullable=False, comment="Language code of name_local."),
        sa.Column("gi_tag_id", sa.Uuid(), nullable=True, comment="GI tag the crop is sold under, if any."),
        sa.Column(
            "event_schema",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Mandatory event types and date-order rules with nursery/main-field tracks (FR22, FR55).",
        ),
        sa.Column("active", sa.Boolean(), nullable=False, comment="False hides the crop from new lots."),
        *_timestamps(),
        sa.ForeignKeyConstraint(["gi_tag_id"], ["gi_tags.id"], name=op.f("fk_crops_gi_tag_id_gi_tags")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_crops")),
        sa.UniqueConstraint("code", name=op.f("uq_crops_code")),
    )
    op.create_table(
        "devices",
        _id(),
        sa.Column("user_id", sa.Uuid(), nullable=False, comment="Signed-in user."),
        sa.Column("platform", sa.Text(), nullable=False, comment="`android`, `ios` or `web`."),
        sa.Column("app_version", sa.Text(), nullable=True, comment="App version last reported, e.g. 1.0.3."),
        sa.Column(
            "refresh_token_hash", sa.Text(), nullable=True, comment="Hash of the current refresh token."
        ),
        sa.Column(
            "last_seen_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Last authenticated request from it.",
        ),
        sa.Column(
            "revoked_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When sign-out or an admin revoked it.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_devices_user_id_users")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_devices")),
    )
    op.create_index(op.f("ix_devices_user_id"), "devices", ["user_id"], unique=False)
    op.create_table(
        "flags",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column(
            "subject_type",
            sa.Enum(
                "plot",
                "event",
                "lot",
                "batch",
                "reading",
                name="flagsubject",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Kind of row flagged.",
        ),
        sa.Column(
            "subject_id",
            sa.Uuid(),
            nullable=False,
            comment="Id of the flagged row (polymorphic, no foreign key).",
        ),
        sa.Column(
            "rule_code", sa.Text(), nullable=False, comment="Rule that raised it, e.g. quantity_mismatch."
        ),
        sa.Column(
            "severity",
            sa.Enum(
                "info", "warn", "hold", name="severity", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="info, warn, or hold (blocks GI labelling).",
        ),
        sa.Column(
            "details",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Rule inputs and limits behind the finding.",
        ),
        sa.Column(
            "dedupe_key",
            sa.Text(),
            nullable=False,
            comment="rule_code + subject (+ discriminator); re-running a rule never duplicates.",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "open",
                "cleared",
                "fixed",
                "escalated",
                name="flagstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Resolution state (FR70).",
        ),
        sa.Column(
            "assigned_role",
            sa.Enum(
                "farmer",
                "field_officer",
                "qc_officer",
                "fpo_admin",
                "viewer",
                name="role",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=True,
            comment="Role expected to resolve it.",
        ),
        sa.Column(
            "raised_at", sa.DateTime(timezone=True), nullable=False, comment="When the rule first raised it."
        ),
        sa.Column("resolved_by", sa.Uuid(), nullable=True, comment="Resolver."),
        sa.Column(
            "resolution_reason_code", sa.Text(), nullable=True, comment="Coded resolution reason (FR70)."
        ),
        sa.Column(
            "resolution_note", sa.Text(), nullable=True, comment="Reviewer's note: method, evidence (FR70)."
        ),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True, comment="When it was resolved."),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_flags_fpo_id_fpos")),
        sa.ForeignKeyConstraint(["resolved_by"], ["users.id"], name=op.f("fk_flags_resolved_by_users")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_flags")),
        sa.UniqueConstraint("dedupe_key", name=op.f("uq_flags_dedupe_key")),
    )
    op.create_index(op.f("ix_flags_fpo_id"), "flags", ["fpo_id"], unique=False)
    op.create_index("ix_flags_subject", "flags", ["subject_type", "subject_id"], unique=False)
    op.create_table(
        "gi_region_versions",
        _id(),
        sa.Column("gi_tag_id", sa.Uuid(), nullable=False, comment="GI tag this region is for."),
        sa.Column(
            "version_no",
            sa.Integer(),
            nullable=False,
            comment="Version number, 0 upwards; latest effective one applies.",
        ),
        sa.Column(
            "geom",
            Geography("MULTIPOLYGON", 4326, spatial_index=False),
            nullable=False,
            comment="Production-area outline (WGS84).",
        ),
        sa.Column(
            "tolerance_buffer_m",
            sa.Numeric(precision=12, scale=3),
            nullable=False,
            comment="GPS-drift buffer around the outline in metres (FR32).",
        ),
        sa.Column(
            "taluks",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Taluks named in the GI registration that this outline unions (D-019).",
        ),
        sa.Column(
            "source_ref",
            sa.Text(),
            nullable=False,
            comment="Source dataset and build script reference (D-019).",
        ),
        sa.Column(
            "licence", sa.Text(), nullable=False, comment="Licence of the source data, e.g. ODbL (D-019)."
        ),
        sa.Column(
            "confidence",
            sa.Text(),
            nullable=False,
            comment="How the outline was derived, e.g. district_derived (D-019).",
        ),
        sa.Column(
            "effective_from", sa.Date(), nullable=False, comment="Date from which checks use this version."
        ),
        sa.Column(
            "created_by",
            sa.Uuid(),
            nullable=True,
            comment="Super-admin who loaded it; null for seeded versions.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["created_by"], ["users.id"], name=op.f("fk_gi_region_versions_created_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["gi_tag_id"], ["gi_tags.id"], name=op.f("fk_gi_region_versions_gi_tag_id_gi_tags")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_gi_region_versions")),
        sa.UniqueConstraint("gi_tag_id", "version_no", name=op.f("uq_gi_region_versions_gi_tag_id")),
    )
    op.create_index(
        "idx_gi_region_versions_geom", "gi_region_versions", ["geom"], unique=False, postgresql_using="gist"
    )
    op.create_table(
        "inputs_master",
        _id(),
        sa.Column(
            "fpo_id", sa.Uuid(), nullable=True, comment="FPO-specific entry; null for the global list."
        ),
        sa.Column("name_en", sa.Text(), nullable=False, comment="Product name in English."),
        sa.Column("name_local", sa.Text(), nullable=True, comment="Product name in the local script (FR5)."),
        sa.Column("manufacturer", sa.Text(), nullable=True, comment="Manufacturer or brand."),
        sa.Column(
            "category",
            sa.Enum(
                "chemical_fertilizer",
                "organic_fertilizer",
                "bio_fertilizer",
                "chemical_pesticide",
                "bio_pesticide",
                "other",
                name="inputcategory",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Category from which practice tags derive (FR56).",
        ),
        sa.Column(
            "unit",
            sa.Text(),
            nullable=False,
            comment="Unit quantities of this input are entered in, e.g. kg, l.",
        ),
        sa.Column(
            "pack_size",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Typical pack size, in `unit`.",
        ),
        sa.Column(
            "photo_key", sa.Text(), nullable=True, comment="Object key of a product photo for picking."
        ),
        sa.Column("active", sa.Boolean(), nullable=False, comment="False hides it from new entries."),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_inputs_master_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_inputs_master")),
    )
    op.create_index(op.f("ix_inputs_master_fpo_id"), "inputs_master", ["fpo_id"], unique=False)
    op.create_table(
        "memberships",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("user_id", sa.Uuid(), nullable=False, comment="The member."),
        sa.Column(
            "role",
            sa.Enum(
                "farmer",
                "field_officer",
                "qc_officer",
                "fpo_admin",
                "viewer",
                name="role",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Role inside this FPO (FR14).",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_memberships_fpo_id_fpos")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_memberships_user_id_users")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_memberships")),
        sa.UniqueConstraint("user_id", "fpo_id", name=op.f("uq_memberships_user_id")),
    )
    op.create_index(op.f("ix_memberships_fpo_id"), "memberships", ["fpo_id"], unique=False)
    op.create_table(
        "notifications",
        _id(),
        sa.Column("user_id", sa.Uuid(), nullable=False, comment="Recipient."),
        sa.Column(
            "channel",
            sa.Enum(
                "push",
                "sms",
                "whatsapp",
                "console",
                name="notificationchannel",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="push, sms, whatsapp or console (dev).",
        ),
        sa.Column(
            "template_key",
            sa.Text(),
            nullable=False,
            comment="Message template, e.g. harvest_window_approaching.",
        ),
        sa.Column("lang", sa.Text(), nullable=False, comment="Language rendered: ta or en (FR5)."),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Template variables; never phone numbers or IDs.",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "queued",
                "sent",
                "failed",
                name="notificationstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="queued, sent or failed.",
        ),
        sa.Column(
            "provider_ref", sa.Text(), nullable=True, comment="Message id returned by the SMS/push provider."
        ),
        sa.Column(
            "sent_at", sa.DateTime(timezone=True), nullable=True, comment="When the provider accepted it."
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_notifications_user_id_users")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_notifications")),
    )
    op.create_index(op.f("ix_notifications_user_id"), "notifications", ["user_id"], unique=False)
    op.create_table(
        "processors",
        _id(),
        sa.Column(
            "fpo_id", sa.Uuid(), nullable=True, comment="FPO that registered it; null for a shared processor."
        ),
        sa.Column("name", sa.Text(), nullable=False, comment="Registered name."),
        sa.Column(
            "kind",
            sa.Enum(
                "fpo", "company", "coop", name="orgkind", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="Legal form: fpo, company or coop.",
        ),
        sa.Column(
            "address",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Structured address {village, block, district, state, pin} (FR53).",
        ),
        sa.Column(
            "fssai_no",
            sa.Text(),
            nullable=True,
            comment="FSSAI licence number shown on the public page (FR62).",
        ),
        sa.Column(
            "gi_authorised_user_no",
            sa.Text(),
            nullable=True,
            comment="GI authorised-user registration number of the processor (FR62).",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_processors_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_processors")),
    )
    op.create_index(op.f("ix_processors_fpo_id"), "processors", ["fpo_id"], unique=False)
    op.create_table(
        "producer_groups",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("name", sa.Text(), nullable=False, comment="Group name."),
        sa.Column(
            "kind",
            sa.Enum(
                "shg", "other", name="producergroupkind", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="shg or other.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_producer_groups_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_producer_groups")),
    )
    op.create_index(op.f("ix_producer_groups_fpo_id"), "producer_groups", ["fpo_id"], unique=False)
    op.create_table(
        "reference_versions",
        _id(),
        sa.Column(
            "part",
            sa.Text(),
            nullable=False,
            comment="Bundle part: plots, crops, inputs, standards, gi_region, villages.",
        ),
        sa.Column(
            "fpo_id", sa.Uuid(), nullable=True, comment="FPO the part version is for; null for global data."
        ),
        sa.Column(
            "version",
            sa.BigInteger(),
            nullable=False,
            comment="Value from sequence reference_version_seq, so one `since` compares all parts.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_reference_versions_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_reference_versions")),
        sa.UniqueConstraint(
            "part", "fpo_id", name=op.f("uq_reference_versions_part"), postgresql_nulls_not_distinct=True
        ),
    )
    op.create_table(
        "farmers",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column(
            "user_id", sa.Uuid(), nullable=True, comment="Sign-in account; null for feature-phone farmers."
        ),
        sa.Column("code", sa.Text(), nullable=False, comment="Farmer code, unique inside the FPO."),
        sa.Column("name", sa.Text(), nullable=False, comment="Name in English script."),
        sa.Column("name_local", sa.Text(), nullable=True, comment="Name in the local script (FR5)."),
        sa.Column("photo_key", sa.Text(), nullable=True, comment="Object key of the profile photo."),
        sa.Column(
            "address",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Structured address {village, block, district, state, pin} (FR53).",
        ),
        sa.Column(
            "village_id", sa.Uuid(), nullable=True, comment="Village picked from the directory, if any."
        ),
        sa.Column(
            "gi_authorised_user_no",
            sa.Text(),
            nullable=True,
            comment="Farmer's GI authorised-user registration number (FR62).",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "pending",
                "active",
                "suspended",
                name="farmerstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="pending until approved or location confirmed (FR67).",
        ),
        sa.Column("approved_by", sa.Uuid(), nullable=True, comment="Admin who approved the farmer."),
        sa.Column(
            "approved_at", sa.DateTime(timezone=True), nullable=True, comment="When the farmer was approved."
        ),
        sa.Column(
            "no_smartphone",
            sa.Boolean(),
            nullable=False,
            comment="True when entries are always made by an officer (assist mode).",
        ),
        sa.Column(
            "producer_group_id", sa.Uuid(), nullable=True, comment="Producer group, when that feature is on."
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["approved_by"], ["users.id"], name=op.f("fk_farmers_approved_by_users")),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_farmers_fpo_id_fpos")),
        sa.ForeignKeyConstraint(
            ["producer_group_id"],
            ["producer_groups.id"],
            name=op.f("fk_farmers_producer_group_id_producer_groups"),
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_farmers_user_id_users")),
        sa.ForeignKeyConstraint(["village_id"], ["villages.id"], name=op.f("fk_farmers_village_id_villages")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_farmers")),
        sa.UniqueConstraint("fpo_id", "code", name=op.f("uq_farmers_fpo_id")),
    )
    op.create_index(op.f("ix_farmers_fpo_id"), "farmers", ["fpo_id"], unique=False)
    op.create_index(op.f("ix_farmers_user_id"), "farmers", ["user_id"], unique=False)
    op.create_table(
        "standards_profiles",
        _id(),
        sa.Column("crop_id", sa.Uuid(), nullable=False, comment="Crop it grades."),
        sa.Column(
            "scheme",
            sa.Enum(
                "agmark",
                "iso",
                "fssai",
                "custom",
                name="standardsscheme",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="agmark, iso, fssai or custom.",
        ),
        sa.Column("name", sa.Text(), nullable=False, comment="Profile name."),
        sa.Column("standard_ref", sa.Text(), nullable=False, comment="Standard document reference."),
        sa.Column("owner_user_id", sa.Uuid(), nullable=True, comment="Compliance owner (super-admin)."),
        *_timestamps(),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"], name=op.f("fk_standards_profiles_crop_id_crops")),
        sa.ForeignKeyConstraint(
            ["owner_user_id"], ["users.id"], name=op.f("fk_standards_profiles_owner_user_id_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_standards_profiles")),
    )
    op.create_index(op.f("ix_standards_profiles_crop_id"), "standards_profiles", ["crop_id"], unique=False)
    op.create_table(
        "sync_cursors",
        sa.Column("device_id", sa.Uuid(), nullable=False, comment="Device this cursor belongs to."),
        sa.Column(
            "last_pull_cursor", sa.Text(), nullable=True, comment="Opaque cursor returned by the last pull."
        ),
        sa.Column(
            "last_push_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When the device last pushed entries.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["device_id"], ["devices.id"], name=op.f("fk_sync_cursors_device_id_devices")
        ),
        sa.PrimaryKeyConstraint("device_id", name=op.f("pk_sync_cursors")),
    )
    op.create_table(
        "sync_metrics",
        _id(),
        sa.Column("device_id", sa.Uuid(), nullable=False, comment="Reporting device."),
        sa.Column("entry_client_id", sa.Uuid(), nullable=False, comment="Client id of the entry measured."),
        sa.Column(
            "saved_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When the entry was saved on the phone.",
        ),
        sa.Column(
            "acked_at", sa.DateTime(timezone=True), nullable=True, comment="When the server acknowledged it."
        ),
        sa.Column(
            "photo_upload_ms", sa.Integer(), nullable=True, comment="Total photo upload time in milliseconds."
        ),
        sa.Column("failures", sa.Integer(), nullable=False, comment="Failed send attempts before success."),
        sa.Column(
            "network_type", sa.Text(), nullable=True, comment="Network at send time, e.g. 2g, 3g, lte, wifi."
        ),
        sa.Column("app_version", sa.Text(), nullable=True, comment="App version that reported it."),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["device_id"], ["devices.id"], name=op.f("fk_sync_metrics_device_id_devices")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_sync_metrics")),
    )
    op.create_index(op.f("ix_sync_metrics_device_id"), "sync_metrics", ["device_id"], unique=False)
    op.create_table(
        "assist_sessions",
        _id(),
        sa.Column(
            "officer_user_id", sa.Uuid(), nullable=False, comment="Field officer or admin doing the entry."
        ),
        sa.Column("farmer_id", sa.Uuid(), nullable=False, comment="Farmer being assisted."),
        sa.Column(
            "started_at", sa.DateTime(timezone=True), nullable=False, comment="Session start (device clock)."
        ),
        sa.Column(
            "ended_at", sa.DateTime(timezone=True), nullable=True, comment="Session end; null while open."
        ),
        sa.Column(
            "started_gps",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="Where the session started (WGS84).",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["farmer_id"], ["farmers.id"], name=op.f("fk_assist_sessions_farmer_id_farmers")
        ),
        sa.ForeignKeyConstraint(
            ["officer_user_id"], ["users.id"], name=op.f("fk_assist_sessions_officer_user_id_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_assist_sessions")),
    )
    op.create_index(op.f("ix_assist_sessions_farmer_id"), "assist_sessions", ["farmer_id"], unique=False)
    op.create_table(
        "consent_records",
        _id(),
        sa.Column("farmer_id", sa.Uuid(), nullable=False, comment="Farmer who consented."),
        sa.Column(
            "consent_type",
            sa.Enum(
                "data_collection",
                "public_name",
                "partner_share",
                name="consenttype",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="What was consented to.",
        ),
        sa.Column(
            "consent_version",
            sa.Text(),
            nullable=False,
            comment="Version of the consent text shown, e.g. v1-ta.",
        ),
        sa.Column(
            "recording_ref",
            sa.Text(),
            nullable=True,
            comment="Object key of an audio/photo recording of the consent, if captured.",
        ),
        sa.Column(
            "witnessed_by_user_id",
            sa.Uuid(),
            nullable=True,
            comment="Officer who witnessed it (assisted capture).",
        ),
        sa.Column(
            "given_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When consent was given (device clock).",
        ),
        sa.Column("device_id", sa.Uuid(), nullable=True, comment="Device that captured it."),
        sa.Column(
            "revoked_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When it was withdrawn; the only column the append-only trigger lets change.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["device_id"], ["devices.id"], name=op.f("fk_consent_records_device_id_devices")
        ),
        sa.ForeignKeyConstraint(
            ["farmer_id"], ["farmers.id"], name=op.f("fk_consent_records_farmer_id_farmers")
        ),
        sa.ForeignKeyConstraint(
            ["witnessed_by_user_id"], ["users.id"], name=op.f("fk_consent_records_witnessed_by_user_id_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_consent_records")),
    )
    op.create_index(op.f("ix_consent_records_farmer_id"), "consent_records", ["farmer_id"], unique=False)
    op.create_table(
        "plots",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("farmer_id", sa.Uuid(), nullable=False, comment="Owner."),
        sa.Column("code", sa.Text(), nullable=False, comment="Plot code shown to people, e.g. P-01."),
        sa.Column(
            "pin",
            Geography("POINT", 4326, spatial_index=False),
            nullable=False,
            comment="Plot pin dropped on the plot (WGS84), FR64.",
        ),
        sa.Column("pin_accuracy_m", sa.Double(), nullable=True, comment="GPS accuracy of the pin in metres."),
        sa.Column(
            "pin_method",
            sa.Enum(
                "live_gps", "map_pin", name="pinmethod", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="live_gps, or map_pin (needs review, FR64).",
        ),
        sa.Column(
            "pin_device_time",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="Phone clock when the pin was taken.",
        ),
        sa.Column(
            "pin_gps_time",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="GPS fix time of the pin, if any.",
        ),
        sa.Column(
            "pin_server_received_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When the server received the pin.",
        ),
        sa.Column(
            "declared_area_acres",
            sa.Numeric(precision=12, scale=3),
            nullable=False,
            comment="Area declared by the farmer, in acres (FR65).",
        ),
        sa.Column(
            "land_record_ref",
            sa.Text(),
            nullable=True,
            comment="Survey / patta / chitta reference (FR65); internal only, never public (CLAUDE.md §6).",
        ),
        sa.Column(
            "walked_boundary",
            Geography("POLYGON", 4326, spatial_index=False),
            nullable=True,
            comment="Boundary walked with GPS (FR66); internal only, never public.",
        ),
        sa.Column(
            "walked_area_acres",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Area of the walked boundary, in acres.",
        ),
        sa.Column(
            "farming_type",
            sa.Enum(
                "irrigated",
                "rainfed",
                name="farmingtype",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=True,
            comment="irrigated or rainfed (FR54).",
        ),
        sa.Column(
            "irrigation_source",
            sa.Enum(
                "well",
                "borewell",
                "canal",
                "tank",
                "rain",
                name="irrigationsource",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=True,
            comment="Water source (FR54).",
        ),
        sa.Column(
            "soil_type", sa.Text(), nullable=True, comment="Soil type, free text or configured list (D-017)."
        ),
        sa.Column(
            "location_status",
            sa.Enum(
                "confirmed",
                "needs_review",
                "outside",
                "near_edge",
                name="locationstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Result of the GI region check (FR67, FR70).",
        ),
        sa.Column(
            "location_method_label",
            sa.Text(),
            nullable=True,
            comment="Public label of how the location was set, e.g. Live GPS pin, Boundary walked (FR72).",
        ),
        sa.Column(
            "revision_no",
            sa.Integer(),
            nullable=False,
            comment="Current revision; bumps on admin correction.",
        ),
        sa.Column(
            "reviewed_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When a flagged location was reviewed (FR70).",
        ),
        sa.Column(
            "review_method",
            sa.Text(),
            nullable=True,
            comment="How it was reviewed: land_record, satellite or field_visit (FR70).",
        ),
        sa.Column("review_outcome", sa.Text(), nullable=True, comment="Reviewer's outcome and note (FR70)."),
        *_timestamps(),
        sa.ForeignKeyConstraint(["farmer_id"], ["farmers.id"], name=op.f("fk_plots_farmer_id_farmers")),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_plots_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_plots")),
    )
    op.create_index("idx_plots_pin", "plots", ["pin"], unique=False, postgresql_using="gist")
    op.create_index(
        "idx_plots_walked_boundary", "plots", ["walked_boundary"], unique=False, postgresql_using="gist"
    )
    op.create_index(op.f("ix_plots_farmer_id"), "plots", ["farmer_id"], unique=False)
    op.create_index(op.f("ix_plots_fpo_id"), "plots", ["fpo_id"], unique=False)
    op.create_table(
        "standards_profile_versions",
        _id(),
        sa.Column("profile_id", sa.Uuid(), nullable=False, comment="Profile."),
        sa.Column("version_no", sa.Integer(), nullable=False, comment="Version number, 1 upwards."),
        sa.Column(
            "edition", sa.Text(), nullable=False, comment="Edition of the standard cited (FR47, FR51)."
        ),
        sa.Column("clause_ref", sa.Text(), nullable=False, comment="Clause or schedule cited (FR47)."),
        sa.Column(
            "rules",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Parameters, limits, gates, trail rules and yield ceiling (StandardsProfileRules, §4).",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "draft",
                "published",
                "retired",
                name="profileversionstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="draft, published or retired.",
        ),
        sa.Column(
            "published_at", sa.DateTime(timezone=True), nullable=True, comment="When it was published."
        ),
        sa.Column("published_by", sa.Uuid(), nullable=True, comment="Publisher."),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["profile_id"],
            ["standards_profiles.id"],
            name=op.f("fk_standards_profile_versions_profile_id_standards_profiles"),
        ),
        sa.ForeignKeyConstraint(
            ["published_by"], ["users.id"], name=op.f("fk_standards_profile_versions_published_by_users")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_standards_profile_versions")),
        sa.UniqueConstraint(
            "profile_id", "version_no", name=op.f("uq_standards_profile_versions_profile_id")
        ),
    )
    op.create_table(
        "batches",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("crop_id", sa.Uuid(), nullable=False, comment="Crop of every lot in it."),
        sa.Column("processor_id", sa.Uuid(), nullable=False, comment="Processor."),
        sa.Column(
            "code",
            sa.Text(),
            nullable=False,
            comment="12-char Crockford base32 batch code, e.g. FGP8T4033HM7 (QR, public URL).",
        ),
        sa.Column(
            "superlot_code",
            sa.Text(),
            nullable=True,
            comment="Super-lot code COMBO_LOT_ + 8 hex, e.g. COMBO_LOT_6C1DCCFE.",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "created",
                "graded",
                "packed",
                "published",
                name="batchstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Batch lifecycle.",
        ),
        sa.Column(
            "gi_label_requested", sa.Boolean(), nullable=False, comment="Admin asked to label it as GI."
        ),
        sa.Column(
            "gi_verified",
            sa.Boolean(),
            nullable=False,
            comment="Every component lot passed the GI region check (FR29, FR30).",
        ),
        sa.Column(
            "gi_block_reasons",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Why GI labelling is blocked: list of {lot_id, reason} (FR29).",
        ),
        sa.Column(
            "total_received_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Sum of intake quantities in kg (FR10).",
        ),
        sa.Column(
            "graded_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Quantity after grading in kg (Stage 8).",
        ),
        sa.Column(
            "packed_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Quantity in final packs in kg (Stage 9).",
        ),
        sa.Column("computed_grade", sa.Text(), nullable=True, comment="Grade computed from readings (FR48)."),
        sa.Column(
            "standards_profile_version_id",
            sa.Uuid(),
            nullable=True,
            comment="Profile version graded against (FR47).",
        ),
        sa.Column("pack_date", sa.Date(), nullable=True, comment="Pack date printed on the label (FR62)."),
        sa.Column(
            "best_before_date", sa.Date(), nullable=True, comment="Best-before date on the label (FR62)."
        ),
        sa.Column(
            "current_build_no", sa.Integer(), nullable=False, comment="Latest public page build (FR17)."
        ),
        sa.Column("created_by", sa.Uuid(), nullable=False, comment="Admin who created it."),
        sa.Column(
            "second_signoff_by",
            sa.Uuid(),
            nullable=True,
            comment="Second approver where a gate needs two people.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"], name=op.f("fk_batches_created_by_users")),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"], name=op.f("fk_batches_crop_id_crops")),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_batches_fpo_id_fpos")),
        sa.ForeignKeyConstraint(
            ["processor_id"], ["processors.id"], name=op.f("fk_batches_processor_id_processors")
        ),
        sa.ForeignKeyConstraint(
            ["second_signoff_by"], ["users.id"], name=op.f("fk_batches_second_signoff_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["standards_profile_version_id"],
            ["standards_profile_versions.id"],
            name=op.f("fk_batches_standards_profile_version_id_standards_profile_versions"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_batches")),
        sa.UniqueConstraint("code", name=op.f("uq_batches_code")),
        sa.UniqueConstraint("superlot_code", name=op.f("uq_batches_superlot_code")),
    )
    op.create_index(op.f("ix_batches_fpo_id"), "batches", ["fpo_id"], unique=False)
    op.create_table(
        "id_documents",
        _id(),
        sa.Column("farmer_id", sa.Uuid(), nullable=False, comment="Document owner."),
        sa.Column(
            "doc_type", sa.Text(), nullable=False, comment="Document type code from field configuration."
        ),
        sa.Column(
            "object_key", sa.Text(), nullable=False, comment="Object key in the private id-docs bucket."
        ),
        sa.Column("captured_by", sa.Uuid(), nullable=False, comment="User who captured it."),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=False, comment="When it was captured."),
        sa.Column(
            "consent_record_id", sa.Uuid(), nullable=False, comment="Consent under which it was captured."
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["captured_by"], ["users.id"], name=op.f("fk_id_documents_captured_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["consent_record_id"],
            ["consent_records.id"],
            name=op.f("fk_id_documents_consent_record_id_consent_records"),
        ),
        sa.ForeignKeyConstraint(
            ["farmer_id"], ["farmers.id"], name=op.f("fk_id_documents_farmer_id_farmers")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_id_documents")),
    )
    op.create_index(op.f("ix_id_documents_farmer_id"), "id_documents", ["farmer_id"], unique=False)
    op.create_table(
        "lots",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("farmer_id", sa.Uuid(), nullable=False, comment="Grower."),
        sa.Column("plot_id", sa.Uuid(), nullable=False, comment="Plot harvested."),
        sa.Column("crop_id", sa.Uuid(), nullable=False, comment="Crop."),
        sa.Column("season_label", sa.Text(), nullable=False, comment="Season, e.g. 2025-26 Rabi."),
        sa.Column("code", sa.Text(), nullable=False, comment="Lot code LOT + 8 hex, e.g. LOT0EF81415."),
        sa.Column(
            "status",
            sa.Enum(
                "open",
                "drying",
                "ready_for_sale",
                "received",
                "batched",
                "closed",
                name="lotstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Lot lifecycle.",
        ),
        sa.Column(
            "practice_tags",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="{declared, derived, contradiction} (core.schemas.PracticeTags, FR56).",
        ),
        sa.Column(
            "harvested_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Sum of harvest quantities in kg (FR57).",
        ),
        sa.Column(
            "packed_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="On-farm packed quantity in kg (Stage 6).",
        ),
        sa.Column(
            "ready_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When the lot passed the ready-for-sale gate.",
        ),
        sa.Column(
            "gi_eligible",
            sa.Boolean(),
            nullable=False,
            comment="True when the lot may join a GI-labelled batch (FR28, FR29, FR68).",
        ),
        sa.Column(
            "gi_hold_reason",
            sa.Text(),
            nullable=True,
            comment="Why the lot is held out of GI batches, if so.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["crop_id"], ["crops.id"], name=op.f("fk_lots_crop_id_crops")),
        sa.ForeignKeyConstraint(["farmer_id"], ["farmers.id"], name=op.f("fk_lots_farmer_id_farmers")),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_lots_fpo_id_fpos")),
        sa.ForeignKeyConstraint(["plot_id"], ["plots.id"], name=op.f("fk_lots_plot_id_plots")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_lots")),
        sa.UniqueConstraint("code", name=op.f("uq_lots_code")),
    )
    op.create_index(op.f("ix_lots_farmer_id"), "lots", ["farmer_id"], unique=False)
    op.create_index(op.f("ix_lots_fpo_id"), "lots", ["fpo_id"], unique=False)
    op.create_index(op.f("ix_lots_plot_id"), "lots", ["plot_id"], unique=False)
    op.create_table(
        "plot_revisions",
        _id(),
        sa.Column("plot_id", sa.Uuid(), nullable=False, comment="Corrected plot."),
        sa.Column("revision_no", sa.Integer(), nullable=False, comment="Revision number this snapshot had."),
        sa.Column(
            "snapshot",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="All plot columns before the correction.",
        ),
        sa.Column("changed_by", sa.Uuid(), nullable=False, comment="FPO admin who corrected it."),
        sa.Column(
            "reason_code", sa.Text(), nullable=False, comment="Coded reason for the correction (FR71)."
        ),
        sa.Column("reason_text", sa.Text(), nullable=True, comment="Free-text explanation."),
        sa.Column(
            "changed_at", sa.DateTime(timezone=True), nullable=False, comment="When the correction was made."
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["changed_by"], ["users.id"], name=op.f("fk_plot_revisions_changed_by_users")
        ),
        sa.ForeignKeyConstraint(["plot_id"], ["plots.id"], name=op.f("fk_plot_revisions_plot_id_plots")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_plot_revisions")),
        sa.UniqueConstraint("plot_id", "revision_no", name=op.f("uq_plot_revisions_plot_id")),
    )
    op.create_table(
        "batch_approvals",
        _id(),
        sa.Column("batch_id", sa.Uuid(), nullable=False, comment="Batch."),
        sa.Column(
            "stage",
            sa.Enum(
                "intake",
                "grading",
                "final_packing",
                "publish",
                name="approvalstage",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Gate approved.",
        ),
        sa.Column("approved_by", sa.Uuid(), nullable=False, comment="Approver."),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=False, comment="When it was approved."),
        sa.Column(
            "blocked_reasons",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Open flags or missing evidence at the time, if any were overridden or pending.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["approved_by"], ["users.id"], name=op.f("fk_batch_approvals_approved_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["batch_id"], ["batches.id"], name=op.f("fk_batch_approvals_batch_id_batches")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_batch_approvals")),
    )
    op.create_index(op.f("ix_batch_approvals_batch_id"), "batch_approvals", ["batch_id"], unique=False)
    op.create_table(
        "batch_shares",
        sa.Column("batch_id", sa.Uuid(), nullable=False, comment="Batch."),
        sa.Column("lot_id", sa.Uuid(), nullable=False, comment="Component lot."),
        sa.Column(
            "kg_contributed",
            sa.Numeric(precision=12, scale=3),
            nullable=False,
            comment="Kilograms of the lot in the batch.",
        ),
        sa.Column(
            "share_pct",
            sa.Numeric(precision=6, scale=3),
            nullable=False,
            comment="Percent of the batch, 0–100.",
        ),
        sa.Column(
            "farmer_id",
            sa.Uuid(),
            nullable=False,
            comment="Grower of the lot (denormalised for the public page).",
        ),
        *_timestamps(),
        sa.CheckConstraint(
            "share_pct >= 0 AND share_pct <= 100", name=op.f("ck_batch_shares_share_pct_range")
        ),
        sa.ForeignKeyConstraint(["batch_id"], ["batches.id"], name=op.f("fk_batch_shares_batch_id_batches")),
        sa.ForeignKeyConstraint(
            ["farmer_id"], ["farmers.id"], name=op.f("fk_batch_shares_farmer_id_farmers")
        ),
        sa.ForeignKeyConstraint(["lot_id"], ["lots.id"], name=op.f("fk_batch_shares_lot_id_lots")),
        sa.PrimaryKeyConstraint("batch_id", "lot_id", name=op.f("pk_batch_shares")),
    )
    op.create_index(op.f("ix_batch_shares_farmer_id"), "batch_shares", ["farmer_id"], unique=False)
    op.create_table(
        "events",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column(
            "subject_type",
            sa.Enum(
                "lot", "batch", name="eventsubject", native_enum=False, create_constraint=True, length=32
            ),
            nullable=False,
            comment="Whether the event belongs to a lot or a batch.",
        ),
        sa.Column(
            "lot_id",
            sa.Uuid(),
            nullable=True,
            comment="Component lot (farm events); exactly one of lot/batch.",
        ),
        sa.Column(
            "batch_id",
            sa.Uuid(),
            nullable=True,
            comment="Batch (processing events); exactly one of lot/batch.",
        ),
        sa.Column(
            "plot_id", sa.Uuid(), nullable=True, comment="Plot where a farm event happened (FR69 GPS check)."
        ),
        sa.Column(
            "event_type",
            sa.Enum(
                "land_preparation",
                "nursery",
                "sowing",
                "input_application",
                "harvest",
                "drying",
                "packing",
                "problem",
                "intake",
                "grading",
                "final_packing",
                name="eventtype",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Event type; selects the payload schema (D-014).",
        ),
        sa.Column(
            "instance_no",
            sa.Integer(),
            nullable=False,
            comment="1-based instance of this type on the subject, e.g. harvest round 2 (FR3).",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "draft",
                "submitted",
                "undone",
                "superseded",
                "locked",
                name="eventstatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Lifecycle (FR25, FR59).",
        ),
        sa.Column(
            "current_version_id", sa.Uuid(), nullable=True, comment="Latest version (denormalised for reads)."
        ),
        sa.Column(
            "occurred_on",
            sa.Date(),
            nullable=False,
            comment="Date of the current version, for date-order listing (FR63).",
        ),
        *_timestamps(),
        sa.CheckConstraint("(lot_id IS NULL) <> (batch_id IS NULL)", name=op.f("ck_events_one_subject")),
        sa.ForeignKeyConstraint(["batch_id"], ["batches.id"], name=op.f("fk_events_batch_id_batches")),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_events_fpo_id_fpos")),
        sa.ForeignKeyConstraint(["lot_id"], ["lots.id"], name=op.f("fk_events_lot_id_lots")),
        sa.ForeignKeyConstraint(["plot_id"], ["plots.id"], name=op.f("fk_events_plot_id_plots")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_events")),
    )
    op.create_index(op.f("ix_events_batch_id"), "events", ["batch_id"], unique=False)
    op.create_index(op.f("ix_events_fpo_id"), "events", ["fpo_id"], unique=False)
    op.create_index(op.f("ix_events_lot_id"), "events", ["lot_id"], unique=False)
    op.create_table(
        "grade_computations",
        _id(),
        sa.Column("batch_id", sa.Uuid(), nullable=False, comment="Batch graded."),
        sa.Column("profile_version_id", sa.Uuid(), nullable=False, comment="Profile version applied."),
        sa.Column(
            "computed_grade",
            sa.Text(),
            nullable=True,
            comment="Lowest grade every parameter meets (FR48); null when incomplete.",
        ),
        sa.Column(
            "declared_grade", sa.Text(), nullable=True, comment="Grade the QC officer declared (FR49)."
        ),
        sa.Column("declared_by", sa.Uuid(), nullable=True, comment="Declaring officer."),
        sa.Column(
            "per_parameter",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Per parameter: reading used, grade reached and limit applied.",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "incomplete",
                "ok",
                "declared_above_computed",
                name="gradestatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="incomplete, ok or declared_above_computed (FR49).",
        ),
        sa.Column(
            "lab_certified",
            sa.Boolean(),
            nullable=False,
            comment="A lab reading with a NABL number was used (FR51).",
        ),
        sa.Column("computed_at", sa.DateTime(timezone=True), nullable=False, comment="When the engine ran."),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["batch_id"], ["batches.id"], name=op.f("fk_grade_computations_batch_id_batches")
        ),
        sa.ForeignKeyConstraint(
            ["declared_by"], ["users.id"], name=op.f("fk_grade_computations_declared_by_users")
        ),
        sa.ForeignKeyConstraint(
            ["profile_version_id"],
            ["standards_profile_versions.id"],
            name=op.f("fk_grade_computations_profile_version_id_standards_profile_versions"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_grade_computations")),
    )
    op.create_index(op.f("ix_grade_computations_batch_id"), "grade_computations", ["batch_id"], unique=False)
    op.create_table(
        "page_builds",
        _id(),
        sa.Column("batch_id", sa.Uuid(), nullable=False, comment="Batch the page is for."),
        sa.Column("build_no", sa.Integer(), nullable=False, comment="Build number per batch, 1 upwards."),
        sa.Column(
            "generation",
            sa.Integer(),
            nullable=False,
            comment="Generation marker for cache busting (PRD §5).",
        ),
        sa.Column(
            "snapshot",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Public data rendered, already filtered for privacy (CLAUDE.md §6).",
        ),
        sa.Column(
            "html_key", sa.Text(), nullable=True, comment="Object key of the HTML page in public-pages."
        ),
        sa.Column("json_key", sa.Text(), nullable=True, comment="Object key of the JSON twin of the page."),
        sa.Column("qr_key", sa.Text(), nullable=True, comment="Object key of the QR image (FR12)."),
        sa.Column(
            "status",
            sa.Text(),
            nullable=False,
            comment="Build state set by the build task, e.g. queued, built, failed.",
        ),
        sa.Column(
            "built_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When the page was written (FR17 last updated).",
        ),
        sa.Column(
            "trigger",
            sa.Text(),
            nullable=False,
            comment="What caused the build, e.g. publish, new_event, manual.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(["batch_id"], ["batches.id"], name=op.f("fk_page_builds_batch_id_batches")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_page_builds")),
        sa.UniqueConstraint("batch_id", "build_no", name=op.f("uq_page_builds_batch_id")),
    )
    op.create_table(
        "event_versions",
        _id(),
        sa.Column("event_id", sa.Uuid(), nullable=False, comment="Event this version belongs to."),
        sa.Column(
            "version_no",
            sa.Integer(),
            nullable=False,
            comment="1 for the first version; each new one must be max+1.",
        ),
        sa.Column(
            "payload",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            comment="Typed per event_type (D-014); every quantity is {value, unit} (FR58).",
        ),
        sa.Column(
            "occurred_on", sa.Date(), nullable=False, comment="Date the activity happened (or started)."
        ),
        sa.Column("occurred_end_on", sa.Date(), nullable=True, comment="End date for spans such as drying."),
        sa.Column(
            "device_time",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="Phone clock at capture (three clocks).",
        ),
        sa.Column(
            "gps_time", sa.DateTime(timezone=True), nullable=True, comment="GPS fix time at capture, if any."
        ),
        sa.Column(
            "server_received_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When the server received it.",
        ),
        sa.Column(
            "gps",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="Device position at submission (FR26); checked by FR69.",
        ),
        sa.Column("gps_accuracy_m", sa.Double(), nullable=True, comment="GPS accuracy in metres."),
        sa.Column(
            "entered_by_user_id",
            sa.Uuid(),
            nullable=False,
            comment="Who entered it, taken from the token, never the body.",
        ),
        sa.Column(
            "on_behalf_of_farmer_id",
            sa.Uuid(),
            nullable=True,
            comment="Farmer the entry was made for in assist mode (CLAUDE.md §6).",
        ),
        sa.Column("assist_session_id", sa.Uuid(), nullable=True, comment="Assist session in force, if any."),
        sa.Column(
            "entered_remotely",
            sa.Boolean(),
            nullable=False,
            comment="True when entered away from the plot (e.g. by phone call).",
        ),
        sa.Column("device_id", sa.Uuid(), nullable=True, comment="Capturing device."),
        sa.Column("app_version", sa.Text(), nullable=True, comment="App version that captured it."),
        sa.Column(
            "change_kind",
            sa.Enum(
                "create",
                "correct",
                "undo",
                "system",
                name="changekind",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="create, correct, undo or system (FR25, FR59).",
        ),
        sa.Column(
            "reason_code",
            sa.Text(),
            nullable=True,
            comment="Coded reason, required for correct and undo (FR25).",
        ),
        sa.Column("reason_text", sa.Text(), nullable=True, comment="Free-text reason or comment (FR59)."),
        sa.Column(
            "supersedes_version_id",
            sa.Uuid(),
            nullable=True,
            comment="Version this one replaces, for corrections and undo.",
        ),
        sa.Column(
            "is_system_generated",
            sa.Boolean(),
            nullable=False,
            comment="True when the platform, not a person, made the entry (FR59).",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["assist_session_id"],
            ["assist_sessions.id"],
            name=op.f("fk_event_versions_assist_session_id_assist_sessions"),
        ),
        sa.ForeignKeyConstraint(
            ["device_id"], ["devices.id"], name=op.f("fk_event_versions_device_id_devices")
        ),
        sa.ForeignKeyConstraint(
            ["entered_by_user_id"], ["users.id"], name=op.f("fk_event_versions_entered_by_user_id_users")
        ),
        sa.ForeignKeyConstraint(["event_id"], ["events.id"], name=op.f("fk_event_versions_event_id_events")),
        sa.ForeignKeyConstraint(
            ["on_behalf_of_farmer_id"],
            ["farmers.id"],
            name=op.f("fk_event_versions_on_behalf_of_farmer_id_farmers"),
        ),
        sa.ForeignKeyConstraint(
            ["supersedes_version_id"],
            ["event_versions.id"],
            name=op.f("fk_event_versions_supersedes_version_id_event_versions"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_event_versions")),
        sa.UniqueConstraint("event_id", "version_no", name=op.f("uq_event_versions_event_id")),
    )
    op.create_index(
        "idx_event_versions_gps", "event_versions", ["gps"], unique=False, postgresql_using="gist"
    )
    op.create_index(
        "ix_event_versions_payload", "event_versions", ["payload"], unique=False, postgresql_using="gin"
    )
    op.create_table(
        "evidence_photos",
        _id(),
        sa.Column(
            "event_version_id", sa.Uuid(), nullable=True, comment="Event version it documents, if any."
        ),
        sa.Column("quality_reading_id", sa.Uuid(), nullable=True, comment="Quality reading it documents."),
        sa.Column("bucket", sa.Text(), nullable=False, comment="Object-storage bucket, normally `evidence`."),
        sa.Column(
            "object_key",
            sa.Text(),
            nullable=False,
            comment="evidence/{fpo_id}/{yyyy}/{event_id}/{photo_id}.jpg; never a temporary path (FR61).",
        ),
        sa.Column(
            "s3_version_id", sa.Text(), nullable=True, comment="Object version id stored on confirm (FR61)."
        ),
        sa.Column(
            "content_type",
            sa.Text(),
            nullable=False,
            comment="MIME type bound into the presigned PUT, e.g. image/jpeg.",
        ),
        sa.Column(
            "size_bytes", sa.BigInteger(), nullable=False, comment="Size in bytes declared by the phone."
        ),
        sa.Column(
            "sha256_client",
            sa.Text(),
            nullable=False,
            comment="SHA-256 (hex) computed on the phone, bound to the PUT.",
        ),
        sa.Column(
            "sha256_server", sa.Text(), nullable=True, comment="SHA-256 (hex) recomputed by the verify task."
        ),
        sa.Column(
            "exif_taken_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="EXIF capture time (FR61 metadata check).",
        ),
        sa.Column(
            "exif_gps",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="EXIF GPS position, if present (FR61).",
        ),
        sa.Column(
            "status",
            sa.Enum(
                "pending_upload",
                "uploaded",
                "verified",
                "checksum_mismatch",
                "exif_mismatch",
                name="photostatus",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Upload and verification state.",
        ),
        sa.Column(
            "variants",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="{thumb_url, medium_url, jpeg_url, width, height} written by the variants task.",
        ),
        sa.Column(
            "upload_url_expires_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Expiry of the presigned PUT URL.",
        ),
        sa.Column(
            "uploaded_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When confirm saw the object in storage.",
        ),
        sa.Column(
            "verified_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When checksum and EXIF were verified.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["event_version_id"],
            ["event_versions.id"],
            name=op.f("fk_evidence_photos_event_version_id_event_versions"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_evidence_photos")),
        sa.UniqueConstraint("object_key", name=op.f("uq_evidence_photos_object_key")),
    )
    op.create_index(
        op.f("ix_evidence_photos_event_version_id"), "evidence_photos", ["event_version_id"], unique=False
    )
    op.create_index(
        op.f("ix_evidence_photos_quality_reading_id"), "evidence_photos", ["quality_reading_id"], unique=False
    )
    op.create_table(
        "instruments",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column(
            "kind",
            sa.Enum(
                "moisture_meter",
                "colorimeter",
                "hygrometer",
                "scale",
                name="instrumentkind",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="Instrument kind.",
        ),
        sa.Column("make_model", sa.Text(), nullable=False, comment="Make and model."),
        sa.Column("serial_no", sa.Text(), nullable=False, comment="Serial number."),
        sa.Column("calibrated_on", sa.Date(), nullable=True, comment="Date of last calibration."),
        sa.Column(
            "calibration_due_on",
            sa.Date(),
            nullable=True,
            comment="Calibration due date; after it the instrument cannot be selected (FR50).",
        ),
        sa.Column(
            "calibration_cert_photo_id",
            sa.Uuid(),
            nullable=True,
            comment="Photo of the calibration certificate.",
        ),
        sa.Column("active", sa.Boolean(), nullable=False, comment="False hides it from new readings."),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["calibration_cert_photo_id"],
            ["evidence_photos.id"],
            name=op.f("fk_instruments_calibration_cert_photo_id_evidence_photos"),
        ),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_instruments_fpo_id_fpos")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_instruments")),
    )
    op.create_index(op.f("ix_instruments_fpo_id"), "instruments", ["fpo_id"], unique=False)
    op.create_table(
        "quality_readings",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("lot_id", sa.Uuid(), nullable=True, comment="Lot measured."),
        sa.Column("batch_id", sa.Uuid(), nullable=True, comment="Batch measured."),
        sa.Column(
            "stage",
            sa.Enum(
                "drying_end",
                "intake",
                "grading",
                "storage",
                name="readingstage",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="drying_end, intake, grading or storage (FR43).",
        ),
        sa.Column(
            "parameter_code",
            sa.Text(),
            nullable=False,
            comment="Parameter code from the profile, e.g. moisture.",
        ),
        sa.Column("value", sa.Numeric(), nullable=False, comment="Measured value, in `unit` (FR58)."),
        sa.Column(
            "unit",
            sa.Text(),
            nullable=False,
            comment="Unit of `value`, e.g. %, ASTA; must match the profile.",
        ),
        sa.Column(
            "method_ref", sa.Text(), nullable=True, comment="Test method reference, e.g. ISO 939 (FR42)."
        ),
        sa.Column(
            "source",
            sa.Enum(
                "lab",
                "instrument",
                "visual",
                name="readingsource",
                native_enum=False,
                create_constraint=True,
                length=32,
            ),
            nullable=False,
            comment="lab, instrument or visual (FR42, FR44).",
        ),
        sa.Column(
            "instrument_id", sa.Uuid(), nullable=True, comment="Instrument used, when source is instrument."
        ),
        sa.Column(
            "calibration_due_on_at_time",
            sa.Date(),
            nullable=True,
            comment="The instrument's calibration due date when the reading was taken (FR42).",
        ),
        sa.Column("lab_name", sa.Text(), nullable=True, comment="Laboratory name, for lab results."),
        sa.Column(
            "lab_nabl_no",
            sa.Text(),
            nullable=True,
            comment="NABL accreditation number; required for the Lab-certified badge (FR51).",
        ),
        sa.Column("sample_id", sa.Text(), nullable=True, comment="Sample identifier (FR42)."),
        sa.Column("certificate_photo_id", sa.Uuid(), nullable=True, comment="Photo of the lab certificate."),
        sa.Column(
            "evidence_photo_id",
            sa.Uuid(),
            nullable=True,
            comment="Photo of the instrument display or colour card (FR44).",
        ),
        sa.Column("measured_by_user_id", sa.Uuid(), nullable=False, comment="Who measured."),
        sa.Column("measured_at", sa.DateTime(timezone=True), nullable=False, comment="When it was measured."),
        sa.Column(
            "device_time",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Phone clock at capture, if from a phone.",
        ),
        sa.Column(
            "gps_time", sa.DateTime(timezone=True), nullable=True, comment="GPS fix time at capture, if any."
        ),
        sa.Column(
            "server_received_at",
            sa.DateTime(timezone=True),
            nullable=False,
            comment="When the server received it.",
        ),
        sa.Column(
            "gps",
            Geography("POINT", 4326, spatial_index=False),
            nullable=True,
            comment="Where it was measured (FR42).",
        ),
        sa.Column(
            "reason_code",
            sa.Text(),
            nullable=True,
            comment="Reason for overriding a trail rule, e.g. moisture rose (FR50).",
        ),
        sa.Column(
            "profile_version_id",
            sa.Uuid(),
            nullable=True,
            comment="Profile version the reading was checked against.",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["batch_id"], ["batches.id"], name=op.f("fk_quality_readings_batch_id_batches")
        ),
        sa.ForeignKeyConstraint(
            ["certificate_photo_id"],
            ["evidence_photos.id"],
            name=op.f("fk_quality_readings_certificate_photo_id_evidence_photos"),
        ),
        sa.ForeignKeyConstraint(
            ["evidence_photo_id"],
            ["evidence_photos.id"],
            name=op.f("fk_quality_readings_evidence_photo_id_evidence_photos"),
        ),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_quality_readings_fpo_id_fpos")),
        sa.ForeignKeyConstraint(
            ["instrument_id"], ["instruments.id"], name=op.f("fk_quality_readings_instrument_id_instruments")
        ),
        sa.ForeignKeyConstraint(["lot_id"], ["lots.id"], name=op.f("fk_quality_readings_lot_id_lots")),
        sa.ForeignKeyConstraint(
            ["measured_by_user_id"], ["users.id"], name=op.f("fk_quality_readings_measured_by_user_id_users")
        ),
        sa.ForeignKeyConstraint(
            ["profile_version_id"],
            ["standards_profile_versions.id"],
            name=op.f("fk_quality_readings_profile_version_id_standards_profile_versions"),
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_quality_readings")),
    )
    op.create_index(op.f("ix_quality_readings_batch_id"), "quality_readings", ["batch_id"], unique=False)
    op.create_index(op.f("ix_quality_readings_fpo_id"), "quality_readings", ["fpo_id"], unique=False)
    op.create_index(op.f("ix_quality_readings_lot_id"), "quality_readings", ["lot_id"], unique=False)
    op.create_table(
        "lot_intakes",
        _id(),
        sa.Column(
            "fpo_id",
            sa.Uuid(),
            nullable=False,
            comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
        ),
        sa.Column("lot_id", sa.Uuid(), nullable=False, comment="Lot received."),
        sa.Column("processor_id", sa.Uuid(), nullable=False, comment="Receiving processor."),
        sa.Column("sale_date", sa.Date(), nullable=False, comment="Date of sale to the processor."),
        sa.Column(
            "received_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=False,
            comment="Quantity received in kg.",
        ),
        sa.Column(
            "price_per_kg",
            sa.Numeric(precision=12, scale=3),
            nullable=True,
            comment="Price in INR per kg; optional, switched by field configuration (D-017).",
        ),
        sa.Column(
            "intake_moisture_reading_id",
            sa.Uuid(),
            nullable=True,
            comment="Moisture reading taken at intake (FR43).",
        ),
        sa.Column("accepted_by_user_id", sa.Uuid(), nullable=False, comment="Who accepted it."),
        sa.Column(
            "reconciliation",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Harvested ≥ packed ≥ received ≥ used chain (core.schemas.Reconciliation, FR60).",
        ),
        sa.Column(
            "yield_check",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
            comment="Yield versus ceiling with margins (core.schemas.YieldCheck, FR68).",
        ),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["accepted_by_user_id"], ["users.id"], name=op.f("fk_lot_intakes_accepted_by_user_id_users")
        ),
        sa.ForeignKeyConstraint(["fpo_id"], ["fpos.id"], name=op.f("fk_lot_intakes_fpo_id_fpos")),
        sa.ForeignKeyConstraint(
            ["intake_moisture_reading_id"],
            ["quality_readings.id"],
            name=op.f("fk_lot_intakes_intake_moisture_reading_id_quality_readings"),
        ),
        sa.ForeignKeyConstraint(["lot_id"], ["lots.id"], name=op.f("fk_lot_intakes_lot_id_lots")),
        sa.ForeignKeyConstraint(
            ["processor_id"], ["processors.id"], name=op.f("fk_lot_intakes_processor_id_processors")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_lot_intakes")),
    )
    op.create_index(op.f("ix_lot_intakes_fpo_id"), "lot_intakes", ["fpo_id"], unique=False)
    op.create_index(op.f("ix_lot_intakes_lot_id"), "lot_intakes", ["lot_id"], unique=False)
    op.create_foreign_key(
        op.f("fk_events_current_version_id_event_versions"),
        "events",
        "event_versions",
        ["current_version_id"],
        ["id"],
        use_alter=True,
    )
    op.create_foreign_key(
        op.f("fk_evidence_photos_quality_reading_id_quality_readings"),
        "evidence_photos",
        "quality_readings",
        ["quality_reading_id"],
        ["id"],
        use_alter=True,
    )
    op.execute("CREATE SEQUENCE reference_version_seq")
    op.execute(FORBID_CHANGE)
    for table, allowed in APPEND_ONLY.items():
        args = ", ".join(f"'{column}'" for column in allowed)
        op.execute(
            f"CREATE TRIGGER {table}_append_only BEFORE UPDATE OR DELETE ON {table} "
            f"FOR EACH ROW EXECUTE FUNCTION forbid_change({args})"
        )
    op.execute(BUMP_REFERENCE_VERSION)
    for table, part in REFERENCE_PARTS.items():
        op.execute(
            f"CREATE TRIGGER {table}_reference_version AFTER INSERT OR UPDATE OR DELETE ON {table} "
            f"FOR EACH ROW EXECUTE FUNCTION bump_reference_version('{part}')"
        )


def downgrade() -> None:
    """Drop everything `upgrade` created except the shared postgis extension.

    Side effects:
        Drops all 39 tables (and with them their triggers and data), both functions and the sequence.
    """
    for name, table in LATE_FOREIGN_KEYS:
        op.drop_constraint(name, table, type_="foreignkey")
    for table in DROP_ORDER:
        op.drop_table(table)
    op.execute("DROP FUNCTION bump_reference_version()")
    op.execute("DROP FUNCTION forbid_change()")
    op.execute("DROP SEQUENCE reference_version_seq")


# Reverse dependency order of the tables created above.
DROP_ORDER = (
    "lot_intakes",
    "quality_readings",
    "instruments",
    "evidence_photos",
    "event_versions",
    "page_builds",
    "grade_computations",
    "events",
    "batch_shares",
    "batch_approvals",
    "plot_revisions",
    "lots",
    "id_documents",
    "batches",
    "standards_profile_versions",
    "plots",
    "consent_records",
    "assist_sessions",
    "sync_metrics",
    "sync_cursors",
    "standards_profiles",
    "farmers",
    "reference_versions",
    "producer_groups",
    "processors",
    "notifications",
    "memberships",
    "inputs_master",
    "gi_region_versions",
    "flags",
    "devices",
    "crops",
    "villages",
    "users",
    "scan_events",
    "otp_challenges",
    "gi_tags",
    "fpos",
    "audit_log",
)
