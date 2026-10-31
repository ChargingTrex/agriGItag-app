"""Request and response models of the registry API.

FPOs, processors, villages, farmers, plots, crops, GI regions and the input master list.

Serves: Stage 0 (onboarding), FR27–FR32 (GI region), FR53 (structured address, no repeated parts),
FR54 (farming type vs irrigation source), FR56 (input categories), FR58 (units), FR64–FR72 (plot
location), D-005 (client ids), D-017 (config-driven fields optional here), D-020 (additive changes);
B13: village import rows, import reports, flag-gated ID documents and producer groups (FR53, FR56,
PLAN "Gap analysis" Master data uploads); B14 (portal gaps found by P01, PLAN gap analysis "Members",
FR8, FR14, FR53, FR70): masked phone and reveal, reject, FPO bounding box.
Callers: registry router and service only (other modules may not import schemas, D-004); OpenAPI
generation (`agritrace.export_openapi`) builds the contract and the Dart/TS clients from these.
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Any, Literal

from pydantic import AwareDatetime, BaseModel, ConfigDict, Field, computed_field, model_validator

from agritrace.core.enums import (
    FarmerStatus,
    FarmingType,
    InputCategory,
    IrrigationSource,
    LocationStatus,
    OrgKind,
    PinMethod,
    ProducerGroupKind,
)
from agritrace.core.schemas import Address, GeoPoint, Quantity

ReviewOutcome = Literal["accepted", "rejected"]

# Positions are [lon, lat] (GeoJSON order, RFC 7946); a third value (altitude) is accepted and ignored.
Position = list[float]


def format_address(address: Address | dict[str, Any] | None) -> str:
    """Render an address as one line without repeated parts (PRD §12.2 "Tiruchuli, Tiruchuli" bug, FR53).

    Args:
        address: structured address, its stored JSON dict, or None.

    Returns:
        Village, block, taluk, district, state and PIN joined by ", ", skipping empty parts and any part
        equal (ignoring case and surrounding spaces) to one already shown; "" for no address.
    """
    if address is None:
        return ""
    parts = address.model_dump() if isinstance(address, Address) else address
    seen: set[str] = set()
    out: list[str] = []
    for key in ("village", "block", "taluk", "district", "state", "pin"):
        value = (parts.get(key) or "").strip()
        if value and value.casefold() not in seen:
            seen.add(value.casefold())
            out.append(value)
    return ", ".join(out)


class PolygonGeoJSON(BaseModel):
    """A GeoJSON Polygon in WGS84, e.g. a walked plot boundary (FR66). First ring is the outer edge."""

    type: Literal["Polygon"] = Field(description="Always `Polygon`.")
    coordinates: list[list[Position]] = Field(
        min_length=1,
        description="Rings of [lon, lat] positions; each ring closed (first = last), at least 4 positions.",
    )


class MultiPolygonGeoJSON(BaseModel):
    """A GeoJSON MultiPolygon in WGS84, e.g. a GI production-area outline (FR27)."""

    type: Literal["MultiPolygon"] = Field(description="Always `MultiPolygon`.")
    coordinates: list[list[list[Position]]] = Field(
        min_length=1, description="Polygons, each a list of closed rings of [lon, lat] positions."
    )


class _Out(BaseModel):
    """Base of response models built from ORM rows."""

    model_config = ConfigDict(from_attributes=True)


# --- FPOs and processors ------------------------------------------------------------------------------


class FpoIn(BaseModel):
    """A new FPO (tenant); created by a super-admin."""

    code: str = Field(
        min_length=2, max_length=64, pattern=r"^[A-Z0-9_]+$", description="Stable upper-case code."
    )
    name: str = Field(min_length=1, max_length=200, description="Registered name.")
    kind: OrgKind = Field(OrgKind.FPO, description="Legal form: fpo, company or coop.")
    address: Address | None = Field(None, description="Registered address (FR53).")
    fssai_no: str | None = Field(None, max_length=32, description="FSSAI licence number (FR62).")
    gi_authorised_user_no: str | None = Field(
        None, max_length=64, description="GI authorised-user registration number (FR62)."
    )
    public_show_farmer_names: bool = Field(
        False, description="Whether public pages may show farmer names (still subject to each consent)."
    )


class FpoOut(_Out):
    """An FPO as returned by the API."""

    id: uuid.UUID = Field(description="FPO id.")
    code: str = Field(description="Stable upper-case code.")
    name: str = Field(description="Registered name.")
    kind: OrgKind = Field(description="Legal form.")
    address: Address | None = Field(description="Registered address.")
    fssai_no: str | None = Field(description="FSSAI licence number.")
    gi_authorised_user_no: str | None = Field(description="GI authorised-user registration number.")
    public_show_farmer_names: bool = Field(description="Whether public pages may show farmer names.")
    # DECISION D-020: B14 adds `bbox` as an optional response field; lists leave it null (additive only).
    #   ADV: old clients ignore it; the list stays one query.  COMPROMISE: same model, two fill levels.
    bbox: list[float] | None = Field(
        None,
        min_length=4,
        max_length=4,
        description="[min_lon, min_lat, max_lon, max_lat] (WGS84) of the FPO's plots, or of the current GI "
        "regions when it has none; for the portal map and tile cache. Only on GET /v1/fpos/{id} for "
        "fpo_admin, field_officer, qc_officer and super-admins; null for farmers and viewers, on "
        "lists and when there is nothing to frame. One plot gives a zero-size box: pad it client-side.",
    )

    @computed_field(description="Address on one line, without repeated parts.")  # type: ignore[prop-decorator]
    @property
    def address_line(self) -> str:
        """One-line address.

        Returns:
            `format_address(self.address)`.
        """
        return format_address(self.address)


class ProcessorIn(BaseModel):
    """A processor an FPO sells to (Stage 7); registered by the FPO admin."""

    name: str = Field(min_length=1, max_length=200, description="Registered name.")
    kind: OrgKind = Field(OrgKind.COMPANY, description="Legal form: fpo, company or coop.")
    address: Address | None = Field(None, description="Address (FR53).")
    fssai_no: str | None = Field(None, max_length=32, description="FSSAI licence number (FR62).")
    gi_authorised_user_no: str | None = Field(
        None, max_length=64, description="GI authorised-user registration number (FR62)."
    )


class ProcessorOut(_Out):
    """A processor as returned by the API."""

    id: uuid.UUID = Field(description="Processor id.")
    fpo_id: uuid.UUID | None = Field(description="FPO that registered it; null for a shared processor.")
    name: str = Field(description="Registered name.")
    kind: OrgKind = Field(description="Legal form.")
    address: Address | None = Field(description="Address.")
    fssai_no: str | None = Field(description="FSSAI licence number.")
    gi_authorised_user_no: str | None = Field(description="GI authorised-user registration number.")

    @computed_field(description="Address on one line, without repeated parts.")  # type: ignore[prop-decorator]
    @property
    def address_line(self) -> str:
        """One-line address.

        Returns:
            `format_address(self.address)`.
        """
        return format_address(self.address)


class VillageOut(_Out):
    """A village from the LGD directory, as offered in the onboarding picker (FR53)."""

    id: uuid.UUID = Field(description="Village id.")
    lgd_code: str | None = Field(description="Local Government Directory village code.")
    name_en: str = Field(description="Village name in English.")
    name_local: str | None = Field(description="Village name in the local script.")
    block: str | None = Field(description="Development block.")
    taluk: str | None = Field(description="Taluk (sub-district).")
    district: str = Field(description="District.")
    state: str = Field(description="State.")
    pincode: str | None = Field(description="Six-digit PIN code.")


# --- farmers ------------------------------------------------------------------------------------------


class FarmerIn(BaseModel):
    """A farmer onboarded by a field officer or admin (Stage 0, UserFlows §Onboarding a farmer)."""

    # DECISION D-017: every field a tenant may switch off (phone, address parts, GI number, photo; on plots
    #   land record, walked boundary, farming type, irrigation, soil) is optional in these schemas.
    #   ADV: no tenant-specific requiredness is hard-coded; B13 layers the YAML field rules on top.
    #   COMPROMISE: until B13 lands, nothing beyond name, pin and declared size is enforced as required.
    name: str = Field(min_length=1, max_length=120, description="Name in English script.")
    name_local: str | None = Field(None, max_length=120, description="Name in the local script (FR5).")
    phone: str | None = Field(
        None,
        pattern=r"^\+[1-9][0-9]{7,14}$",
        description="Mobile number in E.164, e.g. +919876543210; creates or links the farmer's sign-in "
        "account (also for feature-phone farmers, who get SMS).",
    )
    lang: Literal["ta", "en"] = Field("ta", description="Preferred language for app, SMS and voice.")
    address: Address | None = Field(
        None, description="Structured address (FR53); parts left empty are filled from `village_id`."
    )
    village_id: uuid.UUID | None = Field(None, description="Village picked from GET /v1/villages.")
    gi_authorised_user_no: str | None = Field(
        None, max_length=64, description="Farmer's GI authorised-user registration number (FR62)."
    )
    no_smartphone: bool = Field(
        False, description="True when the officer always enters data for this farmer (assist mode)."
    )
    photo_key: str | None = Field(None, max_length=300, description="Object key of the profile photo.")


class FarmerPatch(BaseModel):
    """Changes to a farmer's profile; only the fields sent are changed."""

    name: str | None = Field(None, min_length=1, max_length=120, description="Name in English script.")
    name_local: str | None = Field(None, max_length=120, description="Name in the local script.")
    address: Address | None = Field(None, description="Structured address (replaces the stored one).")
    village_id: uuid.UUID | None = Field(None, description="Village picked from GET /v1/villages.")
    gi_authorised_user_no: str | None = Field(None, max_length=64, description="GI authorised-user number.")
    no_smartphone: bool | None = Field(None, description="True when the officer always enters data.")
    photo_key: str | None = Field(None, max_length=300, description="Object key of the profile photo.")


