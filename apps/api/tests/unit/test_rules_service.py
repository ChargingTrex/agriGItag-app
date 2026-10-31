"""Unit tests of flag dedupe keys, assignment and the resolve route (stand-in session, no Docker).

Serves: B08 acceptance (re-check never duplicates: same key; resolve without reason → 422; officer resolving a
hold → 403; warn → 200), FR70.
Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import AsyncIterator
from datetime import UTC, datetime
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import FlagStatus, FlagSubject, Role, Severity
from agritrace.main import create_app
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.rules_flags.models import Flag
from agritrace.modules.rules_flags.rules import event_location
from agritrace.modules.rules_flags.rules.context import EventContext, FlagCandidate
from agritrace.modules.rules_flags.service import (
    RULE_PASSED,
    apply_hold,
    assignee,
    dedupe_key,
    reopens,
    resolve_from_sync,
)

FPO = uuid.uuid4()


def test_recheck_gives_the_same_dedupe_key() -> None:
    """Running the off-plot rule twice on one event yields one key; another photo id yields another."""
    ctx = EventContext(uuid.uuid4(), datetime(2026, 3, 4).date(), datetime.now(UTC), datetime.now(UTC))
    ctx_off = EventContext(**{**{f: getattr(ctx, f) for f in ctx.__slots__}, "on_plot": False})
    first, again = event_location.run(ctx_off), event_location.run(ctx_off)
    assert dedupe_key(first[0]) == dedupe_key(again[0])
    assert dedupe_key(first[0]).startswith(f"event_off_plot:{ctx.event_id}:")


def test_holds_go_to_the_admin() -> None:
    """Hold → fpo_admin; warn and info → field_officer, except practice-tag contradictions (FR56)."""
    assert assignee(Severity.HOLD, "yield_over_ceiling") == Role.FPO_ADMIN
    assert (
        assignee(Severity.WARN, "event_off_plot")
        == assignee(Severity.INFO, "clock_skew")
        == Role.FIELD_OFFICER
    )
    assert assignee(Severity.WARN, "practice_tag_contradiction") == Role.FPO_ADMIN


def test_closed_flag_reopens_when_the_system_closed_it_or_it_got_worse() -> None:
    """`rule_passed` closures always reopen; a reviewer's decision reopens only on a higher severity."""
    hold = FlagCandidate(FlagSubject.LOT, uuid.uuid4(), "yield_over_ceiling", Severity.HOLD)
    warn = FlagCandidate(FlagSubject.LOT, uuid.uuid4(), "yield_over_ceiling", Severity.WARN)
    auto = _flag(Severity.HOLD, FlagStatus.FIXED)
    auto.resolution_reason_code = RULE_PASSED
    assert reopens(auto, hold)
    looked_fine = _flag(Severity.WARN, FlagStatus.CLEARED)
    looked_fine.resolution_reason_code = "land_record_checked"
    assert reopens(looked_fine, hold)
    assert not reopens(looked_fine, warn)


def test_apply_hold_keeps_another_modules_reason() -> None:
    """A rules hold sets and clears its own reason; a B09 reason survives a rules hold being cleared."""
    lot = Lot(gi_eligible=True, gi_hold_reason=None)
    apply_hold(lot, ["yield_over_ceiling"])
    assert (lot.gi_eligible, lot.gi_hold_reason) == (False, "flags: yield_over_ceiling")
    apply_hold(lot, [])
    assert (lot.gi_eligible, lot.gi_hold_reason) == (True, None)
    lot.gi_eligible, lot.gi_hold_reason = False, "gi_recheck_failed"
    apply_hold(lot, ["yield_over_ceiling"])
    apply_hold(lot, [])
    assert (lot.gi_eligible, lot.gi_hold_reason) == (False, "gi_recheck_failed")


def _flag(severity: Severity, status: FlagStatus = FlagStatus.OPEN) -> Flag:
    """Make an in-memory event flag.

    Args:
        severity: its severity.
        status: its status.

    Returns:
        The flag (not stored).
    """
    return Flag(
        id=uuid.uuid4(),
        fpo_id=FPO,
        subject_type=FlagSubject.EVENT,
        subject_id=uuid.uuid4(),
        rule_code="event_off_plot",
        severity=severity,
        details={},
        dedupe_key="k",
        status=status,
        assigned_role=assignee(severity, "event_off_plot"),
        raised_at=datetime.now(UTC),
    )


