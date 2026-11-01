"""Integration tests of sync push, photo upload/confirm/verify, corrections and undo on PostGIS + LocalStack.

Serves: B06 acceptance (same client_id twice → 1 row + `duplicate`; foreign id → `client_id_conflict`;
mixed batch #1/#3 accepted, #2 rejected; wrong checksum → `checksum_mismatch` + flag task; undo after
24 h → 409; farmer correction → 403; device clock +3 d → stored + `clock_skew` hint), presigned PUT with
SHA-256 then confirm → verify → variants, confirm without upload → `missing`, audit rows for Core writes,
SQLSTATE 23001 → `append_only_violation`, an object bigger than declared → `checksum_mismatch` (B18),
a NUL payload and an int32-overflow `instance_no` reject only their entries, also through the Postgres
class-22 backstop with the pre-check off; a 5,000-deep `data` is a per-entry rejection (B21, Q04-1, B21-r1).
backend-design.md §3, D-005, D-011, FR61.
Callers: pytest (`make test`); needs Docker (tests/conftest.py `stack`). The caller is injected by a
dependency override; Celery's `send_task` is recorded (eager mode does not apply to tasks sent by name);
tasks are run in a thread (they open their own loop and NullPool engine, D-009).
"""

import asyncio
import hashlib
import json
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass, field
from datetime import UTC, datetime, timedelta, timezone
from decimal import Decimal
from io import BytesIO
from pathlib import Path
from typing import Any

import httpx
import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient
from PIL import ExifTags, Image
from sqlalchemy import func, select, text
from sqlalchemy.exc import DBAPIError

