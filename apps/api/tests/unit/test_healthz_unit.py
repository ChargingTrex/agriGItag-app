"""Unit tests for `/v1/healthz` with stubbed dependency probes: GET body, cheap HEAD, independent failure.

Serves: B00 acceptance (healthz), plan §13 A1 (HEAD reachability probe for the mobile sync engine).
Callers: pytest (`make test-unit`); no Docker needed.
"""

import logging

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace import main

CALLS: list[str] = []


async def _ok() -> None:
    """Probe stub that succeeds.

    Side effects:
        Records the call in `CALLS`.
    """
    CALLS.append("ok")


async def _down() -> None:
    """Probe stub that fails with a message containing internal details.

    Raises:
        ConnectionError: always.
    """
    raise ConnectionError('role "agritrace" does not exist at db.internal:5432')


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
    """Make all three probes succeed and reset the call log.

    Args:
        monkeypatch: pytest monkeypatch fixture.
    """
    CALLS.clear()
    for name in ("_ping_db", "_ping_redis", "_ping_s3"):
        monkeypatch.setattr(main, name, _ok)


async def test_get_runs_all_probes(all_ok: None) -> None:
    """GET runs the three probes and returns their statuses.

    Args:
        all_ok: probes stubbed to succeed (fixture).
    """
    assert await _call("GET") == (200, {"db": "ok", "redis": "ok", "s3": "ok"})
    assert len(CALLS) == 3


async def test_head_is_cheap_and_ignores_dependencies(all_ok: None, monkeypatch: pytest.MonkeyPatch) -> None:
    """HEAD answers 200 without running any probe, even when a dependency is down.

    Args:
        all_ok: probes stubbed to succeed (fixture).
        monkeypatch: pytest monkeypatch fixture.
    """
    monkeypatch.setattr(main, "_ping_s3", _down)
    assert (await _call("HEAD"))[0] == 200
    assert CALLS == []


async def test_failure_shows_class_name_only(
    all_ok: None, monkeypatch: pytest.MonkeyPatch, caplog: pytest.LogCaptureFixture
) -> None:
    """A failing probe gives 503 and `error: <ExceptionClass>`; the details go to the log only.

    Args:
        all_ok: probes stubbed to succeed (fixture).
        monkeypatch: pytest monkeypatch fixture.
        caplog: pytest log capture fixture.
    """
    monkeypatch.setattr(main, "_ping_redis", _down)
    with caplog.at_level(logging.WARNING, logger="agritrace.main"):
        status, body = await _call("GET")
    assert (status, body) == (503, {"db": "ok", "redis": "error: ConnectionError", "s3": "ok"})
    assert "db.internal:5432" in caplog.text
