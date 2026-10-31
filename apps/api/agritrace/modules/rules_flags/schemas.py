"""Request and response schemas of the flags API and of the `flag_resolution` sync entry.

Serves: FR70 (review on flags: outcome, reason, note), FR11/FR28/FR56/FR68/FR69 (what a flag says),
docs/api/conventions.md (cursor pages), backend-design §1 rules_flags row, §3 (`flag_resolution` push kind).
Callers: rules_flags router and service; the OpenAPI export and generated clients (D-003).
"""

import uuid
from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field

from agritrace.core.enums import FlagStatus, FlagSubject, Role, Severity

Resolution = Literal["looks_fine", "fixed", "escalated"]


class FlagOut(BaseModel):
    """One rule finding and its review state."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID = Field(description="Flag id (UUIDv7, so newer flags sort later).")
    fpo_id: uuid.UUID = Field(description="FPO that owns the flagged record.")
    subject_type: FlagSubject = Field(
        description="Kind of record flagged: plot, event, lot, batch or reading."
    )
    subject_id: uuid.UUID = Field(description="Id of the flagged record.")
    rule_code: str = Field(description="Rule that raised it, e.g. `quantity_mismatch`, `event_off_plot`.")
    severity: Severity = Field(description="info, warn, or hold (keeps the lot out of GI-labelled batches).")
    details: dict[str, Any] | None = Field(
        description="Rule inputs and limits behind the finding; quantities carry `unit`."
    )
    status: FlagStatus = Field(
        description="open, cleared (looked fine), fixed, or escalated to the FPO admin."
    )
    assigned_role: Role | None = Field(description="Role expected to review it: field_officer, or fpo_admin.")
    raised_at: datetime = Field(description="When a rule first raised it, ISO 8601 UTC.")
    resolved_by: uuid.UUID | None = Field(
        description="User who resolved it; null when open or closed by a rule."
    )
    resolution_reason_code: str | None = Field(
        description="Coded reason of the resolution; `rule_passed` when a later rule run no longer raised it."
    )
    resolution_note: str | None = Field(description="Reviewer's note: method, evidence, what was fixed.")
    resolved_at: datetime | None = Field(description="When it was resolved, ISO 8601 UTC.")


class FlagResolveIn(BaseModel):
    """A reviewer's outcome for one flag (FR70)."""

    resolution: Resolution = Field(
        description="looks_fine → cleared; fixed → fixed; escalated → escalated and reassigned to fpo_admin."
    )
    reason_code: str | None = Field(
        None,
        max_length=64,
        description="Coded reason, e.g. `land_record_checked`, `field_visit`; required (else 422).",
    )
    note: str | None = Field(None, max_length=2000, description="Free text: method, evidence, what changed.")


class FlagResolutionEntry(FlagResolveIn):
    """`data` of a `flag_resolution` sync push entry: the flag and the reviewer's outcome."""

    flag_id: uuid.UUID = Field(description="Flag being resolved (from `GET /v1/flags` or sync pull).")
