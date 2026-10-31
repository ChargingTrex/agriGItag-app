"""notifications service: render and deliver one message (`deliver`) and list a user's messages.

Serves: FR7 (push/SMS reminders and results), FR5 (language), UserFlows §Alerts, help and feature phones,
Arch §Notifications, TODO B02 kwargs contract (`payload.code` never stored or logged).
Callers: `notifications.send` task (tasks.py), notifications router; other modules enqueue
`task_names.NOTIFICATIONS_SEND` by name and never call this directly (D-004);
tests/unit/test_notifications_service.py, tests/integration/test_notifications.py.
"""

import logging
import uuid
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.enums import NotificationChannel, NotificationStatus
from agritrace.core.schemas import Page
from agritrace.core.time import utcnow
from agritrace.modules.identity.models import User
from agritrace.modules.notifications import templates
from agritrace.modules.notifications.models import Notification
from agritrace.modules.notifications.providers import ProviderRefused, select_provider
from agritrace.modules.notifications.schemas import NotificationOut

log = logging.getLogger(__name__)


async def deliver(
    session: AsyncSession,
    user_id: uuid.UUID,
    template_key: str,
    channel: str,
    lang: str,
    payload: dict[str, Any],
) -> NotificationStatus | None:
    """Record, render and send one message; template and provider failures end as a `failed` row.

    Args:
        session: database session (committed here).
        user_id: recipient; their phone is read from `users`.
        template_key: a key of `templates.TEMPLATES`.
        channel: `sms`, `push`, `whatsapp` or `console`.
        lang: `ta` or `en`; falls back to English when the template has no text in it.
        payload: template variables; secret ones (`code`) are stored and logged redacted.

    Returns:
        The final status (`sent` or `failed`), or None when the user does not exist (nothing recorded).

    Raises:
        ValueError: `channel` is not a known channel.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database (the row may stay `queued`).

    Side effects:
        Inserts one `notifications` row (committed as `queued`, then committed as `sent` or `failed` with
        `provider_ref`); calls the provider; logs failures without payload values.
    """
    chosen = NotificationChannel(channel)
    user = await session.get(User, user_id)
    if user is None:
        log.warning("notification %s for unknown user %s dropped", template_key, user_id)
        return None
    row = Notification(
        user_id=user_id,
        channel=chosen,
        template_key=template_key,
        lang=lang,
        payload=templates.redact(payload),
        status=NotificationStatus.QUEUED,
    )
    session.add(row)
    await session.commit()

    try:
        row.lang, text = templates.render(template_key, lang, payload)
        _, log_text = templates.render(template_key, lang, row.payload)
        row.provider_ref = select_provider(chosen).send(user.phone, text, log_text)
        row.status, row.sent_at = NotificationStatus.SENT, utcnow()
    except (KeyError, ProviderRefused) as e:
        if isinstance(e, ProviderRefused):
            reason = str(e)
        else:
            reason = "missing_variable" if template_key in templates.TEMPLATES else "unknown_template"
        # shortcut: the table has no error column, so the reason is kept in provider_ref as `error:<reason>`;
        #   add an `error` column with the first real provider.
        row.status, row.provider_ref = NotificationStatus.FAILED, f"error:{reason}"
        log.warning("notification %s (%s) failed: %s", row.id, template_key, reason)
    await session.commit()
    return row.status


async def list_mine(
    session: AsyncSession, user_id: uuid.UUID, cursor: uuid.UUID | None, limit: int
) -> Page[NotificationOut]:
    """List one user's notifications, newest first.

    Args:
        session: database session.
        user_id: the caller.
        cursor: id of the last item of the previous page, or None for the first page.
        limit: page size.

    Returns:
        One page; `next_cursor` is the last item's id when more rows exist.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(Notification).where(Notification.user_id == user_id)
    if cursor is not None:
        query = query.where(Notification.id < cursor)
    rows = list((await session.scalars(query.order_by(Notification.id.desc()).limit(limit + 1))).all())
    more = len(rows) > limit
    items = [NotificationOut.model_validate(r) for r in rows[:limit]]
    return Page[NotificationOut](items=items, next_cursor=str(items[-1].id) if more else None, has_more=more)
