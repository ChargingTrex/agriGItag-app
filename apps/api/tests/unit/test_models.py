"""Unit tests of the declared schema, without a database.

Covers completeness against the spec, documentation, enums, mixins, spatial columns, key constraints,
and agreement between the models and migration 0001.

Serves: D-012 (schema-first), CLAUDE.md §5 (every model documented, every column commented), D-005, D-023,
backend-design.md §2. Callers: pytest (`make test-unit`); no database needed.
"""

import importlib
import importlib.util
import pathlib
import pkgutil
import re
from enum import StrEnum
from types import ModuleType

import pytest
from geoalchemy2 import Geography
from sqlalchemy import CheckConstraint, Enum, Table, UniqueConstraint
from sqlalchemy.dialects import postgresql

import agritrace.modules
from agritrace.core.db import Base
from agritrace.core.ids import uuid7

for _m in pkgutil.iter_modules(agritrace.modules.__path__):
    if importlib.util.find_spec(f"agritrace.modules.{_m.name}.models"):
        importlib.import_module(f"agritrace.modules.{_m.name}.models")

TABLES = Base.metadata.tables
MAPPERS = list(Base.registry.mappers)

# backend-design.md §2, table by table.
SPEC_TABLES = {
    # identity
    "users", "memberships", "otp_challenges", "devices", "assist_sessions", "consent_records", "audit_log",
    # registry
    "fpos", "processors", "villages", "farmers", "plots", "plot_revisions", "crops", "gi_tags",
    "gi_region_versions", "inputs_master", "id_documents", "producer_groups",
    # events
    "events", "event_versions", "evidence_photos", "sync_cursors", "reference_versions", "sync_metrics",
    # lots_batches
    "lots", "lot_intakes", "batches", "batch_shares", "batch_approvals",
    # quality
    "standards_profiles", "standards_profile_versions", "instruments", "quality_readings",
    "grade_computations",
    # rules_flags, publishing, reporting, notifications
    "flags", "page_builds", "scan_events", "notifications",
}  # fmt: skip
REQUIREMENT = re.compile(r"FR\d+|Stage \d+|D-\d{3}|PRD §|UserFlows|Dataflow|backend-design")


