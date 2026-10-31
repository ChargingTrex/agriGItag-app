"""Reporting reads: FPO dashboard, per-farmer table, audit log search and CSV export, public scan counting.

Every number is one SQL aggregate over the FPO's rows; nothing here writes except `record_scan`.

Serves: FR13 (FPO dashboard), FR20 (scan analytics), FR21 (audit export), FR58 (unit on every amount and a
unit column in the CSV), FR25 / FR59 (who entered each version, assist session), plan §7.1 B11, plan §7.3
P06, plan §13 F1 (sync health), D-037 (stage progress and completeness), D-038 (scan rate limit),
D-039 (audit log FPO scope), CLAUDE.md §6 (FPO scope; no phones or coordinates in any payload).
Callers: `reporting.router` (which commits); tests/unit/test_reporting.py,
tests/integration/test_reporting.py. No other module calls it (`__all__` is empty).
"""

import csv
import hashlib
import io
import json
import logging
import uuid
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal
from functools import cache
from typing import Any

from redis.asyncio import Redis
from redis.exceptions import RedisError
from sqlalchemy import ColumnElement, Select, and_, case, exists, extract, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import aliased

from agritrace.core import fieldconfig
from agritrace.core.config import get_settings
from agritrace.core.db import Base
from agritrace.core.enums import BatchStatus, EventType, LocationStatus, LotStatus, Severity
from agritrace.core.errors import NotFoundError, RateLimitedError
from agritrace.core.schemas import Page, Quantity
from agritrace.core.time import utcnow
from agritrace.modules.events.models import Event, EventVersion, SyncMetric
from agritrace.modules.identity.models import AuditLog, Device, Membership, User
from agritrace.modules.lots_batches.models import Batch, BatchShare, Lot
from agritrace.modules.registry import service as registry_service
from agritrace.modules.registry.models import Crop, Farmer, Plot, Village
from agritrace.modules.reporting.models import ScanEvent
from agritrace.modules.reporting.schemas import (
    AreaByBlock,
    AreaByVillage,
    AreaStats,
    AuditRow,
    Completeness,
    Dashboard,
    FarmerRow,
    FinishedBatch,
    FinishedGoods,
    FlagCounts,
    LandArea,
    Scans,
    StageTile,
    SyncHealthRow,
)
from agritrace.modules.rules_flags.models import Flag
from agritrace.modules.rules_flags.service import ACTIVE, DEAD_EVENTS

__all__: list[str] = []

log = logging.getLogger(__name__)

# P06 stage tiles in farm order; nursery and inputs are tiles too, although they run beside the main track.
STAGES = (
    EventType.LAND_PREPARATION,
    EventType.NURSERY,
    EventType.SOWING,
    EventType.INPUT_APPLICATION,
    EventType.HARVEST,
    EventType.DRYING,
    EventType.PACKING,
)
IN_FIELD = (LotStatus.OPEN, LotStatus.DRYING)  # lot statuses before the ready-for-sale gate
FINISHED = (BatchStatus.PACKED, BatchStatus.PUBLISHED)
WEEK = timedelta(days=7)
FINISHED_ROWS = (
    100  # shortcut: newest 100 batches in the dashboard; add a paginated list when an FPO has more
)
SCAN_LIMIT = 100  # scans per client IP per window (B11 acceptance)
UNKNOWN_SCAN_LIMIT = 10  # scans of codes no batch has, per client IP per window (junk rows, D-038)
SCAN_WINDOW_S = 60
# The quantity a CSV row shows: the first of these payload keys present (event payloads, D-014).
QUANTITY_KEYS = ("quantity", "received", "sown_area", "cultivated_area", "nursery_area", "affected_area")
# Diff and payload keys whose values are locations or land records; shown as `[hidden]` (B11-r1 P2-1).
HIDDEN_KEYS = frozenset(
    {"pin", "walked_boundary", "land_record_ref", "exif_gps", "gps", "started_gps", "boundary"}
)
CSV_COLUMNS = (
    "subject_type",
    "subject_code",
    "event_id",
    "event_type",
    "version_id",
    "version_no",
    "change_kind",
    "occurred_on",
    "occurred_end_on",
    "device_time",
    "server_received_at",
    "entered_by",
    "entered_by_name",
    "on_behalf_of_farmer_id",
    "assist_session_id",
    "entered_remotely",
    "is_system_generated",
    "reason_code",
    "reason_text",
    "quantity",
    "unit",
    "payload",
)


