"""Request and response models of the lots_batches routes: lots, intakes, batches and their gates.

Serves: PRD §5 (Component Lot, Super Lot / Batch), Dataflow Stages 4–9 and §4 (approval gates), FR9–FR11,
FR29, FR56, FR58 (every quantity carries its unit), FR60, FR62, D-005 (client ids), D-020 (/v1, additive).
Callers: `lots_batches.router` and `lots_batches.service`; the OpenAPI document (generated clients, D-003).
Other modules may not import this file (D-004).
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Annotated, Self

from pydantic import AfterValidator, BaseModel, Field, model_validator

from agritrace.core.enums import (
    BatchStatus,
    FlagStatus,
    FlagSubject,
    LotStatus,
    PracticeTag,
    Severity,
)
from agritrace.core.schemas import PracticeTags, Quantity, Reconciliation


def _must_be_kg(q: Quantity) -> Quantity:
    """Refuse a batch or lot quantity that is not in kilograms.

    Args:
        q: the quantity.

    Returns:
        The same quantity.

    Raises:
        ValueError: the unit is not `kg` (FastAPI answers 422 `validation_error`).
    """
    # shortcut: kg only (all pilot forms weigh in kg); add g/quintal conversion when a form offers them.
    if q.unit != "kg":
        raise ValueError("unit must be kg")
    return q


Kg = Annotated[Quantity, AfterValidator(_must_be_kg)]


class LotIn(BaseModel):
    """Open a season lot on a plot (Stage 4); fields follow `config/fields/lot.yaml` (D-017)."""

    client_id: uuid.UUID = Field(description="UUIDv7 made on the device; the lot id and idempotency key.")
    plot_id: uuid.UUID = Field(description="Plot the crop grows on; a farmer may only use their own.")
    crop_id: uuid.UUID = Field(description="Crop grown.")
    season_label: str | None = Field(None, max_length=40, description="Season, e.g. `2025-26 Rabi`.")
    practice_tags_declared: list[PracticeTag] = Field(
        default_factory=list, description="Farming practice the farmer declares (FR56), e.g. `[ipm]`."
    )


class LotOut(BaseModel):
    """A component lot with its lifecycle state and GI eligibility."""

    id: uuid.UUID = Field(description="Lot id.")
    code: str = Field(description="Lot code `LOT` + 8 hex, e.g. `LOT0EF81415`.")
    farmer_id: uuid.UUID = Field(description="Grower.")
    plot_id: uuid.UUID = Field(description="Plot harvested.")
    crop_id: uuid.UUID = Field(description="Crop.")
    season_label: str = Field(description="Season label; empty when the tenant does not capture it.")
    status: LotStatus = Field(description="open → drying → ready_for_sale → received → batched → closed.")
    practice_tags: PracticeTags | None = Field(None, description="Declared and derived tags (FR56).")
    harvested: Quantity | None = Field(None, description="Harvested quantity in kg, filled at intake.")
    packed: Quantity | None = Field(None, description="On-farm packed quantity in kg, filled at intake.")
    ready_at: datetime | None = Field(None, description="When the lot passed the ready-for-sale gate.")
    gi_eligible: bool = Field(description="False while a hold keeps the lot out of GI batches (FR68, FR70).")
    gi_hold_reason: str | None = Field(None, description="Why the lot is held out of GI batches.")


class FlagBrief(BaseModel):
    """An active rule flag found by the gate checks of this request (B08 `run_gate_checks`)."""

    id: uuid.UUID = Field(description="Flag id; details at `GET /v1/flags/{id}`.")
    subject_type: FlagSubject = Field(description="Kind of row flagged.")
    subject_id: uuid.UUID = Field(description="Id of the flagged row.")
    rule_code: str = Field(description="Rule, e.g. `quantity_mismatch`.")
    severity: Severity = Field(description="info, warn, or hold (a hold blocks approval and GI labelling).")
    status: FlagStatus = Field(description="open or escalated.")


class IntakeIn(BaseModel):
    """A processor receives a ready lot (Stage 7 Sale to Processor, FR9)."""

    client_id: uuid.UUID = Field(description="UUIDv7 made by the client; intake id and idempotency key.")
    lot_id: uuid.UUID = Field(description="Lot received; must be `ready_for_sale`.")
    processor_id: uuid.UUID = Field(description="Receiving processor.")
    sale_date: date = Field(description="Date of sale, YYYY-MM-DD.")
    received: Kg = Field(description="Quantity received, unit `kg`.")
    price_per_kg: Decimal | None = Field(None, ge=0, description="Price in INR per kg (optional, D-017).")
    intake_moisture_reading_id: uuid.UUID | None = Field(
        None, description="Moisture reading of this lot taken at the gate (`POST /v1/quality-readings`)."
    )


class IntakeOut(BaseModel):
    """A stored intake with its quantity chain and the flags the lot rules raised."""

    id: uuid.UUID = Field(description="Intake id (the client id).")
    lot_id: uuid.UUID = Field(description="Lot received.")
    processor_id: uuid.UUID = Field(description="Receiving processor.")
    sale_date: date = Field(description="Date of sale.")
    received: Quantity = Field(description="Quantity received in kg.")
    price_per_kg: Decimal | None = Field(None, description="Price in INR per kg.")
    intake_moisture_reading_id: uuid.UUID | None = Field(None, description="Intake moisture reading.")
    accepted_by_user_id: uuid.UUID = Field(description="Admin who accepted the lot.")
    reconciliation: Reconciliation | None = Field(
        None, description="Harvested ≥ packed ≥ received at the time of intake (FR60)."
    )
    flags: list[FlagBrief] = Field(
        default_factory=list, description="Active flags on the lot after the intake; empty on a resend."
    )


class BatchIn(BaseModel):
    """Merge received lots into a super-lot / batch (Stage 7, FR9, FR29)."""

    processor_id: uuid.UUID = Field(description="Processor that received every lot.")
    gi_label_requested: bool = Field(False, description="Ask to label the batch as GI (re-checked, FR29).")
    lot_ids: list[uuid.UUID] = Field(
        min_length=1,
        max_length=200,
        description="`received` lots of the caller's FPO, no repeats; each brings all it delivered here.",
    )

    @model_validator(mode="after")
    def _distinct_lots(self) -> Self:
        """Refuse a lot listed twice.

        Returns:
            The model.

        Raises:
            ValueError: a lot id repeats (422 `validation_error`).
        """
        if len(set(self.lot_ids)) != len(self.lot_ids):
            raise ValueError("a lot may appear only once")
        return self


class ShareOut(BaseModel):
    """A lot's share of a batch (FR60)."""

    lot_id: uuid.UUID = Field(description="Component lot.")
    farmer_id: uuid.UUID = Field(description="Grower of the lot.")
    contributed: Quantity = Field(description="Kilograms of the lot in the batch (its intake kg).")
    share_pct: Decimal = Field(description="Percent of the batch, 3 decimals; the shares sum to 100.000.")


