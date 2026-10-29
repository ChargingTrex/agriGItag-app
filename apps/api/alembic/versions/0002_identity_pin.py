"""Office PIN on users (Argon2id hash, wrong-PIN counter, lock time) and device sign-in columns (B02, D-024).

Serves: Arch §Security ("Field officers and admins add a 4-digit PIN"), FR1, D-012 (small follow-up
revision reviewed centrally), D-024 (phone + OTP + PIN session model).
Callers: `alembic upgrade` / `alembic downgrade` (apps/api/alembic.ini); tests/integration/test_schema.py
and tests/integration/test_identity.py (`alembic upgrade head`).

Mirrors `agritrace/modules/identity/models.py` `User.pin_hash`, `pin_attempts`, `pin_locked_until` and
`Device.previous_refresh_token_hash`, `signed_in_at`, so `alembic check` reports no drift.

Revision ID: 0002_identity_pin
Revises: 0001
Create Date: 2026-10-29
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# DECISION D-012: a module's schema change is a small follow-up revision on top of 0001.
#   ADV: the initial schema stays reviewable as one file; this revision is five nullable/defaulted columns.
#   COMPROMISE: parallel work packages adding revisions on 0001 create two heads; the Orchestrator rebases
#     `down_revision` at merge time.
revision: str = "0002_identity_pin"
down_revision: str | Sequence[str] | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Add the three PIN columns to `users` and the two sign-in columns to `devices`.

    Side effects:
        ALTER TABLE users and devices (no table rewrite: nullable columns and a constant default).
    """
    op.add_column(
        "users",
        sa.Column(
            "pin_hash",
            sa.Text(),
            nullable=True,
            comment="Argon2id hash of the 4-digit office PIN; null until set. Never returned by the API.",
        ),
    )
    op.add_column(
        "users",
        sa.Column(
            "pin_attempts",
            sa.Integer(),
            server_default=sa.text("0"),
            nullable=False,
            comment="Wrong PINs since the last success or lock (max 5).",
        ),
    )
    op.add_column(
        "users",
        sa.Column(
            "pin_locked_until",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="PIN refused until this instant after 5 wrong tries (5-minute lock).",
        ),
    )
    op.add_column(
        "devices",
        sa.Column(
            "previous_refresh_token_hash",
            sa.Text(),
            nullable=True,
            comment="Hash of the refresh token rotated out last; presenting it again is reuse (D-024).",
        ),
    )
    op.add_column(
        "devices",
        sa.Column(
            "signed_in_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="Last OTP/PIN sign-in on this device; access and pin tokens issued earlier are refused.",
        ),
    )


def downgrade() -> None:
    """Drop the PIN and device sign-in columns.

    Side effects:
        ALTER TABLE devices and users; every stored PIN is lost (office users choose a new one at next
        sign-in) and reuse detection forgets the previous refresh tokens.
    """
    op.drop_column("devices", "signed_in_at")
    op.drop_column("devices", "previous_refresh_token_hash")
    op.drop_column("users", "pin_locked_until")
    op.drop_column("users", "pin_attempts")
    op.drop_column("users", "pin_hash")
