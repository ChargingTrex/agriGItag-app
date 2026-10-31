"""lots_batches tables: lots, processor intakes, batches (super-lots), lot shares and approval gates.

Serves: PRD §5 (Component Lot, Super Lot / Batch), Dataflow Stages 4–9 and §4 (approval gates), FR9–FR11,
FR29 (GI re-validation at merge), FR56 (practice tags), FR57, FR58, FR60 (reconciliation and shares),
FR62 (pack and best-before dates), FR68 (yield check).
Callers: lots_batches service and router (B09), rules_flags (B08), quality grading (B05), publishing and
reporting (B10) through `models` (D-004), alembic/env.py, migrations 0001 and 0004 (intake corrections).
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from sqlalchemy import CheckConstraint, ColumnElement, ForeignKey, Numeric, func, select
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, TenantScoped
from agritrace.core.enums import ApprovalStage, BatchStatus, LotStatus


class Lot(Audited, IdTimestamps, TenantScoped, Base):
    """One farmer's harvest of one crop from one plot in one season (PRD §5 Component Lot, Stages 4–7)."""

    __tablename__ = "lots"

    farmer_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("farmers.id"), index=True, comment="Grower.")
    plot_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("plots.id"), index=True, comment="Plot harvested.")
    crop_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("crops.id"), comment="Crop.")
    season_label: Mapped[str] = mapped_column(comment="Season, e.g. 2025-26 Rabi.")
    code: Mapped[str] = mapped_column(unique=True, comment="Lot code LOT + 8 hex, e.g. LOT0EF81415.")
    status: Mapped[LotStatus] = mapped_column(default=LotStatus.OPEN, comment="Lot lifecycle.")
    practice_tags: Mapped[dict[str, Any] | None] = mapped_column(
        comment="{declared, derived, contradiction} (core.schemas.PracticeTags, FR56)."
    )
    harvested_kg: Mapped[Decimal | None] = mapped_column(comment="Sum of harvest quantities in kg (FR57).")
    packed_kg: Mapped[Decimal | None] = mapped_column(comment="On-farm packed quantity in kg (Stage 6).")
    ready_at: Mapped[datetime | None] = mapped_column(comment="When the lot passed the ready-for-sale gate.")
    gi_eligible: Mapped[bool] = mapped_column(
        default=False, comment="True when the lot may join a GI-labelled batch (FR28, FR29, FR68)."
    )
    gi_hold_reason: Mapped[str | None] = mapped_column(
        comment="Why the lot is held out of GI batches, if so."
    )


class LotIntake(Audited, IdTimestamps, TenantScoped, Base):
    """A processor receiving a lot at Sale to Processor (Stage 7, FR9, FR60); client-made `id` (D-005)."""

    __tablename__ = "lot_intakes"

    lot_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("lots.id"), index=True, comment="Lot received.")
    processor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("processors.id"), comment="Receiving processor."
    )
    sale_date: Mapped[date] = mapped_column(comment="Date of sale to the processor.")
    received_kg: Mapped[Decimal] = mapped_column(comment="Quantity received in kg.")
    price_per_kg: Mapped[Decimal | None] = mapped_column(
        comment="Price in INR per kg; optional, switched by field configuration (D-017)."
    )
    intake_moisture_reading_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("quality_readings.id"), comment="Moisture reading taken at intake (FR43)."
    )
    accepted_by_user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="Who accepted it.")
    reconciliation: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Harvested ≥ packed ≥ received ≥ used chain (core.schemas.Reconciliation, FR60)."
    )
    yield_check: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Yield versus ceiling with margins (core.schemas.YieldCheck, FR68)."
    )
    supersedes_intake_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("lot_intakes.id"),
        unique=True,
        comment="Intake this row corrects (append-only, D-033); each intake is corrected at most once.",
    )
    correction_reason: Mapped[str | None] = mapped_column(
        comment="Why the superseded intake was wrong; required with `supersedes_intake_id`."
    )


def current_intake() -> ColumnElement[bool]:
    """Filter `lot_intakes` to the rows no correction has superseded (a lot's current intake, D-033).

    Returns:
        A WHERE clause for `select(LotIntake...)`; callers summing received kg must use it.
    """
    superseded = select(LotIntake.supersedes_intake_id).where(LotIntake.supersedes_intake_id.is_not(None))
    return LotIntake.id.not_in(superseded)


