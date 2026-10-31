"""Integration tests of publishing on PostGIS + LocalStack S3: publish, build task, rebuild, QR, labels.

Serves: B10 acceptance, one test per line: after publish objects exist and `generation` matches; HTML has no
phone/survey/`temp_uploads`; revoked name consent → "Farmer 2"; correction → new build_no, old S3 versions
kept; QR decodes to `{PUBLIC_BASE_URL}/b/<code>`; events ascending. Also the dev proxy, labels, lot QR and the
rebuild gate. FR12, FR15-FR17, FR62, FR63, plan §13 E3, CLAUDE.md §6, D-007.
Callers: pytest (`make test`); needs Docker (containers from tests/conftest.py `stack`). Reuses the seeded
world of test_lots_batches.py; the recorded `publishing.build_page` message is run through the real task.
"""

import asyncio
import json
import subprocess
import sys
import uuid
from datetime import UTC, date, datetime
from io import BytesIO
from pathlib import Path
from typing import Any

import pytest
import zxingcpp
from httpx import AsyncClient
from PIL import Image
from sqlalchemy import select
from test_lots_batches import (  # noqa: F401  (`migrated` and `world` are fixtures used by name)
    World,
    _batch,
    _moisture,
    migrated,
    world,
)

from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import ChangeKind, ConsentType, EventSubject, EventType, FarmingType
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.identity.models import ConsentRecord, User
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.registry.models import Farmer, Fpo, Plot, Processor

pytestmark = pytest.mark.integration

LINT = Path(__file__).parents[4] / "infra" / "scripts" / "privacy-lint.py"
ADDRESS = {
    "village": "PM Pudhupatti",
    "block": "Tiruchuli",
    "district": "Virudhunagar",
    "state": "Tamil Nadu",
}


async def _make_publishable(w: World, consent: bool = True) -> uuid.UUID:
    """Fill the public fields the seed leaves empty and record the farmer's name consent.

    Args:
        w: the seeded world.
        consent: give a `public_name` consent (revoked later by a test when needed).

    Returns:
        The farmer id.

    Side effects:
        Updates the FPO, processor, plot and farmer rows; may insert a consent; commits.
    """
    async with get_sessionmaker()() as s:
        plot = await s.get(Plot, w.plot)
        assert plot is not None
        plot.farming_type = FarmingType.RAINFED
        plot.land_record_ref = "Survey No. 45/2"  # internal: must never reach the page
        farmer = await s.get(Farmer, plot.farmer_id)
        assert farmer is not None
        farmer.address = {**ADDRESS, "pin": "626129"}
        processor = await s.get(Processor, w.processor)
        assert processor is not None
        processor.address, processor.fssai_no, processor.gi_authorised_user_no = (
            ADDRESS,
            "DEMO-FSSAI-1",
            "DEMO-GI-1",
        )
        fpo = await s.get(Fpo, w.fpo)
        assert fpo is not None
        fpo.public_show_farmer_names = True
        if consent:
            s.add(
                ConsentRecord(
                    id=uuid7(),
                    farmer_id=farmer.id,
                    consent_type=ConsentType.PUBLIC_NAME,
                    consent_version="v1-en",
                    given_at=datetime(2026, 1, 1, tzinfo=UTC),
                )
            )
        await s.commit()
        return farmer.id


async def _publish(w: World, client: AsyncClient, *kgs: str) -> dict[str, Any]:
    """Make a batch of one lot per quantity, grade, approve, pack and publish it; run the build task.

    Args:
        w: the seeded world.
        client: the API client.
        *kgs: intake kilograms per lot.

    Returns:
        The batch response body (before publishing).
    """
    batch = await _batch(w, client, *kgs)
    reading = _moisture(w, "10.5", stage="grading", batch_id=batch["id"])
    r = await client.post(
        f"/v1/batches/{batch['id']}/grading", json={"declared_grade": "Standard", "readings": [reading]}
    )
    assert r.status_code == 201, r.text
    r = await client.post(
        f"/v1/batches/{batch['id']}/grading/approve", json={"graded": {"value": 20, "unit": "kg"}}
    )
    assert r.status_code == 200, r.text
    packing = {
        "packed": {"value": 20, "unit": "kg"},
        "pack_date": "2026-08-01",
        "best_before_date": "2027-07-31",
    }
    assert (await client.post(f"/v1/batches/{batch['id']}/final-packing", json=packing)).status_code == 200
    assert (await client.post(f"/v1/batches/{batch['id']}/publish")).status_code == 202
    await _run_last_build(w)
    return batch


async def _run_last_build(w: World) -> None:
    """Run the last recorded `publishing.build_page` message through the real task.

    Args:
        w: the seeded world (holds the recorded messages).

    Side effects:
        Builds the page: S3 objects and the build row.
    """
    from agritrace.modules.publishing import tasks  # late: importing the worker reads the settings

    name, kwargs = w.sent[-1]
    assert name == "publishing.build_page"
    assert await asyncio.to_thread(tasks.build_page, **kwargs) == "built"


