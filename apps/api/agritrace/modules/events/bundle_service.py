"""Offline reference bundles: the manifest, one part body, and the per-part delta (`?since=`).

Each part body is built on request by a plain serialiser; its strong ETag is the hash of that body, so a
304 is exact. Versions of database-fed parts come from `reference_versions` (bumped by triggers, migration
0001); the other parts carry a content fingerprint. Bodies match the shapes the phone parses
(docs/agents/reports/M03.md "Contract for B07"; apps/mobile/lib/core/refdata/models/*.dart).

Serves: FR4, Arch §Offline-first "Reference data travels to the phone", PLAN §13 C2 (bundles with per-part
delta sync + ETag/304) and C3 (simplified GI outline), backend-design.md §3 "Reference bundles", TODO F1
(compare versions per part), D-006, D-016, D-017.
Callers: `events.sync_router` (`GET /v1/sync/bundle`, `/sync/bundle/{part}`, `/sync/reference`);
tests/unit/test_bundle_service.py, tests/integration/test_bundle_pull.py.
"""

import json
import logging
import uuid
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from typing import Any

from geoalchemy2.shape import to_shape
from shapely.geometry import Point
from sqlalchemy import func, or_, select, true
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.enums import Role
from agritrace.core.errors import GiRegionMissingError, ValidationFailedError
from agritrace.modules.events.models import ReferenceVersion
from agritrace.modules.events.schemas import (
    BundleManifest,
    BundlePart,
    PartVersion,
    ReferenceOut,
    ReferencePart,
)
from agritrace.modules.quality import service as quality_service
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiRegionVersion, InputMaster, Plot, Village

log = logging.getLogger(__name__)

# Parts whose source tables carry the `bump_reference_version` trigger (migration 0001 REFERENCE_PARTS).
DB_PARTS = frozenset(
    {
        BundlePart.PLOTS,
        BundlePart.CROPS,
        BundlePart.INPUTS,
        BundlePart.STANDARDS,
        BundlePart.GI_REGION,
        BundlePart.VILLAGES,
    }
)
MAX_REGION_BYTES = 50 * 1024  # PLAN §13 C3: the outline must stay small on 2G
REGION_TOLERANCES_M = (50.0, 100.0, 200.0, 400.0)


@dataclass(frozen=True, slots=True)
class Scope:
    """What one caller may see: the FPO, and for a farmer only their own farmer rows."""

    fpo_id: uuid.UUID
    farmer_ids: list[uuid.UUID] | None  # None = every farmer of the FPO (officer roles)


# --- plain serialisers (unit-tested against the phone's golden fixture) --------------------------------


def plot_json(plot: Plot) -> dict[str, Any]:
    """Serialise a plot for the `plots` part (lean; never the walked boundary or land record, CLAUDE.md §6).

    Args:
        plot: the plot row (its `pin` loaded).

    Returns:
        `{id, farmer_id, code, pin: {lat, lon}, declared_area, area_unit: "acre", gi_tag_id}`.
    """
    pin = to_shape(plot.pin)
    assert isinstance(pin, Point)  # the column is geography(POINT)
    return {
        "id": str(plot.id),
        "farmer_id": str(plot.farmer_id),
        "code": plot.code,
        "pin": {"lat": pin.y, "lon": pin.x},
        "declared_area": float(plot.declared_area_acres),
        "area_unit": "acre",
        "gi_tag_id": str(plot.gi_tag_id) if plot.gi_tag_id else None,
    }


def crop_json(crop: Crop) -> dict[str, Any]:
    """Serialise a crop with its event schema for the `crops` part (FR22, FR55).

    Args:
        crop: the crop row.

    Returns:
        `{id, code, name_en, name_local, gi_tag_id, event_schema: {mandatory, tracks}}` (schema as stored).
    """
    return {
        "id": str(crop.id),
        "code": crop.code,
        "name_en": crop.name_en,
        "name_local": crop.name_local,
        "gi_tag_id": str(crop.gi_tag_id) if crop.gi_tag_id else None,
        "event_schema": crop.event_schema,
    }