from agritrace.core import storage, task_names
from agritrace.core.audit import AUDIT_LOG
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import OrgKind, PinMethod, Role
from agritrace.core.errors import AppendOnlyViolationError, append_only_error
from agritrace.core.ids import lot_code, uuid7
from agritrace.modules.events import service
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.registry.models import Crop, Farmer, Fpo, Plot

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
LAT, LON = 9.5598, 78.1335
IST = timezone(timedelta(hours=5, minutes=30))


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (a no-op when another module already did).

    Args:
        stack: the running containers (fixture).

    Raises:
        AssertionError: alembic failed.
    """
    alembic = str(Path(sys.executable).parent / "alembic")
    result = subprocess.run(  # noqa: S603
        [alembic, "upgrade", "head"], cwd=API_DIR, capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stdout + result.stderr


@dataclass
class World:
    """One seeded FPO: a farmer and a neighbour, each with lot and plot, a field officer, the caller."""

    fpo: uuid.UUID
    farmer_user: uuid.UUID
    officer: uuid.UUID
    lot: uuid.UUID
    plot: uuid.UUID
    neighbour: uuid.UUID
    neighbour_lot: uuid.UUID
    neighbour_plot: uuid.UUID
    caller: CurrentUser
    sent: list[tuple[str, dict[str, Any]]] = field(default_factory=list)

    def act_as(self, user_id: uuid.UUID, role: Role) -> None:
        """Switch the caller.

        Args:
            user_id: the user.
            role: their role.

        Side effects:
            Replaces `caller`.
        """
        self.caller = CurrentUser(user_id=user_id, fpo_id=self.fpo, role=role)


async def _seed() -> dict[str, uuid.UUID]:
    """Insert an FPO, a field officer, and two farmers (the caller and a neighbour), each with plot and lot.

    Returns:
        Ids by name.

    Side effects:
        Commits rows.
    """
    async with get_sessionmaker()() as s:
        officer = User(phone=f"+9197{secrets.randbelow(10**8):08d}", name="Officer")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        crop = Crop(code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={})
        s.add_all([officer, fpo, crop])
        await s.flush()
        ids = {"fpo": fpo.id, "officer": officer.id}
        for prefix, code in (("", "F-001"), ("neighbour_", "F-002")):
            user = User(phone=f"+9198{secrets.randbelow(10**8):08d}", name=code)
            s.add(user)
            await s.flush()
            farmer = Farmer(fpo_id=fpo.id, code=code, name=code, user_id=user.id)
            s.add(farmer)
            await s.flush()
            plot = Plot(
                id=uuid7(),
                fpo_id=fpo.id,
                farmer_id=farmer.id,
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
                fpo_id=fpo.id,
                farmer_id=farmer.id,
                plot_id=plot.id,
                crop_id=crop.id,
                season_label="2025-26",
                code=lot_code(),
            )
            s.add(lot)
            await s.flush()
            key = "neighbour" if prefix else "farmer_user"
            ids |= {key: user.id, f"{prefix}lot": lot.id, f"{prefix}plot": plot.id}
        await s.commit()
        return ids


@pytest.fixture
async def world(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO; the caller starts as its farmer.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: replaces `send_task` with a recorder.

    Returns:
        An async iterator yielding the world and an HTTP client.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    ids = await _seed()
    w = World(caller=CurrentUser(user_id=ids["farmer_user"], fpo_id=ids["fpo"], role=Role.FARMER), **ids)
    monkeypatch.setattr(
        celery_app, "send_task", lambda name, kwargs=None, **_: w.sent.append((name, kwargs or {}))
    )
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client


def harvest(w: World, *, device_time: datetime | None = None, **over: Any) -> dict[str, Any]:
    """Build an `event_version` entry (harvest, version 1) on the world's lot.

    Args:
        w: the world.
        device_time: phone clock; default now.
        **over: data fields to replace.

    Returns:
        The entry.
    """
    data = {
        "event_id": str(uuid7()),
        "version_no": 1,
        "subject_type": "lot",
        "lot_id": str(w.lot),
        "plot_id": str(w.plot),
        "event_type": "harvest",
        "instance_no": 1,
        "occurred_on": "2026-03-04",
        "payload": {"quantity": {"value": 195, "unit": "kg"}, "bags": 13},
        "clocks": {"device_time": (device_time or datetime.now(UTC)).isoformat()},
        "gps": {"lat": LAT, "lon": LON, "accuracy_m": 6.2},
    }
    return {"client_id": str(uuid7()), "kind": "event_version", "data": {**data, **over}}


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


def photo_jpeg(taken: datetime) -> bytes:
    """Make a JPEG whose EXIF matches the entry (capture time in IST with offset, GPS at the plot).

    Args:
        taken: capture time.

    Returns:
        The JPEG bytes.
    """
    exif = Image.Exif()
    sub = exif.get_ifd(ExifTags.IFD.Exif)
    sub[ExifTags.Base.DateTimeOriginal] = taken.astimezone(IST).strftime("%Y:%m:%d %H:%M:%S")
    sub[ExifTags.Base.OffsetTimeOriginal] = "+05:30"
    gps = exif.get_ifd(ExifTags.IFD.GPSInfo)
    gps.update({1: "N", 2: (9.0, 33.0, 35.28), 3: "E", 4: (78.0, 8.0, 0.6)})
    buf = BytesIO()
    Image.new("RGB", (1600, 1200), "darkred").save(buf, "JPEG", exif=exif, quality=80)
    return buf.getvalue()


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


async def test_same_client_id_twice_is_one_row_and_duplicate(world: tuple[World, AsyncClient]) -> None:
    """Resending an entry stores one version and answers `duplicate` with the same server id.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    first = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    second = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    assert first["status"] == "accepted" and second["status"] == "duplicate"
    assert first["server_id"] == second["server_id"] == entry["client_id"]
    assert await count(EventVersion, EventVersion.id == uuid.UUID(entry["client_id"])) == 1


async def test_foreign_client_id_is_a_conflict(world: tuple[World, AsyncClient]) -> None:
    """Another user resending the farmer's id is rejected with `client_id_conflict`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    await client.post("/v1/sync/push", json=envelope(entry))
    w.act_as(w.officer, Role.FIELD_OFFICER)
    result = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    assert result["status"] == "rejected" and result["error"]["code"] == "client_id_conflict"


async def test_mixed_batch_rejects_only_the_bad_entry(world: tuple[World, AsyncClient]) -> None:
    """#1 and #3 are accepted and stored; #2 (negative quantity) is rejected; the response is 200.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    bad = harvest(w, payload={"quantity": {"value": -5, "unit": "kg"}})
    response = await client.post("/v1/sync/push", json=envelope(harvest(w), bad, harvest(w)))
    assert response.status_code == 200
    statuses = [r["status"] for r in response.json()["results"]]
    assert statuses == ["accepted", "rejected", "accepted"]
    assert response.json()["results"][1]["error"]["code"] == "validation_error"
    assert await count(EventVersion, EventVersion.id == uuid.UUID(bad["client_id"])) == 0


