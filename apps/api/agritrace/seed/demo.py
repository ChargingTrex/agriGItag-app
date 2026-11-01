"""Demo seed: the pilot FPO and the PRD §12 reference batch `FGP8T4033HM7`, with its known problems.

Writes FPO `VIRUDHAI_SCFC_VINOBA_BHAVA_FPO` and its processor, GI 883 with the non-official fixture region
(buffer 150 m), the crop and its AGMARK profile, 5 organic/bio inputs, 1 admin, 1 field officer, 1 QC
officer, 3 farmers with consents and plots, lots `LOTD02DADB6` (packed 69 kg, used 100 kg), `LOT3072CB6A`
(140 / 200 kg; nursery 2025-09-05 before ploughing 2025-09-30), `LOT0EF81415` (77.6 + 195 / 20 kg), all
declared Inorganic + IPM, then batch `FGP8T4033HM7` (super-lot `COMBO_LOT_6C1DCCFE`, 320 kg procured) graded
"A", 20 kg on 2026-07-30 without readings. The rules then raise exactly `EXPECTED_FLAGS`.

Serves: backend-design §5, PRD §12.1–§12.2, FR9–FR11, FR29, FR56, FR57, FR60, Architect-Gate rulings
2026-10-31 §1–§2 (D-030), D-019 (region provenance), D-048 (how the seed writes).
Callers: `make seed` (`python -m agritrace.seed.demo` in the api container), tests/e2e/test_reference_batch.py
(`seed`), tests/unit/test_seed_demo.py (the reference data and `EXPECTED_FLAGS`).
"""

import asyncio
import json
import uuid
from dataclasses import dataclass, field
from datetime import UTC, date, datetime, time
from decimal import Decimal
from pathlib import Path
from typing import Any

from geoalchemy2 import WKTElement
from shapely.geometry import shape
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.auth import CurrentUser
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import (
    ChangeKind,
    ConsentType,
    EventSubject,
    EventType,
    FarmerStatus,
    FarmingType,
    InputCategory,
    IrrigationSource,
    LocationStatus,
    LotStatus,
    OrgKind,
    PinMethod,
    Role,
)
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.identity.models import ConsentRecord, Membership, User
from agritrace.modules.lots_batches import service as lots_service
from agritrace.modules.lots_batches.models import Batch, Lot, LotIntake
from agritrace.modules.lots_batches.schemas import BatchIn
from agritrace.modules.quality.profiles.loader import load_profile
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
from agritrace.modules.rules_flags import service as rules_service

FPO_CODE = "VIRUDHAI_SCFC_VINOBA_BHAVA_FPO"
BATCH_CODE = "FGP8T4033HM7"
SUPERLOT_CODE = "COMBO_LOT_6C1DCCFE"
# Fixed client id: `create_batch` is idempotent on it (D-005), and tests find the batch by it.
BATCH_ID = uuid.UUID("01900000-0000-7000-8000-0000000b12aa")
GRADED_KG = Decimal(20)
GRADED_ON = date(2026, 7, 30)
REGION_FILE = Path(__file__).parent / "fixtures" / "gi_region_fixture.geojson"
ADDRESS = {"block": "Tiruchuli", "district": "Virudhunagar", "state": "Tamil Nadu"}
# Same tracks as tests/fixtures/rule_cases.json: nursery and main field are separate (FR55, PRD §12.2).
EVENT_SCHEMA = {
    "mandatory": ["land_preparation", "nursery", "sowing", "harvest", "drying", "packing"],
    "tracks": {
        "nursery": ["nursery", "sowing"],
        "main_field": ["land_preparation", "sowing", "harvest", "drying", "packing"],
    },
}
# name_en → (name_local, manufacturer, category, unit). Local names only where the reference page shows one.
INPUTS: dict[str, tuple[str | None, str | None, InputCategory, str]] = {
    "Organic Fertilizer Gold": ("கரிம உரத் தங்கம்", "Amul", InputCategory.ORGANIC_FERTILIZER, "kg"),
    "Panjakavya": (None, None, InputCategory.ORGANIC_FERTILIZER, "l"),
    "Azospirillum": (None, None, InputCategory.BIO_FERTILIZER, "kg"),
    "Phospho Bacteria": (None, None, InputCategory.BIO_FERTILIZER, "kg"),
    "Effective Micro Organism": (None, None, InputCategory.BIO_FERTILIZER, "l"),
}
# The rule codes the reference batch raises after seeding, with their counts (backend-design §5, D-030).
EXPECTED_FLAGS = {
    "quantity_mismatch": 3,
    "practice_tag_contradiction": 3,
    "ipm_without_pest_event": 3,
    "yield_check_unavailable": 3,
    "grading_loss_high": 1,
}
# Must not appear: nursery before ploughing is normal (FR55); shares 320 kg = received 320 kg.
ABSENT_FLAGS = ("event_out_of_order", "batch_quantity_unattributed")