def input_json(item: InputMaster) -> dict[str, Any]:
    """Serialise an input-master row for the `inputs` part (FR56).

    Args:
        item: the input row.

    Returns:
        `{id, name_en, name_local, manufacturer, category, unit}`.
    """
    return {
        "id": str(item.id),
        "name_en": item.name_en,
        "name_local": item.name_local,
        "manufacturer": item.manufacturer,
        "category": str(item.category),
        "unit": item.unit,
    }


def village_json(village: Village) -> dict[str, Any]:
    """Serialise a village for the `villages` part (FR53 picker offline).

    Args:
        village: the village row.

    Returns:
        `{id, lgd_code, name_en, name_local, block, taluk, district, pincode}`.
    """
    return {
        "id": str(village.id),
        "lgd_code": village.lgd_code,
        "name_en": village.name_en,
        "name_local": village.name_local,
        "block": village.block,
        "taluk": village.taluk,
        "district": village.district,
        "pincode": village.pincode,
    }


def farmer_json(farmer: Farmer) -> dict[str, Any]:
    """Serialise a farmer for the `farmer_profile` part: no phone, address or ID numbers (CLAUDE.md §6).

    Args:
        farmer: the farmer row.

    Returns:
        `{id, code, name, name_local, village_id, status, no_smartphone}`.
    """
    return {
        "id": str(farmer.id),
        "code": farmer.code,
        "name": farmer.name,
        "name_local": farmer.name_local,
        "village_id": str(farmer.village_id) if farmer.village_id else None,
        "status": str(farmer.status),
        "no_smartphone": farmer.no_smartphone,
    }


def public_asset_url(key: str) -> str:
    """URL of an asset in the anonymous-read bucket (product pictures, voice packs).

    Args:
        key: object key in the public-pages bucket.

    Returns:
        `{S3_PUBLIC_ENDPOINT}/{public bucket}/{key}`.
    """
    s = get_settings()
    return f"{s.s3_public_endpoint.rstrip('/')}/{s.s3_bucket_public}/{key}"


def region_json(version: GiRegionVersion, geometry: dict[str, Any], tolerance_m: float) -> dict[str, Any]:
    """Serialise the GI outline for the `gi_region` part (FR27, FR32, D-019 provenance).

    Args:
        version: the region version in effect.
        geometry: its simplified GeoJSON geometry.
        tolerance_m: simplification tolerance used, in metres.

    Returns:
        `{geometry, tolerance_buffer_m, version_no, region_version_id, gi_tag_id, simplified_tolerance_m,
        source_ref, licence, confidence, effective_from}`.
    """
    return {
        "geometry": geometry,
        "tolerance_buffer_m": float(version.tolerance_buffer_m),
        "version_no": version.version_no,
        "region_version_id": str(version.id),
        "gi_tag_id": str(version.gi_tag_id),
        "simplified_tolerance_m": tolerance_m,
        "source_ref": version.source_ref,
        "licence": version.licence,
        "confidence": version.confidence,
        "effective_from": version.effective_from.isoformat(),
    }


def fingerprint(etag: str) -> int:
    """Turn a content ETag into an integer version for parts without a database version.

    Args:
        etag: a quoted hex ETag from `fieldconfig.etag`.

    Returns:
        The first 48 bits of the hash (fits a JavaScript number and SQLite INTEGER).
    """
    return int(etag.strip('"')[:12], 16)


def parse_since(since: str | None) -> dict[str, int]:
    """Read `?since=<part>:<version>,...` (the versions the phone holds).

    Args:
        since: the raw query value, or None/empty when the phone holds nothing.

    Returns:
        Part name -> version. Unknown part names are kept (and never match), so old phones keep working.

    Raises:
        ValidationFailedError: an item is not `<name>:<integer>`.
    """
    held: dict[str, int] = {}
    for item in filter(None, (since or "").split(",")):
        try:
            name, version = item.strip().split(":")
            held[name] = int(version)
        except ValueError as e:
            raise ValidationFailedError(details={"since": f"expected <part>:<version>, got {item!r}"}) from e
    return held


