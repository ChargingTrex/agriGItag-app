"""Rule `plot_checks`: review reasons of a plot (map pin, GI edge/outside, accuracy, taluk, area gap).

The plot API (B03) already ran the GI region check and stored `location_status`; this rule raises the flags a
reviewer works from. A plot outside the GI region is a hold (it may not feed a GI-labelled batch until an FPO
admin reviews it, FR28); the other reasons are warns or info.
Serves: FR28 (outside GI → flagged, not blocked), FR53 (second GI check: taluks of the GI registration),
FR64–FR67 (pin method, accuracy, walked area), FR70 (review only on flags), Stage 0 (onboarding).
Callers: `rules.PLOT_RULES` (service `check_plot`), tests/unit/test_rules_plot.py.
"""

from typing import Any

from agritrace.core.enums import FlagSubject, LocationStatus, PinMethod, Severity
from agritrace.modules.registry.service import area_gap
from agritrace.modules.rules_flags.rules.context import FlagCandidate, PlotContext
from agritrace.modules.rules_flags.rules.gps_quality import ACCURACY_LIMIT_M

CODES = {
    "plot_map_pin",
    "plot_needs_review",
    "plot_near_edge",
    "plot_outside_gi_region",
    "gps_poor_accuracy",
    "plot_taluk_outside_gi",
    "plot_area_gap",
}


def run(ctx: PlotContext) -> list[FlagCandidate]:
    """Collect the plot's review reasons.

    Args:
        ctx: the plot with its stored location status, pin method, accuracy, farmer taluk and areas.

    Returns:
        Flags (subject: the plot): `plot_map_pin` (warn, a map pin nobody reviewed yet), `plot_needs_review`
        (warn: no region check, or a rejected review), `plot_near_edge` (warn), `plot_outside_gi_region`
        (hold), `gps_poor_accuracy` (info), `plot_taluk_outside_gi` (warn) and `plot_area_gap` (warn, walked
        area more than 20 % from declared).
    """
    found: list[tuple[str, Severity, dict[str, Any]]] = []
    if ctx.pin_method == PinMethod.MAP_PIN and ctx.review_outcome is None:
        found.append(("plot_map_pin", Severity.WARN, {}))
    elif ctx.location_status == LocationStatus.NEEDS_REVIEW:
        found.append(("plot_needs_review", Severity.WARN, {"review_outcome": ctx.review_outcome}))
    if ctx.location_status == LocationStatus.NEAR_EDGE:
        found.append(("plot_near_edge", Severity.WARN, {}))
    if ctx.location_status == LocationStatus.OUTSIDE:
        found.append(("plot_outside_gi_region", Severity.HOLD, {}))
    if ctx.pin_accuracy_m is not None and ctx.pin_accuracy_m > ACCURACY_LIMIT_M:
        found.append(("gps_poor_accuracy", Severity.INFO, {"accuracy_m": ctx.pin_accuracy_m}))
    taluks = {t.casefold() for t in ctx.region_taluks or ()}
    if taluks and ctx.taluk and ctx.taluk.casefold() not in taluks:
        details = {"taluk": ctx.taluk, "gi_taluks": sorted(ctx.region_taluks or ())}
        found.append(("plot_taluk_outside_gi", Severity.WARN, details))
    gap_pct, too_far = area_gap(ctx.declared_acres, ctx.walked_acres)
    if too_far:
        found.append(("plot_area_gap", Severity.WARN, {"gap_pct": str(gap_pct)}))
    return [FlagCandidate(FlagSubject.PLOT, ctx.plot_id, code, sev, dict(d)) for code, sev, d in found]
