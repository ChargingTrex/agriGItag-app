"""Unit tests of the event version union: one variant per event type, payload validation, consistency.

Serves: B06 deliverable 1 (discriminated union on `event_type`, D-014), FR3, FR55–FR58.
Callers: pytest (`make test-unit`); no Docker needed.
"""

import uuid
from typing import Any

import pytest

from agritrace.core.enums import EventType
from agritrace.core.errors import ValidationFailedError
from agritrace.modules.events.service import parse_version

KG = {"value": "195", "unit": "kg"}
VALID: dict[EventType, dict[str, Any]] = {
    EventType.LAND_PREPARATION: {
        "cultivated_area": {"value": 1.5, "unit": "acre"},
        "last_ploughed_on": "2025-09-01",
    },
    EventType.NURSERY: {"seed_variety": "K2"},
    EventType.SOWING: {"method": "transplanting"},
    EventType.INPUT_APPLICATION: {"input_id": str(uuid.uuid4()), "quantity": {"value": 25, "unit": "kg"}},
    EventType.HARVEST: {"quantity": KG, "bags": 13},
    EventType.DRYING: {"phase": "start", "quantity": KG},
    EventType.PACKING: {"quantity": KG, "bags": 4},
    EventType.PROBLEM: {"problem_type": "pest", "description": "thrips on leaves"},
    EventType.INTAKE: {"received": KG, "price_per_kg": "210.50"},
    EventType.GRADING: {"quantity": KG, "declared_grade": "Standard"},
    EventType.FINAL_PACKING: {"quantity": KG, "pack_size": {"value": 250, "unit": "g"}, "packs": 780},
}
BATCH_TYPES = {EventType.GRADING, EventType.FINAL_PACKING}


def version(event_type: EventType, payload: dict[str, Any], **over: Any) -> dict[str, Any]:
    """Build the raw `data` of an event_version entry.

    Args:
        event_type: the type.
        payload: its payload.
        **over: fields to replace.

    Returns:
        The entry data.
    """
    subject = {"subject_type": "batch", "batch_id": str(uuid.uuid4())}
    if event_type not in BATCH_TYPES:
        subject = {"subject_type": "lot", "lot_id": str(uuid.uuid4())}
    data = {
        "event_id": str(uuid.uuid4()),
        "version_no": 1,
        "event_type": event_type.value,
        "occurred_on": "2026-03-04",
        "clocks": {"device_time": "2026-03-04T08:12:10+05:30"},
        "payload": payload,
        **subject,
    }
    return {**data, **over}


@pytest.mark.parametrize("event_type", list(EventType))
def test_every_event_type_has_a_variant(event_type: EventType) -> None:
    """Each of the eleven types parses into its own variant with a typed payload.

    Args:
        event_type: the type under test.
    """
    parsed = parse_version(version(event_type, VALID[event_type]))
    assert parsed.event_type == event_type
    assert type(parsed).__name__.endswith("Version")
    assert type(parsed.payload).__name__.lower().startswith(event_type.value.replace("_", ""))


@pytest.mark.parametrize("event_type", list(EventType))
def test_empty_payload_is_accepted(event_type: EventType) -> None:
    """No payload field is hard-coded as required (tenant requiredness is B13 field config, D-017).

    Args:
        event_type: the type under test.
    """
    assert parse_version(version(event_type, {})).event_type == event_type


@pytest.mark.parametrize(
    ("data", "loc_part"),
    [
        (version(EventType.HARVEST, {"quantity": {"value": -1, "unit": "kg"}}), "quantity"),
        (version(EventType.HARVEST, {"quantity": 195}), "quantity"),  # FR58: never a bare number
        (version(EventType.HARVEST, {"weight": KG}), "weight"),  # unknown key rejected
        (version(EventType.SOWING, {"method": "broadcast"}), "method"),
        (
            {**version(EventType.HARVEST, VALID[EventType.HARVEST]), "event_type": "weeding"},
            "union_tag_invalid",
        ),
    ],
)
def test_bad_payloads_are_rejected(data: dict[str, Any], loc_part: str) -> None:
    """Wrong payload values, bare numbers, unknown keys and unknown types answer `validation_error`.

    Args:
        data: the invalid entry data.
        loc_part: a path element (or the error type) expected in one error.
    """
    with pytest.raises(ValidationFailedError) as exc:
        parse_version(data)
    assert any(loc_part in [*map(str, d["loc"]), d["type"]] for d in exc.value.details)


@pytest.mark.parametrize(
    "over",
    [
        {"lot_id": None},  # subject_type lot without lot_id
        {"batch_id": str(uuid.uuid4())},  # both subjects
        {"occurred_end_on": "2026-03-01"},  # end before start
        {"version_no": 2},  # version 2 must be correct or undo
        {"change_kind": "correct"},  # version 1 must be create
        {"clocks": {"device_time": "2026-03-04T08:12:10"}},  # naive time
    ],
)
def test_inconsistent_versions_are_rejected(over: dict[str, Any]) -> None:
    """Subject, dates, change kind and clocks must agree.

    Args:
        over: the inconsistent change.
    """
    with pytest.raises(ValidationFailedError):
        parse_version(version(EventType.HARVEST, VALID[EventType.HARVEST], **over))


def test_union_renders_as_one_of_with_discriminator() -> None:
    """OpenAPI shows the version union as oneOf + discriminator, one mapping entry per event type."""
    from agritrace.main import create_app

    spec = create_app().openapi()
    data = spec["components"]["schemas"]["CorrectionIn"]["properties"]["data"]
    assert data["discriminator"]["propertyName"] == "event_type"
    assert set(data["discriminator"]["mapping"]) == {t.value for t in EventType}
    assert len(data["oneOf"]) == len(EventType)
