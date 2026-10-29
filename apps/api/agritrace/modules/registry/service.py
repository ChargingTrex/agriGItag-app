"""Registry use cases: onboarding farmers and plots, FPOs, processors, villages, crops, GI regions, inputs.

Every function scopes reads and writes to the caller's FPO and role.

Serves: Stage 0 (Farmer & Farm Onboarding), UserFlows §Onboarding a farmer, FR24 (tenant isolation),
FR27–FR32 (GI region, super-admin only), FR53 (structured address), FR56 (input master), FR64–FR67
(pin, declared size, walked boundary, automatic region check), FR70–FR72 (review, corrections with
revisions, location label), Architect-Gate F7 (a `users` row for every farmer with a phone), D-005, D-017,
D-019.
Callers: registry router; other modules through `__all__` only (D-004): events sync push (B06, plots
captured offline), rules_flags (B08, `event_within_plot`, `locate_point`), lots_batches (B09, GI
re-check), publishing (B10, `format_address`), events bundle (B07, `simplify_region`).
Functions flush but never commit: the caller owns the transaction (the router commits per request; the
sync push commits per entry).
"""

import asyncio
import base64
import binascii
import json
import logging
import secrets
import uuid
from collections.abc import Callable
from datetime import UTC, datetime
from decimal import Decimal
from typing import Any

from geoalchemy2 import WKBElement, WKTElement
from geoalchemy2.shape import to_shape
from shapely.geometry import Point
from sqlalchemy import func, inspect, or_, select, tuple_
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import task_names
from agritrace.core.auth import CurrentUser
from agritrace.core.enums import FarmerStatus, LocationStatus, PinMethod, Role
from agritrace.core.errors import (
    ClientIdConflictError,
    ConflictError,
    FarmerNotPendingError,
    FarmerPhoneTakenError,
    ForbiddenError,
    GiRegionMissingError,
    NotFoundError,
    PlotLockedError,
    ReasonRequiredError,
    ValidationFailedError,
)
from agritrace.core.ids import uuid7
from agritrace.core.schemas import Address, GeoPoint, Page, Quantity
from agritrace.core.time import utcnow
from agritrace.modules.identity.models import Membership, User
from agritrace.modules.registry import geo
from agritrace.modules.registry.geo import (
    GeoResult,
    event_within_plot,
    locate_point,
    simplify_region,
    walked_area_acres,
)
from agritrace.modules.registry.models import (
    Crop,
    Farmer,
    Fpo,
    GiRegionVersion,
    GiTag,
    InputMaster,
    Plot,
    PlotRevision,
    Processor,
    Village,
)
from agritrace.modules.registry.schemas import (
    CropOut,
    FarmerIn,
    FarmerOut,
    FarmerPatch,
    FpoIn,
    FpoOut,
    GiRegionOut,
    GiRegionVersionIn,
    GiRegionVersionOut,
    InputIn,
    InputOut,
    PlotCorrection,
    PlotIn,
    PlotOut,
    ProcessorIn,
    ProcessorOut,
    RegionCheckOut,
    VillageOut,
    format_address,
)

__all__ = [
    "GeoResult",
    "area_gap",
    "enqueue_plot_check",
    "event_within_plot",
    "format_address",
    "locate_point",
    "location_status",
    "simplify_region",
    "walked_area_acres",
]

log = logging.getLogger(__name__)

AREA_GAP_LIMIT_PCT = Decimal(20)  # FR66: walked vs declared gap above this is flagged for review (FR70)
CENTS_PER_ACRE = Decimal(100)
REGION_SIMPLIFY_M = 50.0
LABELS = {"walked": "Boundary walked", PinMethod.LIVE_GPS: "Live GPS pin", PinMethod.MAP_PIN: "Map pin"}


# --- small pure helpers (unit-tested) ------------------------------------------------------------------


def encode_cursor(values: list[str]) -> str:
    """Make an opaque cursor from the sort key of the last item on a page.

    Args:
        values: the sort-key values of the last item, as strings.

    Returns:
        URL-safe base64 of the JSON list, without padding.
    """
    return base64.urlsafe_b64encode(json.dumps(values).encode()).decode().rstrip("=")


def decode_cursor(cursor: str, size: int) -> list[str]:
    """Read a cursor made by `encode_cursor`.

    Args:
        cursor: the opaque cursor from a previous page.
        size: number of sort-key values the endpoint expects.

    Returns:
        The sort-key values.

    Raises:
        ValidationFailedError: the cursor is not one this endpoint issued (`validation_error`).
    """
    try:
        values = json.loads(base64.urlsafe_b64decode(cursor + "=" * (-len(cursor) % 4)))
    except (binascii.Error, ValueError) as e:
        raise ValidationFailedError(details={"cursor": "invalid"}) from e
    if not (isinstance(values, list) and len(values) == size and all(isinstance(v, str) for v in values)):
        raise ValidationFailedError(details={"cursor": "invalid"})
    return values


