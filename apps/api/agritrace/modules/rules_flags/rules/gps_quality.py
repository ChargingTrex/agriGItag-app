"""Rule `gps_quality`: a GPS fix less accurate than the limit raises `gps_poor_accuracy` (info).

Serves: FR67 ("acceptable accuracy"), FR70 (poor GPS accuracy is a review reason), FR26, Stages 0–6.
Callers: `rules.EVENT_RULES` (service `check_event`); `plot_checks` reuses `ACCURACY_LIMIT_M` for pins;
tests/unit/test_rules_event.py.
"""

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import EventContext, FlagCandidate

CODES = {"gps_poor_accuracy"}
# Phones outdoors report 3–10 m; above 30 m the fix may be on the neighbour's field.
# shortcut: one limit for every FPO; move it to config/features.yaml (D-017) after field calibration.
ACCURACY_LIMIT_M = 30.0


def run(ctx: EventContext) -> list[FlagCandidate]:
    """Flag an event whose GPS accuracy radius is above the limit.

    Args:
        ctx: the event (accuracy None means no fix or no reported accuracy: nothing to judge).

    Returns:
        One `gps_poor_accuracy` info, or nothing.
    """
    if ctx.gps_accuracy_m is None or ctx.gps_accuracy_m <= ACCURACY_LIMIT_M:
        return []
    details = {"accuracy_m": ctx.gps_accuracy_m, "limit_m": ACCURACY_LIMIT_M}
    return [FlagCandidate(FlagSubject.EVENT, ctx.event_id, "gps_poor_accuracy", Severity.INFO, details)]
