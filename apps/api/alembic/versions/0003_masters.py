"""Plots remember their GI tag: nullable `plots.gi_tag_id` → `gi_tags` (B13, ends the single-GI shortcut).

Serves: FR27–FR32 (region check per GI tag), FR64–FR67, D-012 (small follow-up revision), D-019, TODO.md
"B13 migration 0003: add plots.gi_tag_id".
Callers: `alembic upgrade` / `alembic downgrade` (apps/api/alembic.ini); tests/integration/test_schema.py,
tests/integration/test_config_imports.py (`alembic upgrade head` then `alembic check`).

Mirrors `agritrace/modules/registry/models.py` `Plot.gi_tag_id`, so `alembic check` reports no drift. The
imports (B13) need no new index: villages look up the unique `lgd_code`, farmers the unique `users.phone`,
inputs read the FPO's list once through the existing `inputs_master.fpo_id` index.

Backfill note: existing plots keep NULL and the region check falls back to the only GI tag that has a
region (registry `_check_region`). Before a second GI crop is onboarded, run once per pilot database:
`UPDATE plots SET gi_tag_id = (SELECT id FROM gi_tags WHERE gi_number = '883') WHERE gi_tag_id IS NULL;`
It is not run here because the GI tag row is seed data, not schema.

Revision ID: 0003_masters
Revises: 0002_identity_pin
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# DECISION D-012: a module's schema change is a small follow-up revision on top of the previous head.
#   ADV: one nullable column and one FK, reviewable in isolation; no table rewrite.
#   COMPROMISE: parallel work packages adding revisions on 0002 create two heads; the Orchestrator rebases
#     `down_revision` at merge time.
revision: str = "0003_masters"
down_revision: str | Sequence[str] | None = "0002_identity_pin"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Add `plots.gi_tag_id` with its foreign key.

    Side effects:
        ALTER TABLE plots (nullable column: no rewrite, no backfill).
    """
    op.add_column(
        "plots",
        sa.Column(
            "gi_tag_id",
            sa.Uuid(),
            nullable=True,
            comment="GI tag of the crop picked at onboarding; null = pilot single-GI fallback.",
        ),
    )
    op.create_foreign_key(op.f("fk_plots_gi_tag_id_gi_tags"), "plots", "gi_tags", ["gi_tag_id"], ["id"])


def downgrade() -> None:
    """Drop `plots.gi_tag_id` and its foreign key.

    Side effects:
        ALTER TABLE plots; stored GI tags of plots are lost (the fallback check still works).
    """
    op.drop_constraint(op.f("fk_plots_gi_tag_id_gi_tags"), "plots", type_="foreignkey")
    op.drop_column("plots", "gi_tag_id")