def _page[T](rows: list[T], limit: int, key: Callable[[T], list[str]]) -> tuple[list[T], str | None, bool]:
    """Cut a `limit + 1` query result into one page.

    Args:
        rows: rows fetched with `LIMIT limit + 1` in the endpoint's sort order.
        limit: page size.
        key: sort-key values of a row, for the next cursor.

    Returns:
        (rows on this page, next cursor or None, has_more).
    """
    has_more = len(rows) > limit
    rows = rows[:limit]
    return rows, encode_cursor(key(rows[-1])) if has_more else None, has_more


def to_acres(quantity: Quantity) -> Decimal:
    """Convert a declared land size to acres (UserFlows §Onboarding: acres or cents, 100 cents = 1 acre).

    Args:
        quantity: size with unit `acre` or `cent`.

    Returns:
        Acres, to 0.001.

    Raises:
        ValidationFailedError: another unit, or a size of zero.
    """
    unit = quantity.unit.lower().rstrip("s")
    if unit not in ("acre", "cent"):
        raise ValidationFailedError(details={"declared_area.unit": "use `acre` or `cent`"})
    if quantity.value <= 0:
        raise ValidationFailedError(details={"declared_area.value": "must be more than 0"})
    acres = quantity.value if unit == "acre" else quantity.value / CENTS_PER_ACRE
    return acres.quantize(Decimal("0.001"))


def area_gap(declared_acres: Decimal, walked_acres: Decimal | None) -> tuple[Decimal | None, bool]:
    """Compare the walked area with the declared size (FR66).

    Args:
        declared_acres: declared size in acres (> 0).
        walked_acres: walked-boundary area in acres, or None when no boundary was walked.

    Returns:
        (gap as % of declared to 0.1, True when its absolute value exceeds 20 %); (None, False) without
        a walked area.
    """
    if walked_acres is None:
        return None, False
    pct = ((walked_acres - declared_acres) / declared_acres * 100).quantize(Decimal("0.1"))
    return pct, abs(pct) > AREA_GAP_LIMIT_PCT


def location_status(result: GeoResult | None, pin_method: PinMethod, reviewed: bool) -> LocationStatus:
    """Turn a region check into the plot's location status (FR64, FR67, FR70).

    Args:
        result: region check, or None when no region could be checked (no GI tag or no region loaded).
        pin_method: how the pin was placed.
        reviewed: True once a reviewer recorded an outcome (a reviewed map pin is judged by the check).

    Returns:
        needs_review for an unreviewed map pin or no check; else confirmed, near_edge or outside.
    """
    if (pin_method == PinMethod.MAP_PIN and not reviewed) or result is None:
        return LocationStatus.NEEDS_REVIEW
    return {"inside": LocationStatus.CONFIRMED, "near_edge": LocationStatus.NEAR_EDGE}.get(
        result.status, LocationStatus.OUTSIDE
    )


def _point_wkt(point: GeoPoint) -> WKTElement:
    """Build the value of a geography(POINT) column.

    Args:
        point: WGS84 point.

    Returns:
        `POINT(lon lat)` with SRID 4326.
    """
    return WKTElement(f"POINT({point.lon} {point.lat})", srid=4326)


def _pin(plot: Plot) -> GeoPoint:
    """Read a plot's stored pin.

    Args:
        plot: a loaded plot.

    Returns:
        The pin as a WGS84 point with its recorded accuracy.
    """
    point = to_shape(plot.pin)
    assert isinstance(point, Point)  # the column is geography(POINT)
    return GeoPoint(lat=point.y, lon=point.x, accuracy_m=plot.pin_accuracy_m)


def _json_default(value: object) -> str:
    """Render non-JSON values of a plot snapshot (geography as WKT, dates as ISO 8601, others as text).

    Args:
        value: a column value `json` cannot encode natively.

    Returns:
        Its text form.
    """
    if isinstance(value, WKBElement | WKTElement):
        return str(to_shape(value).wkt)
    iso = getattr(value, "isoformat", None)
    return str(iso()) if callable(iso) else str(value)


def _snapshot(plot: Plot) -> dict[str, Any]:
    """Copy every column of a plot into JSON for `plot_revisions.snapshot` (FR71).

    Args:
        plot: a fully loaded plot.

    Returns:
        `{column: value}` with geography as WKT, decimals and ids as text, times as ISO 8601.
    """
    values = {attr.key: getattr(plot, attr.key) for attr in inspect(Plot).column_attrs}
    result: dict[str, Any] = json.loads(json.dumps(values, default=_json_default))
    return result


