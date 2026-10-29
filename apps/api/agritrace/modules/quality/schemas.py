"""Quality schemas: the Standards Profile rules JSON (`StandardsProfileRules`) and the API shapes.

Serves: PRD §6.8 FR42–FR52 (readings, profiles, grade computation, plausibility), backend-design.md §4
(profile JSON, binding), Dataflow Stages 5 (drying-end moisture, lot gate), 7 (intake moisture, yield
ceiling), 8 (grading readings, declared vs computed grade), D-015 (versioned profile JSON).
Callers: `quality.grade_engine` (rules model), `quality.service`, `quality.router`, `quality.profiles.loader`,
tests/unit/test_quality_*.py, tests/unit/test_grade_engine.py, tests/integration/test_quality.py.
Other modules never import this file (D-004); they get these objects back from `quality.service`.
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Annotated, Literal, Self

from pydantic import AwareDatetime, BaseModel, ConfigDict, Field, PlainSerializer, model_validator

from agritrace.core.enums import (
    GradeStatus,
    InstrumentKind,
    ProfileVersionStatus,
    ReadingSource,
    ReadingStage,
    StandardsScheme,
)
from agritrace.core.schemas import GeoPoint, SignedQuantity

# Marker used in the seed profile where a value must be copied from a purchased or official copy of the
# standard before go-live (PRD §6.8 seed table, PRD §11 "Access to standards text").
LOAD_FROM_STANDARD = "LOAD_FROM_STANDARD"

# Exact decimal in Python (no float rounding at a limit like 10.0), plain JSON number in the stored rules and
# the phone bundle, so the Dart preview (D-006) reads numbers, not strings.
JsonNumber = Annotated[Decimal, PlainSerializer(float, return_type=float, when_used="json")]

# ---------------------------------------------------------------------------------------------------------
# Profile rules JSON (standards_profile_versions.rules), backend-design.md §4
# ---------------------------------------------------------------------------------------------------------


class _Strict(BaseModel):
    """Base of the profile JSON models: unknown keys are rejected so a typo never silently drops a limit."""

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class Range(_Strict):
    """An inclusive numeric interval; a missing bound is open (no limit on that side)."""

    min: JsonNumber | None = Field(
        None, description="Lowest allowed value, inclusive; null means no lower bound."
    )
    max: JsonNumber | None = Field(
        None, description="Highest allowed value, inclusive; null means no upper bound."
    )

    @model_validator(mode="after")
    def _ordered(self) -> Self:
        """Check that `min` is not above `max`.

        Returns:
            The validated range.

        Raises:
            ValueError: `min` > `max`.
        """
        if self.min is not None and self.max is not None and self.min > self.max:
            raise ValueError(f"min {self.min} is above max {self.max}")
        return self

    def holds(self, value: Decimal) -> bool:
        """Tell whether `value` lies inside the range.

        Args:
            value: the measured value.

        Returns:
            True when `min <= value <= max` for the bounds that are set.
        """
        return (self.min is None or value >= self.min) and (self.max is None or value <= self.max)


class StandardRef(_Strict):
    """The published standard a profile version cites (FR47, FR51: shown on the public page with edition)."""

    name: str = Field(min_length=1, description="Full name of the standard, e.g. AGMARK Dry Chillies rules.")
    schedule: str | None = Field(None, description="Schedule or part of the standard, e.g. `IV`.")
    edition: str = Field(
        min_length=1, description=f"Edition or year cited; `{LOAD_FROM_STANDARD}` until copied from the text."
    )
    clause_ref: str = Field(
        min_length=1, description=f"Clause cited; `{LOAD_FROM_STANDARD}` until copied from the standard text."
    )


class Parameter(_Strict):
    """One quality parameter of a profile: unit, method, where it is captured and its limit per grade."""

    code: str = Field(
        pattern=r"^[a-z][a-z0-9_]*$", description="Stable snake_case code readings use, e.g. `moisture`."
    )
    name_en: str | None = Field(None, description="English label for forms and the public page.")
    name_local: str | None = Field(None, description="Label in the local script (Tamil for the pilot).")
    unit: str = Field(min_length=1, max_length=16, description="Unit every reading must carry, e.g. `%`.")
    method_ref: str | None = Field(None, description="Test method the standard prescribes (FR42).")
    required: bool = Field(
        False, description="A grading reading is needed for a complete grade (only when `limits` is set)."
    )
    grading_stage: ReadingStage = Field(
        ReadingStage.GRADING, description="Stage whose latest reading is used to compute the grade."
    )
    capture_stages: list[ReadingStage] = Field(
        default_factory=lambda: [ReadingStage.GRADING],
        min_length=1,
        description="Stages where this parameter is captured (FR43 moisture: drying end, intake, grading).",
    )
    limits: dict[str, Range] | None = Field(
        None,
        description=(
            "Interval the value must lie in to reach each grade, keyed by grade name; when set, every grade "
            "needs a key (`{}` means no constraint for that grade). Null: not graded on this parameter "
            "(see `status`)."
        ),
    )
    plausible: Range | None = Field(
        None, description="Physically sensible range; readings outside it are rejected at entry (FR50)."
    )
    sources_allowed: list[ReadingSource] = Field(
        default_factory=lambda: list(ReadingSource),
        min_length=1,
        description="Measurement sources accepted at entry for this parameter (FR42, FR44).",
    )
    max_grade_for_source: dict[ReadingSource, str] = Field(
        default_factory=dict,
        description="Best grade a reading from that source can earn, e.g. visual → Standard (FR44).",
    )
    status: Literal["active", "load_from_standard"] = Field(
        "active",
        description="`load_from_standard`: limits still to be copied from the standard; graded as missing.",
    )
    role: Literal["grading", "label_declaration", "contract_spec"] = Field(
        "grading",
        description=(
            "`grading` takes part in the grade; `label_declaration` is printed on the label for "
            "`declare_for_grades`; `contract_spec` is a buyer specification, recorded but never graded."
        ),
    )
    declare_for_grades: list[str] = Field(
        default_factory=list,
        description="Grades whose label must declare this value (role label_declaration).",
    )
    exception_flags: list[str] = Field(
        default_factory=list,
        description=(
            "Batch attributes (e.g. `monsooned` coffee) under which a value outside the limits is a warning, "
            "not a fail: the parameter then does not lower the grade."
        ),
    )


class LabCertifiedRequires(_Strict):
    """What makes a grade "Lab-certified" on the public page (FR51)."""

    any_parameter_source: ReadingSource = Field(
        ReadingSource.LAB, description="At least one reading used for the grade must have this source."
    )
    nabl_no_present: bool = Field(
        True, description="That reading must also carry a NABL accreditation number."
    )


class LotGate(_Strict):
    """A reading condition a lot must meet before a lifecycle step, e.g. ready for sale (Dataflow Stage 5)."""

    parameter: str = Field(description="Parameter code checked.")
    stage: ReadingStage = Field(description="Stage whose latest reading is checked.")
    min: JsonNumber | None = Field(None, description="Lowest passing value, inclusive.")
    max: JsonNumber | None = Field(
        None, description="Highest passing value, inclusive, e.g. moisture ≤ 11 %."
    )


class TrailRule(_Strict):
    """How a parameter may change from one capture stage to the next (FR50: moisture must not rise)."""

    parameter: str = Field(description="Parameter code the rule follows.")
    stages: list[ReadingStage] = Field(min_length=2, description="Stages in chain order, earliest first.")
    rule: Literal["non_increasing"] = Field(description="`non_increasing`: a later stage may not be higher.")
    tolerance: JsonNumber = Field(
        Decimal(0), ge=0, description="Rise tolerated before it counts as a violation (meter noise)."
    )
    override_with_reason: bool = Field(
        False, description="A violating reading is accepted when it carries a `reason_code` (then flagged)."
    )


class YieldRule(_Strict):
    """Plausible yield per acre with the warn and hold margins of the yield-ceiling check (FR68, Stage 7)."""

    ceiling_kg_per_acre: JsonNumber = Field(
        gt=0, description="Plausible maximum harvest per acre, in kg/acre."
    )
    warn_margin_pct: JsonNumber = Field(
        ge=0, description="Excess over the ceiling still passing silently, %."
    )
    hold_margin_pct: JsonNumber = Field(ge=0, description="Excess above which the lot is held out of GI, %.")
    note: str | None = Field(None, description="Where the ceiling came from; calibrate after season 1.")

    @model_validator(mode="after")
    def _margins_ordered(self) -> Self:
        """Check that the hold margin is not below the warn margin.

        Returns:
            The validated rule.

        Raises:
            ValueError: `hold_margin_pct` < `warn_margin_pct`.
        """
        if self.hold_margin_pct < self.warn_margin_pct:
            raise ValueError("hold_margin_pct must be >= warn_margin_pct")
        return self


class StandardsProfileRules(_Strict):
    """The rules JSON of one Standards Profile version, interpreted by `grade_engine` (§4, D-015, FR47).

    Grades are listed best first; `fail_grade` is what a batch gets when a parameter meets no grade.
    """

    schema_version: Literal[1] = Field(description="Version of this JSON layout; only 1 exists.")
    standard: StandardRef = Field(description="Standard, edition and clause the limits come from (FR47).")
    grades: list[str] = Field(min_length=1, description="Grade names, best first, e.g. [Special, Standard].")
    fail_grade: str = Field(
        min_length=1, description="Grade given when a limit is not met, e.g. Below grade."
    )
    parameters: list[Parameter] = Field(min_length=1, description="Every parameter of the standard (FR46).")
    lab_certified_requires: LabCertifiedRequires | None = Field(
        None, description="Condition for the Lab-certified badge (FR51); null: never lab-certified."
    )
    lot_gates: dict[str, LotGate] = Field(
        default_factory=dict, description="Named lot gates, e.g. `ready_for_sale` (Dataflow Stage 5)."
    )
    trail_rules: list[TrailRule] = Field(default_factory=list, description="Stage-to-stage rules (FR50).")
    yield_: YieldRule | None = Field(
        None, alias="yield", description="Yield-ceiling parameters (FR68); null: no yield check for the crop."
    )
    public_note: str | None = Field(
        None,
        description=(
            "Shown on the public page next to the grade (FR51); stamped when a version is published with "
            "parameters still `load_from_standard`."
        ),
    )

    @model_validator(mode="after")
    def _cross_check(self) -> Self:
        """Check the references between grades, parameters, gates and trail rules.

        Returns:
            The validated rules.

        Raises:
            ValueError: duplicate grade or parameter code; `fail_grade` listed as a grade; a `limits`,
                `max_grade_for_source` or `declare_for_grades` grade not in `grades`; `limits` set without a
                key for every grade; `grading_stage` not
                in `capture_stages`; a `load_from_standard` parameter with limits; a gate or trail rule
                naming an unknown parameter.
        """
        grades = set(self.grades)
        if len(grades) != len(self.grades) or self.fail_grade in grades:
            raise ValueError("grades must be unique and must not contain fail_grade")
        codes = [p.code for p in self.parameters]
        if len(set(codes)) != len(codes):
            raise ValueError("parameter codes must be unique")
        for p in self.parameters:
            used = set(p.limits or {}) | set(p.max_grade_for_source.values()) | set(p.declare_for_grades)
            if not used <= grades:
                raise ValueError(f"{p.code}: unknown grade(s) {sorted(used - grades)}")
            # A partial map would silently cap every batch (B05 r1 F6), so it must be spelled out.
            if p.limits is not None and set(p.limits) != grades:
                raise ValueError(
                    f"{p.code}: limits needs a key for every grade; missing {sorted(grades - set(p.limits))}"
                )
            if p.grading_stage not in p.capture_stages:
                raise ValueError(f"{p.code}: grading_stage {p.grading_stage} not in capture_stages")
            if p.status == "load_from_standard" and p.limits is not None:
                raise ValueError(f"{p.code}: a load_from_standard parameter must have limits null")
        refs = [g.parameter for g in self.lot_gates.values()] + [t.parameter for t in self.trail_rules]
        if unknown := set(refs) - set(codes):
            raise ValueError(f"lot_gates/trail_rules name unknown parameter(s) {sorted(unknown)}")
        return self

    def parameter(self, code: str) -> Parameter | None:
        """Find a parameter by code.

        Args:
            code: parameter code, e.g. `moisture`.

        Returns:
            The parameter, or None when the profile has no such code.
        """
        return next((p for p in self.parameters if p.code == code), None)

    def pending_parameters(self) -> list[str]:
        """List the grading parameters whose limits are still to be loaded from the standard.

        Returns:
            Codes of `role == grading` parameters with `limits` null, in profile order.
        """
        return [p.code for p in self.parameters if p.role == "grading" and p.limits is None]


# ---------------------------------------------------------------------------------------------------------
# API shapes
# ---------------------------------------------------------------------------------------------------------


class StandardsProfileOut(BaseModel):
    """A Standards Profile with the number of its current published version (FR47)."""

    id: uuid.UUID = Field(description="Profile id.")
    crop_id: uuid.UUID = Field(description="Crop the profile grades.")
    scheme: StandardsScheme = Field(description="agmark, iso, fssai or custom.")
    name: str = Field(description="Profile name.")
    standard_ref: str = Field(description="Standard document reference.")
    published_version_no: int | None = Field(
        description="Version number currently published; null when none is published."
    )


class ProfileVersionIn(BaseModel):
    """A new version of a profile's rules, created by the compliance team (super-admin, FR47)."""

    rules: StandardsProfileRules = Field(description="The rules JSON (backend-design.md §4).")
    status: Literal[ProfileVersionStatus.DRAFT, ProfileVersionStatus.PUBLISHED] = Field(
        ProfileVersionStatus.PUBLISHED,
        description="`published` makes it the version used for new readings and retires the previous one.",
    )
    allow_incomplete: bool = Field(
        False,
        description=(
            "Required to publish while a grading parameter is still `load_from_standard`; the grade is then "
            "computed from the other parameters and a `public_note` is stamped if none is given."
        ),
    )


