"""Unit tests of notification delivery with an in-memory session.

Covers provider selection, the eager Celery path, unknown templates, the unconfigured SMS stub, and the
worker's masking of task arguments in failure logs.

Serves: B04 acceptance ("eager send → row sent/console", "unknown template → row failed, no raise"), FR7,
D-009 (acks_late, masked arguments), TODO B02 kwargs contract (`payload.code` never logged or stored).
Integration counterpart: tests/integration/test_notifications.py.
Callers: pytest (`make test-unit`).
"""

import asyncio
import logging
import uuid
from collections.abc import Callable, Coroutine, Iterator
from typing import Any

import pytest

from agritrace.core.config import get_settings
from agritrace.core.enums import NotificationChannel, NotificationStatus
from agritrace.modules.identity.models import User
from agritrace.modules.notifications import service
from agritrace.modules.notifications.models import Notification
from agritrace.modules.notifications.providers import ConsoleProvider, UnconfiguredProvider, select_provider

OTP = "424242"


@pytest.fixture(autouse=True)
def env(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Configure a JWT secret (the worker reads settings at import) and the console SMS provider.

    Args:
        monkeypatch: pytest's environment patcher.

    Returns:
        An iterator yielding once while the settings are active.

    Side effects:
        Sets JWT_SECRET and SMS_PROVIDER; clears the cached settings before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test-secret-of-at-least-32-bytes!")
    monkeypatch.setenv("SMS_PROVIDER", "console")
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


class FakeSession:
    """Just enough of `AsyncSession` for `deliver`: `get`, `add`, `commit`."""

    def __init__(self, user: User | None) -> None:
        """Hold the one user `get` can return.

        Args:
            user: the recipient, or None for an unknown user.
        """
        self.user = user
        self.added: list[Notification] = []
        self.commits = 0

    async def get(self, _model: type, key: uuid.UUID) -> User | None:
        """Return the user when the id matches.

        Args:
            _model: the ORM class (always `User` here).
            key: the primary key.

        Returns:
            The user or None.
        """
        return self.user if self.user and self.user.id == key else None

    def add(self, row: Notification) -> None:
        """Record an added row.

        Args:
            row: the notification.
        """
        self.added.append(row)

    async def commit(self) -> None:
        """Count commits."""
        self.commits += 1


def _user() -> User:
    """Build a recipient.

    Returns:
        A user with a phone and Tamil as language.
    """
    return User(id=uuid.uuid4(), phone="+919800000001", name="Farmer", lang="ta")


async def _deliver(session: FakeSession, template: str, channel: str = "sms", **payload: Any) -> Any:
    """Call `service.deliver` for the session's user.

    Args:
        session: the fake session.
        template: template key.
        channel: channel name.
        **payload: template variables.

    Returns:
        What `deliver` returned.
    """
    user_id = session.user.id if session.user else uuid.uuid4()
    return await service.deliver(session, user_id, template, channel, "ta", payload)  # type: ignore[arg-type]


def test_provider_selection(monkeypatch: pytest.MonkeyPatch) -> None:
    """Channel console → console; sms → console only when SMS_PROVIDER=console; push/whatsapp → unconfigured.

    Args:
        monkeypatch: pytest's environment patcher.
    """
    assert isinstance(select_provider(NotificationChannel.CONSOLE), ConsoleProvider)
    assert isinstance(select_provider(NotificationChannel.SMS), ConsoleProvider)
    assert isinstance(select_provider(NotificationChannel.PUSH), UnconfiguredProvider)
    monkeypatch.delenv("SMS_PROVIDER")
    get_settings.cache_clear()
    assert isinstance(select_provider(NotificationChannel.SMS), UnconfiguredProvider)
    assert isinstance(select_provider(NotificationChannel.CONSOLE), ConsoleProvider)


async def test_otp_sent_with_code_redacted_in_row_and_log(caplog: pytest.LogCaptureFixture) -> None:
    """The OTP row is `sent` by the console provider; the code is neither stored nor logged.

    Args:
        caplog: log capture.
    """
    session = FakeSession(_user())
    with caplog.at_level(logging.INFO):
        assert await _deliver(session, "otp", code=OTP) is NotificationStatus.SENT
    row = session.added[0]
    assert (row.status, row.provider_ref, row.lang) == (NotificationStatus.SENT, "console", "ta")
    assert row.payload == {"code": "***"} and row.sent_at is not None
    assert OTP not in caplog.text and "***" in caplog.text
    assert session.commits == 2


async def test_unknown_template_fails_without_raising() -> None:
    """An unknown template gives a `failed` row and no exception."""
    session = FakeSession(_user())
    assert await _deliver(session, "no_such_template") is NotificationStatus.FAILED
    row = session.added[0]
    assert (row.status, row.provider_ref) == (NotificationStatus.FAILED, "error:unknown_template")


async def test_missing_variable_and_unconfigured_sms_fail(monkeypatch: pytest.MonkeyPatch) -> None:
    """A missing variable and an SMS without a gateway both end `failed` with their reason.

    Args:
        monkeypatch: pytest's environment patcher.
    """
    session = FakeSession(_user())
    await _deliver(session, "payment_made", amount="₹100")
    assert session.added[0].provider_ref == "error:missing_variable"
    monkeypatch.delenv("SMS_PROVIDER")
    get_settings.cache_clear()
    await _deliver(session, "otp", code=OTP)
    assert (session.added[1].status, session.added[1].provider_ref) == (
        NotificationStatus.FAILED,
        "error:provider_not_configured",
    )


async def test_unknown_user_records_nothing() -> None:
    """No row can reference a missing user (foreign key), so nothing is written."""
    session = FakeSession(None)
    assert await _deliver(session, "otp", code=OTP) is None
    assert session.added == []


def test_eager_task_writes_sent_console_row(monkeypatch: pytest.MonkeyPatch) -> None:
    """`notifications.send` applied eagerly with the B02 kwargs writes a `sent` row via the console provider.

    Args:
        monkeypatch: replaces the task's DB runner with one using the fake session.
    """
    from agritrace.modules.notifications import tasks
    from agritrace.worker import app

    session = FakeSession(_user())

    def run_fake(work: Callable[..., Coroutine[Any, Any, Any]], *args: Any) -> Any:
        """Stand-in for `run_db_task` that hands `work` the fake session.

        Args:
            work: the service coroutine function.
            *args: its arguments after the session.

        Returns:
            What `work` returned.
        """
        return asyncio.run(work(session, *args))

    monkeypatch.setattr(tasks, "run_db_task", run_fake)
    assert app.conf.task_acks_late and app.conf.task_reject_on_worker_lost
    assert not app.conf.result_extended
    kwargs = {
        "user_id": str(session.user.id),  # type: ignore[union-attr]
        "template_key": "otp",
        "channel": "console",
        "lang": "en",
        "payload": {"code": OTP},
    }
    result = tasks.send.apply(kwargs=kwargs)
    assert result.get() == "sent"
    row = session.added[0]
    assert (row.status, row.provider_ref, row.channel) == (NotificationStatus.SENT, "console", "console")


def test_failure_log_masks_task_arguments(caplog: pytest.LogCaptureFixture) -> None:
    """A task that raises is logged by Celery without its args or kwargs (the OTP stays out of logs).

    Args:
        caplog: log capture.
    """
    from agritrace.worker import MASKED, app

    @app.task(name="tests.boom")  # type: ignore[untyped-decorator]
    def boom(payload: dict[str, str]) -> None:
        """Always fail.

        Args:
            payload: carries the secret.

        Raises:
            RuntimeError: always.
        """
        raise RuntimeError("boom")

    with caplog.at_level(logging.INFO):
        boom.apply(kwargs={"payload": {"code": OTP}})
        # The worker's "received" line (celery.worker.strategy) logs the same context shape; no worker runs
        # here, so emit it the way strategy.py does.
        context = {"id": "t1", "name": "tests.boom", "args": "()", "kwargs": repr({"payload": {"code": OTP}})}
        logging.getLogger("celery.worker.strategy").info(
            "Task %(name)s[%(id)s] received", context, extra={"data": context}
        )
    records = [r for r in caplog.records if r.name in ("celery.app.trace", "celery.worker.strategy")]
    assert {r.name for r in records} == {"celery.app.trace", "celery.worker.strategy"}
    assert OTP not in caplog.text
    for record in records:
        assert record.data["kwargs"] == MASKED and record.data["args"] == MASKED  # type: ignore[attr-defined]


@pytest.mark.parametrize("sms_provider", [None, "console"])
def test_prod_refuses_missing_or_console_sms_provider(sms_provider: str | None) -> None:
    """ENV=prod does not start without a real SMS gateway (review B04-r1 P2-1).

    Args:
        sms_provider: the refused value.
    """
    from pydantic import ValidationError

    from agritrace.core.config import Settings

    secret = "x" * 32
    with pytest.raises(ValidationError, match="requires a real SMS_PROVIDER"):
        Settings(_env_file=None, env="prod", jwt_secret=secret, sms_provider=sms_provider)
    assert Settings(_env_file=None, env="dev", jwt_secret=secret, sms_provider=sms_provider)


def test_sms_provider_typo_fails_at_start_up() -> None:
    """A misspelt SMS_PROVIDER is a validation error, not a silent `provider_not_configured` (B04-r1 P3-1)."""
    from pydantic import ValidationError

    from agritrace.core.config import Settings

    with pytest.raises(ValidationError):
        Settings(_env_file=None, jwt_secret="x" * 32, sms_provider="Console")