def _plot_out(plot: Plot, check: GeoResult | None = None) -> PlotOut:
    """Build the API view of a plot.

    Args:
        plot: a loaded plot.
        check: the region check run by this request, if any.

    Returns:
        The response model, with area gap computed from the stored areas.
    """
    pct, exceeds = area_gap(plot.declared_area_acres, plot.walked_area_acres)
    return PlotOut(
        id=plot.id,
        fpo_id=plot.fpo_id,
        farmer_id=plot.farmer_id,
        code=plot.code,
        pin=_pin(plot),
        pin_method=plot.pin_method,
        pin_device_time=plot.pin_device_time,
        pin_gps_time=plot.pin_gps_time,
        pin_server_received_at=plot.pin_server_received_at,
        declared_area=Quantity(value=plot.declared_area_acres, unit="acre"),
        land_record_ref=plot.land_record_ref,
        walked_area=None
        if plot.walked_area_acres is None
        else Quantity(value=plot.walked_area_acres, unit="acre"),
        area_gap_pct=pct,
        area_gap_exceeds=exceeds,
        farming_type=plot.farming_type,
        irrigation_source=plot.irrigation_source,
        soil_type=plot.soil_type,
        location_status=plot.location_status,
        location_method_label=plot.location_method_label,
        revision_no=plot.revision_no,
        reviewed_at=plot.reviewed_at,
        review_method=plot.review_method,
        review_outcome=plot.review_outcome,
        region_check=None
        if check is None
        else RegionCheckOut(
            status=check.status,
            distance_m=check.distance_m,
            region_version_id=check.region_version_id,
            buffer_m=check.buffer_m,
        ),
    )


# --- access helpers ------------------------------------------------------------------------------------


async def _is_super_admin(session: AsyncSession, user: CurrentUser) -> bool:
    """Tell whether the caller is on the platform compliance team (FR31).

    Args:
        session: open database session.
        user: the caller.

    Returns:
        `users.is_super_admin` of the caller (False if the user row is missing).
    """
    return bool(await session.scalar(select(User.is_super_admin).where(User.id == user.user_id)))


async def _require_super_admin(session: AsyncSession, user: CurrentUser) -> None:
    """Admit only super-admins.

    Args:
        session: open database session.
        user: the caller.

    Raises:
        ForbiddenError: the caller is not a super-admin (`forbidden`, 403).
    """
    if not await _is_super_admin(session, user):
        raise ForbiddenError("Only the platform compliance team (super-admin) may do this.")


async def _farmer_in_scope(session: AsyncSession, user: CurrentUser, farmer_id: uuid.UUID) -> Farmer:
    """Load a farmer the caller may see: same FPO, and a farmer caller only sees themself.

    Args:
        session: open database session.
        user: the caller.
        farmer_id: farmer to load.

    Returns:
        The farmer.

    Raises:
        NotFoundError: missing or out of scope; never 403, so ids of other FPOs do not leak (FR24).
    """
    farmer = await session.get(Farmer, farmer_id)
    if (
        farmer is None
        or farmer.fpo_id != user.fpo_id
        or (user.role == Role.FARMER and farmer.user_id != user.user_id)
    ):
        raise NotFoundError(details={"farmer_id": str(farmer_id)})
    return farmer


async def _plot_in_scope(session: AsyncSession, user: CurrentUser, plot_id: uuid.UUID) -> Plot:
    """Load a plot the caller may see (same rule as `_farmer_in_scope`).

    Args:
        session: open database session.
        user: the caller.
        plot_id: plot to load.

    Returns:
        The plot.

    Raises:
        NotFoundError: missing or out of scope.
    """
    plot = await session.get(Plot, plot_id)
    if plot is None or plot.fpo_id != user.fpo_id:
        raise NotFoundError(details={"plot_id": str(plot_id)})
    if user.role == Role.FARMER:
        await _farmer_in_scope(session, user, plot.farmer_id)
    return plot


# --- FPOs, processors, villages ------------------------------------------------------------------------


async def list_fpos(session: AsyncSession, user: CurrentUser) -> list[FpoOut]:
    """List FPOs: all of them for a super-admin, else only the caller's own.

    Args:
        session: open database session.
        user: the caller.

    Returns:
        FPOs ordered by code.
    """
    query = select(Fpo).order_by(Fpo.code)
    if not await _is_super_admin(session, user):
        query = query.where(Fpo.id == user.fpo_id)
    return [FpoOut.model_validate(f) for f in (await session.scalars(query)).all()]


async def create_fpo(session: AsyncSession, user: CurrentUser, body: FpoIn) -> FpoOut:
    """Create an FPO (tenant).

    Args:
        session: open database session.
        user: the caller (must be a super-admin).
        body: the new FPO.

    Returns:
        The stored FPO.

    Raises:
        ForbiddenError: the caller is not a super-admin.
        ConflictError: the code is already used.

    Side effects:
        Inserts an `fpos` row (audited).
    """
    await _require_super_admin(session, user)
    if await session.scalar(select(Fpo.id).where(Fpo.code == body.code)):
        raise ConflictError("This FPO code is already used.", details={"code": body.code})
    fpo = Fpo(**body.model_dump(exclude={"address"}), address=_address_json(body.address))
    session.add(fpo)
    await session.flush()
    await session.refresh(fpo)
    return FpoOut.model_validate(fpo)


