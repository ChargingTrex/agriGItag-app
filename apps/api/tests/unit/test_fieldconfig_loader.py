"""Unit tests of the field/feature YAML: schema validation, start-up refusal, tenant overrides, validator.

Covers B13 acceptance "YAML failing its schema → app refuses to start with a clear message", "disabling
soil type in a tenant file makes the field optional and hidden for that FPO only", and the table-driven
`validate_payload` cases (disabled field dropped, required blocks, tenant override wins, unknown field
rejected only under `extra: forbid`).
Serves: D-017, FR23. Callers: pytest (`make test-unit`); no Docker.
"""

import shutil
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest

from agritrace.core import fieldconfig
from agritrace.core.config import get_settings
from agritrace.core.errors import AppError
from agritrace.core.fieldconfig import ConfigInvalid
from agritrace.main import create_app

DEMO = "VIRUDHAI_SCFC_VINOBA_BHAVA_FPO"
TENANT = f"tenants/{DEMO}.yaml"


@pytest.fixture
def config_dir(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Iterator[Path]:
    """A writable copy of apps/api/config that `fieldconfig.load()` reads for one test.

    Args:
        tmp_path: pytest temporary folder.
        monkeypatch: pytest monkeypatch.

    Returns:
        An iterator yielding the copied folder.

    Side effects:
        Points `fieldconfig.CONFIG_DIR` at the copy and clears the load cache before and after.
    """
    target = tmp_path / "config"
    shutil.copytree(fieldconfig.CONFIG_DIR, target)
    monkeypatch.setattr(fieldconfig, "CONFIG_DIR", target)
    fieldconfig.load.cache_clear()
    yield target
    fieldconfig.load.cache_clear()


def _replace(path: Path, old: str, new: str) -> None:
    """Edit one YAML file in place.

    Args:
        path: the file.
        old: text that must occur in it.
        new: its replacement.
    """
    text = path.read_text(encoding="utf-8")
    assert old in text
    path.write_text(text.replace(old, new), encoding="utf-8")


def test_shipped_config_is_valid() -> None:
    """The committed YAML parses, and every entity the clients need is present."""
    config = fieldconfig.parse(fieldconfig.CONFIG_DIR)
    assert {"farmer", "plot", "lot", "quality_reading", "event_harvest", "village", "input"} <= set(
        config.entities
    )
    assert config.features.id_document_capture is False
    assert config.features.sync_push_max_bytes == 262144
    assert DEMO in config.tenants


@pytest.mark.parametrize(
    ("file", "old", "new", "message"),
    [
        ("fields/plot.yaml", "{name: soil_type, type: text", "{name: soil_type, type: txt", "fields.13.type"),
        ("fields/farmer.yaml", "{name: phone,", "{name: phone, colour: red,", "Extra inputs"),
        ("fields/lot.yaml", "entity: lot", "entity: lots", "must equal the file name"),
        ("features.yaml", "producer_groups: false", "producer_groups: maybe", "producer_groups"),
        ("features.yaml", "otp_daily_cap: 10", "otp_daily_cap: 10\nnew_flag: true", "new_flag"),
        (TENANT, "soil_type:", "soil_typ:", "fields.plot.soil_typ: unknown field"),
        (TENANT, "  plot:", "  farmers:", "fields.farmers: unknown entity"),
        (TENANT, "    soil_type:", "    pin:", "core field cannot be disabled"),
        (TENANT, "fpo_code: VIRUDHAI", "fpo_code: OTHER_VIRUDHAI", "must equal the file name"),
        (TENANT, "boundary_walk: true", "boundary_walk: [", "cannot read YAML"),
    ],
)  # fmt: skip
def test_invalid_yaml_is_refused_with_the_file_and_key(
    config_dir: Path, file: str, old: str, new: str, message: str
) -> None:
    """Each kind of mistake fails `parse` with a message naming the file and the problem.

    Args:
        config_dir: the writable config copy.
        file: file to break, relative to the config folder.
        old: text to replace.
        new: broken text.
        message: substring the error must contain.
    """
    _replace(config_dir / file, old, new)
    with pytest.raises(ConfigInvalid) as err:
        fieldconfig.parse(config_dir)
    assert message in str(err.value)
    assert str(config_dir / file) in str(err.value)


async def test_app_refuses_to_start_on_invalid_yaml(
    config_dir: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The lifespan loads the config, so uvicorn exits before serving a single request.

    Args:
        config_dir: the writable config copy.
        monkeypatch: pytest monkeypatch.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test-secret")
    get_settings.cache_clear()
    _replace(config_dir / "features.yaml", "boundary_walk: true", "boundary_walk: sometimes")
    app = create_app()
    with pytest.raises(ConfigInvalid, match="features.yaml"):
        async with app.router.lifespan_context(app):
            pass  # pragma: no cover - never reached
    get_settings.cache_clear()


def test_tenant_disables_soil_type_for_that_fpo_only() -> None:
    """B13 acceptance: the demo tenant hides plot soil type; every other FPO still sees it."""
    assert "soil_type" not in [f.name for f in fieldconfig.fields_for("plot", DEMO)]
    assert "soil_type" in [f.name for f in fieldconfig.fields_for("plot", "SOME_OTHER_FPO")]
    assert "soil_type" in [f.name for f in fieldconfig.fields_for("plot", None)]
    assert "soil_type" not in fieldconfig.required_fields("plot", DEMO)


def test_features_and_public_fields() -> None:
    """Defaults apply without a tenant file; public fields never include phone or exact location."""
    assert fieldconfig.features_for("NO_FILE_FPO").producer_groups is False
    assert fieldconfig.features_for(DEMO).boundary_walk is True
    assert "phone" not in fieldconfig.public_fields("farmer")
    assert {"pin", "land_record_ref", "walked_boundary"}.isdisjoint(fieldconfig.public_fields("plot"))
    part = fieldconfig.bundle_part(DEMO)
    assert part["version"].startswith('"') and "soil_type" not in str(part["entities"]["plot"])


HARVEST = {"bags": 6, "quantity": {"value": 300, "unit": "kg"}}


@pytest.mark.parametrize(
    ("entity", "fpo", "data", "error", "expected"),
    [
        # disabled field is dropped, not refused
        ("plot", "REQ_FPO", {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t",
                             "declared_area": {}, "soil_type": "red", "gps_time": "g"}, None,
         {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t", "declared_area": {},
          "soil_type": "red"}),
        # required blocks (soil type required by default in this test config)
        ("plot", "REQ_FPO", {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t",
                             "declared_area": {}}, "field_required", None),
        # blank counts as missing
        ("plot", "REQ_FPO", {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t",
                             "declared_area": {}, "soil_type": "  "}, "field_required", None),
        # tenant override wins: the demo FPO disabled soil type, so it is neither required nor kept
        ("plot", DEMO, {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t",
                        "declared_area": {}, "soil_type": "red"}, None,
         {"client_id": "c", "farmer_id": "f", "pin": {}, "device_time": "t", "declared_area": {}}),
        # unknown field refused under extra: forbid ...
        ("farmer", None, {"name": "Muthu", "bogus": 1}, "field_unknown", None),
        # ... and kept under extra: allow
        ("event_harvest", None, {**HARVEST, "bogus": 1}, None, {**HARVEST, "bogus": 1}),
        ("event_harvest", None, {"bags": 6}, "field_required", None),
    ],
)  # fmt: skip
def test_validate_payload(
    config_dir: Path,
    entity: str,
    fpo: str | None,
    data: dict[str, Any],
    error: str | None,
    expected: dict[str, Any] | None,
) -> None:
    """Table-driven: dropped, required, override wins, unknown only under forbid.

    Args:
        config_dir: config copy where plot soil type is required and GPS time disabled by default.
        entity: entity name.
        fpo: FPO code.
        data: payload.
        error: expected error code, or None.
        expected: expected cleaned payload when no error.
    """
    _replace(
        config_dir / "fields/plot.yaml",
        "{name: soil_type, type: text, required: false",
        "{name: soil_type, type: text, required: true",
    )
    _replace(
        config_dir / "fields/plot.yaml",
        "{name: gps_time, type: datetime, required: false, enabled: true",
        "{name: gps_time, type: datetime, required: false, enabled: false",
    )
    if error is None:
        assert fieldconfig.validate_payload(entity, fpo, data) == expected
    else:
        with pytest.raises(AppError) as err:
            fieldconfig.validate_payload(entity, fpo, data)
        assert err.value.code == error
        assert err.value.details["field"] in {"soil_type", "bogus", "quantity"}
