"""Unit tests of `StandardsProfileRules` and the reading schema: the cross-checks that keep a profile sane.

Serves: B05 deliverable 1 (limits keys ⊆ grades, grading_stage ∈ capture_stages, load_from_standard ⇒ limits
null), FR47, D-015, backend-design.md §4.
Callers: pytest (`make test-unit`); no Docker.
"""

import copy
import json
import uuid
from pathlib import Path
from typing import Any

import pytest
from pydantic import ValidationError

from agritrace.modules.quality.schemas import QualityReadingIn, StandardsProfileRules

CHILLI: dict[str, Any] = json.loads(
    (Path(__file__).parents[2] / "agritrace/modules/quality/profiles/dry_chilli_agmark_v1.json").read_text()
)


def test_seed_profile_round_trips_with_the_yield_alias() -> None:
    """The §4 JSON validates and dumps back with the `yield` key (not `yield_`) and numeric limits."""
    rules = StandardsProfileRules.model_validate(CHILLI)
    dumped = rules.model_dump(mode="json", by_alias=True, exclude_none=True)
    assert dumped["yield"]["ceiling_kg_per_acre"] == 1000  # a JSON number, not a string
    assert StandardsProfileRules.model_validate(dumped) == rules


def _broken(path: list[Any], value: Any) -> dict[str, Any]:
    """Copy the chilli profile with one value replaced.

    Args:
        path: keys/indexes leading to the value.
        value: the replacement.

    Returns:
        The modified copy.
    """
    raw = copy.deepcopy(CHILLI)
    target = raw
    for key in path[:-1]:
        target = target[key]
    target[path[-1]] = value
    return raw


@pytest.mark.parametrize(
    ("path", "value", "message"),
    [
        (["parameters", 0, "limits"], {"Premium": {"max": 9}}, "unknown grade"),
        (["parameters", 0, "limits"], {"Special": {"max": 10}}, "a key for every grade"),
        (["parameters", 0, "max_grade_for_source"], {"visual": "Gold"}, "unknown grade"),
        (["parameters", 0, "grading_stage"], "storage", "not in capture_stages"),
        (["parameters", 1, "limits"], {"Special": {"max": 1}, "Standard": {"max": 2}}, "load_from_standard"),
        (["fail_grade"], "Special", "fail_grade"),
        (["lot_gates", "ready_for_sale", "parameter"], "colour", "unknown parameter"),
        (["trail_rules", 0, "parameter"], "colour", "unknown parameter"),
        (["parameters", 0, "limits", "Special"], {"min": 12, "max": 10}, "above max"),
        (["parameters", 0, "colour"], "red", "Extra inputs"),
        (["schema_version"], 2, "schema_version"),
        (["yield", "hold_margin_pct"], 10, "hold_margin_pct"),
    ],
)
def test_cross_checks_reject_inconsistent_profiles(path: list[Any], value: Any, message: str) -> None:
    """Each broken reference is rejected with a message naming it.

    Args:
        path: where to break the profile.
        value: the bad value.
        message: text expected in the validation error.
    """
    with pytest.raises(ValidationError, match=message):
        StandardsProfileRules.model_validate(_broken(path, value))


def test_limits_with_an_empty_range_per_grade_are_accepted() -> None:
    """`{}` spells out "no constraint" for a grade, so a full map with an open grade is valid (F6)."""
    rules = StandardsProfileRules.model_validate(
        _broken(["parameters", 0, "limits"], {"Special": {"max": 10}, "Standard": {}})
    )
    assert rules.parameters[0].limits is not None and rules.parameters[0].limits["Standard"].max is None


def test_every_percent_parameter_of_the_seed_profile_is_range_checked() -> None:
    """FR50 ruling (F7): every `%` parameter carries plausible 0–100, pending ones keep limits null."""
    rules = StandardsProfileRules.model_validate(CHILLI)
    percent = [p for p in rules.parameters if p.unit == "%"]
    assert len(percent) == 7
    assert all(p.plausible is not None and (p.plausible.min, p.plausible.max) == (0, 100) for p in percent)


def test_duplicate_parameter_codes_rejected() -> None:
    """Two parameters with one code are rejected."""
    raw = copy.deepcopy(CHILLI)
    raw["parameters"].append(raw["parameters"][-1])
    with pytest.raises(ValidationError, match="unique"):
        StandardsProfileRules.model_validate(raw)


def _reading(**over: Any) -> dict[str, Any]:
    """Build a valid reading body with overrides.

    Args:
        **over: fields to replace.

    Returns:
        The request body.
    """
    body = {
        "client_id": str(uuid.uuid4()),
        "lot_id": str(uuid.uuid4()),
        "stage": "drying_end",
        "parameter_code": "moisture",
        "measurement": {"value": -1, "unit": "%"},
        "source": "lab",
        "measured_at": "2026-03-04T08:12:10+05:30",
    }
    return {**body, **over}


def test_reading_accepts_negative_value_for_the_plausibility_check() -> None:
    """−1 % passes the schema so the service can answer `implausible_value` rather than a generic error."""
    assert QualityReadingIn.model_validate(_reading()).measurement.value == -1


@pytest.mark.parametrize(
    ("over", "message"),
    [
        ({"batch_id": str(uuid.uuid4())}, "exactly one"),
        ({"lot_id": None}, "exactly one"),
        ({"source": "instrument"}, "instrument_id"),
    ],
)
def test_reading_subject_and_instrument_rules(over: dict[str, Any], message: str) -> None:
    """A reading names exactly one subject, and an instrument reading names its instrument.

    Args:
        over: fields to change.
        message: text expected in the validation error.
    """
    with pytest.raises(ValidationError, match=message):
        QualityReadingIn.model_validate(_reading(**over))
