"""Integration tests of notifications on a real PostGIS database with Celery applied eagerly.

Covers the B04 acceptance literally ("eager send → row sent/console", "unknown template → row failed, no
raise"), the OTP path end to end (`POST /v1/auth/otp/request` → `notifications.send` → row with the code
redacted) and `GET /v1/notifications` (only the caller's rows, newest first, cursor pages).

Serves: B04 acceptance (docs/agents/acceptance/B04.md), FR7, FR1, D-009, TODO B02 kwargs contract.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack`).
"""

import asyncio
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from pathlib import Path
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import NotificationStatus, OrgKind, Role
from agritrace.main import create_app
from agritrace.modules.identity.models import Membership, User
from agritrace.modules.notifications.models import Notification
from agritrace.modules.registry.models import Fpo

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head once per session.

    Args:
        stack: the running containers (fixture).

    Side effects:
        Runs `alembic upgrade head` (a no-op when another test module already did).
    """
    alembic = Path(sys.executable).parent / "alembic"
    subprocess.run([str(alembic), "upgrade", "head"], cwd=API_DIR, check=True)  # noqa: S603


@pytest.fixture
def eager(migrated: None, monkeypatch: pytest.MonkeyPatch) -> None:
    """Run tasks sent by name inline (eager `apply`) and use the console SMS provider.

    `task_always_eager` does not cover `send_task`, so `send_task` is replaced by the registered task's
    `apply`; identity calls it through `asyncio.to_thread`, where `run_db_task` may open its own loop.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: pytest's patcher.

    Side effects:
        Patches the Celery app's `send_task` and the settings' `sms_provider` / `otp_dev_code`.
    """
    import agritrace.modules.notifications.tasks  # noqa: F401  # registers notifications.send
    from agritrace.worker import app

    monkeypatch.setattr(app, "send_task", lambda name, kwargs=None, **_: app.tasks[name].apply(kwargs=kwargs))
    monkeypatch.setattr(get_settings(), "sms_provider", "console")
    monkeypatch.setattr(get_settings(), "otp_dev_code", None)


async def _seed_user() -> dict[str, Any]:
    """Create an FPO and a farmer user with a membership (so OTP requests find the account).

    Returns:
        `user`, `fpo`, `phone`.

    Side effects:
        Commits the rows.
    """
    phone = f"+9196{secrets.randbelow(10**8):08d}"
    async with get_sessionmaker()() as s:
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        user = User(phone=phone, name="Muthu", lang="ta")
        s.add_all([fpo, user])
        await s.flush()
        s.add(Membership(user_id=user.id, fpo_id=fpo.id, role=Role.FARMER))
        await s.commit()
        return {"user": user.id, "fpo": fpo.id, "phone": phone}


async def _send(user_id: uuid.UUID, template_key: str, channel: str = "console", **payload: Any) -> Any:
    """Apply `notifications.send` eagerly in a worker thread (as the worker would, without a running loop).

    Args:
        user_id: recipient.
        template_key: template.
        channel: channel name.
        **payload: template variables.

    Returns:
        The task's return value.
    """
    from agritrace.modules.notifications.tasks import send

    kwargs = {
        "user_id": str(user_id),
        "template_key": template_key,
        "channel": channel,
        "lang": "ta",
        "payload": payload,
    }
    return (await asyncio.to_thread(send.apply, kwargs=kwargs)).get()


async def _rows(user_id: uuid.UUID) -> list[Notification]:
    """Read a user's notification rows, oldest first.

    Args:
        user_id: the user.

    Returns:
        The rows.
    """
    async with get_sessionmaker()() as s:
        query = select(Notification).where(Notification.user_id == user_id).order_by(Notification.id)
        return list((await s.scalars(query)).all())


async def test_eager_send_writes_sent_console_row(eager: None) -> None:
    """Acceptance: eager send → row `sent/console`.

    Args:
        eager: eager task fixture.
    """
    seed = await _seed_user()
    assert await _send(seed["user"], "harvest_reminder", plot_name="North field") == "sent"
    [row] = await _rows(seed["user"])
    assert (row.status, row.provider_ref, row.lang) == (NotificationStatus.SENT, "console", "ta")
    assert row.sent_at is not None and row.payload == {"plot_name": "North field"}


async def test_unknown_template_fails_without_raising(eager: None) -> None:
    """Acceptance: unknown template → row `failed`, no raise.

    Args:
        eager: eager task fixture.
    """
    seed = await _seed_user()
    assert await _send(seed["user"], "no_such_template") == "failed"
    [row] = await _rows(seed["user"])
    assert (row.status, row.provider_ref) == (NotificationStatus.FAILED, "error:unknown_template")


async def test_otp_request_end_to_end_redacts_code(eager: None) -> None:
    """`POST /v1/auth/otp/request` enqueues `notifications.send`; the row is sent and stores no code.

    Args:
        eager: eager task fixture.
    """
    seed = await _seed_user()
    async with AsyncClient(transport=ASGITransport(app=create_app()), base_url="http://test") as api:
        r = await api.post("/v1/auth/otp/request", json={"phone": seed["phone"]})
    assert r.status_code == 204
    [row] = await _rows(seed["user"])
    assert (row.template_key, row.channel, row.status) == ("otp", "sms", NotificationStatus.SENT)
    assert row.payload == {"code": "***"}


@pytest.fixture
async def mine(eager: None) -> AsyncIterator[tuple[AsyncClient, dict[str, Any]]]:
    """A client whose caller is a freshly seeded farmer (auth dependency overridden).

    Args:
        eager: eager task fixture.

    Returns:
        An async iterator yielding `(client, seed)`.
    """
    seed = await _seed_user()
    app = create_app()

    async def caller() -> CurrentUser:
        """Stand-in for the token check.

        Returns:
            The seeded farmer.
        """
        return CurrentUser(user_id=seed["user"], fpo_id=seed["fpo"], role=Role.FARMER)

    app.dependency_overrides[get_current_user] = caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c, seed


async def test_list_my_notifications_newest_first_with_cursor(
    mine: tuple[AsyncClient, dict[str, Any]],
) -> None:
    """Only the caller's rows, newest first, two pages of two and one.

    Args:
        mine: client and seed.
    """
    api, seed = mine
    other = await _seed_user()
    for n in range(3):
        await _send(seed["user"], "grade_given", lot_code=f"L-{n}", grade="A")
    await _send(other["user"], "otp", code="111111")
    first = (await api.get("/v1/notifications", params={"limit": 2})).json()
    assert [i["payload"]["lot_code"] for i in first["items"]] == ["L-2", "L-1"] and first["has_more"]
    second = (await api.get("/v1/notifications", params={"limit": 2, "cursor": first["next_cursor"]})).json()
    assert [i["payload"]["lot_code"] for i in second["items"]] == ["L-0"]
    assert second["has_more"] is False and second["next_cursor"] is None


async def test_list_requires_sign_in(migrated: None) -> None:
    """Without a token the route answers 401 `unauthorized`.

    Args:
        migrated: the migrated database (fixture).
    """
    async with AsyncClient(transport=ASGITransport(app=create_app()), base_url="http://test") as api:
        r = await api.get("/v1/notifications")
    assert r.status_code == 401 and r.json()["error"]["code"] == "unauthorized"
