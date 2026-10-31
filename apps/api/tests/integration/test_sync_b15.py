"""Integration tests of B15 on PostGIS: offline farmers (`farmer` kind, D-031) and per-entry assist (D-032).

One test per B15 acceptance line about sync push and `POST /v1/farmers`. Real tokens are used (sign-in
helpers of test_identity.py), so `get_current_user` resolves `X-Assist-Session` and sets the audit context
exactly as in production.
Serves: B15 acceptance lines 5–12, D-031, D-032, CLAUDE.md §6 (assist mode recorded on every entry), FR41
(consent witness), FR69 (`entered_remotely`), UserFlows §Onboarding.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack`).
"""

import secrets
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any

import pytest
from geoalchemy2 import WKTElement
from httpx import AsyncClient
from sqlalchemy import func, select
from test_identity import _bearer, _officer_session, _otp, _seed, api, migrated  # noqa: F401 (fixtures)

from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import FarmerStatus, PinMethod, Role
from agritrace.core.ids import lot_code, uuid7
from agritrace.core.time import utcnow
from agritrace.modules.events.models import EventVersion
from agritrace.modules.identity.models import AssistSession, AuditLog, ConsentRecord, Membership, User
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.registry.models import Crop, Farmer, Plot

pytestmark = pytest.mark.integration

LAT, LON = 9.5598, 78.1335


@dataclass
class World:
    """An FPO with a signed-in field officer, two farmers with plot and lot, and a second officer."""

    headers: dict[str, str]
    session: dict[str, Any]
    fpo: uuid.UUID
    officer: uuid.UUID
    other_officer: uuid.UUID
    farmers: dict[str, uuid.UUID]
    plots: dict[str, uuid.UUID]
    lots: dict[str, uuid.UUID]


@pytest.fixture
async def world(api: AsyncClient) -> World:  # noqa: F811 (fixture parameter)
    """Seed the FPO and sign the officer in.

    Args:
        api: the client (fixture).

    Returns:
        The world.

    Side effects:
        Commits rows; signs a device in.
    """
    seed = await _seed(Role.FIELD_OFFICER)
    session = await _officer_session(api, seed)
    async with get_sessionmaker()() as s:
        other = User(phone=f"+9196{secrets.randbelow(10**8):08d}", name="Officer 2")
        crop = Crop(code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={})
        farmer_b = Farmer(fpo_id=seed["fpo"], code=f"F-{secrets.token_hex(3)}", name="Ravi")
        s.add_all([other, crop, farmer_b])
        await s.flush()
        s.add(Membership(user_id=other.id, fpo_id=seed["fpo"], role=Role.FIELD_OFFICER))
        farmers, plots, lots = {"A": seed["farmer"], "B": farmer_b.id}, {}, {}
        for name, farmer_id in farmers.items():
            plot = Plot(
                id=uuid7(),
                fpo_id=seed["fpo"],
                farmer_id=farmer_id,
                code="P-01",
                pin=WKTElement(f"POINT({LON} {LAT})", srid=4326),
                pin_method=PinMethod.LIVE_GPS,
                pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
                pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
                declared_area_acres=Decimal("1.5"),
            )
            s.add(plot)
            await s.flush()
            lot = Lot(
                fpo_id=seed["fpo"],
                farmer_id=farmer_id,
                plot_id=plot.id,
                crop_id=crop.id,
                season_label="2025-26",
                code=lot_code(),
            )
            s.add(lot)
            await s.flush()
            plots[name], lots[name] = plot.id, lot.id
        await s.commit()
    return World(_bearer(session), session, seed["fpo"], seed["user"], other.id, farmers, plots, lots)


def envelope(*entries: dict[str, Any]) -> dict[str, Any]:
    """Wrap entries in a push envelope.

    Args:
        *entries: the entries.

    Returns:
        The request body.
    """
    now = datetime.now(UTC).isoformat()
    return {
        "device_id": str(uuid.uuid4()),
        "app_version": "1.0.3",
        "device_time": now,
        "entries": list(entries),
    }


def farmer_entry(farmer_id: uuid.UUID, phone: str | None = None) -> dict[str, Any]:
    """Build a `farmer` entry.

    Args:
        farmer_id: the phone's farmer id.
        phone: the farmer's phone, if any.

    Returns:
        The entry.
    """
    data = {"name": "Muthu", "phone": phone or f"+9195{secrets.randbelow(10**8):08d}"}
    return {"client_id": str(farmer_id), "kind": "farmer", "data": data}