@dataclass(frozen=True)
class Step:
    """One farm event of a reference lot."""

    type: EventType
    on: date
    payload: dict[str, Any] = field(default_factory=dict)
    end: date | None = None
    input: str | None = None  # key of INPUTS for input applications


@dataclass(frozen=True)
class LotSeed:
    """One reference lot with its farmer, plot, events and intake (PRD §12.1)."""

    code: str
    farmer: str
    phone: str
    pin: tuple[float, float]  # lat, lon
    acres: Decimal
    received_kg: Decimal
    steps: tuple[Step, ...]


def _kg(value: str) -> dict[str, Any]:
    """Build a kg quantity payload.

    Args:
        value: kilograms as text.

    Returns:
        `{"value": value, "unit": "kg"}` (FR58).
    """
    return {"value": value, "unit": "kg"}


def _d(text: str) -> date:
    """Parse an ISO date.

    Args:
        text: YYYY-MM-DD.

    Returns:
        The date.
    """
    return date.fromisoformat(text)


# No harvest quantity anywhere (PRD §12.2) → `yield_check_unavailable` on every lot (ruling §2).
LOTS = (
    LotSeed(
        "LOTD02DADB6",
        "muthu murugan",
        "+919000000011",
        (9.559806, 78.133521),
        Decimal("0.5"),
        Decimal(100),
        (
            Step(
                EventType.LAND_PREPARATION,
                _d("2025-08-24"),
                {"cultivated_area": {"value": "0.5", "unit": "acre"}, "last_ploughed_on": "2025-08-24"},
            ),
            Step(EventType.NURSERY, _d("2025-09-19"), {"seed_variety": "K2"}),
            Step(EventType.SOWING, _d("2025-11-11"), {"seed_variety": "K2", "method": "transplanting"}),
            Step(
                EventType.INPUT_APPLICATION,
                _d("2025-12-05"),
                {"quantity": _kg("25")},
                None,
                "Organic Fertilizer Gold",
            ),
            Step(EventType.HARVEST, _d("2026-02-14")),
            Step(EventType.DRYING, _d("2026-02-15"), {}, _d("2026-02-21")),
            Step(EventType.PACKING, _d("2026-03-12"), {"quantity": _kg("69")}),
        ),
    ),
    LotSeed(
        "LOT3072CB6A",
        "Selvi Ramasamy",
        "+919000000012",
        (9.5655, 78.1402),
        Decimal(1),
        Decimal(200),
        (
            Step(EventType.NURSERY, _d("2025-09-05"), {"seed_variety": "K2"}),
            Step(EventType.LAND_PREPARATION, _d("2025-09-30"), {"last_ploughed_on": "2025-09-30"}),
            Step(EventType.SOWING, _d("2025-11-05"), {"seed_variety": "K2", "method": "transplanting"}),
            Step(
                EventType.INPUT_APPLICATION,
                _d("2025-12-10"),
                {"quantity": {"value": "10", "unit": "l"}},
                None,
                "Panjakavya",
            ),
            Step(EventType.INPUT_APPLICATION, _d("2025-12-20"), {"quantity": _kg("2")}, None, "Azospirillum"),
            Step(EventType.HARVEST, _d("2026-02-18")),
            Step(EventType.DRYING, _d("2026-02-19"), {}, _d("2026-02-25")),
            Step(EventType.PACKING, _d("2026-03-10"), {"quantity": _kg("140")}),
        ),
    ),
    LotSeed(
        "LOT0EF81415",
        "Karuppasamy P",
        "+919000000013",
        (9.5521, 78.1250),
        Decimal(1),
        Decimal(20),
        (
            Step(EventType.LAND_PREPARATION, _d("2025-08-28"), {"last_ploughed_on": "2025-08-28"}),
            Step(EventType.NURSERY, _d("2025-09-15"), {"seed_variety": "K2"}),
            Step(EventType.SOWING, _d("2025-11-08"), {"seed_variety": "K2", "method": "transplanting"}),
            Step(
                EventType.INPUT_APPLICATION,
                _d("2025-12-01"),
                {"quantity": _kg("2")},
                None,
                "Phospho Bacteria",
            ),
            Step(
                EventType.INPUT_APPLICATION,
                _d("2025-12-15"),
                {"quantity": {"value": "5", "unit": "l"}},
                None,
                "Effective Micro Organism",
            ),
            Step(EventType.HARVEST, _d("2026-02-14")),
            Step(EventType.DRYING, _d("2026-02-15"), {}, _d("2026-02-21")),
            Step(EventType.PACKING, _d("2026-02-24"), {"quantity": _kg("77.6")}),
            Step(EventType.HARVEST, _d("2026-03-04")),
            Step(EventType.DRYING, _d("2026-03-05"), {}, _d("2026-03-11")),
            Step(EventType.PACKING, _d("2026-03-14"), {"quantity": _kg("195")}),
        ),
    ),
)
STAFF = (
    ("Demo FPO Admin", "+919000000001", Role.FPO_ADMIN),
    ("Demo Field Officer", "+919000000002", Role.FIELD_OFFICER),
    ("Demo QC Officer", "+919000000003", Role.QC_OFFICER),
)


