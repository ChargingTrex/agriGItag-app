"""End-to-end test of the PRD §12 reference batch: seed, flags, refused gates, fixes, publish, public page.

Runs the demo seed (`agritrace.seed.demo`) on PostGIS, then drives the API as the seeded admin, field
officer and QC officer: the exact flag set (D-030), grade "A" → 422, approve → 409, publish → 409 with its
reasons; then the documented fixes (log the missing chemical input and a pest event on each lot, register
a moisture meter, re-grade with a reading, approve, pack) and a publish that builds the page with GI verified,
shares 31.250/62.500/6.250 and a unit on every quantity.

Serves: B12 acceptance (all lines), backend-design §5, PRD §12.2, FR11, FR29, FR48–FR49, FR56, FR58, FR60,
FR62, D-048. Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`).
"""

import asyncio
import json
import uuid
from collections import Counter
from collections.abc import AsyncIterator, Iterator
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import func, select

from agritrace.core import storage
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import Role
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.identity.models import AuditLog, ConsentRecord, Membership, User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot, LotIntake
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.registry.models import (
    Crop,
    Farmer,
    Fpo,
    GiRegionVersion,
    GiTag,
    InputMaster,
    Plot,
    Processor,
)
from agritrace.modules.rules_flags.models import Flag
from agritrace.seed import demo

pytestmark = pytest.mark.integration

TABLES = (
    Fpo, Processor, User, Membership, Farmer, ConsentRecord, Plot, GiTag, GiRegionVersion, Crop, InputMaster,
    Lot, LotIntake, Event, EventVersion, Batch, BatchShare, Flag, AuditLog,
)  # fmt: skip
FIXED_CODES = {"practice_tag_contradiction", "ipm_without_pest_event"}


@dataclass
class Demo:
    """The seeded ids the test needs, the caller the API sees and the Celery messages sent."""

    fpo: uuid.UUID
    staff: dict[Role, uuid.UUID]
    lots: dict[str, uuid.UUID]
    caller: CurrentUser | None = None
    sent: list[tuple[str, dict[str, Any]]] = field(default_factory=list)

    def act_as(self, role: Role) -> None:
        """Switch the caller to the seeded staff member with this role.

        Args:
            role: fpo_admin, field_officer or qc_officer.

        Side effects:
            Replaces `caller`.
        """
        self.caller = CurrentUser(user_id=self.staff[role], fpo_id=self.fpo, role=role)


async def _seed() -> bool:
    """Run the demo seed once in its own session.

    Returns:
        What `demo.seed` returned (True when it wrote).
    """
    async with get_sessionmaker()() as s:
        return await demo.seed(s)


async def _counts() -> dict[str, int]:
    """Count the rows of every table the seed writes to.

    Returns:
        Row count by table name.
    """
    async with get_sessionmaker()() as s:
        return {t.__tablename__: await s.scalar(select(func.count()).select_from(t)) or 0 for t in TABLES}