def _migration() -> ModuleType:
    """Load alembic/versions/0001_initial.py as a module without running it.

    Returns:
        The migration module (its constants describe the triggers it creates).
    """
    path = pathlib.Path(__file__).parents[2] / "alembic" / "versions" / "0001_initial.py"
    spec = importlib.util.spec_from_file_location("migration_0001", path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_every_spec_table_is_modelled_and_nothing_else() -> None:
    """The metadata holds exactly the 39 tables of backend-design.md §2 (no speculative tables)."""
    assert set(TABLES) == SPEC_TABLES


def test_every_model_has_a_docstring_naming_a_requirement() -> None:
    """Each model class documents itself and cites an FR, stage, ADR or spec section."""
    for mapper in MAPPERS:
        doc = mapper.class_.__dict__.get("__doc__") or ""
        assert REQUIREMENT.search(doc), f"{mapper.class_.__name__} docstring cites no requirement"


def test_every_column_has_a_comment() -> None:
    """Every column carries `comment=` (CLAUDE.md §5); the database stores it as COMMENT ON COLUMN."""
    missing = [f"{t.name}.{c.name}" for t in TABLES.values() for c in t.columns if not c.comment]
    assert missing == []


def test_constraint_and_index_names_are_unique() -> None:
    """Naming conventions give every constraint and index a distinct name (Alembic diffs depend on it)."""
    names = [str(c.name) for t in TABLES.values() for c in t.constraints]
    names += [str(i.name) for t in TABLES.values() for i in t.indexes]
    assert len(names) == len(set(names))


def _enum_columns() -> list[tuple[str, Enum]]:
    """List every enum-typed column.

    Returns:
        (`table.column`, its `Enum` type) pairs.
    """
    return [
        (f"{t.name}.{c.name}", c.type) for t in TABLES.values() for c in t.columns if isinstance(c.type, Enum)
    ]


@pytest.mark.parametrize(("where", "type_"), _enum_columns())
def test_enum_columns_store_values_and_round_trip(where: str, type_: Enum) -> None:
    """Enum columns are VARCHAR + CHECK of the StrEnum values and convert both ways (D-023).

    Args:
        where: `table.column`, for the failure message.
        type_: the column's SQLAlchemy Enum type.
    """
    enum_class = type_.enum_class
    assert enum_class is not None and issubclass(enum_class, StrEnum), where
    assert type_.enums == [m.value for m in enum_class], where
    assert not type_.native_enum and type_.create_constraint, where
    dialect = postgresql.asyncpg.dialect()  # type: ignore[attr-defined]
    to_db, from_db = type_.bind_processor(dialect), type_.result_processor(dialect, None)
    for member in enum_class:
        stored = to_db(member) if to_db else member
        assert stored == member.value
        assert (from_db(stored) if from_db else stored) is member


def test_id_mixin_defaults_to_uuid7_and_tenant_mixin_points_at_fpos() -> None:
    """`IdTimestamps.id` defaults to a UUIDv7; `TenantScoped.fpo_id` is a NOT NULL, indexed FK to fpos."""
    id_default = TABLES["lots"].c.id.default
    assert id_default is not None and id_default.arg.__name__ == uuid7.__name__  # type: ignore[attr-defined]
    assert id_default.arg(None).version == 7  # type: ignore[attr-defined]
    for name in ("farmers", "plots", "events", "lots", "lot_intakes", "batches", "quality_readings", "flags"):
        fpo = TABLES[name].c.fpo_id
        assert not fpo.nullable and fpo.index, name
        assert {fk.target_fullname for fk in fpo.foreign_keys} == {"fpos.id"}, name
    for name in ("users", "fpos", "event_versions", "audit_log"):
        assert TABLES[name].c.created_at.server_default is not None
        assert TABLES[name].c.updated_at.onupdate is not None


def test_geography_columns_are_wgs84_and_gist_indexed_where_queried() -> None:
    """Every geography column is SRID 4326; exactly the four spatially queried ones have GiST indexes."""
    geo = {
        f"{t.name}.{c.name}": c for t in TABLES.values() for c in t.columns if isinstance(c.type, Geography)
    }
    assert all(c.type.srid == 4326 for c in geo.values())
    assert geo["plots.pin"].type.geometry_type == "POINT"
    assert geo["plots.walked_boundary"].type.geometry_type == "POLYGON"
    assert geo["gi_region_versions.geom"].type.geometry_type == "MULTIPOLYGON"
    gist = {
        f"{t.name}.{i.columns.keys()[0]}"
        for t in TABLES.values()
        for i in t.indexes
        if i.dialect_options["postgresql"]["using"] == "gist"
    }
    assert gist == {"plots.pin", "plots.walked_boundary", "gi_region_versions.geom", "event_versions.gps"}
    payload_index = next(i for i in TABLES["event_versions"].indexes if i.name == "ix_event_versions_payload")
    assert payload_index.dialect_options["postgresql"]["using"] == "gin"


def _uniques(table: Table) -> set[tuple[str, ...]]:
    """Collect the column tuples of a table's unique constraints.

    Args:
        table: the table.

    Returns:
        One tuple of column names per UNIQUE constraint.
    """
    return {tuple(c.columns.keys()) for c in table.constraints if isinstance(c, UniqueConstraint)}


def test_spec_keys_and_checks() -> None:
    """The keys and checks backend-design.md §2 names are declared."""
    assert ("event_id", "version_no") in _uniques(TABLES["event_versions"])
    assert ("gi_tag_id", "version_no") in _uniques(TABLES["gi_region_versions"])
    assert ("profile_id", "version_no") in _uniques(TABLES["standards_profile_versions"])
    assert ("user_id", "fpo_id") in _uniques(TABLES["memberships"])
    assert ("dedupe_key",) in _uniques(TABLES["flags"])
    assert TABLES["batch_shares"].primary_key.columns.keys() == ["batch_id", "lot_id"]
    assert TABLES["sync_cursors"].primary_key.columns.keys() == ["device_id"]
    checks = {str(c.sqltext) for c in TABLES["events"].constraints if isinstance(c, CheckConstraint)}
    assert "(lot_id IS NULL) <> (batch_id IS NULL)" in checks
    for table, column in (
        ("lots", "code"),
        ("batches", "code"),
        ("batches", "superlot_code"),
        ("users", "phone"),
    ):
        assert (column,) in _uniques(TABLES[table]), f"{table}.{column}"


def test_migration_triggers_name_real_tables_and_columns() -> None:
    """Migration 0001's trigger lists and drop order match the models (no typo silently skips a table)."""
    migration = _migration()
    assert set(migration.DROP_ORDER) == SPEC_TABLES
    assert set(migration.APPEND_ONLY) == {"event_versions", "evidence_photos", "audit_log", "consent_records"}
    for table, allowed in migration.APPEND_ONLY.items():
        assert set(allowed) <= set(TABLES[table].columns.keys()), table
    assert set(migration.REFERENCE_PARTS) <= SPEC_TABLES
    for name, table in migration.LATE_FOREIGN_KEYS:
        assert name in {str(fk.name) for fk in TABLES[table].foreign_key_constraints}