def _at(day: date) -> datetime:
    """Return 09:00 IST (03:30 UTC) on a day, the capture time of the historic entries.

    Args:
        day: the day.

    Returns:
        An aware UTC datetime.
    """
    return datetime.combine(day, time(3, 30), UTC)


def packed_kg(lot: LotSeed) -> Decimal:
    """Sum a reference lot's on-farm packing quantities.

    Args:
        lot: the reference lot.

    Returns:
        Kilograms packed (69, 140, 272.6).
    """
    return sum(
        (Decimal(s.payload["quantity"]["value"]) for s in lot.steps if s.type == EventType.PACKING),
        Decimal(0),
    )


async def _gi_crop(session: AsyncSession) -> Crop:
    """Get or create GI 883, its fixture region version 1 and the crop, then publish the crop's profile.

    Args:
        session: database session (committed here).

    Returns:
        The crop.

    Raises:
        FileNotFoundError: the fixture region or the profile file is missing.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts the rows that are missing and commits; `load_profile` publishes version 1 once.
    """
    tag = await session.scalar(select(GiTag).where(GiTag.gi_number == "883"))
    if tag is None:
        tag = GiTag(gi_number="883", name="Virudhunagar Samba Vathal", name_local="விருதுநகர் சம்பா வத்தல்")
        session.add(tag)
        await session.flush()
    if await session.scalar(select(GiRegionVersion.id).where(GiRegionVersion.gi_tag_id == tag.id)) is None:
        feature = json.loads(REGION_FILE.read_text())["features"][0]
        props = feature["properties"]
        session.add(
            GiRegionVersion(
                gi_tag_id=tag.id,
                version_no=1,
                geom=WKTElement(shape(feature["geometry"]).wkt, srid=4326),
                tolerance_buffer_m=Decimal(props["tolerance_buffer_m"]),
                taluks=props["taluks"],
                # The label says NON-OFFICIAL; real outlines: build_virudhunagar.py + POST region-versions.
                source_ref=props["label"],
                licence=props["licence"],
                confidence=props["confidence"],
                effective_from=date(2020, 1, 1),
            )
        )
    crop = await session.scalar(select(Crop).where(Crop.gi_tag_id == tag.id))
    if crop is None:
        crop = Crop(
            code="SAMBA_VATHAL",
            name_en="VIRUDHUNAGAR SAMBA VATHAL",
            name_local="விருதுநகர் சம்பா வத்தல்",
            gi_tag_id=tag.id,
            event_schema=EVENT_SCHEMA,
        )
        session.add(crop)
    await session.commit()
    await load_profile(session, crop.id)
    return crop


