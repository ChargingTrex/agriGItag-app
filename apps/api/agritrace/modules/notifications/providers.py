"""Delivery providers: the console provider (dev) and the SMS gateway stub, chosen per channel.

No provider SDK is used yet; a real Indian SMS gateway (DLT templates, `SMS_SENDER_ID`) replaces
`UnconfiguredProvider` when one is chosen. Push (FCM) and WhatsApp have no provider yet either.

Serves: FR7 (push/SMS reminders), UserFlows §Alerts, help and feature phones (SMS for every farmer),
Arch §Notifications.
Callers: notifications service (`deliver`), tests/unit/test_notifications_service.py.
"""

import logging
from typing import Protocol

from agritrace.core.config import get_settings
from agritrace.core.enums import NotificationChannel

log = logging.getLogger(__name__)


class ProviderRefused(Exception):
    """The provider refused or could not take the message; `str(error)` is a snake_case reason.

    Internal to the worker: the service turns it into a `failed` row, so it never reaches an API client and
    is not an `AppError` (gen-error-codes checks only `raise ...Error` names, the API's error classes).
    """


class SmsProvider(Protocol):
    """What the service needs from any provider (SMS gateway, push, console)."""

    def send(self, to: str, text: str, log_text: str) -> str:
        """Hand one message to the provider.

        Args:
            to: recipient phone number in E.164 form.
            text: the full message, secrets included.
            log_text: the same message with secrets replaced; the only form that may be logged.

        Returns:
            The provider's message reference.

        Raises:
            ProviderRefused: the message was not accepted (reason in the message).
        """
        ...


class ConsoleProvider:
    """Development provider: logs the message without its secrets or the phone number instead of sending."""

    def send(self, to: str, text: str, log_text: str) -> str:
        """Log the redacted message.

        Args:
            to: recipient phone (not logged; CLAUDE.md §6).
            text: the full message (not logged; it can carry an OTP).
            log_text: the redacted message, logged at INFO.

        Returns:
            `console`.

        Side effects:
            One INFO log line.
        """
        log.info("console notification: %s", log_text)
        return "console"


class UnconfiguredProvider:
    """Stand-in for a channel without a real gateway; every message fails `provider_not_configured`."""

    # TODO(provider): replace with the chosen SMS gateway client (sender `SMS_SENDER_ID`, DLT template ids).
    def send(self, to: str, text: str, log_text: str) -> str:
        """Refuse the message.

        Args:
            to: recipient phone (unused).
            text: the full message (unused).
            log_text: the redacted message (unused).

        Returns:
            Never returns.

        Raises:
            ProviderRefused: always, `provider_not_configured`.
        """
        raise ProviderRefused("provider_not_configured")


def select_provider(channel: NotificationChannel) -> SmsProvider:
    """Pick the provider for a channel from the settings.

    Args:
        channel: the notification's channel.

    Returns:
        `ConsoleProvider` for `console`, and for `sms` when `SMS_PROVIDER=console`; otherwise
        `UnconfiguredProvider` (push and WhatsApp have no provider yet).

    Raises:
        pydantic.ValidationError: the settings are invalid (from `get_settings`).
    """
    if channel is NotificationChannel.CONSOLE or (
        channel is NotificationChannel.SMS and get_settings().sms_provider == "console"
    ):
        return ConsoleProvider()
    return UnconfiguredProvider()
