"""Rule `yield_ceiling`: harvest above declared acres × profile ceiling → `yield_over_ceiling` warn/hold.

Up to the warn margin above the ceiling passes; up to the hold margin is a warn; above is a hold, which the
service turns into `lots.gi_eligible = false` with the reason. Without a harvest quantity (or without a yield
rule) the check is impossible and says so: `yield_check_unavailable` (info).
Serves: FR57 (harvest quantity with a yield plausibility check), FR68 (20 %/30 % margins), FR70, PRD §12.2
("No harvest quantity"), Dataflow Stage 7.
Callers: `rules.LOT_RULES` (service `check_lot`), tests/unit/test_rules_lot.py.
"""

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import FlagCandidate, LotContext

CODES = {"yield_over_ceiling", "yield_check_unavailable"}


def run(ctx: LotContext) -> list[FlagCandidate]:
    """Compare the lot's harvest with declared area × the yield ceiling.

    Args:
        ctx: the lot with `harvested_kg`, `declared_acres` and the profile's `yield_limits`.

    Returns:
        Nothing when within the warn margin; `yield_over_ceiling` warn or hold above it;
        `yield_check_unavailable` info when the harvest, the area or the yield rule is missing.
    """
    if ctx.harvested_kg is None or ctx.yield_limits is None or not ctx.declared_acres:
        reason = "no_harvest_quantity" if ctx.harvested_kg is None else "no_yield_rule_or_area"
        details = {"reason": reason}
        return [FlagCandidate(FlagSubject.LOT, ctx.lot_id, "yield_check_unavailable", Severity.INFO, details)]
    # DECISION D-015: ceiling and both margins come from the crop's Standards Profile, never from code.
    #   ADV: the compliance team tunes 20 %/30 % per crop after season 1 by publishing a profile version.
    #   COMPROMISE: a crop without a published profile cannot be checked (flagged as unavailable instead).
    ceiling, warn_pct, hold_pct = ctx.yield_limits
    excess_pct = (ctx.harvested_kg / (ceiling * ctx.declared_acres) - 1) * 100
    if excess_pct <= warn_pct:
        return []
    severity = Severity.WARN if excess_pct <= hold_pct else Severity.HOLD
    details = {
        "harvested_kg": str(ctx.harvested_kg),
        "declared_acres": str(ctx.declared_acres),
        "ceiling_kg_per_acre": str(ceiling),
        "excess_pct": str(round(excess_pct, 1)),
        "warn_margin_pct": str(warn_pct),
        "hold_margin_pct": str(hold_pct),
    }
    return [FlagCandidate(FlagSubject.LOT, ctx.lot_id, "yield_over_ceiling", severity, details)]