class FarmerOut(_Out):
    """A farmer as returned by the API; the phone (on the sign-in account) only masked (B14)."""

    id: uuid.UUID = Field(description="Farmer id.")
    fpo_id: uuid.UUID = Field(description="Owning FPO.")
    user_id: uuid.UUID | None = Field(description="Sign-in account; null when no phone was given.")
    code: str = Field(description="Farmer code, unique inside the FPO.")
    name: str = Field(description="Name in English script.")
    name_local: str | None = Field(description="Name in the local script.")
    photo_key: str | None = Field(description="Object key of the profile photo.")
    address: Address | None = Field(description="Structured address.")
    village_id: uuid.UUID | None = Field(description="Village from the directory.")
    gi_authorised_user_no: str | None = Field(description="GI authorised-user registration number.")
    status: FarmerStatus = Field(
        description="pending until an FPO admin approves; then active; suspended when rejected (B14)."
    )
    approved_by: uuid.UUID | None = Field(description="Admin who approved the farmer.")
    approved_at: datetime | None = Field(description="When the farmer was approved.")
    no_smartphone: bool = Field(description="True when the officer always enters data.")
    # DECISION D-017: the phone is `internal` (fields/farmer.yaml); only its last 4 digits leave the API
    #   here, the full number only through the audited GET /v1/farmers/{id}/phone (B14).
    #   ADV: officers can still tell farmers apart and call-check by suffix.  COMPROMISE: one join per list.
    phone_masked: str | None = Field(
        None,
        description="Phone of the sign-in account with all but the last 4 digits hidden, e.g. `XXXXXX3210`; "
        "null without a phone. FPO admins read the full number via GET /v1/farmers/{id}/phone (audited).",
    )

    @computed_field(description="Address on one line, without repeated parts.")  # type: ignore[prop-decorator]
    @property
    def address_line(self) -> str:
        """One-line address.

        Returns:
            `format_address(self.address)`.
        """
        return format_address(self.address)


