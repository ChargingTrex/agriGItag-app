"""Rule `profile_incomplete`: a grade computed while limits are still `load_from_standard` → info flag.

The grade engine skips parameters whose limits are not yet loaded from the standard and marks them
`outcome == "profile_incomplete"` in `grade_computations.per_parameter`; the buyer-facing grade is then based
on fewer parameters than the standard names, which the FPO should know.
Serves: FR47–FR49, backend-design §4 ("Parameters with `limits: null` are skipped and raise an info flag
`profile_incomplete`"), TODO B05→B08, Stage 8.
Callers: `rules.BATCH_RULES` (service `check_lot` for a batch), tests/unit/test_rules_lot.py.
"""

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import BatchContext, FlagCandidate

CODES = {"profile_incomplete"}


def run(ctx: BatchContext) -> list[FlagCandidate]:
    """Flag a batch whose latest grade skipped parameters.

    Args:
        ctx: the batch with the parameter codes its latest grade computation skipped.

    Returns:
        One `profile_incomplete` info listing them, or nothing.
    """
    if not ctx.profile_incomplete:
        return []
    details = {"parameters": sorted(ctx.profile_incomplete)}
    return [FlagCandidate(FlagSubject.BATCH, ctx.batch_id, "profile_incomplete", Severity.INFO, details)]
