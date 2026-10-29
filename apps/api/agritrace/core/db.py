"""Async SQLAlchemy engine, session factory, request-scoped session dependency and declarative `Base`.

Serves: Arch §Backend services (Postgres 16 + PostGIS), D-001 (SQLAlchemy 2 async), D-009.
Callers: every module's `models.py` (Base) and routers (`get_session`), `alembic/env.py`, `agritrace.main`
(health check), `agritrace.worker` (cache reset after fork).
"""

from collections.abc import AsyncIterator
from functools import lru_cache

from sqlalchemy import MetaData
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from agritrace.core.config import get_settings


class Base(DeclarativeBase):
    """Declarative base for every table; B01 adds the models."""

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