class FarmerPhoneOut(BaseModel):
    """A farmer's full phone number, revealed to an FPO admin and audited (B14, D-017 `internal`)."""

    farmer_id: uuid.UUID = Field(description="Farmer id.")
    phone: str | None = Field(description="Phone in E.164 from the sign-in account; null without one.")


class FarmerReject(BaseModel):
    """Why an FPO admin turns down a pending farmer (Stage 0 approval, FR70)."""

    reason_code: str = Field(
        min_length=1,
        max_length=64,
        description="Coded reason, e.g. `duplicate`, `not_a_member`, `outside_gi_area`, `incomplete`.",
    )
    reason_text: str | None = Field(None, max_length=500, description="Free-text explanation.")


# --- plots --------------------------------------------------------------------------------------------


class PlotIn(BaseModel):
    """A plot captured at onboarding: live-GPS pin, declared size, optional walked boundary (FR64–FR66)."""

    # DECISION D-005: the phone generates the plot id; resending the same id is a no-op.
    #   ADV: offline capture and retries never create a second plot.
    #   COMPROMISE: an id already owned by another farmer or FPO is refused (`client_id_conflict`).
    client_id: uuid.UUID = Field(
        description="UUIDv7 generated on the device; primary key and idempotency key."
    )
    farmer_id: uuid.UUID = Field(description="Farmer who owns the plot (same FPO as the caller).")
    code: str | None = Field(
        None, max_length=32, description="Plot code shown to people; default `P-<n>` per farmer."
    )
    gi_tag_id: uuid.UUID | None = Field(
        None,
        description="GI tag of the crop picked at onboarding; null uses the only GI tag with a region, "
        "if exactly one exists (pilot), else the plot needs review.",
    )
    pin: GeoPoint = Field(
        description="Pin from live GPS while standing on the plot, with its accuracy (FR64)."
    )
    pin_method: PinMethod = Field(
        PinMethod.LIVE_GPS, description="live_gps, or map_pin (assisted fallback; always needs review)."
    )
    device_time: AwareDatetime = Field(description="Phone clock when the pin was taken.")
    gps_time: AwareDatetime | None = Field(None, description="GPS fix time of the pin, if any.")
    declared_area: Quantity = Field(
        description="Land size declared by the farmer; unit `acre` or `cent` (100 cents = 1 acre), FR65."
    )
    land_record_ref: str | None = Field(
        None, max_length=120, description="Survey number / patta / chitta reference; never public (FR65)."
    )
    walked_boundary: PolygonGeoJSON | None = Field(
        None, description="Boundary walked with GPS (FR66); never public."
    )
    farming_type: FarmingType | None = Field(None, description="irrigated or rainfed (FR54).")
    irrigation_source: IrrigationSource | None = Field(None, description="Water source (FR54).")
    soil_type: str | None = Field(None, max_length=60, description="Soil type (field configuration, D-017).")


