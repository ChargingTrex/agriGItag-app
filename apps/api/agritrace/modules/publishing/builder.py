"""Public page snapshot: turn a batch's rows into the record `agritrace_page.render` accepts.

Purpose: `load` reads everything one public batch page shows; `assemble` (pure) maps it onto W01's
`PublicBatchRecord` allow-list: header and GI indicator, FSSAI and GI authorised-user numbers, lots with
consent-aware farmer names, share %, 3 dp map pin, events in date order, grade with standard edition, readings
and lab badge, location method and the generation stamp. `privacy_hits` lints the rendered page (B18).
Serves: FR15-FR18 (public page), FR51 (grade block), FR60 (shares), FR62 (compliance numbers, pack and
best-before dates), FR63 (events in date order with counts), FR72 (location method), PRD §12.1 (field
inventory), plan §13 E2 (WebP variants), CLAUDE.md §6 (privacy), D-007, D-017, D-034.
Callers: `publishing.service.build_page`; tests/unit/test_publishing_builder.py.
"""

import uuid
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from agritrace_page import RenderResult, privacy_lint
from geoalchemy2.shape import to_shape
from shapely.geometry import Point
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.config import get_settings
from agritrace.core.enums import ApprovalStage, ConsentType, EventStatus, EventType, PhotoStatus
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.identity.models import ConsentRecord
from agritrace.modules.lots_batches.models import (
    Batch,
    BatchApproval,
    BatchShare,
    Lot,
    LotIntake,
    current_intake,
)
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.quality.models import GradeComputation, StandardsProfileVersion
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiTag, InputMaster, Plot, Processor, Village

# Internal event type -> public page stage. Problem reports stay internal; intake, grading and final packing
# come from the intake and batch rows (one source each), not from events.
STAGES = {
    EventType.LAND_PREPARATION: "land_preparation",
    EventType.NURSERY: "nursery_preparation",
    EventType.SOWING: "sowing",
    EventType.INPUT_APPLICATION: "input_application",
    EventType.HARVEST: "harvest",
    EventType.DRYING: "drying",
    EventType.PACKING: "farm_packing",
}
# Stage order of the page; same-day events are sent in this order (W01 cross-package expectation).
STAGE_ORDER = (*STAGES.values(), "sale_to_processor", "grading", "processing_packing")
QUANTITY_FIELDS = ("quantity", "cultivated_area", "sown_area", "received")
LIVE = (EventStatus.SUBMITTED, EventStatus.LOCKED)
PAGE_IRRIGATION = {"well", "borewell", "canal", "tank"}  # "rain" is shown as rainfed with no source
ORG_KIND = {"fpo": "FPO", "company": "Company", "coop": "Co-operative"}
REVIEW_METHODS = {
    "land_record": "land record check",
    "satellite": "satellite image",
    "field_visit": "field visit",
}
# YAML fields behind the W01 schema's required page fields, by entity (D-034 ruling): farm area, farming type
# and the grade readings. They stay `public` and enabled for every tenant; `agritrace.main` passes this to
# `fieldconfig.check_page_required` at start-up (core cannot import a module, D-004).
PAGE_REQUIRED_FIELDS: dict[str, tuple[str, ...]] = {
    "plot": ("declared_area", "farming_type"),
    "quality_reading": ("parameter_code", "measurement", "source"),
}


@dataclass
class LotRows:
    """One component lot and the rows its public block is built from.

    Attributes:
        lot: the lot.
        share: its share of the batch (kg and %).
        farmer: the grower.
        plot: the plot harvested.
        village: the farmer's village from the directory, if picked.
        name_consent: the farmer has a `public_name` consent that is not revoked.
        intake: the lot's current intake (sale to processor), if any.
        events: live farm events with their current versions.
    """

    lot: Lot
    share: BatchShare
    farmer: Farmer
    plot: Plot
    village: Village | None
    name_consent: bool
    intake: LotIntake | None
    events: list[tuple[Event, EventVersion]]


