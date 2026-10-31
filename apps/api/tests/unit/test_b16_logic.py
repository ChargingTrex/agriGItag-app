"""Unit tests of B16 without Docker: QC intake (D-040), GI-only holds (D-041), assist per kind (D-042).

Serves: B16 acceptance line 8 (`hold_reasons` and `GI_ONLY_HOLD_CODES` tied to the rules), line 11 (the
committed OpenAPI document) and the logic of lines 2–4 and 9–10 (role checks, processor default, ready gate
at intake, assist checks per kind); the database paths are covered by tests/integration/test_b16.py.
Callers: pytest (`uv run pytest tests/unit`); no Docker needed.
"""

import json
import uuid
from datetime import date
from decimal import Decimal
from pathlib import Path
from types import SimpleNamespace
from typing import Any, cast

import pytest

from agritrace.core.auth import CurrentUser
from agritrace.core.enums import (
    ApprovalStage,
    FlagSubject,
    LocationStatus,
    LotStatus,
    PinMethod,
    Role,
    Severity,
)
from agritrace.core.errors import FieldRequiredError, ForbiddenError, GateNotMetError, ValidationFailedError
from agritrace.modules.events import service as events_service
from agritrace.modules.events.schemas import SyncEntry
from agritrace.modules.lots_batches import service as lb
from agritrace.modules.lots_batches.models import Lot, LotIntake
from agritrace.modules.lots_batches.schemas import IntakeIn
from agritrace.modules.quality import service as quality_service
from agritrace.modules.quality.models import QualityReading
from agritrace.modules.rules_flags import rules
from agritrace.modules.rules_flags import service as rules_service
from agritrace.modules.rules_flags.rules import plot_checks, yield_ceiling
from agritrace.modules.rules_flags.rules.context import LotContext, PlotContext

FPO = uuid.uuid4()


def _user(role: Role, on_behalf: uuid.UUID | None = None) -> CurrentUser:
    """Build a caller of the test FPO.

    Args:
        role: the caller's role.
        on_behalf: the assisted farmer, if any.

    Returns:
        The caller.
    """
    return CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=role, on_behalf_of_farmer_id=on_behalf)


def _flag(code: str, severity: Severity = Severity.HOLD) -> Any:
    """Build an active flag stand-in.

    Args:
        code: rule code.
        severity: its severity.

    Returns:
        An object with the fields `hold_reasons` and `_approval` read.
    """
    return SimpleNamespace(
        id=uuid.uuid4(),
        severity=severity,
        rule_code=code,
        subject_type=FlagSubject.LOT,
        subject_id=uuid.uuid4(),
    )


# --- D-041 --------------------------------------------------------------------------------------------------


def test_gi_only_holds_do_not_block_a_non_gi_batch_but_others_do() -> None:
    """Non-GI: GI-only holds pass, `event_off_plot` hold still blocks; GI-requested: every hold blocks."""
    flags = [_flag("plot_outside_gi_region"), _flag("yield_over_ceiling"), _flag("event_off_plot")]
    assert [r["rule_code"] for r in lb.hold_reasons(flags, False)] == ["event_off_plot"]
    assert [r["rule_code"] for r in lb.hold_reasons(flags, True)] == [
        "plot_outside_gi_region",
        "yield_over_ceiling",
        "event_off_plot",
    ]


def test_gi_only_codes_are_hold_codes_of_the_rules() -> None:
    """Every code in `GI_ONLY_HOLD_CODES` is in a rule module's `CODES` and raised by it as a hold."""
    groups = (rules.EVENT_RULES, rules.LOT_RULES, rules.BATCH_RULES, rules.PLOT_RULES)
    assert set().union(*(rules.codes(g) for g in groups)) >= lb.GI_ONLY_HOLD_CODES
    plot = PlotContext(
        plot_id=uuid.uuid4(),
        pin_method=PinMethod.LIVE_GPS,
        location_status=LocationStatus.OUTSIDE,
        declared_acres=Decimal(1),
    )
    lot = LotContext(
        uuid.uuid4(), harvested_kg=Decimal(1350), declared_acres=Decimal(1), yield_outcome="hold"
    )
    raised = {(f.rule_code, f.severity) for f in plot_checks.run(plot) + yield_ceiling.run(lot)}
    assert {(code, Severity.HOLD) for code in lb.GI_ONLY_HOLD_CODES} <= raised


def test_approval_records_gi_only_holds_of_a_non_gi_batch() -> None:
    """The approval row lists warns and, in a non-GI batch only, the GI-only holds it approved over."""
    flags = [
        _flag("plot_outside_gi_region"),
        _flag("yield_over_ceiling"),
        _flag("quantity_mismatch", Severity.WARN),
    ]
    user = _user(Role.FPO_ADMIN)
    non_gi = lb._approval(
        cast(Any, SimpleNamespace(id=uuid.uuid4(), gi_label_requested=False)),
        ApprovalStage.PUBLISH,
        user,
        flags,
    )
    assert non_gi.blocked_reasons == ["plot_outside_gi_region", "quantity_mismatch", "yield_over_ceiling"]
    gi = lb._approval(
        cast(Any, SimpleNamespace(id=uuid.uuid4(), gi_label_requested=True)),
        ApprovalStage.PUBLISH,
        user,
        flags,
    )
    assert gi.blocked_reasons == ["quantity_mismatch"]


