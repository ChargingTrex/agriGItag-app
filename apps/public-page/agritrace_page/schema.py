"""Public batch record: the complete allow-list of what a public QR page may show.

Purpose: one Pydantic v2 model tree that describes, field by field, everything the static
public page and its ``data.json`` may contain, and that refuses anything personal.
Requirements: PRD FR15-FR19 (public page), FR30 (GI boundary indicator), FR51 (grade, standard,
readings, lab badge), FR53 (structured address), FR54, FR56-FR63 (units, share %, compliance ids,
date order, event counts), FR72 (location method); Arch §Security, privacy and consent;
CLAUDE.md §6 privacy invariants.
Callers: ``agritrace_page.render.render`` validates every record through ``PublicBatchRecord``;
the backend page builder (B10) builds a ``PublicBatchRecord`` and the portal preview posts one.
"""

import datetime as dt
import re
from typing import Annotated, Any, Literal, get_args

from pydantic import (
    AfterValidator,
    AwareDatetime,
    BaseModel,
    ConfigDict,
    Field,
    computed_field,
    field_validator,
    model_validator,
)

# DECISION D-017: this schema is the "visibility: public" allow-list; anything not declared here
#   cannot reach the page (extra="forbid"), so a new internal field is private by default.
#   ADV: privacy is enforced where the page is built, not trusted to every caller (Arch §Security).
#   COMPROMISE: a field made public in YAML also needs a field here; that review step is intended.
# hide_input_in_errors keeps a rejected phone number out of the ValidationError text and the logs.
# revalidate_instances="always" re-runs every check on a model instance passed to render(), so a
# field changed after construction (review r1 P1-1) cannot skip the privacy check.
_CONFIG = ConfigDict(
    extra="forbid",
    hide_input_in_errors=True,
    str_strip_whitespace=True,
    revalidate_instances="always",
)

# Privacy patterns (CLAUDE.md §6). Unknown keys and number/coordinate arrays need no pattern:
# extra="forbid" and the field types already refuse them.
# Number patterns run on a copy with spaces and dashes removed, so "987 654 3210" and
# "98765-43210" are caught. Digit lookarounds (not \b) also catch digits glued to letters or
# Tamil text, and still pass longer ids such as 14-digit FSSAI numbers.
_NUMBER_PATTERNS = {
    "phone number": re.compile(r"(?<!\d)(?:\+?91|0)?[6-9]\d{9}(?!\d)"),
    "Aadhaar-like number": re.compile(r"(?<!\d)[2-9]\d{11}(?!\d)"),
}
# These also run on URLs: a coordinate pair or polygon can hide in a URL path or query.
_TEXT_PATTERNS = {
    "land record reference": re.compile(
        r"(?i)\b(?:s\.?\s*f\.?|sy\.?|survey)\s*(?:no|number)\b|\bpatta\b|\bchitta\b"
    ),
    "boundary polygon": re.compile(r"(?i)polygon"),
    "precise coordinates": re.compile(r"-?\d{1,3}\.\d{4,}\s*,\s*-?\d{1,3}\.\d{4,}"),
}
_TEMP_PATH = re.compile(r"temp_uploads|/tmp/")
# Photo URLs must point into the permanent evidence bucket (FR61), never a temporary path.
_EVIDENCE_URL = r"^https?://[^\s/]+/(?:[^\s]*/)?evidence/[^\s]+$"

Stage = Literal[
    "land_preparation",
    "nursery_preparation",
    "sowing",
    "input_application",
    "harvest",
    "drying",
    "farm_packing",
    "sale_to_processor",
    "grading",
    "processing_packing",
]


