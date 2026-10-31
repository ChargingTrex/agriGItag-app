"""Shared phone/server cases (tests/fixtures/rule_cases.json) run through the Python rules (D-006).

The same file feeds the Dart preview tests (M03), so both sides give the same answer for event order and
practice tags; the `gi_check` cases need PostGIS and run in tests/integration/test_rules.py.
Serves: D-006 (phone preview equals server authority), FR55, FR56, TODO B08 (port and shared fixture).
Callers: pytest (`make test-unit`), no Docker.
"""

import json
import uuid
from datetime import date
from pathlib import Path
from typing import Any

import pytest

from agritrace.modules.rules_flags.rules.context import LotEvent
from agritrace.modules.rules_flags.rules.event_order import order_gaps
from agritrace.modules.rules_flags.rules.practice_tags import derived_tags, practice_flags

CASES = json.loads((Path(__file__).parents[1] / "fixtures" / "rule_cases.json").read_text())
ORDER = CASES["event_order"]


@pytest.mark.parametrize("case", ORDER["cases"], ids=lambda c: c["name"])
def test_event_order_case(case: dict[str, Any]) -> None:
    """`order_gaps` returns the fixture's gaps.

    Args:
        case: one fixture case.
    """
    recorded = [LotEvent(uuid.uuid4(), e["type"], date.fromisoformat(e["on"])) for e in case["recorded"]]
    gaps = order_gaps(
        ORDER["event_schema"]["tracks"], recorded, case["new_type"], date.fromisoformat(case["on"])
    )
    assert gaps == case["gaps"]


@pytest.mark.parametrize("case", CASES["practice_tags"]["cases"], ids=lambda c: c["name"])
def test_practice_tags_case(case: dict[str, Any]) -> None:
    """`derived_tags` and `practice_flags` return the fixture's derived tags and flags, in order.

    Args:
        case: one fixture case.
    """
    assert sorted(derived_tags(case["input_categories"])) == case["derived"]
    assert practice_flags(case["declared"], case["input_categories"], case["has_pest_event"]) == case["flags"]