def session_entry(session_id: uuid.UUID, farmer_id: uuid.UUID) -> dict[str, Any]:
    """Build an `assist_session` entry.

    Args:
        session_id: the phone's session id.
        farmer_id: the assisted farmer.

    Returns:
        The entry.
    """
    data = {"farmer_id": str(farmer_id), "started_at": "2026-03-04T08:00:00+05:30", "started_gps": None}
    return {"client_id": str(session_id), "kind": "assist_session", "data": data}


def consent_entry(farmer_id: uuid.UUID, session_id: uuid.UUID | None = None) -> dict[str, Any]:
    """Build a `consent` entry.

    Args:
        farmer_id: the farmer.
        session_id: its `assist_session_id`, if any.

    Returns:
        The entry.
    """
    data = {
        "farmer_id": str(farmer_id),
        "consent_type": "data_collection",
        "consent_version": "v1-ta",
        "given_at": "2026-03-04T08:12:10+05:30",
    }
    return {
        "client_id": str(uuid7()),
        "kind": "consent",
        "data": data,
        "assist_session_id": session_id and str(session_id),
    }


def plot_entry(farmer_id: uuid.UUID, session_id: uuid.UUID | None = None) -> dict[str, Any]:
    """Build a `plot` entry.

    Args:
        farmer_id: the farmer.
        session_id: its `assist_session_id`, if any.

    Returns:
        The entry.
    """
    data = {
        "farmer_id": str(farmer_id),
        "pin": {"lat": LAT, "lon": LON, "accuracy_m": 5},
        "pin_method": "live_gps",
        "device_time": "2026-03-04T08:20:00+05:30",
        "declared_area": {"value": 1.5, "unit": "acre"},
    }
    return {
        "client_id": str(uuid7()),
        "kind": "plot",
        "data": data,
        "assist_session_id": session_id and str(session_id),
    }


def event_entry(w: World, name: str, session_id: uuid.UUID, *, lat: float = LAT) -> dict[str, Any]:
    """Build an `event_version` entry (harvest, version 1) on farmer `name`'s lot.

    Args:
        w: the world.
        name: `A` or `B`.
        session_id: its `assist_session_id`.
        lat: latitude of the GPS fix (far from the pin → entered remotely).

    Returns:
        The entry.
    """
    data = {
        "event_id": str(uuid7()),
        "version_no": 1,
        "subject_type": "lot",
        "lot_id": str(w.lots[name]),
        "plot_id": str(w.plots[name]),
        "event_type": "harvest",
        "instance_no": 1,
        "occurred_on": "2026-03-04",
        "payload": {"quantity": {"value": 195, "unit": "kg"}, "bags": 13},
        "clocks": {"device_time": datetime.now(UTC).isoformat()},
        "gps": {"lat": lat, "lon": LON, "accuracy_m": 6.2},
    }
    return {
        "client_id": str(uuid7()),
        "kind": "event_version",
        "data": data,
        "assist_session_id": str(session_id),
    }


async def push(api: AsyncClient, headers: dict[str, str], *entries: dict[str, Any]) -> list[dict[str, Any]]:  # noqa: F811
    """Push entries and return the per-entry results.

    Args:
        api: the client.
        headers: request headers (Bearer, optional `X-Assist-Session`).
        *entries: the entries.

    Returns:
        The results.
    """
    r = await api.post("/v1/sync/push", json=envelope(*entries), headers=headers)
    assert r.status_code == 200, r.text
    results: list[dict[str, Any]] = r.json()["results"]
    return results


async def count(model: Any, *where: Any) -> int:
    """Count rows.

    Args:
        model: the mapped class.
        *where: filters.

    Returns:
        The number of matching rows.
    """
    async with get_sessionmaker()() as s:
        return int(await s.scalar(select(func.count()).select_from(model).where(*where)) or 0)


async def audit_row(entity_type: str, entity_id: uuid.UUID) -> AuditLog:
    """Load the single `create` audit row of an entity.

    Args:
        entity_type: table name.
        entity_id: row id.

    Returns:
        The audit row.
    """
    async with get_sessionmaker()() as s:
        query = select(AuditLog).where(
            AuditLog.entity_type == entity_type, AuditLog.entity_id == entity_id, AuditLog.action == "create"
        )
        [row] = (await s.scalars(query)).all()
        return row


