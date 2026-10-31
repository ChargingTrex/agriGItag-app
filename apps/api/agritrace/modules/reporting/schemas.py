"""Response models of the reporting routes: FPO dashboard, per-farmer table and audit log rows.

Serves: FR13 (FPO dashboard), FR20 (scan analytics), FR21 (audit export / viewer), FR58 (every amount
carries its unit), plan §7.3 P06 (stage tiles, Land Area Analytics, Finished Goods, Audit Log viewer,
Sync health, plan §13 F1), D-037 (stage-progress and completeness semantics).
Callers: `reporting.router` and `reporting.service`; the OpenAPI document (generated clients, D-003).
Other modules may not import this file (D-004).
"""

import uuid
from datetime import date, datetime
from typing import Any

from pydantic import BaseModel, Field

from agritrace.core.enums import BatchStatus, FarmerStatus
from agritrace.core.schemas import Quantity


class Completeness(BaseModel):
    """Share of lots that have every mandatory event of their crop (D-037)."""

    lots: int = Field(description="Lots in scope (count).")
    complete_lots: int = Field(
        description="Lots with a live event of every type in `event_schema.mandatory`."
    )
    complete: Quantity | None = Field(
        description="complete_lots ÷ lots, unit `%`, one decimal; null when there are no lots."
    )


class StageTile(BaseModel):
    """Lot counts for one farm stage (D-037); done + in_progress + not_started = lots in scope."""

    stage: str = Field(description="Event type of the stage, e.g. `land_preparation`, `harvest`.")
    done: int = Field(description="Lots with this stage recorded and a later stage reached (count).")
    in_progress: int = Field(
        description="Lots whose furthest recorded stage is this one while the lot is still in the field."
    )
    not_started: int = Field(description="Lots with no live event of this stage (count).")


class FlagCounts(BaseModel):
    """Active (open or escalated) flags of the FPO by severity."""

    info: int = Field(description="Active `info` flags (count).")
    warn: int = Field(description="Active `warn` flags (count).")
    hold: int = Field(description="Active `hold` flags; each blocks GI labelling (count).")


class AreaStats(BaseModel):
    """Plot areas of a group of plots (Land Area Analytics); areas only, never locations (CLAUDE.md §6)."""

    plots: int = Field(description="Plots (count).")
    declared_area: Quantity = Field(description="Sum of declared areas, unit `acre`.")
    walked_plots: int = Field(description="Plots with a GPS-walked boundary (count).")
    walked_area: Quantity = Field(description="Sum of walked areas, unit `acre`.")
    walked_declared_area: Quantity = Field(
        description="Declared area of the walked plots only, unit `acre`; compare with `walked_area`."
    )
    gi_confirmed_area: Quantity = Field(
        description="Declared area of plots whose location is `confirmed` inside the GI region, unit `acre`."
    )
    gi_confirmed_share: Quantity | None = Field(
        description="gi_confirmed_area ÷ declared_area, unit `%`; null when declared_area is 0."
    )


class AreaByVillage(AreaStats):
    """Plot areas of one village (the farmer's village from the villages master)."""

    village_id: uuid.UUID | None = Field(description="Village id; null groups farmers without a village.")
    village: str | None = Field(description="Village name in English.")
    block: str | None = Field(description="Development block of the village.")


class AreaByBlock(AreaStats):
    """Plot areas of one development block."""

    block: str | None = Field(description="Development block; null groups farmers without a village/block.")


class LandArea(BaseModel):
    """Land Area Analytics: acres by village and block, declared vs walked, GI-confirmed share."""

    total: AreaStats = Field(description="All plots in scope.")
    by_block: list[AreaByBlock] = Field(description="One row per block, by block name.")
    by_village: list[AreaByVillage] = Field(description="One row per village, by block then village name.")


class FinishedBatch(BaseModel):
    """A packed or published batch in the Finished Goods inventory."""

    batch_id: uuid.UUID = Field(description="Batch id.")
    code: str = Field(description="Batch code printed on the label.")
    status: BatchStatus = Field(description="`packed` or `published`.")
    packed: Quantity | None = Field(description="Quantity in final packs, unit `kg`; null if not recorded.")
    remaining: Quantity | None = Field(
        description="Quantity still in stock, unit `kg`; equals `packed` until sales are recorded."
    )
    pack_date: date | None = Field(description="Pack date on the label.")
    scans: int = Field(description="Public page scans of this batch code (count, FR20).")


