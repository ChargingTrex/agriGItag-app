"""UTC clock and the three-clocks skew check.

Serves: Arch §Offline-first (device, GPS and server clocks), B06/B08 `clock_skew` flag.
Callers: events service (stamps `server_received_at`), rules_flags clock_skew rule,
tests/unit/test_schemas.py.
"""

from datetime import UTC, datetime, timedelta

from agritrace.core.schemas import ThreeClocks


def utcnow() -> datetime:
    """Return the current time.

    Returns:
        A timezone-aware datetime in UTC.
    """
    return datetime.now(UTC)


def clock_skew(clocks: ThreeClocks, limit: timedelta) -> timedelta | None:
    """Measure how far the phone clock is from a trusted clock, if beyond `limit`.

    GPS time is preferred as the reference because it was taken at capture; server time is the fallback.

    Args:
        clocks: the entry's three clocks.
        limit: largest tolerated absolute difference.

    Returns:
        `device_time - reference` when its absolute value exceeds `limit`; None when within the limit
        or when there is no reference clock.
    """
    reference = clocks.gps_time or clocks.server_received_at
    if reference is None:
        return None
    skew = clocks.device_time - reference
    return skew if abs(skew) > limit else None
