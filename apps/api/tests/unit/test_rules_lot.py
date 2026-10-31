"""Unit tests of the lot- and batch-level rules with the plan's acceptance cases.

Serves: B08 acceptance (nursery before ploughing → no flag; sowing before nursery → flag; Inorganic with only
organic inputs → `practice_tag_contradiction`; IPM without pest event → flag; 1,150/1,250/1,350 kg on 1 acre →
none/warn/hold), B15 acceptance (D-030 attribution and grading loss cases),
FR50, FR55–FR57, FR60, FR68, PRD §12.2 (the reference lots' quantities).
Callers: pytest (`make test-unit`), no Docker.
"""

import json
import uuid
from datetime import date
from decimal import Decimal
from pathlib import Path

import pytest

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.quality import grade_engine
from agritrace.modules.quality.schemas import StandardsProfileRules
from agritrace.modules.rules_flags.rules import (
    event_order,
    moisture_trail_override,
    practice_tags,
    profile_incomplete,
    quantity_reconciliation,
    yield_ceiling,
)
from agritrace.modules.rules_flags.rules.context import BatchContext, LotContext, LotEvent, ReadingFacts

SCHEMA = {
    "mandatory": ["land_preparation", "nursery", "sowing", "harvest", "drying", "packing"],
    "tracks": {
        "nursery": ["nursery", "sowing"],
        "main_field": ["land_preparation", "sowing", "harvest", "drying", "packing"],
    },
}
ORGANIC = ("organic_fertilizer", "bio_fertilizer", "bio_fertilizer")
LOT = uuid.uuid4()
CHILLI = (Decimal(1000), Decimal(20), Decimal(30))  # ceiling kg/acre, warn %, hold %
PROFILE = StandardsProfileRules.model_validate(
    json.loads((Path(grade_engine.__file__).parent / "profiles" / "dry_chilli_agmark_v1.json").read_text())
)


def _event(kind: str, on: str) -> LotEvent:
    """Make a lot event.

    Args:
        kind: event type.
        on: ISO date.

    Returns:
        The event with a fresh id.
    """
    return LotEvent(uuid.uuid4(), kind, date.fromisoformat(on))


def test_nursery_before_ploughing_is_not_a_flag() -> None:
    """LOT3072CB6A: bed seeding 2025-09-05 precedes ploughing 2025-09-30, which is normal (PRD §12.2)."""
    days = [("nursery", "2025-09-05"), ("land_preparation", "2025-09-30"), ("sowing", "2025-10-20")]
    events = tuple(_event(kind, on) for kind, on in [*days, ("harvest", "2026-02-14")])
    assert event_order.run(LotContext(LOT, SCHEMA, events)) == []


def test_sowing_before_nursery_is_flagged_on_the_sowing() -> None:
    """Sowing dated before the nursery raises `event_out_of_order` on the sowing event."""
    sowing = _event("sowing", "2025-10-20")
    events = (_event("land_preparation", "2025-09-30"), _event("nursery", "2025-10-25"), sowing)
    [flag] = event_order.run(LotContext(LOT, SCHEMA, events))
    assert (flag.subject_type, flag.subject_id, flag.rule_code) == (
        FlagSubject.EVENT,
        sowing.id,
        "event_out_of_order",
    )
    assert flag.details["missing"] == ["nursery"]


def test_inorganic_declared_with_only_organic_inputs_is_a_contradiction() -> None:
    """Declared Inorganic, organic/bio inputs only, a pest event present → contradiction only."""
    ctx = LotContext(LOT, declared_tags=("inorganic",), input_categories=ORGANIC, has_pest_event=True)
    assert [f.rule_code for f in practice_tags.run(ctx)] == ["practice_tag_contradiction"]


def test_ipm_without_pest_event_is_flagged() -> None:
    """IPM declared and no problem/pest event on the lot."""
    ctx = LotContext(LOT, declared_tags=("organic", "ipm"), input_categories=ORGANIC)
    [flag] = practice_tags.run(ctx)
    assert (flag.rule_code, flag.severity) == ("ipm_without_pest_event", Severity.WARN)


@pytest.mark.parametrize(
    ("kg", "expected"),
    [(1150, None), (1250, Severity.WARN), (1350, Severity.HOLD), (1200, None), (1300, Severity.WARN)],
)
def test_yield_on_one_acre(kg: int, expected: Severity | None) -> None:
    """1,150 / 1,250 / 1,350 kg on 1 acre at 1,000 kg/acre (20 %/30 %) → none / warn / hold; limits inclusive.

    Args:
        kg: harvested kilograms.
        expected: severity of `yield_over_ceiling`, or None for no flag.
    """
    outcome = grade_engine.yield_outcome(PROFILE, kg, 1)  # what quality.service.yield_outcome_for_crop runs
    ctx = LotContext(LOT, harvested_kg=Decimal(kg), declared_acres=Decimal(1), yield_outcome=outcome)
    assert [f.severity for f in yield_ceiling.run(ctx)] == ([expected] if expected else [])


