"""Unit tests of the demo seed: idempotency guard, flag codes against the rule registry, reference shares.

Serves: B12 acceptance "seed idempotent" (guard on `BATCH_ID`, review B12-r1 P2-2), the flag-set constant
(D-030, rulings 2026-10-31 §1–§2) against the rule registry, "shares 31.25/62.5/6.25"; D-048. The exact flag
set on the seeded rows is asserted only by tests/e2e/test_reference_batch.py, via the real service (no hand
copy of `_lot_context` here, review B12-r1 P3-4). Callers: pytest (`uv run pytest tests/unit`); no Docker.
"""

from decimal import Decimal
from typing import Any, cast

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.modules.lots_batches import shares
from agritrace.modules.registry.models import Fpo
from agritrace.modules.rules_flags import rules
from agritrace.seed import demo


class _Session:
    """A session stand-in: the demo FPO always exists; the batch exists or not; writes fail."""

    def __init__(self, batch: object | None) -> None:
        """Remember what the batch lookup answers.

        Args:
            batch: the stored batch, or None.
        """
        self.batch = batch

    async def get(self, _model: Any, _key: Any) -> object | None:
        """Answer the batch lookup.

        Args:
            _model: ignored.
            _key: ignored.

        Returns:
            The batch given to the constructor.
        """
        return self.batch

    async def scalar(self, _query: Any) -> Fpo:
        """Answer any lookup with a bare FPO carrying the demo code.

        Args:
            _query: ignored.

        Returns:
            The FPO.
        """
        return Fpo(code=demo.FPO_CODE)

    def add(self, _row: Any) -> None:
        """Refuse writes.

        Args:
            _row: ignored.

        Raises:
            AssertionError: always.
        """
        raise AssertionError("the seed wrote a row")


class _Proceeded(Exception):
    """Raised by the patched `_gi_crop`: the seed went past its guard."""


async def test_second_run_writes_nothing() -> None:
    """With the reference batch stored, `seed` returns False before touching anything."""
    assert await demo.seed(cast(AsyncSession, _Session(batch=object()))) is False


async def test_bare_fpo_does_not_count_as_seeded(monkeypatch: pytest.MonkeyPatch) -> None:
    """An FPO with the demo code but no batch (e.g. from an import test) does not stop the seed.

    Args:
        monkeypatch: replaces `_gi_crop` with a probe.
    """

    async def probe(_session: AsyncSession) -> None:
        """Signal that the seed started writing.

        Args:
            _session: ignored.

        Raises:
            _Proceeded: always.
        """
        raise _Proceeded

    monkeypatch.setattr(demo, "_gi_crop", probe)
    with pytest.raises(_Proceeded):
        await demo.seed(cast(AsyncSession, _Session(batch=None)))


def test_expected_codes_exist_in_the_rule_registry() -> None:
    """Every expected and every must-not-appear code is one the lot/batch rules can raise (no typo passes)."""
    known = rules.codes(rules.LOT_RULES) | rules.codes(rules.BATCH_RULES)
    assert set(demo.EXPECTED_FLAGS) | set(demo.ABSENT_FLAGS) <= known


def test_reference_shares() -> None:
    """Intakes 100 / 200 / 20 kg (320 kg) split into 31.250 / 62.500 / 6.250 % (PRD §12, FR60)."""
    pct = shares.split({lot.code: lot.received_kg for lot in demo.LOTS})
    assert pct == {
        "LOTD02DADB6": Decimal("31.250"),
        "LOT3072CB6A": Decimal("62.500"),
        "LOT0EF81415": Decimal("6.250"),
    }
    assert [demo.packed_kg(lot) for lot in demo.LOTS] == [69, 140, Decimal("272.6")]
    assert sum(lot.received_kg for lot in demo.LOTS) == 320
