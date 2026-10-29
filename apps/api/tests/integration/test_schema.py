"""Integration tests of migration 0001 on a real PostGIS database.

Covers: no drift, enum CHECKs equal to the StrEnums, append-only triggers, SRID, reference version bumps
and audit rows.

Serves: B01 acceptance (`alembic upgrade head && alembic check` no drift; `UPDATE event_versions ...`
raises `append_only_violation`; plots SRID 4326), D-005, D-012, D-023, FR25, FR61, backend-design.md §3.
Callers: pytest (`make test`); needs Docker (PostGIS container from tests/conftest.py `stack`).
"""

import importlib
import re
import secrets
import subprocess
import sys
import uuid
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

import pytest
from geoalchemy2 import WKTElement
from sqlalchemy import Enum, text
from sqlalchemy.exc import DBAPIError

from agritrace.core.audit import AuditContext, reset_audit_context, set_audit_context
from agritrace.core.db import Base, get_engine, get_sessionmaker
from agritrace.core.enums import ChangeKind, EventSubject, EventType, OrgKind, PinMethod
from agritrace.core.ids import lot_code, uuid7
from agritrace.core.schemas import GeoPoint
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.identity.models import User
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.registry.models import Crop, Farmer, Fpo, Plot

# The enum drift guard walks every table, so load the models of the modules not imported above too.
for _name in ("notifications", "publishing", "quality", "reporting", "rules_flags"):
    importlib.import_module(f"agritrace.modules.{_name}.models")

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
ALEMBIC = Path(sys.executable).parent / "alembic"
NOW = datetime(2026, 3, 4, 8, 12, tzinfo=UTC)


def _alembic(*args: str) -> str:
    """Run the alembic CLI against the test database (DATABASE_URL is set by the `stack` fixture).

    Args:
        *args: alembic arguments, e.g. `upgrade`, `head`.

    Returns:
        Combined stdout and stderr.

    Raises:
        AssertionError: alembic exited non-zero (the output is in the message).
    """
    result = subprocess.run([str(ALEMBIC), *args], cwd=API_DIR, capture_output=True, text=True, check=False)  # noqa: S603
    output = result.stdout + result.stderr
    assert result.returncode == 0, output
    return output


@pytest.fixture(scope="session")
def schema(stack: None) -> None:
    """Migrate the test database to head once per session.

    Args:
        stack: the running containers (fixture).

    Side effects:
        Creates every table, function and trigger of migration 0001.
    """
    _alembic("upgrade", "head")


def _plot(fpo_id: uuid.UUID, farmer_id: uuid.UUID) -> Plot:
    """Build a live-GPS plot in Virudhunagar.

    Args:
        fpo_id: owning FPO.
        farmer_id: owning farmer.

    Returns:
        A transient `Plot` with a client-style UUIDv7 id.
    """
    return Plot(
        id=uuid7(),
        fpo_id=fpo_id,
        farmer_id=farmer_id,
        code="P-01",
        pin=WKTElement("POINT(77.96 9.58)", srid=4326),
        pin_method=PinMethod.LIVE_GPS,
        pin_device_time=NOW,
        pin_server_received_at=NOW,
        declared_area_acres=Decimal("1.5"),
    )


async def _seed() -> dict[str, uuid.UUID]:
    """Insert one FPO with a user, farmer, crop, plot, lot, harvest event and its first version.

    Returns:
        Ids by name: user, fpo, farmer, plot, lot, event, version.

    Side effects:
        Commits the rows (and their audit rows) to the test database.
    """
    async with get_sessionmaker()() as s:
        user = User(phone=f"+9198{secrets.randbelow(10**8):08d}", name="Officer")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        crop = Crop(code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={})
        s.add_all([user, fpo, crop])
        await s.flush()
        farmer = Farmer(fpo_id=fpo.id, code="F-001", name="Muthu")
        s.add(farmer)
        await s.flush()
        plot = _plot(fpo.id, farmer.id)
        s.add(plot)
        await s.flush()
        lot = Lot(
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            plot_id=plot.id,
            crop_id=crop.id,
            season_label="2025-26",
            code=lot_code(),
        )
        s.add(lot)
        await s.flush()
        event = Event(
            id=uuid7(),
            fpo_id=fpo.id,
            subject_type=EventSubject.LOT,
            lot_id=lot.id,
            plot_id=plot.id,
            event_type=EventType.HARVEST,
            occurred_on=date(2026, 3, 4),
        )
        s.add(event)
        await s.flush()
        version = EventVersion(
            id=uuid7(),
            event_id=event.id,
            version_no=1,
            payload={"quantity": {"value": 195, "unit": "kg"}, "bags": 13},
            occurred_on=date(2026, 3, 4),
            device_time=NOW,
            server_received_at=NOW,
            entered_by_user_id=user.id,
            change_kind=ChangeKind.CREATE,
        )
        s.add(version)
        await s.commit()
        names = ("user", "fpo", "farmer", "plot", "lot", "event", "version")
        return dict(
            zip(names, (user.id, fpo.id, farmer.id, plot.id, lot.id, event.id, version.id), strict=True)
        )


def test_upgrade_head_then_check_reports_no_drift(schema: None) -> None:
    """`alembic check` finds nothing to generate; downgrade and re-upgrade both work.

    Args:
        schema: the migrated database (fixture).
    """
    assert "No new upgrade operations detected" in _alembic("check")
    _alembic("downgrade", "base")
    _alembic("upgrade", "head")
    assert "No new upgrade operations detected" in _alembic("check")