def _get(key: str, version: str | None = None) -> dict[str, Any]:
    """Read an object from public-pages.

    Args:
        key: object key.
        version: S3 version id, or None for the latest.

    Returns:
        The S3 GetObject response with `Body` read into bytes.
    """
    extra = {"VersionId": version} if version else {}
    obj: dict[str, Any] = storage.client().get_object(
        Bucket=get_settings().s3_bucket_public, Key=key, **extra
    )
    obj["Body"] = obj["Body"].read()
    return obj


async def test_publish_writes_objects_with_matching_generation(world: tuple[World, AsyncClient]) -> None:
    """After publish the three objects exist with the cache headers and data.json `generation` = the row's.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    await _make_publishable(w)
    batch = await _publish(w, client, "100")
    prefix = f"batches/{batch['code']}"
    async with get_sessionmaker()() as s:
        build = await s.scalar(select(PageBuild).where(PageBuild.batch_id == uuid.UUID(batch["id"])))
    assert build is not None and build.status == "built" and build.html_key == f"{prefix}/index.html"
    html, data, qr = _get(f"{prefix}/index.html"), _get(f"{prefix}/data.json"), _get(f"{prefix}/qr.png")
    assert json.loads(data["Body"])["footer"]["generation"] == str(build.generation) == "1"
    assert build.snapshot["footer"]["generation"] == "1"
    assert html["CacheControl"] == data["CacheControl"] == "public, max-age=60"
    assert qr["CacheControl"] == "public, max-age=31536000, immutable" and qr["ContentType"] == "image/png"
    proxy = await client.get(f"/v1/public/batches/{batch['code']}")
    assert proxy.status_code == 200 and proxy.content == html["Body"]
    assert proxy.headers["cache-control"] == "public, max-age=60"
    r = await client.get(f"/v1/batches/{batch['id']}/builds")
    assert [(b["build_no"], b["status"], b["trigger"]) for b in r.json()["items"]] == [
        (1, "built", "publish")
    ]


async def test_html_has_no_phone_survey_or_temp_path(
    world: tuple[World, AsyncClient], tmp_path: Path
) -> None:
    """The built page carries no phone number, land record or temporary path; privacy-lint finds nothing.

    Args:
        world: seeded FPO and client (fixture).
        tmp_path: folder the built objects are downloaded to.
    """
    w, client = world
    await _make_publishable(w)
    batch = await _publish(w, client, "100")
    async with get_sessionmaker()() as s:
        phone = (await s.get(User, w.admin)).phone  # type: ignore[union-attr]
    folder = tmp_path / "batches" / batch["code"]
    folder.mkdir(parents=True)
    for name in ("index.html", "data.json"):
        body = _get(f"batches/{batch['code']}/{name}")["Body"].decode()
        for leak in (phone, phone[-10:], "Survey", "45/2", "temp_uploads", "626129"):
            assert leak not in body, (name, leak)
        (folder / name).write_text(body, encoding="utf-8")
    result = subprocess.run(  # noqa: S603
        [sys.executable, str(LINT), str(tmp_path)], capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stdout


async def test_revoked_name_consent_shows_farmer_2(world: tuple[World, AsyncClient]) -> None:
    """A revoked `public_name` consent hides the name: the second lot shows as "Farmer 2".

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    farmer = await _make_publishable(w)
    async with get_sessionmaker()() as s:
        consent = await s.scalar(select(ConsentRecord).where(ConsentRecord.farmer_id == farmer))
        assert consent is not None
        consent.revoked_at = datetime(2026, 6, 1, tzinfo=UTC)
        await s.commit()
    batch = await _publish(w, client, "100", "200")
    html = _get(f"batches/{batch['code']}/index.html")["Body"].decode()
    data = json.loads(_get(f"batches/{batch['code']}/data.json")["Body"])
    assert "Farmer 2" in html and "Muthu" not in html
    assert [lot["farmer_name"] for lot in data["lots"]] == [None, None]


