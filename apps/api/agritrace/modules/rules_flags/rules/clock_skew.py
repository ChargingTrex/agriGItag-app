"""Rule `clock_skew`: the phone clock was more than 10 minutes off at capture → `clock_skew` (info).

Against the server clock only a device time in the future counts (an offline entry arrives later, so a
device time in the past is normal). GPS time is advisory: Android may derive it from the phone clock on fused
fixes, so agreeing with the device proves nothing, but disagreeing beyond the limit is still reported.
Serves: Arch §Offline-first (three clocks), FR26 (timestamp corroborates when), TODO B06/B08 (gps_time
advisory), Stages 1–7.
Callers: `rules.EVENT_RULES` (service `check_event`), tests/unit/test_rules_event.py.
"""

from datetime import timedelta

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import EventContext, FlagCandidate

CODES = {"clock_skew"}
LIMIT = timedelta(minutes=10)


def run(ctx: EventContext) -> list[FlagCandidate]:
    """Flag a phone clock that is ahead of the server, or off from GPS time, by more than `LIMIT`.

    Args:
        ctx: the event's device, GPS and server times (all timezone-aware).

    Returns:
        One `clock_skew` info naming the clock it was measured against (`server` or `gps_time`), or nothing.
    """
    ahead = ctx.device_time - ctx.server_received_at
    if ahead > LIMIT:
        basis, skew = "server", ahead
    elif ctx.gps_time is not None and abs(ctx.device_time - ctx.gps_time) > LIMIT:
        basis, skew = "gps_time", ctx.device_time - ctx.gps_time
    else:
        return []
    details = {"basis": basis, "skew_s": int(skew.total_seconds()), "limit_s": int(LIMIT.total_seconds())}
    return [FlagCandidate(FlagSubject.EVENT, ctx.event_id, "clock_skew", Severity.INFO, details)]