@dataclass(frozen=True, slots=True)
class Filters:
    """Dashboard filters (P06 crop → district → block → village); None means no filter."""

    crop_id: uuid.UUID | None = None
    district: str | None = None
    block: str | None = None
    village_id: uuid.UUID | None = None


# --- small pure helpers (unit-tested) ------------------------------------------------------------------


def percent(part: Decimal | int, whole: Decimal | int) -> Quantity | None:
    """Express `part` as a share of `whole`.

    Args:
        part: the counted part (lots, acres, attempts).
        whole: the total it is part of.

    Returns:
        A `Quantity` with unit `%` rounded to 0.1, or None when `whole` is 0.
    """
    if not whole:
        return None
    return Quantity(value=(Decimal(part) * 100 / Decimal(whole)).quantize(Decimal("0.1")), unit="%")


def _acres(value: Decimal | None) -> Quantity:
    """Wrap an area sum in its unit.

    Args:
        value: acres, or None for an empty group.

    Returns:
        A `Quantity` with unit `acre` (0 for None).
    """
    return Quantity(value=value or Decimal(0), unit="acre")


def _kg(value: Decimal | None) -> Quantity | None:
    """Wrap a batch quantity in its unit.

    Args:
        value: kilograms, or None when not recorded.

    Returns:
        A `Quantity` with unit `kg`, or None.
    """
    return None if value is None else Quantity(value=value, unit="kg")


def _ms(value: float | None) -> Quantity | None:
    """Wrap a duration percentile in its unit.

    Args:
        value: milliseconds from `percentile_cont`, or None when the group had no value.

    Returns:
        A `Quantity` with unit `ms` rounded to whole milliseconds, or None.
    """
    return None if value is None else Quantity(value=Decimal(round(value)), unit="ms")


def main_quantity(payload: dict[str, Any]) -> tuple[Any, Any]:
    """Pick the quantity a CSV row shows for an event version (FR58: value and unit in separate columns).

    Args:
        payload: the version's stored payload, every quantity `{value, unit}` (D-014).

    Returns:
        `(value, unit)` of the first `QUANTITY_KEYS` entry present, else `(None, None)`.
    """
    for key in QUANTITY_KEYS:
        if isinstance(q := payload.get(key), dict):
            return q.get("value"), q.get("unit")
    return None, None


def csv_cell(value: Any) -> str:
    """Render one CSV cell; text that a spreadsheet would run as a formula is neutralised.

    Args:
        value: any cell value (None, UUID, date, datetime, bool, number, text).

    Returns:
        ISO 8601 for dates and times, "" for None, else `str(value)`; a leading `=`, `+`, `-`, `@`, tab or
        carriage return gets a `'` prefix (CSV formula injection, TODO B13 review).
    """
    text = value.isoformat() if isinstance(value, date) else "" if value is None else str(value)
    return f"'{text}" if text[:1] in ("=", "+", "-", "@", "\t", "\r") else text


def scrub(value: Any) -> Any:
    """Hide location and land-record values anywhere in a stored diff or payload (CLAUDE.md §6).

    Args:
        value: a JSON value (dict, list or scalar) as stored in `audit_log.diff` or a payload.

    Returns:
        A copy in which the value of every `HIDDEN_KEYS` key, at any depth, reads `[hidden]`; the key
        stays, so a reader still sees that it changed.
    """
    if isinstance(value, dict):
        return {k: "[hidden]" if k in HIDDEN_KEYS else scrub(v) for k, v in value.items()}
    return [scrub(v) for v in value] if isinstance(value, list) else value


@cache
def _log_valkey_down() -> None:
    """Warn once per process that scans are not being counted.

    Side effects:
        One WARNING log line (cached, so later calls do nothing).
    """
    log.warning("Valkey unreachable: public page scans are not counted until it is back")


