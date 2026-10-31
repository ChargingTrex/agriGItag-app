"""Request and response schemas of the events module: event versions, sync push/pull, photo confirm, bundles.

The event version is a discriminated union on `event_type` (one variant per type, each with its own typed
payload), rendered in OpenAPI as `oneOf` with a discriminator.

Serves: FR3 (structured event fields), FR4 and Arch §Offline-first (sync envelope, three clocks, client
UUIDs), FR25/FR59 (corrections and undo as versions), FR26 (GPS at submission), FR61 (evidence photos),
FR63 (lot timeline), backend-design.md §3 (binding sync protocol), plan §13 A3, A4, C2 (reference bundles with
per-part delta), F1, D-005, D-011, D-014, D-016, D-031/D-032 (`farmer` and `assist_session` kinds, per-entry
assist session), D-040 (`lot_intake` kind), D-042 (assist session per kind).
Callers: `events.router`, `events.sync_router`, `events.service`, `events.evidence`, `events.bundle_service`,
`events.pull_service`; tests.
"""

import uuid
from datetime import date, datetime
from enum import StrEnum
from typing import Annotated, Any, Literal, Self

from pydantic import AwareDatetime, BaseModel, ConfigDict, Field, model_validator

from agritrace.core.enums import ChangeKind, EventStatus, EventSubject, EventType, PhotoStatus
from agritrace.core.schemas import ErrorBody, GeoPoint, ThreeClocks
from agritrace.modules.events.payloads.farm import (
    DryingPayload,
    HarvestPayload,
    InputApplicationPayload,
    LandPreparationPayload,
    NurseryPayload,
    PackingPayload,
    ProblemPayload,
    SowingPayload,
)
from agritrace.modules.events.payloads.processing import FinalPackingPayload, GradingPayload, IntakePayload

MAX_ENTRIES = 50
MAX_PHOTOS_PER_ENTRY = 10
MAX_PHOTO_BYTES = 5_000_000  # phones compress to <= 350 KB (M04); this only stops absurd declarations


class PhotoIn(BaseModel):
    """An evidence photo or voice note announced with its entry; bytes follow by presigned PUT (D-011)."""

    model_config = ConfigDict(extra="forbid")

    client_id: uuid.UUID = Field(description="UUIDv7 generated on the phone; the photo's id (D-005).")
    sha256: str = Field(
        pattern=r"^[0-9a-f]{64}$", description="Lower-case hex SHA-256 of the JPEG; bound into the PUT."
    )
    size_bytes: int = Field(gt=0, le=MAX_PHOTO_BYTES, description="File size in bytes.")
    content_type: Literal["image/jpeg", "audio/ogg", "audio/mp4"] = Field(
        "image/jpeg",
        description="`image/jpeg` for photos (M04); voice notes `audio/ogg` (Android 10+) or `audio/mp4` "
        "(iOS, Android 8–9). Bound into the PUT; picks the object key extension.",
    )
    exif_taken_at: AwareDatetime | None = Field(
        None, description="Capture time the phone wrote into EXIF, with offset; re-read by the server."
    )
    exif_gps: GeoPoint | None = Field(None, description="GPS position the phone wrote into EXIF, if any.")


