"""Shared pytest fixtures: throwaway PostGIS, Redis and MinIO containers plus an HTTP client over the app.

Serves: B00 test harness (plan §7.1), D-008 (buckets as in production), D-009 (eager Celery in tests).
Callers: pytest. Unit tests use none of these fixtures, so `pytest tests/unit` needs no Docker; tests
marked `integration` request `client` (or `stack`) and start the containers once per session.
"""

import os
from collections.abc import AsyncIterator, Iterator

import boto3
import pytest
from httpx import ASGITransport, AsyncClient
from testcontainers.community.minio import MinioContainer
from testcontainers.community.postgres import PostgresContainer
from testcontainers.community.redis import RedisContainer

from agritrace.core import db, storage
from agritrace.core.config import get_settings


@pytest.fixture(scope="session")
def stack() -> Iterator[None]:
    """Start PostGIS, Redis and MinIO, point the settings at them and create the three buckets.

    Returns:
        An iterator yielding once while the containers run.

    Raises:
        docker.errors.DockerException: Docker is not running.

    Side effects:
        Sets DATABASE_URL, REDIS_URL, S3_* and ENV in `os.environ`; clears cached settings, engine and S3
        client; stops the containers at session end.
    """
    with (
        PostgresContainer("postgis/postgis:16-3.4", driver="asyncpg") as pg,
        RedisContainer("redis:7-alpine") as rd,
        # Same image as infra/docker-compose.yml; official minio/minio images are no longer published.
        MinioContainer("pgsty/minio:RELEASE.2026-08-04T00-00-00Z") as mn,
    ):
        cfg = mn.get_config()
        os.environ.update(
            ENV="test",
            DATABASE_URL=pg.get_connection_url(),
            REDIS_URL=f"redis://{rd.get_container_host_ip()}:{rd.get_exposed_port(6379)}/0",
            S3_ENDPOINT=f"http://{cfg['endpoint']}",
            S3_ACCESS_KEY=cfg["access_key"],
            S3_SECRET_KEY=cfg["secret_key"],
        )
        for cached in (get_settings, db.get_engine, db.get_sessionmaker, storage.client):
            cached.cache_clear()
        s3 = boto3.client(
            "s3",
            endpoint_url=os.environ["S3_ENDPOINT"],
            aws_access_key_id=cfg["access_key"],
            aws_secret_access_key=cfg["secret_key"],
            region_name="us-east-1",
        )
        # Same bucket semantics as infra/scripts/minio-init.sh (D-008).
        s3.create_bucket(Bucket="evidence", ObjectLockEnabledForBucket=True)
        s3.create_bucket(Bucket="public-pages")
        s3.create_bucket(Bucket="id-docs")
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