async def limit_scans(
    redis: Redis, client_ip: str, now: float, kind: str = "scans", limit: int = SCAN_LIMIT
) -> None:
    """Count one scan against the caller's per-minute budget (fixed window, D-038).

    Args:
        redis: Valkey client.
        client_ip: the caller's address; only a hash of it reaches Valkey.
        now: current Unix time in seconds.
        kind: budget name in the key: `scans` (every scan) or `unknown` (codes no batch has).
        limit: hits allowed per window for this budget.

    Raises:
        RateLimitedError: more than `limit` hits on this budget from this address in the current window
            (`rate_limited`, 429, `details.retry_after_s` = seconds to the next window).
        redis.exceptions.RedisError: Valkey unreachable.

    Side effects:
        Increments `ratelimit:<kind>:<ip hash>:<window>` in Valkey; the key expires after one window.
    """
    # DECISION D-038: fixed one-minute window per IP hash in Valkey, a few lines on redis-py (no library).
    #   ADV: one INCR per scan; the window is in the key, so a lost EXPIRE never blocks past the minute.
    #   COMPROMISE: up to 2 × the limit across a window boundary; fine for counting page opens.
    window, elapsed = divmod(int(now), SCAN_WINDOW_S)
    key = f"ratelimit:{kind}:{hashlib.sha256(client_ip.encode()).hexdigest()[:16]}:{window}"
    hits = await redis.incr(key)
    if hits == 1:
        await redis.expire(key, SCAN_WINDOW_S)
    if hits > limit:
        raise RateLimitedError(details={"retry_after_s": SCAN_WINDOW_S - elapsed})


# --- shared SQL pieces ---------------------------------------------------------------------------------


def lot_complete() -> ColumnElement[bool]:
    """SQL test: the lot has a live event of every type in its crop's `event_schema.mandatory` (D-037).

    Correlates with `lots` and `crops`, so the enclosing query must have both in its FROM.

    Returns:
        A boolean expression; true also when the crop lists no mandatory types.
    """
    # DECISION D-037: completeness and stage progress are derived from live events and the crop's
    #   `event_schema`; nothing stores a lot's stage.
    #   ADV: no migration; the server rules' live-event rule; one SQL definition for both endpoints.
    #   COMPROMISE: correlated subqueries per lot; store a per-lot stage summary at tens of thousands of lots.
    mandatory = func.jsonb_array_elements_text(Crop.event_schema["mandatory"]).table_valued("value")
    ev = aliased(Event)
    # Two levels deep, auto-correlation would re-list `lots` and the list here; correlate them.
    recorded = (
        exists()
        .where(ev.lot_id == Lot.id, ev.event_type == mandatory.c.value, ev.status.not_in(DEAD_EVENTS))
        .correlate(Lot, mandatory)
    )
    return ~exists(select(mandatory.c.value).where(~recorded))


def _place(query: Select[*tuple[Any, ...]], f: Filters) -> Select[*tuple[Any, ...]]:
    """Join the farmer's village and apply the place filters (P06 district → block → village).

    Args:
        query: a select that already has `farmers` in its FROM.
        f: the filters; exact matches on the villages master (B13).

    Returns:
        The query with `villages` outer-joined and the filters applied.
    """
    query = query.outerjoin(Village, Village.id == Farmer.village_id)
    if f.district is not None:
        query = query.where(Village.district == f.district)
    if f.block is not None:
        query = query.where(Village.block == f.block)
    if f.village_id is not None:
        query = query.where(Farmer.village_id == f.village_id)
    return query


def _scoped_lots(fpo_id: uuid.UUID, f: Filters) -> Select[*tuple[Any, ...]]:
    """Select the FPO's lots in the filters with their status and completeness.

    Args:
        fpo_id: the FPO.
        f: the filters (crop and place).

    Returns:
        `SELECT lots.id, lots.farmer_id, lots.status, complete` (one row per lot), not executed.
    """
    query: Select[*tuple[Any, ...]] = (
        select(Lot.id, Lot.farmer_id, Lot.status, lot_complete().label("complete"))
        .join(Crop, Crop.id == Lot.crop_id)
        .join(Farmer, Farmer.id == Lot.farmer_id)
        .where(Lot.fpo_id == fpo_id)
    )
    if f.crop_id is not None:
        query = query.where(Lot.crop_id == f.crop_id)
    return _place(query, f)