class EventVersionBase(BaseModel):
    """Fields every event version carries, whatever its type (backend-design.md §2 `event_versions`)."""

    model_config = ConfigDict(extra="forbid")

    event_id: uuid.UUID = Field(description="Client id of the event, stable across its versions (D-005).")
    version_no: int = Field(ge=1, description="1 for a new event; each later version must be max + 1.")
    change_kind: Literal["create", "correct", "undo"] = Field(
        "create", description="`create` for version 1; `correct` (officer/admin) or `undo` (farmer) after."
    )
    subject_type: EventSubject = Field(description="`lot` for farm events, `batch` for processing events.")
    lot_id: uuid.UUID | None = Field(None, description="Lot of a farm event; exactly one of lot/batch.")
    batch_id: uuid.UUID | None = Field(None, description="Batch of a processing event.")
    plot_id: uuid.UUID | None = Field(None, description="Plot where a farm event happened (FR69 GPS check).")
    instance_no: int = Field(1, ge=1, description="1-based instance of this type on the subject (FR3).")
    occurred_on: date = Field(description="Date the activity happened (or started), YYYY-MM-DD.")
    occurred_end_on: date | None = Field(None, description="End date of a span such as drying.")
    clocks: ThreeClocks = Field(description="Device and GPS clocks at capture; the server adds its own.")
    gps: GeoPoint | None = Field(None, description="Device position at submission (FR26).")
    photos: list[PhotoIn] = Field(
        default_factory=list, max_length=MAX_PHOTOS_PER_ENTRY, description="Evidence photos (FR3, FR61)."
    )
    reason_code: str | None = Field(
        None, max_length=64, description="Coded reason; required for `correct` (422 `reason_required`)."
    )
    reason_text: str | None = Field(None, max_length=500, description="Free-text reason or comment (FR59).")

    @model_validator(mode="after")
    def _consistent(self) -> Self:
        """Check subject, dates and change kind agree with each other.

        Returns:
            The model unchanged.

        Raises:
            ValueError: subject id does not match `subject_type`, the end date is before the start, or
                `change_kind` is `create` exactly when `version_no` is not 1.
        """
        expected = self.lot_id if self.subject_type == EventSubject.LOT else self.batch_id
        if expected is None or (self.lot_id is not None and self.batch_id is not None):
            raise ValueError("send exactly one of lot_id / batch_id, matching subject_type")
        if self.occurred_end_on is not None and self.occurred_end_on < self.occurred_on:
            raise ValueError("occurred_end_on is before occurred_on")
        if (self.version_no == 1) != (self.change_kind == "create"):
            raise ValueError("version 1 is change_kind create; later versions are correct or undo")
        return self


def _type_field(event_type: EventType) -> Any:
    """Build the discriminator field of one variant.

    Args:
        event_type: the variant's event type.

    Returns:
        A pydantic `Field` describing the constant.
    """
    return Field(description=f"Always `{event_type.value}` for this variant (discriminator).")


class LandPreparationVersion(EventVersionBase):
    """Version of a land preparation event (Stage 1)."""

    event_type: Literal[EventType.LAND_PREPARATION] = _type_field(EventType.LAND_PREPARATION)
    payload: LandPreparationPayload = Field(description="Land preparation fields.")


class NurseryVersion(EventVersionBase):
    """Version of a nursery preparation event (FR55)."""

    event_type: Literal[EventType.NURSERY] = _type_field(EventType.NURSERY)
    payload: NurseryPayload = Field(description="Nursery fields.")


class SowingVersion(EventVersionBase):
    """Version of a sowing / transplanting event (Stage 2)."""

    event_type: Literal[EventType.SOWING] = _type_field(EventType.SOWING)
    payload: SowingPayload = Field(description="Sowing fields.")


class InputApplicationVersion(EventVersionBase):
    """Version of a fertiliser or pesticide application (Stage 3)."""

    event_type: Literal[EventType.INPUT_APPLICATION] = _type_field(EventType.INPUT_APPLICATION)
    payload: InputApplicationPayload = Field(description="Input application fields.")


class HarvestVersion(EventVersionBase):
    """Version of a harvest round (Stage 4)."""

    event_type: Literal[EventType.HARVEST] = _type_field(EventType.HARVEST)
    payload: HarvestPayload = Field(description="Harvest fields.")


class DryingVersion(EventVersionBase):
    """Version of a drying start, end or span (Stage 5)."""

    event_type: Literal[EventType.DRYING] = _type_field(EventType.DRYING)
    payload: DryingPayload = Field(description="Drying fields.")


class PackingVersion(EventVersionBase):
    """Version of on-farm packing (Stage 6)."""

    event_type: Literal[EventType.PACKING] = _type_field(EventType.PACKING)
    payload: PackingPayload = Field(description="Packing fields.")