def test_no_harvest_quantity_makes_yield_unavailable() -> None:
    """PRD §12.2 "No harvest quantity" → `yield_check_unavailable` info."""
    [flag] = yield_ceiling.run(LotContext(LOT, declared_acres=Decimal(1), yield_limits=CHILLI))
    assert (flag.rule_code, flag.severity) == ("yield_check_unavailable", Severity.INFO)


@pytest.mark.parametrize(
    ("chain", "flagged"),
    [
        ({"packed_kg": 69, "used_kg": 100}, True),  # LOTD02DADB6
        ({"packed_kg": 140, "used_kg": 200}, True),  # LOT3072CB6A
        ({"packed_kg": Decimal("272.6"), "used_kg": 20}, True),  # LOT0EF81415
        ({"packed_kg": 69, "received_kg": 100}, True),  # B09: intake 100 vs packed 69
        ({"harvested_kg": 400, "packed_kg": 100, "received_kg": 98, "used_kg": 98}, False),
        ({"packed_kg": 100, "received_kg": 104}, False),  # within 5 %
    ],
)
def test_quantity_chain(chain: dict[str, object], flagged: bool) -> None:
    """Harvested ≥ packed ≥ received ≥ used within 5 %; drying loss after harvest is allowed.

    Args:
        chain: recorded quantities in kg.
        flagged: whether `quantity_mismatch` is expected.
    """
    values = {k: Decimal(str(v)) for k, v in chain.items()}
    flags = quantity_reconciliation.run(LotContext(LOT, **values))  # type: ignore[arg-type]
    assert [f.rule_code for f in flags] == (["quantity_mismatch"] if flagged else [])


def _batch_codes(**kg: object) -> list[str]:
    """Run the batch reconciliation on kilogram values and return the raised codes.

    Args:
        **kg: `BatchContext` fields; numbers become `Decimal`, `grading_loss_warn_pct` stays an int.

    Returns:
        The rule codes, in the rule's order.
    """
    values = {k: v if k == "grading_loss_warn_pct" else Decimal(str(v)) for k, v in kg.items()}
    return [f.rule_code for f in quantity_reconciliation.run(BatchContext(uuid.uuid4(), **values))]  # type: ignore[arg-type]


@pytest.mark.parametrize(
    ("graded", "loss_pct"),
    [(290, None), (260, "18.75"), (20, "93.75"), (340, "-6.25")],
)
def test_grading_loss(graded: int, loss_pct: str | None) -> None:
    """D-030: received 320, shares 320; graded 290 passes, 260 / 20 (losses) and 340 (gain) warn.

    Args:
        graded: graded kilograms.
        loss_pct: expected `loss_pct` detail of `grading_loss_high`, or None for no flag.
    """
    ctx = BatchContext(
        uuid.uuid4(), shares_kg=Decimal(320), batch_kg=Decimal(graded), received_kg=Decimal(320)
    )
    flags = quantity_reconciliation.run(ctx)
    assert [(f.rule_code, f.severity, f.details["loss_pct"]) for f in flags] == (
        [("grading_loss_high", Severity.WARN, loss_pct)] if loss_pct else []
    )


@pytest.mark.parametrize(
    ("kg", "codes"),
    [
        ({"received_kg": 320}, ["batch_quantity_unattributed"]),
        ({"received_kg": 320, "shares_kg": 300}, ["batch_quantity_unattributed"]),
        ({"received_kg": 320, "shares_kg": 310}, []),
        ({"shares_kg": 100, "batch_kg": 20}, []),  # no received kg: nothing to compare
        (
            {"received_kg": 320, "shares_kg": 320, "batch_kg": 290, "grading_loss_warn_pct": 5},
            ["grading_loss_high"],
        ),
    ],
)
def test_batch_attribution_and_tenant_limit(kg: dict[str, object], codes: list[str]) -> None:
    """D-030: shares vs received kg at 5 %, missing shares warn, no received kg is silent; a 5 % tenant limit.

    Args:
        kg: `BatchContext` kilogram fields (and the loss limit).
        codes: expected rule codes.
    """
    assert _batch_codes(**kg) == codes


def test_trail_override_reading_and_profile_incomplete() -> None:
    """A reading accepted with a reason is a warn on the reading; skipped parameters an info on the batch."""
    reading = ReadingFacts(uuid.uuid4(), "moisture", "grading", Decimal("12.0"), "resampled")
    batch = BatchContext(uuid.uuid4(), profile_incomplete=("broken_fruits",), trail_overrides=(reading,))
    [trail] = moisture_trail_override.run(batch)
    assert (trail.subject_type, trail.subject_id) == (FlagSubject.READING, reading.id)
    [info] = profile_incomplete.run(batch)
    assert (info.rule_code, info.severity, info.details) == (
        "profile_incomplete",
        Severity.INFO,
        {"parameters": ["broken_fruits"]},
    )
