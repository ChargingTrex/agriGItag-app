"""Unit tests for `/v1/healthz` with stubbed dependency probes: GET body, HEAD probe, independent failure.

Serves: B00 acceptance (healthz), plan §13 A1 (HEAD reachability probe for the mobile sync engine).
Callers: pytest (`make test-unit`); no Docker needed.
"""

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace import main


async def _ok() -> None:
    """Probe stub that succeeds."""


async def _down() -> None:
    """Probe stub that fails.

    Raises:
        ConnectionError: always.
    """
    raise ConnectionError("connection refused")


async def _call(method: str) -> tuple[int, dict[str, str] | None]:
    """Call `/v1/healthz` on a fresh app.

    Args:
        method: HTTP method, `GET` or `HEAD`.

    Returns:
        Status code and the JSON body (None for HEAD, which has no body).
    """
    async with AsyncClient(transport=ASGITransport(app=main.create_app()), base_url="http://test") as c:
        r = await c.request(method, "/v1/healthz")
    return r.status_code, (r.json() if method == "GET" else None)


@pytest.fixture
def all_ok(monkeypatch: pytest.MonkeyPatch) -> None:
    """Make all three probes succeed.

    Args:
        monkeypatch: pytest monkeypatch fixture.
    """
    for name in ("_ping_db", "_ping_redis", "_ping_s3"):
        monkeypatch.setattr(main, name, _ok)


async def test_get_and_head_ok(all_ok: None) -> None:
    """GET returns the three statuses; HEAD answers 200 for the reachability probe.

    Args:
        all_ok: probes stubbed to succeed (fixture).
    """
    assert await _call("GET") == (200, {"db": "ok", "redis": "ok", "s3": "ok"})
    assert (await _call("HEAD"))[0] == 200


async def test_one_failure_is_reported_alone(all_ok: None, monkeypatch: pytest.MonkeyPatch) -> None:
    """A failing Redis probe marks only `redis` as an error and turns GET and HEAD into 503.

    Args:
        all_ok: probes stubbed to succeed (fixture).
        monkeypatch: pytest monkeypatch fixture.
    """
    monkeypatch.setattr(main, "_ping_redis", _down)
    assert await _call("GET") == (503, {"db": "ok", "redis": "error: connection refused", "s3": "ok"})
    assert (await _call("HEAD"))[0] == 503