async def test_offline_farmer_then_consent_and_plot(api: AsyncClient, world: World) -> None:  # noqa: F811
    """`[farmer F, consent(F), plot(F)]` by an officer, then the same push again.

    The farmer and plot are accepted, then duplicates, with one `farmers`, `users` and `memberships` row.
    The consent without an assist session stays `forbidden`: `_check_writer` is unchanged by ruling §4
    (D-032), so an officer's consent needs `assist_session_id` (see the next-but-two test).

    Args:
        api: the client.
        world: the seeded FPO.
    """
    f = uuid7()
    phone = f"+9195{secrets.randbelow(10**8):08d}"
    entries = (farmer_entry(f, phone), consent_entry(f), plot_entry(f))
    first = await push(api, world.headers, *entries)
    assert [r["status"] for r in first] == ["accepted", "rejected", "accepted"]
    assert first[1]["error"]["code"] == "forbidden"
    again = await push(api, world.headers, *entries)
    assert [r["status"] for r in again] == ["duplicate", "rejected", "duplicate"]
    async with get_sessionmaker()() as s:
        farmer = await s.get(Farmer, f)
        assert farmer is not None and farmer.status == FarmerStatus.PENDING and farmer.fpo_id == world.fpo
        user_id = await s.scalar(select(User.id).where(User.phone == phone))
    assert await count(User, User.phone == phone) == 1
    assert await count(Membership, Membership.user_id == user_id, Membership.fpo_id == world.fpo) == 1


async def test_rest_farmer_client_id_then_push_and_other_fpo(api: AsyncClient, world: World) -> None:  # noqa: F811
    """`POST /v1/farmers` with `client_id` F, then `kind=farmer` F → `duplicate`; another FPO → conflict.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    f = uuid7()
    entry = farmer_entry(f)
    created = await api.post("/v1/farmers", json=entry["data"] | {"client_id": str(f)}, headers=world.headers)
    assert created.status_code == 201 and created.json()["id"] == str(f)
    [result] = await push(api, world.headers, entry)
    assert result["status"] == "duplicate"  # not farmer_phone_taken
    other = await _officer_session(api, await _seed(Role.FIELD_OFFICER))  # a new FPO
    [foreign] = await push(api, _bearer(other), entry)
    assert (foreign["status"], foreign["error"]["code"]) == ("rejected", "client_id_conflict")
    rest = await api.post("/v1/farmers", json=entry["data"] | {"client_id": str(f)}, headers=_bearer(other))
    assert (rest.status_code, rest.json()["error"]["code"]) == (409, "client_id_conflict")


async def test_farmer_kind_by_farmer_and_taken_phone(api: AsyncClient, world: World) -> None:  # noqa: F811
    """Farmer token → `forbidden`; another FPO farmer's phone → `farmer_phone_taken`, its plot rejected.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    farmer_seed = await _seed(Role.FARMER)
    farmer_session = await _otp(api, farmer_seed["phone"])
    [denied] = await push(api, _bearer(farmer_session), farmer_entry(uuid7()))
    assert (denied["status"], denied["error"]["code"]) == ("rejected", "forbidden")
    phone = f"+9195{secrets.randbelow(10**8):08d}"
    [ok] = await push(api, world.headers, farmer_entry(uuid7(), phone))
    assert ok["status"] == "accepted"
    f = uuid7()
    taken, plot = await push(api, world.headers, farmer_entry(f, phone), plot_entry(f))
    assert (taken["status"], taken["error"]["code"]) == ("rejected", "farmer_phone_taken")
    assert plot["status"] == "rejected"


