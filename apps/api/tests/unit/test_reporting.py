"""Unit tests of the reporting module's pure parts and of the routes that need no database.

Covers B11 acceptance "100 scans/min → 429" (route + fixed-window limiter on a stand-in Valkey) and
"partner → 501" (plus storage monitoring), the dashboard's FPO and role scope, percentages with units
(FR58), the CSV quantity/unit pick and formula-injection guard (TODO B13 review), and the shape of the
completeness SQL (D-037). Integration tests on PostGIS: tests/integration/test_reporting.py.
Serves: FR13, FR20, FR21, FR58, D-037, D-038. Callers: pytest (`make test-unit`).
"""

import uuid
from collections.abc import AsyncIterator
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.dialects import postgresql

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.core.errors import RateLimitedError
from agritrace.main import create_app
from agritrace.modules.reporting import service


class FakeValkey:
    """Stand-in for the Valkey client: an in-memory counter per key."""

    def __init__(self) -> None:
        """Start with no keys."""
        self.counts: dict[str, int] = {}
        self.ttl: dict[str, int] = {}

    async def incr(self, key: str) -> int:
        """Increment a counter.

        Args:
            key: the key.

        Returns:
            The new count.
        """
        self.counts[key] = self.counts.get(key, 0) + 1
        return self.counts[key]

    async def expire(self, key: str, seconds: int) -> None:
        """Record a key's time to live.

        Args:
            key: the key.
            seconds: time to live.
        """
        self.ttl[key] = seconds

    async def aclose(self) -> None:
        """Close the client (nothing to do)."""


class FakeSession:
    """Stand-in session that records added rows and commits."""

    def __init__(self) -> None:
        """Start empty."""
        self.added: list[Any] = []
        self.commits = 0

    def add(self, row: Any) -> None:
        """Record a row.

        Args:
            row: the ORM object.
        """
        self.added.append(row)

    async def commit(self) -> None:
        """Count a commit."""
        self.commits += 1


def test_percent_has_unit_and_one_decimal() -> None:
    """1 of 3 lots → 33.3 %; nothing to divide by → null (not 0 %)."""
    assert service.percent(1, 3) == service.Quantity(value=Decimal("33.3"), unit="%")
    assert service.percent(Decimal("1.5"), Decimal("1.5")).value == Decimal("100.0")  # type: ignore[union-attr]
    assert service.percent(0, 0) is None


def test_main_quantity_picks_the_payload_quantity() -> None:
    """Harvest `quantity`, intake `received`; a payload without a quantity gives empty cells."""
    assert service.main_quantity({"quantity": {"value": "100", "unit": "kg"}}) == ("100", "kg")
    assert service.main_quantity({"received": {"value": "95", "unit": "kg"}}) == ("95", "kg")
    final = {"pack_size": {"value": "1", "unit": "kg"}, "quantity": {"value": "25", "unit": "kg"}}
    assert service.main_quantity(final) == ("25", "kg")
    assert service.main_quantity({"note": "x"}) == (None, None)


def test_csv_cell_neutralises_formulas_and_writes_iso_dates() -> None:
    """`=`, `+`, `-`, `@` get a quote prefix; dates are ISO 8601; None is empty."""
    assert service.csv_cell("=HYPERLINK(1)") == "'=HYPERLINK(1)"
    assert service.csv_cell("@cmd") == "'@cmd"
    assert service.csv_cell("plain") == "plain"
    assert service.csv_cell(None) == ""
    assert service.csv_cell(date(2026, 2, 14)) == "2026-02-14"
    assert service.csv_cell(datetime(2026, 2, 14, 9, 30, tzinfo=UTC)) == "2026-02-14T09:30:00+00:00"


async def test_limiter_allows_100_per_window_then_429_and_resets() -> None:
    """Hits 1–100 pass, hit 101 raises `rate_limited` with the seconds left; the next minute starts afresh."""
    valkey = FakeValkey()
    now = 1_800_000_015.0  # 15 s into a window
    for _ in range(100):
        await service.limit_scans(valkey, "203.0.113.9", now)  # type: ignore[arg-type]
    with pytest.raises(RateLimitedError) as err:
        await service.limit_scans(valkey, "203.0.113.9", now)  # type: ignore[arg-type]
    assert err.value.details == {"retry_after_s": 45}
    await service.limit_scans(valkey, "198.51.100.1", now)  # type: ignore[arg-type]  # other address
    await service.limit_scans(valkey, "203.0.113.9", now + 60)  # type: ignore[arg-type]
    assert not any("203.0.113.9" in key for key in valkey.counts)  # only a hash of the IP reaches Valkey
    assert set(valkey.ttl.values()) == {60}