class PlotCorrection(BaseModel):
    """An FPO admin's correction of an onboarded plot; only the fields sent change (FR70, FR71)."""

    reason_code: str | None = Field(
        None,
        max_length=64,
        description="Coded reason, e.g. `gps_drift`, `wrong_plot`, `land_record_checked`; required "
        "(422 `reason_required` when missing).",
    )
    reason_text: str | None = Field(None, max_length=500, description="Free-text explanation.")
    gi_tag_id: uuid.UUID | None = Field(None, description="GI tag to re-check against (see PlotIn).")
    pin: GeoPoint | None = Field(None, description="Corrected pin.")
    pin_method: PinMethod | None = Field(None, description="How the corrected pin was placed.")
    declared_area: Quantity | None = Field(None, description="Corrected declared size (`acre` or `cent`).")
    land_record_ref: str | None = Field(None, max_length=120, description="Corrected land-record reference.")
    walked_boundary: PolygonGeoJSON | None = Field(None, description="Corrected walked boundary.")
    farming_type: FarmingType | None = Field(None, description="Corrected farming type.")
    irrigation_source: IrrigationSource | None = Field(None, description="Corrected irrigation source.")
    soil_type: str | None = Field(None, max_length=60, description="Corrected soil type.")
    review_method: Literal["land_record", "satellite", "field_visit"] | None = Field(
        None, description="How a flagged location was reviewed (FR70); send with `review_outcome`."
    )
    review_outcome: ReviewOutcome | None = Field(
        None,
        description="Review result (FR70): `accepted` lets the region check decide the status (also for a "
        "map pin); `rejected` keeps the plot `needs_review`. Put the reviewer's note in `reason_text`.",
    )

    @model_validator(mode="after")
    def _review_complete(self) -> "PlotCorrection":
        """Require `review_method` and `review_outcome` together.

        Returns:
            The model unchanged.

        Raises:
            ValueError: only one of the two was sent (FastAPI answers 422 `validation_error`).
        """
        if (self.review_method is None) != (self.review_outcome is None):
            raise ValueError("send review_method and review_outcome together")
        return self


