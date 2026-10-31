"""publishing API models: public page builds.

Serves: FR15-FR17 (page versions with a generation stamp), D-007, D-020 (additive /v1 contract).
Callers: `publishing.router` (response models); the portal (P04) through the generated client (D-003).
"""

import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class BuildOut(BaseModel):
    """One build of a batch's public page."""

    id: uuid.UUID = Field(description="`page_builds` row id.")
    batch_id: uuid.UUID = Field(description="Batch the page is for.")
    build_no: int = Field(description="Build number per batch, 1 upwards; each publish or rebuild adds one.")
    generation: int = Field(description="Generation stamp shown in the page footer and data.json.")
    status: str = Field(
        description="`queued`, `built`, `failed` (see `error`) or `superseded` (a newer build ran first)."
    )
    trigger: str = Field(description="What asked for it: `publish` or `rebuild`.")
    built_at: datetime | None = Field(description="When the page was written (FR17); null until built.")
    html_key: str | None = Field(
        description="public-pages key of index.html, e.g. `batches/<code>/index.html`."
    )
    json_key: str | None = Field(description="public-pages key of data.json.")
    qr_key: str | None = Field(description="public-pages key of qr.png.")
    error: dict[str, Any] | None = Field(
        description="On `failed`: `{code: public_record_invalid, details: [{loc, msg, type}]}`; values are "
        "never echoed."
    )
