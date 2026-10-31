"""Batch approvals, lot intakes and batch shares become append-only; intakes gain a correction link (B09).

Serves: Dataflow §4 (approval gates are recorded human decisions), FR10/FR60 (intake quantities and lot
shares are commercial records printed on public pages), D-005 and CLAUDE.md §6 (append-only, corrections add
rows), D-033.
Callers: `alembic upgrade` / `alembic downgrade` (apps/api/alembic.ini); tests/integration/test_schema.py
and tests/integration/test_lots_batches.py (`alembic upgrade head`).

Reuses `forbid_change()` from 0001 with no allowed columns: any UPDATE or DELETE raises
`append_only_violation`, which the API maps to the registered error of the same code. A wrong intake is
corrected by a new row naming it in `supersedes_intake_id` (UNIQUE: corrected at most once) with a
`correction_reason`. Mirrors `lots_batches/models.py` `LotIntake`, so `alembic check` reports no drift.

Revision ID: 0004_lots_append_only
Revises: 0003_masters
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0004_lots_append_only"
down_revision: str | Sequence[str] | None = "0003_masters"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

TABLES = ("batch_approvals", "lot_intakes", "batch_shares")


def upgrade() -> None:
    """Add the intake correction columns, then the append-only trigger to each table.

    Side effects:
        ALTER TABLE lot_intakes (two nullable columns, UNIQUE, self foreign key; no rewrite);
        CREATE TRIGGER <table>_append_only BEFORE UPDATE OR DELETE (no columns may change).
    """
    op.add_column(
        "lot_intakes",
        sa.Column(
            "supersedes_intake_id",
            sa.Uuid(),
            nullable=True,
            comment="Intake this row corrects (append-only, D-033); each intake is corrected at most once.",
        ),
    )
    op.add_column(
        "lot_intakes",
        sa.Column(
            "correction_reason",
            sa.Text(),
            nullable=True,
            comment="Why the superseded intake was wrong; required with `supersedes_intake_id`.",
        ),
    )
    op.create_unique_constraint(
        op.f("uq_lot_intakes_supersedes_intake_id"), "lot_intakes", ["supersedes_intake_id"]
    )
    op.create_foreign_key(
        op.f("fk_lot_intakes_supersedes_intake_id_lot_intakes"),
        "lot_intakes",
        "lot_intakes",
        ["supersedes_intake_id"],
        ["id"],
    )
    for table in TABLES:
        op.execute(
            f"CREATE TRIGGER {table}_append_only BEFORE UPDATE OR DELETE ON {table} "
            "FOR EACH ROW EXECUTE FUNCTION forbid_change()"
        )


def downgrade() -> None:
    """Drop the triggers and the correction columns again.

    Side effects:
        DROP TRIGGER on the three tables (rows may then be edited); corrections lose their link and reason.
    """
    for table in TABLES:
        op.execute(f"DROP TRIGGER IF EXISTS {table}_append_only ON {table}")
    op.drop_constraint(
        op.f("fk_lot_intakes_supersedes_intake_id_lot_intakes"), "lot_intakes", type_="foreignkey"
    )
    op.drop_constraint(op.f("uq_lot_intakes_supersedes_intake_id"), "lot_intakes", type_="unique")
    op.drop_column("lot_intakes", "correction_reason")
    op.drop_column("lot_intakes", "supersedes_intake_id")