# --- dashboard -----------------------------------------------------------------------------------------


async def _progress(
    session: AsyncSession, fpo_id: uuid.UUID, f: Filters
) -> tuple[Completeness, list[StageTile]]:
    """Count complete lots and per-stage done / in-progress / not-started lots in one query (D-037).

    Args:
        session: database session.
        fpo_id: the FPO.
        f: the filters.

    Returns:
        The completeness block and one tile per `STAGES` entry, in farm order.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    lots = _scoped_lots(fpo_id, f).subquery()
    stage_no = case({s: i for i, s in enumerate(STAGES)}, value=Event.event_type)
    per_lot = (
        select(
            lots.c.status,
            lots.c.complete,
            func.max(stage_no).label("furthest"),
            *(func.bool_or(Event.event_type == s).label(s.value) for s in STAGES),
        )
        .select_from(lots)
        .outerjoin(Event, and_(Event.lot_id == lots.c.id, Event.status.not_in(DEAD_EVENTS)))
        .group_by(lots.c.id, lots.c.status, lots.c.complete)
        .subquery()
    )
    in_field = per_lot.c.status.in_(IN_FIELD)
    cols = [func.count().label("lots"), func.count().filter(per_lot.c.complete).label("complete")]
    for i, s in enumerate(STAGES):
        has = per_lot.c[s.value].is_(True)  # a lot with stage i recorded has furthest >= i
        cols.append(func.count().filter(has, or_(per_lot.c.furthest > i, ~in_field)).label(f"{s}_done"))
        cols.append(func.count().filter(has, per_lot.c.furthest == i, in_field).label(f"{s}_doing"))
    m = (await session.execute(select(*cols).select_from(per_lot))).one()._mapping
    tiles = [
        StageTile(
            stage=s,
            done=m[f"{s}_done"],
            in_progress=m[f"{s}_doing"],
            not_started=m["lots"] - m[f"{s}_done"] - m[f"{s}_doing"],
        )
        for s in STAGES
    ]
    pct = percent(m["complete"], m["lots"])
    return Completeness(lots=m["lots"], complete_lots=m["complete"], complete=pct), tiles


def _area_stats(row: Any) -> dict[str, Any]:
    """Turn one land-area aggregate row into `AreaStats` fields.

    Args:
        row: a row with `plots, declared, walked_plots, walked, walked_declared, gi`.

    Returns:
        Keyword arguments for `AreaStats` and its subclasses.
    """
    return {
        "plots": row.plots,
        "declared_area": _acres(row.declared),
        "walked_plots": row.walked_plots,
        "walked_area": _acres(row.walked),
        "walked_declared_area": _acres(row.walked_declared),
        "gi_confirmed_area": _acres(row.gi),
        "gi_confirmed_share": percent(row.gi or 0, row.declared or 0),
    }


async def _land_area(session: AsyncSession, fpo_id: uuid.UUID, f: Filters) -> LandArea:
    """Sum plot areas in total, by block and by village (Land Area Analytics, P06).

    Args:
        session: database session.
        fpo_id: the FPO.
        f: the place filters (the crop filter does not apply: plots carry no crop).

    Returns:
        The land-area block, areas in acres; no plot locations (CLAUDE.md §6).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    walked = Plot.walked_area_acres.is_not(None)
    confirmed = Plot.location_status == LocationStatus.CONFIRMED
    sums = (
        func.count().label("plots"),
        func.sum(Plot.declared_area_acres).label("declared"),
        func.count(Plot.walked_area_acres).label("walked_plots"),
        func.sum(Plot.walked_area_acres).label("walked"),
        func.sum(Plot.declared_area_acres).filter(walked).label("walked_declared"),
        func.sum(Plot.declared_area_acres).filter(confirmed).label("gi"),
    )

    async def grouped(*keys: Any) -> list[Any]:
        """Run the area sums grouped by `keys` (none: one total row).

        Args:
            *keys: village columns to group and order by.

        Returns:
            The result rows.
        """
        query: Select[*tuple[Any, ...]] = (
            select(*keys, *sums).select_from(Plot).join(Farmer, Farmer.id == Plot.farmer_id)
        )
        query = _place(query.where(Plot.fpo_id == fpo_id), f)
        if keys:
            query = query.group_by(*keys).order_by(*keys)
        return list((await session.execute(query)).all())

    total = (await grouped())[0]
    blocks = await grouped(Village.block)
    villages = await grouped(Village.block, Village.name_en, Village.id)
    return LandArea(
        total=AreaStats(**_area_stats(total)),
        by_block=[AreaByBlock(block=r.block, **_area_stats(r)) for r in blocks],
        by_village=[
            AreaByVillage(village_id=r.id, village=r.name_en, block=r.block, **_area_stats(r))
            for r in villages
        ],
    )


