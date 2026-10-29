"""Integration tests of the quality API on a real PostGIS database: readings, calibration, trail, grading.

Serves: B05 acceptance (moisture −1 → 422, expired instrument → 422, grading 12.0 after intake 10.0 → 422
without reason and 201 + `rules.check_lot` with reason, declared Special vs computed Standard →
`declared_above_computed`, grade "A" → `unknown_grade_for_profile`), D-005 (idempotent client id), FR47
(publishing an incomplete profile), FR42–FR50, Dataflow Stages 7 and 8.
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`). Auth is replaced by
a dependency override until identity (B02) issues real tokens; Celery's `send_task` is recorded, because
`task_always_eager` does not apply to tasks sent by name.
"""

import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient

from agritrace.core import task_names
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import InstrumentKind, OrgKind, PinMethod, Role
from agritrace.core.ids import batch_code, lot_code, uuid7
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot
from agritrace.modules.quality.models import Instrument
from agritrace.modules.quality.profiles.loader import load_profile
from agritrace.modules.registry.models import Crop, Farmer, Fpo, Plot, Processor

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
MEASURED = "2026-07-30T09:00:00+05:30"


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (a no-op when another test module already did).

    Args:
        stack: the running containers (fixture).

    Raises:
        AssertionError: alembic failed (its output is in the message).

    Side effects:
        Creates every table of migration 0001.
    """
    alembic = str(Path(sys.executable).parent / "alembic")
    cmd = [alembic, "upgrade", "head"]
    result = subprocess.run(cmd, cwd=API_DIR, capture_output=True, text=True, check=False)  # noqa: S603
    assert result.returncode == 0, result.stdout + result.stderr


@dataclass
class World:
    """Ids of one freshly seeded FPO and the caller the API sees."""

    fpo: uuid.UUID
    qc: uuid.UUID
    admin: uuid.UUID
    lot: uuid.UUID
    batch: uuid.UUID
    instrument: uuid.UUID
    expired_instrument: uuid.UUID
    crop: uuid.UUID
    caller: CurrentUser
    sent: list[tuple[str, dict[str, Any]]] = field(default_factory=list)

    def act_as(self, user_id: uuid.UUID, role: Role = Role.QC_OFFICER) -> None:
        """Switch the caller for the next requests.

        Args:
            user_id: the user to act as.
            role: their role in this FPO.

        Side effects:
            Replaces `caller`.
        """
        self.caller = CurrentUser(user_id=user_id, fpo_id=self.fpo, role=role)


async def _seed() -> dict[str, uuid.UUID]:
    """Insert an FPO with its people, a lot, a batch sharing it, two instruments and the chilli profile.

    People: a QC officer and a super-admin; the profile is loaded with the B12 seed loader.

    Returns:
        Ids by name.

    Side effects:
        Commits the rows to the test database.
    """
    async with get_sessionmaker()() as s:
        qc = User(phone=f"+9197{secrets.randbelow(10**8):08d}", name="QC")
        admin = User(phone=f"+9196{secrets.randbelow(10**8):08d}", name="Compliance", is_super_admin=True)
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        crop = Crop(code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={})
        s.add_all([qc, admin, fpo, crop])
        await s.flush()
        farmer = Farmer(fpo_id=fpo.id, code="F-001", name="Muthu")
        processor = Processor(fpo_id=fpo.id, name="Demo processor", kind=OrgKind.COMPANY)
        s.add_all([farmer, processor])
        await s.flush()
        plot = Plot(
            id=uuid7(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            code="P-01",
            pin=WKTElement("POINT(77.96 9.58)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
            pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
            declared_area_acres=Decimal("1.5"),
        )
        s.add(plot)
        await s.flush()
        lot = Lot(
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            plot_id=plot.id,
            crop_id=crop.id,
            season_label="2025-26",
            code=lot_code(),
        )
        batch = Batch(
            fpo_id=fpo.id, crop_id=crop.id, processor_id=processor.id, code=batch_code(), created_by=qc.id
        )
        ok = Instrument(
            fpo_id=fpo.id,
            kind=InstrumentKind.MOISTURE_METER,
            make_model="Meter A",
            serial_no="A-1",
            calibrated_on=date(2026, 1, 1),
            calibration_due_on=date(2026, 12, 31),
        )
        expired = Instrument(
            fpo_id=fpo.id,
            kind=InstrumentKind.MOISTURE_METER,
            make_model="Meter B",
            serial_no="B-1",
            calibrated_on=date(2025, 1, 1),
            calibration_due_on=date(2026, 1, 1),
        )
        s.add_all([lot, batch, ok, expired])
        await s.flush()
        s.add(
            BatchShare(
                batch_id=batch.id,
                lot_id=lot.id,
                kg_contributed=Decimal(100),
                share_pct=100,
                farmer_id=farmer.id,
            )
        )
        await s.commit()
        await load_profile(s, crop.id)
        return {
            "fpo": fpo.id,
            "qc": qc.id,
            "admin": admin.id,
            "lot": lot.id,
            "batch": batch.id,
            "instrument": ok.id,
            "expired_instrument": expired.id,
            "crop": crop.id,
        }


@pytest.fixture
async def world(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO and an HTTP client whose caller is that FPO's QC officer.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: replaces the Celery app's `send_task` with a recorder.

    Returns:
        An async iterator yielding the seeded world and the client.

    Side effects:
        Seeds rows; overrides `get_current_user` on a new app instance.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    ids = await _seed()
    w = World(
        fpo=ids["fpo"],
        qc=ids["qc"],
        admin=ids["admin"],
        lot=ids["lot"],
        batch=ids["batch"],
        instrument=ids["instrument"],
        expired_instrument=ids["expired_instrument"],
        crop=ids["crop"],
        caller=CurrentUser(user_id=ids["qc"], fpo_id=ids["fpo"], role=Role.QC_OFFICER),
    )
    celery_app.conf.task_always_eager = True
    monkeypatch.setattr(
        celery_app, "send_task", lambda name, kwargs=None, **_: w.sent.append((name, kwargs or {}))
    )
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client


def _reading(w: World, **over: Any) -> dict[str, Any]:
    """Build a valid instrument moisture reading on the world's lot at intake.

    Args:
        w: the seeded world.
        **over: fields to replace.

    Returns:
        The request body.
    """
    body: dict[str, Any] = {
        "client_id": str(uuid7()),
        "lot_id": str(w.lot),
        "stage": "intake",
        "parameter_code": "moisture",
        "measurement": {"value": "10.0", "unit": "%"},
        "source": "instrument",
        "instrument_id": str(w.instrument),
        "measured_at": MEASURED,
    }
    return {**body, **over}


@pytest.mark.parametrize(
    ("over", "code"),
    [
        ({"measurement": {"value": -1, "unit": "%"}}, "implausible_value"),
        ({"measurement": {"value": 101, "unit": "%"}}, "implausible_value"),
        ({"measurement": {"value": 9.8, "unit": "percent"}}, "unit_mismatch"),
        ({"parameter_code": "gluten"}, "unknown_parameter"),
        ({"source": "visual", "instrument_id": None}, "source_not_allowed"),
    ],
)
async def test_implausible_readings_are_rejected(
    world: tuple[World, AsyncClient], over: dict[str, Any], code: str
) -> None:
    """Each plausibility failure answers 422 with its own code and stores nothing (FR50).

    Args:
        world: seeded FPO and client (fixture).
        over: the field that makes the reading implausible.
        code: the expected error code.
    """
    w, client = world
    r = await client.post("/v1/quality-readings", json=_reading(w, **over))
    assert r.status_code == 422, r.text
    assert r.json()["error"]["code"] == code
    listed = await client.get(f"/v1/lots/{w.lot}/readings")
    assert listed.json()["items"] == []


async def test_expired_instrument_is_rejected_and_valid_one_recorded(
    world: tuple[World, AsyncClient],
) -> None:
    """A meter past its due date gives 422; a calibrated one stores its due date with the reading (FR50).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    r = await client.post("/v1/quality-readings", json=_reading(w, instrument_id=str(w.expired_instrument)))
    assert r.status_code == 422, r.text
    assert r.json()["error"]["code"] == "instrument_calibration_expired"
    r = await client.post("/v1/quality-readings", json=_reading(w))
    assert r.status_code == 201, r.text
    assert r.json()["calibration_due_on_at_time"] == "2026-12-31"
    assert r.json()["profile_version_id"] is not None


