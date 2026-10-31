"""Unit tests: credential columns never reach the append-only audit trail in clear (review B02-r1 P1-1).

Serves: FR25 (audit trail), D-024 (PIN and refresh hashes are secrets), CWE-532.
Callers: pytest (`make test-unit`).
"""

import json
import uuid

from sqlalchemy.orm import Session, make_transient_to_detached

from agritrace.core.audit import REDACTED, audit_rows, is_secret_column
from agritrace.modules.identity.models import Device, User
from agritrace.modules.identity.service import hash_pin


def test_secret_columns_are_recognised_by_name() -> None:
    """`*_hash` and `*_secret` columns are secrets; the identity tables' hash columns all match."""
    assert is_secret_column("pin_hash") and is_secret_column("refresh_token_hash")
    assert is_secret_column("previous_refresh_token_hash") and is_secret_column("api_secret")
    assert not is_secret_column("pin_attempts") and not is_secret_column("phone")
    hashes = [c for c in (*User.__table__.columns.keys(), *Device.__table__.columns.keys()) if "hash" in c]
    assert hashes and all(is_secret_column(c) for c in hashes)


def test_pin_set_and_change_are_audited_as_redacted() -> None:
    """Creating a user with a PIN and changing the PIN leave `[redacted]`, never the Argon2 hash."""
    session = Session()
    user = User(id=uuid.uuid4(), phone="+919800000001", name="Officer", pin_hash=hash_pin("2468"))
    session.add(user)
    [created] = audit_rows(session)
    assert created["diff"]["pin_hash"] == REDACTED

    old = hash_pin("2468")
    stored = User(id=uuid.uuid4(), phone="+919800000002", name="Officer", pin_hash=old, pin_attempts=0)
    make_transient_to_detached(stored)
    session = Session()
    session.add(stored)
    stored.pin_hash, stored.pin_attempts = hash_pin("1357"), 0
    stored.pin_attempts = 1
    [changed] = audit_rows(session)
    assert changed["diff"]["pin_hash"] == REDACTED
    assert changed["diff"]["pin_attempts"] == [0, 1]  # security events stay visible
    text = json.dumps([created, changed], default=str)
    assert "$argon2" not in text and old not in text and stored.pin_hash not in text
