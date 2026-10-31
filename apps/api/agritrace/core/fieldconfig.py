"""Field and feature configuration from `apps/api/config/*.yaml`: schema, loader, tenant overrides, validator.

Serves: D-017 (YAML field/feature config with per-tenant overrides), FR22/FR23 (configurable capture per
crop and tenant), FR53, FR56, PLAN "Gap analysis" (ID capture, PIN login, SHG groups, master data uploads).
Callers: `agritrace.main` lifespan (`load`, refuses to start on invalid YAML), config router (GET
/v1/config/*), registry service hooks (`create_farmer`, `create_plot`) and imports (templates,
`validate_payload`), registry router feature gates; later events (B06), sync bundle (B07, `bundle_part`),
publishing (B10, `public_fields`).
"""

import hashlib
import json
from functools import lru_cache
from pathlib import Path
from typing import Any, Literal

import yaml
from pydantic import BaseModel, ConfigDict, Field, ValidationError, model_validator

from agritrace.core.errors import FieldRequiredError, FieldUnknownError

CONFIG_DIR = Path(__file__).resolve().parents[2] / "config"
VISIBILITY_RANK = {"internal": 0, "partner": 1, "public": 2}
GLOBAL_ENTITIES = {"village"}  # master data shared by every FPO: tenant overrides make no sense

FieldType = Literal[
    "text", "number", "integer", "boolean", "date", "datetime", "phone", "choice", "id",
    "address", "photo", "audio", "point", "polygon", "quantity",
]  # fmt: skip
Visibility = Literal["public", "partner", "internal"]
Stage = Literal[
    "onboarding", "cultivation", "harvest", "drying", "packing", "intake", "grading", "master_data"
]


class ConfigInvalid(RuntimeError):
    """A YAML file under `apps/api/config` is unreadable or fails its schema; the API must not start.

    A start-up failure, never an HTTP response: it has no `Error` suffix because `gen-error-codes.py` treats
    every `raise *Error` as an API error that must carry a registered code.
    """


class _Strict(BaseModel):
    """Base of the YAML schema models: unknown keys are errors, so typos fail at start-up."""

    model_config = ConfigDict(extra="forbid")


class Labels(_Strict):
    """Field label in each app language (FR5)."""

    en: str = Field(min_length=1, description="English label.")
    ta: str = Field(min_length=1, description="Tamil label.")


class FieldSpec(_Strict):
    """One configurable field of an entity, after tenant overrides (D-017)."""

    name: str = Field(pattern=r"^[a-z][a-z0-9_]*$", description="Payload key / CSV column, snake_case.")
    type: FieldType = Field(description="Value kind; clients pick the input widget from it.")
    required: bool = Field(description="True: a payload without a value is refused (`field_required`).")
    enabled: bool = Field(description="False: hidden from clients and dropped from payloads; never required.")
    visibility: Visibility = Field(
        description="Who may see the value: public (consumer page), partner (partner API) or internal."
    )
    label: Labels = Field(description="Labels shown in the apps, English and Tamil.")
    stage: Stage = Field(description="Capture stage the field belongs to.")
    core: bool = Field(
        False, description="True: the database needs it, so tenants may not disable it or make it optional."
    )


class EntityConfig(_Strict):
    """One `fields/<entity>.yaml` file."""

    entity: str = Field(pattern=r"^[a-z][a-z0-9_]*$", description="Entity name; equals the file name.")
    extra: Literal["forbid", "allow"] = Field(
        "allow", description="forbid: payload keys not listed are refused (`field_unknown`); allow: kept."
    )
    fields: list[FieldSpec] = Field(min_length=1, description="The entity's fields in capture order.")

    @model_validator(mode="after")
    def _unique_names(self) -> "EntityConfig":
        """Refuse a field listed twice.

        Returns:
            The model unchanged.

        Raises:
            ValueError: a field name repeats.
        """
        names = [f.name for f in self.fields]
        if len(names) != len(set(names)):
            raise ValueError(f"field names repeat in {self.entity}: {sorted(names)}")
        return self


class Features(_Strict):
    """Feature flags and limits (`features.yaml`, tenant overrides applied). Readers named in the YAML."""

    id_document_capture: bool = Field(description="ID document upload endpoint on (consent-gated).")
    farmer_pin_login: bool = Field(description="Farmers may sign in with a PIN (not wired on the server).")
    producer_groups: bool = Field(description="Producer group (SHG) endpoints on.")
    boundary_walk: bool = Field(description="Onboarding offers the boundary walk step.")
    second_signoff_threshold_kg: int = Field(ge=0, description="Batches above this weight need 2 sign-offs.")
    wifi_only_photos_default: bool = Field(description="Phones upload photos on Wi-Fi only by default.")
    sync_push_max_entries: int = Field(ge=1, description="Most entries in one sync push.")
    sync_push_max_bytes: int = Field(ge=1, description="Largest sync push body, in bytes.")
    otp_daily_cap: int = Field(ge=1, description="Most OTP codes per phone per 24 hours (informative).")