async def seed(session: AsyncSession) -> bool:
    """Write the demo FPO and the reference batch once; a second run changes nothing.

    Args:
        session: database session (committed here).

    Returns:
        True when the data was written, False when the reference batch (`BATCH_ID`) already existed.

    Raises:
        AppError: from `create_batch` (e.g. `gate_not_met`) if the reference data no longer fits the gates.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts every row listed in the module header (audit rows, system actor, for audited models:
        events yes, event_versions no), runs the lot and batch rules (flags, practice tags) and commits at
        the end. `_gi_crop` commits the GI/crop/profile rows first (get-or-create). An FPO with this code
        that exists without the batch (e.g. made by an admin or a test) is reused and given the reference
        values. If `create_batch` refuses a gate it commits the history first (`_refuse`); recover by
        deleting the FPO's rows before re-running.
    """
    # The batch is the last row written, so its presence means fully seeded (an FPO alone does not).
    if await session.get(Batch, BATCH_ID) is not None:
        return False
    crop = await _gi_crop(session)
    # DECISION D-048: history is written by direct model inserts; only the batch goes through `create_batch`.
    #   ADV: the PRD §12 record is reproduced as it was captured (no readings, no ready gate, past dates,
    #     grade "A" that the API now refuses); the batch, its shares and flags come from the real code.
    #   COMPROMISE: the inserts skip the API's validation, so tests/unit/test_seed_demo.py re-checks the
    #     data against the rules and the e2e test runs the gates on it; reference codes are set afterwards.
    office = {"village": "P Thottiyangulam", **ADDRESS}
    fpo = await session.scalar(select(Fpo).where(Fpo.code == FPO_CODE)) or Fpo(code=FPO_CODE)
    fpo.name, fpo.kind, fpo.address = FPO_CODE, OrgKind.FPO, office
    fpo.fssai_no, fpo.gi_authorised_user_no = "DEMO-FSSAI-12426999000001", "DEMO-GI-AU-883-0001"
    fpo.public_show_farmer_names = True
    staff = [User(phone=phone, name=name, lang="en") for name, phone, _ in STAFF]
    session.add_all([fpo, *staff])
    await session.flush()
    admin, officer, qc = staff
    processor = Processor(
        fpo_id=fpo.id,
        name=FPO_CODE,
        kind=OrgKind.FPO,
        address=office,
        fssai_no=fpo.fssai_no,
        gi_authorised_user_no=fpo.gi_authorised_user_no,
    )
    inputs = {
        name: InputMaster(
            fpo_id=fpo.id, name_en=name, name_local=local, manufacturer=maker, category=cat, unit=unit
        )
        for name, (local, maker, cat, unit) in INPUTS.items()
    }
    session.add_all([processor, *inputs.values()])
    session.add_all(
        Membership(fpo_id=fpo.id, user_id=u.id, role=r) for u, (_, _, r) in zip(staff, STAFF, strict=True)
    )
    farmer_users = [User(phone=lot.phone, name=lot.farmer) for lot in LOTS]
    session.add_all(farmer_users)
    await session.flush()
    lots: list[Lot] = []
    for n, (ref, user) in enumerate(zip(LOTS, farmer_users, strict=True), start=1):
        lots.append(await _lot(session, fpo, crop, admin, officer, processor, inputs, ref, user, n))
    await session.flush()
    batch, _, _ = await lots_service.create_batch(
        session,
        CurrentUser(user_id=admin.id, fpo_id=fpo.id, role=Role.FPO_ADMIN),
        BatchIn(
            client_id=BATCH_ID,
            processor_id=processor.id,
            gi_label_requested=True,
            lot_ids=[lot.id for lot in lots],
        ),
    )
    await _legacy_grading(session, fpo, batch, qc)
    await rules_service.run_gate_checks(session, batch_id=batch.id)
    await session.commit()
    return True