class RegionCheckOut(BaseModel):
    """Result of the automatic GI region check run on create or correct (FR67)."""

    status: Literal["inside", "near_edge", "outside"] = Field(description="Where the pin lies.")
    distance_m: float = Field(description="Metres from the outline; 0 inside.")
    region_version_id: uuid.UUID = Field(description="Region version checked against.")
    buffer_m: Decimal = Field(description="Tolerance buffer of that version, in metres (FR32).")


class PlotOut(BaseModel):
    """A plot as returned by the API. The walked outline itself is not returned (internal only)."""

    id: uuid.UUID = Field(description="Plot id (client-generated, D-005).")
    fpo_id: uuid.UUID = Field(description="Owning FPO.")
    farmer_id: uuid.UUID = Field(description="Owner.")
    code: str = Field(description="Plot code shown to people.")
    gi_tag_id: uuid.UUID | None = Field(
        None, description="GI tag stored at onboarding or correction; null when none was sent (fallback)."
    )
    pin: GeoPoint = Field(description="Plot pin (WGS84) with its GPS accuracy.")
    pin_method: PinMethod = Field(description="live_gps or map_pin.")
    pin_device_time: datetime = Field(description="Phone clock when the pin was taken.")
    pin_gps_time: datetime | None = Field(description="GPS fix time of the pin.")
    pin_server_received_at: datetime = Field(description="When the server received the pin.")
    declared_area: Quantity = Field(description="Declared size (unit `acre`).")
    land_record_ref: str | None = Field(description="Land-record reference (internal only).")
    walked_area: Quantity | None = Field(description="Area of the walked boundary (unit `acre`), if walked.")
    area_gap_pct: Decimal | None = Field(
        description="Walked minus declared, as % of declared; null when no boundary was walked."
    )
    area_gap_exceeds: bool = Field(
        description="True when |area_gap_pct| > 20 %: walked area far from declared size (FR66, FR70)."
    )
    farming_type: FarmingType | None = Field(description="irrigated or rainfed.")
    irrigation_source: IrrigationSource | None = Field(description="Water source.")
    soil_type: str | None = Field(description="Soil type.")
    location_status: LocationStatus = Field(
        description="confirmed, near_edge, outside, or needs_review (map pin or no region to check)."
    )
    location_method_label: str | None = Field(
        description="How the location was set, for the public page: `Live GPS pin`, `Boundary walked` or "
        "`Map pin` (FR72)."
    )
    revision_no: int = Field(description="Current revision; bumps on every admin correction.")
    reviewed_at: datetime | None = Field(description="When a flagged location was reviewed (FR70).")
    review_method: str | None = Field(description="land_record, satellite or field_visit.")
    review_outcome: str | None = Field(description="accepted or rejected (FR70); null when not reviewed.")
    region_check: RegionCheckOut | None = Field(
        None, description="Region check run by this request (create or correct); null on reads."
    )


# --- crops, GI regions, inputs ------------------------------------------------------------------------


