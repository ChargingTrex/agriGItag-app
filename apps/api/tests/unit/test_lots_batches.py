"""Unit tests of the lots_batches pure logic: shares, reconciliation, gate reasons and request schemas.

Serves: B09 acceptance "lots {100,200,20} → 31.250/62.500/6.250", "intake 100 vs packed 69" (chain out of
order), FR58 (kg only), FR60, D-033 (reasons list).
Callers: pytest (`uv run pytest tests/unit`); no Docker.
"""

import uuid
from datetime import date
from decimal import Decimal
from types import SimpleNamespace
from typing import Any, cast

import pytest
from pydantic import ValidationError

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.lots_batches import shares
from agritrace.modules.lots_batches.schemas import BatchIn, FinalPackingIn, IntakeIn
from agritrace.modules.lots_batches.service import hold_reasons, reason, reconcile


def test_reference_batch_shares() -> None:
    """The PRD §12 batch {100, 200, 20} kg splits exactly into 31.250 / 62.500 / 6.250 %."""
    pct = shares.split({"a": Decimal(100), "b": Decimal(200), "c": Decimal(20)})
    assert pct == {"a": Decimal("31.250"), "b": Decimal("62.500"), "c": Decimal("6.250")}


def test_residual_goes_to_largest_and_sum_is_exact() -> None:
    """Thirds round to 33.333 each; the 0.001 residual goes to the largest (first on a tie)."""
    pct = shares.split({"a": Decimal(1), "b": Decimal(1), "c": Decimal(1)})
    assert pct == {"a": Decimal("33.334"), "b": Decimal("33.333"), "c": Decimal("33.333")}
    odd = shares.split({"x": Decimal("7.1"), "y": Decimal("13.9"), "z": Decimal("0.3")})
    assert sum(odd.values()) == Decimal("100.000")
    assert odd["y"] == max(odd.values())


def test_half_even_rounding() -> None:
    """1/8 = 12.5 % and 0.0625 % → half-even at the third decimal (0.062, not 0.063)."""
    pct = shares.split({"big": Decimal(1599), "tiny": Decimal(1)})
    assert pct["tiny"] == Decimal("0.062")  # 0.0625 rounds to even
    assert pct["big"] == Decimal("99.938")


def test_split_refuses_empty_or_zero() -> None:
    """Shares need at least one positive quantity each."""
    with pytest.raises(ValueError, match="positive"):
        shares.split({})
    with pytest.raises(ValueError, match="positive"):
        shares.split({"a": Decimal(0), "b": Decimal(5)})


def test_reconcile_flags_received_above_packed() -> None:
    """Packed 69 kg, received 100 kg: the chain is out of order (B08 raises quantity_mismatch)."""
    r = reconcile(Decimal(150), Decimal(69), Decimal(100))
    assert not r.in_order
    assert r.received is not None and r.received.unit == "kg"
    assert reconcile(Decimal(150), Decimal(120), Decimal(100), Decimal(100)).in_order
    assert reconcile(None, None, Decimal(100)).in_order  # missing steps are skipped


def test_hold_reasons_keep_only_holds() -> None:
    """Only hold flags block; plot holds are included like any other subject."""
    plot_id = uuid.uuid4()
    flags = [
        SimpleNamespace(
            id=uuid.uuid4(),
            severity=Severity.HOLD,
            rule_code="plot_outside_gi_region",
            subject_type=FlagSubject.PLOT,
            subject_id=plot_id,
        ),
        SimpleNamespace(
            id=uuid.uuid4(),
            severity=Severity.WARN,
            rule_code="quantity_mismatch",
            subject_type=FlagSubject.LOT,
            subject_id=uuid.uuid4(),
        ),
    ]
    out = hold_reasons(cast(Any, flags))
    assert [r["rule_code"] for r in out] == ["plot_outside_gi_region"]
    assert out[0]["code"] == "open_hold_flag" and out[0]["subject_id"] == str(plot_id)


def test_reason_is_json_safe() -> None:
    """UUIDs and Decimals in reason context become strings."""
    lot = uuid.uuid4()
    r = reason("packed_above_graded", "msg", lot_id=lot, packed_kg=Decimal("25"))
    assert r == {"code": "packed_above_graded", "message": "msg", "lot_id": str(lot), "packed_kg": "25"}


def test_quantities_must_be_kg() -> None:
    """A batch or intake quantity in another unit is a validation error (FR58, kg only in the pilot)."""
    body = {
        "client_id": str(uuid.uuid4()),
        "lot_id": str(uuid.uuid4()),
        "processor_id": str(uuid.uuid4()),
        "sale_date": "2026-07-01",
        "received": {"value": "100", "unit": "g"},
    }
    with pytest.raises(ValidationError, match="unit must be kg"):
        IntakeIn.model_validate(body)
    body["received"] = {"value": "100", "unit": "kg"}
    assert IntakeIn.model_validate(body).received.value == Decimal(100)


def test_batch_refuses_repeated_lot_and_bad_dates() -> None:
    """A lot listed twice and a best-before before the pack date are refused."""
    lot = str(uuid.uuid4())
    with pytest.raises(ValidationError, match="only once"):
        BatchIn.model_validate({"processor_id": str(uuid.uuid4()), "lot_ids": [lot, lot]})
    with pytest.raises(ValidationError, match="best_before_date"):
        FinalPackingIn(
            packed={"value": 10, "unit": "kg"},  # type: ignore[arg-type]
            pack_date=date(2026, 8, 1),
            best_before_date=date(2026, 7, 1),
        )