async def _lot(
    session: AsyncSession,
    fpo: Fpo,
    crop: Crop,
    admin: User,
    officer: User,
    processor: Processor,
    inputs: dict[str, InputMaster],
    ref: LotSeed,
    user: User,
    n: int,
) -> Lot:
    """Insert one farmer with membership, consents and plot, then the lot, its events and its intake.

    Args:
        session: database session (flushed, not committed).
        fpo: the demo FPO.
        crop: the GI crop.
        admin: approves the farmer and accepts the intake.
        officer: witnesses the consents.
        processor: receives the lot.
        inputs: input master rows by English name.
        ref: the reference lot.
        user: the farmer's user account.
        n: farmer number (code `F00000n`).

    Returns:
        The lot, status `received`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts farmers, memberships, consent_records, plots, lots, events, event_versions, lot_intakes.
    """
    farmer = Farmer(
        fpo_id=fpo.id,
        user_id=user.id,
        code=f"F{n:06X}",  # API format: F + 6 upper-case hex
        name=ref.farmer,
        address={"village": "PM Pudhupatti", **ADDRESS},
        gi_authorised_user_no=f"DEMO-GI-AU-883-01{n:02d}",
        status=FarmerStatus.ACTIVE,
        approved_by=admin.id,
        approved_at=_at(date(2025, 8, 1)),
    )
    session.add_all([farmer, Membership(fpo_id=fpo.id, user_id=user.id, role=Role.FARMER)])
    await session.flush()
    session.add_all(
        ConsentRecord(
            id=uuid7(),
            farmer_id=farmer.id,
            consent_type=kind,
            consent_version="v1-ta",
            witnessed_by_user_id=officer.id,
            given_at=_at(date(2025, 8, 1)),
        )
        for kind in (ConsentType.DATA_COLLECTION, ConsentType.PUBLIC_NAME)
    )
    plot = Plot(
        id=uuid7(),
        fpo_id=fpo.id,
        farmer_id=farmer.id,
        code="P-01",
        gi_tag_id=crop.gi_tag_id,
        pin=WKTElement(f"POINT({ref.pin[1]} {ref.pin[0]})", srid=4326),
        pin_accuracy_m=5.0,
        pin_method=PinMethod.LIVE_GPS,
        pin_device_time=_at(date(2025, 8, 1)),
        pin_server_received_at=_at(date(2025, 8, 1)),
        declared_area_acres=ref.acres,
        farming_type=FarmingType.IRRIGATED,
        irrigation_source=IrrigationSource.WELL,
        location_status=LocationStatus.CONFIRMED,
    )
    session.add(plot)
    await session.flush()
    lot = Lot(
        fpo_id=fpo.id,
        farmer_id=farmer.id,
        plot_id=plot.id,
        crop_id=crop.id,
        season_label="2025-26",
        code=ref.code,
        status=LotStatus.RECEIVED,
        practice_tags={"declared": ["inorganic", "ipm"], "derived": [], "contradiction": False},
        packed_kg=packed_kg(ref),
        # Same start as lots_batches.service.create_lot: eligible until a hold flag says otherwise (FR29).
        gi_eligible=True,
    )
    session.add(lot)
    await session.flush()
    instances: dict[EventType, int] = {}
    for step in ref.steps:
        instances[step.type] = instances.get(step.type, 0) + 1
        payload = {**step.payload, **({"input_id": str(inputs[step.input].id)} if step.input else {})}
        await _event(
            session,
            fpo,
            user,
            step.type,
            step.on,
            payload,
            lot=lot,
            end=step.end,
            instance=instances[step.type],
        )
    session.add(
        LotIntake(
            id=uuid7(),
            fpo_id=fpo.id,
            lot_id=lot.id,
            processor_id=processor.id,
            sale_date=date(2026, 5, 2),
            received_kg=ref.received_kg,
            accepted_by_user_id=admin.id,
            reconciliation=lots_service.reconcile(None, lot.packed_kg, ref.received_kg).model_dump(
                mode="json"
            ),
        )
    )
    return lot


