"""Rule `event_location`: an event's GPS fix must lie on its plot, else `event_off_plot` (warn).

The PostGIS test (walked boundary, or pin radius, plus the GI tag's drift buffer) runs in the service through
`registry.service.event_within_plot`; this rule only turns its answer into a flag. Flagged, never rejected.
Serves: FR26 (event-time GPS), FR69 (event GPS check), FR32 (drift buffer), FR70 (repeated off-plot events
are a review reason), Stages 1–6.
Callers: `rules.EVENT_RULES` (service `check_event`), tests/unit/test_rules_event.py.
"""

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import EventContext, FlagCandidate

CODES = {"event_off_plot"}
# FR69 "a set radius of the pin" for plots without a walked boundary; the GI buffer is added on top.
# shortcut: one radius for every FPO; move it to config/features.yaml (D-017) once a tenant asks.
PIN_RADIUS_M = 200.0


def run(ctx: EventContext) -> list[FlagCandidate]:
    """Flag an event whose GPS fix is off its plot.

    Args:
        ctx: the event; `on_plot` is None when there was no fix or no plot to compare with.

    Returns:
        One `event_off_plot` warn when `on_plot` is False, else nothing.
    """
    if ctx.on_plot is not False:
        return []
    details = {"pin_radius_m": ctx.pin_radius_m, "buffer_m": ctx.buffer_m}
    return [FlagCandidate(FlagSubject.EVENT, ctx.event_id, "event_off_plot", Severity.WARN, details)]
