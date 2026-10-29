"""Audit trail: the `Audited` marker mixin and the flush listener that writes `audit_log` rows.

One row per created, changed or deleted audited row, stamped with who did it, for whom, from which device
and where.

Serves: FR25 (audit trail with edit history), FR59 (person vs system entries), CLAUDE.md §6 (assist mode
recorded on every entry), Dataflow Stage 11 (audit / compliance review), D-005.
Callers: models that inherit `Audited` (modules/*/models.py); identity (B02) calls `set_audit_context`
once per request from the JWT, `X-Device-Id` and `X-Assist-Session`; Celery tasks may set an actor-less
context (system). Read by reporting's audit export (B10). tests/unit/test_audit.py,
tests/integration/test_schema.py.
"""

import json
import uuid
from contextvars import ContextVar, Token
from dataclasses import dataclass
from typing import Any

from geoalchemy2 import Geography
from sqlalchemy import DateTime, Text, Uuid, column, event, insert, inspect, table
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import InstanceState, Session, UOWTransaction

from agritrace.core.ids import uuid7
from agritrace.core.schemas import GeoPoint
from agritrace.core.time import utcnow

# Columns the listener writes. identity/models.py `AuditLog` owns the table; core may not import a module
# (D-004), so this lightweight handle names the same columns (tests/unit/test_audit.py keeps them in step).
AUDIT_LOG = table(
    "audit_log",
    column("id", Uuid()),
    column("at", DateTime(timezone=True)),
    column("actor_user_id", Uuid()),
    column("on_behalf_of_farmer_id", Uuid()),
    column("assist_session_id", Uuid()),
    column("device_id", Uuid()),
    column("gps", Geography("POINT", 4326, spatial_index=False)),
    column("action", Text()),
    column("entity_type", Text()),
    column("entity_id", Uuid()),
    column("diff", JSONB()),
    column("request_id", Text()),
)


@dataclass(frozen=True, slots=True)
class AuditContext:
    """Who is acting in the current request or task; every field is optional (system actions have none)."""

    actor_user_id: uuid.UUID | None = None
    on_behalf_of_farmer_id: uuid.UUID | None = None
    assist_session_id: uuid.UUID | None = None
    device_id: uuid.UUID | None = None
    gps: GeoPoint | None = None
    request_id: str | None = None


_context: ContextVar[AuditContext | None] = ContextVar("audit_context", default=None)


def set_audit_context(ctx: AuditContext) -> Token[AuditContext | None]:
    """Make `ctx` the audit context for the current request or task (context-variable scoped).

    Args:
        ctx: actor, assist and device details to stamp on audit rows written from now on.

    Returns:
        A token for `reset_audit_context`, restoring the previous context.

    Side effects:
        Sets a context variable visible to code running in the same asyncio task or thread.
    """
    return _context.set(ctx)


def reset_audit_context(token: Token[AuditContext | None]) -> None:
    """Restore the audit context that was active before `set_audit_context` returned `token`.

    Args:
        token: the value `set_audit_context` returned.

    Raises:
        ValueError: the token was created in a different context.

    Side effects:
        Resets the context variable.
    """
    _context.reset(token)


class Audited:
    """Mixin marking a model whose inserts, updates and deletes are written to `audit_log` (FR25).

    Append-only tables (event_versions, evidence_photos) are their own history and do not use it.

    The listener only sees ORM unit-of-work flushes. Core statements (`insert()`/`update()`/`delete()`,
    including the sync push's `INSERT … ON CONFLICT (id) DO NOTHING`, backend-design.md §3) and ORM bulk
    statements bypass it, so code writing audited tables that way must add its audit rows itself
    (e.g. `session.execute(insert(AUDIT_LOG), rows)` in the same transaction).
    """


def _json_default(value: object) -> str:
    """Render a non-JSON value (UUID, datetime, date, Decimal, geography) for the `diff` column.

    Args:
        value: any column value `json` cannot encode natively.

    Returns:
        ISO 8601 text for dates and times, else `str(value)`.
    """
    iso = getattr(value, "isoformat", None)
    return str(iso()) if callable(iso) else str(value)


def _diff(state: InstanceState[Any], action: str) -> dict[str, Any]:
    """Describe what a flush did to one row.

    Args:
        state: the instance state of an audited object, inside `after_flush`.
        action: `create`, `update` or `delete`.

    Returns:
        For `update`, `{column: [old, new]}` for changed columns only; otherwise `{column: value}` for every
        loaded column. Values are made JSON-safe.
    """
    out: dict[str, Any] = {}
    for attr in state.mapper.column_attrs:
        if action == "update":
            history = state.attrs[attr.key].history
            if history.has_changes():
                out[attr.key] = [next(iter(history.deleted), None), next(iter(history.added), None)]
        elif attr.key in state.dict:
            out[attr.key] = state.dict[attr.key]
    result: dict[str, Any] = json.loads(json.dumps(out, default=_json_default))
    return result


def audit_rows(session: Session) -> list[dict[str, Any]]:
    """Build the `audit_log` rows for the audited objects in the current flush.

    Args:
        session: a session inside `after_flush` (its new/dirty/deleted sets still show the flushed work).

    Returns:
        One row dict per created, changed or deleted `Audited` object, stamped with the current
        `AuditContext`; empty when nothing audited changed.
    """
    ctx = _context.get() or AuditContext()  # unset = system action, nobody to stamp
    gps = f"SRID=4326;POINT({ctx.gps.lon} {ctx.gps.lat})" if ctx.gps else None
    now = utcnow()
    rows: list[dict[str, Any]] = []
    for action, objects in (("create", session.new), ("update", session.dirty), ("delete", session.deleted)):
        for obj in objects:
            if not isinstance(obj, Audited) or (action == "update" and not session.is_modified(obj)):
                continue
            state: InstanceState[Any] = inspect(obj, raiseerr=True)
            rows.append(
                {
                    "id": uuid7(),
                    "at": now,
                    "actor_user_id": ctx.actor_user_id,
                    "on_behalf_of_farmer_id": ctx.on_behalf_of_farmer_id,
                    "assist_session_id": ctx.assist_session_id,
                    "device_id": ctx.device_id,
                    "gps": gps,
                    "action": action,
                    "entity_type": str(state.mapper.persist_selectable.description),
                    "entity_id": state.dict.get("id"),
                    "diff": _diff(state, action),
                    "request_id": ctx.request_id,
                }
            )
    return rows


@event.listens_for(Session, "after_flush")
def _write_audit_rows(session: Session, _flush_context: UOWTransaction) -> None:
    """Insert the audit rows for this flush in the same transaction as the change itself.

    Args:
        session: the flushing session (the sync session behind an `AsyncSession` too).
        _flush_context: SQLAlchemy's unit-of-work object (unused).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: the insert failed; the flush's transaction then rolls back, so a
            change is never stored without its audit row.

    Side effects:
        Executes one multi-row INSERT into `audit_log` when audited objects changed.
    """
    rows = audit_rows(session)
    if rows:
        session.connection().execute(insert(AUDIT_LOG), rows)