@dataclass
class BatchRows:
    """Everything `assemble` reads for one batch, loaded by `load`.

    Attributes:
        batch: the batch.
        fpo: the owning FPO (name display switch, fallback compliance numbers, tenant field rules).
        crop: the crop (product names).
        gi_tag: the crop's GI tag, if any.
        processor: the processor that graded and packed it.
        grade: the latest grade computation, if any.
        profile: the standards profile version of that computation.
        graded_on: date of the grading approval, if any.
        lots: the component lots.
        photos: verified evidence photos with WebP variants, by event version id.
        inputs: input master rows used by input events, by id.
    """

    batch: Batch
    fpo: Fpo
    crop: Crop
    gi_tag: GiTag | None
    processor: Processor
    grade: GradeComputation | None
    profile: StandardsProfileVersion | None
    graded_on: date | None
    lots: list[LotRows]
    photos: dict[uuid.UUID, list[EvidencePhoto]]
    inputs: dict[uuid.UUID, InputMaster]


async def load(session: AsyncSession, batch: Batch) -> BatchRows:
    """Read the rows of one batch's public page.

    Args:
        session: database session.
        batch: the batch.

    Returns:
        The rows; lots in batch-share order (`assemble` sorts them by lot code).

    Raises:
        LookupError: the FPO, crop or processor row is missing (broken foreign keys only).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """

    async def need[T](model: type[T], key: uuid.UUID) -> T:
        """Load a row that a foreign key guarantees.

        Args:
            model: ORM class.
            key: primary key.

        Returns:
            The row.

        Raises:
            LookupError: no such row.
        """
        row = await session.get(model, key)
        if row is None:
            raise LookupError(f"{model.__name__} {key}")
        return row

    crop = await need(Crop, batch.crop_id)
    grade = await session.scalar(
        select(GradeComputation)
        .where(GradeComputation.batch_id == batch.id)
        .order_by(GradeComputation.computed_at.desc())
        .limit(1)
    )
    approved_at = await session.scalar(
        select(BatchApproval.approved_at)
        .where(BatchApproval.batch_id == batch.id, BatchApproval.stage == ApprovalStage.GRADING)
        .order_by(BatchApproval.approved_at.desc())
        .limit(1)
    )
    lots = []
    for share in (await session.scalars(select(BatchShare).where(BatchShare.batch_id == batch.id))).all():
        lot = await need(Lot, share.lot_id)
        farmer = await need(Farmer, share.farmer_id)
        consent = await session.scalar(
            select(ConsentRecord.id).where(
                ConsentRecord.farmer_id == farmer.id,
                ConsentRecord.consent_type == ConsentType.PUBLIC_NAME,
                ConsentRecord.revoked_at.is_(None),
            )
        )
        events = (
            await session.execute(
                select(Event, EventVersion)
                .join(EventVersion, EventVersion.id == Event.current_version_id)
                .where(Event.lot_id == lot.id, Event.status.in_(LIVE), Event.event_type.in_(list(STAGES)))
            )
        ).tuples()
        lots.append(
            LotRows(
                lot=lot,
                share=share,
                farmer=farmer,
                plot=await need(Plot, lot.plot_id),
                village=await session.get(Village, farmer.village_id) if farmer.village_id else None,
                name_consent=consent is not None,
                intake=await session.scalar(
                    select(LotIntake).where(LotIntake.lot_id == lot.id, current_intake()).limit(1)
                ),
                events=list(events),
            )
        )
    versions = [v.id for rows in lots for _, v in rows.events]
    photos: dict[uuid.UUID, list[EvidencePhoto]] = {}
    for photo in (
        await session.scalars(
            select(EvidencePhoto)
            .where(
                EvidencePhoto.event_version_id.in_(versions),
                EvidencePhoto.status == PhotoStatus.VERIFIED,
                EvidencePhoto.variants.is_not(None),
            )
            .order_by(EvidencePhoto.id)
        )
    ).all():
        photos.setdefault(photo.event_version_id, []).append(photo)  # type: ignore[arg-type]  # filtered
    input_ids = {
        uuid.UUID(str(v.payload["input_id"]))
        for rows in lots
        for _, v in rows.events
        if v.payload.get("input_id")
    }
    inputs = (
        {i.id: i for i in (await session.scalars(select(InputMaster).where(InputMaster.id.in_(input_ids))))}
        if input_ids
        else {}
    )
    return BatchRows(
        batch=batch,
        fpo=await need(Fpo, batch.fpo_id),
        crop=crop,
        gi_tag=await session.get(GiTag, crop.gi_tag_id) if crop.gi_tag_id else None,
        processor=await need(Processor, batch.processor_id),
        grade=grade,
        profile=await session.get(StandardsProfileVersion, grade.profile_version_id) if grade else None,
        graded_on=approved_at.date() if approved_at else None,
        lots=lots,
        photos=photos,
        inputs=inputs,
    )