async def _event(
    session: AsyncSession,
    fpo: Fpo,
    user: User,
    kind: EventType,
    on: date,
    payload: dict[str, Any],
    *,
    lot: Lot | None = None,
    batch: Batch | None = None,
    end: date | None = None,
    instance: int = 1,
) -> None:
    """Add a submitted event with its version 1 (append-only, D-014) on a lot or a batch.

    Args:
        session: database session.
        fpo: the FPO.
        user: who entered it.
        kind: event type.
        on: the day it happened.
        payload: version payload (quantities with units).
        lot: the lot, for farm events.
        batch: the batch, for processing events.
        end: end day of a span (drying).
        instance: instance number of this type on the subject.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Inserts the event and its version and points the event at the version; flushes.
    """
    event = Event(
        id=uuid7(),
        fpo_id=fpo.id,
        subject_type=EventSubject.LOT if lot else EventSubject.BATCH,
        lot_id=lot.id if lot else None,
        batch_id=batch.id if batch else None,
        plot_id=lot.plot_id if lot else None,
        event_type=kind,
        instance_no=instance,
        occurred_on=on,
    )
    version = EventVersion(
        id=uuid7(),
        event_id=event.id,
        version_no=1,
        payload=payload,
        occurred_on=on,
        occurred_end_on=end,
        device_time=_at(on),
        server_received_at=_at(on),
        entered_by_user_id=user.id,
        change_kind=ChangeKind.CREATE,
    )
    session.add_all([event, version])
    await session.flush()  # the event and the version reference each other: insert both, then link
    event.current_version_id = version.id


async def _legacy_grading(session: AsyncSession, fpo: Fpo, batch: Batch, qc: User) -> None:
    """Record the reference page's grading: grade "A", 20 kg on 2026-07-30, no readings (PRD §12.1).

    Args:
        session: database session (flushed, not committed).
        fpo: the demo FPO.
        batch: the reference batch, just created.
        qc: the QC officer who entered it.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        Sets the reference batch and super-lot codes and `graded_kg` (status stays `created`: no grade
        computation exists, so the grading gate is still closed); adds the grading event; flushes.
    """
    batch.code, batch.superlot_code, batch.graded_kg = BATCH_CODE, SUPERLOT_CODE, GRADED_KG
    await _event(
        session,
        fpo,
        qc,
        EventType.GRADING,
        GRADED_ON,
        {"declared_grade": "A", "quantity": _kg("20")},
        batch=batch,
    )
    await session.flush()


async def main() -> None:
    """Seed the database named by the settings and print what happened.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: database unreachable or not migrated.

    Side effects:
        As `seed`; prints one line.
    """
    async with get_sessionmaker()() as session:
        written = await seed(session)
    print(f"seed: {'wrote' if written else 'already present:'} {FPO_CODE}, batch {BATCH_CODE}")  # noqa: T201


if __name__ == "__main__":
    asyncio.run(main())