class FieldOverride(_Strict):
    """A tenant's change to one field; only the keys given change."""

    required: bool | None = Field(None, description="New requiredness.")
    enabled: bool | None = Field(None, description="New enabled state.")
    visibility: Visibility | None = Field(None, description="New visibility.")
    label: Labels | None = Field(None, description="New labels.")


class TenantConfig(_Strict):
    """One `tenants/<FPO_CODE>.yaml` file."""

    fpo_code: str = Field(pattern=r"^[A-Z0-9_]+$", description="FPO code; equals the file name.")
    features: dict[str, Any] = Field(default_factory=dict, description="Feature keys to override.")
    fields: dict[str, dict[str, FieldOverride]] = Field(
        default_factory=dict, description="Overrides by entity, then field name."
    )


class Config(BaseModel):
    """The whole validated configuration."""

    entities: dict[str, EntityConfig] = Field(description="Field configuration by entity name.")
    features: Features = Field(description="Default feature flags.")
    tenants: dict[str, TenantConfig] = Field(description="Overrides by FPO code.")


def _read(path: Path) -> Any:
    """Parse one YAML file.

    Args:
        path: the file.

    Returns:
        The parsed document.

    Raises:
        ConfigInvalid: unreadable or not valid YAML.
    """
    try:
        return yaml.safe_load(path.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as e:
        raise ConfigInvalid(f"{path}: cannot read YAML: {e}") from e


def _check_tenant(
    tenant: TenantConfig, path: Path, entities: dict[str, EntityConfig], base: Features
) -> None:
    """Refuse a tenant file that would break the schema or the privacy rules.

    Refused: unknown or global entities, unknown fields or flags, a relaxed core field, widened visibility.

    Args:
        tenant: the parsed tenant file.
        path: its path, for the message.
        entities: the parsed field files.
        base: the default features.

    Raises:
        ConfigInvalid: any of the problems above; the message names the file and the key.
    """
    if tenant.fpo_code != path.stem:
        raise ConfigInvalid(f"{path}: fpo_code {tenant.fpo_code!r} must equal the file name")
    try:
        Features.model_validate(base.model_dump() | tenant.features)
    except ValidationError as e:
        raise ConfigInvalid(f"{path}: features: {e}") from e
    for entity, overrides in tenant.fields.items():
        if entity not in entities:
            raise ConfigInvalid(f"{path}: fields.{entity}: unknown entity; known: {sorted(entities)}")
        if entity in GLOBAL_ENTITIES:
            raise ConfigInvalid(f"{path}: fields.{entity}: shared by every FPO, no tenant overrides")
        specs = {f.name: f for f in entities[entity].fields}
        for name, override in overrides.items():
            if name not in specs:
                raise ConfigInvalid(f"{path}: fields.{entity}.{name}: unknown field")
            if specs[name].core and (override.enabled is False or override.required is False):
                raise ConfigInvalid(f"{path}: fields.{entity}.{name}: core field cannot be disabled")
            # DECISION D-017: a tenant may only narrow visibility (public > partner > internal).
            #   ADV: no tenant file can make a phone number or land record public (CLAUDE.md §6).
            #   COMPROMISE: widening a field for one FPO needs a reviewed change to the default YAML.
            if (
                override.visibility
                and VISIBILITY_RANK[override.visibility] > VISIBILITY_RANK[specs[name].visibility]
            ):
                raise ConfigInvalid(f"{path}: fields.{entity}.{name}: visibility may only be narrowed")


def parse(config_dir: Path) -> Config:
    """Read and validate every YAML file of a configuration folder.

    Args:
        config_dir: folder holding `features.yaml`, `fields/*.yaml` and `tenants/*.yaml`.

    Returns:
        The validated configuration.

    Raises:
        ConfigInvalid: a file is unreadable, fails its schema, or a tenant override is invalid; the
            message starts with the file path.
    """
    entities: dict[str, EntityConfig] = {}
    for path in sorted((config_dir / "fields").glob("*.yaml")):
        try:
            entity = EntityConfig.model_validate(_read(path))
        except ValidationError as e:
            raise ConfigInvalid(f"{path}: {e}") from e
        if entity.entity != path.stem:
            raise ConfigInvalid(f"{path}: entity {entity.entity!r} must equal the file name")
        entities[entity.entity] = entity
    features_path = config_dir / "features.yaml"
    try:
        features = Features.model_validate(_read(features_path))
    except ValidationError as e:
        raise ConfigInvalid(f"{features_path}: {e}") from e
    tenants: dict[str, TenantConfig] = {}
    for path in sorted((config_dir / "tenants").glob("*.yaml")):
        try:
            tenant = TenantConfig.model_validate(_read(path))
        except ValidationError as e:
            raise ConfigInvalid(f"{path}: {e}") from e
        _check_tenant(tenant, path, entities, features)
        tenants[tenant.fpo_code] = tenant
    return Config(entities=entities, features=features, tenants=tenants)


@lru_cache
def load() -> Config:
    """Load `CONFIG_DIR` once per process.

    Returns:
        The cached configuration. Tests change `CONFIG_DIR` and call `load.cache_clear()`.

    Raises:
        ConfigInvalid: see `parse`.
    """
    return parse(CONFIG_DIR)


def _all_fields(entity: str, fpo_code: str | None) -> list[FieldSpec]:
    """Every field of an entity, disabled ones included, with the tenant's overrides applied.

    Args:
        entity: entity name, e.g. `farmer`.
        fpo_code: the tenant's FPO code; None (or an FPO without a file) means the defaults.

    Returns:
        The fields in YAML order.

    Raises:
        KeyError: unknown entity.
    """
    config = load()
    tenant = config.tenants.get(fpo_code or "")
    overrides = tenant.fields.get(entity, {}) if tenant else {}
    return [
        FieldSpec.model_validate(f.model_dump() | overrides[f.name].model_dump(exclude_none=True))
        if f.name in overrides
        else f
        for f in config.entities[entity].fields
    ]


def fields_for(entity: str, fpo_code: str | None) -> list[FieldSpec]:
    """The fields a tenant captures for an entity: enabled only, overrides applied (`GET /v1/config/fields`).

    Args:
        entity: entity name.
        fpo_code: the tenant's FPO code, or None for the defaults.

    Returns:
        Enabled fields in YAML order; a disabled field is absent (hidden from clients).

    Raises:
        KeyError: unknown entity.
    """
    return [f for f in _all_fields(entity, fpo_code) if f.enabled]


def features_for(fpo_code: str | None) -> Features:
    """The feature flags in force for a tenant.

    Args:
        fpo_code: the tenant's FPO code, or None for the defaults.

    Returns:
        Defaults with the tenant's `features` overrides applied.
    """
    config = load()
    tenant = config.tenants.get(fpo_code or "")
    return Features.model_validate(config.features.model_dump() | (tenant.features if tenant else {}))


def public_fields(entity: str, fpo_code: str | None) -> list[str]:
    """Names of the fields the public page may show for a tenant (CLAUDE.md §6; B10 honours it, D-017).

    Safe to apply tenant overrides: the loader refuses any override that widens visibility, so a tenant can
    only hide fields (disable them or narrow them to partner/internal), never expose more.

    Args:
        entity: entity name.
        fpo_code: the tenant's FPO code, or None for the defaults.

    Returns:
        Enabled field names whose visibility for this tenant is `public`.

    Raises:
        KeyError: unknown entity.
    """
    return [f.name for f in fields_for(entity, fpo_code) if f.visibility == "public"]


def _blank(value: Any) -> bool:
    """Tell whether a payload value counts as not sent.

    Args:
        value: the value.

    Returns:
        True for None and blank strings.
    """
    return value is None or (isinstance(value, str) and not value.strip())


def validate_payload(entity: str, fpo_code: str | None, data: dict[str, Any]) -> dict[str, Any]:
    """Apply a tenant's field rules to a payload: drop disabled fields, enforce required ones.

    Args:
        entity: entity name.
        fpo_code: the tenant's FPO code, or None for the defaults.
        data: the payload (API body dump or CSV row), keys are field names.

    Returns:
        A copy of `data` without disabled fields. Keys not in the YAML are kept when the entity says
        `extra: allow`.

    Raises:
        FieldUnknownError: a key is not in the YAML and the entity says `extra: forbid` (`field_unknown`).
        FieldRequiredError: an enabled required field is missing or blank (`field_required`).
        KeyError: unknown entity.
    """
    specs = {f.name: f for f in _all_fields(entity, fpo_code)}
    if load().entities[entity].extra == "forbid":
        unknown = sorted(set(data) - set(specs))
        if unknown:
            raise FieldUnknownError(details={"field": unknown[0], "entity": entity})
    for spec in specs.values():
        if spec.enabled and spec.required and _blank(data.get(spec.name)):
            raise FieldRequiredError(details={"field": spec.name, "entity": entity})
    return {k: v for k, v in data.items() if k not in specs or specs[k].enabled}


def bundle_part(fpo_code: str | None) -> dict[str, Any]:
    """The sync bundle part `fields` for a tenant (B07 serves it; the phone renders forms from it).

    Args:
        fpo_code: the tenant's FPO code, or None for the defaults.

    Returns:
        `{"version": <sha256 prefix>, "entities": {entity: [field, ...]}, "features": {...}}`.
    """
    body = {
        "entities": {e: [f.model_dump() for f in fields_for(e, fpo_code)] for e in load().entities},
        "features": features_for(fpo_code).model_dump(),
    }
    return {"version": etag(body)} | body


def etag(body: Any) -> str:
    """A strong ETag for a JSON-serialisable configuration view.

    Args:
        body: the view (dicts, lists, scalars).

    Returns:
        The first 16 hex characters of the SHA-256 of its canonical JSON, quoted per RFC 9110.
    """
    digest = hashlib.sha256(json.dumps(body, sort_keys=True, ensure_ascii=False).encode()).hexdigest()
    return f'"{digest[:16]}"'
