"""Shared Pydantic building blocks reused by every module's request and response schemas.

Serves: FR58 (quantities always carry units), Arch §Offline-first (three clocks, client UUIDs, D-005),
plan §7.1 ground rules (error envelope), docs/api/conventions.md (cursor pages), FR53 (structured address),
FR56 (practice tags), FR60 (per-lot reconciliation), FR68 (yield check) — the last four are the shapes of
JSONB columns (`*.address`, `lots.practice_tags`, `lot_intakes.reconciliation`, `lot_intakes.yield_check`).
Callers: `modules/*/schemas.py` (B01+), registry / lots_batches / rules_flags services (B03, B08, B09),
`core.time`, `core.audit`, `core.errors` envelope docs, `agritrace.main`.
"""

from decimal import Decimal
from typing import Any, Literal
from uuid import UUID

from pydantic import AwareDatetime, BaseModel, Field

from agritrace.core.enums import PracticeTag


class Quantity(BaseModel):
    """A non-negative amount with its unit (FR58): never a bare number."""

    value: Decimal = Field(ge=0, description="Amount; decimal string or number, never negative.")
    unit: str = Field(min_length=1, max_length=16, description="Unit code, e.g. `kg`, `acre`, `l`, `count`.")


class SignedQuantity(Quantity):
    """A quantity that may be negative, used only for adjustments and differences."""

    value: Decimal = Field(description="Amount; negative allowed (adjustment or difference).")


class GeoPoint(BaseModel):
    """A WGS84 point with the device's reported accuracy."""

    lat: float = Field(ge=-90, le=90, description="Latitude in decimal degrees (WGS84).")
    lon: float = Field(ge=-180, le=180, description="Longitude in decimal degrees (WGS84).")
    accuracy_m: float | None = Field(None, ge=0, description="Horizontal accuracy radius in metres.")


class ThreeClocks(BaseModel):
    """The three timestamps kept for every offline capture (device, GPS, server)."""

    device_time: AwareDatetime = Field(description="Phone clock at capture, ISO 8601 with offset.")
    gps_time: AwareDatetime | None = Field(None, description="GPS fix time at capture, if a fix was taken.")
    server_received_at: AwareDatetime | None = Field(
        None, description="Set by the server when the entry arrives; clients leave it empty."
    )


class ClientRef(BaseModel):
    """Client-generated UUID that is both primary key and idempotency key (D-005)."""

    client_id: UUID = Field(description="UUIDv7 generated on the device; resending it is a no-op.")


class Page[T](BaseModel):
    """One page of a cursor-paginated list."""

    items: list[T] = Field(description="Items on this page, in the endpoint's documented order.")
    next_cursor: str | None = Field(None, description="Opaque cursor for the next page; null on the last.")
    has_more: bool = Field(description="True when another page exists.")


class ErrorBody(BaseModel):
    """Inner object of the error envelope."""

    code: str = Field(description="Registered snake_case error code (docs/api/error-codes.md).")
    message: str = Field(description="English message; clients show their own en/ta text for `code`.")
    details: Any = Field(None, description="Context such as failing fields, ids or limits; may be null.")


class ErrorEnvelope(BaseModel):
    """Shape of every error response: `{"error": {"code", "message", "details"}}`."""

    error: ErrorBody = Field(description="The error.")


class Address(BaseModel):
    """Structured address of a farmer, plot, FPO or processor (FR53); also a second GI check by taluk.

    Every part is optional here: which parts are required is field configuration (D-017, B13).
    """

    village: str | None = Field(None, max_length=120, description="Village or hamlet name.")
    block: str | None = Field(None, max_length=120, description="Block or taluk (sub-district).")
    district: str | None = Field(None, max_length=120, description="District, e.g. `Virudhunagar`.")
    state: str | None = Field(None, max_length=120, description="State, e.g. `Tamil Nadu`.")
    pin: str | None = Field(None, pattern=r"^[1-9][0-9]{5}$", description="Six-digit Indian PIN code.")


class PracticeTags(BaseModel):
    """Farming practice tags of a lot: what the farmer declared versus what the inputs used imply (FR56)."""

    declared: list[PracticeTag] = Field(default_factory=list, description="Tags the farmer declared.")
    derived: list[PracticeTag] = Field(
        default_factory=list, description="Tags derived from the categories of inputs actually applied."
    )
    contradiction: bool = Field(
        False, description="True when a declared tag conflicts with the derived ones (raises a flag)."
    )


class Reconciliation(BaseModel):
    """Per-lot quantity chain: harvested ≥ packed ≥ received by the processor ≥ used in batches (FR60)."""

    harvested: Quantity | None = Field(None, description="Sum of harvest event quantities; null if none.")
    packed: Quantity | None = Field(None, description="On-farm packed quantity; null if not recorded.")
    received: Quantity | None = Field(None, description="Quantity the processor received at intake.")
    used: Quantity | None = Field(None, description="Quantity of this lot used in batches.")
    in_order: bool = Field(description="True when every recorded step is ≤ the one before it.")


class YieldCheck(BaseModel):
    """Harvest versus declared area × the profile's yield ceiling, with the 20 %/30 % margins (FR68)."""

    declared_area: Quantity | None = Field(None, description="Declared plot area (unit `acre`).")
    harvested: Quantity | None = Field(None, description="Harvested quantity of the lot (unit `kg`).")
    ceiling: Quantity | None = Field(
        None, description="Plausible maximum yield per acre from the standards profile (unit `kg/acre`)."
    )
    excess_pct: Decimal | None = Field(
        None, description="Percent above declared area × ceiling; negative when below; null if unavailable."
    )
    outcome: Literal["ok", "warn", "hold", "unavailable"] = Field(
        description="ok within the warn margin, warn up to the hold margin, hold above; unavailable: no data."
    )