def kg(value: Decimal | None) -> dict[str, Any] | None:
    """Wrap kilograms as a page quantity (FR58: never a number without its unit).

    Args:
        value: kilograms, or None.

    Returns:
        `{value, unit: "kg"}`, or None.
    """
    return None if value is None else {"value": float(value), "unit": "kg"}


def photo_copies(photo: EvidencePhoto, code: str) -> list[tuple[str, str]]:
    """Name the public copies of a photo's two WebP variants.

    Args:
        photo: a verified photo whose `variants` record holds `thumb_url` and `medium_url`.
        code: the batch code.

    Returns:
        `[(evidence key, public-pages key)]` for the thumbnail and the medium image. The public key is
        content-addressed (`batches/<code>/evidence/<sha256[:16]>.<thumb|medium>.webp`), so it never shows the
        raw evidence key (FPO and event ids) and can be cached as immutable (plan §13 E3).

    Raises:
        KeyError: the variants record lacks `thumb_url` or `medium_url`.
    """
    variants = photo.variants or {}
    marker = f"/{get_settings().s3_bucket_evidence}/"  # same split as events.evidence.signed_variants
    digest = (photo.sha256_server or photo.sha256_client)[:16]
    return [
        (variants[f"{kind}_url"].split(marker, 1)[-1], f"batches/{code}/evidence/{digest}.{kind}.webp")
        for kind in ("thumb", "medium")
    ]


def _photo(photo: EvidencePhoto, code: str, alt: str) -> dict[str, Any]:
    """Build one page photo from its public WebP copies.

    Args:
        photo: a verified photo with variants.
        code: the batch code.
        alt: text alternative.

    Returns:
        The `Photo` record.

    Raises:
        KeyError: the variants record lacks a URL, `width` or `height`.
    """
    base = get_settings().public_base_url.rstrip("/")
    (_, thumb), (_, medium) = photo_copies(photo, code)
    variants = photo.variants or {}
    # DECISION D-034: the original evidence JPEG is never published; `jpeg_url` (the <img> fallback) points at
    #   the medium WebP.
    #   ADV: the original keeps the phone's exact EXIF GPS (M04), i.e. the plot location (CLAUDE.md §6).
    #   COMPROMISE: a browser without WebP shows no photo; every supported browser has WebP.
    return {
        "thumb_url": f"{base}/{thumb}",
        "medium_url": f"{base}/{medium}",
        "jpeg_url": f"{base}/{medium}",
        "width": variants["width"],
        "height": variants["height"],
        "alt": alt,
    }


def _quantity(payload: Mapping[str, Any], public: list[str]) -> dict[str, Any] | None:
    """Pick the event's quantity when the tenant shows it publicly.

    Args:
        payload: event payload.
        public: public field names of the event entity (`fieldconfig.public_fields`).

    Returns:
        The first public quantity-like field with a unit, or None.
    """
    for name in QUANTITY_FIELDS:
        q = payload.get(name)
        if name in public and isinstance(q, dict) and q.get("unit") and q.get("value") is not None:
            return {"value": float(q["value"]), "unit": q["unit"]}
    return None