class ProfileVersionOut(BaseModel):
    """One version of a profile with its rules (FR47)."""

    id: uuid.UUID = Field(description="Version id; readings and grade computations reference it.")
    profile_id: uuid.UUID = Field(description="Profile.")
    version_no: int = Field(description="Version number, 1 upwards.")
    edition: str = Field(description="Edition of the standard cited.")
    clause_ref: str = Field(description="Clause cited.")
    status: ProfileVersionStatus = Field(description="draft, published or retired.")
    published_at: datetime | None = Field(description="When it was published.")
    rules: StandardsProfileRules = Field(description="The rules JSON.")


class InstrumentIn(BaseModel):
    """A moisture meter, colorimeter, hygrometer or scale registered by the FPO (FR42, FR50)."""

    kind: InstrumentKind = Field(description="Instrument kind.")
    make_model: str = Field(min_length=1, max_length=200, description="Make and model.")
    serial_no: str = Field(min_length=1, max_length=100, description="Serial number.")
    calibrated_on: date | None = Field(None, description="Date of last calibration (YYYY-MM-DD).")
    calibration_due_on: date | None = Field(
        None, description="Calibration due date; readings measured after it are rejected (FR50)."
    )
    calibration_cert_photo_id: uuid.UUID | None = Field(
        None, description="Evidence photo of the certificate."
    )
    active: bool = Field(True, description="False hides it from new readings.")

    @model_validator(mode="after")
    def _dates_ordered(self) -> Self:
        """Check that the due date is not before the calibration date.

        Returns:
            The validated instrument.

        Raises:
            ValueError: `calibration_due_on` < `calibrated_on`.
        """
        if self.calibrated_on and self.calibration_due_on and self.calibration_due_on < self.calibrated_on:
            raise ValueError("calibration_due_on is before calibrated_on")
        return self


