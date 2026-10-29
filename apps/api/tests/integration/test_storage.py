"""Integration test: a presigned evidence PUT is accepted only with the promised SHA-256.

Serves: D-011 (single presigned PUT with checksum), D-008 (object-locked evidence bucket).
Callers: pytest (`make test`); needs Docker.
"""

import base64
import hashlib

import httpx
import pytest

from agritrace.core import storage

pytestmark = pytest.mark.integration


def test_presigned_put_checks_sha256(stack: None) -> None:
    """Matching bytes are stored and visible via head(); different bytes are refused.

    Args:
        stack: the running containers (fixture).
    """
    body = b"\xff\xd8 fake jpeg"
    digest = hashlib.sha256(body).digest()
    url = storage.presign_put("t/photo.jpg", "image/jpeg", digest.hex())
    headers = {"Content-Type": "image/jpeg", "x-amz-checksum-sha256": base64.b64encode(digest).decode()}

    assert httpx.put(url, content=b"tampered", headers=headers).status_code == 400
    assert storage.head("t/photo.jpg") is None
    assert httpx.put(url, content=body, headers=headers).status_code == 200
    meta = storage.head("t/photo.jpg")
    assert meta is not None and meta["ContentLength"] == len(body)
    assert storage.get_stream("t/photo.jpg").read() == body
