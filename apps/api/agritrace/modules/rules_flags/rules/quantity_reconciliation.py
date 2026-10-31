"""Rule `quantity_reconciliation`: harvested ≥ packed ≥ received ≥ used per lot; batch kg vs farmer shares.

Lot: consecutive recorded steps of the chain are compared; a step more than 5 % above the one before breaks
the chain, and so does one more than 5 % below it, except after harvest (drying and sorting lose weight
between harvest and packing; between packing, sale and use nothing should go missing) → `quantity_mismatch`.
Batch: the kilograms in the batch must be attributed back to farmers' shares within 5 % →
`batch_quantity_unattributed`.
Serves: FR11, FR60 (per-lot reconciliation), PRD §12.2 ("Quantities don't reconcile"; "the 20 kg batch is
never attributed back"), Dataflow Stages 6–8.
Callers: `rules.LOT_RULES` and `rules.BATCH_RULES` (service `check_lot`), tests/unit/test_rules_lot.py.
"""

from decimal import Decimal

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import BatchContext, FlagCandidate, LotContext

CODES = {"quantity_mismatch", "batch_quantity_unattributed"}
TOLERANCE = Decimal("0.05")


def _pct(value: Decimal, base: Decimal) -> str:
    """Variance of `value` against `base` in percent, as text.

    Args:
        value: the later quantity.
        base: the earlier quantity (> 0).

    Returns:
        `(value / base - 1) × 100` rounded to 0.1, e.g. `"44.9"`.
    """
    return str(round((value / base - 1) * 100, 1))


def _lot(ctx: LotContext) -> list[FlagCandidate]:
    """Check the lot's quantity chain.

    Args:
        ctx: the lot with harvested / packed / received / used kilograms (None when not recorded).

    Returns:
        One `quantity_mismatch` warn listing every broken link, or nothing.
    """
    chain = {
        "harvested": ctx.harvested_kg,
        "packed": ctx.packed_kg,
        "received": ctx.received_kg,
        "used": ctx.used_kg,
    }
    steps = [(name, kg) for name, kg in chain.items() if kg is not None]
    problems = []
    for (prev, base), (name, kg) in zip(steps, steps[1:], strict=False):
        over = kg > base * (1 + TOLERANCE)
        short = prev != "harvested" and kg < base * (1 - TOLERANCE)
        if over or short:
            problems.append({"from": prev, "to": name, "variance_pct": _pct(kg, base) if base else None})
    if not problems:
        return []
    details = {name: str(kg) for name, kg in steps} | {"unit": "kg", "problems": problems}
    return [FlagCandidate(FlagSubject.LOT, ctx.lot_id, "quantity_mismatch", Severity.WARN, details)]


def _batch(ctx: BatchContext) -> list[FlagCandidate]:
    """Check that the batch's kilograms are attributed to farmer shares.

    Args:
        ctx: the batch with its output kilograms and the sum of its shares.

    Returns:
        One `batch_quantity_unattributed` warn when there are kilograms but no shares, or the two differ by
        more than 5 %; else nothing.
    """
    # shortcut: normal grading loss above 5 % also warns here (B08 review P2-4); Architect-Gate ruling
    #   pending on comparing shares with received kg instead, before B09 lets warns block publish.
    if not ctx.batch_kg:
        return []
    shares = ctx.shares_kg or Decimal(0)
    if shares and abs(ctx.batch_kg - shares) <= shares * TOLERANCE:
        return []
    details = {"batch_kg": str(ctx.batch_kg), "shares_kg": str(shares), "unit": "kg"}
    return [
        FlagCandidate(FlagSubject.BATCH, ctx.batch_id, "batch_quantity_unattributed", Severity.WARN, details)
    ]


def run(ctx: LotContext | BatchContext) -> list[FlagCandidate]:
    """Run the lot or the batch reconciliation, by context type.

    Args:
        ctx: a lot or a batch context.

    Returns:
        The flags of `_lot` or `_batch`.
    """
    return _lot(ctx) if isinstance(ctx, LotContext) else _batch(ctx)