class InstrumentOut(InstrumentIn):
    """A registered instrument."""

    id: uuid.UUID = Field(description="Instrument id.")
    fpo_id: uuid.UUID = Field(description="Owning FPO.")


class QualityReadingIn(BaseModel):
    """One measured parameter of a lot or batch at a stage (FR42–FR46). Also the sync `quality_reading` data.

    Exactly one of `lot_id` and `batch_id` is set.
    """

    client_id: uuid.UUID = Field(description="UUIDv7 from the device; primary and idempotency key (D-005).")
    lot_id: uuid.UUID | None = Field(None, description="Lot measured (drying end, intake).")
    batch_id: uuid.UUID | None = Field(None, description="Batch measured (grading, storage).")
    stage: ReadingStage = Field(description="drying_end, intake, grading or storage (FR43, FR45).")
    parameter_code: str = Field(min_length=1, max_length=64, description="Profile parameter code.")
    measurement: SignedQuantity = Field(
        description=(
            "Value with its unit, e.g. {value: 9.8, unit: %}. Negative values pass the schema so the "
            "plausibility check can answer `implausible_value`."
        )
    )
    method_ref: str | None = Field(None, max_length=200, description="Test method reference (FR42).")
    source: ReadingSource = Field(description="lab, instrument or visual (FR42, FR44).")
    instrument_id: uuid.UUID | None = Field(
        None, description="Instrument used; required when source=instrument."
    )
    lab_name: str | None = Field(None, max_length=200, description="Laboratory name, for lab results.")
    lab_nabl_no: str | None = Field(None, max_length=64, description="NABL number; needed for Lab-certified.")
    sample_id: str | None = Field(None, max_length=100, description="Sample identifier (FR42).")
    certificate_photo_id: uuid.UUID | None = Field(None, description="Evidence photo of the lab certificate.")
    evidence_photo_id: uuid.UUID | None = Field(
        None, description="Photo of the meter display or colour card."
    )
    measured_at: AwareDatetime = Field(description="When it was measured, ISO 8601 with offset.")
    device_time: AwareDatetime | None = Field(None, description="Phone clock at capture.")
    gps_time: AwareDatetime | None = Field(None, description="GPS fix time at capture.")
    gps: GeoPoint | None = Field(None, description="Where it was measured (FR42).")
    reason_code: str | None = Field(
        None, max_length=64, description="Reason accepted for a trail-rule override, e.g. `rain_exposure`."
    )

    @model_validator(mode="after")
    def _subject_and_instrument(self) -> Self:
        """Check the subject and the instrument link.

        Returns:
            The validated reading.

        Raises:
            ValueError: not exactly one of lot_id/batch_id; source=instrument without `instrument_id`.
        """
        if (self.lot_id is None) == (self.batch_id is None):
            raise ValueError("set exactly one of lot_id and batch_id")
        if self.source == ReadingSource.INSTRUMENT and self.instrument_id is None:
            raise ValueError("instrument_id is required when source is instrument")
        return self