async def test_photo_upload_confirm_verify_and_variants(world: tuple[World, AsyncClient]) -> None:
    """Presigned PUT with SHA-256 → confirm `received` → verify `verified` → WebP variants recorded.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    now = datetime.now(UTC)
    body = photo_jpeg(now)
    photo_id = uuid7()
    meta = {"client_id": str(photo_id), "sha256": hashlib.sha256(body).hexdigest(), "size_bytes": len(body)}
    result = (
        await client.post("/v1/sync/push", json=envelope(harvest(w, device_time=now, photos=[meta])))
    ).json()
    upload = result["results"][0]["photo_uploads"][0]
    assert not [s for s in w.sent if s[0] == task_names.RULES_CHECK_EVENT]  # waits for the photo
    assert httpx.put(upload["url"], content=body, headers=upload["headers"]).status_code == 200

    confirmed = await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(photo_id)}]})
    assert confirmed.json() == [{"client_id": str(photo_id), "status": "received"}]
    assert (task_names.EVENTS_VERIFY_PHOTO, {"photo_id": str(photo_id)}) in w.sent

    from agritrace.modules.events import tasks  # lazy: the worker module reads settings on import

    assert await asyncio.to_thread(tasks.verify_photo, str(photo_id)) == "verified"
    assert any(n == task_names.EVENTS_MAKE_VARIANTS for n, _ in w.sent)
    variants = await asyncio.to_thread(tasks.make_variants, str(photo_id))
    assert variants is not None
    assert set(variants) >= {"thumb_url", "medium_url", "jpeg_url", "width", "height"}
    assert variants["jpeg_url"].endswith(f"{photo_id}.jpg") and "/evidence/" in variants["jpeg_url"]
    key = variants["thumb_url"].split(f"/{get_settings().s3_bucket_evidence}/", 1)[1]
    assert storage.head(key) is not None


async def test_wrong_checksum_is_flagged(world: tuple[World, AsyncClient]) -> None:
    """Bytes that differ from the promised SHA-256 → `checksum_mismatch` and a rules task with the hint.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    photo_id = uuid7()
    meta = {"client_id": str(photo_id), "sha256": hashlib.sha256(b"promised").hexdigest(), "size_bytes": 8}
    await client.post("/v1/sync/push", json=envelope(harvest(w, photos=[meta])))
    async with get_sessionmaker()() as s:
        row = await s.get(EvidencePhoto, photo_id)
        assert row is not None
        key = row.object_key
    # Written around the presigned URL (which storage would refuse), as a tampered object would be.
    storage.client().put_object(
        Bucket=get_settings().s3_bucket_evidence, Key=key, Body=b"tampered", ChecksumAlgorithm="SHA256"
    )
    await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(photo_id)}]})
    from agritrace.modules.events import tasks  # lazy: the worker module reads settings on import

    assert await asyncio.to_thread(tasks.verify_photo, str(photo_id)) == "checksum_mismatch"
    rules = [k for n, k in w.sent if n == task_names.RULES_CHECK_EVENT]
    assert rules and rules[-1]["hints"] == ["checksum_mismatch"]
    assert not any(n == task_names.EVENTS_MAKE_VARIANTS for n, _ in w.sent)


