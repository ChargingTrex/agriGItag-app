"""quality tables: standards profiles and versions, instruments, quality readings, grade computations.

Serves: PRD §5 (Quality Reading, Standards Profile, Instrument), PRD §6.8 FR42–FR51, FR68 (yield ceiling
lives in the profile), Dataflow Stages 5, 7, 8, D-015 (versioned JSON profiles, one grade engine).
Callers: quality service and router (B05), rules_flags (B08), lots_batches (B09), publishing (B10),
events sync bundle `standards` part (B06) through `models` (D-004), alembic/env.py, migration 0001.
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from geoalchemy2 import Geography
from sqlalchemy import ForeignKey, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, SpatialValue, TenantScoped
from agritrace.core.enums import (
    GradeStatus,
    InstrumentKind,
    ProfileVersionStatus,
    ReadingSource,
    ReadingStage,
    StandardsScheme,
)


class StandardsProfile(Audited, IdTimestamps, Base):
    """A grading standard for a crop, e.g. AGMARK Dry Chillies Schedule IV (FR47, D-015)."""

    __tablename__ = "standards_profiles"

    crop_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("crops.id"), index=True, comment="Crop it grades.")
    scheme: Mapped[StandardsScheme] = mapped_column(comment="agmark, iso, fssai or custom.")
    name: Mapped[str] = mapped_column(comment="Profile name.")
    standard_ref: Mapped[str] = mapped_column(comment="Standard document reference.")
    owner_user_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Compliance owner (super-admin)."
    )


class StandardsProfileVersion(Audited, IdTimestamps, Base):
    """One published edition of a profile's rules JSON (FR47–FR50, FR68, D-015, backend-design.md §4)."""

    __tablename__ = "standards_profile_versions"
    __table_args__ = (UniqueConstraint("profile_id", "version_no"),)

    profile_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("standards_profiles.id"), comment="Profile.")
    version_no: Mapped[int] = mapped_column(comment="Version number, 1 upwards.")
    edition: Mapped[str] = mapped_column(comment="Edition of the standard cited (FR47, FR51).")
    clause_ref: Mapped[str] = mapped_column(comment="Clause or schedule cited (FR47).")
    rules: Mapped[dict[str, Any]] = mapped_column(
        comment="Parameters, limits, gates, trail rules and yield ceiling (StandardsProfileRules, §4)."
    )
    status: Mapped[ProfileVersionStatus] = mapped_column(
        default=ProfileVersionStatus.DRAFT, comment="draft, published or retired."
    )
    published_at: Mapped[datetime | None] = mapped_column(comment="When it was published.")
    published_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), comment="Publisher.")


class Instrument(Audited, IdTimestamps, TenantScoped, Base):
    """A registered moisture meter, colorimeter, hygrometer or scale with its calibration (FR42, FR50)."""

    __tablename__ = "instruments"

    kind: Mapped[InstrumentKind] = mapped_column(comment="Instrument kind.")
    make_model: Mapped[str] = mapped_column(comment="Make and model.")
    serial_no: Mapped[str] = mapped_column(comment="Serial number.")
    calibrated_on: Mapped[date | None] = mapped_column(comment="Date of last calibration.")
    calibration_due_on: Mapped[date | None] = mapped_column(
        comment="Calibration due date; after it the instrument cannot be selected (FR50)."
    )
    calibration_cert_photo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("evidence_photos.id"), comment="Photo of the calibration certificate."
    )
    active: Mapped[bool] = mapped_column(default=True, comment="False hides it from new readings.")


class QualityReading(Audited, IdTimestamps, TenantScoped, Base):
    """One measured parameter of a lot or batch at a stage, with its evidence (FR42–FR46, FR50).

    PRD §5 Quality Reading. `id` is client-generated (D-005).
    """

    __tablename__ = "quality_readings"

    lot_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("lots.id"), index=True, comment="Lot measured."
    )
    batch_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("batches.id"), index=True, comment="Batch measured."
    )
    stage: Mapped[ReadingStage] = mapped_column(comment="drying_end, intake, grading or storage (FR43).")
    parameter_code: Mapped[str] = mapped_column(comment="Parameter code from the profile, e.g. moisture.")
    value: Mapped[Decimal] = mapped_column(Numeric, comment="Measured value, in `unit` (FR58).")
    unit: Mapped[str] = mapped_column(comment="Unit of `value`, e.g. %, ASTA; must match the profile.")
    method_ref: Mapped[str | None] = mapped_column(comment="Test method reference, e.g. ISO 939 (FR42).")
    source: Mapped[ReadingSource] = mapped_column(comment="lab, instrument or visual (FR42, FR44).")
    instrument_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("instruments.id"), comment="Instrument used, when source is instrument."
    )
    calibration_due_on_at_time: Mapped[date | None] = mapped_column(
        comment="The instrument's calibration due date when the reading was taken (FR42)."
    )
    lab_name: Mapped[str | None] = mapped_column(comment="Laboratory name, for lab results.")
    lab_nabl_no: Mapped[str | None] = mapped_column(
        comment="NABL accreditation number; required for the Lab-certified badge (FR51)."
    )
    sample_id: Mapped[str | None] = mapped_column(comment="Sample identifier (FR42).")
    certificate_photo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("evidence_photos.id"), comment="Photo of the lab certificate."
    )
    evidence_photo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("evidence_photos.id"), comment="Photo of the instrument display or colour card (FR44)."
    )
    measured_by_user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="Who measured.")
    measured_at: Mapped[datetime] = mapped_column(comment="When it was measured.")
    device_time: Mapped[datetime | None] = mapped_column(comment="Phone clock at capture, if from a phone.")
    gps_time: Mapped[datetime | None] = mapped_column(comment="GPS fix time at capture, if any.")
    server_received_at: Mapped[datetime] = mapped_column(comment="When the server received it.")
    gps: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326, spatial_index=False), comment="Where it was measured (FR42)."
    )
    reason_code: Mapped[str | None] = mapped_column(
        comment="Reason for overriding a trail rule, e.g. moisture rose (FR50)."
    )
    profile_version_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("standards_profile_versions.id"),
        comment="Profile version the reading was checked against.",
    )


class GradeComputation(IdTimestamps, Base):
    """The grade a batch qualifies for, computed from readings, against the declared grade (FR48, FR49)."""

    __tablename__ = "grade_computations"

    batch_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("batches.id"), index=True, comment="Batch graded.")
    profile_version_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("standards_profile_versions.id"), comment="Profile version applied."
    )
    computed_grade: Mapped[str | None] = mapped_column(
        comment="Lowest grade every parameter meets (FR48); null when incomplete."
    )
    declared_grade: Mapped[str | None] = mapped_column(comment="Grade the QC officer declared (FR49).")
    declared_by: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Declaring officer."
    )
    per_parameter: Mapped[dict[str, Any]] = mapped_column(
        comment="Per parameter: reading used, grade reached and limit applied."
    )
    status: Mapped[GradeStatus] = mapped_column(comment="incomplete, ok or declared_above_computed (FR49).")
    lab_certified: Mapped[bool] = mapped_column(
        default=False, comment="A lab reading with a NABL number was used (FR51)."
    )
    computed_at: Mapped[datetime] = mapped_column(comment="When the engine ran.")
