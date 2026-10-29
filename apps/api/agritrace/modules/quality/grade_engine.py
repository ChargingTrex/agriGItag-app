"""Grade engine: pure functions interpreting a Standards Profile's rules JSON. No database, no FastAPI.

Serves: PRD §6.8 FR44 (visual readings cannot earn the top grade), FR48 (batch grade = lowest grade all
parameters meet), FR49 (declared vs computed), FR50 (plausibility and moisture trail at entry), FR51
(lab-certified), FR68 (yield ceiling with 20 %/30 % margins), Dataflow Stage 5 (ready-for-sale lot gate),
Stage 7 (intake moisture, yield check), Stage 8 (grading), backend-design.md §4 steps 1–6.
Callers: `quality.service` (readings, grading, lot gate, yield), tests/unit/test_grade_engine.py with the
shared cases in tests/fixtures/grade_cases.json; the mobile preview (M03) ports this file to Dart.

DECISION D-015: one generic engine reads the versioned profile JSON; there is no per-crop code.
  ADV: compliance edits limits without a deployment; chilli, turmeric, saffron and coffee profiles all
    run through the same six steps (see the fixtures).
  COMPROMISE: non-tabular standards (coffee defect charts, tea sensory grades) need engine extensions;
    seed values marked load_from_standard must be replaced before go-live.
DECISION D-006: the engine imports only Pydantic and core enums, so the phone can run the same rules as a
preview and both sides are tested with the same JSON fixtures.
  ADV: offline preview on the phone; the server result stays the authority.
  COMPROMISE: two interpreters (Python and Dart) must be kept in step through tests/fixtures/grade_cases.json.
"""

import uuid
from collections.abc import Iterable, Sequence
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any, Literal

from pydantic import AwareDatetime, BaseModel, Field

from agritrace.core.enums import ReadingSource, ReadingStage
from agritrace.modules.quality.schemas import ParameterResult, Range, StandardsProfileRules

ViolationCode = Literal[
    "unknown_parameter",
    "unit_mismatch",
    "implausible_value",
    "source_not_allowed",
    "moisture_trail_violation",
]


class Reading(BaseModel):
    """The engine's view of one quality reading (a stored row, a request body or a phone draft)."""

    id: uuid.UUID | None = Field(None, description="Reading id, echoed in the per-parameter result.")
    parameter_code: str = Field(description="Profile parameter code.")
    value: Decimal = Field(description="Measured value.")
    unit: str = Field(description="Unit of `value`.")
    stage: ReadingStage = Field(description="Stage it was captured at.")
    source: ReadingSource = Field(description="lab, instrument or visual.")
    measured_at: AwareDatetime | None = Field(
        None, description="Capture time; the latest wins. Null sorts first; equal times fall back to `id`."
    )
    lab_nabl_no: str | None = Field(None, description="NABL number, for the Lab-certified badge.")


class GradeResult(BaseModel):
    """Outcome of `compute` (FR48, FR51)."""

    status: Literal["ok", "incomplete"] = Field(description="incomplete when a required reading is missing.")
    grade: str | None = Field(description="Batch grade (worst per-parameter grade); null when incomplete.")
    lab_certified: bool = Field(
        description="Any reading given (any stage, any profile parameter) meets `lab_certified_requires`."
    )
    per_parameter: dict[str, ParameterResult] = Field(description="Every parameter's contribution, by code.")
    missing_required: list[str] = Field(description="Required graded parameters without a reading.")
    profile_incomplete: list[str] = Field(
        description="Grading parameters skipped because their limits are load_from_standard (info flag)."
    )
    warnings: list[str] = Field(description="Parameters whose limits were waived by an exception flag.")


class Violation(BaseModel):
    """Why a reading is rejected at entry (FR50). `code` equals the API error code."""

    code: ViolationCode = Field(description="Registered error code, e.g. implausible_value.")
    parameter: str = Field(description="Parameter code of the reading.")
    message: str = Field(description="English explanation for logs and the error envelope.")
    overridable: bool = Field(False, description="True when a `reason_code` turns the rejection into a flag.")


