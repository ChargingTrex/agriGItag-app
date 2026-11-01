"""Integration test: a presigned evidence PUT is accepted only with the promised SHA-256 and length.

Serves: D-011 (single presigned PUT with checksum), D-008 (object-locked evidence bucket), B18.
Callers: pytest (`make test`); needs Docker.
"""

import base64
import hashlib

import httpx
import pytest

from agritrace.core import storage

pytestmark = pytest.mark.integration


def test_presigned_put_checks_sha256(stack: None) -> None:
    """Matching bytes are stored; wrong bytes give 400, a missing checksum or other Content-Type give 403.

    Args:
        stack: the running containers (fixture).
    """
    body = b"\xff\xd8 fake jpeg"
    digest = hashlib.sha256(body).digest()
    url = storage.presign_put("t/photo.jpg", "image/jpeg", digest.hex())
    headers = {"Content-Type": "image/jpeg", "x-amz-checksum-sha256": base64.b64encode(digest).decode()}

    assert httpx.put(url, content=b"tampered", headers=headers).status_code == 400
    # Signed headers (S3_SKIP_SIGNATURE_VALIDATION=0): dropping the checksum or changing the type fails.
    no_checksum = {"Content-Type": "image/jpeg"}
    assert httpx.put(url, content=body, headers=no_checksum).status_code == 403
    assert httpx.put(url, content=body, headers={**headers, "Content-Type": "image/png"}).status_code == 403
    assert storage.head("t/photo.jpg") is None
    assert httpx.put(url, content=body, headers=headers).status_code == 200
    meta = storage.head("t/photo.jpg")
    assert meta is not None and meta["ContentLength"] == len(body)
    assert storage.get_stream("t/photo.jpg").read() == body


def test_presigned_put_checks_declared_length(stack: None) -> None:
    """A PUT whose Content-Length differs from the signed `size_bytes` is refused (B18, audit waves 3-6 #4).

    Args:
        stack: the running containers (fixture).
    """
    body = b"\xff\xd8 fake jpeg"
    digest = hashlib.sha256(body).digest()
    headers = {"Content-Type": "image/jpeg", "x-amz-checksum-sha256": base64.b64encode(digest).decode()}
    # The checksum matches, so only the signed length can refuse it.
    lying = storage.presign_put("t/sized.jpg", "image/jpeg", digest.hex(), size_bytes=len(body) + 1)
    assert httpx.put(lying, content=body, headers=headers).status_code == 403
    assert storage.head("t/sized.jpg") is None
    honest = storage.presign_put("t/sized.jpg", "image/jpeg", digest.hex(), size_bytes=len(body))
    assert httpx.put(honest, content=body, headers=headers).status_code == 200