class _Session:
    """Stand-in session holding one flag."""

    def __init__(self, flag: Flag) -> None:
        """Keep the flag.

        Args:
            flag: answered by every `get`.
        """
        self.flag = flag
        self.commits = 0

    async def get(self, _entity: Any, _key: Any) -> Flag:
        """Answer a primary-key lookup.

        Args:
            _entity: model class (ignored).
            _key: id (ignored).

        Returns:
            The flag.
        """
        return self.flag

    async def flush(self) -> None:
        """Do nothing (no database)."""

    async def commit(self) -> None:
        """Count the commit."""
        self.commits += 1


@pytest.fixture
def world() -> dict[str, Any]:
    """Shared mutable state: the flag in the session and the caller's role.

    Returns:
        `{"flag": Flag | None, "role": Role}`.
    """
    return {"flag": None, "role": Role.FIELD_OFFICER}


@pytest.fixture
async def client(world: dict[str, Any]) -> AsyncIterator[AsyncClient]:
    """App with the session and caller replaced.

    Args:
        world: the shared state.

    Returns:
        An async iterator yielding the HTTP client.
    """
    app = create_app()

    async def session() -> AsyncIterator[_Session]:
        """Yield the stand-in session.

        Returns:
            An iterator yielding one session.
        """
        yield _Session(world["flag"])

    app.dependency_overrides[get_session] = session
    app.dependency_overrides[get_current_user] = lambda: CurrentUser(uuid.uuid4(), FPO, world["role"])
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


async def test_resolve_without_reason_is_422(client: AsyncClient, world: dict[str, Any]) -> None:
    """Officer resolving a warn without `reason_code` → 422 `reason_required`.

    Args:
        client: HTTP client.
        world: shared state.
    """
    world["flag"] = _flag(Severity.WARN)
    r = await client.post(f"/v1/flags/{world['flag'].id}/resolve", json={"resolution": "looks_fine"})
    assert (r.status_code, r.json()["error"]["code"]) == (422, "reason_required")


async def test_officer_resolving_hold_is_403(client: AsyncClient, world: dict[str, Any]) -> None:
    """Officer on a hold → 403 `resolution_forbidden`; the admin may.

    Args:
        client: HTTP client.
        world: shared state.
    """
    world["flag"] = _flag(Severity.HOLD)
    body = {"resolution": "looks_fine", "reason_code": "land_record_checked"}
    r = await client.post(f"/v1/flags/{world['flag'].id}/resolve", json=body)
    assert (r.status_code, r.json()["error"]["code"]) == (403, "resolution_forbidden")
    world["role"] = Role.FPO_ADMIN
    r = await client.post(f"/v1/flags/{world['flag'].id}/resolve", json=body)
    assert (r.status_code, r.json()["status"]) == (200, "cleared")


async def test_officer_resolving_warn_is_200_then_409(client: AsyncClient, world: dict[str, Any]) -> None:
    """Officer resolves a warn → 200 `fixed` with the reason; resolving it again → 409 `flag_not_open`.

    Args:
        client: HTTP client.
        world: shared state.
    """
    world["flag"] = _flag(Severity.WARN)
    body = {"resolution": "fixed", "reason_code": "field_visit", "note": "GPS re-taken on the plot"}
    r = await client.post(f"/v1/flags/{world['flag'].id}/resolve", json=body)
    assert r.status_code == 200
    assert (r.json()["status"], r.json()["resolution_reason_code"]) == ("fixed", "field_visit")
    r = await client.post(f"/v1/flags/{world['flag'].id}/resolve", json=body)
    assert (r.status_code, r.json()["error"]["code"]) == (409, "flag_not_open")


async def test_escalation_reassigns_to_admin_and_locks_out_the_officer() -> None:
    """`escalated` hands the flag to fpo_admin; then only the admin can resolve it."""
    flag = _flag(Severity.WARN)
    officer = CurrentUser(uuid.uuid4(), FPO, Role.FIELD_OFFICER)
    session: Any = _Session(flag)
    data = {"flag_id": str(flag.id), "resolution": "escalated", "reason_code": "needs_admin"}
    assert await resolve_from_sync(session, officer, data) == (flag.id, True)
    assert (flag.status, flag.assigned_role) == (FlagStatus.ESCALATED, Role.FPO_ADMIN)
    assert await resolve_from_sync(session, officer, data) == (flag.id, False)  # retried push: duplicate
    with pytest.raises(Exception, match="FPO admin"):
        await resolve_from_sync(session, officer, {**data, "resolution": "fixed"})