class GiBlockReason(BaseModel):
    """Why a batch may not carry the GI label (FR29); it can still be traced as a normal batch."""

    lot_id: uuid.UUID | None = Field(None, description="Lot concerned; null for a batch-wide reason.")
    reason: str = Field(
        description="`crop_has_no_gi_tag`, `gi_region_missing`, `lot_on_hold`, `plot_location_<status>`, "
        "`plot_outside_gi_region` or `hold_flag`."
    )
    detail: str | None = Field(None, description="Hold reason, rule code or distance, when known.")


class BatchOut(BaseModel):
    """A batch with its shares, gate state and GI verdict."""

    id: uuid.UUID = Field(description="Batch id.")
    code: str = Field(description="12-char batch code, e.g. `FGP8T4033HM7` (QR, public URL).")
    superlot_code: str | None = Field(None, description="Super-lot code, e.g. `COMBO_LOT_6C1DCCFE`.")
    crop_id: uuid.UUID = Field(description="Crop of every component lot.")
    processor_id: uuid.UUID = Field(description="Processor.")
    status: BatchStatus = Field(description="created → graded → packed → published.")
    gi_label_requested: bool = Field(description="The admin asked for the GI label.")
    gi_verified: bool = Field(description="GI label requested and every component lot passed the re-check.")
    gi_block_reasons: list[GiBlockReason] = Field(description="Why GI is blocked; empty when verified.")
    total_received: Quantity | None = Field(None, description="Sum of the lots' intake kg (FR10).")
    graded: Quantity | None = Field(None, description="Graded quantity in kg (ceiling for packing).")
    packed: Quantity | None = Field(None, description="Quantity in final packs in kg.")
    computed_grade: str | None = Field(None, description="Grade approved at the grading gate (FR48).")
    standards_profile_version_id: uuid.UUID | None = Field(None, description="Profile version graded on.")
    pack_date: date | None = Field(None, description="Pack date for the label (FR62).")
    best_before_date: date | None = Field(None, description="Best-before date for the label (FR62).")
    current_build_no: int = Field(description="Latest public page build number; 0 before publishing.")
    created_by: uuid.UUID = Field(description="Admin who created the batch.")
    second_signoff_required: bool = Field(
        description="Total above the FPO's `second_signoff_threshold_kg` (Dataflow §4 gate 2)."
    )
    second_signoff_by: uuid.UUID | None = Field(None, description="Second admin who signed it off.")
    shares: list[ShareOut] = Field(description="Component lots and their shares.")
    flags: list[FlagBrief] = Field(
        default_factory=list,
        description="Active flags found by this request's gate checks (POST routes); empty on GET.",
    )


class GradingApproveIn(BaseModel):
    """FPO admin approves the latest grade computation (Stage 8, FR49)."""

    graded: Kg = Field(description="Graded quantity in kg; becomes the ceiling for final packing.")


class FinalPackingIn(BaseModel):
    """FPO admin signs off final (retail) packing (Stage 9, FR62)."""

    packed: Kg = Field(description="Quantity in final packs in kg; at most the graded quantity.")
    pack_date: date = Field(description="Pack date printed on the label.")
    best_before_date: date = Field(description="Best-before date printed on the label.")

    @model_validator(mode="after")
    def _dates_in_order(self) -> Self:
        """Refuse a best-before date before the pack date.

        Returns:
            The model.

        Raises:
            ValueError: best before is earlier than the pack date (422 `validation_error`).
        """
        if self.best_before_date < self.pack_date:
            raise ValueError("best_before_date must not be before pack_date")
        return self


class PublishOut(BaseModel):
    """A queued public page build (D-007); the worker writes the page."""

    batch_id: uuid.UUID = Field(description="Batch published.")
    code: str = Field(description="Batch code (QR and public page).")
    build_no: int = Field(description="Build number of this publish.")
    page_build_id: uuid.UUID = Field(description="`page_builds` row; `GET /v1/batches/{id}/builds` (B10).")
    status: str = Field(description="`queued` until the build task writes the page.")
