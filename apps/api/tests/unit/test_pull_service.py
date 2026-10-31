"""Unit tests of the sync pull helpers: cursor, page merge, the 24 h `photo_pending` rule, presigned variants.

Serves: B07 acceptance (`GET /v1/sync/pull` opaque cursor, `photo_pending` after 24 h, variant URLs presigned
per the B06 review P3), backend-design.md §3, FR61.
Callers: pytest (`make test-unit`); no Docker needed (boto3 signs offline).
"""

import uuid
from collections.abc import Iterator
from datetime import UTC, datetime, timedelta
from urllib.parse import parse_qs, urlsplit

import pytest

from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.enums import PhotoStatus
from agritrace.core.errors import ValidationFailedError
from agritrace.modules.events import evidence
from agritrace.modules.events import pull_service as ps

NOW = datetime(2026, 3, 5, 8, 0, tzinfo=UTC)


@pytest.fixture
def s3(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Point the settings at a public S3 endpoint.

    Args:
        monkeypatch: pytest monkeypatch fixture.

    Returns:
        An iterator yielding once; caches are cleared before and after.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test")
    monkeypatch.setenv("S3_PUBLIC_ENDPOINT", "http://192.168.1.5:4566")
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()
    yield
    for cached in (get_settings, storage._client_for):
        cached.cache_clear()


def test_cursor_round_trip() -> None:
    """A cursor decodes to the (updated_at, id) it was made from and is URL-safe."""
    row_id = uuid.uuid4()
    cursor = ps.encode_cursor(NOW, row_id)
    assert ps.decode_cursor(cursor) == (NOW, row_id)
    assert set(cursor) <= set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")


@pytest.mark.parametrize(
    "bad",
    [
        "not base64!",
        "W10",  # []
        ps.encode_cursor(NOW, uuid.uuid4())[:-4],
        ps.encode_cursor(NOW.replace(tzinfo=None), uuid.uuid4()),  # naive time
    ],
)
def test_bad_cursor_is_validation_error(bad: str) -> None:
    """Anything this endpoint did not issue is a 422 `validation_error`.

    Args:
        bad: an invalid cursor.
    """
    with pytest.raises(ValidationFailedError):
        ps.decode_cursor(bad)


def test_merge_page_orders_across_tables_and_reports_more() -> None:
    """Rows of several tables come out by (updated_at, id); `has_more` when more than `limit` remain."""
    t = [NOW + timedelta(seconds=i) for i in range(4)]
    ids = sorted(uuid.uuid4() for _ in range(4))
    changes: list[ps.Change] = [
        (t[2], ids[0], "flag", {}),
        (t[0], ids[1], "lot", {}),
        (t[1], ids[3], "event", {}),
        (t[1], ids[2], "intake", {}),
    ]
    page, more = ps.merge_page(changes, 3)
    assert [c[2] for c in page] == ["lot", "intake", "event"]
    assert more
    assert ps.merge_page(changes, 4) == (sorted(changes, key=lambda c: (c[0], c[1])), False)


def test_photo_pending_after_24_hours_only() -> None:
    """Still `pending_upload` at 24 h → pending; younger, or uploaded, → not."""
    day = timedelta(hours=24)
    assert ps.is_photo_pending(PhotoStatus.PENDING_UPLOAD, NOW - day, NOW)
    assert not ps.is_photo_pending(PhotoStatus.PENDING_UPLOAD, NOW - day + timedelta(minutes=1), NOW)
    assert not ps.is_photo_pending(PhotoStatus.UPLOADED, NOW - 2 * day, NOW)


@pytest.mark.usefixtures("s3")
def test_presign_get_signs_public_endpoint() -> None:
    """`presign_get` targets the public endpoint and the evidence bucket by default, with an expiry."""
    parts = urlsplit(storage.presign_get("evidence/f/2026/e/p.thumb.webp", 600))
    assert f"{parts.scheme}://{parts.netloc}" == "http://192.168.1.5:4566"
    assert parts.path == "/evidence/evidence/f/2026/e/p.thumb.webp"
    query = parse_qs(parts.query)
    assert query["X-Amz-Expires"] == ["600"] and "X-Amz-Signature" in query


@pytest.mark.usefixtures("s3")
def test_signed_variants_presigns_webp_and_drops_original() -> None:
    """Thumb and medium become presigned GETs of the same keys; the EXIF JPEG is dropped (B07-r1 P2-1)."""
    base = "evidence/f/2026/e/p"
    stored = {
        "thumb_url": evidence._public_url(f"{base}.thumb.webp"),
        "medium_url": evidence._public_url(f"{base}.medium.webp"),
        "jpeg_url": evidence._public_url(f"{base}.jpg"),
        "width": 480,
        "height": 360,
    }
    signed = evidence.signed_variants(stored)
    assert signed is not None
    assert set(signed) == {"thumb_url", "medium_url", "width", "height"}
    assert urlsplit(signed["thumb_url"]).path == f"/evidence/{base}.thumb.webp"
    assert "X-Amz-Signature" in parse_qs(urlsplit(signed["medium_url"]).query)
    assert (signed["width"], signed["height"]) == (480, 360)
    assert evidence.signed_variants(None) is None
