"""publishing table: builds of the static public batch page.

Serves: PRD §5 (Public Traceability Record, versioned with a generation marker), FR15–FR17 (public page
regenerated on change, last-updated stamp), FR12 (QR), Dataflow Stage 10, D-007 (static page built by a
worker job).
Callers: publishing service, router and `publishing.build_page` task (B10), lots_batches publish gate
(B09) through `models` (D-004), alembic/env.py, migration 0001.
"""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.db import Base, IdTimestamps


class PageBuild(IdTimestamps, Base):
    """One build of a batch's public page with the exact data snapshot it rendered (FR15–FR17, D-007)."""

    __tablename__ = "page_builds"
    __table_args__ = (UniqueConstraint("batch_id", "build_no"),)

    batch_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("batches.id"), comment="Batch the page is for.")
    build_no: Mapped[int] = mapped_column(comment="Build number per batch, 1 upwards.")
    generation: Mapped[int] = mapped_column(comment="Generation marker for cache busting (PRD §5).")
    snapshot: Mapped[dict[str, Any]] = mapped_column(
        comment="Public data rendered, already filtered for privacy (CLAUDE.md §6)."
    )
    html_key: Mapped[str | None] = mapped_column(comment="Object key of the HTML page in public-pages.")
    json_key: Mapped[str | None] = mapped_column(comment="Object key of the JSON twin of the page.")
    qr_key: Mapped[str | None] = mapped_column(comment="Object key of the QR image (FR12).")
    status: Mapped[str] = mapped_column(
        comment="Build state set by the build task, e.g. queued, built, failed."
    )
    built_at: Mapped[datetime | None] = mapped_column(
        comment="When the page was written (FR17 last updated)."
    )
    trigger: Mapped[str] = mapped_column(comment="What caused the build, e.g. publish, new_event, manual.")