def _address_json(address: Address | None) -> dict[str, Any] | None:
    """Store an address without empty parts.

    Args:
        address: structured address or None.

    Returns:
        Its JSON dict without null parts, or None.
    """
    return None if address is None else address.model_dump(exclude_none=True)


async def list_processors(session: AsyncSession, user: CurrentUser) -> list[ProcessorOut]:
    """List the processors the caller's FPO registered plus shared ones.

    Args:
        session: open database session.
        user: the caller.

    Returns:
        Processors ordered by name.
    """
    query = (
        select(Processor)
        .where(or_(Processor.fpo_id == user.fpo_id, Processor.fpo_id.is_(None)))
        .order_by(Processor.name)
    )
    return [ProcessorOut.model_validate(p) for p in (await session.scalars(query)).all()]


async def create_processor(session: AsyncSession, user: CurrentUser, body: ProcessorIn) -> ProcessorOut:
    """Register a processor for the caller's FPO (Stage 7, FR62).

    Args:
        session: open database session.
        user: the caller (FPO admin).
        body: the processor.

    Returns:
        The stored processor.

    Side effects:
        Inserts a `processors` row (audited).
    """
    processor = Processor(
        **body.model_dump(exclude={"address"}), address=_address_json(body.address), fpo_id=user.fpo_id
    )
    session.add(processor)
    await session.flush()
    await session.refresh(processor)
    return ProcessorOut.model_validate(processor)


async def list_villages(
    session: AsyncSession,
    district: str | None,
    block: str | None,
    q: str | None,
    cursor: str | None,
    limit: int,
) -> Page[VillageOut]:
    """Search the village directory for the onboarding picker (FR53).

    Args:
        session: open database session.
        district: exact district name (case-insensitive), optional.
        block: exact block name (case-insensitive), optional.
        q: part of the English or local name, optional.
        cursor: cursor from the previous page.
        limit: page size.

    Returns:
        One page ordered by English name, then id.

    Raises:
        ValidationFailedError: invalid cursor.
    """
    query = select(Village)
    if district:
        query = query.where(func.lower(Village.district) == district.lower())
    if block:
        query = query.where(func.lower(Village.block) == block.lower())
    if q:
        query = query.where(
            or_(
                Village.name_en.icontains(q, autoescape=True),
                Village.name_local.icontains(q, autoescape=True),
            )
        )
    if cursor:
        name, last_id = decode_cursor(cursor, 2)
        query = query.where(tuple_(Village.name_en, Village.id) > tuple_(name, uuid.UUID(last_id)))
    rows = list((await session.scalars(query.order_by(Village.name_en, Village.id).limit(limit + 1))).all())
    items, next_cursor, has_more = _page(rows, limit, lambda v: [v.name_en, str(v.id)])
    return Page[VillageOut](
        items=[VillageOut.model_validate(v) for v in items], next_cursor=next_cursor, has_more=has_more
    )


# --- farmers ------------------------------------------------------------------------------------------


async def list_farmers(
    session: AsyncSession, user: CurrentUser, status: FarmerStatus | None, cursor: str | None, limit: int
) -> Page[FarmerOut]:
    """List the farmers of the caller's FPO (a farmer caller sees only themself).

    Args:
        session: open database session.
        user: the caller.
        status: only farmers in this status, optional.
        cursor: cursor from the previous page.
        limit: page size.

    Returns:
        One page in onboarding order (UUIDv7 ids).

    Raises:
        ValidationFailedError: invalid cursor.
    """
    query = select(Farmer).where(Farmer.fpo_id == user.fpo_id)
    if user.role == Role.FARMER:
        query = query.where(Farmer.user_id == user.user_id)
    if status:
        query = query.where(Farmer.status == status)
    if cursor:
        query = query.where(Farmer.id > uuid.UUID(decode_cursor(cursor, 1)[0]))
    rows = list((await session.scalars(query.order_by(Farmer.id).limit(limit + 1))).all())
    items, next_cursor, has_more = _page(rows, limit, lambda f: [str(f.id)])
    return Page[FarmerOut](
        items=[FarmerOut.model_validate(f) for f in items], next_cursor=next_cursor, has_more=has_more
    )


async def get_farmer(session: AsyncSession, user: CurrentUser, farmer_id: uuid.UUID) -> FarmerOut:
    """Read one farmer of the caller's FPO.

    Args:
        session: open database session.
        user: the caller.
        farmer_id: farmer to read.

    Returns:
        The farmer.

    Raises:
        NotFoundError: missing, another FPO's, or (for a farmer caller) someone else.
    """
    return FarmerOut.model_validate(await _farmer_in_scope(session, user, farmer_id))


