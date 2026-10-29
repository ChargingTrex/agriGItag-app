"""Unit tests for S3 client settings and presigned PUT signing (offline; boto3 signs without network).

Serves: D-011 (presigned PUT bound to the SHA-256), P2-4 of review B00-r1 (bounded S3 timeouts).
Callers: pytest (`make test-unit`); no Docker needed.
"""

import hashlib
from collections.abc import Iterator
from urllib.parse import parse_qs, urlsplit

import pytest

from agritrace.core import storage
from agritrace.core.config import get_settings


@pytest.fixture(autouse=True)
def settings(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Point the settings at an internal and a public S3 endpoint.

    Args:
        monkeypatch: pytest monkeypatch fixture.

    Returns:
        An iterator yielding once; caches are cleared before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test")
    monkeypatch.setenv("S3_ENDPOINT", "http://s3:4566")
    monkeypatch.setenv("S3_PUBLIC_ENDPOINT", "http://192.168.1.5:4566")
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()
    yield
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()


def test_client_has_bounded_timeouts() -> None:
    """The client gives up fast: 3 s connect, 10 s read, standard mode, 2 retries (3 attempts in total)."""
    cfg = storage.client().meta.config
    assert (cfg.connect_timeout, cfg.read_timeout) == (3, 10)
    assert cfg.retries == {"mode": "standard", "total_max_attempts": 3}  # botocore stores max_attempts + 1
    assert storage.client().meta.endpoint_url == "http://s3:4566"


def test_presign_put_signs_public_endpoint_with_checksum() -> None:
    """The URL targets the public endpoint and signs Content-Type and the SHA-256 header."""
    url = storage.presign_put("t/a.jpg", "image/jpeg", hashlib.sha256(b"x").hexdigest())
    parts = urlsplit(url)
    assert f"{parts.scheme}://{parts.netloc}" == "http://192.168.1.5:4566"
    assert parts.path == "/evidence/t/a.jpg"
    signed = parse_qs(parts.query)["X-Amz-SignedHeaders"][0].split(";")
    assert {"content-type", "x-amz-checksum-sha256"} <= set(signed)


@pytest.mark.parametrize("bad", ["ab", "zz" * 32, "00" * 31, "00" * 33])
def test_presign_put_rejects_bad_digest(bad: str) -> None:
    """Anything but 64 hex characters is refused before signing.

    Args:
        bad: an invalid digest string.
    """
    with pytest.raises(ValueError):
        storage.presign_put("t/a.jpg", "image/jpeg", bad)
