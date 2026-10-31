"""Unit tests of the lots_batches pure logic: shares, reconciliation, gate reasons and request schemas.

Serves: B09 acceptance "lots {100,200,20} → 31.250/62.500/6.250", "intake 100 vs packed 69" (chain out of
order), FR58 (kg only), FR60, D-033 (reasons list); r2: batch idempotency on `client_id` (D-005) and the
refusal to correct an intake once the lot is batched.
Callers: pytest (`uv run pytest tests/unit`); no Docker.
"""

import uuid
from datetime import date
from decimal import Decimal
from types import SimpleNamespace
from typing import Any, cast
from unittest.mock import AsyncMock

import pytest
from pydantic import ValidationError

from agritrace.core.auth import CurrentUser
from agritrace.core.enums import FlagSubject, LotStatus, Role, Severity
from agritrace.core.errors import ClientIdConflictError, GateNotMetError
from agritrace.modules.lots_batches import shares
from agritrace.modules.lots_batches.models import Batch, Lot, LotIntake
from agritrace.modules.lots_batches.schemas import BatchIn, FinalPackingIn, IntakeIn
from agritrace.modules.lots_batches.service import (
    create_batch,
    create_intake,
    hold_reasons,
    reason,
    reconcile,
)
from agritrace.modules.registry.models import Processor


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
        BatchIn.model_validate(
            {"client_id": str(uuid.uuid4()), "processor_id": str(uuid.uuid4()), "lot_ids": [lot, lot]}
        )
    with pytest.raises(ValidationError, match="best_before_date"):
        FinalPackingIn(
            packed={"value": 10, "unit": "kg"},  # type: ignore[arg-type]
            pack_date=date(2026, 8, 1),
            best_before_date=date(2026, 7, 1),
        )


def _session(rows: dict[type, Any]) -> Any:
    """Build a stand-in async session whose `get` answers by model class.

    Args:
        rows: what `session.get(Model, id)` returns per model class (missing → None).

    Returns:
        An object with async `get`, `commit` and `scalar` methods.
    """

    async def get(model: type, _id: Any, **_: Any) -> Any:
        """Return the row configured for `model`.

        Args:
            model: the ORM class.
            _id: the primary key (ignored).
            **_: options such as `with_for_update` (ignored).

        Returns:
            The configured row or None.
        """
        return rows.get(model)

    return SimpleNamespace(get=get, commit=AsyncMock(), scalar=AsyncMock(return_value=0))


async def test_batch_resend_is_idempotent_per_fpo() -> None:
    """The same batch `client_id` returns the stored batch for its FPO and conflicts for another (D-005)."""
    fpo, processor = uuid.uuid4(), uuid.uuid4()
    stored = SimpleNamespace(fpo_id=fpo, processor_id=processor)
    body = BatchIn(client_id=uuid.uuid4(), processor_id=processor, lot_ids=[uuid.uuid4()])
    me = CurrentUser(user_id=uuid.uuid4(), fpo_id=fpo, role=Role.FPO_ADMIN)
    assert await create_batch(_session({Batch: stored}), me, body) == (stored, [], False)
    other = CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=Role.FPO_ADMIN)
    with pytest.raises(ClientIdConflictError):
        await create_batch(_session({Batch: stored}), other, body)


async def test_intake_correction_refused_once_batched() -> None:
    """Correcting the intake of a batched lot → 409 `lot_already_batched` (shares are append-only, D-033)."""
    fpo, lot_id, processor = uuid.uuid4(), uuid.uuid4(), uuid.uuid4()
    lot = SimpleNamespace(id=lot_id, fpo_id=fpo, status=LotStatus.BATCHED)
    prior = SimpleNamespace(id=uuid.uuid4(), fpo_id=fpo, lot_id=lot_id)
    session = _session({Lot: lot, Processor: SimpleNamespace(id=processor, fpo_id=None), LotIntake: None})
    real_get = session.get

    async def get(model: type, key: Any, **kw: Any) -> Any:
        """Answer the superseded intake by its id, the resend lookup with None.

        Args:
            model: the ORM class.
            key: the primary key.
            **kw: passed through.

        Returns:
            The configured row.
        """
        return prior if model is LotIntake and key == prior.id else await real_get(model, key, **kw)

    session.get = get
    body = IntakeIn(
        client_id=uuid.uuid4(),
        lot_id=lot_id,
        processor_id=processor,
        sale_date=date(2026, 7, 1),
        received={"value": 95, "unit": "kg"},  # type: ignore[arg-type]
        supersedes_intake_id=prior.id,
        correction_reason="scale misread",
    )
    me = CurrentUser(user_id=uuid.uuid4(), fpo_id=fpo, role=Role.FPO_ADMIN)
    with pytest.raises(GateNotMetError) as err:
        await create_intake(session, me, body)
    assert [r["code"] for r in err.value.details["reasons"]] == ["lot_already_batched"]


def test_correction_needs_a_reason() -> None:
    """`supersedes_intake_id` without `correction_reason` is a validation error."""
    with pytest.raises(ValidationError, match="go together"):
        IntakeIn(
            client_id=uuid.uuid4(),
            lot_id=uuid.uuid4(),
            processor_id=uuid.uuid4(),
            sale_date=date(2026, 7, 1),
            received={"value": 95, "unit": "kg"},  # type: ignore[arg-type]
            supersedes_intake_id=uuid.uuid4(),
        )
