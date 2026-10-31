"""Inputs and output of the rule functions: the facts a rule reads and the flag it proposes.

Rules stay pure: the service loads rows, does the PostGIS work (event on plot) and fills these frozen
dataclasses; each `rules/<rule>.py` turns one context into `FlagCandidate`s.
Serves: Arch §Rules and flags, plan §7.1 B08, D-006 (server rules are the authority).
Callers: rules_flags service (builds contexts, stores candidates as `flags`), every `rules/*.py`,
tests/unit/test_rules_*.py.
"""

import uuid
from dataclasses import dataclass, field
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from agritrace.core.enums import FlagSubject, LocationStatus, PhotoStatus, PinMethod, Severity


@dataclass(frozen=True, slots=True)
class FlagCandidate:
    """A finding one rule proposes; the service turns it into a `flags` row (deduped)."""

    subject_type: FlagSubject
    subject_id: uuid.UUID
    rule_code: str
    severity: Severity
    details: dict[str, Any] = field(default_factory=dict)
    # Tells two findings of one rule on one subject apart (e.g. the photo id); empty when one is enough.
    discriminator: str = ""


@dataclass(frozen=True, slots=True)
class PhotoFacts:
    """An evidence photo of the event version being checked (status set by `events.verify_photo`)."""

    id: uuid.UUID
    status: PhotoStatus
    exif_taken_at: datetime | None = None


@dataclass(frozen=True, slots=True)
class EventContext:
    """One event's current version, for the event-level rules (Stages 1–7, FR26, FR61, FR69)."""

    event_id: uuid.UUID
    occurred_on: date
    device_time: datetime
    server_received_at: datetime
    occurred_end_on: date | None = None
    gps_time: datetime | None = None
    gps_accuracy_m: float | None = None
    on_plot: bool | None = None  # None: no GPS fix or no plot, so nothing to compare
    pin_radius_m: float = 0
    buffer_m: float = 0
    photos: tuple[PhotoFacts, ...] = ()


@dataclass(frozen=True, slots=True)
class LotEvent:
    """A live (not undone, not superseded) farm event of a lot: its type and the day it happened."""

    id: uuid.UUID
    type: str
    on: date


@dataclass(frozen=True, slots=True)
class ReadingFacts:
    """A quality reading accepted with a `reason_code` (a trail override, FR50)."""

    id: uuid.UUID
    parameter: str
    stage: str
    value: Decimal
    reason_code: str


@dataclass(frozen=True, slots=True)
class LotContext:
    """A lot with its events, inputs, quantities and profile yield rule, for the lot-level rules."""

    lot_id: uuid.UUID
    event_schema: dict[str, Any] = field(default_factory=dict)
    events: tuple[LotEvent, ...] = ()
    declared_tags: tuple[str, ...] = ()
    input_categories: tuple[str, ...] = ()
    has_pest_event: bool = False
    harvested_kg: Decimal | None = None
    packed_kg: Decimal | None = None
    received_kg: Decimal | None = None
    used_kg: Decimal | None = None
    declared_acres: Decimal | None = None
    # (ceiling kg/acre, warn margin %, hold margin %) from the Standards Profile; None when it has none.
    yield_limits: tuple[Decimal, Decimal, Decimal] | None = None
    trail_overrides: tuple[ReadingFacts, ...] = ()


@dataclass(frozen=True, slots=True)
class BatchContext:
    """A batch with its farmer shares, output quantity and latest grade computation."""

    batch_id: uuid.UUID
    shares_kg: Decimal | None = None  # sum of batch_shares.kg_contributed; None when no share exists
    batch_kg: Decimal | None = None  # packed, else graded, else received quantity of the batch
    profile_incomplete: tuple[str, ...] = ()
    trail_overrides: tuple[ReadingFacts, ...] = ()


@dataclass(frozen=True, slots=True)
class PlotContext:
    """A plot as onboarded, with its GI region check result and the GI registration's taluks."""

    plot_id: uuid.UUID
    pin_method: PinMethod
    location_status: LocationStatus
    declared_acres: Decimal
    review_outcome: str | None = None
    pin_accuracy_m: float | None = None
    walked_acres: Decimal | None = None
    taluk: str | None = None
    region_taluks: tuple[str, ...] | None = None