async def test_oversize_object_is_flagged_without_reading_it_whole(world: tuple[World, AsyncClient]) -> None:
    """An object bigger than the declared size is `checksum_mismatch`, read only to size + 1 (B18).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    photo_id = uuid7()
    head = b"\xff\xd8 promised"
    # The SHA-256 of the first size + 1 bytes: the bounded read matches it, so only the length check refuses.
    digest = hashlib.sha256(head + b"x").hexdigest()
    meta = {"client_id": str(photo_id), "sha256": digest, "size_bytes": len(head)}
    await client.post("/v1/sync/push", json=envelope(harvest(w, photos=[meta])))
    async with get_sessionmaker()() as s:
        row = await s.get(EvidencePhoto, photo_id)
        assert row is not None
        key = row.object_key
    # Written around the presigned URL (which signs the length), as a store that ignores it would allow.
    big = head + b"x" * 4096
    storage.client().put_object(
        Bucket=get_settings().s3_bucket_evidence, Key=key, Body=big, ChecksumAlgorithm="SHA256"
    )
    await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(photo_id)}]})
    from agritrace.modules.events import tasks  # lazy: the worker module reads settings on import

    assert await asyncio.to_thread(tasks.verify_photo, str(photo_id)) == "checksum_mismatch"
    rules = [k for n, k in w.sent if n == task_names.RULES_CHECK_EVENT]
    assert rules and rules[-1]["hints"] == ["checksum_mismatch"]
    assert not any(n == task_names.EVENTS_MAKE_VARIANTS for n, _ in w.sent)


async def test_confirm_without_upload_is_missing(world: tuple[World, AsyncClient]) -> None:
    """Confirming a photo never uploaded answers `missing` and queues nothing.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    photo_id = uuid7()
    meta = {"client_id": str(photo_id), "sha256": "ab" * 32, "size_bytes": 10}
    await client.post("/v1/sync/push", json=envelope(harvest(w, photos=[meta])))
    response = await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(photo_id)}]})
    assert response.json() == [{"client_id": str(photo_id), "status": "missing"}]
    assert not any(n == task_names.EVENTS_VERIFY_PHOTO for n, _ in w.sent)


async def test_undo_after_24_hours_is_409(world: tuple[World, AsyncClient]) -> None:
    """The farmer's own entry captured 25 hours ago cannot be undone (`undo_window_closed`).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w, device_time=datetime.now(UTC) - timedelta(hours=25))
    await client.post("/v1/sync/push", json=envelope(entry))
    event_id = entry["data"]["event_id"]
    response = await client.post(
        f"/v1/events/{event_id}/undo", json={"client_id": str(uuid7()), "version_no": 2}
    )
    assert response.status_code == 409 and response.json()["error"]["code"] == "undo_window_closed"


async def test_undo_within_24_hours_marks_event_undone(world: tuple[World, AsyncClient]) -> None:
    """A fresh own entry is undone: version 2 with change_kind undo, event status `undone`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    await client.post("/v1/sync/push", json=envelope(entry))
    event_id = entry["data"]["event_id"]
    response = await client.post(
        f"/v1/events/{event_id}/undo", json={"client_id": str(uuid7()), "version_no": 2}
    )
    assert response.status_code == 200 and response.json()["status"] == "accepted"
    listed = (await client.get(f"/v1/lots/{w.lot}/events")).json()["items"]
    assert [(e["status"], e["version_no"], e["change_kind"]) for e in listed] == [("undone", 2, "undo")]


async def test_farmer_correction_is_403_and_officer_correction_works(
    world: tuple[World, AsyncClient],
) -> None:
    """Farmers get 403 on corrections; an officer's correction with a reason becomes version 2.

    Its audit row names the actor and the reason code (P06 audit search, B20).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    await client.post("/v1/sync/push", json=envelope(entry))
    event_id = entry["data"]["event_id"]
    data = {**entry["data"], "version_no": 2, "change_kind": "correct", "reason_code": "wrong_quantity"}
    data["payload"] = {"quantity": {"value": 185, "unit": "kg"}}
    body = {"client_id": str(uuid7()), "data": data}
    farmer = await client.post(f"/v1/events/{event_id}/versions", json=body)
    assert farmer.status_code == 403 and farmer.json()["error"]["code"] == "forbidden"
    w.act_as(w.officer, Role.FIELD_OFFICER)
    officer = await client.post(f"/v1/events/{event_id}/versions", json=body)
    assert officer.status_code == 200 and officer.json()["status"] == "accepted"
    stale = await client.post(f"/v1/events/{event_id}/versions", json={**body, "client_id": str(uuid7())})
    assert stale.status_code == 409 and stale.json()["error"]["code"] == "stale_version"
    async with get_sessionmaker()() as s:
        event = await s.get(Event, uuid.UUID(event_id))
        assert event is not None and event.current_version_id == uuid.UUID(body["client_id"])
        audit = (
            await s.execute(select(AUDIT_LOG).where(AUDIT_LOG.c.entity_id == uuid.UUID(body["client_id"])))
        ).one()
    assert (audit.action, audit.actor_user_id, audit.diff["reason_code"]) == (
        "event.correct",
        w.officer,
        "wrong_quantity",
    )


async def test_device_clock_three_days_ahead_is_stored_with_hint(world: tuple[World, AsyncClient]) -> None:
    """A device time 3 days in the future is stored (three clocks kept) and hints `clock_skew` to rules.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w, device_time=datetime.now(UTC) + timedelta(days=3))
    result = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    assert result["status"] == "accepted"
    rules = [k for n, k in w.sent if n == task_names.RULES_CHECK_EVENT]
    assert rules == [
        {"event_id": entry["data"]["event_id"], "version_id": entry["client_id"], "hints": ["clock_skew"]}
    ]
    async with get_sessionmaker()() as s:
        row = await s.get(EventVersion, uuid.UUID(entry["client_id"]))
        assert row is not None and row.device_time - row.server_received_at > timedelta(days=2)


