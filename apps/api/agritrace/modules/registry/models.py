"""registry tables: who and where — FPOs, processors, farmers, plots, crops, GI regions, inputs.

Also villages, plot revisions, GI tags, and the flag-gated ID documents and producer groups.

Serves: PRD §5 (Farmer, Plot, Crop, Processor/FPO, GI boundary), Dataflow Stage 0 (onboarding),
FR2, FR8, FR23, FR27–FR32 (GI region), FR53–FR56, FR62, FR64–FR67, FR70–FR72 (plot location), D-012,
D-017 (config-driven fields stay nullable), D-019 (GI region provenance).
Callers: registry service and router (B03, B04), rules_flags geo checks (B08), lots_batches (B09),
publishing (B10), events sync bundle (B06) through `models` (D-004), alembic/env.py, migration 0001.
"""

import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from geoalchemy2 import Geography
from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from agritrace.core.audit import Audited
from agritrace.core.db import Base, IdTimestamps, SpatialValue, TenantScoped
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

# DECISION D-017: columns whose capture is switched on or off by field configuration (address parts,
#   land record, soil type, irrigation, photo, GI numbers, FSSAI number) are nullable in the schema.
#   ADV: a tenant can disable a field without a migration; requiredness lives in apps/api/config (B13).
#   COMPROMISE: NOT NULL is not enforced by the database for them; services validate against the YAML.


class Fpo(Audited, IdTimestamps, Base):
    """A farmer producer organisation, company or co-op: the tenant (FR24, PRD §5 Processor / FPO entity)."""

    __tablename__ = "fpos"

    code: Mapped[str] = mapped_column(
        unique=True, comment="Short stable code, e.g. VIRUDHAI_SCFC_VINOBA_BHAVA_FPO."
    )
    name: Mapped[str] = mapped_column(comment="Registered name.")
    kind: Mapped[OrgKind] = mapped_column(comment="Legal form: fpo, company or coop.")
    address: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Structured address {village, block, district, state, pin} (core.schemas.Address, FR53)."
    )
    fssai_no: Mapped[str | None] = mapped_column(
        comment="FSSAI licence number shown on the public page (FR62)."
    )
    gi_authorised_user_no: Mapped[str | None] = mapped_column(
        comment="GI authorised-user registration number of the FPO (FR62)."
    )
    public_show_farmer_names: Mapped[bool] = mapped_column(
        default=False, comment="Whether public pages may show farmer names (still subject to consent)."
    )


class Processor(Audited, IdTimestamps, Base):
    """A processor buying lots at Sale to Processor (Stage 7, FR9, FR62); may belong to an FPO."""

    __tablename__ = "processors"

    fpo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("fpos.id"), index=True, comment="FPO that registered it; null for a shared processor."
    )
    name: Mapped[str] = mapped_column(comment="Registered name.")
    kind: Mapped[OrgKind] = mapped_column(comment="Legal form: fpo, company or coop.")
    address: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Structured address {village, block, district, state, pin} (FR53)."
    )
    fssai_no: Mapped[str | None] = mapped_column(
        comment="FSSAI licence number shown on the public page (FR62)."
    )
    gi_authorised_user_no: Mapped[str | None] = mapped_column(
        comment="GI authorised-user registration number of the processor (FR62)."
    )


class Village(IdTimestamps, Base):
    """A village from the LGD directory, picked during onboarding instead of typed (FR53)."""

    __tablename__ = "villages"

    lgd_code: Mapped[str | None] = mapped_column(
        unique=True, comment="Local Government Directory village code."
    )
    name_en: Mapped[str] = mapped_column(comment="Village name in English.")
    name_local: Mapped[str | None] = mapped_column(comment="Village name in the local script (FR5).")
    block: Mapped[str | None] = mapped_column(comment="Development block.")
    taluk: Mapped[str | None] = mapped_column(comment="Taluk (sub-district); second GI check (FR53).")
    district: Mapped[str] = mapped_column(comment="District.")
    state: Mapped[str] = mapped_column(comment="State.")
    pincode: Mapped[str | None] = mapped_column(comment="Six-digit PIN code.")


class ProducerGroup(IdTimestamps, TenantScoped, Base):
    """A self-help or other producer group inside an FPO (feature flag `producer_groups`, D-017)."""

    __tablename__ = "producer_groups"

    name: Mapped[str] = mapped_column(comment="Group name.")
    kind: Mapped[ProducerGroupKind] = mapped_column(comment="shg or other.")