def rank(rules: StandardsProfileRules, grade: str) -> int | None:
    """Position of a grade, best first; the fail grade ranks after every grade.

    Args:
        rules: the profile rules.
        grade: a grade name.

    Returns:
        0 for the best grade, `len(grades)` for `fail_grade`, None for a name the profile does not know.
    """
    if grade == rules.fail_grade:
        return len(rules.grades)
    return rules.grades.index(grade) if grade in rules.grades else None


_NO_TIME = datetime.min.replace(tzinfo=UTC)
_NO_ID = uuid.UUID(int=0)


def _latest(readings: Iterable[Reading]) -> Reading | None:
    """Pick the most recent reading, independently of input order.

    Ordered by `(measured_at, id)`: null times sort first, and equal instants (e.g. a re-test entered at
    minute resolution) are broken by the UUIDv7 id, which follows capture order. The phone preview (D-006)
    must use the same key so both sides pick the same reading.

    Args:
        readings: candidate readings.

    Returns:
        The reading with the greatest `(measured_at, id)`, or None when there is none.
    """
    return max(readings, key=lambda r: (r.measured_at or _NO_TIME, r.id or _NO_ID), default=None)


def _counts_as_lab(rules: StandardsProfileRules, reading: Reading) -> bool:
    """Tell whether one reading is an accredited lab result under `lab_certified_requires` (FR51).

    Args:
        rules: the profile rules.
        reading: any reading of the batch.

    Returns:
        True when the profile has the rule, the reading's parameter is in the profile, its source matches
        and, when a NABL number is required, the number is not blank or whitespace.
    """
    need = rules.lab_certified_requires
    if need is None or rules.parameter(reading.parameter_code) is None:
        return False
    has_nabl = bool((reading.lab_nabl_no or "").strip())
    return reading.source == need.any_parameter_source and (has_nabl or not need.nabl_no_present)


