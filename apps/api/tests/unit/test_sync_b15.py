"""Unit tests of B15 without Docker: per-entry assist context in sync push, kind role checks, plot check.

Covers the `farmer` and `assist_session` kinds' role checks, the plot assist-farmer check and
`create_farmer`'s client id.

Serves: B15 acceptance (D-031 farmer kind idempotent and officer/admin only, D-032 per-entry assist context:
unknown session → `assist_session_invalid` and the next entry still runs, a session for farmer A on farmer B
→ `forbidden`, the `farmer` kind ignores assist), CLAUDE.md §6. The database paths are covered by
tests/integration/test_sync_b15.py.
Callers: pytest (`make test-unit`); no Docker needed.
"""

import uuid
from datetime import UTC, datetime
from typing import Any

import pytest

from agritrace.core import audit
from agritrace.core.audit import AuditContext, reset_audit_context, set_audit_context
from agritrace.core.auth import CurrentUser
from agritrace.core.enums import Role
from agritrace.core.errors import ClientIdConflictError, ForbiddenError
from agritrace.modules.events import service
from agritrace.modules.events.schemas import SyncPushIn, SyncResult
from agritrace.modules.identity import service as identity_service
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Farmer
from agritrace.modules.registry.schemas import FarmerIn, PlotIn

FPO = uuid.uuid4()
OFFICER = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FIELD_OFFICER, device_id=uuid.uuid4())
FARMER_TOKEN = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FARMER)
FARMER_A, FARMER_B = uuid.uuid4(), uuid.uuid4()
SESSION_A = uuid.uuid4()


class _Session:
    """Session stand-in: records rollbacks; `get` returns the preset row."""

    def __init__(self, row: object = None) -> None:
        """Preset what `get` returns.

        Args:
            row: the row, or None.
        """
        self.row = row
        self.rollbacks = 0

    async def get(self, *_: object) -> object:
        """Return the preset row.

        Returns:
            The row given to the constructor.
        """
        return self.row

    async def scalar(self, *_: object) -> None:
        """Answer every scalar query with nothing (no phone on the account)."""

    async def rollback(self) -> None:
        """Record a rollback."""
        self.rollbacks += 1


def _entry(kind: str, session_id: uuid.UUID | None = None) -> dict[str, Any]:
    """Build a push entry whose data the recording handler ignores.

    Args:
        kind: the entry kind.
        session_id: its `assist_session_id`, if any.

    Returns:
        The entry as JSON-like dict.
    """
    return {"client_id": str(uuid.uuid4()), "kind": kind, "data": {}, "assist_session_id": session_id}