class QualityReadingOut(BaseModel):
    """A stored quality reading."""

    id: uuid.UUID = Field(description="Reading id (= client_id).")
    fpo_id: uuid.UUID = Field(description="Owning FPO.")
    lot_id: uuid.UUID | None = Field(description="Lot measured.")
    batch_id: uuid.UUID | None = Field(description="Batch measured.")
    stage: ReadingStage = Field(description="Stage.")
    parameter_code: str = Field(description="Parameter code.")
    measurement: SignedQuantity = Field(description="Value with its unit.")
    method_ref: str | None = Field(description="Test method reference.")
    source: ReadingSource = Field(description="lab, instrument or visual.")
    instrument_id: uuid.UUID | None = Field(description="Instrument used.")
    calibration_due_on_at_time: date | None = Field(
        description="Instrument's calibration due date when read."
    )
    lab_name: str | None = Field(description="Laboratory name.")
    lab_nabl_no: str | None = Field(description="NABL number.")
    sample_id: str | None = Field(description="Sample identifier.")
    measured_by_user_id: uuid.UUID = Field(description="Who measured.")
    measured_at: datetime = Field(description="When it was measured.")
    server_received_at: datetime = Field(description="When the server received it.")
    reason_code: str | None = Field(description="Trail-override reason, if any.")
    profile_version_id: uuid.UUID | None = Field(description="Profile version it was checked against.")