class FinishedGoods(BaseModel):
    """Finished Goods: packed batches and their quantities."""

    batches: int = Field(description="Packed or published batches (count).")
    packed: Quantity = Field(description="Total in final packs, unit `kg`.")
    items: list[FinishedBatch] = Field(description="Newest 100 batches, latest pack date first.")


class Scans(BaseModel):
    """Public page scans of the FPO's batch codes (FR20)."""

    total: int = Field(description="All scans (count).")
    last_7_days: int = Field(description="Scans in the last 7 days (count).")


class SyncHealthRow(BaseModel):
    """Phone sync timings of one network type over the last 7 days (plan §13 F1)."""

    network_type: str | None = Field(
        description="Network at send time, e.g. `2g`, `lte`, `wifi`; null if unknown."
    )
    entries: int = Field(description="Entries measured (count).")
    save_to_ack_p50: Quantity | None = Field(description="Median phone save → server ack time, unit `ms`.")
    save_to_ack_p95: Quantity | None = Field(description="95th percentile save → ack time, unit `ms`.")
    photo_upload_p50: Quantity | None = Field(description="Median photo upload time, unit `ms`.")
    photo_upload_p95: Quantity | None = Field(description="95th percentile photo upload time, unit `ms`.")
    failure_rate: Quantity = Field(
        description="Failed send attempts ÷ all send attempts (failures + entries), unit `%`."
    )


class Dashboard(BaseModel):
    """FPO dashboard (FR13, P06). Filters narrow completeness, stage tiles and land area only."""

    fpo_id: uuid.UUID = Field(description="FPO the numbers are for.")
    completeness: Completeness = Field(description="Lots with all mandatory events ÷ lots.")
    stages: list[StageTile] = Field(description="Stage-progress tiles in farm order.")
    flags: FlagCounts = Field(description="Active flags by severity (whole FPO).")
    batches: dict[str, int] = Field(description="Batches by status (whole FPO), every status present.")
    land_area: LandArea = Field(description="Land Area Analytics.")
    finished_goods: FinishedGoods = Field(description="Finished Goods inventory (whole FPO).")
    scans: Scans = Field(description="Public page scans (whole FPO).")
    sync_health: list[SyncHealthRow] = Field(
        description="Sync timings by network type, last 7 days, from devices of the FPO's members; a "
        "member of several FPOs is counted in each."
    )


class FarmerRow(BaseModel):
    """One row of the per-farmer dashboard table; no phone, address or plot location (CLAUDE.md §6)."""

    id: uuid.UUID = Field(description="Farmer id.")
    code: str = Field(description="Farmer code, unique in the FPO.")
    name: str = Field(description="Name in English script.")
    name_local: str | None = Field(description="Name in the local script.")
    status: FarmerStatus = Field(description="Onboarding status.")
    village_id: uuid.UUID | None = Field(description="Village from the villages master, if picked.")
    village: str | None = Field(description="Village name in English.")
    block: str | None = Field(description="Development block of the village.")
    plots: int = Field(description="Plots (count).")
    declared_area: Quantity = Field(description="Sum of declared plot areas, unit `acre`.")
    walked_area: Quantity = Field(description="Sum of walked plot areas, unit `acre`.")
    lots: int = Field(description="Lots, of the `crop_id` filter when given (count).")
    lots_complete: int = Field(description="Of those, lots with every mandatory event (count, D-037).")


class AuditRow(BaseModel):
    """One `audit_log` row; device id and GPS columns are left out, location values in `diff` are hidden."""

    id: uuid.UUID = Field(description="Audit row id (UUIDv7, time-ordered).")
    at: datetime = Field(description="When the change was written (UTC).")
    actor_user_id: uuid.UUID | None = Field(description="User who made the change; null for system jobs.")
    on_behalf_of_farmer_id: uuid.UUID | None = Field(description="Farmer the actor entered data for.")
    assist_session_id: uuid.UUID | None = Field(description="Assist session in force, if any.")
    action: str = Field(description="`create`, `update`, `delete` or a named action such as `event.correct`.")
    entity_type: str = Field(description="Table name of the changed row, e.g. `farmers`, `event_versions`.")
    entity_id: uuid.UUID | None = Field(description="Primary key of the changed row.")
    diff: dict[str, Any] = Field(
        description="What changed, as stored; secret columns read `[redacted]`, location, boundary and "
        "land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, ...) read `[hidden]`."
    )
    request_id: str | None = Field(description="Request id for correlating with API logs.")