def _privacy_violation(value: Any, path: str = "record") -> str | None:
    """Find the first personal or unsafe text anywhere in a record.

    Args:
        value: Any JSON-like value (dict, list, str, number, bool, None) or a model instance.
        path: Dotted location of ``value`` in the record, used in the message.

    Returns:
        A message naming the kind of problem and its path (never the offending value),
        or None when ``value`` is clean.

    Raises:
        Nothing.
    """
    if isinstance(value, BaseModel):  # a caller may pass models, e.g. Lot(...) or a whole record
        value = value.model_dump(mode="json")
    if isinstance(value, dict):
        items = ((f"{path}.{k}", v) for k, v in value.items())
    elif isinstance(value, list | tuple):
        items = ((f"{path}[{n}]", v) for n, v in enumerate(value))
    elif isinstance(value, str):
        if _TEMP_PATH.search(value):
            return f"temporary storage path at {path}"
        checks = dict(_TEXT_PATTERNS)
        # URLs are system-generated; hash digits in them would false-positive the number checks.
        if not value.startswith(("http://", "https://")):
            checks |= _NUMBER_PATTERNS
        compact = re.sub(r"[\s-]", "", value)
        for kind, pattern in checks.items():
            if pattern.search(compact if kind in _NUMBER_PATTERNS else value):
                return f"{kind} at {path}"
        return None
    else:
        return None
    return next((found for p, v in items if (found := _privacy_violation(v, p))), None)


class Quantity(BaseModel):
    """A number that is never shown without its unit (FR58)."""

    model_config = _CONFIG
    value: float = Field(ge=0, description="Numeric amount, e.g. 320.")
    unit: str = Field(
        min_length=1, max_length=12, description="Unit shown after the value: kg, acre, %."
    )


class Reading(BaseModel):
    """One quality reading and where it came from (FR42, FR51)."""

    model_config = _CONFIG
    parameter: str = Field(min_length=1, description="Parameter name in English, e.g. 'Moisture'.")
    value: float = Field(description="Measured value.")
    unit: str = Field(min_length=1, max_length=12, description="Unit of the value, e.g. '%'.")
    source: Literal["lab", "instrument", "visual"] = Field(
        description="Measurement source: accredited lab, calibrated instrument, or visual check."
    )


class Photo(BaseModel):
    """An evidence photo: two server-made WebP variants plus the original JPEG (plan §13 B6, E2).

    The builder (B10) takes ``thumb_url``, ``medium_url``, ``width`` and ``height`` from the
    variants the server records after a photo is verified (B06 ``evidence_photos.variants``), and
    ``jpeg_url`` from the original evidence object.
    """

    model_config = _CONFIG
    thumb_url: str = Field(
        pattern=_EVIDENCE_URL, description="WebP thumbnail (~60 KB, B06 variant) URL."
    )
    medium_url: str = Field(pattern=_EVIDENCE_URL, description="WebP medium (~150 KB) URL, on tap.")
    jpeg_url: str = Field(
        pattern=_EVIDENCE_URL,
        description="Original evidence JPEG object URL (~350 KB after phone compression); "
        "fallback for browsers without WebP.",
    )
    width: int = Field(
        gt=0, description="Thumbnail width in pixels, from the B06 variants record (layout space)."
    )
    height: int = Field(
        gt=0, description="Thumbnail height in pixels, from the B06 variants record."
    )
    alt: str = Field(min_length=1, description="Text alternative describing the photo.")


class Place(BaseModel):
    """Structured public address, village level only (FR53)."""

    model_config = _CONFIG
    village: str = Field(min_length=1, description="Village name.")
    block: str = Field(min_length=1, description="Block or taluk.")
    district: str = Field(min_length=1, description="District.")
    state: str = Field(min_length=1, description="State.")


class GeoPoint(BaseModel):
    """Farm pin, coarsened before it can reach the page (FR18, Arch §Security)."""

    model_config = _CONFIG
    lat: float = Field(ge=-90, le=90, description="Latitude, rounded to 3 decimal places (~100 m).")
    lon: float = Field(ge=-180, le=180, description="Longitude, rounded to 3 decimal places.")

    # DECISION D-017: round the pin here instead of trusting the caller to do it.
    #   ADV: no exact plot location can be published whatever the builder sends (CLAUDE.md §6).
    #   COMPROMISE: ~100 m precision; 3 dp awaits product/privacy sign-off (TODO.md §2).
    @field_validator("lat", "lon")
    @classmethod
    def _coarsen(cls, v: float) -> float:
        """Round a coordinate to 3 decimal places.

        Args:
            v: Raw coordinate in decimal degrees.

        Returns:
            The coordinate rounded to 3 decimal places.

        Raises:
            Nothing.
        """
        return round(v, 3)