async def _finished_goods(session: AsyncSession, fpo_id: uuid.UUID) -> tuple[FinishedGoods, Scans]:
    """List packed batches with their scans, and count the FPO's public page scans (FR20).

    Args:
        session: database session.
        fpo_id: the FPO.

    Returns:
        The Finished Goods block and the scan counts.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    fpo_codes = select(Batch.code).where(Batch.fpo_id == fpo_id)
    ours = ScanEvent.batch_code.in_(fpo_codes)
    since = utcnow() - WEEK
    total, recent = (
        await session.execute(
            select(func.count(), func.count().filter(ScanEvent.scanned_at >= since)).where(ours)
        )
    ).one()
    per_code = (
        select(ScanEvent.batch_code, func.count().label("n"))
        .where(ours)
        .group_by(ScanEvent.batch_code)
        .subquery()
    )
    finished = and_(Batch.fpo_id == fpo_id, Batch.status.in_(FINISHED))
    count, packed = (
        await session.execute(
            select(func.count(), func.coalesce(func.sum(Batch.packed_kg), 0)).where(finished)
        )
    ).one()
    rows = await session.execute(
        select(Batch.id, Batch.code, Batch.status, Batch.packed_kg, Batch.pack_date, per_code.c.n)
        .outerjoin(per_code, per_code.c.batch_code == Batch.code)
        .where(finished)
        .order_by(Batch.pack_date.desc().nulls_last(), Batch.id.desc())
        .limit(FINISHED_ROWS)
    )
    # remaining = packed: no sale or dispatch is recorded yet (TODO.md B11 line).
    items = [
        FinishedBatch(
            batch_id=r.id,
            code=r.code,
            status=r.status,
            packed=_kg(r.packed_kg),
            remaining=_kg(r.packed_kg),
            pack_date=r.pack_date,
            scans=r.n or 0,
        )
        for r in rows.all()
    ]
    goods = FinishedGoods(batches=count, packed=Quantity(value=packed, unit="kg"), items=items)
    return goods, Scans(total=total, last_7_days=recent)


async def _sync_health(session: AsyncSession, fpo_id: uuid.UUID) -> list[SyncHealthRow]:
    """Percentiles of phone sync timings by network type over the last 7 days (plan §13 F1).

    Args:
        session: database session.
        fpo_id: the FPO; metrics count when the reporting device's user is a member of it.

    Returns:
        One row per network type, ordered by network type.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    ack_ms = extract("epoch", SyncMetric.acked_at - SyncMetric.saved_at) * 1000

    def pct(q: float, col: Any) -> Any:
        """Build `percentile_cont(q) WITHIN GROUP (ORDER BY col)`; NULLs are ignored.

        Args:
            q: the fraction, e.g. 0.95.
            col: the measured expression.

        Returns:
            The aggregate expression.
        """
        return func.percentile_cont(q).within_group(col)

    rows = await session.execute(
        select(
            SyncMetric.network_type,
            func.count().label("entries"),
            pct(0.5, ack_ms).label("ack50"),
            pct(0.95, ack_ms).label("ack95"),
            pct(0.5, SyncMetric.photo_upload_ms).label("photo50"),
            pct(0.95, SyncMetric.photo_upload_ms).label("photo95"),
            func.coalesce(func.sum(SyncMetric.failures), 0).label("failures"),
        )
        .join(Device, Device.id == SyncMetric.device_id)
        .join(Membership, and_(Membership.user_id == Device.user_id, Membership.fpo_id == fpo_id))
        .where(SyncMetric.saved_at >= utcnow() - WEEK)
        .group_by(SyncMetric.network_type)
        .order_by(SyncMetric.network_type)
    )
    return [
        SyncHealthRow(
            network_type=r.network_type,
            entries=r.entries,
            save_to_ack_p50=_ms(r.ack50),
            save_to_ack_p95=_ms(r.ack95),
            photo_upload_p50=_ms(r.photo50),
            photo_upload_p95=_ms(r.photo95),
            failure_rate=percent(r.failures, r.failures + r.entries) or Quantity(value=Decimal(0), unit="%"),
        )
        for r in rows.all()
    ]