class CropOut(_Out):
    """A crop farmers can grow, with its GI tag and event schema (FR22, FR55)."""

    id: uuid.UUID = Field(description="Crop id.")
    code: str = Field(description="Stable crop code.")
    name_en: str = Field(description="Crop name in English.")
    name_local: str | None = Field(description="Crop name in the local script.")
    lang: str = Field(description="Language code of name_local.")
    gi_tag_id: uuid.UUID | None = Field(description="GI tag the crop is sold under, if any.")
    event_schema: dict[str, Any] = Field(description="Mandatory event types and date-order rules (FR55).")
    active: bool = Field(description="False hides the crop from new lots.")


class GiRegionVersionIn(BaseModel):
    """A new version of a GI tag's production-area outline with its provenance (FR27, FR31, FR32, D-019)."""

    geometry: MultiPolygonGeoJSON = Field(description="Outline in WGS84 [lon, lat].")
    tolerance_buffer_m: Decimal = Field(
        ge=0, le=5000, description="GPS-drift buffer around the outline in metres (FR32), e.g. 150."
    )
    taluks: list[str] = Field(
        min_length=1, description="Taluks named in the GI registration that this outline unions (D-019)."
    )
    source_ref: str = Field(
        min_length=1, max_length=500, description="Source dataset, file and build script reference (D-019)."
    )
    licence: str = Field(
        min_length=1, max_length=120, description="Licence of the source data, e.g. ODbL-1.0."
    )
    confidence: Literal["official", "district_derived", "fixture"] = Field(
        description="How the outline was derived: official (registry or surveyed file), district_derived "
        "(admin boundaries, D-019) or fixture (test data, never for real checks)."
    )
    attribution: str = Field(
        min_length=1,
        max_length=300,
        description="Attribution line the source licence requires, e.g. `Boundary data © geoBoundaries "
        "contributors, ODbL-1.0; ...`; stored inside `source_ref` (no column for it).",
    )
    share_alike: bool = Field(
        description="True when the derived outline must be shared under the same licence (ODbL); stored "
        "inside `source_ref`."
    )
    effective_from: date | None = Field(None, description="First day checks use it; default today.")


class GiRegionVersionOut(_Out):
    """Metadata of one region version (the outline itself is served by GET /v1/gi-tags/{id}/region)."""

    id: uuid.UUID = Field(description="Region version id.")
    gi_tag_id: uuid.UUID = Field(description="GI tag.")
    version_no: int = Field(description="Version number, 0 upwards.")
    tolerance_buffer_m: Decimal = Field(description="GPS-drift buffer in metres.")
    taluks: list[str] | None = Field(description="Taluks this outline unions.")
    source_ref: str = Field(
        description="Source dataset and build script reference, then `; attribution: …; share_alike: …`."
    )
    licence: str = Field(description="Licence of the source data.")
    confidence: str = Field(description="How the outline was derived.")
    effective_from: date = Field(description="First day checks use it.")


class GiRegionOut(BaseModel):
    """The current region of a GI tag: version metadata plus a simplified outline (≤ 50 KB)."""

    version: GiRegionVersionOut = Field(description="The region version in effect today.")
    geometry: dict[str, Any] = Field(
        description="Simplified GeoJSON outline (MultiPolygon or Polygon), [lon, lat], 6 decimal places."
    )
    simplified_tolerance_m: float = Field(description="Simplification tolerance used, in metres.")


class InputIn(BaseModel):
    """A fertiliser or pesticide added to the master list (FR56)."""

    name_en: str = Field(min_length=1, max_length=120, description="Product name in English.")
    name_local: str | None = Field(None, max_length=120, description="Product name in the local script.")
    manufacturer: str | None = Field(None, max_length=120, description="Manufacturer or brand.")
    category: InputCategory = Field(description="Category from which practice tags are derived (FR56).")
    unit: str = Field(min_length=1, max_length=16, description="Unit quantities are entered in, e.g. kg, l.")
    pack_size: Decimal | None = Field(None, ge=0, description="Typical pack size, in `unit`.")
    photo_key: str | None = Field(None, max_length=300, description="Object key of a product photo.")
    global_entry: bool = Field(
        False, description="True adds it to the list every FPO sees (super-admin only); else FPO-only."
    )