def _event(
    rows: BatchRows, event: Event, version: EventVersion, public: Mapping[str, list[str]]
) -> dict[str, Any]:
    """Map one live farm event onto the page's `Event`.

    Args:
        rows: the batch rows (photos, inputs).
        event: the event.
        version: its current version.
        public: public field names by entity.

    Returns:
        The `Event` record; only fields the tenant marks public are filled (D-034).

    Raises:
        KeyError: a photo's variants record is incomplete (from `_photo`).
    """
    stage = STAGES[event.event_type]
    fields = public.get(f"event_{event.event_type.value}", [])
    payload = version.payload
    item = rows.inputs.get(uuid.UUID(str(payload["input_id"]))) if payload.get("input_id") else None
    label = f"{stage.replace('_', ' ').capitalize()} {event.instance_no}"
    return {
        "stage": stage,
        "instance_no": event.instance_no,
        "date": version.occurred_on,
        "end_date": version.occurred_end_on,
        "quantity": _quantity(payload, fields),
        "input": (
            {
                "name_en": item.name_en,
                "name_local": item.name_local or item.name_en,
                "manufacturer": item.manufacturer,
            }
            if item and "input_id" in fields
            else None
        ),
        "seed_variety": payload.get("seed_variety") if "seed_variety" in fields else None,
        # shortcut: every live event shows as complete; an open drying range (start without end) would be
        #   in_progress (FR59). Derive it when the phone sends drying start and end as one event.
        "status": "complete",
        "system_generated": version.is_system_generated,
        "photos": [_photo(p, rows.batch.code, f"{label} photo") for p in rows.photos.get(version.id, [])],
    }


