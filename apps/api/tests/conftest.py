"""Shared pytest fixtures: throwaway PostGIS, Valkey and LocalStack S3 containers plus an HTTP client.

Serves: B00 test harness (plan §7.1), D-008 (buckets as in production), D-009 (eager Celery in tests),
D-021 (Valkey as the Redis-protocol broker).
Callers: pytest. Unit tests use none of these fixtures, so `pytest tests/unit` needs no Docker; tests
marked `integration` (tests/integration, tests/e2e) request `client`, `migrated` or `stack` and start the
containers once per session. `_without_stack_env` hides the stack's variables from every test that does
not request `stack`, because the session fixture stays up until the unit tests after it have run (B00-2).
"""

import os
import subprocess
import sys
from collections.abc import AsyncIterator, Iterator
from contextlib import suppress
from pathlib import Path
from unittest import mock

import pytest
from httpx import ASGITransport, AsyncClient
from testcontainers.community.localstack import LocalStackContainer
from testcontainers.community.postgres import PostgresContainer
from testcontainers.community.redis import RedisContainer

from agritrace.core import db, storage
from agritrace.core.config import get_settings

REGION = "ap-south-1"
API_DIR = Path(__file__).parents[1]
BEFORE_STACK: dict[str, str | None] = {}  # values of the stack's variables before `stack` set them


@pytest.fixture(scope="session")
def stack() -> Iterator[None]:
    """Start PostGIS, Valkey and LocalStack S3, point the settings at them and create the three buckets.

    Returns:
        An iterator yielding once while the containers run.

    Raises:
        docker.errors.DockerException: Docker is not running.

    Side effects:
        Sets DATABASE_URL, REDIS_URL, S3_*, ENV, JWT_SECRET and OTP_DEV_CODE in `os.environ` (restored at
        session end); records their old values in BEFORE_STACK; clears cached settings, engine and S3
        clients; stops the containers at session end.
    """
    with (
        mock.patch.dict(os.environ),
        PostgresContainer("postgis/postgis:16-3.4", driver="asyncpg") as pg,
        # DECISION D-021: Valkey instead of Redis, same image as infra/docker-compose.yml; it speaks the
        #   Redis protocol, so RedisContainer and redis-py work unchanged.
        #   ADV: BSD-3 licence (Redis 7.4+ is RSAL/SSPL); ElastiCache for Valkey in production.
        #   COMPROMISE: newer project; Redis-only modules are not available.
        RedisContainer("valkey/valkey:8-alpine") as rd,
        # LocalStack 4.14.0 is the last tag that starts without an auth token (D-008).
        # S3_SKIP_SIGNATURE_VALIDATION=0: LocalStack checks presigned signatures like AWS (signed headers).
        LocalStackContainer("localstack/localstack:4.14.0", region_name=REGION)
        .with_services("s3")
        .with_env("S3_SKIP_SIGNATURE_VALIDATION", "0") as ls,
    ):
        env = dict(
            ENV="test",
            DATABASE_URL=pg.get_connection_url(),
            REDIS_URL=f"redis://{rd.get_container_host_ip()}:{rd.get_exposed_port(6379)}/0",
            S3_ENDPOINT=ls.get_url(),
            S3_PUBLIC_ENDPOINT=ls.get_url(),
            S3_REGION=REGION,
            S3_ACCESS_KEY="test",
            S3_SECRET_KEY="test",
            JWT_SECRET="integration-test-secret",
            OTP_DEV_CODE="123456",
        )
        BEFORE_STACK.update((key, os.environ.get(key)) for key in env)
        os.environ.update(env)
        for cached in (get_settings, db.get_engine, db.get_sessionmaker, storage._client_for):
            cached.cache_clear()
        s3 = storage.client()
        where = {"CreateBucketConfiguration": {"LocationConstraint": REGION}}
        # Same bucket semantics as infra/scripts/s3-init.sh (D-008); retention is not needed in tests.
        for bucket, lock in (("evidence", True), ("public-pages", False), ("id-docs", False)):
            # A slow first reply makes botocore retry a CreateBucket that already succeeded (B00-1).
            with suppress(s3.exceptions.BucketAlreadyOwnedByYou, s3.exceptions.BucketAlreadyExists):
                s3.create_bucket(Bucket=bucket, ObjectLockEnabledForBucket=lock, **where)
        # A rebuilt page keeps the previous build's objects as older versions (B10 acceptance).
        s3.put_bucket_versioning(Bucket="public-pages", VersioningConfiguration={"Status": "Enabled"})
        yield


@pytest.fixture(autouse=True)
def _without_stack_env(request: pytest.FixtureRequest, monkeypatch: pytest.MonkeyPatch) -> None:
    """Give a test that does not use `stack` the environment it would have had without it (B00-2).

    Args:
        request: the test's fixture request (its fixture closure says whether it uses `stack`).
        monkeypatch: undoes the change after the test.

    Side effects:
        For the duration of the test only, resets the variables in BEFORE_STACK to their old values.
    """
    if "stack" in request.fixturenames:
        return
    for key, old in BEFORE_STACK.items():
        if old is None:
            monkeypatch.delenv(key, raising=False)
        else:
            monkeypatch.setenv(key, old)


@pytest.fixture(scope="session")
def migrated(stack: None) -> None:
    """Migrate the test database to head (a no-op when another test module already did).

    Args:
        stack: the running containers (fixture).

    Raises:
        AssertionError: alembic failed (its output is in the message).

    Side effects:
        Creates every table and trigger up to the latest revision.
    """
    alembic = str(Path(sys.executable).parent / "alembic")
    result = subprocess.run(  # noqa: S603
        [alembic, "upgrade", "head"], cwd=API_DIR, capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stdout + result.stderr


@pytest.fixture
async def client(stack: None) -> AsyncIterator[AsyncClient]:
    """HTTP client calling the app in-process, with Celery tasks executed eagerly.

    Args:
        stack: the running containers (fixture).

    Returns:
        An async iterator yielding an `httpx.AsyncClient` with base URL `http://test`.

    Side effects:
        Sets `task_always_eager` on the Celery app for the test session.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    celery_app.conf.task_always_eager = True  # CELERY_TASK_ALWAYS_EAGER: tasks run inline in tests
    async with AsyncClient(transport=ASGITransport(app=create_app()), base_url="http://test") as c:
        yield c
