"""The server rule set: one module per rule, grouped by the subject they check (no rule engine, no DSL).

Each rule module exposes `run(ctx) -> list[FlagCandidate]` and `CODES` (the rule codes it can raise, used to
close flags a later run no longer raises).
Serves: Arch §Rules and flags, plan §7.1 B08, D-006.
Callers: rules_flags service (`check_event`, `check_plot`, `check_lot`, `run_gate_checks`); tests.
"""

from types import ModuleType
from typing import Any

from agritrace.modules.rules_flags.rules import (
    clock_skew,
    event_location,
    event_order,
    gps_quality,
    moisture_trail_override,
    photo_evidence,
    plot_checks,
    practice_tags,
    profile_incomplete,
    quantity_reconciliation,
    yield_ceiling,
)
from agritrace.modules.rules_flags.rules.context import FlagCandidate

# DECISION D-006: every rule runs again on the server, whatever the phone preview showed; the rules the
#   phone also runs (event_order, practice_tags, GI check) are held equal by tests/fixtures/rule_cases.json.
#   ADV: the server is the single source of truth for flags, holds and GI eligibility (Arch §Offline-first).
#   COMPROMISE: two implementations (Dart, Python) of those rules; mitigated by the shared fixture cases.
EVENT_RULES: dict[str, ModuleType] = {
    "event_location": event_location,
    "gps_quality": gps_quality,
    "clock_skew": clock_skew,
    "photo_evidence": photo_evidence,
}
LOT_RULES: dict[str, ModuleType] = {
    "event_order": event_order,
    "practice_tags": practice_tags,
    "yield_ceiling": yield_ceiling,
    "quantity_reconciliation": quantity_reconciliation,
    "moisture_trail_override": moisture_trail_override,
}
BATCH_RULES: dict[str, ModuleType] = {
    "quantity_reconciliation": quantity_reconciliation,
    "profile_incomplete": profile_incomplete,
    "moisture_trail_override": moisture_trail_override,
}
PLOT_RULES: dict[str, ModuleType] = {"plot_checks": plot_checks}


def run_all(group: dict[str, ModuleType], ctx: Any) -> list[FlagCandidate]:
    """Run every rule of a group on one context.

    Args:
        group: one of the groups above.
        ctx: the context those rules take.

    Returns:
        Every candidate raised, in group order.
    """
    return [c for module in group.values() for c in module.run(ctx)]


def codes(group: dict[str, ModuleType]) -> set[str]:
    """List every rule code a group can raise (the scope a run may close flags in).

    Args:
        group: one of the groups above.

    Returns:
        The union of the modules' `CODES`.
    """
    return set().union(*(module.CODES for module in group.values()))