class InputUsed(BaseModel):
    """A farm input from the input master list (FR56)."""

    model_config = _CONFIG
    name_en: str = Field(min_length=1, description="Input name in English.")
    name_local: str = Field(min_length=1, description="Input name in the local language.")
    manufacturer: str | None = Field(None, description="Manufacturer, when known.")


class Event(BaseModel):
    """One farming or processing event instance (FR16, FR59, FR63)."""

    model_config = _CONFIG
    stage: Stage = Field(description="Stage key; its bilingual label comes from i18n/*.json.")
    instance_no: int = Field(ge=1, description="Instance number within the stage (1, 2, ...).")
    date: dt.date = Field(description="Event date, or start date for a range such as drying.")
    end_date: dt.date | None = Field(None, description="End date for a range event, else null.")
    quantity: Quantity | None = Field(None, description="Quantity handled, with unit (FR57, FR58).")
    input: InputUsed | None = Field(None, description="Input applied, for input events (FR56).")
    seed_variety: str | None = Field(None, description="Seed variety, for nursery/sowing events.")
    moisture: Reading | None = Field(None, description="Moisture reading, e.g. end of drying.")
    status: Literal["complete", "in_progress"] = Field(description="Event status (FR59).")
    system_generated: bool = Field(
        description="True when the system, not a person, made the entry."
    )
    comment: str | None = Field(None, description="Public comment, e.g. a system status note.")
    photos: list[Photo] = Field(default_factory=list, description="Evidence photos for the event.")

    @model_validator(mode="after")
    def _range_order(self) -> "Event":
        """Reject a range that ends before it starts.

        Returns:
            The event unchanged.

        Raises:
            ValueError: When ``end_date`` is earlier than ``date``.
        """
        if self.end_date and self.end_date < self.date:
            raise ValueError("end_date is before date")
        return self


# Stage literals are listed in field order, so their position is the crop-cycle order.
_STAGE_ORDER = {stage: n for n, stage in enumerate(get_args(Stage))}


def _by_date(events: list[Event]) -> list[Event]:
    """Order events by date, stage, then instance (FR63; PRD §12.2 'instances out of order').

    Same-day events of different stages keep the crop-cycle order B10 sends (B10 report risk),
    e.g. harvest before drying, instead of being reordered by instance number.

    Args:
        events: Events in any order.

    Returns:
        A new list in ascending (date, stage order, instance_no) order.

    Raises:
        Nothing.
    """
    return sorted(events, key=lambda e: (e.date, _STAGE_ORDER[e.stage], e.instance_no))


Timeline = Annotated[list[Event], AfterValidator(_by_date)]


class Grade(BaseModel):
    """Computed grade and the evidence behind it (FR48, FR51)."""

    model_config = _CONFIG
    grade: str = Field(min_length=1, description="Computed grade, e.g. 'Standard'.")
    standard_name: str = Field(min_length=1, description="Standard graded against.")
    edition: str = Field(min_length=1, description="Edition of the standard.")
    clause: str = Field(min_length=1, description="Clause or schedule, e.g. 'Schedule IV'.")
    readings: list[Reading] = Field(min_length=1, description="Key readings (moisture, colour).")
    lab_certified: bool = Field(
        description="True only when an accredited lab result is attached; needs a 'lab' reading."
    )
    lab_name: str | None = Field(None, description="Lab name; allowed only when lab_certified.")

    @model_validator(mode="after")
    def _lab_claim_backed(self) -> "Grade":
        """Show the Lab-certified badge and lab name only with a lab result behind them (FR51).

        Returns:
            The grade unchanged.

        Raises:
            ValueError: When ``lab_name`` is set but ``lab_certified`` is false, or when
                ``lab_certified`` is true but no reading has source "lab".
        """
        if self.lab_name and not self.lab_certified:
            raise ValueError("lab_name given for a grade that is not lab-certified")
        if self.lab_certified and not any(r.source == "lab" for r in self.readings):
            raise ValueError("lab_certified needs at least one reading with source 'lab'")
        return self


class Processor(BaseModel):
    """Processor or FPO that graded and packed the batch (FR16, FR62)."""

    model_config = _CONFIG
    name: str = Field(min_length=1, description="Processor display name.")
    type: str = Field(min_length=1, description="Processor type, e.g. 'FPO'.")
    place: Place = Field(description="Processor address, village level.")
    fssai_licence_no: str = Field(min_length=1, description="FSSAI licence number (FR62).")
    gi_authorised_user_no: str = Field(min_length=1, description="GI authorised-user number.")