def compute(
    rules: StandardsProfileRules, readings: Sequence[Reading], exception_flags: Iterable[str] = ()
) -> GradeResult:
    """Compute the grade a set of readings earns under a profile (backend-design.md §4, FR48).

    Steps: (1) latest reading per parameter at its `grading_stage`; (2) a missing required parameter with
    limits makes the result incomplete; (3) each parameter gets the best grade whose limits hold, else the
    fail grade, (4) capped by `max_grade_for_source`; (5) the batch grade is the worst parameter grade;
    (6) lab-certified when ANY reading given, at any stage and for any profile parameter, meets
    `lab_certified_requires` ("accredited lab result attached", FR51; Architect-Gate ruling, B05 r1 F1);
    each parameter records whether it has such a reading. Parameters with null limits are
    skipped and reported in `profile_incomplete`; label/contract parameters are reported, never graded.

    Args:
        rules: the profile rules.
        readings: readings attached to the batch, at any stage (grading uses `grading_stage` only).
        exception_flags: batch attributes such as `monsooned`; a parameter listing one of them in its
            `exception_flags` warns instead of failing when out of limits.

    Returns:
        The grade result with a per-parameter breakdown.
    """
    flags = set(exception_flags)
    per: dict[str, ParameterResult] = {}
    missing: list[str] = []
    pending: list[str] = []
    warnings: list[str] = []
    worst = -1  # rank of the worst graded parameter so far
    for p in rules.parameters:
        reading = _latest(r for r in readings if r.parameter_code == p.code and r.stage == p.grading_stage)
        lab = any(_counts_as_lab(rules, r) for r in readings if r.parameter_code == p.code)
        seen: dict[str, Any] = {"lab_certified": lab}
        if reading:
            seen |= {
                "reading_id": reading.id,
                "value": reading.value,
                "unit": reading.unit,
                "source": reading.source,
            }
        if p.role != "grading":
            per[p.code] = ParameterResult(parameter=p.code, outcome="not_graded", **seen)
            continue
        if p.limits is None:
            pending.append(p.code)
            per[p.code] = ParameterResult(parameter=p.code, outcome="profile_incomplete", **seen)
            continue
        if reading is None:
            if p.required:
                missing.append(p.code)
            per[p.code] = ParameterResult(parameter=p.code, outcome="missing", lab_certified=lab)
            continue
        hit = next(
            (
                (i, g)
                for i, g in enumerate(rules.grades)
                if g in p.limits and p.limits[g].holds(reading.value)
            ),
            None,
        )
        if hit is None and flags & set(p.exception_flags):
            # "Flag, do not reject" (PRD §6.8 monsooned coffee): the parameter stops limiting the grade.
            warnings.append(p.code)
            worst = max(worst, 0)
            per[p.code] = ParameterResult(parameter=p.code, outcome="exception", **seen)
            continue
        position, limit = (hit[0], p.limits[hit[1]]) if hit else (len(rules.grades), None)
        cap = p.max_grade_for_source.get(reading.source)
        capped = cap is not None and rules.grades.index(cap) > position
        if capped:
            assert cap is not None  # narrowed for mypy; `capped` implies it
            position, limit = rules.grades.index(cap), p.limits.get(cap)
        grade = rules.grades[position] if position < len(rules.grades) else rules.fail_grade
        worst = max(worst, position)
        per[p.code] = ParameterResult(
            parameter=p.code, outcome="graded", grade=grade, limit=limit, capped_by_source=capped, **seen
        )
    complete = not missing and worst >= 0
    batch_grade = (
        (rules.grades[worst] if worst < len(rules.grades) else rules.fail_grade) if complete else None
    )
    return GradeResult(
        status="ok" if complete else "incomplete",
        grade=batch_grade,
        lab_certified=any(_counts_as_lab(rules, r) for r in readings),
        per_parameter=per,
        missing_required=missing,
        profile_incomplete=pending,
        warnings=warnings,
    )


def declared_vs_computed(
    rules: StandardsProfileRules, declared: str, computed: str | None
) -> Literal["ok", "declared_above_computed", "unknown_grade_for_profile"]:
    """Compare the QC officer's declared grade with the computed one (FR49).

    Args:
        rules: the profile rules.
        declared: grade the officer declared.
        computed: grade from `compute`; None when incomplete (only the name is checked then).

    Returns:
        `unknown_grade_for_profile` when the profile has no such grade (e.g. "A" on AGMARK chilli);
        `declared_above_computed` when the declared grade is better than the computed one; else `ok`.
    """
    declared_rank = rank(rules, declared)
    if declared_rank is None:
        return "unknown_grade_for_profile"
    computed_rank = rank(rules, computed) if computed is not None else None
    if computed_rank is not None and declared_rank < computed_rank:
        return "declared_above_computed"
    return "ok"


def check_plausibility(rules: StandardsProfileRules, reading: Reading) -> list[Violation]:
    """Check a reading at entry against its parameter (FR50): known code, unit, range, source.

    Args:
        rules: the profile rules.
        reading: the incoming reading.

    Returns:
        Every violation found, in the order unknown parameter, unit, range, source; empty when acceptable.
        An unknown parameter is reported alone (nothing else can be checked).
    """
    p = rules.parameter(reading.parameter_code)
    if p is None:
        return [
            Violation(
                code="unknown_parameter", parameter=reading.parameter_code, message="Not in the profile."
            )
        ]
    out: list[Violation] = []
    if reading.unit != p.unit:
        out.append(Violation(code="unit_mismatch", parameter=p.code, message=f"Unit must be {p.unit!r}."))
    if p.plausible and not p.plausible.holds(reading.value):
        bounds = f"[{p.plausible.min}, {p.plausible.max}]"
        out.append(Violation(code="implausible_value", parameter=p.code, message=f"Outside {bounds}."))
    if reading.source not in p.sources_allowed:
        allowed = ", ".join(p.sources_allowed)
        out.append(Violation(code="source_not_allowed", parameter=p.code, message=f"Allowed: {allowed}."))
    return out