async def dashboard(session: AsyncSession, fpo_id: uuid.UUID, f: Filters) -> Dashboard:
    """Build the FPO dashboard (FR13, P06).

    Args:
        session: database session.
        fpo_id: the FPO, already checked against the caller's.
        f: filters for completeness, stage tiles and land area.

    Returns:
        Every dashboard section; amounts carry units (FR58).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    completeness, stages = await _progress(session, fpo_id, f)
    flags = dict(
        (
            await session.execute(
                select(Flag.severity, func.count())
                .where(Flag.fpo_id == fpo_id, Flag.status.in_(ACTIVE))
                .group_by(Flag.severity)
            )
        )
        .tuples()
        .all()
    )
    batches = dict(
        (
            await session.execute(
                select(Batch.status, func.count()).where(Batch.fpo_id == fpo_id).group_by(Batch.status)
            )
        )
        .tuples()
        .all()
    )
    finished, scans = await _finished_goods(session, fpo_id)
    return Dashboard(
        fpo_id=fpo_id,
        completeness=completeness,
        stages=stages,
        flags=FlagCounts(**{s.value: flags.get(s, 0) for s in Severity}),
        batches={s.value: batches.get(s, 0) for s in BatchStatus},
        land_area=await _land_area(session, fpo_id, f),
        finished_goods=finished,
        scans=scans,
        sync_health=await _sync_health(session, fpo_id),
    )


# --- per-farmer table ----------------------------------------------------------------------------------


async def farmer_fields(session: AsyncSession, fpo_id: uuid.UUID) -> set[str]:
    """Names `?fields=` may pick on the per-farmer table (conventions.md, plan §13 C4, D-017).

    Args:
        session: database session.
        fpo_id: the FPO whose tenant configuration applies.

    Returns:
        Every `FarmerRow` field except farmer fields the tenant's `fields/farmer.yaml` disables.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    code = await registry_service.fpo_code(session, fpo_id)
    configured = {f.name for f in fieldconfig.load().entities["farmer"].fields}
    hidden = configured - {f.name for f in fieldconfig.fields_for("farmer", code)}
    return set(FarmerRow.model_fields) - hidden


