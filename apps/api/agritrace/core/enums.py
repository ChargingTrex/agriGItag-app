"""Closed value sets of the domain model, shared by the tables, the API schemas and the rules.

Serves: backend-design.md §2 (every `a | b | c` column), PRD §5 (core concepts), FR14 (roles), FR56
(input categories, practice tags), D-014 (event types), D-012 (schema-first).
Callers: every `modules/*/models.py` (through `core.db.Base.type_annotation_map`), `core.auth`
(`Role`), `core.schemas` (`PracticeTag`), module schemas and services (B02+), tests/unit/test_models.py.

Members are UPPER_CASE; the stored and wire value is the lower-case `.value` (see `core.db.Base`).
Adding a value is additive under D-020; removing or renaming one is a breaking change.
"""

from enum import StrEnum


class Role(StrEnum):
    """A user's role inside one FPO (FR14, Dataflow §3 role matrix)."""

    FARMER = "farmer"
    FIELD_OFFICER = "field_officer"
    QC_OFFICER = "qc_officer"
    FPO_ADMIN = "fpo_admin"
    VIEWER = "viewer"


class UserStatus(StrEnum):
    """Whether a user account may sign in (FR1)."""

    ACTIVE = "active"
    SUSPENDED = "suspended"


class ConsentType(StrEnum):
    """What a farmer consented to (FR41, CLAUDE.md §6)."""

    DATA_COLLECTION = "data_collection"
    PUBLIC_NAME = "public_name"
    PARTNER_SHARE = "partner_share"


class OrgKind(StrEnum):
    """Legal form of an FPO or processor (PRD §5 Processor / FPO entity)."""

    FPO = "fpo"
    COMPANY = "company"
    COOP = "coop"


class FarmerStatus(StrEnum):
    """Farmer onboarding state (Stage 0; FR67 activates on a confirmed location)."""

    PENDING = "pending"
    ACTIVE = "active"
    SUSPENDED = "suspended"


class PinMethod(StrEnum):
    """How a plot pin was placed (FR64)."""

    LIVE_GPS = "live_gps"
    MAP_PIN = "map_pin"


class FarmingType(StrEnum):
    """Irrigated or rainfed farming (FR54)."""

    IRRIGATED = "irrigated"
    RAINFED = "rainfed"


class IrrigationSource(StrEnum):
    """Water source of an irrigated plot (FR54)."""

    WELL = "well"
    BOREWELL = "borewell"
    CANAL = "canal"
    TANK = "tank"
    RAIN = "rain"


class LocationStatus(StrEnum):
    """Result of the GI region check on a plot (FR28, FR67, FR70)."""

    CONFIRMED = "confirmed"
    NEEDS_REVIEW = "needs_review"
    OUTSIDE = "outside"
    NEAR_EDGE = "near_edge"


class InputCategory(StrEnum):
    """Category of a farm input; practice tags are derived from it (FR56)."""

    CHEMICAL_FERTILIZER = "chemical_fertilizer"
    ORGANIC_FERTILIZER = "organic_fertilizer"
    BIO_FERTILIZER = "bio_fertilizer"
    CHEMICAL_PESTICIDE = "chemical_pesticide"
    BIO_PESTICIDE = "bio_pesticide"
    OTHER = "other"


class PracticeTag(StrEnum):
    """Farming practice label declared by the farmer or derived from inputs (FR56, PRD §5)."""

    ORGANIC = "organic"
    INORGANIC = "inorganic"
    IPM = "ipm"


class ProducerGroupKind(StrEnum):
    """Kind of producer group (flag `producer_groups`, D-017)."""

    SHG = "shg"
    OTHER = "other"


class EventSubject(StrEnum):
    """What a farm or processing event is recorded against (PRD §5)."""

    LOT = "lot"
    BATCH = "batch"


class EventType(StrEnum):
    """Event types sharing the one event_versions table (D-014; Stages 1–9; FR3, FR55)."""

    LAND_PREPARATION = "land_preparation"
    NURSERY = "nursery"
    SOWING = "sowing"
    INPUT_APPLICATION = "input_application"
    HARVEST = "harvest"
    DRYING = "drying"
    PACKING = "packing"
    PROBLEM = "problem"
    INTAKE = "intake"
    GRADING = "grading"
    FINAL_PACKING = "final_packing"