# --- D-040 --------------------------------------------------------------------------------------------------


class _Session:
    """Session stand-in for `create_intake`: rows by model class, own processors for the default query."""

    def __init__(self, rows: dict[type, Any], own: list[Any] | None = None) -> None:
        """Preset the rows.

        Args:
            rows: what `get(Model, id)` returns per class (missing → None).
            own: what the own-processor query returns.
        """
        self.rows, self.own = rows, own or []
        self.added: list[Any] = []

    async def get(self, model: type, _id: Any, **_: Any) -> Any:
        """Return the preset row for a class.

        Args:
            model: the ORM class.
            _id: primary key (ignored).
            **_: options (ignored).

        Returns:
            The row or None.
        """
        return self.rows.get(model)

    async def scalars(self, _q: Any) -> Any:
        """Answer the own-processor query.

        Args:
            _q: the query (ignored).

        Returns:
            An object whose `all()` lists the own processors.
        """
        return SimpleNamespace(all=lambda: self.own)

    async def scalar(self, _q: Any) -> int:
        """Answer count queries with 0.

        Args:
            _q: the query (ignored).

        Returns:
            0.
        """
        return 0

    def add(self, row: Any) -> None:
        """Record an added row.

        Args:
            row: the row.
        """
        self.added.append(row)

    async def flush(self) -> None:
        """Do nothing."""

    async def commit(self) -> None:
        """Do nothing."""


def _intake(**kw: Any) -> IntakeIn:
    """Build an intake of 230 kg.

    Args:
        **kw: field overrides.

    Returns:
        The intake.
    """
    body: dict[str, Any] = {
        "client_id": uuid.uuid4(),
        "lot_id": uuid.uuid4(),
        "sale_date": date(2026, 10, 31),
        "received": {"value": 230, "unit": "kg"},
    }
    return IntakeIn.model_validate(body | kw)


@pytest.mark.parametrize("role", [Role.FARMER, Role.FIELD_OFFICER, Role.VIEWER])
async def test_intake_refused_for_other_roles(role: Role) -> None:
    """A farmer, field officer or viewer → `forbidden` before any lookup.

    Args:
        role: the caller's role.
    """
    with pytest.raises(ForbiddenError):
        await lb.create_intake(cast(Any, _Session({})), _user(role), _intake())


async def test_correction_by_qc_officer_refused() -> None:
    """A correction (`supersedes_intake_id` + reason) by a QC officer → `forbidden`."""
    body = _intake(supersedes_intake_id=uuid.uuid4(), correction_reason="scale misread")
    with pytest.raises(ForbiddenError):
        await lb.create_intake(cast(Any, _Session({})), _user(Role.QC_OFFICER), body)


@pytest.mark.parametrize("count", [0, 2])
async def test_processor_default_needs_exactly_one_own(count: int) -> None:
    """No `processor_id` and zero or two own processors → `field_required` naming `processor_id`.

    Args:
        count: number of own processors.
    """
    lot = SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO, status=LotStatus.READY_FOR_SALE)
    own = [SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO) for _ in range(count)]
    with pytest.raises(FieldRequiredError) as err:
        await lb.create_intake(cast(Any, _Session({Lot: lot}, own)), _user(Role.QC_OFFICER), _intake())
    assert err.value.details["field"] == "processor_id"


async def test_open_lot_failing_the_moisture_gate_is_not_received(monkeypatch: pytest.MonkeyPatch) -> None:
    """An open lot whose drying-end moisture fails → `moisture_gate_failed`, lot unchanged, no row added.

    Args:
        monkeypatch: replaces the moisture gate.
    """

    async def fails(*_: Any) -> bool:
        """Fail the gate.

        Returns:
            False.
        """
        return False

    monkeypatch.setattr(quality_service, "lot_gate_passes", fails)
    lot = SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO, status=LotStatus.OPEN, ready_at=None)
    session = _Session({Lot: lot}, [SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO)])
    with pytest.raises(GateNotMetError) as err:
        await lb.create_intake(cast(Any, session), _user(Role.QC_OFFICER), _intake())
    assert [r["code"] for r in err.value.details["reasons"]] == ["moisture_gate_failed"]
    assert (lot.status, lot.ready_at, session.added) == (LotStatus.OPEN, None, [])


