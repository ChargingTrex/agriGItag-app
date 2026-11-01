"""Unit tests of the public page snapshot builder, the QR image and the label sheet (no database, no S3).

Serves: B10 acceptance (HTML has no phone/survey/`temp_uploads`; revoked name consent → "Farmer 2"; QR decodes
to `{PUBLIC_BASE_URL}/b/<code>`; events ascending; `generation` in data.json), FR51, FR60, FR62, FR63, FR72,
CLAUDE.md §6 (privacy-lint over a built page; B18 `privacy_hits` refuses free-text leaks), D-034.
Callers: pytest (`make test-unit`). The fixture batch mirrors the reference batch FGP8T4033HM7 (PRD §12) with
its data problems fixed; the rows are ORM objects built in memory and fed to `builder.assemble`.
"""

import json
import subprocess
import sys
import uuid
from collections.abc import Iterator
from datetime import UTC, date, datetime
from decimal import Decimal
from io import BytesIO
from pathlib import Path
from typing import Any

import pytest
import zxingcpp
from agritrace_page import render
from geoalchemy2 import WKTElement
from PIL import Image
from pydantic import ValidationError

from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.enums import (
    ChangeKind,
    EventStatus,
    EventSubject,
    EventType,
    FarmingType,
    GradeStatus,
    IrrigationSource,
    OrgKind,
    PhotoStatus,
    PinMethod,
)
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot, LotIntake
from agritrace.modules.publishing import builder, service
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.quality.models import GradeComputation, StandardsProfileVersion
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiTag, Plot, Processor, Village

LINT = Path(__file__).parents[4] / "infra" / "scripts" / "privacy-lint.py"
BASE = "https://trace.example.in"
CODE = "FGP8T4033HM7"
NOW = datetime(2026, 7, 30, 9, 27, tzinfo=UTC)
# Lots in the reference batch, deliberately not in code order: (code, farmer, kg, share %, consent, walked).
LOTS = (
    ("LOTD02DADB6", "Kannan Example", "100", "31.25", True, False),
    ("LOT3072CB6A", "Selvi Example", "200", "62.5", False, True),
    ("LOT0EF81415", "Murugan Example", "20", "6.25", True, False),
)


