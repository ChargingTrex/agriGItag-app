"""Unit tests of the pure grade engine, driven by the shared cases in tests/fixtures/grade_cases.json.

Serves: B05 acceptance (9.8 → Special, 10.5 → Standard, 11.4 → Below grade, visual cap, incomplete,
moisture −1, trail 12.0 after 10.0, declared above computed), FR44, FR48–FR50, FR68, Dataflow Stages 5,
7, 8, D-006 (the same JSON cases run against the Dart preview engine in M03), D-015 (one engine, four crops).
Callers: pytest (`make test-unit`); no Docker.
"""

import json
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest

from agritrace.modules.quality import grade_engine as ge
from agritrace.modules.quality.schemas import StandardsProfileRules

CASES: dict[str, Any] = json.loads((Path(__file__).parents[1] / "fixtures" / "grade_cases.json").read_text())
PROFILES_DIR = Path(ge.__file__).parent / "profiles"


def _rules(name: str) -> StandardsProfileRules:
    """Resolve a case's profile name to validated rules.

    Args:
        name: a key of the fixture's `profiles`, or a file name (without .json) in the profiles folder.

    Returns:
        The validated profile rules.
    """
    raw = CASES["profiles"].get(name) or json.loads((PROFILES_DIR / f"{name}.json").read_text())
    return StandardsProfileRules.model_validate(raw)


def _ids(kind: str) -> list[str]:
    """Name each case of a section for pytest output.

    Args:
        kind: fixture section, e.g. `compute`.

    Returns:
        The case names in order.
    """
    return [c["name"] for c in CASES[kind]]


@pytest.mark.parametrize("case", CASES["compute"], ids=_ids("compute"))
def test_compute(case: dict[str, Any]) -> None:
    """The computed status, grade and the optional expectations match the case.

    Args:
        case: one `compute` fixture case.
    """
    readings = [ge.Reading.model_validate(r) for r in case["readings"]]
    result = ge.compute(_rules(case["profile"]), readings, case.get("exception_flags", ()))
    want = case["expect"]
    assert (result.status, result.grade) == (want["status"], want["grade"])
    for key in ("lab_certified", "profile_incomplete", "missing_required", "warnings"):
        if key in want:
            assert getattr(result, key) == want[key], key
    if "capped" in want:
        assert [c for c, p in result.per_parameter.items() if p.capped_by_source] == want["capped"]


@pytest.mark.parametrize("case", CASES["declared"], ids=_ids("declared"))
def test_declared_vs_computed(case: dict[str, Any]) -> None:
    """Declared grade versus computed grade gives the expected verdict (FR49).

    Args:
        case: one `declared` fixture case.
    """
    assert (
        ge.declared_vs_computed(_rules(case["profile"]), case["declared"], case["computed"]) == case["expect"]
    )


@pytest.mark.parametrize("case", CASES["plausibility"], ids=_ids("plausibility"))
def test_check_plausibility(case: dict[str, Any]) -> None:
    """Entry checks report exactly the expected violation codes, in order (FR50).

    Args:
        case: one `plausibility` fixture case.
    """
    found = ge.check_plausibility(_rules(case["profile"]), ge.Reading.model_validate(case["reading"]))
    assert [v.code for v in found] == case["expect"]


@pytest.mark.parametrize("case", CASES["trail"], ids=_ids("trail"))
def test_check_trail(case: dict[str, Any]) -> None:
    """The moisture trail rule fires only on a rise beyond the tolerance (FR50).

    Args:
        case: one `trail` fixture case.
    """
    prior = [ge.Reading.model_validate(r) for r in case["prior"]]
    found = ge.check_trail(_rules(case["profile"]), prior, ge.Reading.model_validate(case["reading"]))
    assert (found.code if found else None) == case["expect"]
    if found:
        assert found.overridable is case["overridable"]


@pytest.mark.parametrize("case", CASES["yield"], ids=_ids("yield"))
def test_yield_outcome(case: dict[str, Any]) -> None:
    """Yield versus declared area × ceiling gives pass, warn or hold at the 20 %/30 % margins (FR68).

    Args:
        case: one `yield` fixture case.
    """
    outcome = ge.yield_outcome(_rules(case["profile"]), Decimal(str(case["kg"])), Decimal(str(case["acres"])))
    assert outcome == case["expect"]


@pytest.mark.parametrize("case", CASES["lot_gate"], ids=_ids("lot_gate"))
def test_lot_gate(case: dict[str, Any]) -> None:
    """The ready-for-sale gate opens only on a drying-end reading within the limit (Dataflow Stage 5).

    Args:
        case: one `lot_gate` fixture case.
    """
    readings = [ge.Reading.model_validate(r) for r in case["readings"]]
    assert ge.lot_gate(_rules(case["profile"]), case["gate"], readings) is case["expect"]


def test_rank_orders_grades_then_fail_grade() -> None:
    """Grades rank best first, the fail grade last, unknown names None."""
    rules = _rules("dry_chilli_agmark_v1")
    assert [ge.rank(rules, g) for g in ("Special", "Standard", "Below grade", "A")] == [0, 1, 2, None]


def test_per_parameter_reports_reading_and_limit() -> None:
    """The per-parameter detail names the value, the limit of the grade reached and skipped parameters."""
    reading = ge.Reading(
        parameter_code="moisture", value=Decimal("10.5"), unit="%", stage="grading", source="lab"
    )
    per = ge.compute(_rules("dry_chilli_agmark_v1"), [reading]).per_parameter
    assert per["moisture"].grade == "Standard"
    assert per["moisture"].limit is not None and per["moisture"].limit.max == Decimal("11.0")
    assert per["extraneous_matter"].outcome == "profile_incomplete"
    assert per["capsaicinoid"].outcome == "not_graded"