async def test_sync_writes_have_audit_rows(world: tuple[World, AsyncClient]) -> None:
    """The Core insert of a version is audited explicitly (`sync.push`, entity event_versions).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    await client.post("/v1/sync/push", json=envelope(entry))
    async with get_sessionmaker()() as s:
        rows = (
            await s.execute(select(AUDIT_LOG).where(AUDIT_LOG.c.entity_id == uuid.UUID(entry["client_id"])))
        ).all()
    assert [(r.action, r.entity_type, r.actor_user_id) for r in rows] == [
        ("sync.push", "event_versions", w.farmer_user)
    ]
    assert rows[0].diff["photos"] == []


async def test_append_only_violation_is_mapped(world: tuple[World, AsyncClient]) -> None:
    """Updating an event version raises SQLSTATE 23001, mapped to `append_only_violation`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w)
    await client.post("/v1/sync/push", json=envelope(entry))
    async with get_sessionmaker()() as s:
        with pytest.raises(DBAPIError) as exc:
            await s.execute(
                text("UPDATE event_versions SET reason_text = 'edited' WHERE id = :id"),
                {"id": entry["client_id"]},
            )
        await s.rollback()
    assert isinstance(append_only_error(exc.value), AppendOnlyViolationError)


async def test_plot_must_be_the_lots_plot(world: tuple[World, AsyncClient]) -> None:
    """A neighbour's plot in the same FPO on the farmer's own lot is rejected (FR69 compares to it).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w, plot_id=str(w.neighbour_plot))
    result = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    assert result["status"] == "rejected" and result["error"]["code"] == "validation_error"


async def test_farmer_cannot_write_on_another_farmers_lot(world: tuple[World, AsyncClient]) -> None:
    """The neighbour's lot is not found for this farmer (404 semantics, nothing stored).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    entry = harvest(w, lot_id=str(w.neighbour_lot), plot_id=str(w.neighbour_plot))
    result = (await client.post("/v1/sync/push", json=envelope(entry))).json()["results"][0]
    assert result["status"] == "rejected" and result["error"]["code"] == "not_found"
    assert await count(EventVersion, EventVersion.id == uuid.UUID(entry["client_id"])) == 0


async def test_voice_note_gets_its_own_key_and_type(world: tuple[World, AsyncClient]) -> None:
    """An `audio/ogg` voice note is registered with a `.ogg` key and a PUT bound to its type.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    note = {"client_id": str(uuid7()), "sha256": "cd" * 32, "size_bytes": 48_000, "content_type": "audio/ogg"}
    result = (await client.post("/v1/sync/push", json=envelope(harvest(w, photos=[note])))).json()["results"][
        0
    ]
    upload = result["photo_uploads"][0]
    assert upload["headers"]["Content-Type"] == "audio/ogg"
    assert upload["url"].split("?")[0].endswith(f"{note['client_id']}.ogg")


async def test_only_the_uploader_confirms(world: tuple[World, AsyncClient]) -> None:
    """Another user of the same FPO confirming the farmer's photo gets `missing` and queues nothing.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    photo_id = uuid7()
    meta = {"client_id": str(photo_id), "sha256": "ab" * 32, "size_bytes": 10}
    await client.post("/v1/sync/push", json=envelope(harvest(w, photos=[meta])))
    w.act_as(w.officer, Role.FIELD_OFFICER)
    response = await client.post("/v1/sync/photos/confirm", json={"photos": [{"client_id": str(photo_id)}]})
    assert response.json() == [{"client_id": str(photo_id), "status": "missing"}]