async def farmer_rows(
    session: AsyncSession, fpo_id: uuid.UUID, f: Filters, cursor: uuid.UUID | None, limit: int
) -> Page[FarmerRow]:
    """List the FPO's farmers with plot areas and lot completeness (P06 per-farmer table).

    Args:
        session: database session.
        fpo_id: the FPO, already checked against the caller's.
        f: place filters narrow the farmers; the crop filter narrows the lots counted.
        cursor: last farmer id of the previous page, or None.
        limit: page size.

    Returns:
        One page of rows, farmer id order (onboarding order, UUIDv7).

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    lots = _scoped_lots(fpo_id, Filters(crop_id=f.crop_id)).subquery()
    lot_counts = (
        select(
            lots.c.farmer_id, func.count().label("lots"), func.count().filter(lots.c.complete).label("done")
        )
        .group_by(lots.c.farmer_id)
        .subquery()
    )
    plots = (
        select(
            Plot.farmer_id,
            func.count().label("plots"),
            func.sum(Plot.declared_area_acres).label("declared"),
            func.sum(Plot.walked_area_acres).label("walked"),
        )
        .where(Plot.fpo_id == fpo_id)
        .group_by(Plot.farmer_id)
        .subquery()
    )
    query: Select[*tuple[Any, ...]] = select(
        Farmer.id,
        Farmer.code,
        Farmer.name,
        Farmer.name_local,
        Farmer.status,
        Farmer.village_id,
        Village.name_en,
        Village.block,
        plots.c.plots,
        plots.c.declared,
        plots.c.walked,
        lot_counts.c.lots,
        lot_counts.c.done,
    ).select_from(Farmer)
    query = _place(query.where(Farmer.fpo_id == fpo_id), f)
    query = query.outerjoin(plots, plots.c.farmer_id == Farmer.id)
    query = query.outerjoin(lot_counts, lot_counts.c.farmer_id == Farmer.id)
    if cursor is not None:
        query = query.where(Farmer.id > cursor)
    rows = list((await session.execute(query.order_by(Farmer.id).limit(limit + 1))).all())
    more = len(rows) > limit
    rows = rows[:limit]
    items = [
        FarmerRow(
            id=r.id,
            code=r.code,
            name=r.name,
            name_local=r.name_local,
            status=r.status,
            village_id=r.village_id,
            village=r.name_en,
            block=r.block,
            plots=r.plots or 0,
            declared_area=_acres(r.declared),
            walked_area=_acres(r.walked),
            lots=r.lots or 0,
            lots_complete=r.done or 0,
        )
        for r in rows
    ]
    return Page[FarmerRow](items=items, next_cursor=str(rows[-1].id) if more else None, has_more=more)


# --- audit log and export ------------------------------------------------------------------------------


def _owned_by(fpo_id: uuid.UUID) -> ColumnElement[bool]:
    """SQL test: the audit row describes a row of this FPO (D-039; `audit_log` has no `fpo_id`).

    Args:
        fpo_id: the FPO.

    Returns:
        True for rows about the FPO itself, about any row of a table with an `fpo_id` column that belongs
        to the FPO, or about an event version of the FPO's events. Rows about deleted rows or about
        untenanted tables (users, devices) are not matched.
    """
    # DECISION D-039: scope by the ownership of the described row, since `audit_log` has no `fpo_id`.
    #   ADV: exact isolation even for users in several FPOs; new tenant tables are covered automatically.
    #   COMPROMISE: rows about deleted or untenanted records (users, devices) are not shown.
    # shortcut: one IN-subquery per tenant table; add `audit_log.fpo_id` (set by the listener) when the
    #   audit viewer gets slow on a large log.
    tenant_tables = [t for t in Base.metadata.sorted_tables if "fpo_id" in t.c and "id" in t.c]
    versions = (
        select(EventVersion.id).join(Event, Event.id == EventVersion.event_id).where(Event.fpo_id == fpo_id)
    )
    return or_(
        and_(AuditLog.entity_type == "fpos", AuditLog.entity_id == fpo_id),
        and_(AuditLog.entity_type == "event_versions", AuditLog.entity_id.in_(versions)),
        *(
            and_(
                AuditLog.entity_type == t.name,
                AuditLog.entity_id.in_(select(t.c.id).where(t.c.fpo_id == fpo_id)),
            )
            for t in tenant_tables
        ),
    )


async def audit_rows(
    session: AsyncSession,
    fpo_id: uuid.UUID,
    where: list[ColumnElement[bool]],
    cursor: uuid.UUID | None,
    limit: int,
) -> Page[AuditRow]:
    """Search the audit log of one FPO, newest first (FR21, P06 Audit Log viewer).

    Args:
        session: database session.
        fpo_id: the caller's FPO.
        where: extra conditions on `AuditLog` built by the router from the search parameters.
        cursor: id of the last row of the previous page, or None.
        limit: page size.

    Returns:
        One page of rows; diffs as stored (secrets already `[redacted]`) except that location, boundary and
        land-record values read `[hidden]` (`scrub`); no device id or GPS column.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    query = select(AuditLog).where(_owned_by(fpo_id), *where)
    if cursor is not None:
        query = query.where(AuditLog.id < cursor)
    rows = list((await session.scalars(query.order_by(AuditLog.id.desc()).limit(limit + 1))).all())
    more = len(rows) > limit
    rows = rows[:limit]
    items = [AuditRow.model_validate(r, from_attributes=True) for r in rows]
    items = [i.model_copy(update={"diff": scrub(i.diff)}) for i in items]
    return Page[AuditRow](items=items, next_cursor=str(rows[-1].id) if more else None, has_more=more)