class Lot(BaseModel):
    """One farmer's lot inside the batch (FR16, FR54, FR60, FR72)."""

    model_config = _CONFIG
    lot_code: str = Field(min_length=1, description="Lot ID, e.g. 'LOTD02DADB6'.")
    # DECISION D-017: the builder sends null when the FPO or farmer opted out of name display, and
    #   the page shows "Farmer N"; no hidden name field exists that could leak by mistake.
    #   ADV: one consent switch; the name is absent from data.json too (Arch §Security).
    #   COMPROMISE: N is the lot's position in the list, so the builder must keep a stable order.
    farmer_name: str | None = Field(
        None, description="Farmer name with consent; null when opted out (shown as 'Farmer N')."
    )
    place: Place = Field(description="Farm village, block, district and state.")
    farm_area: Quantity = Field(description="Declared farm area with unit.")
    quantity: Quantity = Field(description="Quantity procured from this lot.")
    share_pct: float = Field(
        ge=0, le=100, description="Lot's share of the procured quantity, % (FR60)."
    )
    # DECISION D-017: farming type is optional at capture (config/fields/plot.yaml), so the page takes null
    #   and leaves the line out; it stays always-public (D-034 PAGE_REQUIRED_FIELDS), never hidden by a tenant.
    #   ADV: a plot captured without it no longer blocks publishing (B10-1); the YAML stays the one source.
    #   COMPROMISE: a lot block may lack the farming-type line until the plot is completed.
    farming_type: Literal["irrigated", "rainfed"] | None = Field(
        None, description="Farming type (FR54); null when not recorded (optional in the plot YAML)."
    )
    irrigation_source: Literal["well", "borewell", "canal", "tank"] | None = Field(
        None, description="Irrigation source (FR54); null for rainfed farms."
    )
    practice_tags: list[Literal["organic", "inorganic", "ipm"]] = Field(
        default_factory=list, description="Practice tags derived from recorded inputs (FR56)."
    )
    location_method: Literal["live_gps_pin", "boundary_walked"] = Field(
        description="How the plot location was established (FR72)."
    )
    review_note: str | None = Field(None, description="Review method and date if flagged (FR72).")
    map_point: GeoPoint = Field(description="Farm pin for the map link, coarsened to 3 dp.")
    gi_authorised_user_no: str | None = Field(None, description="Producer GI authorised-user no.")
    events: Timeline = Field(description="Farming events of this lot, ascending by date.")

    @computed_field(description="Google Maps link built from the 3 dp pin (FR18).")
    @property
    def map_link(self) -> str:
        """Build the public map link from the coarsened pin.

        Returns:
            A Google Maps URL with 3-decimal coordinates.

        Raises:
            Nothing.
        """
        return f"https://www.google.com/maps?q={self.map_point.lat:.3f},{self.map_point.lon:.3f}"

    @computed_field(description="Number of farming events in this lot (FR63).")
    @property
    def event_count(self) -> int:
        """Count this lot's events.

        Returns:
            The number of events.

        Raises:
            Nothing.
        """
        return len(self.events)


class Footer(BaseModel):
    """Freshness and build stamp of the page (FR17)."""

    model_config = _CONFIG
    last_updated: AwareDatetime = Field(
        description="Last update time, ISO 8601 with offset; shown in UTC."
    )
    generation: str = Field(
        min_length=1, description="Build generation marker set by the publisher."
    )
    page_version: int = Field(ge=1, description="Page version number; increases on each rebuild.")


