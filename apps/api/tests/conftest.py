"""Shared pytest fixtures: throwaway PostGIS, Valkey and LocalStack S3 containers plus an HTTP client.

Serves: B00 test harness (plan §7.1), D-008 (buckets as in production), D-009 (eager Celery in tests),
D-021 (Valkey as the Redis-protocol broker).
Callers: pytest. Unit tests use none of these fixtures, so `pytest tests/unit` needs no Docker; tests
marked `integration` request `client` (or `stack`) and start the containers once per session.
"""

import os
from collections.abc import AsyncIterator, Iterator

import pytest
from httpx import ASGITransport, AsyncClient
from testcontainers.community.localstack import LocalStackContainer
from testcontainers.community.postgres import PostgresContainer
from testcontainers.community.redis import RedisContainer

from agritrace.core import db, storage
from agritrace.core.config import get_settings

REGION = "ap-south-1"


@pytest.fixture(scope="session")
def stack() -> Iterator[None]:
    """Start PostGIS, Valkey and LocalStack S3, point the settings at them and create the three buckets.

    Returns:
        An iterator yielding once while the containers run.

    Raises:
        docker.errors.DockerException: Docker is not running.

    Side effects:
        Sets DATABASE_URL, REDIS_URL, S3_* and ENV in `os.environ`; clears cached settings, engine and S3
        clients; stops the containers at session end.
    """
    with (
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
        os.environ.update(
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
        for cached in (get_settings, db.get_engine, db.get_sessionmaker, storage._client_for):
            cached.cache_clear()
        s3 = storage.client()
        where = {"CreateBucketConfiguration": {"LocationConstraint": REGION}}
        # Same bucket semantics as infra/scripts/s3-init.sh (D-008); retention is not needed in tests.
        s3.create_bucket(Bucket="evidence", ObjectLockEnabledForBucket=True, **where)
        s3.create_bucket(Bucket="public-pages", **where)
        # A rebuilt page keeps the previous build's objects as older versions (B10 acceptance).
        s3.put_bucket_versioning(Bucket="public-pages", VersioningConfiguration={"Status": "Enabled"})
        s3.create_bucket(Bucket="id-docs", **where)
        yield


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