class Farmer(Audited, IdTimestamps, TenantScoped, Base):
    """A grower registered with an FPO (PRD §5 Farmer, Stage 0, FR8, FR53, FR62)."""

    __tablename__ = "farmers"
    __table_args__ = (UniqueConstraint("fpo_id", "code"),)

    user_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), index=True, comment="Sign-in account; null for feature-phone farmers."
    )
    code: Mapped[str] = mapped_column(comment="Farmer code, unique inside the FPO.")
    name: Mapped[str] = mapped_column(comment="Name in English script.")
    name_local: Mapped[str | None] = mapped_column(comment="Name in the local script (FR5).")
    photo_key: Mapped[str | None] = mapped_column(comment="Object key of the profile photo.")
    address: Mapped[dict[str, Any] | None] = mapped_column(
        comment="Structured address {village, block, district, state, pin} (FR53)."
    )
    village_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("villages.id"), comment="Village picked from the directory, if any."
    )
    gi_authorised_user_no: Mapped[str | None] = mapped_column(
        comment="Farmer's GI authorised-user registration number (FR62)."
    )
    status: Mapped[FarmerStatus] = mapped_column(
        default=FarmerStatus.PENDING, comment="pending until approved or location confirmed (FR67)."
    )
    approved_by: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Admin who approved the farmer."
    )
    approved_at: Mapped[datetime | None] = mapped_column(comment="When the farmer was approved.")
    no_smartphone: Mapped[bool] = mapped_column(
        default=False, comment="True when entries are always made by an officer (assist mode)."
    )
    producer_group_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("producer_groups.id"), comment="Producer group, when that feature is on."
    )


class Plot(Audited, IdTimestamps, TenantScoped, Base):
    """A farm plot: live-GPS pin, declared area, optional walked boundary (FR2, FR54, FR64–FR67, FR70–FR72).

    PRD §5 Farm / Plot. `id` is client-generated (D-005).
    """

    __tablename__ = "plots"

    farmer_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("farmers.id"), index=True, comment="Owner.")
    code: Mapped[str] = mapped_column(comment="Plot code shown to people, e.g. P-01.")
    gi_tag_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("gi_tags.id"),
        comment="GI tag of the crop picked at onboarding; null = pilot single-GI fallback.",
    )
    pin: Mapped[SpatialValue] = mapped_column(
        Geography("POINT", 4326), comment="Plot pin dropped on the plot (WGS84), FR64."
    )
    pin_accuracy_m: Mapped[float | None] = mapped_column(comment="GPS accuracy of the pin in metres.")
    pin_method: Mapped[PinMethod] = mapped_column(comment="live_gps, or map_pin (needs review, FR64).")
    pin_device_time: Mapped[datetime] = mapped_column(comment="Phone clock when the pin was taken.")
    pin_gps_time: Mapped[datetime | None] = mapped_column(comment="GPS fix time of the pin, if any.")
    pin_server_received_at: Mapped[datetime] = mapped_column(comment="When the server received the pin.")
    declared_area_acres: Mapped[Decimal] = mapped_column(
        comment="Area declared by the farmer, in acres (FR65)."
    )
    land_record_ref: Mapped[str | None] = mapped_column(
        comment="Survey / patta / chitta reference (FR65); internal only, never public (CLAUDE.md §6)."
    )
    walked_boundary: Mapped[SpatialValue | None] = mapped_column(
        Geography("POLYGON", 4326), comment="Boundary walked with GPS (FR66); internal only, never public."
    )
    walked_area_acres: Mapped[Decimal | None] = mapped_column(
        comment="Area of the walked boundary, in acres."
    )
    farming_type: Mapped[FarmingType | None] = mapped_column(comment="irrigated or rainfed (FR54).")
    irrigation_source: Mapped[IrrigationSource | None] = mapped_column(comment="Water source (FR54).")
    soil_type: Mapped[str | None] = mapped_column(comment="Soil type, free text or configured list (D-017).")
    location_status: Mapped[LocationStatus] = mapped_column(
        default=LocationStatus.NEEDS_REVIEW, comment="Result of the GI region check (FR67, FR70)."
    )
    location_method_label: Mapped[str | None] = mapped_column(
        comment="Public label of how the location was set, e.g. Live GPS pin, Boundary walked (FR72)."
    )
    revision_no: Mapped[int] = mapped_column(
        default=1, comment="Current revision; bumps on admin correction."
    )
    reviewed_at: Mapped[datetime | None] = mapped_column(
        comment="When a flagged location was reviewed (FR70)."
    )
    review_method: Mapped[str | None] = mapped_column(
        comment="How it was reviewed: land_record, satellite or field_visit (FR70)."
    )
    review_outcome: Mapped[str | None] = mapped_column(comment="Reviewer's outcome and note (FR70).")


class PlotRevision(IdTimestamps, Base):
    """The previous state of a plot kept on every admin correction (FR71)."""

    __tablename__ = "plot_revisions"
    __table_args__ = (UniqueConstraint("plot_id", "revision_no"),)

    plot_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("plots.id"), comment="Corrected plot.")
    revision_no: Mapped[int] = mapped_column(comment="Revision number this snapshot had.")
    snapshot: Mapped[dict[str, Any]] = mapped_column(comment="All plot columns before the correction.")
    changed_by: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id"), comment="FPO admin who corrected it."
    )
    reason_code: Mapped[str] = mapped_column(comment="Coded reason for the correction (FR71).")
    reason_text: Mapped[str | None] = mapped_column(comment="Free-text explanation.")
    changed_at: Mapped[datetime] = mapped_column(comment="When the correction was made.")