async def _address_with_village(
    session: AsyncSession, address: Address | None, village_id: uuid.UUID | None
) -> dict[str, Any] | None:
    """Fill the address parts the officer left empty from the picked village (FR53: picked, not typed).

    Args:
        session: open database session.
        address: address as sent, or None.
        village_id: picked village, or None.

    Returns:
        The address JSON to store, or None.

    Raises:
        ValidationFailedError: `village_id` is not in the directory.
    """
    if village_id is None:
        return _address_json(address)
    village = await session.get(Village, village_id)
    if village is None:
        raise ValidationFailedError(details={"village_id": "unknown village"})
    from_village = {
        "village": village.name_en,
        "block": village.block,
        "taluk": village.taluk,
        "district": village.district,
        "state": village.state,
        "pin": village.pincode,
    }
    sent = _address_json(address) or {}
    return {k: v for k, v in from_village.items() if v} | sent


async def create_farmer(session: AsyncSession, user: CurrentUser, body: FarmerIn) -> FarmerOut:
    """Onboard a farmer in the caller's FPO, pending admin approval (Stage 0).

    With a phone number the farmer gets (or is linked to) a `users` row and a `farmer` membership, also
    when `no_smartphone` is set, so SMS reaches them and the phone has exactly one home (Architect-Gate F7).

    Args:
        session: open database session.
        user: the caller (field officer or FPO admin).
        body: the farmer.

    Returns:
        The stored farmer, status `pending`.

    Raises:
        FarmerPhoneTakenError: another farmer of this FPO already has this phone.
        ValidationFailedError: unknown `village_id`.

    Side effects:
        Inserts `farmers` and possibly `users` and `memberships` rows (all audited).
    """
    user_id = None
    if body.phone:
        account = await session.scalar(select(User).where(User.phone == body.phone))
        if account is None:
            account = User(
                id=uuid7(), phone=body.phone, name=body.name, name_local=body.name_local, lang=body.lang
            )
            session.add(account)
        elif await session.scalar(
            select(Farmer.id).where(Farmer.fpo_id == user.fpo_id, Farmer.user_id == account.id)
        ):
            raise FarmerPhoneTakenError(details={"phone": "already used by a farmer of this FPO"})
        if not await session.scalar(
            select(Membership.id).where(Membership.user_id == account.id, Membership.fpo_id == user.fpo_id)
        ):
            session.add(Membership(user_id=account.id, fpo_id=user.fpo_id, role=Role.FARMER))
        user_id = account.id
    farmer = Farmer(
        fpo_id=user.fpo_id,
        user_id=user_id,
        # shortcut: random 24-bit code per FPO (collision ~0.03 % at 100 farmers, then a 500 on the
        #   UNIQUE(fpo_id, code)); switch to a per-FPO sequence before an FPO passes ~1,000 farmers.
        code="F" + secrets.token_hex(3).upper(),
        name=body.name,
        name_local=body.name_local,
        photo_key=body.photo_key,
        address=await _address_with_village(session, body.address, body.village_id),
        village_id=body.village_id,
        gi_authorised_user_no=body.gi_authorised_user_no,
        status=FarmerStatus.PENDING,
        no_smartphone=body.no_smartphone,
    )
    session.add(farmer)
    await session.flush()
    await session.refresh(farmer)
    return FarmerOut.model_validate(farmer)


async def update_farmer(
    session: AsyncSession, user: CurrentUser, farmer_id: uuid.UUID, body: FarmerPatch
) -> FarmerOut:
    """Change a farmer's profile fields; only the fields sent change.

    Args:
        session: open database session.
        user: the caller (field officer or FPO admin).
        farmer_id: farmer to change.
        body: the changes.

    Returns:
        The updated farmer.

    Raises:
        NotFoundError: missing or another FPO's.
        ValidationFailedError: unknown `village_id`.

    Side effects:
        Updates the `farmers` row (audited with old and new values).
    """
    farmer = await _farmer_in_scope(session, user, farmer_id)
    changes = body.model_dump(exclude_unset=True, exclude={"address", "village_id"})
    for key, value in changes.items():
        if value is not None or key not in ("name", "no_smartphone"):  # these two are NOT NULL
            setattr(farmer, key, value)
    if "address" in body.model_fields_set or "village_id" in body.model_fields_set:
        village_id = body.village_id if "village_id" in body.model_fields_set else farmer.village_id
        address = (
            body.address
            if "address" in body.model_fields_set
            else Address.model_validate(farmer.address or {})
        )
        farmer.village_id = village_id
        farmer.address = await _address_with_village(session, address, village_id)
    await session.flush()
    await session.refresh(farmer)
    return FarmerOut.model_validate(farmer)


