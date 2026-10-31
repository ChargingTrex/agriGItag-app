"""Batch approvals, lot intakes and batch shares become append-only (B09, D-033, D-005).

Serves: Dataflow §4 (approval gates are recorded human decisions), FR10/FR60 (intake quantities and lot
shares are commercial records printed on public pages), D-005 (append-only, corrections add rows), D-033.
Callers: `alembic upgrade` / `alembic downgrade` (apps/api/alembic.ini); tests/integration/test_schema.py
and tests/integration/test_lots_batches.py (`alembic upgrade head`).

Reuses `forbid_change()` from 0001 with no allowed columns: any UPDATE or DELETE raises
`append_only_violation`, which the API maps to the registered error of the same code. No model changes,
so `alembic check` reports no drift.

Revision ID: 0004_lots_append_only
Revises: 0003_masters
Create Date: 2026-10-31
"""

from collections.abc import Sequence

from alembic import op

revision: str = "0004_lots_append_only"
down_revision: str | Sequence[str] | None = "0003_masters"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TABLES = ("batch_approvals", "lot_intakes", "batch_shares")


def upgrade() -> None:
    """Add the append-only trigger to each table.

    Side effects:
        CREATE TRIGGER <table>_append_only BEFORE UPDATE OR DELETE (no columns may change).
    """
    for table in TABLES:
        op.execute(
            f"CREATE TRIGGER {table}_append_only BEFORE UPDATE OR DELETE ON {table} "
            "FOR EACH ROW EXECUTE FUNCTION forbid_change()"
        )


def downgrade() -> None:
    """Drop the triggers again.

    Side effects:
        DROP TRIGGER on the three tables; rows may then be edited.
    """
    for table in TABLES:
        op.execute(f"DROP TRIGGER IF EXISTS {table}_append_only ON {table}")