class GradingIn(BaseModel):
    """Grade a batch: the declared grade plus the readings to use (Dataflow Stage 8, FR48, FR49)."""

    declared_grade: str = Field(min_length=1, max_length=64, description="Grade the QC officer declares.")
    reading_ids: list[uuid.UUID] | None = Field(
        None, description="Readings of this batch to use; omitted: every reading of the batch."
    )
    readings: list[QualityReadingIn] = Field(
        default_factory=list,
        max_length=50,
        description="Readings to record first, then used too; their subject is forced to this batch.",
    )


class ParameterResult(BaseModel):
    """How one parameter contributed to the grade (`grade_computations.per_parameter`)."""

    parameter: str = Field(description="Parameter code.")
    outcome: Literal["graded", "missing", "profile_incomplete", "not_graded", "exception"] = Field(
        description=(
            "graded: limits applied; missing: no reading at the grading stage; profile_incomplete: limits "
            "still load_from_standard; not_graded: label or contract value; exception: limits waived by a "
            "batch exception flag (warning)."
        )
    )
    grade: str | None = Field(None, description="Grade reached by this parameter (graded only).")
    reading_id: uuid.UUID | None = Field(None, description="Reading used.")
    value: Decimal | None = Field(None, description="Value used.")
    unit: str | None = Field(None, description="Unit of the value.")
    source: ReadingSource | None = Field(None, description="Source of the reading used.")
    limit: Range | None = Field(None, description="Limit of the grade reached; null for the fail grade.")
    capped_by_source: bool = Field(False, description="True when `max_grade_for_source` lowered the grade.")
    lab_certified: bool = Field(
        False,
        description=(
            "An accredited lab result (source lab, non-blank NABL number) for this parameter is attached to "
            "the batch at any stage; lets the public page say which values are lab-measured (FR51)."
        ),
    )


class GradeOut(BaseModel):
    """A stored grade computation of a batch (FR48, FR49, FR51)."""

    id: uuid.UUID = Field(description="Computation id.")
    batch_id: uuid.UUID = Field(description="Batch graded.")
    profile_version_id: uuid.UUID = Field(description="Profile version applied.")
    computed_grade: str | None = Field(
        description="Lowest grade every parameter meets; null when incomplete."
    )
    declared_grade: str | None = Field(description="Grade the QC officer declared.")
    status: GradeStatus = Field(
        description="ok, incomplete or declared_above_computed (FR49 blocks approval)."
    )
    lab_certified: bool = Field(
        description="Any batch reading of a profile parameter is a lab result with a NABL number (FR51)."
    )
    per_parameter: dict[str, ParameterResult] = Field(description="Contribution of each parameter, by code.")
    computed_at: datetime = Field(description="When the engine ran.")
