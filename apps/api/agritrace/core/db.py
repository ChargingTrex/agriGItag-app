"""Async SQLAlchemy engine and sessions, the declarative `Base` and the two table mixins of every model.

Serves: Arch §Backend services (Postgres 16 + PostGIS), D-001 (SQLAlchemy 2 async), D-005 (client ids as
primary keys), D-009, D-012 (schema-first), backend-design.md §0 (id, created_at, updated_at, fpo_id).
Callers: every module's `models.py` (Base, IdTimestamps, TenantScoped) and routers (`get_session`),
`core.audit`, `alembic/env.py`, `agritrace.main` (health check), `agritrace.worker` (cache reset after fork).
"""

import enum
import uuid
from collections.abc import AsyncIterator
from datetime import datetime
from decimal import Decimal
from functools import lru_cache
from typing import Any

from geoalchemy2 import WKBElement, WKTElement
from sqlalchemy import DateTime, Enum, ForeignKey, MetaData, Numeric, Text, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from agritrace.core.config import get_settings
from agritrace.core.ids import uuid7

# Value of a geography column: WKB when read back, WKT (e.g. "SRID=4326;POINT(77.96 9.58)") when written.
SpatialValue = WKBElement | WKTElement


def _enum_values(cls: type[enum.Enum]) -> list[str]:
    """List the stored values of an enum (its `.value`s, not its member names).

    Args:
        cls: a `StrEnum` from `core.enums`.

    Returns:
        The member values in declaration order.
    """
    return [str(member.value) for member in cls]


class Base(DeclarativeBase):
    """Declarative base for every table (models live in `modules/*/models.py`, D-012)."""

    # Deterministic constraint names keep Alembic autogenerate diffs stable across machines.
    metadata = MetaData(
        naming_convention={
            "ix": "ix_%(column_0_label)s",
            "uq": "uq_%(table_name)s_%(column_0_name)s",
            "ck": "ck_%(table_name)s_%(constraint_name)s",
            "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
            "pk": "pk_%(table_name)s",
        }
    )
    # Plain annotations (`Mapped[str]`, `Mapped[Decimal]`, `Mapped[Role]`) resolve to these column types.
    type_annotation_map = {
        str: Text(),
        # FR58: quantities are NUMERIC(12,3) paired with a unit (column-name suffix or a sibling column).
        Decimal: Numeric(12, 3),
        datetime: DateTime(timezone=True),
        dict[str, Any]: JSONB(),
        # DECISION D-014: enums are VARCHAR(32) + CHECK constraint, not Postgres ENUM types.
        #   ADV: event types and statuses grow additively (D-014, D-020); a new value is a plain
        #     DROP/ADD CONSTRAINT inside the migration transaction, with no `ALTER TYPE ... ADD VALUE`
        #     (unusable in the transaction that adds it) and no type objects to drop on downgrade.
        #   COMPROMISE: `alembic check` does not compare CHECK constraints, so a value added to a StrEnum
        #     without a migration is not caught as drift; the DB still rejects the value at insert, and
        #     tests/unit/test_models.py pins each column's allowed values to its StrEnum.
        enum.Enum: Enum(
            enum.Enum, native_enum=False, create_constraint=True, length=32, values_callable=_enum_values
        ),
    }


class IdTimestamps:
    """Mixin: UUIDv7 primary key plus `created_at` / `updated_at` (backend-design.md §0)."""

    # DECISION D-005: rows captured offline (plots, events, event versions, photos, readings, intakes,
    #   consents, assist sessions, devices) use the phone's UUID as primary key and idempotency key;
    #   every other row gets a UUIDv7 from the API (`core.ids.uuid7`) when the client sends none.
    #   ADV: retries are no-ops (INSERT ... ON CONFLICT (id) DO NOTHING); v7 keeps B-tree inserts ordered.
    #   COMPROMISE: a client can pick an id another user already owns, so services must reject that
    #     (`client_id_conflict`); rows inserted by raw SQL must supply an id (no DB-side default).
    id: Mapped[uuid.UUID] = mapped_column(
        primary_key=True,
        default=uuid7,
        sort_order=-10,
        comment="Primary key, UUIDv7; from the phone for offline-captured rows (D-005), else the API.",
    )
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), sort_order=10, comment="When the row was inserted (database clock, UTC)."
    )
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(),
        onupdate=func.now(),
        sort_order=10,
        comment="When the row was last changed (database clock, UTC).",
    )


class TenantScoped:
    """Mixin: the owning FPO (`fpo_id`) on every tenant-scoped table (FR24, CLAUDE.md §6)."""

    fpo_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("fpos.id"),
        index=True,
        sort_order=-9,
        comment="Owning FPO (tenant); every query is scoped to the caller's FPO (FR24).",
    )


@lru_cache
def get_engine() -> AsyncEngine:
    """Create the process-wide async engine on first use.

    Returns:
        The cached engine for `DATABASE_URL`. No connection is opened until first query.

    Raises:
        sqlalchemy.exc.ArgumentError: `DATABASE_URL` is not a valid SQLAlchemy URL.
    """
    return create_async_engine(get_settings().database_url, pool_pre_ping=True)


@lru_cache
def get_sessionmaker() -> async_sessionmaker[AsyncSession]:
    """Create the session factory bound to `get_engine()`.

    Returns:
        A cached factory producing `AsyncSession` objects that keep attributes loaded after commit.
    """
    return async_sessionmaker(get_engine(), expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    """FastAPI dependency yielding one session per request.

    Returns:
        An async iterator yielding a single `AsyncSession`; the caller commits explicitly.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: passed through from the database driver.

    Side effects:
        Closes the session (rolling back anything uncommitted) when the request ends.
    """
    async with get_sessionmaker()() as session:
        yield session
