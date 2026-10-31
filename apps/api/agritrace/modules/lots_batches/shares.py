"""Lot shares of a batch: each component lot's percent of the batch, as shown on the public page.

Serves: FR60 (each farmer's share of every batch), PRD §12 reference batch ({100, 200, 20} kg →
31.250 / 62.500 / 6.250 %), backend-design.md §2 (`batch_shares.share_pct` numeric(6,3), Σ = 100 ± 0.01).
Callers: `lots_batches.service.create_batch`; tests/unit/test_lots_shares.py.
"""

from collections.abc import Hashable, Mapping
from decimal import ROUND_HALF_EVEN, Decimal

STEP = Decimal("0.001")  # numeric(6,3)
HUNDRED = Decimal(100)


def split[K: Hashable](kg_by_lot: Mapping[K, Decimal]) -> dict[K, Decimal]:
    """Turn kilograms per lot into percent shares that add up to exactly 100.000.

    Args:
        kg_by_lot: kilograms each lot contributed, every value > 0, in the order the lots were given.

    Returns:
        Percent per lot, rounded half-even to 3 decimals; the rounding residual goes to the largest lot
        (the first one given when several tie), so the shares always sum to exactly 100.000.

    Raises:
        ValueError: empty input or a non-positive quantity.
    """
    if not kg_by_lot or min(kg_by_lot.values()) <= 0:
        raise ValueError("every lot must contribute a positive quantity")
    total = sum(kg_by_lot.values(), Decimal(0))
    pct = {k: (v * HUNDRED / total).quantize(STEP, ROUND_HALF_EVEN) for k, v in kg_by_lot.items()}
    # Residual to the largest share: it changes that farmer's figure least in relative terms.
    largest = max(kg_by_lot, key=lambda k: kg_by_lot[k])
    pct[largest] += HUNDRED - sum(pct.values(), Decimal(0))
    return pct
