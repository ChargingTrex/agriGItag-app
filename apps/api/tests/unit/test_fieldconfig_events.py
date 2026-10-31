"""Unit test keeping `config/fields/event_*.yaml` and B06's event payload models (D-014) in step.

Every YAML field must be a key of the matching payload model and every payload key must have a YAML line,
so forms render every key and `validate_payload` never requires a key the phone cannot send (B13 review
r1 P2-3). Skipped until B06 (`agritrace.modules.events.payloads`) is on the branch.
Serves: D-017, D-014, FR22, FR23. Callers: pytest (`make test-unit`); no Docker.
"""

import pytest
from pydantic import BaseModel

from agritrace.core import fieldconfig

farm = pytest.importorskip("agritrace.modules.events.payloads.farm")
processing = pytest.importorskip("agritrace.modules.events.payloads.processing")

EVENT_TYPES = [
    "land_preparation", "nursery", "sowing", "input_application", "harvest", "drying", "packing",
    "problem", "intake", "grading", "final_packing",
]  # fmt: skip


def _model(event_type: str) -> type[BaseModel]:
    """Find B06's payload model for an event type (`harvest` → `HarvestPayload`).

    Args:
        event_type: event type code.

    Returns:
        The Pydantic payload model.
    """
    name = "".join(part.title() for part in event_type.split("_")) + "Payload"
    model: type[BaseModel] = getattr(farm, name, None) or getattr(processing, name)
    return model


@pytest.mark.parametrize("event_type", EVENT_TYPES)
def test_yaml_fields_equal_payload_keys(event_type: str) -> None:
    """YAML field names and payload model keys are the same set.

    Args:
        event_type: event type code.
    """
    yaml_names = {f.name for f in fieldconfig.load().entities[f"event_{event_type}"].fields}
    assert yaml_names == set(_model(event_type).model_fields)


def test_every_event_type_has_a_yaml_file() -> None:
    """No event entity in the YAML without a payload model, and none missing."""
    entities = {e.removeprefix("event_") for e in fieldconfig.load().entities if e.startswith("event_")}
    assert entities == set(EVENT_TYPES)
