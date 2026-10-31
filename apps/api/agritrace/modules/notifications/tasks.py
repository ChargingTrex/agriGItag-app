"""Celery task `notifications.send`: render and deliver one message off the request path.

Kwargs contract (TODO B02): `user_id` (str UUID), `template_key`, `channel` (`sms` | `push` | `whatsapp` |
`console`), `lang` (`ta` | `en`), `payload` (template variables; `code` is secret). The phone is resolved
from `user_id` here, never sent in the message; `payload.code` never reaches logs (worker masking filter),
the database (redacted payload) or a result backend (none, D-009).

Serves: FR7, UserFlows §Alerts, help and feature phones, Arch §Notifications, D-004 (enqueued by name
from `core.task_names`), D-009.
Callers: Celery worker (autodiscovered); identity `_send_otp_sms` and later modules via
`app.send_task(task_names.NOTIFICATIONS_SEND, kwargs=...)`; tests.
"""

import uuid
from typing import Any

from agritrace.core import task_names
from agritrace.modules.notifications import service
from agritrace.worker import app, run_db_task


@app.task(name=task_names.NOTIFICATIONS_SEND)  # type: ignore[untyped-decorator]  # celery ships no stubs
def send(user_id: str, template_key: str, channel: str, lang: str, payload: dict[str, Any]) -> str | None:
    """Deliver one notification (see the module docstring for the kwargs contract).

    Args:
        user_id: recipient user id.
        template_key: template name, e.g. `otp`.
        channel: delivery channel.
        lang: preferred language.
        payload: template variables.

    Returns:
        The final status value (`sent` or `failed`), or None for an unknown user.

    Raises:
        ValueError: malformed `user_id` or unknown `channel`.
        sqlalchemy.exc.SQLAlchemyError: database failure; Celery logs it with arguments masked.

    Side effects:
        See `service.deliver`: one `notifications` row and one provider call.
    """
    status = run_db_task(service.deliver, uuid.UUID(user_id), template_key, channel, lang, payload)
    return status.value if status else None