@pytest.fixture(autouse=True)
def settings(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Point the settings at a public base URL and the default buckets.

    Args:
        monkeypatch: pytest monkeypatch fixture.

    Returns:
        An iterator yielding once; caches are cleared before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test")
    monkeypatch.setenv("PUBLIC_BASE_URL", BASE)
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()
    yield
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()


def _event(
    lot: Lot, kind: EventType, on: date, instance: int = 1, **payload: Any
) -> tuple[Event, EventVersion]:
    """Build a live event with its current version.

    Args:
        lot: the lot.
        kind: event type.
        on: date it happened.
        instance: instance number.
        **payload: payload fields.

    Returns:
        `(event, version)`.
    """
    event = Event(
        id=uuid.uuid4(),
        fpo_id=lot.fpo_id,
        subject_type=EventSubject.LOT,
        lot_id=lot.id,
        event_type=kind,
        instance_no=instance,
        status=EventStatus.SUBMITTED,
        occurred_on=on,
    )
    version = EventVersion(
        id=uuid.uuid4(),
        event_id=event.id,
        version_no=1,
        payload=payload,
        occurred_on=on,
        device_time=NOW,
        server_received_at=NOW,
        entered_by_user_id=uuid.uuid4(),
        change_kind=ChangeKind.CREATE,
        is_system_generated=False,
    )
    event.current_version_id = version.id
    return event, version


def _rows(names_on: bool = True) -> builder.BatchRows:
    """Build the reference batch rows in memory.

    Args:
        names_on: the FPO's `public_show_farmer_names` switch.

    Returns:
        Rows for `builder.assemble`; lot 2 (by code) has revoked its name consent and walked a boundary.
    """
    fpo = Fpo(
        id=uuid.uuid4(),
        code="VIRUDHAI_SCFC_VINOBA_BHAVA_FPO",
        name="Virudhai SCFC Vinoba Bhava FPO",
        kind=OrgKind.FPO,
        fssai_no="DEMO-FSSAI-0001",
        gi_authorised_user_no="DEMO-GI-AU-883-0001",
        public_show_farmer_names=names_on,
    )
    gi = GiTag(id=uuid.uuid4(), gi_number="883", name="Virudhunagar Samba Vathal")
    crop = Crop(
        id=uuid.uuid4(),
        code="SAMBA_VATHAL",
        name_en="Virudhunagar Samba Vathal",
        name_local="விருதுநகர் சம்பா வத்தல்",
        gi_tag_id=gi.id,
        event_schema={},
    )
    processor = Processor(
        id=uuid.uuid4(),
        fpo_id=fpo.id,
        name="Virudhai SCFC Vinoba Bhava FPO",
        kind=OrgKind.FPO,
        address={
            "village": "P Thottiyangulam",
            "block": "Tiruchuli",
            "district": "Virudhunagar",
            "state": "Tamil Nadu",
            "pin": "626129",
        },
    )
    batch = Batch(
        id=uuid.uuid4(),
        fpo_id=fpo.id,
        crop_id=crop.id,
        processor_id=processor.id,
        code=CODE,
        superlot_code="COMBO_LOT_6C1DCCFE",
        gi_verified=True,
        total_received_kg=Decimal("320"),
        graded_kg=Decimal("20"),
        packed_kg=Decimal("20"),
        pack_date=date(2026, 7, 30),
        best_before_date=date(2027, 7, 29),
        current_build_no=3,
    )
    profile = StandardsProfileVersion(
        id=uuid.uuid4(),
        edition="LOAD_FROM_STANDARD",
        clause_ref="Schedule IV",
        rules={
            "standard": {"name": "AGMARK Dry Chillies and Capsicums"},
            "parameters": [{"code": "moisture", "name_en": "Moisture"}],
        },
    )
    grade = GradeComputation(
        batch_id=batch.id,
        profile_version_id=profile.id,
        computed_grade="Standard",
        per_parameter={
            "moisture": {
                "parameter": "moisture",
                "outcome": "graded",
                "value": "10.4",
                "unit": "%",
                "source": "instrument",
            },
            "extraneous_matter": {"parameter": "extraneous_matter", "outcome": "missing"},
        },
        status=GradeStatus.OK,
        lab_certified=False,
        computed_at=NOW,
    )
    village = Village(name_en="PM Pudhupatti", block="Tiruchuli", district="Virudhunagar", state="Tamil Nadu")
    lots, photos = [], {}
    for code, name, kgs, pct, consent, walked in LOTS:
        farmer = Farmer(
            id=uuid.uuid4(), fpo_id=fpo.id, code=code, name=name, gi_authorised_user_no="DEMO-GI-P-1"
        )
        plot = Plot(
            id=uuid.uuid4(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            pin=WKTElement("POINT(78.201934 9.536271)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            declared_area_acres=Decimal("0.5"),
            land_record_ref="S.F. No. 123/4A",  # internal: must never reach the page
            walked_boundary=(
                WKTElement("POLYGON((78.2 9.5, 78.21 9.5, 78.21 9.51, 78.2 9.5))", srid=4326)
                if walked
                else None
            ),
            farming_type=FarmingType.IRRIGATED,
            irrigation_source=IrrigationSource.WELL,
            reviewed_at=datetime(2026, 3, 4, tzinfo=UTC) if walked else None,
            review_method="field_visit" if walked else None,
        )
        lot = Lot(
            id=uuid.uuid4(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            plot_id=plot.id,
            crop_id=crop.id,
            code=code,
            practice_tags={"declared": ["organic"], "derived": ["organic"], "contradiction": False},
        )
        # Sent newest first and with a same-day pair, so ordering is the builder's job.
        events = [
            _event(lot, EventType.PACKING, date(2026, 3, 12), quantity={"value": 69, "unit": "kg"}),
            _event(lot, EventType.DRYING, date(2026, 2, 15)),
            _event(lot, EventType.HARVEST, date(2026, 2, 15), quantity={"value": 77.6, "unit": "kg"}),
            _event(lot, EventType.SOWING, date(2025, 11, 11), seed_variety="K2"),
            _event(lot, EventType.LAND_PREPARATION, date(2025, 8, 24)),
        ]
        sowing_version = events[3][1]
        photos[sowing_version.id] = [
            EvidencePhoto(
                id=uuid.uuid4(),
                object_key=f"evidence/{fpo.id}/2025/{events[3][0].id}/{uuid.uuid4()}.jpg",
                sha256_client="ab" * 32,
                status=PhotoStatus.VERIFIED,
                variants={
                    "thumb_url": f"http://localhost:4566/evidence/evidence/{fpo.id}/2025/x/p.thumb.webp",
                    "medium_url": f"http://localhost:4566/evidence/evidence/{fpo.id}/2025/x/p.medium.webp",
                    "jpeg_url": f"http://localhost:4566/evidence/evidence/{fpo.id}/2025/x/p.jpg",
                    "width": 480,
                    "height": 360,
                },
            )
        ]
        lots.append(
            builder.LotRows(
                lot=lot,
                share=BatchShare(
                    batch_id=batch.id,
                    lot_id=lot.id,
                    farmer_id=farmer.id,
                    kg_contributed=Decimal(kgs),
                    share_pct=Decimal(pct),
                ),
                farmer=farmer,
                plot=plot,
                village=village,
                name_consent=consent,
                intake=LotIntake(lot_id=lot.id, sale_date=date(2026, 5, 2), received_kg=Decimal(kgs)),
                events=events,
            )
        )
    return builder.BatchRows(
        batch=batch,
        fpo=fpo,
        crop=crop,
        gi_tag=gi,
        processor=processor,
        grade=grade,
        profile=profile,
        graded_on=date(2026, 7, 30),
        lots=lots,
        photos=photos,
        inputs={},
    )


def _build(rows: builder.BatchRows) -> tuple[str, dict[str, Any]]:
    """Assemble and render the rows as build 3.

    Args:
        rows: batch rows.

    Returns:
        `(index.html, parsed data.json)`.
    """
    build = PageBuild(
        batch_id=rows.batch.id, build_no=3, generation=3, snapshot={}, status="queued", trigger="rebuild"
    )
    page = render(builder.assemble(rows, build, NOW))
    return page.html, json.loads(page.data_json)


def test_built_page_passes_privacy_lint(tmp_path: Path) -> None:
    """A built page and data.json pass infra/scripts/privacy-lint.py (BM-09) and leak no internal value."""
    html, data = _build(_rows())
    folder = tmp_path / "batches" / CODE
    folder.mkdir(parents=True)
    (folder / "index.html").write_text(html, encoding="utf-8")
    (folder / "data.json").write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    result = subprocess.run(  # noqa: S603
        [sys.executable, str(LINT), str(tmp_path), "--canary", "Selvi Example", "--canary", "626129"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    for text in (html, json.dumps(data)):
        assert "temp_uploads" not in text and "123/4A" not in text and "/evidence/evidence/" not in text
    assert data["footer"]["generation"] == "3" and data["footer"]["page_version"] == 3


@pytest.mark.parametrize(
    ("village", "rule"),
    [
        ("Kumarapuram R.S. No. 112/3", "sensitive_label"),
        ("Kumarapuram புல எண் 123/4", "sensitive_label"),
        ("Kumarapuram 98765.43210", "phone"),
        ("Kumarapuram 9.559806 78.133521", "coordinate_precision"),
    ],
)
def test_privacy_hits_refuse_free_text_leaks(village: str, rule: str) -> None:
    """The clean page has no hit; a leak typed into the free-text village is found in both files (B18).

    These four formats pass the renderer's own schema check, so only the linter stops them.

    Args:
        village: the processor's free-text village (no directory village, `builder._place`).
        rule: the linter rule that must fire.
    """
    rows = _rows()
    build = PageBuild(batch_id=rows.batch.id, build_no=1, generation=1, snapshot={}, status="queued")
    assert builder.privacy_hits(render(builder.assemble(rows, build, NOW))) == []
    rows.processor.address = {**(rows.processor.address or {}), "village": village}
    hits = builder.privacy_hits(render(builder.assemble(rows, build, NOW)))
    assert {h["loc"][0] for h in hits if h["type"] == rule} == {"index.html", "data.json"}
    assert village.split(" ", 1)[1] not in json.dumps(hits, ensure_ascii=False)


def test_revoked_name_consent_shows_farmer_2() -> None:
    """Lot 2 in code order has no unrevoked `public_name` consent: "Farmer 2", null in data.json."""
    html, data = _build(_rows())
    assert [lot["lot_code"] for lot in data["lots"]] == ["LOT0EF81415", "LOT3072CB6A", "LOTD02DADB6"]
    assert [lot["farmer_name"] for lot in data["lots"]] == ["Murugan Example", None, "Kannan Example"]
    assert "Farmer 2" in html and "Selvi Example" not in html


def test_fpo_switch_off_hides_every_name() -> None:
    """With `public_show_farmer_names` off no name is published, consent or not."""
    html, data = _build(_rows(names_on=False))
    assert all(lot["farmer_name"] is None for lot in data["lots"])
    assert "Kannan Example" not in html and "Farmer 3" in html


def test_events_ascending_with_counts() -> None:
    """Events are date-ascending, same-day events in stage order, intake last; counts are per lot (FR63)."""
    _, data = _build(_rows())
    lot = data["lots"][0]
    assert [(e["date"], e["stage"]) for e in lot["events"]] == [
        ("2025-08-24", "land_preparation"),
        ("2025-11-11", "sowing"),
        ("2026-02-15", "harvest"),
        ("2026-02-15", "drying"),
        ("2026-03-12", "farm_packing"),
        ("2026-05-02", "sale_to_processor"),
    ]
    assert lot["event_count"] == 6 and data["farming_event_count"] == 18
    assert [e["stage"] for e in data["processing_events"]] == ["grading", "processing_packing"]


def test_tenant_rules_hide_partner_fields() -> None:
    """Default YAML: farm quantities are `partner`; seed variety, final pack weight are `public` (D-034)."""
    _, data = _build(_rows())
    events = {e["stage"]: e for e in data["lots"][0]["events"]}
    assert events["harvest"]["quantity"] is None and events["farm_packing"]["quantity"] is None
    assert events["sowing"]["seed_variety"] == "K2"
    assert data["processing_events"][1]["quantity"] == {"value": 20.0, "unit": "kg"}


def test_header_grade_compliance_and_location() -> None:
    """Header quantities, GI, FSSAI and GI-user numbers (FR62), grade (FR51), 3 dp pin, FR72 method."""
    _, data = _build(_rows())
    assert data["total_quantity"] == {"value": 20.0, "unit": "kg"}
    assert data["procured_quantity"] == {"value": 320.0, "unit": "kg"}
    assert data["gi_verified"] is True and data["gi_tag_number"] == "883"
    assert data["processor"]["fssai_licence_no"] == "DEMO-FSSAI-0001"
    assert data["processor"]["place"]["village"] == "P Thottiyangulam" and "626129" not in json.dumps(data)
    assert data["grade"]["readings"] == [
        {"parameter": "Moisture", "value": 10.4, "unit": "%", "source": "instrument"}
    ]
    assert data["grade"]["lab_certified"] is False
    assert [lot["share_pct"] for lot in data["lots"]] == [6.25, 62.5, 31.25]
    walked = data["lots"][1]
    assert walked["location_method"] == "boundary_walked"
    assert walked["review_note"] == "Reviewed by field visit on 4 Mar 2026"
    assert walked["map_link"] == "https://www.google.com/maps?q=9.536,78.202"


def test_photos_use_public_webp_copies() -> None:
    """Photos use content-addressed WebP copies; the original JPEG and raw key never appear (D-034)."""
    rows = _rows()
    _, data = _build(rows)
    photo = next(e for e in data["lots"][0]["events"] if e["stage"] == "sowing")["photos"][0]
    digest = "ab" * 8
    assert photo["thumb_url"] == f"{BASE}/batches/{CODE}/evidence/{digest}.thumb.webp"
    assert photo["jpeg_url"] == photo["medium_url"] == f"{BASE}/batches/{CODE}/evidence/{digest}.medium.webp"
    source = next(iter(rows.photos.values()))[0]
    assert builder.photo_copies(source, CODE)[0] == (
        source.variants["thumb_url"].split("/evidence/", 1)[1],
        f"batches/{CODE}/evidence/{digest}.thumb.webp",
    )


def test_missing_farming_type_is_refused_with_its_path() -> None:
    """A required public field left empty fails validation naming the path, so the build is marked failed."""
    rows = _rows()
    rows.lots[0].plot.farming_type = None
    with pytest.raises(ValidationError) as caught:
        _build(rows)
    assert any(e["loc"][-1] == "farming_type" for e in caught.value.errors())


def test_qr_decodes_to_public_url() -> None:
    """The QR PNG decodes to `{PUBLIC_BASE_URL}/b/<code>` (FR12)."""
    png = service.qr_png(service.public_url(CODE))
    decoded = zxingcpp.read_barcodes(Image.open(BytesIO(png)))
    assert [r.text for r in decoded] == [f"{BASE}/b/{CODE}"]


def test_label_sheet_is_a_pdf_with_the_qr() -> None:
    """The label sheet is a one-page PDF."""
    pdf = service.labels_pdf(["Virudhunagar Samba Vathal", f"Batch {CODE}"], service.public_url(CODE))
    assert pdf.startswith(b"%PDF") and pdf.count(b"/Type /Page\n") + pdf.count(b"/Type /Page ") >= 1


async def test_build_checks_supersession_under_the_batch_lock() -> None:
    """build_page locks the batch row, re-reads the build, and skips a build older than the batch's latest."""
    batch = Batch(id=uuid.uuid4(), current_build_no=2)
    build = PageBuild(
        id=uuid.uuid4(),
        batch_id=batch.id,
        build_no=1,
        generation=1,
        snapshot={},
        status="queued",
        trigger="publish",
    )
    calls: list[Any] = []

    class FakeSession:
        """Records the calls build_page makes; holds one build and its batch."""

        async def get(self, model: type, key: uuid.UUID, **options: Any) -> Any:
            """Return the build or the batch.

            Args:
                model: ORM class.
                key: primary key.
                **options: lock options.

            Returns:
                The row.
            """
            calls.append((model, options))
            return build if model is PageBuild else batch

        async def refresh(self, row: Any) -> None:
            """Record a refresh.

            Args:
                row: the refreshed row.
            """
            calls.append(("refresh", row))

        async def commit(self) -> None:
            """Record a commit."""
            calls.append("commit")

    out = await service.build_page(FakeSession(), build.id)  # type: ignore[arg-type]
    assert out is build and build.status == "superseded"
    lock = (Batch, {"with_for_update": True, "populate_existing": True})
    assert calls.index(lock) < calls.index(("refresh", build)) < calls.index("commit")