class EventStatus(StrEnum):
    """Lifecycle of an event (FR25, FR59)."""

    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDONE = "undone"
    SUPERSEDED = "superseded"
    LOCKED = "locked"


class ChangeKind(StrEnum):
    """Why an event version exists (FR25 corrections with reason, FR59 system entries)."""

    CREATE = "create"
    CORRECT = "correct"
    UNDO = "undo"
    SYSTEM = "system"


class PhotoStatus(StrEnum):
    """Upload and verification state of an evidence photo (FR61, D-011)."""

    PENDING_UPLOAD = "pending_upload"
    UPLOADED = "uploaded"
    VERIFIED = "verified"
    CHECKSUM_MISMATCH = "checksum_mismatch"
    EXIF_MISMATCH = "exif_mismatch"


class LotStatus(StrEnum):
    """Component lot lifecycle (Stages 4–7)."""

    OPEN = "open"
    DRYING = "drying"
    READY_FOR_SALE = "ready_for_sale"
    RECEIVED = "received"
    BATCHED = "batched"
    CLOSED = "closed"


class BatchStatus(StrEnum):
    """Batch lifecycle (Stages 7–10)."""

    CREATED = "created"
    GRADED = "graded"
    PACKED = "packed"
    PUBLISHED = "published"


class ApprovalStage(StrEnum):
    """Approval gates on a batch (Dataflow §4)."""

    INTAKE = "intake"
    GRADING = "grading"
    FINAL_PACKING = "final_packing"
    PUBLISH = "publish"


class StandardsScheme(StrEnum):
    """Grading scheme of a standards profile (FR47)."""

    AGMARK = "agmark"
    ISO = "iso"
    FSSAI = "fssai"
    CUSTOM = "custom"


class ProfileVersionStatus(StrEnum):
    """Publication state of a standards profile version (FR47)."""

    DRAFT = "draft"
    PUBLISHED = "published"
    RETIRED = "retired"


class InstrumentKind(StrEnum):
    """Kind of registered measuring instrument (FR42, PRD §5 Instrument)."""

    MOISTURE_METER = "moisture_meter"
    COLORIMETER = "colorimeter"
    HYGROMETER = "hygrometer"
    SCALE = "scale"


class ReadingStage(StrEnum):
    """Where in the chain a quality reading was taken (FR43, FR45)."""

    DRYING_END = "drying_end"
    INTAKE = "intake"
    GRADING = "grading"
    STORAGE = "storage"


class ReadingSource(StrEnum):
    """How a quality value was measured (FR42, FR44)."""

    LAB = "lab"
    INSTRUMENT = "instrument"
    VISUAL = "visual"


class GradeStatus(StrEnum):
    """Outcome of a grade computation (FR48, FR49)."""

    INCOMPLETE = "incomplete"
    OK = "ok"
    DECLARED_ABOVE_COMPUTED = "declared_above_computed"


class FlagSubject(StrEnum):
    """What a rule flag is raised on (FR11, FR28, FR69)."""

    PLOT = "plot"
    EVENT = "event"
    LOT = "lot"
    BATCH = "batch"
    READING = "reading"


class Severity(StrEnum):
    """Flag severity; `hold` blocks GI labelling until resolved (FR68, FR70)."""

    INFO = "info"
    WARN = "warn"
    HOLD = "hold"


class FlagStatus(StrEnum):
    """Flag resolution state (FR70)."""

    OPEN = "open"
    CLEARED = "cleared"
    FIXED = "fixed"
    ESCALATED = "escalated"


class NotificationChannel(StrEnum):
    """Delivery channel of a notification (FR7)."""

    PUSH = "push"
    SMS = "sms"
    WHATSAPP = "whatsapp"
    CONSOLE = "console"


class NotificationStatus(StrEnum):
    """Delivery state of a notification (FR7)."""

    QUEUED = "queued"
    SENT = "sent"
    FAILED = "failed"