class Batch(Audited, IdTimestamps, TenantScoped, Base):
    """A super-lot of component lots at one processor, identified by its batch code (PRD §5, Stages 7–10)."""

    __tablename__ = "batches"

    crop_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("crops.id"), comment="Crop of every lot in it.")
    processor_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("processors.id"), comment="Processor.")
    code: Mapped[str] = mapped_column(
        unique=True, comment="12-char Crockford base32 batch code, e.g. FGP8T4033HM7 (QR, public URL)."
    )
    superlot_code: Mapped[str | None] = mapped_column(
        unique=True, comment="Super-lot code COMBO_LOT_ + 8 hex, e.g. COMBO_LOT_6C1DCCFE."
    )
    status: Mapped[BatchStatus] = mapped_column(default=BatchStatus.CREATED, comment="Batch lifecycle.")
    gi_label_requested: Mapped[bool] = mapped_column(default=False, comment="Admin asked to label it as GI.")
    gi_verified: Mapped[bool] = mapped_column(
        default=False, comment="Every component lot passed the GI region check (FR29, FR30)."
    )
    gi_block_reasons: Mapped[list[Any] | None] = mapped_column(
        JSONB, comment="Why GI labelling is blocked: list of {lot_id, reason} (FR29)."
    )
    total_received_kg: Mapped[Decimal | None] = mapped_column(
        comment="Sum of intake quantities in kg (FR10)."
    )
    graded_kg: Mapped[Decimal | None] = mapped_column(comment="Quantity after grading in kg (Stage 8).")
    packed_kg: Mapped[Decimal | None] = mapped_column(comment="Quantity in final packs in kg (Stage 9).")
    computed_grade: Mapped[str | None] = mapped_column(comment="Grade computed from readings (FR48).")
    standards_profile_version_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("standards_profile_versions.id"), comment="Profile version graded against (FR47)."
    )
    pack_date: Mapped[date | None] = mapped_column(comment="Pack date printed on the label (FR62).")
    best_before_date: Mapped[date | None] = mapped_column(comment="Best-before date on the label (FR62).")
    current_build_no: Mapped[int] = mapped_column(default=0, comment="Latest public page build (FR17).")
    created_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="Admin who created it.")
    second_signoff_by: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Second approver where a gate needs two people."
    )


class BatchShare(Audited, Base):
    """How much of a batch each component lot contributed, shown on the public page (FR60).

    The shares of one batch must sum to 100 ± 0.01 %; that cross-row rule is checked by the B09 service.
    """

    __tablename__ = "batch_shares"
    __table_args__ = (CheckConstraint("share_pct >= 0 AND share_pct <= 100", name="share_pct_range"),)

    batch_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("batches.id"), primary_key=True, comment="Batch.")
    lot_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("lots.id"), primary_key=True, comment="Component lot."
    )
    kg_contributed: Mapped[Decimal] = mapped_column(comment="Kilograms of the lot in the batch.")
    share_pct: Mapped[Decimal] = mapped_column(Numeric(6, 3), comment="Percent of the batch, 0–100.")
    farmer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("farmers.id"), index=True, comment="Grower of the lot (denormalised for the public page)."
    )
    # Composite key, so this table takes the timestamps but not the id of `IdTimestamps`.
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), comment="When the row was inserted (database clock, UTC)."
    )
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(),
        onupdate=func.now(),
        comment="When the row was last changed (database clock, UTC).",
    )


class BatchApproval(Audited, IdTimestamps, Base):
    """A human decision at a batch gate: intake, grading, final packing or publish (Dataflow §4, FR49)."""

    __tablename__ = "batch_approvals"

    batch_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("batches.id"), index=True, comment="Batch.")
    stage: Mapped[ApprovalStage] = mapped_column(comment="Gate approved.")
    approved_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="Approver.")
    approved_at: Mapped[datetime] = mapped_column(comment="When it was approved.")
    blocked_reasons: Mapped[list[Any] | None] = mapped_column(
        JSONB, comment="Open flags or missing evidence at the time, if any were overridden or pending."
    )
