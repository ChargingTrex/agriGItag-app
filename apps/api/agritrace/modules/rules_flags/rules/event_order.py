"""Rule `event_order`: an event dated before an earlier step of its crop track → `event_out_of_order`.

Port of apps/mobile/lib/core/rules/event_order.dart `orderGaps` (same inputs, same answer; held equal by
tests/fixtures/rule_cases.json). Each crop's `event_schema.tracks` lists event types in date order; tracks are
independent, so a nursery dated before land preparation is normal (PRD §12.2 "Nursery before ploughing").
Serves: FR55 (nursery split from the main field, date-order rules per crop), FR22, PRD §12.2, Stages 1–6.
Callers: `rules.LOT_RULES` (service `check_lot`), tests/unit/test_rules_lot.py and test_rules_shared_cases.py.
"""

from collections.abc import Iterable, Mapping, Sequence
from datetime import date

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import FlagCandidate, LotContext, LotEvent

CODES = {"event_out_of_order"}


def order_gaps(
    tracks: Mapping[str, Sequence[str]], recorded: Iterable[LotEvent], new_type: str, on: date
) -> list[str]:
    """List the earlier steps of every track containing `new_type` that have no event on or before `on`.

    Args:
        tracks: track name → event types in required date order (`event_schema.tracks`).
        recorded: the lot's events (the event itself may be included; its own type is never a predecessor).
        new_type: type of the event being checked.
        on: the day it happened.

    Returns:
        The missing steps once each, in track order; empty when the order is fine or the type is in no track.
    """
    done = [e for e in recorded if e.on <= on]
    gaps: dict[str, None] = {}  # ordered set, like the Dart set literal
    for steps in tracks.values():
        if new_type in steps:
            for step in steps[: list(steps).index(new_type)]:
                if not any(e.type == step for e in done):
                    gaps[step] = None
    return list(gaps)


def run(ctx: LotContext) -> list[FlagCandidate]:
    """Flag each event of the lot that is dated before a step its track needs first.

    Args:
        ctx: the lot with its live events and the crop's `event_schema` `{mandatory, tracks}`.

    Returns:
        One `event_out_of_order` warn per such event (subject: the event), with the `missing` steps.
    """
    tracks = ctx.event_schema.get("tracks") or {}
    # A step is done by a date iff its earliest event is on or before it, so the earliest event of each type
    #   gives `order_gaps` the same answer as all of them: O(events × types) instead of O(events²) (B22).
    firsts = {e.type: e for e in sorted(ctx.events, key=lambda e: e.on, reverse=True)}.values()
    flags = []
    for event in ctx.events:
        if missing := order_gaps(tracks, firsts, event.type, event.on):
            details = {"event_type": event.type, "occurred_on": event.on.isoformat(), "missing": missing}
            flags.append(
                FlagCandidate(FlagSubject.EVENT, event.id, "event_out_of_order", Severity.WARN, details)
            )
    return flags