def changed_parts(current: dict[BundlePart, PartVersion], held: dict[str, int]) -> list[BundlePart]:
    """Pick the parts whose version differs from the one the phone holds, comparing each part on its own.

    Args:
        current: the caller's parts now.
        held: versions the phone holds (`parse_since`).

    Returns:
        Parts that are new to the phone or changed, in manifest order.
    """
    # Per part, never one global number: the shared sequence orders transaction starts, not commits, so a
    # single `since` could skip a part that commits late (review B01-r1 F1). "Differs" rather than "greater":
    # database versions only grow, and fingerprints have no order.
    return [p for p, v in current.items() if held.get(p.value) != v.version]


# --- part builders ------------------------------------------------------------------------------------


async def _scope(session: AsyncSession, user: CurrentUser) -> Scope:
    """Resolve what the caller may see.

    Args:
        session: database session.
        user: the caller.

    Returns:
        The FPO, and the caller's own farmer ids when the caller is a farmer.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    if user.role != Role.FARMER:
        return Scope(user.fpo_id, None)
    query = select(Farmer.id).where(Farmer.user_id == user.user_id, Farmer.fpo_id == user.fpo_id)
    return Scope(user.fpo_id, list((await session.scalars(query)).all()))


def _farmer_filter(column: Any, scope: Scope) -> Any:
    """SQL condition limiting rows to the scope's farmers.

    Args:
        column: a column holding a farmer id.
        scope: the caller's scope.

    Returns:
        `column IN (farmer ids)`, or a true condition for officer roles.
    """
    return column.in_(scope.farmer_ids) if scope.farmer_ids is not None else true()


async def _plots(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `plots` part: the caller's plots (farmer) or the FPO's plots (officers).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"plots": [plot_json]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = (
        select(Plot)
        .where(Plot.fpo_id == scope.fpo_id, _farmer_filter(Plot.farmer_id, scope))
        .order_by(Plot.farmer_id, Plot.code, Plot.id)
    )
    return {"plots": [plot_json(p) for p in await session.scalars(query)]}


async def _active_crops(session: AsyncSession) -> list[Crop]:
    """Load active crops in a stable order.

    Args:
        session: database session.

    Returns:
        Active crops ordered by code.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    return list(await session.scalars(select(Crop).where(Crop.active.is_(True)).order_by(Crop.code)))


