"""Payload schemas of the on-farm event types (Stages 1–6 plus problem reports), one model per type.

Every field is optional: which fields a tenant requires is field configuration (D-017, supplied by B13),
never hard-coded here. Quantities are `Quantity` (value + unit, FR58). Dates of the activity itself live on
the version (`occurred_on`, `occurred_end_on`), not in the payload.

Serves: Dataflow Stages 1–6, FR3 (structured fields per event type), FR55 (nursery split from sowing),
FR56 (input from the master list), FR57 (harvest quantity), FR58, D-014 (typed JSON payloads).
Callers: `events.schemas` (discriminated union of event versions), tests/unit/test_events_payloads.py.
"""

import uuid
from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from agritrace.core.schemas import Quantity


class Payload(BaseModel):
    """Base of every payload: unknown keys are rejected, so a typo never silently drops data."""

    model_config = ConfigDict(extra="forbid")


class LandPreparationPayload(Payload):
    """Stage 1 land preparation: cultivated area and the last ploughing date."""

    cultivated_area: Quantity | None = Field(
        None, description="Area prepared, unit `acre` (flagged when above the plot's declared size)."
    )
    last_ploughed_on: date | None = Field(None, description="Last date of ploughing, YYYY-MM-DD.")


class NurseryPayload(Payload):
    """Nursery preparation, split from main-field sowing (FR55); seeding date is `occurred_on`."""

    seed_variety: str | None = Field(None, max_length=120, description="Seed variety, e.g. `K2`.")
    nursery_area: Quantity | None = Field(None, description="Nursery bed area, e.g. unit `cent`.")


class SowingPayload(Payload):
    """Stage 2 sowing or transplanting in the main field, one entry per instance (FR3, FR55)."""

    seed_variety: str | None = Field(None, max_length=120, description="Seed variety sown or transplanted.")
    method: Literal["direct_seeding", "transplanting"] | None = Field(
        None, description="Direct seeding, or transplanting nursery seedlings."
    )
    sown_area: Quantity | None = Field(None, description="Area sown, unit `acre`.")


class InputApplicationPayload(Payload):
    """Stage 3 fertiliser or pesticide application, many instances per season (FR56)."""

    input_id: uuid.UUID | None = Field(
        None, description="Input from the master list (`GET /v1/inputs`); practice tags derive from it."
    )
    input_name: str | None = Field(
        None, max_length=200, description="Name as written by the farmer when the input is not in the list."
    )
    quantity: Quantity | None = Field(None, description="Amount applied, e.g. `{value: 25, unit: kg}`.")


class HarvestPayload(Payload):
    """Stage 4 harvest round; several rounds per lot (FR3, FR57)."""

    quantity: Quantity | None = Field(None, description="Harvested quantity, unit `kg` (FR57 yield check).")
    bags: int | None = Field(None, ge=0, description="Number of bags filled.")


class DryingPayload(Payload):
    """Stage 5 drying on the farm; several drying runs allowed.

    `start` is recorded when drying begins, `end` when it ends; one entry may carry the whole span
    (`occurred_on` = start, `occurred_end_on` = end). The end-of-drying moisture is a quality reading.
    """

    phase: Literal["start", "end"] | None = Field(
        None, description="Which moment this entry records; omit when it carries the whole span."
    )
    quantity: Quantity | None = Field(None, description="Quantity spread for drying, unit `kg`.")
    moisture_reading_id: uuid.UUID | None = Field(
        None, description="Client id of the end-of-drying moisture reading (kind `quality_reading`)."
    )


class PackingPayload(Payload):
    """Stage 6 on-farm packing."""

    quantity: Quantity | None = Field(None, description="Packed quantity, unit `kg` (FR58).")
    bags: int | None = Field(None, ge=0, description="Number of bags packed.")


class ProblemPayload(Payload):
    """A problem seen in the field (pest, disease, weather), reported with a photo."""

    problem_type: Literal["pest", "disease", "weather", "other"] | None = Field(
        None, description="Kind of problem."
    )
    description: str | None = Field(
        None, max_length=1000, description="What was seen, in the farmer's words."
    )
    affected_area: Quantity | None = Field(None, description="Area affected, unit `acre` or `cent`.")