async def audit_csv(session: AsyncSession, fpo_id: uuid.UUID, batch_id: uuid.UUID) -> tuple[str, str]:
    """Export every version of every event of a batch and its component lots as CSV (FR21, FR58).

    Args:
        session: database session.
        fpo_id: the caller's FPO.
        batch_id: the batch.

    Returns:
        `(batch code, CSV text)`: a header row (`CSV_COLUMNS`) then one row per event version, ordered by
        event date, event and version. `entered_by` is the user id (name in `entered_by_name`, never the
        phone); `quantity` and `unit` are separate columns.

    Raises:
        NotFoundError: no such batch in the caller's FPO (404).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.
    """
    batch = await session.get(Batch, batch_id)
    if batch is None or batch.fpo_id != fpo_id:
        raise NotFoundError()
    lots = select(BatchShare.lot_id).where(BatchShare.batch_id == batch.id)
    rows = await session.execute(
        select(EventVersion, Event.subject_type, Event.event_type, Lot.code, User.name)
        .join(Event, Event.id == EventVersion.event_id)
        .outerjoin(Lot, Lot.id == Event.lot_id)
        .join(User, User.id == EventVersion.entered_by_user_id)
        .where(or_(Event.batch_id == batch.id, Event.lot_id.in_(lots)))
        .order_by(Event.occurred_on, EventVersion.event_id, EventVersion.version_no)
    )
    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(CSV_COLUMNS)
    for v, subject, event_type, lot_code, name in rows.tuples().all():
        value, unit = main_quantity(v.payload)
        cells = (
            subject,
            lot_code or batch.code,
            v.event_id,
            event_type,
            v.id,
            v.version_no,
            v.change_kind,
            v.occurred_on,
            v.occurred_end_on,
            v.device_time,
            v.server_received_at,
            v.entered_by_user_id,
            name,
            v.on_behalf_of_farmer_id,
            v.assist_session_id,
            v.entered_remotely,
            v.is_system_generated,
            v.reason_code,
            v.reason_text,
            value,
            unit,
            json.dumps(scrub(v.payload), ensure_ascii=False, sort_keys=True),
        )
        writer.writerow([csv_cell(c) for c in cells])
    return batch.code, out.getvalue()


# --- public scans --------------------------------------------------------------------------------------


async def record_scan(session: AsyncSession, batch_code: str, user_agent: str | None, client_ip: str) -> None:
    """Count one anonymous open of a public batch page (FR20), within the per-IP rate limits (D-038).

    Args:
        session: database session (the router commits).
        batch_code: code from the scanned URL (Crockford pattern checked by the router); codes no batch
            has are still counted, under the tighter `UNKNOWN_SCAN_LIMIT`.
        user_agent: the `User-Agent` header, stored only as a SHA-256 hash.
        client_ip: the caller's address; used for the rate limits only and never stored.

    Raises:
        RateLimitedError: over 100 scans, or over 10 scans of unknown codes, from this address this minute
            (`rate_limited`, 429).
        sqlalchemy.exc.SQLAlchemyError: passed through from the database.

    Side effects:
        One or two Valkey INCRs (plus EXPIRE on a first hit); one indexed batch lookup; adds a `scan_events`
        row to the session. When Valkey is unreachable nothing is stored (logged once per process).
    """
    code = batch_code.upper()
    # shortcut: one short-lived Valkey connection per scan, like the health check; share a pool if scans
    #   ever reach hundreds per second.
    redis = Redis.from_url(get_settings().redis_url)
    try:
        now = utcnow().timestamp()
        await limit_scans(redis, client_ip, now)
        if await session.scalar(select(Batch.id).where(Batch.code == code)) is None:
            await limit_scans(redis, client_ip, now, kind="unknown", limit=UNKNOWN_SCAN_LIMIT)
    except RedisError:
        # A beacon must not fail; without its limiter the scan is dropped rather than stored unbounded.
        _log_valkey_down()
        return
    finally:
        await redis.aclose()
    ua_hash = hashlib.sha256(user_agent.encode()).hexdigest() if user_agent else None
    session.add(ScanEvent(batch_code=code, scanned_at=utcnow(), user_agent_hash=ua_hash))
