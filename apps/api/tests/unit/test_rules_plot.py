"""Unit tests of the plot review rule: map pin, GI edge/outside, accuracy, taluk (FR53), walked-area gap.

Serves: FR28, FR53, FR64–FR67, FR70, TODO B03→B08.
Callers: pytest (`make test-unit`), no Docker.
"""

import uuid
from decimal import Decimal

from agritrace.core.enums import LocationStatus, PinMethod, Severity
from agritrace.modules.rules_flags.rules import plot_checks
from agritrace.modules.rules_flags.rules.context import PlotContext


def _codes(**kw: object) -> dict[str, Severity]:
    """Run the rule on a confirmed live-GPS plot with overrides.

    Args:
        **kw: fields to override.

    Returns:
        Raised rule codes with their severity.
    """
    base: dict[str, object] = {
        "plot_id": uuid.uuid4(),
        "pin_method": PinMethod.LIVE_GPS,
        "location_status": LocationStatus.CONFIRMED,
        "declared_acres": Decimal(1),
    }
    return {f.rule_code: f.severity for f in plot_checks.run(PlotContext(**(base | kw)))}  # type: ignore[arg-type]


def test_confirmed_live_pin_raises_nothing() -> None:
    """A confirmed live-GPS pin with good accuracy and matching taluk needs no review."""
    assert _codes(pin_accuracy_m=5.0, taluk="Tiruchuli", region_taluks=("Tiruchuli",)) == {}


def test_review_reasons() -> None:
    """Map pin, outside (hold), poor accuracy, foreign taluk and a 30 % area gap each raise their flag."""
    assert _codes(pin_method=PinMethod.MAP_PIN, location_status=LocationStatus.NEEDS_REVIEW) == {
        "plot_map_pin": Severity.WARN
    }
    assert _codes(pin_method=PinMethod.MAP_PIN, review_outcome="accepted") == {}
    rejected = {"pin_method": PinMethod.MAP_PIN, "review_outcome": "rejected"}
    assert _codes(**rejected, location_status=LocationStatus.NEEDS_REVIEW) == {
        "plot_needs_review": Severity.WARN
    }
    assert _codes(location_status=LocationStatus.OUTSIDE) == {"plot_outside_gi_region": Severity.HOLD}
    assert _codes(location_status=LocationStatus.NEAR_EDGE) == {"plot_near_edge": Severity.WARN}
    assert _codes(pin_accuracy_m=50.0) == {"gps_poor_accuracy": Severity.INFO}
    assert _codes(taluk="Madurai South", region_taluks=("Tiruchuli", "Aruppukottai")) == {
        "plot_taluk_outside_gi": Severity.WARN
    }
    assert _codes(walked_acres=Decimal("1.3")) == {"plot_area_gap": Severity.WARN}
    assert _codes(walked_acres=Decimal("1.2")) == {}
