"""Shared Pydantic building blocks reused by every module's request and response schemas.

Serves: FR58 (quantities always carry units), Arch §Offline-first (three clocks, client UUIDs, D-005),
plan §7.1 ground rules (error envelope), docs/api/conventions.md (cursor pages).
Callers: `modules/*/schemas.py` (B01+), `core.time`, `core.errors` envelope docs, `agritrace.main`.
"""

from decimal import Decimal
from typing import Any
from uuid import UUID

from pydantic import AwareDatetime, BaseModel, Field


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