def _sorted(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Order events by date, then stage, then instance (FR63; same-day events in stage order).

    Args:
        events: page events.

    Returns:
        A new, sorted list.
    """
    return sorted(events, key=lambda e: (e["date"], STAGE_ORDER.index(e["stage"]), e["instance_no"]))


def _place(address: Mapping[str, Any] | None, village: Village | None) -> dict[str, str]:
    """Build a village-level public address (FR53); street, PIN and coordinates never reach it.

    Args:
        address: structured address `{village, block, taluk, district, state, ...}`, or None.
        village: directory village, preferred when present.

    Returns:
        `{village, block, district, state}`; a missing part is "" and fails the schema with its path.
    """
    if village is not None:
        return {
            "village": village.name_en,
            "block": village.block or village.taluk or "",
            "district": village.district,
            "state": village.state,
        }
    a = address or {}
    return {
        "village": a.get("village") or "",
        "block": a.get("block") or a.get("taluk") or "",
        "district": a.get("district") or "",
        "state": a.get("state") or "",
    }


def location_method(plot: Plot) -> str:
    """Say how the plot location was established (FR72).

    Args:
        plot: the plot.

    Returns:
        "boundary_walked" when a GPS boundary was walked, else "live_gps_pin".
    """
    return "boundary_walked" if plot.walked_boundary is not None else "live_gps_pin"


def review_note(plot: Plot) -> str | None:
    """Describe the review of a flagged location: method and date (FR70, FR72).

    Args:
        plot: the plot.

    Returns:
        E.g. "Reviewed by field visit on 4 Mar 2026", or None when never reviewed.
    """
    if plot.reviewed_at is None:
        return None
    method = REVIEW_METHODS.get(plot.review_method or "", "office review")
    return f"Reviewed by {method} on {plot.reviewed_at.day} {plot.reviewed_at:%b %Y}"


def _lot(rows: BatchRows, lr: LotRows, public: Mapping[str, list[str]]) -> dict[str, Any]:
    """Build one lot block.

    Args:
        rows: the batch rows.
        lr: the lot rows.
        public: public field names by entity.

    Returns:
        The `Lot` record.

    Raises:
        KeyError: `public` lacks an entity, or a photo's variants record is incomplete.
        AssertionError: the plot pin is not a point (the column is geography(POINT)).
    """
    farmer_fields, plot_fields = public["farmer"], public["plot"]
    # Name only with the FPO switch on, the field public for the tenant and an unrevoked consent; otherwise
    # null, which the page shows as "Farmer N" (W01 D-017).
    show_name = rows.fpo.public_show_farmer_names and lr.name_consent and "name" in farmer_fields
    pin = to_shape(lr.plot.pin)
    assert isinstance(pin, Point)  # the column is geography(POINT)
    source = lr.plot.irrigation_source.value if lr.plot.irrigation_source else None
    events = [_event(rows, e, v, public) for e, v in lr.events]
    if lr.intake is not None:
        events.append(
            {
                "stage": "sale_to_processor",
                "instance_no": 1,
                "date": lr.intake.sale_date,
                "quantity": kg(lr.intake.received_kg) if "received" in public["event_intake"] else None,
                "status": "complete",
                "system_generated": False,
            }
        )
    return {
        "lot_code": lr.lot.code,
        "farmer_name": lr.farmer.name if show_name else None,
        "place": _place(lr.farmer.address, lr.village),
        "farm_area": {"value": float(lr.plot.declared_area_acres), "unit": "acre"},
        "quantity": kg(lr.share.kg_contributed),
        "share_pct": float(lr.share.share_pct),
        "farming_type": lr.plot.farming_type.value if lr.plot.farming_type else None,
        "irrigation_source": source
        if source in PAGE_IRRIGATION and "irrigation_source" in plot_fields
        else None,
        "practice_tags": list((lr.lot.practice_tags or {}).get("derived") or []),
        "location_method": location_method(lr.plot),
        "review_note": review_note(lr.plot),
        # Rounded here and again by the schema (W01 D-017): no exact plot location can be published.
        "map_point": {"lat": round(pin.y, 3), "lon": round(pin.x, 3)},
        "gi_authorised_user_no": (
            lr.farmer.gi_authorised_user_no if "gi_authorised_user_no" in farmer_fields else None
        ),
        "events": _sorted(events),
    }


def _grade(rows: BatchRows) -> dict[str, Any]:
    """Build the grade block: grade, standard, edition, clause, readings and lab badge (FR51).

    Args:
        rows: the batch rows.

    Returns:
        The `Grade` record; blanks fail the schema when the batch has no computation.
    """
    g, v = rows.grade, rows.profile
    rules = v.rules if v else {}
    names = {
        p["code"]: p.get("name_en") or p["code"].replace("_", " ").capitalize()
        for p in rules.get("parameters", [])
    }
    readings = [
        {
            "parameter": names.get(code, code),
            "value": float(p["value"]),
            "unit": p["unit"],
            "source": p["source"],
        }
        for code, p in (g.per_parameter if g else {}).items()
        if p.get("value") is not None and p.get("unit") and p.get("source")
    ]
    return {
        "grade": (g.computed_grade if g else None) or "",
        "standard_name": rules.get("standard", {}).get("name", ""),
        "edition": v.edition if v else "",
        "clause": v.clause_ref if v else "",
        "readings": readings,
        # B05 sets lab_certified for any lab reading with a NABL number on the batch; the badge also needs
        # lab value among the readings shown, or the page would claim a result it does not show (W01 P2-2).
        "lab_certified": bool(g and g.lab_certified) and any(r["source"] == "lab" for r in readings),
        # shortcut: lab name is `partner` in quality_reading.yaml, so it is never sent; read the lab reading
        #   when a tenant makes it public.
        "lab_name": None,
    }


def assemble(rows: BatchRows, build: PageBuild, now: datetime) -> dict[str, Any]:
    """Map a batch's rows onto W01's `PublicBatchRecord` (not yet validated; `render` does that).

    Args:
        rows: what `load` read.
        build: the page build (generation and build number go into the footer).
        now: aware build time (FR17 last updated).

    Returns:
        The raw record. Lots are sorted by lot code so "Farmer N" stays the same between rebuilds.

    Raises:
        KeyError: `fieldconfig.public_fields` does not know an entity, or a photo's variants record is
            incomplete.
        AssertionError: a plot pin is not a point (the column is geography(POINT)).
    """
    # DECISION D-034: W01's `PublicBatchRecord` is the page allow-list; tenant field rules (B13) can only hide
    #   the fields the schema makes optional. Fields the PRD fixes on the page (farm area, lot quantity and
    #   share, place, farming type, grade readings) are always sent, at village level.
    #   ADV: the page keeps its PRD §12.1 shape for every tenant; a tenant can still hide quantities, inputs,
    #     seed varieties, names and GI numbers.
    #   COMPROMISE: the YAML behind those fields is `public` (`PAGE_REQUIRED_FIELDS`) and a tenant cannot
    #     narrow it; the app refuses to start on such an override (`fieldconfig.check_page_required`).
    fpo, batch, gi = rows.fpo, rows.batch, rows.gi_tag
    entities = ("farmer", "plot", "event_intake", "event_grading", "event_final_packing")
    public = {e: fieldconfig.public_fields(e, fpo.code) for e in entities} | {
        f"event_{t.value}": fieldconfig.public_fields(f"event_{t.value}", fpo.code) for t in STAGES
    }
    processing = []
    if rows.graded_on is not None:
        processing.append(
            {
                "stage": "grading",
                "instance_no": 1,
                "date": rows.graded_on,
                "quantity": kg(batch.graded_kg) if "quantity" in public["event_grading"] else None,
                "status": "complete",
                "system_generated": False,
            }
        )
    if batch.pack_date is not None:
        processing.append(
            {
                "stage": "processing_packing",
                "instance_no": 1,
                "date": batch.pack_date,
                "quantity": kg(batch.packed_kg) if "quantity" in public["event_final_packing"] else None,
                "status": "complete",
                "system_generated": False,
            }
        )
    processor = rows.processor
    lots = sorted(rows.lots, key=lambda lr: lr.lot.code)
    gi_number = gi.gi_number if gi else ""
    return {
        "product_name_en": rows.crop.name_en,
        "product_name_local": rows.crop.name_local or rows.crop.name_en,
        "batch_code": batch.code,
        "super_lot_code": batch.superlot_code or batch.code,
        "total_quantity": kg(batch.packed_kg),
        "procured_quantity": kg(batch.total_received_kg),
        "gi_tag_number": gi_number,
        "gi_tag_name": gi.name if gi else "",
        "gi_verified": batch.gi_verified,
        "gi_verification_note": (
            f"All {len(lots)} lot locations are inside the GI {gi_number} production area."
            if batch.gi_verified
            else "The GI origin of this batch is not verified."
        ),
        "grade": _grade(rows),
        "processor": {
            "name": processor.name,
            "type": ORG_KIND.get(processor.kind.value, processor.kind.value),
            "place": _place(processor.address, None),
            "fssai_licence_no": processor.fssai_no or fpo.fssai_no or "",
            "gi_authorised_user_no": processor.gi_authorised_user_no or fpo.gi_authorised_user_no or "",
        },
        "lots": [_lot(rows, lr, public) for lr in lots],
        "processing_events": _sorted(processing),
        "pack_date": batch.pack_date,
        "best_before_date": batch.best_before_date,
        "footer": {"last_updated": now, "generation": str(build.generation), "page_version": build.build_no},
    }


def privacy_hits(page: RenderResult) -> list[dict[str, Any]]:
    """Run the built-output privacy linter (W02) over a rendered page before it is published.

    Args:
        page: the rendered `index.html` and `data.json`.

    Returns:
        One `{loc: [file, line], msg, type: rule}` per rule and line that hit, in the shape of the
        `public_record_invalid` details; the matched text is never included. Empty when the page is clean.
    """
    # The schema check inside `render` is the first line of defence, this linter the second (CLAUDE.md §6,
    # audit waves 3-6 #3): free text such as a typed village can still carry a survey number or a phone.
    hits = set()
    for name, text, as_json in (("index.html", page.html, False), ("data.json", page.data_json, True)):
        for offset, rule, _ in privacy_lint.scan_text(text, [], as_json):
            hits.add((name, text.count("\n", 0, offset) + 1, rule))
    return [{"loc": [f, line], "msg": "privacy lint hit", "type": rule} for f, line, rule in sorted(hits)]