class ProblemVersion(EventVersionBase):
    """Version of a field problem report."""

    event_type: Literal[EventType.PROBLEM] = _type_field(EventType.PROBLEM)
    payload: ProblemPayload = Field(description="Problem fields.")


class IntakeVersion(EventVersionBase):
    """Version of a sale-to-processor intake on the lot timeline (Stage 7)."""

    event_type: Literal[EventType.INTAKE] = _type_field(EventType.INTAKE)
    payload: IntakePayload = Field(description="Intake fields.")


class GradingVersion(EventVersionBase):
    """Version of a batch grading event (Stage 8)."""

    event_type: Literal[EventType.GRADING] = _type_field(EventType.GRADING)
    payload: GradingPayload = Field(description="Grading fields.")


class FinalPackingVersion(EventVersionBase):
    """Version of a batch final packing event (Stage 9)."""

    event_type: Literal[EventType.FINAL_PACKING] = _type_field(EventType.FINAL_PACKING)
    payload: FinalPackingPayload = Field(description="Final packing fields.")


# DECISION D-014: one version shape for all eleven types; only `payload` differs, chosen by `event_type`.
#   ADV: one sync, correction, undo and audit path; OpenAPI renders oneOf + discriminator, so the Dart and
#     TS generators produce one typed class per event type.
#   COMPROMISE: payload fields are JSONB, not columns; tenant requiredness is applied later (B13, D-017).
AnyEventVersion = (
    LandPreparationVersion
    | NurseryVersion
    | SowingVersion
    | InputApplicationVersion
    | HarvestVersion
    | DryingVersion
    | PackingVersion
    | ProblemVersion
    | IntakeVersion
    | GradingVersion
    | FinalPackingVersion
)
EventVersionIn = Annotated[AnyEventVersion, Field(discriminator="event_type")]


class CorrectionIn(BaseModel):
    """A correction of an event: the same shape as a sync `event_version` entry (FR25)."""

    client_id: uuid.UUID = Field(description="Client id of the new version (idempotency key, D-005).")
    data: EventVersionIn = Field(description="The full corrected version; `change_kind` must be `correct`.")


class UndoIn(BaseModel):
    """A farmer's undo of an own entry within 24 hours (FR6, FR25)."""

    model_config = ConfigDict(extra="forbid")

    client_id: uuid.UUID = Field(description="Client id of the undo version (idempotency key, D-005).")
    version_no: int = Field(ge=2, description="Current max version + 1.")
    reason_code: str | None = Field(
        None, max_length=64, description="Coded reason, e.g. `entered_by_mistake`."
    )
    reason_text: str | None = Field(None, max_length=500, description="Free-text comment.")
    clocks: ThreeClocks | None = Field(
        None, description="Phone clocks at the undo; omitted means server now."
    )


class SyncMetricIn(BaseModel):
    """Per-entry sync telemetry measured on the phone (plan §13 F1)."""

    entry_client_id: uuid.UUID = Field(description="Client id of the entry measured.")
    saved_at: AwareDatetime = Field(description="When the entry was saved on the phone.")
    acked_at: AwareDatetime | None = Field(None, description="When the server acknowledged it, if known.")
    photo_upload_ms: int | None = Field(None, ge=0, description="Total photo upload time in milliseconds.")
    failures: int = Field(0, ge=0, description="Failed send attempts before success.")
    network_type: str | None = Field(
        None, max_length=16, description="Network at send time: 2g, 3g, lte, wifi."
    )


