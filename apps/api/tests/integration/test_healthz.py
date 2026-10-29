"""Integration test: `/v1/healthz` reports every dependency as ok against real containers.

Serves: B00 acceptance (`/healthz` `{db, redis, s3: ok}`).
Callers: pytest (`make test`); needs Docker.
"""

import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.integration


async def test_healthz_all_ok(client: AsyncClient) -> None:
    """All three checks pass when the containers are up.

    Args:
        client: HTTP client over the app (fixture).
    """
    r = await client.get("/v1/healthz")
    assert r.status_code == 200
    assert r.json() == {"db": "ok", "redis": "ok", "s3": "ok"}


async def test_healthz_reports_each_failure_independently(
    client: AsyncClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A broken Redis turns only `redis` into an error and the status into 503.

    Args:
        client: HTTP client over the app (fixture).
        monkeypatch: pytest monkeypatch fixture.
    """
    from agritrace.core.config import get_settings

    monkeypatch.setattr(get_settings(), "redis_url", "redis://127.0.0.1:1/0")
    r = await client.get("/v1/healthz")
    assert r.status_code == 503
    body = r.json()
    assert body["db"] == "ok" and body["s3"] == "ok"
    assert body["redis"].startswith("error: ")