class GiTag(IdTimestamps, Base):
    """A registered Geographical Indication, e.g. GI 883 Virudhunagar Samba Vathal (FR27)."""

    __tablename__ = "gi_tags"

    gi_number: Mapped[str] = mapped_column(unique=True, comment="GI application number, e.g. 883.")
    name: Mapped[str] = mapped_column(comment="Registered GI name in English.")
    name_local: Mapped[str | None] = mapped_column(comment="GI name in the local script.")
    registry_ref: Mapped[str | None] = mapped_column(comment="Certificate / GI Journal reference.")


class Crop(IdTimestamps, Base):
    """A crop with its bilingual name, GI tag and event schema (PRD §5 Crop, FR5, FR22, FR23, FR55)."""

    __tablename__ = "crops"

    code: Mapped[str] = mapped_column(unique=True, comment="Stable crop code, e.g. SAMBA_VATHAL.")
    name_en: Mapped[str] = mapped_column(comment="Crop name in English.")
    name_local: Mapped[str | None] = mapped_column(comment="Crop name in the local script.")
    lang: Mapped[str] = mapped_column(default="ta", comment="Language code of name_local.")
    gi_tag_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("gi_tags.id"), comment="GI tag the crop is sold under, if any."
    )
    event_schema: Mapped[dict[str, Any]] = mapped_column(
        comment="Mandatory event types and date-order rules with nursery/main-field tracks (FR22, FR55)."
    )
    active: Mapped[bool] = mapped_column(default=True, comment="False hides the crop from new lots.")


class GiRegionVersion(Audited, IdTimestamps, Base):
    """One version of a GI tag's production area with its provenance; super-admin only (FR27, FR31, FR32).

    Audited: a region is a legal fact (FR31), so every upload is in `audit_log` with its uploader.
    """

    __tablename__ = "gi_region_versions"
    __table_args__ = (UniqueConstraint("gi_tag_id", "version_no"),)

    gi_tag_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("gi_tags.id"), comment="GI tag this region is for."
    )
    version_no: Mapped[int] = mapped_column(
        comment="Version number, 0 upwards; latest effective one applies."
    )
    geom: Mapped[SpatialValue] = mapped_column(
        Geography("MULTIPOLYGON", 4326), comment="Production-area outline (WGS84)."
    )
    tolerance_buffer_m: Mapped[Decimal] = mapped_column(
        comment="GPS-drift buffer around the outline in metres (FR32)."
    )
    # DECISION D-019: every region version records where its outline came from and how far to trust it.
    #   ADV: a district- or taluk-derived outline is reproducible and can be swapped for an official file
    #     without a schema change.
    #   COMPROMISE: still an approximation (2011 taluk boundaries); near-edge review stays on.
    taluks: Mapped[list[str] | None] = mapped_column(
        JSONB, comment="Taluks named in the GI registration that this outline unions (D-019)."
    )
    source_ref: Mapped[str] = mapped_column(comment="Source dataset and build script reference (D-019).")
    licence: Mapped[str] = mapped_column(comment="Licence of the source data, e.g. ODbL (D-019).")
    confidence: Mapped[str] = mapped_column(
        comment="How the outline was derived, e.g. district_derived (D-019)."
    )
    effective_from: Mapped[date] = mapped_column(comment="Date from which checks use this version.")
    created_by: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id"), comment="Super-admin who loaded it; null for seeded versions."
    )


class InputMaster(IdTimestamps, Base):
    """A fertiliser or pesticide farmers pick from, global or FPO-specific (FR5, FR56)."""

    __tablename__ = "inputs_master"

    fpo_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("fpos.id"), index=True, comment="FPO-specific entry; null for the global list."
    )
    name_en: Mapped[str] = mapped_column(comment="Product name in English.")
    name_local: Mapped[str | None] = mapped_column(comment="Product name in the local script (FR5).")
    manufacturer: Mapped[str | None] = mapped_column(comment="Manufacturer or brand.")
    category: Mapped[InputCategory] = mapped_column(
        comment="Category from which practice tags derive (FR56)."
    )
    unit: Mapped[str] = mapped_column(comment="Unit quantities of this input are entered in, e.g. kg, l.")
    pack_size: Mapped[Decimal | None] = mapped_column(comment="Typical pack size, in `unit`.")
    photo_key: Mapped[str | None] = mapped_column(comment="Object key of a product photo for picking.")
    active: Mapped[bool] = mapped_column(default=True, comment="False hides it from new entries.")


class IdDocument(IdTimestamps, Base):
    """A farmer identity document image (feature flag `id_document_capture`, D-017); never public."""

    __tablename__ = "id_documents"

    farmer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("farmers.id"), index=True, comment="Document owner."
    )
    doc_type: Mapped[str] = mapped_column(comment="Document type code from field configuration.")
    object_key: Mapped[str] = mapped_column(comment="Object key in the private id-docs bucket.")
    captured_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), comment="User who captured it.")
    captured_at: Mapped[datetime] = mapped_column(comment="When it was captured.")
    consent_record_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("consent_records.id"), comment="Consent under which it was captured."
    )
