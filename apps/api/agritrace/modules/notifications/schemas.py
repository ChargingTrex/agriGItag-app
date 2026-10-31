"""Response schema of the notifications API (lean list items for 2G/3G phones).

Serves: FR7 (the farmer's or officer's own messages), docs/api/conventions.md (cursor pages, flat items).
Callers: notifications router and service; the OpenAPI export and generated clients (D-003).
"""

import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field

from agritrace.core.enums import NotificationChannel, NotificationStatus


class NotificationOut(BaseModel):
    """One message sent (or attempted) to the caller."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID = Field(description="Notification id (UUIDv7, so newer ids sort later).")
    template_key: str = Field(description="Template, e.g. `harvest_reminder`; the app may show its own text.")
    channel: NotificationChannel = Field(description="push, sms, whatsapp or console.")
    lang: str = Field(description="Language the message was rendered in: `ta` or `en`.")
    payload: dict[str, Any] = Field(description="Template variables; secrets (the OTP code) appear as `***`.")
    status: NotificationStatus = Field(description="queued, sent or failed.")
    created_at: datetime = Field(description="When the message was queued, ISO 8601 UTC.")
