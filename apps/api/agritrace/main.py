"""FastAPI application factory: OpenAPI metadata, compression, error envelope, `/v1` routes, health check.

Serves: Arch §Backend services, D-001 (OpenAPI 3.1 from Pydantic), D-020 (`/v1` prefix),
plan §13 C1 (brotli/gzip responses), B00 acceptance (`GET /v1/healthz` reports db, redis, s3).
Callers: uvicorn (`agritrace.main:app`, see infra/docker-compose.yml), `agritrace.export_openapi`, tests.
"""

import asyncio
import importlib
import importlib.metadata
import importlib.util
import pkgutil
from collections.abc import Awaitable, Callable

from brotli_asgi import BrotliMiddleware
from fastapi import APIRouter, FastAPI, Response
from pydantic import BaseModel, Field
from redis.asyncio import Redis
from sqlalchemy import text

import agritrace.modules
from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.db import get_engine
from agritrace.core.errors import install_handlers
from agritrace.core.schemas import ErrorEnvelope

DESCRIPTION = """Farm-to-consumer traceability for GI-tagged produce (pilot: Virudhunagar Samba Vathal
dry chilli, GI 883). Every error uses the envelope `{"error": {"code", "message", "details"}}`; codes are
listed in docs/api/error-codes.md. Conventions (pagination, units, clocks, idempotency) are in
docs/api/conventions.md."""

TAGS = [
    {"name": "health", "description": "Liveness of the API and its dependencies."},
    {"name": "identity", "description": "OTP sign-in, tokens, roles, devices, assist sessions, consent."},
    {"name": "registry", "description": "FPOs, farmers, plots, crops, GI tags and regions, inputs."},
    {"name": "events", "description": "Append-only farm events, sync push and pull, evidence photos."},
    {"name": "rules_flags", "description": "Rule checks and the flags they raise."},
    {"name": "lots_batches", "description": "Lots, intakes, super-lots, batches and lifecycle gates."},
    {"name": "quality", "description": "Standards profiles, instruments, readings and grades."},
    {"name": "storage_monitoring", "description": "Storage monitoring (pilot stub, 501)."},
    {"name": "publishing", "description": "Public batch pages and scans."},
    {"name": "notifications", "description": "Notifications to farmers and FPO staff."},
    {"name": "partner_api", "description": "Partner API (pilot stub, 501)."},
    {"name": "reporting", "description": "Dashboards and exports."},
]


class Health(BaseModel):
    """Status of each dependency: `ok` or `error: <reason>`."""

    db: str = Field(description="Postgres: `ok` after `SELECT 1`, else `error: <reason>`.")
    redis: str = Field(description="Redis: `ok` after `PING`, else `error: <reason>`.")
    s3: str = Field(description="S3: `ok` after HEAD on the evidence bucket, else `error: <reason>`.")


async def _check(probe: Callable[[], Awaitable[object]]) -> str:
    """Run one dependency probe with a 3 s timeout.

    Args:
        probe: coroutine function that raises when the dependency is unhealthy.

    Returns:
        `ok`, or `error: <reason>` when the probe raised or timed out.
    """
    try:
        await asyncio.wait_for(probe(), timeout=3)
    except Exception as e:  # noqa: BLE001 - a health check reports failures instead of raising them
        return f"error: {str(e) or type(e).__name__}"
    return "ok"


async def _ping_db() -> None:
    """Run `SELECT 1` on a pooled connection.

    Raises:
        sqlalchemy.exc.SQLAlchemyError | OSError: the database is unreachable or refused the query.
    """
    async with get_engine().connect() as conn:
        await conn.execute(text("SELECT 1"))


async def _ping_redis() -> None:
    """Send `PING` on a short-lived connection.

    Raises:
        redis.exceptions.RedisError: Redis is unreachable or refused.
    """
    r = Redis.from_url(get_settings().redis_url)
    try:
        await r.ping()
    finally:
        await r.aclose()


async def _ping_s3() -> None:
    """HEAD the evidence bucket in a worker thread (boto3 is blocking).

    Raises:
        botocore.exceptions.BotoCoreError | botocore.exceptions.ClientError: S3 unreachable or bucket missing.
    """
    await asyncio.to_thread(storage.client().head_bucket, Bucket=get_settings().s3_bucket_evidence)


async def healthz(response: Response) -> Health:
    """Check Postgres, Redis and object storage independently and concurrently.

    Args:
        response: the outgoing response, whose status is set to 503 when any check fails.

    Returns:
        One status string per dependency.

    Side effects:
        Opens one DB connection, one Redis connection and one S3 request.
    """
    db, redis, s3 = await asyncio.gather(_check(_ping_db), _check(_ping_redis), _check(_ping_s3))
    if any(status != "ok" for status in (db, redis, s3)):
        response.status_code = 503
    return Health(db=db, redis=redis, s3=s3)


def create_app() -> FastAPI:
    """Build the FastAPI application.

    Returns:
        The app with compression, error handlers, the health route and every module router under `/v1`.

    Raises:
        ImportError: a module's `router.py` fails to import.
    """
    app = FastAPI(
        title="AgriTrace API",
        version=importlib.metadata.version("agritrace"),
        description=DESCRIPTION,
        openapi_tags=TAGS,
    )
    app.add_middleware(BrotliMiddleware, gzip_fallback=True)
    install_handlers(app)

    # DECISION D-020: every public route lives under /v1; changes are additive only.
    #   ADV: apps from last season keep working; oasdiff can diff one prefix.
    #   COMPROMISE: deprecated fields linger for a season.
    v1 = APIRouter(prefix="/v1", responses={"default": {"model": ErrorEnvelope, "description": "Error"}})
    v1.add_api_route(
        "/healthz",
        healthz,
        methods=["GET"],
        tags=["health"],
        response_model=Health,
        responses={503: {"model": Health, "description": "At least one dependency is failing."}},
    )
    # DECISION D-004: each module exposes `router` in `modules/<name>/router.py`; it is mounted here by
    # discovery so parallel work packages never edit this file.
    #   ADV: no merge conflicts in main.py; adding a module needs no wiring.
    #   COMPROMISE: mounting is implicit; the OpenAPI document is the list of what got mounted.
    for mod in pkgutil.iter_modules(agritrace.modules.__path__):
        name = f"agritrace.modules.{mod.name}.router"
        if importlib.util.find_spec(name):
            v1.include_router(importlib.import_module(name).router)
    app.include_router(v1)
    return app


app = create_app()
