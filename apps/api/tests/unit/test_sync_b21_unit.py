"""Unit tests of B21 without Docker: push refuses what Postgres cannot store, per entry or at the envelope.

Serves: B21 acceptance (Q04-1: a database data error rejects only its entry and the next entry still runs;
any other database error stays a 500; a NUL anywhere in an entry's data rejects that entry; Q04-2: telemetry
with NUL or int32 overflow is a 422 before any entry is written). The real-Postgres path is
tests/integration/test_sync.py `test_nul_and_int32_overflow_reject_only_their_entries`.
Callers: pytest (`make test-unit`); no Docker needed.
"""

import uuid
from datetime import UTC, datetime
from typing import Any

import pytest
from pydantic import ValidationError
from sqlalchemy.exc import DBAPIError

from agritrace.core.auth import CurrentUser
from agritrace.core.enums import Role
from agritrace.modules.events import service
from agritrace.modules.events.schemas import SyncPushIn, SyncResult

USER = CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=Role.FARMER)
NOW = datetime.now(UTC).isoformat()


class _Driver(Exception):
    """Driver error stand-in carrying a SQLSTATE, as SQLAlchemy's asyncpg adapter exposes it."""

    def __init__(self, sqlstate: str) -> None:
        """Keep the SQLSTATE.

        Args:
            sqlstate: the five-character code.
        """
        super().__init__(sqlstate)
        self.sqlstate = sqlstate


class _Session:
    """Session stand-in: counts rollbacks."""

    rollbacks = 0

    async def rollback(self) -> None:
        """Record a rollback."""
        self.rollbacks += 1


async def _no_metrics(*_: object) -> None:
    """Skip the metrics write."""


def _body(*kinds: str, **over: Any) -> SyncPushIn:
    """Build a push envelope.

    Args:
        *kinds: entry kinds, in order.
        **over: envelope fields to replace.

    Returns:
        The validated envelope.
    """
    entries = [{"client_id": str(uuid.uuid4()), "kind": k, "data": {}} for k in kinds]
    base = {"device_id": str(uuid.uuid4()), "app_version": "1.0.3", "device_time": NOW, "entries": entries}
    return SyncPushIn.model_validate(base | over)


@pytest.mark.parametrize(("sqlstate", "rejected"), [("22021", True), ("08006", False)])
async def test_data_error_rejects_its_entry_and_other_db_errors_raise(
    monkeypatch: pytest.MonkeyPatch, sqlstate: str, rejected: bool
) -> None:
    """A class-22 error on #1 is `validation_error` and #2 runs; a connection error (08006) is re-raised.

    Args:
        monkeypatch: replaces the handlers and the metrics write.
        sqlstate: what the failing entry's driver error reports.
        rejected: whether the entry is rejected (else the push raises).
    """

    async def fail(*_: object) -> SyncResult:
        """Fail like a refused INSERT.

        Raises:
            DBAPIError: always, with the parametrised SQLSTATE.
        """
        raise DBAPIError("INSERT", {}, _Driver(sqlstate))

    async def ok(_s: object, _c: object, entry: Any, _v: str) -> SyncResult:
        """Accept the entry.

        Args:
            _s: session (unused).
            _c: caller (unused).
            entry: the entry.
            _v: app version (unused).

        Returns:
            `accepted`.
        """
        return SyncResult(client_id=entry.client_id, status="accepted")

    monkeypatch.setattr(service, "HANDLERS", {"plot": fail, "consent": ok})
    monkeypatch.setattr(service, "_store_metrics", _no_metrics)
    session: Any = _Session()
    if not rejected:
        with pytest.raises(DBAPIError):
            await service.push(session, USER, _body("plot", "consent"))
        return
    out = await service.push(session, USER, _body("plot", "consent"))
    assert [r.status for r in out.results] == ["rejected", "accepted"]
    assert out.results[0].error is not None and out.results[0].error.code == "validation_error"
    assert session.rollbacks == 1


async def test_nul_in_entry_data_rejects_that_entry(monkeypatch: pytest.MonkeyPatch) -> None:
    """A NUL nested in `data` (here a list item) is that entry's `validation_error` (`loc ["data"]`).

    Args:
        monkeypatch: replaces the metrics write.
    """
    monkeypatch.setattr(service, "_store_metrics", _no_metrics)
    body = _body("plot")
    body.entries[0].data = {"payload": {"tags": ["ok", "x\x00"]}}
    session: Any = _Session()
    out = await service.push(session, USER, body)
    assert out.results[0].status == "rejected" and out.results[0].error is not None
    assert out.results[0].error.details[0]["loc"] == ["data"]


@pytest.mark.parametrize(
    "over",
    [
        {"app_version": "1.0.3\x00"},
        {"metrics": [{"entry_client_id": str(uuid.uuid4()), "saved_at": NOW, "network_type": "lte\x00"}]},
        {"metrics": [{"entry_client_id": str(uuid.uuid4()), "saved_at": NOW, "failures": 2**31}]},
        {"metrics": [{"entry_client_id": str(uuid.uuid4()), "saved_at": NOW, "photo_upload_ms": 2**31}]},
    ],
)
def test_telemetry_postgres_cannot_store_is_refused_at_the_envelope(over: dict[str, Any]) -> None:
    """NUL in `app_version`/`network_type` or a counter above int32 fails validation (422), not the INSERT.

    Args:
        over: the bad envelope field.
    """
    with pytest.raises(ValidationError):
        _body(**over)
