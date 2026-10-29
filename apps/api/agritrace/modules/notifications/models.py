"""notifications table: messages to farmers and FPO staff and their delivery state.

Serves: FR7 (push/SMS reminders), FR37 (benefit records surfaced by SMS, later phase), FR5 (language).
Callers: notifications service, router and `notifications.send` task (B11); other modules enqueue by task
name only (`core/task_names.py`, D-004); alembic/env.py, migration 0001.
"""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.db import Base, IdTimestamps
from agritrace.core.enums import NotificationChannel, NotificationStatus


class Notification(IdTimestamps, Base):
    """One message to one user on one channel (FR7)."""

    __tablename__ = "notifications"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), index=True, comment="Recipient.")
    channel: Mapped[NotificationChannel] = mapped_column(comment="push, sms, whatsapp or console (dev).")
    template_key: Mapped[str] = mapped_column(comment="Message template, e.g. harvest_window_approaching.")
    lang: Mapped[str] = mapped_column(comment="Language rendered: ta or en (FR5).")
    payload: Mapped[dict[str, Any]] = mapped_column(comment="Template variables; never phone numbers or IDs.")
    status: Mapped[NotificationStatus] = mapped_column(
        default=NotificationStatus.QUEUED, comment="queued, sent or failed."
    )
    provider_ref: Mapped[str | None] = mapped_column(comment="Message id returned by the SMS/push provider.")
    sent_at: Mapped[datetime | None] = mapped_column(comment="When the provider accepted it.")
