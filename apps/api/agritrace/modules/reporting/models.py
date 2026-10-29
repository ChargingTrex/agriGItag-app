"""reporting table: anonymous scans of public batch pages.

Serves: FR20 (scan analytics: number and geography of scans per batch), Dataflow Stage 10.
Callers: reporting service and router (B10: `POST /public/scans`, FPO dashboard) through `models`
(D-004), alembic/env.py, migration 0001.
"""

from datetime import datetime

from geoalchemy2 import Geography
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.db import Base, IdTimestamps, SpatialValue


class ScanEvent(IdTimestamps, Base):
    """One anonymous open of a public batch page (FR20); holds no personal data."""

    __tablename__ = "scan_events"

    # A code, not a foreign key: scans of unknown or mistyped codes are still counted.
    batch_code: Mapped[str] = mapped_column(index=True, comment="Batch code from the scanned URL.")
    scanned_at: Mapped[datetime] = mapped_column(comment="When the page was opened.")
    approx_location: Mapped[SpatialValue | None] = mapped_column(
        Geography("POINT", 4326, spatial_index=False), comment="Coarse location (city level), if known."
    )
    user_agent_hash: Mapped[str | None] = mapped_column(
        comment="Hash of the user agent, to count unique viewers."
    )