@pytest.fixture
async def api(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[Demo, AsyncClient]]:
    """Seed the demo data (if needed) and give an HTTP client acting as one of its staff.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: replaces the Celery app's `send_task` with a recorder.

    Returns:
        An async iterator yielding the seeded ids and the client.

    Side effects:
        Seeds rows once per database; overrides `get_current_user` on a new app instance.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    await _seed()
    async with get_sessionmaker()() as s:
        fpo = await s.scalar(select(Fpo.id).where(Fpo.code == demo.FPO_CODE))
        assert fpo is not None
        rows = await s.execute(
            select(Membership.role, User.id)
            .join(User, User.id == Membership.user_id)
            .where(Membership.fpo_id == fpo)
        )
        staff = {role: user for role, user in rows.tuples() if role != Role.FARMER}
        lots = dict((await s.execute(select(Lot.code, Lot.id).where(Lot.fpo_id == fpo))).tuples().all())
    d = Demo(fpo=fpo, staff=staff, lots=lots)
    d.act_as(Role.FPO_ADMIN)
    monkeypatch.setattr(
        celery_app, "send_task", lambda name, kwargs=None, **_: d.sent.append((name, kwargs or {}))
    )
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: d.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield d, client


async def test_seed_is_idempotent(api: tuple[Demo, AsyncClient]) -> None:
    """A second run returns False and changes no row in any table it writes to (audit log included).

    Args:
        api: the seeded demo and client (fixture).
    """
    before = await _counts()
    assert await _seed() is False
    assert await _counts() == before


async def _flag_codes(client: AsyncClient) -> Counter[str]:
    """Count the FPO's active (open) flags by rule code.

    Args:
        client: the API client (acting as the admin).

    Returns:
        Rule code → number of open flags.
    """
    r = await client.get("/v1/flags", params={"status": "open", "limit": 200})
    assert r.status_code == 200, r.text
    assert r.json()["has_more"] is False
    return Counter(f["rule_code"] for f in r.json()["items"])


def _reasons(response: Any) -> set[str]:
    """Read the reason codes of a `gate_not_met` answer.

    Args:
        response: the httpx response.

    Returns:
        The `details.reasons[].code` values.
    """
    assert response.status_code == 409, response.text
    error = response.json()["error"]
    assert error["code"] == "gate_not_met"
    return {r["code"] for r in error["details"]["reasons"]}


def _entry(lot_id: uuid.UUID, event_type: str, on: str, payload: dict[str, Any]) -> dict[str, Any]:
    """Build a sync push `event_version` entry (version 1) on a lot.

    Args:
        lot_id: the lot.
        event_type: event type.
        on: ISO date it happened.
        payload: the payload.

    Returns:
        The entry.
    """
    data = {
        "event_id": str(uuid7()),
        "version_no": 1,
        "subject_type": "lot",
        "lot_id": str(lot_id),
        "event_type": event_type,
        "occurred_on": on,
        "payload": payload,
        "clocks": {"device_time": datetime.now(UTC).isoformat()},
    }
    return {"client_id": str(uuid7()), "kind": "event_version", "data": data}


def _quantities(node: Any) -> Iterator[dict[str, Any]]:
    """Yield every `{value, ...}` object in a JSON document.

    Args:
        node: the parsed JSON.

    Returns:
        An iterator over the quantity-shaped objects.
    """
    if isinstance(node, dict):
        if "value" in node:
            yield node
        for child in node.values():
            yield from _quantities(child)
    elif isinstance(node, list):
        for child in node:
            yield from _quantities(child)


async def _apply_fixes(d: Demo, client: AsyncClient, batch: str) -> None:
    """Fix the PRD §12.2 problems that hold the batch back, through the API.

    The farmers declared Inorganic, so the missing chemical input is logged (PRD §12.2: "either the tag is
    wrong or chemical inputs were not logged"; no route edits declared tags) and each lot gets the pest
    event its IPM claim needs. QC registers a moisture meter and grades "Standard" on a reading; the admin
    approves 20 kg and signs off 20 kg of packs.

    Args:
        d: the seeded demo.
        client: the API client.
        batch: the batch id.
    """
    body = {"name_en": "Demo NPK 17:17:17", "category": "chemical_fertilizer", "unit": "kg"}
    r = await client.post("/v1/inputs", json=body)
    assert r.status_code == 201, r.text
    npk = r.json()["id"]
    d.act_as(Role.FIELD_OFFICER)
    entries = []
    for lot in d.lots.values():
        entries += [
            _entry(
                lot,
                "input_application",
                "2025-12-08",
                {"input_id": npk, "quantity": {"value": 10, "unit": "kg"}},
            ),
            _entry(
                lot, "problem", "2026-01-10", {"problem_type": "pest", "description": "Thrips; neem spray"}
            ),
        ]
    envelope = {
        "device_id": str(uuid.uuid4()),
        "app_version": "1.0.0",
        "device_time": datetime.now(UTC).isoformat(),
        "entries": entries,
    }
    r = await client.post("/v1/sync/push", json=envelope)
    assert [x["status"] for x in r.json()["results"]] == ["accepted"] * len(entries), r.text

    d.act_as(Role.QC_OFFICER)
    meter = {
        "kind": "moisture_meter",
        "make_model": "Demo meter",
        "serial_no": "DM-1",
        "calibrated_on": "2026-01-01",
        "calibration_due_on": "2026-12-31",
    }
    r = await client.post("/v1/instruments", json=meter)
    assert r.status_code == 201, r.text
    reading = {
        "client_id": str(uuid7()),
        "stage": "grading",
        "parameter_code": "moisture",
        "measurement": {"value": "10.5", "unit": "%"},
        "source": "instrument",
        "instrument_id": r.json()["id"],
        "measured_at": "2026-07-30T09:00:00+05:30",
        "batch_id": batch,
    }
    r = await client.post(
        f"/v1/batches/{batch}/grading", json={"declared_grade": "Standard", "readings": [reading]}
    )
    assert r.status_code == 201, r.text

    d.act_as(Role.FPO_ADMIN)
    r = await client.post(
        f"/v1/batches/{batch}/grading/approve", json={"graded": {"value": 20, "unit": "kg"}}
    )
    assert r.status_code == 200, r.text
    packing = {
        "packed": {"value": 20, "unit": "kg"},
        "pack_date": "2026-07-30",
        "best_before_date": "2027-07-29",
    }
    r = await client.post(f"/v1/batches/{batch}/final-packing", json=packing)
    assert r.status_code == 200, r.text


async def test_reference_batch_flags_gates_fixes_and_publish(api: tuple[Demo, AsyncClient]) -> None:
    """Seeded state → exact flags and refused gates; after the fixes → published page, GI verified, shares.

    Args:
        api: the seeded demo and client (fixture).
    """
    d, client = api
    batch = str(demo.BATCH_ID)
    flags = await _flag_codes(client)
    assert flags == Counter(demo.EXPECTED_FLAGS)
    assert not set(demo.ABSENT_FLAGS) & set(flags)

    d.act_as(Role.QC_OFFICER)
    r = await client.post(f"/v1/batches/{batch}/grading", json={"declared_grade": "A"})
    assert r.status_code == 422 and r.json()["error"]["code"] == "unknown_grade_for_profile", r.text
    d.act_as(Role.FPO_ADMIN)
    graded = {"graded": {"value": 20, "unit": "kg"}}
    assert "not_graded" in _reasons(await client.post(f"/v1/batches/{batch}/grading/approve", json=graded))
    refused = _reasons(await client.post(f"/v1/batches/{batch}/publish"))
    assert {"grading_not_approved", "final_packing_missing"} <= refused

    await _apply_fixes(d, client, batch)
    r = await client.post(f"/v1/batches/{batch}/publish")
    assert r.status_code == 202, r.text
    name, kwargs = d.sent[-1]
    assert name == "publishing.build_page"
    from agritrace.modules.publishing import tasks  # late: importing the worker reads the settings

    assert await asyncio.to_thread(tasks.build_page, **kwargs) == "built"

    out = (await client.get(f"/v1/batches/{batch}")).json()
    assert (out["code"], out["superlot_code"], out["status"]) == (
        demo.BATCH_CODE,
        demo.SUPERLOT_CODE,
        "published",
    )
    assert out["gi_verified"] is True and out["gi_block_reasons"] == []
    by_lot = {s["lot_id"]: s for s in out["shares"]}
    assert {code: by_lot[str(i)]["share_pct"] for code, i in d.lots.items()} == {
        "LOTD02DADB6": "31.250",
        "LOT3072CB6A": "62.500",
        "LOT0EF81415": "6.250",
    }
    assert all(s["contributed"]["unit"] == "kg" for s in out["shares"])
    assert [out[k]["unit"] for k in ("total_received", "graded", "packed")] == ["kg"] * 3
    # Warns never block publish; the fixed problems are closed, the rest stay visible to the admin.
    flags = await _flag_codes(client)
    assert not FIXED_CODES & set(flags)
    assert flags["quantity_mismatch"] == 3 and flags["grading_loss_high"] == 1

    async with get_sessionmaker()() as s:
        build = await s.scalar(select(PageBuild).where(PageBuild.batch_id == demo.BATCH_ID))
    assert build is not None and build.status == "built"
    bucket, prefix = get_settings().s3_bucket_public, f"batches/{demo.BATCH_CODE}"
    for key in ("index.html", "qr.png"):
        assert storage.client().head_object(Bucket=bucket, Key=f"{prefix}/{key}")
    page = json.loads(storage.client().get_object(Bucket=bucket, Key=f"{prefix}/data.json")["Body"].read())
    assert page["gi_verified"] is True and page["procured_quantity"] == {"value": 320.0, "unit": "kg"}
    lots = {lot["lot_code"]: lot for lot in page["lots"]}
    assert {c: lot["share_pct"] for c, lot in lots.items()} == {
        "LOTD02DADB6": 31.25,
        "LOT3072CB6A": 62.5,
        "LOT0EF81415": 6.25,
    }
    assert lots["LOTD02DADB6"]["farmer_name"] == "muthu murugan"
    assert all(q.get("unit") for q in _quantities(page)), "a quantity on the page has no unit (FR58)"