async def test_trail_rise_needs_a_reason_then_is_flagged(world: tuple[World, AsyncClient]) -> None:
    """Grading 12.0 after intake 10.0 on its lot: 422 without reason; 201 + rules.check_lot with one.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    assert (await client.post("/v1/quality-readings", json=_reading(w))).status_code == 201
    grading = _reading(
        w, lot_id=None, batch_id=str(w.batch), stage="grading", measurement={"value": 12.0, "unit": "%"}
    )
    r = await client.post("/v1/quality-readings", json=grading)
    assert r.status_code == 422, r.text
    assert r.json()["error"]["code"] == "moisture_trail_violation"
    assert w.sent == []

    r = await client.post("/v1/quality-readings", json={**grading, "reason_code": "rain_exposure"})
    assert r.status_code == 201, r.text
    assert r.json()["reason_code"] == "rain_exposure"
    assert w.sent == [
        (
            task_names.RULES_CHECK_LOT,
            {
                "lot_id": None,
                "batch_id": str(w.batch),
                "reading_id": grading["client_id"],
                "hint": "moisture_trail_override",
            },
        )
    ]


async def test_grading_declared_above_computed(world: tuple[World, AsyncClient]) -> None:
    """Declared Special with a 10.5 % reading → 201, computed Standard, status declared_above_computed (FR49).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    inline = _reading(
        w, lot_id=None, batch_id=str(w.batch), stage="grading", measurement={"value": 10.5, "unit": "%"}
    )
    r = await client.post(
        f"/v1/batches/{w.batch}/grading", json={"declared_grade": "Special", "readings": [inline]}
    )
    assert r.status_code == 201, r.text
    body = r.json()
    assert (body["computed_grade"], body["declared_grade"], body["status"]) == (
        "Standard",
        "Special",
        "declared_above_computed",
    )
    assert body["per_parameter"]["moisture"]["value"] == "10.5"
    assert body["per_parameter"]["extraneous_matter"]["outcome"] == "profile_incomplete"
    latest = await client.get(f"/v1/batches/{w.batch}/grade")
    assert latest.json()["id"] == body["id"]