class SyncEntry(BaseModel):
    """One offline entry; `data` is validated per entry, so one bad entry never rejects the batch."""

    client_id: uuid.UUID = Field(
        description="Id of the record created (event version, reading, plot, consent, farmer, assist "
        "session, lot intake); idempotency key."
    )
    kind: Literal[
        "event_version",
        "quality_reading",
        "plot",
        "consent",
        "flag_resolution",
        "farmer",
        "assist_session",
        "lot_intake",
    ] = Field(description="What `data` holds.")
    data: dict[str, Any] = Field(
        description="`event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: "
        "`QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: "
        "`FlagResolutionEntry` `{flag_id, resolution, reason_code, note}` (its `server_id` is the flag id); "
        "`farmer`: `FarmerIn` (field officer or FPO admin; stored `pending`, D-031); `assist_session`: "
        "`AssistStartIn` without `client_id` (field officer only, D-032); `lot_intake`: `IntakeIn` without "
        "`client_id` (QC officer or FPO admin; receives the lot, `processor_id` optional, corrections FPO "
        "admin only; its `server_id` is the intake id, D-040). "
        "Otherwise the entry's `client_id` is used as the record's id."
    )
    assist_session_id: uuid.UUID | None = Field(
        None,
        description="Assist session this entry was captured in (D-032): one of the caller's sessions, "
        "open or ended, pushed earlier as an `assist_session` entry or started online. Records assist "
        "mode for this entry only (event version, audit row, consent witness); the entry's farmer must "
        "be the session's (`forbidden` otherwise: consent, plot, lot event, reading on a lot); a batch "
        "reading or batch event with it → `forbidden` (D-042); unknown or another officer's → "
        "`assist_session_invalid`. When absent, the `X-Assist-Session` header applies. Ignored (no "
        "lookup, no assist fields) on `farmer`, `flag_resolution`, `assist_session` and `lot_intake` "
        "entries.",
    )


class SyncPushIn(BaseModel):
    """Sync push envelope: at most 50 entries and 256 KB (backend-design.md §3, plan §13 A4)."""

    device_id: uuid.UUID = Field(description="Device id of the app; the token's device is what is stored.")
    app_version: str = Field(max_length=32, description="App version, e.g. `1.0.3`.")
    device_time: AwareDatetime = Field(description="Phone clock when the push was sent.")
    metrics: list[SyncMetricIn] = Field(
        default_factory=list, max_length=200, description="Telemetry rows to store in `sync_metrics`."
    )
    entries: list[SyncEntry] = Field(
        max_length=MAX_ENTRIES, description="Entries in capture order; each one is its own transaction."
    )


class PhotoUpload(BaseModel):
    """How to upload one photo: a single presigned PUT (D-011)."""

    photo_client_id: uuid.UUID = Field(description="The photo's client id.")
    method: Literal["PUT"] = Field("PUT", description="HTTP method to use.")
    url: str = Field(description="Presigned URL on the public storage endpoint.")
    headers: dict[str, str] = Field(
        description="Headers to send exactly: `Content-Type` and `x-amz-checksum-sha256` (base64)."
    )
    expires_at: datetime = Field(description="When the URL stops working (15 minutes).")


class SyncResult(BaseModel):
    """Outcome of one entry (or of a REST correction / undo)."""

    client_id: uuid.UUID = Field(description="The entry's client id.")
    status: Literal["accepted", "duplicate", "rejected"] = Field(
        description="accepted: stored now; duplicate: already stored by you; rejected: see `error`."
    )
    server_id: uuid.UUID | None = Field(None, description="Id of the stored record (equals client_id).")
    photo_uploads: list[PhotoUpload] = Field(
        default_factory=list, description="Uploads still owed; on a duplicate only photos not yet uploaded."
    )
    error: ErrorBody | None = Field(None, description="Why the entry was rejected.")


class SyncPushOut(BaseModel):
    """Per-entry results, in the order sent."""

    server_time: datetime = Field(description="Server clock (UTC), for the phone's skew display.")
    results: list[SyncResult] = Field(description="One result per entry, same order.")


class PhotoRef(BaseModel):
    """A photo the phone has uploaded."""

    client_id: uuid.UUID = Field(description="The photo's client id.")


class PhotosConfirmIn(BaseModel):
    """Photos the phone believes are uploaded."""

    photos: list[PhotoRef] = Field(min_length=1, max_length=MAX_ENTRIES, description="Photos to confirm.")


class PhotoConfirmOut(BaseModel):
    """Whether storage holds the photo."""

    client_id: uuid.UUID = Field(description="The photo's client id.")
    status: Literal["received", "missing"] = Field(
        description="received: stored and queued for verification; missing: upload again, then confirm."
    )


