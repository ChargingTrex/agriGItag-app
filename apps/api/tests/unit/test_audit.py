"""Unit tests of the audit trail, without a database.

Covers context handling and the rows built for created, changed and ignored objects.

Serves: FR25 (audit trail with edit history), CLAUDE.md §6 (assist mode recorded).
Callers: pytest (`make test-unit`). tests/integration/test_schema.py checks the rows reach `audit_log`.
"""

import uuid
from collections.abc import Iterator
from datetime import UTC, datetime

import pytest
from sqlalchemy.orm import Session, make_transient_to_detached

from agritrace.core.audit import AUDIT_LOG, AuditContext, audit_rows, reset_audit_context, set_audit_context
from agritrace.core.schemas import GeoPoint
from agritrace.modules.identity.models import AuditLog, OtpChallenge
from agritrace.modules.registry.models import Farmer

OFFICER, FARMER, ASSIST, DEVICE = (uuid.uuid4() for _ in range(4))


@pytest.fixture
def assist_context() -> Iterator[AuditContext]:
    """Set an assist-mode audit context for one test.

    Returns:
        An iterator yielding the context that is in force.

    Side effects:
        Sets, then resets, the audit context variable.
    """
    ctx = AuditContext(OFFICER, FARMER, ASSIST, DEVICE, GeoPoint(lat=9.58, lon=77.96), "req-1")
    token = set_audit_context(ctx)
    yield ctx
    reset_audit_context(token)


def _farmer(**values: object) -> Farmer:
    """Build an unsaved farmer with required columns filled.

    Args:
        **values: column overrides.

    Returns:
        A transient `Farmer`.
    """
    base: dict[str, object] = {"id": uuid.uuid4(), "fpo_id": uuid.uuid4(), "code": "F-001", "name": "Muthu"}
    return Farmer(**(base | values))


def test_lightweight_audit_table_matches_the_model() -> None:
    """core.audit writes exactly the AuditLog columns that have no database default."""
    written = set(AUDIT_LOG.columns.keys())
    assert written <= set(AuditLog.__table__.columns.keys())
    assert set(AuditLog.__table__.columns.keys()) - written == {"created_at", "updated_at"}


def test_create_row_carries_actor_assist_device_and_gps(assist_context: AuditContext) -> None:
    """A new audited object yields one `create` row stamped with the whole context.

    Args:
        assist_context: the context in force (fixture).
    """
    session = Session()
    farmer = _farmer()
    session.add(farmer)
    [row] = audit_rows(session)
    assert row["action"] == "create" and row["entity_type"] == "farmers" and row["entity_id"] == farmer.id
    assert (row["actor_user_id"], row["on_behalf_of_farmer_id"]) == (OFFICER, FARMER)
    assert (row["assist_session_id"], row["device_id"], row["request_id"]) == (ASSIST, DEVICE, "req-1")
    assert row["gps"] == "SRID=4326;POINT(77.96 9.58)"
    assert row["diff"]["name"] == "Muthu" and row["diff"]["id"] == str(farmer.id)


def test_update_row_holds_old_and_new_values_only_for_changed_columns(assist_context: AuditContext) -> None:
    """A changed persistent object yields an `update` row with `{column: [old, new]}`.

    Args:
        assist_context: the context in force (fixture).
    """
    farmer = _farmer(approved_at=datetime(2026, 2, 14, tzinfo=UTC))
    make_transient_to_detached(farmer)
    session = Session()
    session.add(farmer)
    farmer.name = "Muthu K"
    [row] = audit_rows(session)
    assert row["action"] == "update"
    assert row["diff"] == {"name": ["Muthu", "Muthu K"]}


def test_unaudited_objects_and_missing_context() -> None:
    """Objects without `Audited` are skipped; with no context set, rows are system rows (no actor)."""
    session = Session()
    session.add(OtpChallenge(phone="+919876543210", code_hash="x", expires_at=datetime.now(UTC)))
    assert audit_rows(session) == []
    session.add(_farmer())
    [row] = audit_rows(session)
    assert row["actor_user_id"] is None and row["gps"] is None and row["request_id"] is None


def test_reset_restores_previous_context() -> None:
    """Nested contexts unwind in order."""
    outer = set_audit_context(AuditContext(actor_user_id=OFFICER))
    inner = set_audit_context(AuditContext(actor_user_id=FARMER))
    reset_audit_context(inner)
    session = Session()
    session.add(_farmer())
    assert audit_rows(session)[0]["actor_user_id"] == OFFICER
    reset_audit_context(outer)
