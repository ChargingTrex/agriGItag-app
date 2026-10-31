"""Unit tests of the demo seed: idempotency guard, reference data against the real rules, shares.

Serves: B12 acceptance "seed idempotent" (guard), the exact flag set (D-030, rulings 2026-10-31 §1–§2)
computed by the rule modules on the seed's own reference data, "shares 31.25/62.5/6.25"; D-048 (the direct
inserts are re-checked here). Callers: pytest (`uv run pytest tests/unit`); no Docker.
"""

import uuid
from collections import Counter
from decimal import Decimal
from typing import Any, cast

from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.enums import EventType
from agritrace.modules.lots_batches import shares
from agritrace.modules.rules_flags import rules
from agritrace.modules.rules_flags.rules.context import BatchContext, LotContext, LotEvent
from agritrace.seed import demo


class _SeededSession:
    """A session that finds the demo FPO and fails on any write."""

    async def scalar(self, _query: Any) -> uuid.UUID:
        """Answer the FPO lookup.

        Args:
            _query: ignored.

        Returns:
            An FPO id, as if the seed had already run.
        """
        return uuid.uuid4()

    def add(self, _row: Any) -> None:
        """Refuse writes.

        Args:
            _row: ignored.

        Raises:
            AssertionError: always; a second run must not write.
        """
        raise AssertionError("a second seed run wrote a row")


async def test_second_run_writes_nothing() -> None:
    """With the FPO present, `seed` returns False before touching anything."""
    assert await demo.seed(cast(AsyncSession, _SeededSession())) is False


def test_expected_codes_exist_in_the_rule_registry() -> None:
    """Every expected and every must-not-appear code is one the lot/batch rules can raise (no typo passes)."""
    known = rules.codes(rules.LOT_RULES) | rules.codes(rules.BATCH_RULES)
    assert set(demo.EXPECTED_FLAGS) | set(demo.ABSENT_FLAGS) <= known


def _lot_context(lot: demo.LotSeed) -> LotContext:
    """Build the context `rules_flags.service._lot_context` would read from the seeded rows.

    Args:
        lot: a reference lot.

    Returns:
        Its rule context (used = received, as `create_batch` builds the shares from the intakes).
    """
    return LotContext(
        lot_id=uuid.uuid4(),
        event_schema=demo.EVENT_SCHEMA,
        events=tuple(LotEvent(uuid.uuid4(), str(s.type), s.on) for s in lot.steps),
        declared_tags=("inorganic", "ipm"),
        input_categories=tuple(str(demo.INPUTS[s.input][2]) for s in lot.steps if s.input),
        has_pest_event=any(s.type == EventType.PROBLEM for s in lot.steps),
        harvested_kg=None,
        packed_kg=demo.packed_kg(lot),
        received_kg=lot.received_kg,
        used_kg=lot.received_kg,
        declared_acres=lot.acres,
    )


def test_reference_data_raises_exactly_the_expected_flags() -> None:
    """The real lot and batch rules on the seed's data give `EXPECTED_FLAGS` and none of `ABSENT_FLAGS`."""
    raised = [c.rule_code for lot in demo.LOTS for c in rules.run_all(rules.LOT_RULES, _lot_context(lot))]
    received = sum((lot.received_kg for lot in demo.LOTS), Decimal(0))
    batch = BatchContext(
        batch_id=uuid.uuid4(), shares_kg=received, batch_kg=demo.GRADED_KG, received_kg=received
    )
    raised += [c.rule_code for c in rules.run_all(rules.BATCH_RULES, batch)]
    assert Counter(raised) == Counter(demo.EXPECTED_FLAGS)
    assert received == 320 and [demo.packed_kg(lot) for lot in demo.LOTS] == [69, 140, Decimal("272.6")]


def test_reference_shares() -> None:
    """Intakes 100 / 200 / 20 kg split into 31.250 / 62.500 / 6.250 % (PRD §12, FR60)."""
    pct = shares.split({lot.code: lot.received_kg for lot in demo.LOTS})
    assert pct == {
        "LOTD02DADB6": Decimal("31.250"),
        "LOT3072CB6A": Decimal("62.500"),
        "LOT0EF81415": Decimal("6.250"),
    }