class InputOut(_Out):
    """An entry of the input master list."""

    id: uuid.UUID = Field(description="Input id.")
    fpo_id: uuid.UUID | None = Field(description="FPO-specific entry; null for the global list.")
    name_en: str = Field(description="Product name in English.")
    name_local: str | None = Field(description="Product name in the local script.")
    manufacturer: str | None = Field(description="Manufacturer or brand.")
    category: InputCategory = Field(description="Input category (FR56).")
    unit: str = Field(description="Unit quantities are entered in.")
    pack_size: Decimal | None = Field(description="Typical pack size, in `unit`.")
    photo_key: str | None = Field(description="Object key of a product photo.")
    active: bool = Field(description="False hides it from new entries.")


# --- B13: master data imports, ID documents, producer groups ------------------------------------------


class VillageIn(BaseModel):
    """One village row of a master data import (FR53); validated per CSV row."""

    lgd_code: str = Field(min_length=1, max_length=16, description="LGD village code; the import key.")
    name_en: str = Field(min_length=1, max_length=120, description="Village name in English.")
    name_local: str | None = Field(None, max_length=120, description="Village name in the local script.")
    block: str | None = Field(None, max_length=120, description="Development block.")
    taluk: str | None = Field(None, max_length=120, description="Taluk (sub-district).")
    district: str = Field(min_length=1, max_length=120, description="District.")
    state: str = Field(min_length=1, max_length=120, description="State.")
    pincode: str | None = Field(None, pattern=r"^[1-9][0-9]{5}$", description="Six-digit PIN code.")


class ImportRowError(BaseModel):
    """Why one CSV row was not imported."""

    row: int = Field(description="Line number in the file; the header is line 1, the first data row 2.")
    code: str = Field(description="Registered error code (docs/api/error-codes.md), e.g. `field_required`.")
    field: str | None = Field(None, description="Column the problem is in, when known.")


class ImportReport(BaseModel):
    """Row-level outcome of a CSV import (dry run or commit)."""

    dry_run: bool = Field(description="True: nothing was written; the counts are what a commit would do.")
    accepted: int = Field(description="Rows imported (or importable, on a dry run).")
    rejected: list[ImportRowError] = Field(description="Rows not imported, in file order.")


class IdDocumentIn(BaseModel):
    """Request to upload one identity document image (flag `id_document_capture`, consent-gated)."""

    doc_type: str = Field(
        min_length=1, max_length=32, pattern=r"^[a-z_]+$", description="Document type code, e.g. `aadhaar`."
    )
    consent_record_id: uuid.UUID = Field(
        description="The farmer's unrevoked `data_collection` consent under which it is captured."
    )
    content_type: Literal["image/jpeg", "image/webp"] = Field(description="MIME type of the image to upload.")
    sha256: str = Field(pattern=r"^[0-9a-f]{64}$", description="Hex SHA-256 of the image (device).")


class IdDocumentUpload(BaseModel):
    """Where to PUT the ID document image; the URL accepts only bytes matching `sha256`."""

    id: uuid.UUID = Field(description="ID document id.")
    method: Literal["PUT"] = Field(description="Always PUT.")
    url: str = Field(description="Presigned URL into the private id-docs bucket (15 minutes).")
    headers: dict[str, str] = Field(
        description="Headers to send: `Content-Type` and `x-amz-checksum-sha256` (base64 digest)."
    )
    expires_at: datetime = Field(description="When the URL stops working.")


class ProducerGroupIn(BaseModel):
    """A new producer group (SHG) in the caller's FPO (flag `producer_groups`)."""

    name: str = Field(min_length=1, max_length=120, description="Group name.")
    kind: ProducerGroupKind = Field(ProducerGroupKind.SHG, description="shg or other.")


class ProducerGroupOut(_Out):
    """A producer group."""

    id: uuid.UUID = Field(description="Group id.")
    fpo_id: uuid.UUID = Field(description="Owning FPO.")
    name: str = Field(description="Group name.")
    kind: ProducerGroupKind = Field(description="shg or other.")