async def approve_farmer(session: AsyncSession, user: CurrentUser, farmer_id: uuid.UUID) -> FarmerOut:
    """Confirm a pending farmer as a genuine member and activate them (Stage 0 approval).

    Args:
        session: open database session.
        user: the caller (FPO admin).
        farmer_id: farmer to approve.

    Returns:
        The farmer, status `active`, with `approved_by` and `approved_at`.

    Raises:
        NotFoundError: missing or another FPO's.
        FarmerNotPendingError: the farmer is not pending.

    Side effects:
        Updates the `farmers` row; the audit listener records the change with the caller as actor.
    """
    farmer = await _farmer_in_scope(session, user, farmer_id)
    if farmer.status != FarmerStatus.PENDING:
        raise FarmerNotPendingError(details={"status": str(farmer.status)})
    farmer.status = FarmerStatus.ACTIVE
    farmer.approved_by = user.user_id
    farmer.approved_at = utcnow()
    await session.flush()
    await session.refresh(farmer)
    return FarmerOut.model_validate(farmer)


# --- plots --------------------------------------------------------------------------------------------


async def _check_region(
    session: AsyncSession, point: GeoPoint, gi_tag_id: uuid.UUID | None
) -> GeoResult | None:
    """Run the GI region check for a plot pin, if there is a region to check against.

    Args:
        session: open database session.
        point: the pin.
        gi_tag_id: GI tag from the request; None picks the only GI tag that has a region, if exactly one.

    Returns:
        The check, or None when no tag can be chosen or the tag has no region (plot then needs review).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    if gi_tag_id is None:
        # shortcut: plots do not store their GI tag, so without one in the request the pilot's single
        #   GI tag is assumed; add `plots.gi_tag_id` (B13 migration) when a second GI crop is onboarded.
        tags = (await session.scalars(select(GiRegionVersion.gi_tag_id).distinct().limit(2))).all()
        if len(tags) != 1:
            return None
        gi_tag_id = tags[0]
    try:
        return await locate_point(session, point, gi_tag_id)
    except GiRegionMissingError:
        return None


def _label(plot: Plot) -> str:
    """Public label of how the plot location was set (FR72).

    Args:
        plot: the plot.

    Returns:
        `Boundary walked`, `Live GPS pin` or `Map pin`.
    """
    return LABELS["walked" if plot.walked_boundary is not None else plot.pin_method]


async def create_plot(session: AsyncSession, user: CurrentUser, body: PlotIn) -> tuple[PlotOut, bool]:
    """Register a plot at onboarding and check its pin against the GI region (FR64–FR67, Stage 0).

    Idempotent on `client_id` (D-005): resending the same plot returns the stored one.

    Args:
        session: open database session.
        user: the caller (the farmer themself, a field officer or an FPO admin).
        body: the plot as captured on the phone.

    Returns:
        (the plot with this request's region check, True if created now / False if it already existed).

    Raises:
        NotFoundError: the farmer is missing, another FPO's, or (farmer caller) someone else.
        ClientIdConflictError: the id belongs to another FPO's or another farmer's plot.
        PlotLockedError: the id exists with a different pin or size (corrections go through an admin).
        ValidationFailedError: declared size unit not acre/cent, or zero.
        InvalidGeometryError: walked boundary malformed.

    Side effects:
        Inserts a `plots` row (audited; the reference-version trigger bumps the `plots` bundle part).
        The caller enqueues `rules.check_plot` after commit (`enqueue_plot_check`).
    """
    declared = to_acres(body.declared_area)
    existing = await session.get(Plot, body.client_id)
    if existing is not None:
        if existing.fpo_id != user.fpo_id or existing.farmer_id != body.farmer_id:
            raise ClientIdConflictError(details={"client_id": str(body.client_id)})
        await _plot_in_scope(session, user, existing.id)
        pin = _pin(existing)
        same = (round(pin.lon, 7), round(pin.lat, 7), existing.declared_area_acres) == (
            round(body.pin.lon, 7),
            round(body.pin.lat, 7),
            declared,
        )
        if not same:
            raise PlotLockedError(details={"plot_id": str(existing.id)})
        return _plot_out(existing), False

    farmer = await _farmer_in_scope(session, user, body.farmer_id)
    walked = body.walked_boundary.model_dump() if body.walked_boundary else None
    count = await session.scalar(select(func.count()).select_from(Plot).where(Plot.farmer_id == farmer.id))
    plot = Plot(
        id=body.client_id,
        fpo_id=user.fpo_id,
        farmer_id=farmer.id,
        code=body.code or f"P-{(count or 0) + 1:02d}",
        pin=_point_wkt(body.pin),
        pin_accuracy_m=body.pin.accuracy_m,
        pin_method=body.pin_method,
        pin_device_time=body.device_time,
        pin_gps_time=body.gps_time,
        pin_server_received_at=utcnow(),
        declared_area_acres=declared,
        land_record_ref=body.land_record_ref,
        walked_boundary=None if walked is None else WKTElement(geo.parse_polygon(walked).wkt, srid=4326),
        walked_area_acres=None if walked is None else walked_area_acres(walked),
        farming_type=body.farming_type,
        irrigation_source=body.irrigation_source,
        soil_type=body.soil_type,
        revision_no=1,
    )
    check = await _check_region(session, body.pin, body.gi_tag_id)
    plot.location_status = location_status(check, body.pin_method, reviewed=False)
    plot.location_method_label = _label(plot)
    session.add(plot)
    await session.flush()
    await session.refresh(plot)
    return _plot_out(plot, check), True


async def get_plot(session: AsyncSession, user: CurrentUser, plot_id: uuid.UUID) -> PlotOut:
    """Read one plot of the caller's FPO.

    Args:
        session: open database session.
        user: the caller.
        plot_id: plot to read.

    Returns:
        The plot (no region check is run on reads).

    Raises:
        NotFoundError: missing, another FPO's, or (farmer caller) someone else's.
    """
    return _plot_out(await _plot_in_scope(session, user, plot_id))


async def correct_plot(
    session: AsyncSession, user: CurrentUser, plot_id: uuid.UUID, body: PlotCorrection
) -> PlotOut:
    """Correct an onboarded plot with a logged reason, keeping its previous state (FR70, FR71).

    Args:
        session: open database session.
        user: the caller (FPO admin).
        plot_id: plot to correct.
        body: the changed fields, the reason and optionally the review outcome.

    Returns:
        The corrected plot with the re-run region check.

    Raises:
        ReasonRequiredError: no `reason_code`.
        NotFoundError: missing or another FPO's.
        ValidationFailedError: declared size unit not acre/cent, or zero.
        InvalidGeometryError: walked boundary malformed.

    Side effects:
        Inserts a `plot_revisions` snapshot of the old state, updates the plot (audited), bumps
        `revision_no`; the caller enqueues `rules.check_plot` after commit.
    """
    if not (body.reason_code and body.reason_code.strip()):
        raise ReasonRequiredError(details={"field": "reason_code"})
    plot = await _plot_in_scope(session, user, plot_id)
    now = utcnow()
    session.add(
        PlotRevision(
            plot_id=plot.id,
            revision_no=plot.revision_no,
            snapshot=_snapshot(plot),
            changed_by=user.user_id,
            reason_code=body.reason_code.strip(),
            reason_text=body.reason_text,
            changed_at=now,
        )
    )
    sent = body.model_fields_set
    if body.pin is not None:
        plot.pin = _point_wkt(body.pin)
        plot.pin_accuracy_m = body.pin.accuracy_m
        plot.pin_server_received_at = now
    if body.pin_method is not None:
        plot.pin_method = body.pin_method
    if body.declared_area is not None:
        plot.declared_area_acres = to_acres(body.declared_area)
    if body.walked_boundary is not None:
        walked = body.walked_boundary.model_dump()
        plot.walked_boundary = WKTElement(geo.parse_polygon(walked).wkt, srid=4326)
        plot.walked_area_acres = walked_area_acres(walked)
    for key in ("land_record_ref", "farming_type", "irrigation_source", "soil_type"):
        if key in sent:
            setattr(plot, key, getattr(body, key))
    if body.review_method is not None:
        plot.review_method = body.review_method
        plot.review_outcome = body.review_outcome
        plot.reviewed_at = now
    plot.revision_no += 1
    pin = body.pin or _pin(plot)
    check = await _check_region(session, pin, body.gi_tag_id)
    plot.location_status = location_status(check, plot.pin_method, reviewed=plot.reviewed_at is not None)
    plot.location_method_label = _label(plot)
    await session.flush()
    await session.refresh(plot)
    return _plot_out(plot, check)


async def enqueue_plot_check(plot_id: uuid.UUID) -> None:
    """Ask the worker to run the plot rules (`rules.check_plot`, B08) after the plot is committed.

    Args:
        plot_id: the committed plot.

    Side effects:
        Publishes one Celery message by task name (D-004: no import of rules_flags). A broker failure is
        logged, not raised: the plot is already stored and the rule sweep can re-check it.
    """
    # Imported here: importing the worker reads the settings (secrets), which OpenAPI export must not need.
    from agritrace.worker import app as celery_app

    try:
        await asyncio.to_thread(celery_app.send_task, task_names.RULES_CHECK_PLOT, args=[str(plot_id)])
    except Exception:  # noqa: BLE001 - see Side effects
        log.warning("could not enqueue %s for plot %s", task_names.RULES_CHECK_PLOT, plot_id, exc_info=True)


# --- crops, GI regions, inputs ------------------------------------------------------------------------


async def list_crops(session: AsyncSession) -> list[CropOut]:
    """List active crops.

    Args:
        session: open database session.

    Returns:
        Active crops ordered by English name.
    """
    query = select(Crop).where(Crop.active.is_(True)).order_by(Crop.name_en)
    return [CropOut.model_validate(c) for c in (await session.scalars(query)).all()]


async def get_region(session: AsyncSession, gi_tag_id: uuid.UUID) -> GiRegionOut:
    """Return the region in effect today for a GI tag, simplified for phones and maps (FR27, FR30).

    Args:
        session: open database session.
        gi_tag_id: the GI tag.

    Returns:
        Version metadata and the outline simplified at 50 m.

    Raises:
        GiRegionMissingError: no version is in effect.
    """
    version = await session.scalar(
        select(GiRegionVersion)
        .where(GiRegionVersion.gi_tag_id == gi_tag_id, GiRegionVersion.effective_from <= func.current_date())
        .order_by(GiRegionVersion.version_no.desc())
        .limit(1)
    )
    if version is None:
        raise GiRegionMissingError(details={"gi_tag_id": str(gi_tag_id)})
    return GiRegionOut(
        version=GiRegionVersionOut.model_validate(version),
        geometry=await simplify_region(session, version.id, REGION_SIMPLIFY_M),
        simplified_tolerance_m=REGION_SIMPLIFY_M,
    )


async def create_region_version(
    session: AsyncSession, user: CurrentUser, gi_tag_id: uuid.UUID, body: GiRegionVersionIn
) -> GiRegionVersionOut:
    """Store a new version of a GI tag's production-area outline with its provenance (FR31, D-019).

    Args:
        session: open database session.
        user: the caller (must be a super-admin; FPO admins get 403).
        gi_tag_id: the GI tag.
        body: outline, buffer and provenance.

    Returns:
        The stored version's metadata; `version_no` is the previous highest + 1 (0 for the first).

    Raises:
        ForbiddenError: the caller is not a super-admin.
        NotFoundError: no such GI tag.
        InvalidGeometryError: outline invalid.

    Side effects:
        Inserts a `gi_region_versions` row; its trigger bumps the `gi_region` bundle part.
    """
    await _require_super_admin(session, user)
    if await session.get(GiTag, gi_tag_id) is None:
        raise NotFoundError(details={"gi_tag_id": str(gi_tag_id)})
    outline = geo.parse_multipolygon(body.geometry.model_dump())
    last = await session.scalar(
        select(func.max(GiRegionVersion.version_no)).where(GiRegionVersion.gi_tag_id == gi_tag_id)
    )
    version = GiRegionVersion(
        gi_tag_id=gi_tag_id,
        version_no=0 if last is None else last + 1,
        geom=WKTElement(outline.wkt, srid=4326),
        tolerance_buffer_m=body.tolerance_buffer_m,
        taluks=body.taluks,
        source_ref=body.source_ref,
        licence=body.licence,
        confidence=body.confidence,
        effective_from=body.effective_from or datetime.now(UTC).date(),
        created_by=user.user_id,
    )
    session.add(version)
    await session.flush()
    await session.refresh(version)
    return GiRegionVersionOut.model_validate(version)


async def list_inputs(session: AsyncSession, user: CurrentUser) -> list[InputOut]:
    """List the active inputs farmers of the caller's FPO pick from: the global list plus the FPO's own.

    Args:
        session: open database session.
        user: the caller.

    Returns:
        Inputs ordered by category, then English name.
    """
    query = (
        select(InputMaster)
        .where(
            InputMaster.active.is_(True), or_(InputMaster.fpo_id.is_(None), InputMaster.fpo_id == user.fpo_id)
        )
        .order_by(InputMaster.category, InputMaster.name_en)
    )
    return [InputOut.model_validate(i) for i in (await session.scalars(query)).all()]


async def create_input(session: AsyncSession, user: CurrentUser, body: InputIn) -> InputOut:
    """Add an input to the FPO's list, or to the global list for a super-admin (FR56).

    Args:
        session: open database session.
        user: the caller (FPO admin; super-admin for a global entry).
        body: the input.

    Returns:
        The stored input.

    Raises:
        ForbiddenError: `global_entry` requested by someone who is not a super-admin.

    Side effects:
        Inserts an `inputs_master` row; its trigger bumps the `inputs` bundle part.
    """
    if body.global_entry:
        await _require_super_admin(session, user)
    item = InputMaster(
        **body.model_dump(exclude={"global_entry"}), fpo_id=None if body.global_entry else user.fpo_id
    )
    session.add(item)
    await session.flush()
    await session.refresh(item)
    return InputOut.model_validate(item)


# TODO(B13): `id_documents` (flag `id_document_capture`) and `producer_groups` (flag `producer_groups`)
#   get no endpoints here; B13 adds them behind the feature flags (D-017).