async def test_grading_unknown_grade_and_incomplete(world: tuple[World, AsyncClient]) -> None:
    """Grade "A" → 422 unknown_grade_for_profile; no grading reading → status incomplete (FR48, PRD §12).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    r = await client.post(f"/v1/batches/{w.batch}/grading", json={"declared_grade": "A"})
    assert r.status_code == 422, r.text
    assert r.json()["error"]["code"] == "unknown_grade_for_profile"
    r = await client.post(f"/v1/batches/{w.batch}/grading", json={"declared_grade": "Standard"})
    assert r.status_code == 201, r.text
    assert (r.json()["status"], r.json()["computed_grade"]) == ("incomplete", None)


async def test_client_id_is_idempotent(world: tuple[World, AsyncClient]) -> None:
    """Resending a reading returns the stored one with 200; another user's resend is a 409 (D-005).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    body = _reading(w)
    first = await client.post("/v1/quality-readings", json=body)
    again = await client.post(
        "/v1/quality-readings", json={**body, "measurement": {"value": 9.0, "unit": "%"}}
    )
    assert (first.status_code, again.status_code) == (201, 200)
    assert again.json()["id"] == first.json()["id"] == body["client_id"]
    assert again.json()["measurement"] == first.json()["measurement"]  # the resent 9.0 is ignored
    assert again.json()["measured_at"] == first.json()["measured_at"]  # both read back from the database
    w.act_as(w.admin, Role.FPO_ADMIN)
    other = await client.post("/v1/quality-readings", json=body)
    assert other.status_code == 409
    assert other.json()["error"]["code"] == "client_id_conflict"


async def test_profile_versions_need_super_admin_and_allow_incomplete(
    world: tuple[World, AsyncClient],
) -> None:
    """The seed version carries the public note; republishing needs a super-admin and allow_incomplete (FR47).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    listed = await client.get("/v1/standards-profiles", params={"crop_id": str(w.crop)})
    profiles = listed.json()["items"]
    assert [p["published_version_no"] for p in profiles] == [1]
    pid = profiles[0]["id"]
    v1 = (await client.get(f"/v1/standards-profiles/{pid}/versions/1")).json()
    assert v1["rules"]["public_note"] == "Graded on moisture only — full schedule pending"
    rules = {**v1["rules"], "public_note": None}

    assert (
        await client.post(f"/v1/standards-profiles/{pid}/versions", json={"rules": rules})
    ).status_code == 403
    w.act_as(w.admin, Role.FPO_ADMIN)
    r = await client.post(f"/v1/standards-profiles/{pid}/versions", json={"rules": rules})
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "profile_incomplete_not_allowed"
    r = await client.post(
        f"/v1/standards-profiles/{pid}/versions", json={"rules": rules, "allow_incomplete": True}
    )
    assert r.status_code == 201, r.text
    assert (r.json()["version_no"], r.json()["status"]) == (2, "published")
    assert (await client.get(f"/v1/standards-profiles/{pid}/versions/1")).json()["status"] == "retired"
