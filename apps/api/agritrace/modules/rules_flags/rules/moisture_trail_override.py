"""Rule `moisture_trail_override`: a reading accepted with a `reason_code` → `moisture_trail_override`.

Quality (B05) accepts a moisture reading that breaks the non-increasing trail only with a reason and asks for
this flag by task hint; running the rule on every lot/batch check also sweeps up overrides whose enqueue was
lost while the broker was down (B05 `shortcut:`).
Serves: FR50 (trail rule, "override with reason → flag"), backend-design §4 `trail_rules`, Stages 5–8.
Callers: `rules.LOT_RULES` and `rules.BATCH_RULES` (service `check_lot`), tests/unit/test_rules_lot.py.
"""

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import BatchContext, FlagCandidate, LotContext

CODES = {"moisture_trail_override"}


def run(ctx: LotContext | BatchContext) -> list[FlagCandidate]:
    """Flag each overridden reading of the lot or batch.

    Args:
        ctx: a lot or batch context with its readings that carry a `reason_code`.

    Returns:
        One warn per reading (subject: the reading), with parameter, stage, value and reason.
    """
    return [
        FlagCandidate(
            FlagSubject.READING,
            r.id,
            "moisture_trail_override",
            Severity.WARN,
            {"parameter": r.parameter, "stage": r.stage, "value": str(r.value), "reason_code": r.reason_code},
        )
        for r in ctx.trail_overrides
    ]