async def test_offline_onboarding_with_assist_session(api: AsyncClient, world: World) -> None:  # noqa: F811
    """`[farmer F, assist_session S(F), consent(F, S), plot(F, S)]` → 4 accepted, witness and audit; replay.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    f, s_id = uuid7(), uuid7()
    entries = (farmer_entry(f), session_entry(s_id, f), consent_entry(f, s_id), plot_entry(f, s_id))
    first = await push(api, world.headers, *entries)
    assert [r["status"] for r in first] == ["accepted"] * 4
    async with get_sessionmaker()() as s:
        consent = await s.get(ConsentRecord, uuid.UUID(entries[2]["client_id"]))
        assert consent is not None and consent.witnessed_by_user_id == world.officer
    for entity, entry in (("consent_records", entries[2]), ("plots", entries[3])):
        row = await audit_row(entity, uuid.UUID(entry["client_id"]))
        assert (row.assist_session_id, row.on_behalf_of_farmer_id, row.actor_user_id) == (
            s_id,
            f,
            world.officer,
        )
    farmer_row = await audit_row("farmers", f)
    assert (farmer_row.assist_session_id, farmer_row.on_behalf_of_farmer_id) == (None, None)
    again = await push(api, world.headers, *entries)
    assert [r["status"] for r in again] == ["duplicate"] * 4


async def test_one_push_two_assisted_farmers(api: AsyncClient, world: World) -> None:  # noqa: F811
    """Events for farmers A and B under S1 and S2 keep their own assist fields; off-plot GPS is remote (FR69).

    Args:
        api: the client.
        world: the seeded FPO.
    """
    s1, s2 = uuid7(), uuid7()
    a, b = event_entry(world, "A", s1, lat=LAT + 0.05), event_entry(world, "B", s2)
    results = await push(
        api, world.headers, session_entry(s1, world.farmers["A"]), session_entry(s2, world.farmers["B"]), a, b
    )
    assert [r["status"] for r in results] == ["accepted"] * 4
    async with get_sessionmaker()() as s:
        va = await s.get(EventVersion, uuid.UUID(a["client_id"]))
        vb = await s.get(EventVersion, uuid.UUID(b["client_id"]))
    assert va is not None and vb is not None
    assert (va.assist_session_id, va.on_behalf_of_farmer_id, va.entered_remotely) == (
        s1,
        world.farmers["A"],
        True,
    )
    assert (vb.assist_session_id, vb.on_behalf_of_farmer_id, vb.entered_remotely) == (
        s2,
        world.farmers["B"],
        False,
    )


async def test_invalid_or_mismatched_session(api: AsyncClient, world: World) -> None:  # noqa: F811
    """Unknown / another officer's session → `assist_session_invalid`, next entry runs; A's on B → forbidden.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    theirs = uuid7()
    async with get_sessionmaker()() as s:
        s.add(
            AssistSession(
                id=theirs,
                officer_user_id=world.other_officer,
                farmer_id=world.farmers["A"],
                started_at=utcnow(),
            )
        )
        await s.commit()
    s_a = uuid7()
    results = await push(
        api,
        world.headers,
        consent_entry(world.farmers["A"], uuid7()),
        consent_entry(world.farmers["A"], theirs),
        session_entry(s_a, world.farmers["A"]),
        consent_entry(world.farmers["B"], s_a),
        plot_entry(world.farmers["B"], s_a),
        event_entry(world, "B", s_a),
    )
    codes = [r["error"]["code"] if r["status"] == "rejected" else r["status"] for r in results]
    assert codes == [
        "assist_session_invalid",
        "assist_session_invalid",
        "accepted",
        "forbidden",
        "forbidden",
        "forbidden",
    ]


async def test_ended_session_per_entry_but_not_in_header(api: AsyncClient, world: World) -> None:  # noqa: F811
    """An entry with an ended S is accepted with assist recorded; the header with the same S → 403.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    s_id = uuid7()
    started = await api.post(
        "/v1/assist/start",
        json={"client_id": str(s_id), "farmer_id": str(world.farmers["A"])},
        headers=world.headers,
    )
    assert started.status_code == 201, started.text
    ended = await api.post("/v1/assist/end", json={"assist_session_id": str(s_id)}, headers=world.headers)
    assert ended.status_code == 200, ended.text
    entry = consent_entry(world.farmers["A"], s_id)
    [result] = await push(api, world.headers, entry)
    assert result["status"] == "accepted"
    row = await audit_row("consent_records", uuid.UUID(entry["client_id"]))
    assert (row.assist_session_id, row.on_behalf_of_farmer_id) == (s_id, world.farmers["A"])
    header = await api.post(
        "/v1/sync/push",
        json=envelope(plot_entry(world.farmers["A"])),
        headers=world.headers | {"X-Assist-Session": str(s_id)},
    )
    assert (header.status_code, header.json()["error"]["code"]) == (403, "assist_session_invalid")


async def test_assist_session_kind_conflict_and_farmer_token(api: AsyncClient, world: World) -> None:  # noqa: F811
    """An `assist_session` id used by another officer → `conflict`; by a farmer token → `forbidden`.

    Args:
        api: the client.
        world: the seeded FPO.
    """
    theirs = uuid7()
    async with get_sessionmaker()() as s:
        s.add(
            AssistSession(
                id=theirs,
                officer_user_id=world.other_officer,
                farmer_id=world.farmers["A"],
                started_at=utcnow(),
            )
        )
        await s.commit()
    [conflict] = await push(api, world.headers, session_entry(theirs, world.farmers["A"]))
    assert (conflict["status"], conflict["error"]["code"]) == ("rejected", "conflict")
    farmer_session = await _otp(api, (await _seed(Role.FARMER))["phone"])
    [denied] = await push(api, _bearer(farmer_session), session_entry(uuid7(), world.farmers["A"]))
    assert (denied["status"], denied["error"]["code"]) == ("rejected", "forbidden")