def check_trail(
    rules: StandardsProfileRules, prior_readings: Sequence[Reading], new_reading: Reading
) -> Violation | None:
    """Apply the profile's trail rules to a new reading (FR50: moisture must not rise along the chain).

    The baseline is the highest value among the readings at the latest earlier stage that has any (several
    component lots feed one batch, so the most lenient one is used and genuine mixes never fail).

    Args:
        rules: the profile rules.
        prior_readings: earlier readings of the same lot, or of the batch and its component lots.
        new_reading: the incoming reading.

    Returns:
        A `moisture_trail_violation` (named after the pilot's only trail rule; `overridable` when the
        rule allows a reason) if the value rises above the baseline plus tolerance, else None.
    """
    for rule in rules.trail_rules:
        if rule.parameter != new_reading.parameter_code or new_reading.stage not in rule.stages:
            continue
        at = rule.stages.index(new_reading.stage)
        earlier = [
            r for r in prior_readings if r.parameter_code == rule.parameter and r.stage in rule.stages[:at]
        ]
        if not earlier:
            continue
        last_stage = max(rule.stages.index(r.stage) for r in earlier)
        baseline = max(r.value for r in earlier if rule.stages.index(r.stage) == last_stage)
        if new_reading.value > baseline + rule.tolerance:
            return Violation(
                code="moisture_trail_violation",
                parameter=rule.parameter,
                message=(
                    f"{new_reading.value} at {new_reading.stage} is above {baseline} at "
                    f"{rule.stages[last_stage]} (+{rule.tolerance} tolerated)."
                ),
                overridable=rule.override_with_reason,
            )
    return None


def lot_gate(rules: StandardsProfileRules, gate: str, readings: Sequence[Reading]) -> bool:
    """Tell whether a lot's readings pass a named gate, e.g. `ready_for_sale` (Dataflow Stage 5).

    Args:
        rules: the profile rules.
        gate: gate name in `rules.lot_gates`.
        readings: the lot's readings.

    Returns:
        True when the profile defines no such gate, or the latest reading of the gate's parameter at the
        gate's stage lies within its bounds; False when there is no such reading or it is out of bounds.
    """
    g = rules.lot_gates.get(gate)
    if g is None:
        return True
    latest = _latest(r for r in readings if r.parameter_code == g.parameter and r.stage == g.stage)
    return latest is not None and Range(min=g.min, max=g.max).holds(latest.value)


def yield_outcome(
    rules: StandardsProfileRules, kg: Decimal | float | str, declared_acres: Decimal | float | str
) -> Literal["pass", "warn", "hold"] | None:
    """Compare a lot's harvest with declared area × the yield ceiling (FR68, Dataflow Stage 7).

    Args:
        rules: the profile rules.
        kg: harvested quantity in kg; int, float, str or Decimal (converted with `Decimal(str(x))`).
        declared_acres: declared plot area in acres; same types as `kg`.

    Returns:
        `pass` up to `warn_margin_pct` over the ceiling, `warn` up to `hold_margin_pct`, `hold` above;
        None when the profile has no yield rule or the area is not positive (check unavailable).

    Raises:
        decimal.InvalidOperation: `kg` or `declared_acres` is not a number.
    """
    y = rules.yield_
    # str() first so a float such as 0.7 becomes Decimal("0.7"), not its binary expansion.
    kg, acres = Decimal(str(kg)), Decimal(str(declared_acres))
    if y is None or acres <= 0:
        return None
    excess_pct = (kg / (y.ceiling_kg_per_acre * acres) - 1) * 100
    if excess_pct <= y.warn_margin_pct:
        return "pass"
    return "warn" if excess_pct <= y.hold_margin_pct else "hold"