async def test_open_lot_passing_the_gate_is_received(monkeypatch: pytest.MonkeyPatch) -> None:
    """An open lot whose drying-end moisture passes → `ready_at` set, lot `received`, intake by the QC user.

    Args:
        monkeypatch: replaces the moisture gate, the farm kg sum and the rules.
    """

    async def passes(*_: Any) -> bool:
        """Pass the gate.

        Returns:
            True.
        """
        return True

    async def nothing(*_: Any, **__: Any) -> Any:
        """Answer an empty result.

        Returns:
            An empty dict (falsy for both callers).
        """
        return {}

    monkeypatch.setattr(quality_service, "lot_gate_passes", passes)
    monkeypatch.setattr(lb, "_farm_kg", nothing)
    monkeypatch.setattr(rules_service, "run_gate_checks", nothing)
    lot = SimpleNamespace(
        id=uuid.uuid4(), fpo_id=FPO, status=LotStatus.OPEN, ready_at=None, harvested_kg=None, packed_kg=None
    )
    processor = SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO)
    user = _user(Role.QC_OFFICER)
    intake, _, created = await lb.create_intake(cast(Any, _Session({Lot: lot}, [processor])), user, _intake())
    assert created and lot.status == LotStatus.RECEIVED and lot.ready_at is not None
    assert (intake.processor_id, intake.accepted_by_user_id) == (processor.id, user.user_id)


async def test_intake_from_sync_validates() -> None:
    """Malformed `lot_intake` data → `validation_error` with details."""
    with pytest.raises(ValidationFailedError) as err:
        await lb.create_intake_from_sync(cast(Any, _Session({})), _user(Role.QC_OFFICER), {"lot_id": "x"})
    assert err.value.details


async def test_intake_resend_is_a_duplicate_for_a_qc_officer() -> None:
    """The same intake id resent by a QC officer returns the stored row, not created (D-005)."""
    body = _intake()
    stored = SimpleNamespace(id=body.client_id, fpo_id=FPO, lot_id=body.lot_id)
    out = await lb.create_intake(cast(Any, _Session({LotIntake: stored})), _user(Role.QC_OFFICER), body)
    assert cast(Any, out) == (stored, [], False)


# --- D-042 --------------------------------------------------------------------------------------------------


@pytest.mark.parametrize("kind", sorted(events_service.NO_ASSIST_KINDS))
async def test_no_assist_kinds_drop_the_session_without_lookup(
    kind: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """`farmer`, `flag_resolution`, `assist_session`, `lot_intake` with any session id → no lookup, no assist.

    Args:
        kind: the entry kind.
        monkeypatch: makes the session lookup fail the test.
    """

    async def lookup(*_: Any) -> None:
        """Fail: these kinds must not look the session up.

        Raises:
            AssertionError: always.
        """
        raise AssertionError("looked up")

    monkeypatch.setattr(events_service, "assist_session_farmer", lookup)
    entry = SyncEntry(client_id=uuid.uuid4(), kind=kind, data={}, assist_session_id=uuid.uuid4())
    caller = await events_service._entry_caller(
        cast(Any, None), _user(Role.FIELD_OFFICER, uuid.uuid4()), entry
    )
    assert caller is not None
    assert (caller.on_behalf_of_farmer_id, caller.assist_session_id) == (None, None)


async def test_batch_event_in_assist_mode_is_forbidden() -> None:
    """A batch event version written by an officer in assist mode → `forbidden` (a batch has many farmers)."""
    v = SimpleNamespace(lot_id=None, batch_id=uuid.uuid4(), plot_id=None)
    with pytest.raises(ForbiddenError):
        await events_service._check_subject(
            cast(Any, None), _user(Role.FIELD_OFFICER, uuid.uuid4()), cast(Any, v)
        )


def _reading(**subject: str) -> dict[str, Any]:
    """Build raw drying-end moisture reading data.

    Args:
        **subject: `lot_id=...` or `batch_id=...`.

    Returns:
        The sync `data` dict.
    """
    return {
        "client_id": str(uuid.uuid4()),
        "stage": "drying_end",
        "parameter_code": "moisture",
        "measurement": {"value": "10.5", "unit": "%"},
        "source": "visual",
        "measured_at": "2026-10-31T09:00:00+05:30",
        **subject,
    }


async def test_assisted_reading_on_another_farmers_lot_or_a_batch_is_forbidden() -> None:
    """Session for farmer A: a reading on farmer B's lot or on any batch → `forbidden`."""
    farmer_a, farmer_b = uuid.uuid4(), uuid.uuid4()
    lot_b = SimpleNamespace(id=uuid.uuid4(), fpo_id=FPO, farmer_id=farmer_b, crop_id=uuid.uuid4())
    session = cast(Any, _Session({QualityReading: None, Lot: lot_b}))
    officer = _user(Role.FIELD_OFFICER, farmer_a)
    with pytest.raises(ForbiddenError):
        await quality_service.create_reading(session, officer, _reading(lot_id=str(lot_b.id)))
    with pytest.raises(ForbiddenError):
        await quality_service.create_reading(session, officer, _reading(batch_id=str(uuid.uuid4())))


def test_openapi_lists_lot_intake_and_optional_processor() -> None:
    """Line 11: the committed spec lists kind `lot_intake` and makes `IntakeIn.processor_id` optional."""
    spec = json.loads((Path(__file__).parents[4] / "packages/openapi/openapi.json").read_text())
    schemas = spec["components"]["schemas"]
    entry = schemas["SyncEntry"]["properties"]
    assert "lot_intake" in entry["kind"]["enum"]
    assert "processor_id" not in schemas["IntakeIn"]["required"]
    assert "lot_intake" in entry["assist_session_id"]["description"]
    assert "lot_intake" in entry["data"]["description"]
