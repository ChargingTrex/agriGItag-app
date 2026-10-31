"""Unit tests of the event-level rules: event off plot, GPS accuracy, clock skew, photo evidence.

Serves: B08 acceptance ("600 m off plot → `event_off_plot` warn"; the PostGIS distance itself is in
tests/integration/test_rules.py), FR26, FR61, FR69, TODO B06/B08 (gps_time advisory).
Callers: pytest (`make test-unit`), no Docker.
"""

import uuid
from datetime import UTC, date, datetime, timedelta

from agritrace.core.enums import PhotoStatus, Severity
from agritrace.modules.rules_flags.rules import clock_skew, event_location, gps_quality, photo_evidence
from agritrace.modules.rules_flags.rules.context import EventContext, PhotoFacts

NOW = datetime(2026, 3, 4, 8, 0, tzinfo=UTC)


def _ctx(**kw: object) -> EventContext:
    """Build an event context with sane defaults.

    Args:
        **kw: fields to override.

    Returns:
        The context.
    """
    base: dict[str, object] = {
        "event_id": uuid.uuid4(),
        "occurred_on": date(2026, 3, 4),
        "device_time": NOW,
        "server_received_at": NOW + timedelta(hours=5),
    }
    return EventContext(**(base | kw))  # type: ignore[arg-type]


def test_off_plot_event_is_a_warn_with_the_limits() -> None:
    """An event the PostGIS check put off its plot raises one warn naming radius and buffer."""
    [flag] = event_location.run(_ctx(on_plot=False, pin_radius_m=200, buffer_m=150))
    assert (flag.rule_code, flag.severity) == ("event_off_plot", Severity.WARN)
    assert flag.details == {"pin_radius_m": 200, "buffer_m": 150}


def test_on_plot_or_unknown_location_raises_nothing() -> None:
    """On the plot, or no GPS fix to compare, is no flag."""
    assert event_location.run(_ctx(on_plot=True)) == []
    assert event_location.run(_ctx(on_plot=None)) == []


def test_poor_accuracy_is_info_and_good_accuracy_is_silent() -> None:
    """Accuracy above 30 m is an info flag; 30 m or better, or none reported, is fine."""
    assert [f.severity for f in gps_quality.run(_ctx(gps_accuracy_m=45.0))] == [Severity.INFO]
    assert gps_quality.run(_ctx(gps_accuracy_m=30.0)) == []
    assert gps_quality.run(_ctx(gps_accuracy_m=None)) == []


def test_device_clock_ahead_of_server_is_skew() -> None:
    """A device time more than 10 minutes in the server's future is flagged against the server."""
    [flag] = clock_skew.run(_ctx(device_time=NOW + timedelta(minutes=11), server_received_at=NOW))
    assert flag.details["basis"] == "server"


def test_offline_entry_arriving_late_is_not_skew() -> None:
    """A device time hours before the server time is just an offline entry."""
    assert clock_skew.run(_ctx()) == []


def test_gps_time_disagreeing_is_reported_as_advisory_basis() -> None:
    """GPS time 2 hours away from the device clock is reported, with basis `gps_time`."""
    [flag] = clock_skew.run(_ctx(gps_time=NOW + timedelta(hours=2)))
    assert flag.details["basis"] == "gps_time"
    assert flag.severity == Severity.INFO


def test_photo_statuses_become_flags_one_per_photo() -> None:
    """Checksum mismatch and B06 EXIF mismatch each raise one warn keyed by the photo."""
    bad_hash, bad_exif = uuid.uuid4(), uuid.uuid4()
    photos = (
        PhotoFacts(bad_hash, PhotoStatus.CHECKSUM_MISMATCH),
        PhotoFacts(bad_exif, PhotoStatus.EXIF_MISMATCH),
        PhotoFacts(uuid.uuid4(), PhotoStatus.VERIFIED, NOW),
    )
    flags = photo_evidence.run(_ctx(photos=photos))
    assert [(f.rule_code, f.discriminator) for f in flags] == [
        ("photo_checksum_mismatch", str(bad_hash)),
        ("exif_mismatch", str(bad_exif)),
    ]


def test_photo_taken_days_before_occurred_on_is_exif_mismatch() -> None:
    """A verified photo taken 3 days before the stated day is flagged; one day off is normal."""
    early = PhotoFacts(uuid.uuid4(), PhotoStatus.VERIFIED, NOW - timedelta(days=3))
    [flag] = photo_evidence.run(_ctx(photos=(early,)))
    assert flag.details["reasons"] == ["exif_vs_occurred_on"]
    next_day = PhotoFacts(uuid.uuid4(), PhotoStatus.VERIFIED, NOW + timedelta(days=1))
    assert photo_evidence.run(_ctx(photos=(next_day,))) == []
