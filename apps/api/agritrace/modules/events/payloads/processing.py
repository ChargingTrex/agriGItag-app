"""Payload schemas of the processing event types (Stages 7–9), one model per type.

Quality parameters are not payload fields: they are quality readings (`kind=quality_reading`, FR42), and
the event only points at them. Requiredness is field configuration (D-017, B13).

Serves: Dataflow Stages 7–9, FR3, FR58, D-014.
Callers: `events.schemas`, tests/unit/test_events_payloads.py.
"""

import uuid
from decimal import Decimal

from pydantic import Field

from agritrace.core.schemas import Quantity
from agritrace.modules.events.payloads.farm import Payload


class IntakePayload(Payload):
    """Stage 7 sale of a lot to the processor, as recorded on the lot's timeline."""

    processor_id: uuid.UUID | None = Field(None, description="Processor that received the lot.")
    received: Quantity | None = Field(None, description="Quantity received, unit `kg`.")
    price_per_kg: Decimal | None = Field(None, ge=0, description="Price paid in INR per kg (optional).")
    moisture_reading_id: uuid.UUID | None = Field(
        None, description="Client id of the intake moisture reading taken at the gate."
    )


class GradingPayload(Payload):
    """Stage 8 grading / sorting of a batch; readings and the computed grade live in quality."""

    quantity: Quantity | None = Field(None, description="Graded quantity, unit `kg` (ceiling for packing).")
    declared_grade: str | None = Field(None, max_length=40, description="Grade declared by the QC officer.")


class FinalPackingPayload(Payload):
    """Stage 9 final (retail) packing of a batch."""

    quantity: Quantity | None = Field(None, description="Packed quantity, unit `kg`.")
    pack_size: Quantity | None = Field(
        None, description="Size of one retail pack, e.g. `{value: 250, unit: g}`."
    )
    packs: int | None = Field(None, ge=0, description="Number of packs filled.")
    avg_sale_price_per_kg: Decimal | None = Field(None, ge=0, description="Average sale price, INR per kg.")