async def test_live_enum_checks_match_the_strenums(schema: None) -> None:
    """Every enum column's CHECK in the database allows exactly its StrEnum's values (D-023 drift guard).

    `alembic check` ignores CHECK constraints, so a value added to a StrEnum without a migration is caught
    here instead of at the first production insert.

    Args:
        schema: the migrated database (fixture).
    """
    expected = {
        f"ck_{table.name}_{column.type.name}": (column.name, {m.value for m in column.type.enum_class})
        for table in Base.metadata.tables.values()
        for column in table.columns
        if isinstance(column.type, Enum) and column.type.enum_class is not None
    }
    query = text("SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE contype = 'c'")
    async with get_engine().connect() as conn:
        live = dict((await conn.execute(query)).tuples().all())
    assert len(expected) == 32
    for name, (column, values) in expected.items():
        assert name in live, f"{name} missing in the database"
        assert f"({column})::text" in live[name], f"{name} does not check {column}: {live[name]}"
        assert set(re.findall(r"'([^']*)'::", live[name])) == values, f"{name}: {live[name]}"


@pytest.mark.parametrize(
    "statement", ["UPDATE event_versions SET payload = '{}'", "DELETE FROM event_versions"]
)
async def test_event_versions_are_append_only(schema: None, statement: str) -> None:
    """UPDATE and DELETE on an event version raise `append_only_violation` (D-005).

    Args:
        schema: the migrated database (fixture).
        statement: the forbidden statement, restricted to the seeded version.
    """
    ids = await _seed()
    async with get_engine().connect() as conn:
        with pytest.raises(DBAPIError, match="append_only_violation"):
            await conn.execute(text(f"{statement} WHERE id = :id"), {"id": ids["version"]})


async def test_plot_pin_is_stored_in_srid_4326(schema: None) -> None:
    """A plot pin reads back as SRID 4326 (WGS84).

    Args:
        schema: the migrated database (fixture).
    """
    ids = await _seed()
    async with get_engine().connect() as conn:
        srid = await conn.scalar(
            text("SELECT ST_SRID(pin::geometry) FROM plots WHERE id = :id"), {"id": ids["plot"]}
        )
    assert srid == 4326


async def test_plot_insert_bumps_the_fpo_plots_reference_version(schema: None) -> None:
    """Each plot insert moves the FPO's `plots` bundle version forward.

    Args:
        schema: the migrated database (fixture).
    """
    ids = await _seed()
    query = text("SELECT version FROM reference_versions WHERE part = 'plots' AND fpo_id = :fpo")
    async with get_engine().connect() as conn:
        first = await conn.scalar(query, {"fpo": ids["fpo"]})
    assert first is not None
    async with get_sessionmaker()() as s:
        s.add(_plot(ids["fpo"], ids["farmer"]))
        await s.commit()
    async with get_engine().connect() as conn:
        assert await conn.scalar(query, {"fpo": ids["fpo"]}) > first


async def test_evidence_photo_allows_verification_updates_only(schema: None) -> None:
    """The verify task may set status and checksums; the object key can never change (FR61).

    Args:
        schema: the migrated database (fixture).
    """
    ids = await _seed()
    photo_id = uuid7()
    async with get_sessionmaker()() as s:
        s.add(
            EvidencePhoto(
                id=photo_id,
                event_version_id=ids["version"],
                bucket="evidence",
                object_key=f"evidence/{ids['fpo']}/2026/{ids['event']}/{photo_id}.jpg",
                content_type="image/jpeg",
                size_bytes=287311,
                sha256_client="ab" * 32,
            )
        )
        await s.commit()
    async with get_engine().begin() as conn:
        await conn.execute(
            text("UPDATE evidence_photos SET status = 'verified', sha256_server = :h WHERE id = :id"),
            {"h": "ab" * 32, "id": photo_id},
        )
    async with get_engine().connect() as conn:
        with pytest.raises(DBAPIError, match="append_only_violation"):
            await conn.execute(
                text("UPDATE evidence_photos SET object_key = 'x' WHERE id = :id"), {"id": photo_id}
            )


async def test_audited_insert_writes_an_audit_row_with_context(schema: None) -> None:
    """Creating a farmer under an assist context writes a `create` audit row that cannot be changed.

    Args:
        schema: the migrated database (fixture).
    """
    ids = await _seed()
    officer, session_id = uuid.uuid4(), uuid.uuid4()
    token = set_audit_context(
        AuditContext(actor_user_id=officer, assist_session_id=session_id, gps=GeoPoint(lat=9.58, lon=77.96))
    )
    try:
        async with get_sessionmaker()() as s:
            farmer = Farmer(fpo_id=ids["fpo"], code="F-002", name="Lakshmi")
            s.add(farmer)
            await s.commit()
    finally:
        reset_audit_context(token)
    query = text(
        "SELECT action, actor_user_id, assist_session_id, ST_SRID(gps::geometry), diff ->> 'name' "
        "FROM audit_log WHERE entity_type = 'farmers' AND entity_id = :id"
    )
    async with get_engine().connect() as conn:
        rows = (await conn.execute(query, {"id": farmer.id})).all()
        assert [tuple(r) for r in rows] == [("create", officer, session_id, 4326, "Lakshmi")]
        with pytest.raises(DBAPIError, match="append_only_violation"):
            await conn.execute(text("DELETE FROM audit_log WHERE entity_id = :id"), {"id": farmer.id})