class EventPhotoOut(BaseModel):
    """An evidence photo on the timeline."""

    id: uuid.UUID = Field(description="Photo id.")
    status: PhotoStatus = Field(description="Upload and verification state.")
    variants: dict[str, Any] | None = Field(
        None,
        description=(
            "{thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of "
            "the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never "
            "listed (it keeps exact EXIF GPS). Re-read for fresh links."
        ),
    )


class EventOut(BaseModel):
    """One event with its latest version, lean for 2G timelines (FR63)."""

    id: uuid.UUID = Field(description="Event id.")
    event_type: EventType = Field(description="Event type.")
    instance_no: int = Field(description="Instance of this type on the lot.")
    status: EventStatus = Field(description="submitted, undone, ... (FR59).")
    occurred_on: date = Field(description="Date of the latest version.")
    occurred_end_on: date | None = Field(description="End date for spans.")
    version_no: int = Field(description="Number of the latest version.")
    change_kind: ChangeKind = Field(description="How the latest version came about.")
    payload: dict[str, Any] = Field(description="Typed payload of the latest version (D-014).")
    entered_by_user_id: uuid.UUID = Field(description="Who entered the latest version.")
    on_behalf_of_farmer_id: uuid.UUID | None = Field(description="Farmer assisted, in assist mode.")
    is_system_generated: bool = Field(description="True for platform entries (FR59).")
    reason_code: str | None = Field(description="Reason of a correction or undo.")
    photos: list[EventPhotoOut] = Field(description="Photos of the latest version.")


class BundlePart(StrEnum):
    """Offline reference-bundle parts (backend-design.md §3; bodies per docs/agents/reports/M03.md)."""

    PLOTS = "plots"
    CROPS = "crops"
    INPUTS = "inputs"
    STANDARDS = "standards"
    GI_REGION = "gi_region"
    FARMER_PROFILE = "farmer_profile"
    VILLAGES = "villages"
    FIELDS = "fields"
    PROMPTS = "prompts"
    IMAGES = "images"
    CALENDAR = "calendar"


class PartVersion(BaseModel):
    """Version and ETag of one bundle part as the caller would download it now."""

    version: int = Field(
        description=(
            "Part version: from `reference_versions` for database-fed parts (only grows), a content "
            "fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`."
        )
    )
    etag: str = Field(description="Strong ETag of the part body; send it in `If-None-Match` for a 304.")


class BundleManifest(BaseModel):
    """Every bundle part available to the caller, with version and ETag (FR4, plan §13 C2)."""

    parts: dict[BundlePart, PartVersion] = Field(
        description="Part name -> version and ETag. `gi_region` is absent while no region is in effect."
    )


class ReferencePart(PartVersion):
    """A changed bundle part with its body."""

    body: dict[str, Any] = Field(description="The part body, as `GET /v1/sync/bundle/{part}` returns it.")


class ReferenceOut(BaseModel):
    """Parts whose version differs from the ones the phone holds (plan §13 C2)."""

    parts: dict[BundlePart, ReferencePart] = Field(description="Changed or new parts only.")


class PullChange(BaseModel):
    """One server-side change for the phone's local copy."""

    entity: Literal["flag", "lot", "event", "intake", "notification", "photo_pending"] = Field(
        description="Kind of record in `data`."
    )
    op: Literal["upsert"] = Field(description="Always `upsert`: replace the local row with the same `id`.")
    data: dict[str, Any] = Field(description="The record, lean; decimals are strings, times ISO 8601 UTC.")


class PullOut(BaseModel):
    """One page of changes since the cursor (backend-design.md §3)."""

    changes: list[PullChange] = Field(description="Changes ordered by change time, then id.")
    next_cursor: str | None = Field(
        description="Opaque cursor to send next time; equals the sent cursor when nothing changed."
    )
    has_more: bool = Field(description="True when another page is waiting; call again with `next_cursor`.")