class PublicBatchRecord(BaseModel):
    """Everything one public batch page shows, and nothing else (FR15-FR19)."""

    model_config = _CONFIG
    product_name_en: str = Field(min_length=1, description="Product name in English.")
    product_name_local: str = Field(min_length=1, description="Product name in the local language.")
    batch_code: str = Field(min_length=1, description="Batch ID printed on the QR label.")
    super_lot_code: str = Field(min_length=1, description="Super-lot ID the batch was made from.")
    total_quantity: Quantity = Field(description="Batch quantity packed under this batch code.")
    procured_quantity: Quantity = Field(
        description="Quantity procured from the lots (super-lot), with unit; >= batch quantity."
    )
    gi_tag_number: str = Field(min_length=1, description="GI registration number, e.g. '883'.")
    gi_tag_name: str = Field(min_length=1, description="Registered GI name.")
    gi_verified: bool = Field(
        description="True when every lot passed the GI boundary check (FR29-FR30)."
    )
    gi_verification_note: str | None = Field(None, description="One-line note on the GI check.")
    # https only: the value goes into an href, so a javascript: or http: URL must not reach it.
    boundary_map_url: str | None = Field(
        None, pattern=r"^https://\S+$", description="GI boundary map image URL, https (FR30)."
    )
    # W03: set by the builder from PUBLIC_BASE_URL (B10 follow-up). http is allowed because the
    # local base URL is LocalStack's http endpoint; the scheme pattern still keeps javascript: out.
    public_url: str | None = Field(
        None,
        pattern=r"^https?://\S+$",
        description="Public page URL the pack QR encodes ({PUBLIC_BASE_URL}/b/<code>); used for "
        "og:url and the printed link. Null hides both.",
    )
    # No quotes, brackets or backslash: the value also sits in a CSS url('...') in a style attr.
    qr_url: str | None = Field(
        None,
        pattern=r"^https?://[^\s'\"()\\]+$",
        description="Absolute URL of this batch's qr.png; used for og:image and the printed QR. "
        "Null hides both.",
    )
    grade: Grade = Field(description="Computed grade block (FR51).")
    processor: Processor = Field(description="Processor block (FR16, FR62).")
    lots: list[Lot] = Field(min_length=1, description="Component lots in display order.")
    processing_events: Timeline = Field(
        default_factory=list, description="Processor-side events, ascending by date."
    )
    pack_date: dt.date = Field(description="Pack date (FR62).")
    best_before_date: dt.date = Field(description="Best-before date (FR62).")
    footer: Footer = Field(description="Last-updated time, generation and page version.")

    @model_validator(mode="before")
    @classmethod
    def _reject_personal_data(cls, data: Any) -> Any:
        """Refuse a raw record that carries personal or unsafe data (CLAUDE.md §6).

        Args:
            data: The raw input: a dict from JSON, or a model instance being revalidated.

        Returns:
            ``data`` unchanged when it is clean.

        Raises:
            ValueError: Naming the kind and path of the first phone number, Aadhaar-like number,
                land record reference, polygon, precise coordinates or temporary path found.
        """
        if found := _privacy_violation(data):
            raise ValueError(f"privacy: {found}")
        return data

    @model_validator(mode="after")
    def _consistent(self) -> "PublicBatchRecord":
        """Check cross-field facts the page states as true (FR60, FR62).

        Returns:
            The record unchanged.

        Raises:
            ValueError: When lot shares do not add up to 100 % (within 0.1), the procured
                quantity is below the batch quantity or in another unit, or the best-before
                date is not after the pack date.
        """
        if abs(sum(lot.share_pct for lot in self.lots) - 100) > 0.1:
            raise ValueError("lot share_pct values must add up to 100")
        procured, batch = self.procured_quantity, self.total_quantity
        if procured.unit != batch.unit or procured.value < batch.value:
            raise ValueError("procured_quantity must be >= total_quantity, in the same unit")
        if self.best_before_date <= self.pack_date:
            raise ValueError("best_before_date must be after pack_date")
        return self

    @computed_field(description="Number of component lots.")
    @property
    def lot_count(self) -> int:
        """Count the component lots.

        Returns:
            The number of lots.

        Raises:
            Nothing.
        """
        return len(self.lots)

    @computed_field(description="Farming events across all lots (FR63).")
    @property
    def farming_event_count(self) -> int:
        """Count farming events across all lots.

        Returns:
            The sum of the lots' event counts.

        Raises:
            Nothing.
        """
        return sum(lot.event_count for lot in self.lots)

    @computed_field(description="Processing events of the batch (FR63).")
    @property
    def processing_event_count(self) -> int:
        """Count processor-side events.

        Returns:
            The number of processing events.

        Raises:
            Nothing.
        """
        return len(self.processing_events)