async def test_push_applies_each_entrys_assist_context_and_restores_it(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Header caller assists B; `farmer` runs with no assist, an entry with S uses A, unknown S is rejected.

    Args:
        monkeypatch: replaces the handlers, the session lookup and the metrics write.
    """
    seen: list[tuple[str, uuid.UUID | None, uuid.UUID | None, AuditContext | None]] = []

    async def record(_s: object, caller: CurrentUser, entry: Any, _v: str) -> SyncResult:
        """Record the caller and audit context the handler sees.

        Args:
            _s: session (unused).
            caller: the entry's caller.
            entry: the entry.
            _v: app version (unused).

        Returns:
            An accepted result.
        """
        ctx = audit._context.get()
        seen.append((entry.kind, caller.on_behalf_of_farmer_id, caller.assist_session_id, ctx))
        return SyncResult(client_id=entry.client_id, status="accepted")

    async def lookup(_s: object, session_id: uuid.UUID, officer: uuid.UUID) -> uuid.UUID | None:
        """Know only SESSION_A of OFFICER, for farmer A (ended or not does not matter here).

        Args:
            _s: session (unused).
            session_id: the entry's session.
            officer: the caller.

        Returns:
            Farmer A for the known session, else None.
        """
        return FARMER_A if (session_id, officer) == (SESSION_A, OFFICER.user_id) else None

    async def no_metrics(*_: object) -> None:
        """Skip the metrics write."""

    monkeypatch.setattr(service, "HANDLERS", dict.fromkeys(["farmer", "consent", "plot"], record))
    monkeypatch.setattr(service, "assist_session_farmer", lookup)
    monkeypatch.setattr(service, "_store_metrics", no_metrics)
    header_session = uuid.uuid4()
    caller = CurrentUser(
        user_id=OFFICER.user_id,
        fpo_id=FPO,
        role=Role.FIELD_OFFICER,
        on_behalf_of_farmer_id=FARMER_B,
        assist_session_id=header_session,
        device_id=OFFICER.device_id,
    )
    request_ctx = AuditContext(
        actor_user_id=OFFICER.user_id,
        on_behalf_of_farmer_id=FARMER_B,
        assist_session_id=header_session,
        device_id=OFFICER.device_id,
        request_id="req-1",
    )
    body = SyncPushIn.model_validate(
        {
            "device_id": str(uuid.uuid4()),
            "app_version": "1.0.3",
            "device_time": datetime.now(UTC).isoformat(),
            "entries": [
                _entry("farmer", SESSION_A),
                _entry("consent", SESSION_A),
                _entry("plot", uuid.uuid4()),
                _entry("plot"),
            ],
        }
    )
    token = set_audit_context(request_ctx)
    try:
        out = await service.push(_Session(), caller, body)  # type: ignore[arg-type]
        assert audit._context.get() == request_ctx  # restored after the push
    finally:
        reset_audit_context(token)
    assert [r.status for r in out.results] == ["accepted", "accepted", "rejected", "accepted"]
    assert out.results[2].error is not None and out.results[2].error.code == "assist_session_invalid"
    farmer, consent, plain = seen
    assert farmer[:3] == ("farmer", None, None)
    assert farmer[3] == AuditContext(OFFICER.user_id, None, None, OFFICER.device_id, None, "req-1")
    assert consent[:3] == ("consent", FARMER_A, SESSION_A)
    assert consent[3] == AuditContext(OFFICER.user_id, FARMER_A, SESSION_A, OFFICER.device_id, None, "req-1")
    assert plain == ("plot", FARMER_B, header_session, request_ctx)  # no field: the header applies


async def test_farmer_and_assist_kinds_refuse_a_farmer_token() -> None:
    """`kind=farmer` and `kind=assist_session` by a farmer token → `forbidden` before any read."""
    with pytest.raises(ForbiddenError):
        await registry_service.create_farmer_from_sync(_Session(), FARMER_TOKEN, {"name": "x"})  # type: ignore[arg-type]
    with pytest.raises(ForbiddenError):
        await identity_service.start_assist_from_sync(_Session(), FARMER_TOKEN, {"farmer_id": str(FARMER_A)})  # type: ignore[arg-type]


async def test_assisted_plot_for_another_farmer_is_forbidden() -> None:
    """D-032: in assist mode for farmer A, a plot for farmer B is refused like consent and events."""
    assisting = CurrentUser(
        user_id=OFFICER.user_id,
        fpo_id=FPO,
        role=Role.FIELD_OFFICER,
        on_behalf_of_farmer_id=FARMER_A,
        assist_session_id=SESSION_A,
    )
    plot = PlotIn.model_validate(
        {
            "client_id": str(uuid.uuid4()),
            "farmer_id": str(FARMER_B),
            "pin": {"lat": 9.56, "lon": 78.13, "accuracy_m": 5},
            "pin_method": "live_gps",
            "device_time": datetime.now(UTC).isoformat(),
            "declared_area": {"value": 1.5, "unit": "acre"},
        }
    )
    with pytest.raises(ForbiddenError):
        await registry_service.create_plot(_Session(), assisting, plot)  # type: ignore[arg-type]


async def test_farmer_client_id_resend_and_foreign_fpo() -> None:
    """D-031: a stored id of this FPO returns that farmer (no phone check); another FPO's → conflict."""
    farmer_id = uuid.uuid4()
    stored = Farmer(
        id=farmer_id, fpo_id=FPO, code="F-001", name="Muthu", status="pending", no_smartphone=False
    )
    stored.created_at = stored.updated_at = datetime.now(UTC)
    body = FarmerIn(name="Muthu", phone="+919876543210", client_id=farmer_id)
    out = await registry_service.create_farmer(_Session(stored), OFFICER, body)  # type: ignore[arg-type]
    assert out.id == farmer_id
    other = CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=Role.FIELD_OFFICER)
    with pytest.raises(ClientIdConflictError):
        await registry_service.create_farmer(_Session(stored), other, body)  # type: ignore[arg-type]