async def _crops(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `crops` part (global).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"crops": [crop_json]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    return {"crops": [crop_json(c) for c in await _active_crops(session)]}


def _inputs_query(scope: Scope) -> Any:
    """Select the active inputs farmers of the FPO pick from: the global list plus the FPO's own.

    Args:
        scope: the caller's scope.

    Returns:
        The SELECT, ordered by category, English name, id (stable for the ETag).
    """
    return (
        select(InputMaster)
        .where(
            InputMaster.active.is_(True),
            or_(InputMaster.fpo_id.is_(None), InputMaster.fpo_id == scope.fpo_id),
        )
        .order_by(InputMaster.category, InputMaster.name_en, InputMaster.id)
    )


async def _inputs(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `inputs` part (global + FPO).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"inputs": [input_json]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    return {"inputs": [input_json(i) for i in await session.scalars(_inputs_query(scope))]}


async def _standards(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `standards` part: the full rules JSON of each crop's published profile version.

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"profiles": {crop_id: rules JSON}}`; crops without a published version are absent.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # DECISION D-006: the phone gets the exact `standards_profile_versions.rules` JSON the server grades with,
    #   not a trimmed subset (Orchestrator decision 2026-10-31 after M03).
    #   ADV: one rule source; the grade preview needs grades, fail_grade, trail rules, per-parameter fields.
    #   COMPROMISE: a few KB more per crop, and internal fields (clause notes) reach the phone.
    profiles: dict[str, Any] = {}
    for crop in await _active_crops(session):
        version = await quality_service.latest_profile_version_for_crop(session, crop.id)
        if version is not None:
            profiles[str(crop.id)] = version.rules
    return {"profiles": profiles}


async def _gi_region(session: AsyncSession, scope: Scope) -> dict[str, Any] | None:
    """Build the `gi_region` part, simplified until it fits 50 KB; None when no region is in effect.

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `region_json(...)` (the coarsest attempt if none fits 50 KB), or None when no region version of
        an active crop's GI tag is in effect.

    Raises:
        NotFoundError: the region version vanished between lookup and simplification.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: one GI tag per bundle (pilot GI 883); a second GI crop needs a list of regions in the part.
    tags = select(Crop.gi_tag_id).where(Crop.active.is_(True), Crop.gi_tag_id.is_not(None))
    version = await session.scalar(
        select(GiRegionVersion)
        .where(GiRegionVersion.gi_tag_id.in_(tags), GiRegionVersion.effective_from <= func.current_date())
        .order_by(GiRegionVersion.gi_tag_id, GiRegionVersion.version_no.desc())
        .limit(1)
    )
    if version is None:
        return None
    for tolerance in REGION_TOLERANCES_M:
        geometry = await registry_service.simplify_region(session, version.id, tolerance)
        size = len(json.dumps(geometry))
        if size <= MAX_REGION_BYTES:
            break
    else:
        log.warning(
            "gi_region %s is %d bytes at %s m, over %d", version.id, size, tolerance, MAX_REGION_BYTES
        )
    return region_json(version, geometry, tolerance)


async def _farmer_profile(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `farmer_profile` part: the farmer themself, or the FPO's farmers for assist mode.

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"farmers": [farmer_json]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = (
        select(Farmer)
        .where(Farmer.fpo_id == scope.fpo_id, _farmer_filter(Farmer.id, scope))
        .order_by(Farmer.code, Farmer.id)
    )
    return {"farmers": [farmer_json(f) for f in await session.scalars(query)]}


async def _villages(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `villages` part: villages of the FPO's district (empty when the FPO has no district).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"villages": [village_json]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    fpo = await session.get(Fpo, scope.fpo_id)
    district = ((fpo.address if fpo else None) or {}).get("district")
    if not district:
        return {"villages": []}
    query = (
        select(Village)
        .where(func.lower(Village.district) == district.lower())
        .order_by(Village.name_en, Village.id)
    )
    return {"villages": [village_json(v) for v in await session.scalars(query)]}


async def _fields(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `fields` part from the field configuration.

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `fieldconfig.bundle_part(fpo_code)`: `{version, entities, features}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # DECISION D-017: forms on the phone render from the same YAML field configuration the API enforces.
    #   ADV: a tenant override reaches the phone with the next bundle check, no app release.
    #   COMPROMISE: the part changes on every config deploy, so it carries a content fingerprint, not a
    #     database version.
    return fieldconfig.bundle_part(await registry_service.fpo_code(session, scope.fpo_id))


async def _prompts(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `prompts` part: downloadable voice packs beyond the bundled ta/en clips (none yet).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"prompts": []}`.
    """
    # shortcut: no server-side voice packs exist (D-016 ships ta+en in the app); items will be
    #   {lang, prompt_id, key, url}. Fill from the public bucket when a third language is recorded.
    return {"prompts": []}


async def _images(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `images` part: product pictures of the inputs the caller picks from.

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"images": [{id, kind: "input", key, url}]}`.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # DECISION D-016: FPO content (product pictures, voice packs) is a downloadable bundle; the manifest
    #   lists keys and plain URLs into the anonymous-read public bucket instead of carrying the bytes.
    #   ADV: stable URLs keep the part's ETag stable (presigned links change on every call) and are
    #     CDN-cacheable; the phone downloads each picture once.
    #   COMPROMISE: anyone with the URL can fetch a product picture; only non-sensitive assets go there,
    #     never evidence photos or ID documents (those use presigned GETs).
    items = [
        {"id": str(i.id), "kind": "input", "key": i.photo_key, "url": public_asset_url(i.photo_key)}
        for i in await session.scalars(_inputs_query(scope))
        if i.photo_key
    ]
    return {"images": items}


async def _calendar(session: AsyncSession, scope: Scope) -> dict[str, Any]:
    """Build the `calendar` part: crop-calendar reminders (no source yet).

    Args:
        session: database session.
        scope: the caller's scope.

    Returns:
        `{"calendar": []}`.
    """
    # shortcut: no crop-calendar source exists before B08/B09; items will be
    #   {event_type, due_on: "YYYY-MM-DD", prompt_id, lot_id?} (M03 contract). Fill once lots carry sowing
    #   dates.
    return {"calendar": []}


BUILDERS: dict[BundlePart, Callable[[AsyncSession, Scope], Awaitable[dict[str, Any] | None]]] = {
    BundlePart.PLOTS: _plots,
    BundlePart.CROPS: _crops,
    BundlePart.INPUTS: _inputs,
    BundlePart.STANDARDS: _standards,
    BundlePart.GI_REGION: _gi_region,
    BundlePart.FARMER_PROFILE: _farmer_profile,
    BundlePart.VILLAGES: _villages,
    BundlePart.FIELDS: _fields,
    BundlePart.PROMPTS: _prompts,
    BundlePart.IMAGES: _images,
    BundlePart.CALENDAR: _calendar,
}


# --- use cases ----------------------------------------------------------------------------------------


async def _db_versions(session: AsyncSession, fpo_id: uuid.UUID) -> dict[str, int]:
    """Read the database versions of the parts for one FPO.

    Args:
        session: database session.
        fpo_id: the caller's FPO.

    Returns:
        Part -> sum of its global row and the FPO's row. Each row only grows in commit order (bumped under
        its row lock), so the sum grows with every visible change; a max would not (a late-committing
        global bump below the FPO's value would be hidden).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = (
        select(ReferenceVersion.part, func.sum(ReferenceVersion.version))
        .where(or_(ReferenceVersion.fpo_id.is_(None), ReferenceVersion.fpo_id == fpo_id))
        .group_by(ReferenceVersion.part)
    )
    return {part: int(total) for part, total in (await session.execute(query)).all()}


async def _snapshot(session: AsyncSession, user: CurrentUser) -> dict[BundlePart, ReferencePart]:
    """Build every part the caller can download, with version and ETag.

    Args:
        session: database session.
        user: the caller.

    Returns:
        Part -> version, ETag and body; `gi_region` is left out while no region is in effect.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    scope = await _scope(session, user)
    versions = await _db_versions(session, user.fpo_id)
    parts: dict[BundlePart, ReferencePart] = {}
    for part, build in BUILDERS.items():
        body = await build(session, scope)
        if body is None:
            continue
        etag = fieldconfig.etag(body)
        version = versions.get(part.value, 0) if part in DB_PARTS else fingerprint(etag)
        parts[part] = ReferencePart(version=version, etag=etag, body=body)
    return parts


async def manifest(session: AsyncSession, user: CurrentUser) -> BundleManifest:
    """List the caller's bundle parts with version and ETag (`GET /v1/sync/bundle`).

    Args:
        session: database session.
        user: the caller.

    Returns:
        The manifest.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    # shortcut: builds every body to hash it (no cache, per Ponytail); a few small queries per call for
    #   one pilot FPO. Cache by (part, version, scope) if manifest latency shows up in sync metrics.
    snapshot = await _snapshot(session, user)
    return BundleManifest(parts={p: PartVersion(version=v.version, etag=v.etag) for p, v in snapshot.items()})


async def part_body(session: AsyncSession, user: CurrentUser, part: BundlePart) -> dict[str, Any]:
    """Build one part body for the caller (`GET /v1/sync/bundle/{part}`).

    Args:
        session: database session.
        user: the caller.
        part: the part.

    Returns:
        The body (JSON-native values only, so its ETag is `fieldconfig.etag(body)`).

    Raises:
        GiRegionMissingError: `gi_region` asked while no region version is in effect.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    body = await BUILDERS[part](session, await _scope(session, user))
    if body is None:
        raise GiRegionMissingError(details={"part": part.value})
    return body


async def reference(session: AsyncSession, user: CurrentUser, since: str | None) -> ReferenceOut:
    """Return the parts whose version differs from the ones the phone holds (`GET /v1/sync/reference`).

    Args:
        session: database session.
        user: the caller.
        since: `<part>:<version>,...` as the phone holds them; None for everything.

    Returns:
        The changed parts with bodies; empty `parts` means the phone is up to date (the router answers 304).

    Raises:
        ValidationFailedError: `since` is malformed.
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    held = parse_since(since)
    snapshot = await _snapshot(session, user)
    versions = {p: PartVersion(version=v.version, etag=v.etag) for p, v in snapshot.items()}
    return ReferenceOut(parts={p: snapshot[p] for p in changed_parts(versions, held)})
