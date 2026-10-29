"""Unit tests for the error registry and the error envelope.

Serves: CLAUDE.md §5.5 (registered codes), plan §7.1 (envelope shape and statuses).
Callers: pytest (`make test-unit`).
"""

import re

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from agritrace.core.errors import REGISTRY, AppError, GateNotMetError, install_handlers

REQUIRED = {
    "validation_error": 422,
    "not_found": 404,
    "forbidden": 403,
    "unauthorized": 401,
    "conflict": 409,
    "rate_limited": 429,
    "not_implemented_pilot": 501,
    "gate_not_met": 409,
    "append_only_violation": 409,
    "payload_too_large": 413,
}


def _client() -> AsyncClient:
    """Build a tiny app with the envelope handlers and two routes.

    Returns:
        An in-process HTTP client for the app.
    """
    app = FastAPI()
    install_handlers(app)

    @app.get("/gate")
    def gate() -> None:
        """Raise a gate error with details.

        Raises:
            GateNotMetError: always.
        """
        raise GateNotMetError(details={"open_flags": 2})

    @app.get("/num/{n}")
    def num(n: int) -> int:
        """Echo an integer path parameter.

        Args:
            n: the integer.

        Returns:
            `n`.
        """
        return n

    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test")


def test_required_codes_registered_with_status() -> None:
    """Every code the plan names exists with its HTTP status and has message key and fix text."""
    for code, status in REQUIRED.items():
        assert REGISTRY[code].status == status
    for cls in REGISTRY.values():
        assert re.fullmatch(r"[a-z][a-z0-9_]*", cls.code)
        assert cls.message_key and cls.message and cls.fix


def test_duplicate_code_is_refused() -> None:
    """Defining a second class with an existing code fails and leaves the registry unchanged."""
    before = dict(REGISTRY)
    with pytest.raises(ValueError, match="already registered"):

        class Dup(AppError):
            """Duplicate of not_found."""

            code = "not_found"

    assert before == REGISTRY


async def test_app_error_envelope() -> None:
    """A raised AppError becomes {"error": {code, message, details}} with its status."""
    async with _client() as c:
        r = await c.get("/gate")
    assert r.status_code == 409
    assert r.json() == {
        "error": {"code": "gate_not_met", "message": GateNotMetError.message, "details": {"open_flags": 2}}
    }


async def test_validation_and_unknown_path_use_envelope() -> None:
    """FastAPI validation errors and unknown paths are wrapped in the same envelope."""
    async with _client() as c:
        bad = await c.get("/num/abc")
        missing = await c.get("/nope")
    assert bad.status_code == 422
    assert bad.json()["error"]["code"] == "validation_error"
    assert bad.json()["error"]["details"][0]["loc"] == ["path", "n"]
    assert missing.status_code == 404
    assert set(missing.json()["error"]) == {"code", "message", "details"}
    assert missing.json()["error"]["code"] == "not_found"


async def test_wrong_method_keeps_allow_header() -> None:
    """405 uses the envelope and keeps the `Allow` header (RFC 9110)."""
    async with _client() as c:
        r = await c.post("/num/1")
    assert r.status_code == 405
    assert r.json()["error"]["code"] == "method_not_allowed"
    assert r.headers["allow"] == "GET"