def test_completeness_sql_correlates_with_the_lot_and_its_crop() -> None:
    """The mandatory list comes from `crops.event_schema`, and `lots` / `crops` are not re-listed inside."""
    sql = str(service._scoped_lots(uuid.uuid4(), service.Filters()).compile(dialect=postgresql.dialect()))
    assert "jsonb_array_elements_text(crops.event_schema[" in sql
    assert sql.count("FROM lots") == 1
    assert "FROM events AS events_1 \nWHERE events_1.lot_id = lots.id" in sql  # nothing re-listed inside


@pytest.fixture
async def api(
    monkeypatch: pytest.MonkeyPatch,
) -> AsyncIterator[tuple[AsyncClient, FakeSession, dict[str, Any]]]:
    """An app with a stand-in session, a stand-in Valkey and a switchable caller.

    Args:
        monkeypatch: replaces `Redis.from_url` in the reporting service.

    Returns:
        An async iterator yielding the client, the session and a dict whose `user` is the caller.

    Side effects:
        Overrides `get_session` and `get_current_user` on a new app instance.
    """
    session, valkey, caller = FakeSession(), FakeValkey(), {"user": None}
    monkeypatch.setattr(service.Redis, "from_url", lambda *_a, **_k: valkey)
    monkeypatch.setattr(service, "get_settings", lambda: type("S", (), {"redis_url": "redis://fake"})())
    app = create_app()
    app.dependency_overrides[get_session] = lambda: session
    app.dependency_overrides[get_current_user] = lambda: caller["user"]
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client, session, caller


async def test_scans_101st_in_a_minute_is_429(
    api: tuple[AsyncClient, FakeSession, dict[str, Any]], monkeypatch: pytest.MonkeyPatch
) -> None:
    """B11 acceptance: 100 scans from one address in a minute → 204 each; the 101st → 429 `rate_limited`."""
    client, session, _ = api
    frozen = datetime(2026, 10, 31, 9, 30, 5, tzinfo=UTC)
    monkeypatch.setattr(service, "utcnow", lambda: frozen)
    for _ in range(100):
        assert (
            await client.post("/v1/public/scans", params={"batch_code": "fgp8t4033hm7"})
        ).status_code == 204
    over = await client.post("/v1/public/scans", params={"batch_code": "FGP8T4033HM7"})
    assert over.status_code == 429
    assert over.json()["error"]["code"] == "rate_limited"
    assert len(session.added) == 100 and session.commits == 100
    assert session.added[0].batch_code == "FGP8T4033HM7"  # normalised; no IP column exists to fill


async def test_scan_rejects_a_malformed_code(api: tuple[AsyncClient, FakeSession, dict[str, Any]]) -> None:
    """A code with a slash or over 32 characters → 422 before any write."""
    client, session, _ = api
    assert (await client.post("/v1/public/scans", params={"batch_code": "a/b"})).status_code == 422
    assert (await client.post("/v1/public/scans", params={"batch_code": "A" * 33})).status_code == 422
    assert session.added == []


@pytest.mark.parametrize(
    ("method", "path"),
    [
        ("GET", "/v1/partner/batches/FGP8T4033HM7"),
        ("POST", "/v1/partner/benefits"),
        ("POST", "/v1/probes"),
        ("POST", "/v1/probe-readings"),
    ],
)
async def test_stubs_answer_501(
    api: tuple[AsyncClient, FakeSession, dict[str, Any]], method: str, path: str
) -> None:
    """B11 acceptance: partner (and storage monitoring) routes → 501 `not_implemented_pilot`."""
    response = await api[0].request(method, path)
    assert response.status_code == 501
    assert response.json()["error"]["code"] == "not_implemented_pilot"


async def test_dashboard_is_scoped_to_the_callers_fpo_and_office_roles(
    api: tuple[AsyncClient, FakeSession, dict[str, Any]],
) -> None:
    """Another FPO's dashboard → 404; a farmer → 403; the audit log needs an FPO admin."""
    client, _, caller = api
    fpo = uuid.uuid4()
    caller["user"] = CurrentUser(user_id=uuid.uuid4(), fpo_id=fpo, role=Role.FPO_ADMIN)
    assert (await client.get(f"/v1/dashboard/fpo/{uuid.uuid4()}")).status_code == 404
    assert (await client.get(f"/v1/dashboard/fpo/{uuid.uuid4()}/farmers")).status_code == 404
    caller["user"] = CurrentUser(user_id=uuid.uuid4(), fpo_id=fpo, role=Role.FARMER)
    assert (await client.get(f"/v1/dashboard/fpo/{fpo}")).status_code == 403
    caller["user"] = CurrentUser(user_id=uuid.uuid4(), fpo_id=fpo, role=Role.VIEWER)
    assert (await client.get("/v1/audit-log")).status_code == 403
