"""Unit tests of the sync push envelope limits: more than 50 entries → 422, more than 256 KB → 413.

Serves: B06 acceptance "51 entries → 422", plan §13 A4 (≤ 50 entries or 256 KB), TODO B06 (413
`payload_too_large`).
Callers: pytest (`make test-unit`); no Docker: auth and session dependencies are overridden and neither
request reaches the database.
"""

import uuid
from collections.abc import AsyncIterator
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import Role


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    """An in-process client whose caller is a farmer and whose session is never opened.

    Returns:
        An async iterator yielding the client.
    """
    from agritrace.main import create_app

    app = create_app()
    caller = CurrentUser(user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=Role.FARMER, device_id=uuid.uuid4())
    app.dependency_overrides[get_current_user] = lambda: caller

    async def no_session() -> AsyncIterator[None]:
        """Stand in for the database session (unused by these requests).

        Returns:
            An async iterator yielding None.
        """
        yield None

    app.dependency_overrides[get_session] = no_session
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


def envelope(entries: list[dict[str, Any]]) -> dict[str, Any]:
    """Build a push envelope.

    Args:
        entries: the entries.

    Returns:
        The request body.
    """
    return {
        "device_id": str(uuid.uuid4()),
        "app_version": "1.0.3",
        "device_time": "2026-03-04T08:12:10+05:30",
        "entries": entries,
    }


def entry(data: dict[str, Any] | None = None) -> dict[str, Any]:
    """Build one entry.

    Args:
        data: the entry data.

    Returns:
        The entry.
    """
    return {"client_id": str(uuid.uuid4()), "kind": "event_version", "data": data or {}}


async def test_fifty_one_entries_is_a_validation_error(client: AsyncClient) -> None:
    """51 entries → 422 `validation_error` naming the entries list.

    Args:
        client: the HTTP client (fixture).
    """
    response = await client.post("/v1/sync/push", json=envelope([entry() for _ in range(51)]))
    assert response.status_code == 422
    body = response.json()["error"]
    assert body["code"] == "validation_error"
    assert any("entries" in d["loc"] for d in body["details"])


async def test_body_over_256_kb_is_payload_too_large(client: AsyncClient) -> None:
    """A body over 256 KB → 413 `payload_too_large` with the limits in details, even with few entries.

    Args:
        client: the HTTP client (fixture).
    """
    big = entry({"payload": {"description": "x" * (260 * 1024)}})
    response = await client.post("/v1/sync/push", json=envelope([big]))
    assert response.status_code == 413
    error = response.json()["error"]
    assert error["code"] == "payload_too_large"
    assert error["details"] == {"max_bytes": 256 * 1024, "max_entries": 50}
