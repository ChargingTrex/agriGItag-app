"""Unit tests of evidence helpers: object key, presigned upload, EXIF reading and tolerances, WebP sizes.

Serves: B06 deliverable 6 (object key format, presign request shape, EXIF comparison tolerances, variants
sizing with a generated image), FR61, plan §13 B3, B6, D-011.
Callers: pytest (`make test-unit`); no Docker (boto3 signs offline; Pillow generates the images).
"""

import base64
import hashlib
import random
import uuid
from collections.abc import Iterator
from datetime import UTC, datetime, timedelta, timezone
from io import BytesIO
from urllib.parse import parse_qs, urlsplit

import pytest
from PIL import ExifTags, Image

from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.schemas import GeoPoint
from agritrace.modules.events import evidence

IST = timezone(timedelta(hours=5, minutes=30))


@pytest.fixture
def settings(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
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


def jpeg(
    taken: str | None = None, offset: str | None = None, lat: float = 9.5598, lon: float = 78.1335
) -> bytes:
    """Make a small JPEG with EXIF capture time and GPS.

    Args:
        taken: `YYYY:MM:DD HH:MM:SS`, or None for no capture time.
        offset: `OffsetTimeOriginal`, e.g. `+05:30`.
        lat: latitude (north).
        lon: longitude (east).

    Returns:
        The JPEG bytes.
    """
    exif = Image.Exif()
    sub = exif.get_ifd(ExifTags.IFD.Exif)
    if taken:
        sub[ExifTags.Base.DateTimeOriginal] = taken
    if offset:
        sub[ExifTags.Base.OffsetTimeOriginal] = offset
    gps = exif.get_ifd(ExifTags.IFD.GPSInfo)

    def dms(value: float) -> tuple[float, float, float]:
        """Split decimal degrees.

        Args:
            value: decimal degrees.

        Returns:
            (degrees, minutes, seconds).
        """
        minutes = (value % 1) * 60
        return (float(int(value)), float(int(minutes)), round((minutes % 1) * 60, 4))

    gps.update({1: "N", 2: dms(lat), 3: "E", 4: dms(lon)})
    buf = BytesIO()
    Image.new("RGB", (64, 48), "red").save(buf, "JPEG", exif=exif)
    return buf.getvalue()


def test_object_key_format() -> None:
    """Keys are `evidence/{fpo}/{yyyy}/{event}/{photo}.jpg` (backend-design.md §2)."""
    fpo, event, photo = uuid.uuid4(), uuid.uuid4(), uuid.uuid4()
    assert evidence.object_key(fpo, 2026, event, photo) == f"evidence/{fpo}/2026/{event}/{photo}.jpg"


def test_upload_instruction_binds_checksum_and_type(settings: None) -> None:
    """One PUT on the public endpoint, signed over Content-Type and the SHA-256, 15-minute expiry.

    Args:
        settings: S3 settings (fixture).
    """
    digest = hashlib.sha256(b"photo").hexdigest()
    expires = datetime(2026, 3, 4, tzinfo=UTC)
    up = evidence.upload_instruction(uuid.uuid4(), "evidence/f/2026/e/p.jpg", "image/jpeg", digest, expires)
    parts = urlsplit(up.url)
    assert up.method == "PUT" and up.expires_at == expires
    assert f"{parts.scheme}://{parts.netloc}" == "http://192.168.1.5:4566"
    assert parts.path == "/evidence/evidence/f/2026/e/p.jpg"
    query = parse_qs(parts.query)
    assert query["X-Amz-Expires"] == ["900"]
    assert {"content-type", "x-amz-checksum-sha256"} <= set(query["X-Amz-SignedHeaders"][0].split(";"))
    checksum = base64.b64encode(hashlib.sha256(b"photo").digest()).decode()
    assert up.headers == {"Content-Type": "image/jpeg", "x-amz-checksum-sha256": checksum}


def test_read_exif_time_and_gps() -> None:
    """Capture time (offset or India time) and decimal GPS are read back."""
    taken, gps = evidence.read_exif(jpeg("2026:03:04 08:10:00", "+05:30"))
    assert taken == datetime(2026, 3, 4, 8, 10, tzinfo=IST)
    assert gps is not None and abs(gps.lat - 9.5598) < 1e-4 and abs(gps.lon - 78.1335) < 1e-4
    naive, _ = evidence.read_exif(jpeg("2026:03:04 08:10:00"))
    assert naive == datetime(2026, 3, 4, 2, 40, tzinfo=UTC)  # read as IST
    assert evidence.read_exif(jpeg(None))[0] is None


@pytest.mark.parametrize(
    ("minutes", "metres_north", "problems"),
    [
        (0, 0, []),
        (30, 0, []),
        (31, 0, ["time_mismatch"]),
        (-31, 0, ["time_mismatch"]),
        (0, 240, []),
        (0, 260, ["gps_mismatch"]),
    ],
)
def test_exif_tolerances(minutes: int, metres_north: float, problems: list[str]) -> None:
    """Time within 30 minutes and position within 250 m of the entry pass.

    Args:
        minutes: EXIF time minus device time.
        metres_north: EXIF position north of the entry position.
        problems: expected problem codes.
    """
    device = datetime(2026, 3, 4, 2, 40, tzinfo=UTC)
    entry = GeoPoint(lat=9.5598, lon=78.1335)
    exif_gps = GeoPoint(lat=9.5598 + metres_north / 110_600, lon=78.1335)  # ~110.6 km per degree here
    assert evidence.exif_problems(device + timedelta(minutes=minutes), exif_gps, device, entry) == problems


def test_missing_capture_time_and_gps() -> None:
    """No EXIF time is a problem; GPS is compared only when both positions exist."""
    device = datetime(2026, 3, 4, tzinfo=UTC)
    assert evidence.exif_problems(None, None, device, GeoPoint(lat=9.5, lon=78.1)) == ["no_capture_time"]
    assert evidence.exif_problems(device, GeoPoint(lat=10, lon=79), device, None) == []


def test_webp_variants_fit_their_budgets() -> None:
    """A photo-like 2000x1500 image gives a thumbnail ≤ 60 KB and a medium ≤ 150 KB (long edge ≤ 480/1280)."""
    rng = random.Random(7)  # noqa: S311 - deterministic test pixels
    # Upscaled noise has the soft texture of a field photo; raw pixel noise is incompressible.
    noise = Image.frombytes("RGB", (200, 150), bytes(rng.getrandbits(8) for _ in range(200 * 150 * 3)))
    image = noise.resize((2000, 1500), Image.Resampling.BICUBIC)
    thumb, width, height = evidence.webp_variant(image, *evidence.THUMB)
    medium, mw, mh = evidence.webp_variant(image, *evidence.MEDIUM)
    assert (width, height) == (480, 360)  # fits at some quality step
    assert mw <= 1280 and mh <= 960 and abs(mw / mh - 4 / 3) < 0.01  # may shrink to fit, keeps aspect
    assert len(thumb) <= 60_000 and len(medium) <= 150_000
    assert Image.open(BytesIO(thumb)).format == "WEBP"
    small, sw, sh = evidence.webp_variant(Image.new("RGB", (300, 200), "green"), *evidence.THUMB)
    assert (sw, sh) == (300, 200)  # never upscaled


@pytest.mark.parametrize(
    ("content_type", "ext"), [("image/jpeg", "jpg"), ("audio/ogg", "ogg"), ("audio/mp4", "m4a")]
)
def test_object_key_extension_follows_content_type(content_type: str, ext: str) -> None:
    """Voice notes keep their own extension next to photos.

    Args:
        content_type: the media type.
        ext: the expected extension.
    """
    key = evidence.object_key(uuid.uuid4(), 2026, uuid.uuid4(), uuid.uuid4(), content_type)
    assert key.endswith(f".{ext}")
