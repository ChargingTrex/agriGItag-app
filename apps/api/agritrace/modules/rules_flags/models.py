"""rules_flags table: flags raised by the server-side rule checks and their resolution.

Serves: FR11 (quantity mismatch), FR28/FR29 (GI region), FR49, FR56 (practice contradictions), FR60,
FR68–FR70 (yield, event GPS, review on flags), Dataflow §4 (gates block on open holds), D-006 (server rules
are the authority).
Callers: rules_flags service, router and tasks (B08), lots_batches gates (B09), reporting (B10), events
sync pull (B06) through `models` (D-004), alembic/env.py, migration 0001.
"""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, TenantScoped
from agritrace.core.enums import FlagStatus, FlagSubject, Role, Severity


class Flag(Audited, IdTimestamps, TenantScoped, Base):
    """A rule finding on a plot, event, lot, batch or reading, open until resolved (FR11, FR28, FR68–FR70)."""

    __tablename__ = "flags"
    __table_args__ = (Index("ix_flags_subject", "subject_type", "subject_id"),)

    subject_type: Mapped[FlagSubject] = mapped_column(comment="Kind of row flagged.")
    subject_id: Mapped[uuid.UUID] = mapped_column(
        comment="Id of the flagged row (polymorphic, no foreign key)."
    )
    rule_code: Mapped[str] = mapped_column(comment="Rule that raised it, e.g. quantity_mismatch.")
    severity: Mapped[Severity] = mapped_column(comment="info, warn, or hold (blocks GI labelling).")
    details: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Rule inputs and limits behind the finding."
    )
    dedupe_key: Mapped[str] = mapped_column(
        unique=True, comment="rule_code + subject (+ discriminator); re-running a rule never duplicates."
    )
    status: Mapped[FlagStatus] = mapped_column(default=FlagStatus.OPEN, comment="Resolution state (FR70).")
    assigned_role: Mapped[Role | None] = mapped_column(comment="Role expected to resolve it.")
    raised_at: Mapped[datetime] = mapped_column(comment="When the rule first raised it.")
    resolved_by: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("users.id"), comment="Resolver.")
    resolution_reason_code: Mapped[str | None] = mapped_column(comment="Coded resolution reason (FR70).")
    resolution_note: Mapped[str | None] = mapped_column(comment="Reviewer's note: method, evidence (FR70).")
    resolved_at: Mapped[datetime | None] = mapped_column(comment="When it was resolved.")