async def test_correction_rebuild_keeps_old_versions(world: tuple[World, AsyncClient]) -> None:
    """A correction then rebuild → build_no 2; the build 1 objects stay retrievable as older S3 versions.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    await _make_publishable(w)
    batch = await _publish(w, client, "100")
    async with get_sessionmaker()() as s:  # the correction: the processor's FSSAI number was wrong
        processor = await s.get(Processor, w.processor)
        assert processor is not None
        processor.fssai_no = "DEMO-FSSAI-2"
        await s.commit()
    r = await client.post(f"/v1/batches/{batch['id']}/rebuild")
    assert r.status_code == 202, r.text
    assert (r.json()["build_no"], r.json()["status"], r.json()["trigger"]) == (2, "queued", "rebuild")
    await _run_last_build(w)
    key = f"batches/{batch['code']}/data.json"
    versions = storage.client().list_object_versions(Bucket=get_settings().s3_bucket_public, Prefix=key)[
        "Versions"
    ]
    assert len(versions) == 2
    old = next(v for v in versions if not v["IsLatest"])
    old_data, new_data = json.loads(_get(key, old["VersionId"])["Body"]), json.loads(_get(key)["Body"])
    assert (
        old_data["footer"]["generation"] == "1"
        and old_data["processor"]["fssai_licence_no"] == "DEMO-FSSAI-1"
    )
    assert (
        new_data["footer"]["generation"] == "2"
        and new_data["processor"]["fssai_licence_no"] == "DEMO-FSSAI-2"
    )
    r = await client.get(f"/v1/batches/{batch['id']}/builds")
    assert [(b["build_no"], b["status"]) for b in r.json()["items"]] == [(1, "built"), (2, "built")]


async def test_qr_decodes_to_public_url(world: tuple[World, AsyncClient]) -> None:
    """Stored qr.png and `GET /batches/{id}/qr.png` decode to `{PUBLIC_BASE_URL}/b/<code>`; lot QR = lot code.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    await _make_publishable(w)
    batch = await _publish(w, client, "100")
    expected = f"{get_settings().public_base_url.rstrip('/')}/b/{batch['code']}"
    api = await client.get(f"/v1/batches/{batch['id']}/qr.png")
    assert api.status_code == 200 and api.headers["content-type"] == "image/png"
    for png in (api.content, _get(f"batches/{batch['code']}/qr.png")["Body"]):
        assert [r.text for r in zxingcpp.read_barcodes(Image.open(BytesIO(png)))] == [expected]
    lot_id = batch["shares"][0]["lot_id"]
    lot = await client.get(f"/v1/lots/{lot_id}/qr")
    code = (await client.get(f"/v1/lots/{lot_id}")).json()["code"]
    assert [r.text for r in zxingcpp.read_barcodes(Image.open(BytesIO(lot.content)))] == [code]
    labels = await client.get(f"/v1/batches/{batch['id']}/labels.pdf")
    assert labels.status_code == 200 and labels.content.startswith(b"%PDF")


async def test_events_ascending(world: tuple[World, AsyncClient]) -> None:
    """Events stored newest first come out date-ascending in data.json (FR63).

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    await _make_publishable(w)
    batch = await _batch(w, client, "100")
    lot_id = uuid.UUID(batch["shares"][0]["lot_id"])
    async with get_sessionmaker()() as s:
        for n, (kind, on) in enumerate(
            [
                (EventType.PACKING, date(2026, 3, 12)),
                (EventType.HARVEST, date(2026, 2, 14)),
                (EventType.LAND_PREPARATION, date(2025, 8, 24)),
            ]
        ):
            event = Event(
                id=uuid7(),
                fpo_id=w.fpo,
                subject_type=EventSubject.LOT,
                lot_id=lot_id,
                plot_id=w.plot,
                event_type=kind,
                occurred_on=on,
            )
            s.add(event)
            await s.flush()
            version = EventVersion(
                id=uuid7(),
                event_id=event.id,
                version_no=1,
                payload={},
                occurred_on=on,
                device_time=datetime(2026, 3, 12, n, tzinfo=UTC),
                server_received_at=datetime(2026, 3, 12, n, tzinfo=UTC),
                entered_by_user_id=w.admin,
                change_kind=ChangeKind.CREATE,
            )
            s.add(version)
            await s.flush()
            event.current_version_id = version.id
        await s.commit()
    reading = _moisture(w, "10.5", stage="grading", batch_id=batch["id"])
    await client.post(
        f"/v1/batches/{batch['id']}/grading", json={"declared_grade": "Standard", "readings": [reading]}
    )
    await client.post(
        f"/v1/batches/{batch['id']}/grading/approve", json={"graded": {"value": 20, "unit": "kg"}}
    )
    packing = {
        "packed": {"value": 20, "unit": "kg"},
        "pack_date": "2026-08-01",
        "best_before_date": "2027-07-31",
    }
    await client.post(f"/v1/batches/{batch['id']}/final-packing", json=packing)
    assert (await client.post(f"/v1/batches/{batch['id']}/publish")).status_code == 202
    await _run_last_build(w)
    data = json.loads(_get(f"batches/{batch['code']}/data.json")["Body"])
    dates = [e["date"] for e in data["lots"][0]["events"]]
    assert dates == sorted(dates) and dates[0] == "2025-08-24" and len(dates) == 4  # 3 events + sale


async def test_rebuild_needs_a_published_batch(world: tuple[World, AsyncClient]) -> None:
    """Rebuilding an unpublished batch → 409 `not_published`; labels before packing → `final_packing_missing`.

    Args:
        world: seeded FPO and client (fixture).
    """
    w, client = world
    batch = await _batch(w, client, "100")
    r = await client.post(f"/v1/batches/{batch['id']}/rebuild")
    assert r.status_code == 409 and r.json()["error"]["details"]["reasons"][0]["code"] == "not_published"
    r = await client.get(f"/v1/batches/{batch['id']}/labels.pdf")
    assert (
        r.status_code == 409 and r.json()["error"]["details"]["reasons"][0]["code"] == "final_packing_missing"
    )
    assert (await client.get(f"/v1/public/batches/{batch['code']}")).status_code == 404