async def test_declared_exif_is_kept_in_the_audit_row(world: tuple[World, AsyncClient]) -> None:
    """The phone's declared EXIF time is stored append-only; the photo's exif columns wait for verify.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    photo_id = uuid7()
    meta = {
        "client_id": str(photo_id),
        "sha256": "ab" * 32,
        "size_bytes": 10,
        "exif_taken_at": "2026-03-04T08:10:00+05:30",
        "exif_gps": {"lat": LAT, "lon": LON},
    }
    entry = harvest(w, photos=[meta])
    await client.post("/v1/sync/push", json=envelope(entry))
    async with get_sessionmaker()() as s:
        row = (
            await s.execute(select(AUDIT_LOG).where(AUDIT_LOG.c.entity_id == uuid.UUID(entry["client_id"])))
        ).one()
        photo = await s.get(EvidencePhoto, photo_id)
    declared = row.diff["photos"][0]
    assert declared["client_id"] == str(photo_id) and declared["exif_gps"]["lat"] == LAT
    assert declared["exif_taken_at"].startswith("2026-03-04T08:10:00")
    assert photo is not None and photo.exif_taken_at is None


async def test_nul_and_int32_overflow_reject_only_their_entries(world: tuple[World, AsyncClient]) -> None:
    """[NUL in payload, clean, instance_no above int32] → rejected, accepted, rejected; 200 (Q04-1).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    nul = harvest(w, event_type="problem", payload={"problem_type": "pest", "description": "a\x00b"})
    big = harvest(w, instance_no=3_000_000_000)
    response = await client.post("/v1/sync/push", json=envelope(nul, harvest(w), big))
    assert response.status_code == 200
    results = response.json()["results"]
    assert [r["status"] for r in results] == ["rejected", "accepted", "rejected"]
    assert {results[0]["error"]["code"], results[2]["error"]["code"]} == {"validation_error"}
    refused = [uuid.UUID(nul["client_id"]), uuid.UUID(big["client_id"])]
    assert await count(EventVersion, EventVersion.id.in_(refused)) == 0


async def test_postgres_data_error_rejects_only_its_entry(
    world: tuple[World, AsyncClient], monkeypatch: pytest.MonkeyPatch
) -> None:
    """With the NUL pre-check off, Postgres refuses the NUL (class 22): [NUL, clean] → rejected, accepted.

    Args:
        world: seeded FPO and client (fixture).
        monkeypatch: switches `service.has_nul` off so the entry reaches the INSERT.
    """
    w, client = world
    monkeypatch.setattr(service, "has_nul", lambda _: False)
    nul = harvest(w, event_type="problem", payload={"problem_type": "pest", "description": "a\x00b"})
    response = await client.post("/v1/sync/push", json=envelope(nul, harvest(w)))
    assert response.status_code == 200
    results = response.json()["results"]
    assert [r["status"] for r in results] == ["rejected", "accepted"]
    assert results[0]["error"]["code"] == "validation_error"
    assert results[0]["error"]["details"][0]["type"] == "db_data_error"


async def test_deeply_nested_data_rejects_only_its_entry(world: tuple[World, AsyncClient]) -> None:
    """An entry whose `data` nests 5,000 lists deep (NUL at the bottom) is rejected, not a 500 (B21-r1 P2-1).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    body = json.dumps(envelope(harvest(w), harvest(w, deep="__DEEP__"), harvest(w)))
    deep = "[" * 5_000 + '"x\\u0000"' + "]" * 5_000  # built as text: json.dumps refuses this depth
    content = body.replace('"__DEEP__"', deep)
    headers = {"Content-Type": "application/json"}
    response = await client.post("/v1/sync/push", content=content, headers=headers)
    assert response.status_code == 200
    assert [r["status"] for r in response.json()["results"]] == ["accepted", "rejected", "accepted"]
