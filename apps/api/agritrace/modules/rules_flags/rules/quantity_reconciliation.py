"""Rule `quantity_reconciliation`: harvested ≥ packed ≥ received ≥ used per lot; batch attribution and loss.

Lot: consecutive recorded steps of the chain are compared; a step more than 5 % above the one before breaks
the chain, and so does one more than 5 % below it, except after harvest (drying and sorting lose weight
between harvest and packing; between packing, sale and use nothing should go missing) → `quantity_mismatch`.
Batch (D-030): the received kilograms must be attributed to farmers' shares within 5 % →
`batch_quantity_unattributed`; the output (packed, else graded) must not fall more than
`grading_loss_warn_pct` below the received kilograms, nor rise more than 5 % above them → `grading_loss_high`.
Serves: FR11, FR60 (per-lot reconciliation), PRD §12.2 ("Quantities don't reconcile"; "the 20 kg batch is
never attributed back"), Dataflow Stages 6–8, D-030.
Callers: `rules.LOT_RULES` and `rules.BATCH_RULES` (service `check_lot`), tests/unit/test_rules_lot.py.
"""

from decimal import Decimal

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import BatchContext, FlagCandidate, LotContext

CODES = {"quantity_mismatch", "batch_quantity_unattributed", "grading_loss_high"}
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
    """Check the batch's attribution to farmer shares and its grading loss (D-030).

    Args:
        ctx: the batch with its received kilograms, output kilograms, share sum and loss limit.

    Returns:
        A `batch_quantity_unattributed` warn when there are no shares or their sum differs from the received
        kilograms by more than 5 %, and a `grading_loss_high` warn when the output is more than
        `grading_loss_warn_pct` below the received kilograms or more than 5 % above them; nothing when the
        received kilograms are not recorded.
    """
    # DECISION D-030: attribution (shares vs received) and grading loss (output vs received) are two warns.
    #   ADV: each code means what it says; a normal grading loss no longer warns; the limit is per tenant.
    #   COMPROMISE: one more code and feature key; loss really depends on the crop (Standards Profile later).
    received = ctx.received_kg
    if not received:
        return []
    flags = []
    shares = ctx.shares_kg or Decimal(0)
    if not shares or abs(shares - received) > received * TOLERANCE:
        details = {"received_kg": str(received), "shares_kg": str(shares), "unit": "kg"}
        flags.append(
            FlagCandidate(
                FlagSubject.BATCH, ctx.batch_id, "batch_quantity_unattributed", Severity.WARN, details
            )
        )
    output = ctx.batch_kg
    limit = Decimal(ctx.grading_loss_warn_pct) / 100
    if output is not None and (output < received * (1 - limit) or output > received * (1 + TOLERANCE)):
        details = {
            "received_kg": str(received),
            "output_kg": str(output),
            "loss_pct": str(round((1 - output / received) * 100, 2)),
            "limit_pct": str(ctx.grading_loss_warn_pct),
            "unit": "kg",
        }
        flags.append(
            FlagCandidate(FlagSubject.BATCH, ctx.batch_id, "grading_loss_high", Severity.WARN, details)
        )
    return flags


def run(ctx: LotContext | BatchContext) -> list[FlagCandidate]:
    """Run the lot or the batch reconciliation, by context type.

    Args:
        ctx: a lot or a batch context.

    Returns:
        The flags of `_lot` or `_batch`.
    """
    return _lot(ctx) if isinstance(ctx, LotContext) else _batch(ctx)
