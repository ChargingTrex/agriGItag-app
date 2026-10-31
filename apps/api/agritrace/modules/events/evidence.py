"""Evidence photos: object keys, presigned upload instructions, EXIF checks and WebP variants.

The pure helpers (`object_key`, `upload_instruction`, `read_exif`, `exif_problems`, `webp_variant`) are
unit-tested; `verify` and `make_variants` are the bodies of the Celery tasks of the same names.

Serves: FR3 (photo evidence), FR26 (time and place of capture), FR61 (permanent, versioned storage; photo
time and GPS checked against the event), plan §13 B3 (presigned PUT + SHA-256) and B6 (WebP thumbnail
~60 KB, medium ~150 KB), D-011, W01 cross-package expectation (variants carry `width`, `height`,
`jpeg_url`).
Callers: `events.service` (keys, upload instructions, `signed_variants` for the lot timeline),
`events.pull_service` (`signed_variants`, B07), `events.tasks` (verify, make_variants),
tests/unit/test_events_evidence.py, tests/integration/test_sync.py.
"""

import asyncio
import base64
import hashlib
import uuid
from datetime import datetime, timedelta
from io import BytesIO
from typing import Any
from zoneinfo import ZoneInfo

from geoalchemy2 import WKTElement
from geoalchemy2.shape import to_shape
from PIL import ExifTags, Image, ImageOps
from pyproj import Geod
from shapely.geometry import Point
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import storage
from agritrace.core.config import get_settings
from agritrace.core.enums import PhotoStatus
from agritrace.core.schemas import GeoPoint
from agritrace.core.time import utcnow
from agritrace.modules.events.models import EventVersion, EvidencePhoto
from agritrace.modules.events.schemas import PhotoUpload

UPLOAD_TTL = timedelta(minutes=15)
# Photos (M04) and voice notes: Android 10+ records Opus in Ogg, iOS and Android 8–9 AAC in MP4.
EXTENSIONS = {"image/jpeg": "jpg", "audio/ogg": "ogg", "audio/mp4": "m4a"}
# shortcut: tolerances are constants until B13 field configuration carries them; tune after field trials.
EXIF_TIME_TOLERANCE = timedelta(minutes=30)  # photo taken while filling the entry, which is saved later
EXIF_GPS_TOLERANCE_M = 250.0
# shortcut: EXIF without OffsetTimeOriginal is read as India time (pilot is Tamil Nadu; the stored device
#   time is UTC and has lost the phone's offset); store the device offset if the platform leaves India.
PILOT_TZ = ZoneInfo("Asia/Kolkata")
THUMB = (480, 60_000)  # long edge px, byte budget (plan §13 B6)
MEDIUM = (1280, 150_000)
WEBP_QUALITIES = (80, 70, 60, 50, 40, 30)
_GEOD = Geod(ellps="WGS84")


def object_key(
    fpo_id: uuid.UUID, year: int, event_id: uuid.UUID, photo_id: uuid.UUID, content_type: str = "image/jpeg"
) -> str:
    """Build the permanent object key of an evidence photo or voice note (FR61; never a temporary path).

    Args:
        fpo_id: owning FPO.
        year: year of the event (`occurred_on`).
        event_id: the event the media documents.
        photo_id: the media's client id.
        content_type: one of `EXTENSIONS`; picks the file extension.

    Returns:
        `evidence/{fpo_id}/{yyyy}/{event_id}/{photo_id}.{jpg|ogg|m4a}` inside the evidence bucket.

    Raises:
        KeyError: an unsupported content type (the request schema admits only `EXTENSIONS`).
    """
    return f"evidence/{fpo_id}/{year:04d}/{event_id}/{photo_id}.{EXTENSIONS[content_type]}"


def upload_instruction(
    photo_id: uuid.UUID, key: str, content_type: str, sha256_hex: str, expires_at: datetime
) -> PhotoUpload:
    """Presign the single PUT of one photo (D-011).

    Args:
        photo_id: the photo's client id.
        key: its object key.
        content_type: MIME type bound into the signature.
        sha256_hex: the phone's hex SHA-256, bound into the signature.
        expires_at: expiry stored on the row; the URL lives `UPLOAD_TTL`.

    Returns:
        Method, URL on the public endpoint, the exact headers to send, and the expiry.

    Raises:
        ValueError: `sha256_hex` is not 64 hex characters (from `storage.presign_put`).
    """
    # DECISION D-011: one presigned PUT per photo, SHA-256 and Content-Type bound into the signature.
    #   ADV: the API never proxies bytes; storage itself refuses bytes that differ from the promised digest.
    #   COMPROMISE: a dropped upload restarts the whole ~300 KB; no resumable upload in the pilot.
    url = storage.presign_put(key, content_type, sha256_hex, int(UPLOAD_TTL.total_seconds()))
    checksum = base64.b64encode(bytes.fromhex(sha256_hex)).decode()
    headers = {"Content-Type": content_type, "x-amz-checksum-sha256": checksum}
    return PhotoUpload(photo_client_id=photo_id, url=url, headers=headers, expires_at=expires_at)


def _degrees(dms: Any, ref: Any) -> float:
    """Convert an EXIF degrees/minutes/seconds triple to signed decimal degrees.

    Args:
        dms: three rationals (degrees, minutes, seconds).
        ref: `N`/`S` or `E`/`W`.

    Returns:
        Decimal degrees, negative for south and west.
    """
    value = float(dms[0]) + float(dms[1]) / 60 + float(dms[2]) / 3600
    return -value if str(ref).upper() in ("S", "W") else value


def read_exif(data: bytes) -> tuple[datetime | None, GeoPoint | None]:
    """Read capture time and GPS position from a JPEG's EXIF (FR61).

    Args:
        data: the image bytes.

    Returns:
        (capture time, position). The time is aware when `OffsetTimeOriginal` is present, else read as
        India time; either part is None when absent or unreadable.

    Raises:
        PIL.UnidentifiedImageError: the bytes are not an image.
    """
    exif = Image.open(BytesIO(data)).getexif()
    sub = exif.get_ifd(ExifTags.IFD.Exif)
    taken_at = None
    raw = sub.get(ExifTags.Base.DateTimeOriginal)
    if raw:
        offset = sub.get(ExifTags.Base.OffsetTimeOriginal)
        try:
            taken_at = (
                datetime.strptime(f"{raw} {offset}", "%Y:%m:%d %H:%M:%S %z")
                if offset
                else datetime.strptime(str(raw), "%Y:%m:%d %H:%M:%S").replace(tzinfo=PILOT_TZ)
            )
        except ValueError:
            taken_at = None
    gps = exif.get_ifd(ExifTags.IFD.GPSInfo)
    point = None
    try:
        lat = _degrees(gps[ExifTags.GPS.GPSLatitude], gps[ExifTags.GPS.GPSLatitudeRef])
        lon = _degrees(gps[ExifTags.GPS.GPSLongitude], gps[ExifTags.GPS.GPSLongitudeRef])
        point = GeoPoint(lat=lat, lon=lon)
    except (KeyError, IndexError, TypeError, ValueError, ZeroDivisionError):
        point = None
    return taken_at, point


def exif_problems(
    taken_at: datetime | None, gps: GeoPoint | None, device_time: datetime, entry_gps: GeoPoint | None
) -> list[str]:
    """Compare a photo's EXIF with its entry's device clock and GPS (FR26, FR61).

    Args:
        taken_at: EXIF capture time (aware), or None.
        gps: EXIF position, or None.
        device_time: the entry's device time (aware).
        entry_gps: the entry's GPS fix, or None.

    Returns:
        Problem codes: `no_capture_time`, `time_mismatch` (beyond `EXIF_TIME_TOLERANCE`), `gps_mismatch`
        (beyond `EXIF_GPS_TOLERANCE_M`; checked only when both positions exist). Empty when consistent.
    """
    problems = []
    if taken_at is None:
        problems.append("no_capture_time")
    elif abs(taken_at - device_time) > EXIF_TIME_TOLERANCE:
        problems.append("time_mismatch")
    if gps is not None and entry_gps is not None:
        distance = _GEOD.inv(gps.lon, gps.lat, entry_gps.lon, entry_gps.lat)[2]
        if distance > EXIF_GPS_TOLERANCE_M:
            problems.append("gps_mismatch")
    return problems


def webp_variant(image: Image.Image, long_edge: int, max_bytes: int) -> tuple[bytes, int, int]:
    """Encode a downscaled WebP within a byte budget (plan §13 B6).

    Steps the quality down; if even the lowest quality is over budget (very busy pictures), shrinks the
    picture by 15 % and tries again, so the budget always holds.

    Args:
        image: the upright source image.
        long_edge: longest side of the variant in pixels (never upscaled).
        max_bytes: size budget in bytes.

    Returns:
        (WebP bytes, width, height). No EXIF is copied into the variant.
    """
    copy = image.convert("RGB")
    copy.thumbnail((long_edge, long_edge))
    while True:
        for quality in WEBP_QUALITIES:
            buf = BytesIO()
            copy.save(buf, "WEBP", quality=quality)
            if buf.tell() <= max_bytes or min(copy.size) < 32:
                return buf.getvalue(), copy.width, copy.height
        copy = copy.resize((int(copy.width * 0.85), int(copy.height * 0.85)), Image.Resampling.LANCZOS)


def _read_object(key: str) -> bytes:
    """Download one evidence object (photos are <= a few hundred KB, so it is read whole).

    Args:
        key: object key in the evidence bucket.

    Returns:
        The bytes.

    Raises:
        botocore.exceptions.ClientError: missing object or storage refused.
    """
    body = storage.get_stream(key)
    try:
        data: bytes = body.read()
    finally:
        body.close()
    return data


# Long enough for a phone on 2G to load a timeline's thumbnails; short enough that a leaked link dies soon.
VARIANT_URL_TTL_S = 3600


def _public_url(key: str) -> str:
    """URL of an evidence object on the public storage endpoint (B10 may front it with a CDN).

    Args:
        key: object key in the evidence bucket.

    Returns:
        `{S3_PUBLIC_ENDPOINT}/{evidence bucket}/{key}`.
    """
    s = get_settings()
    return f"{s.s3_public_endpoint.rstrip('/')}/{s.s3_bucket_evidence}/{key}"


def signed_variants(
    variants: dict[str, Any] | None, expires: int = VARIANT_URL_TTL_S
) -> dict[str, Any] | None:
    """Swap the stored variant URLs for presigned GETs; the evidence bucket is private (B06 review P3).

    Args:
        variants: the stored `variants` record (`*_url` values made by `_public_url`), or None.
        expires: URL lifetime in seconds.

    Returns:
        A copy with every `*_url` presigned, other keys (width, height) unchanged; None for None.
    """
    if variants is None:
        return None
    # Split on the bucket, not the whole public prefix, so links stored under an older endpoint still resolve.
    marker = f"/{get_settings().s3_bucket_evidence}/"
    return {
        k: storage.presign_get(v.split(marker, 1)[-1], expires)
        if k.endswith("_url") and isinstance(v, str)
        else v
        for k, v in variants.items()
    }


async def verify(session: AsyncSession, photo_id: uuid.UUID) -> tuple[PhotoStatus, uuid.UUID | None, bool]:
    """Check an uploaded photo's SHA-256 and EXIF against its entry (task `events.verify_photo`).

    Args:
        session: database session (committed here).
        photo_id: the photo.

    Returns:
        (resulting status, id of the event the photo documents or None, True when this call changed the
        status). A photo not in `uploaded` state is left alone.

    Raises:
        botocore.exceptions.ClientError: the object cannot be read.
        LookupError: no photo with this id.

    Side effects:
        Downloads the object; updates `sha256_server`, `exif_taken_at`, `exif_gps` (what the file says;
        the phone's declared values stay in the push audit row), `status`, `verified_at` (columns the
        append-only trigger allows) and commits. Voice notes get the checksum check only.
    """
    photo = await session.get(EvidencePhoto, photo_id)
    if photo is None:
        raise LookupError(photo_id)
    version = await session.get(EventVersion, photo.event_version_id) if photo.event_version_id else None
    event_id = version.event_id if version else None
    if photo.status != PhotoStatus.UPLOADED:
        return photo.status, event_id, False
    data = await asyncio.to_thread(_read_object, photo.object_key)
    photo.sha256_server = hashlib.sha256(data).hexdigest()
    photo.verified_at = utcnow()
    if photo.sha256_server != photo.sha256_client:
        photo.status = PhotoStatus.CHECKSUM_MISMATCH
        await session.commit()
        return photo.status, event_id, True
    if not photo.content_type.startswith("image/"):
        photo.status = PhotoStatus.VERIFIED  # audio has no EXIF to compare
        await session.commit()
        return photo.status, event_id, True
    taken_at, gps = read_exif(data)
    photo.exif_taken_at = taken_at
    photo.exif_gps = WKTElement(f"POINT({gps.lon} {gps.lat})", srid=4326) if gps else None
    problems: list[str] = []
    if version is not None:
        entry_gps = None
        if version.gps is not None:
            point = to_shape(version.gps)
            assert isinstance(point, Point)  # the column is geography(POINT)
            entry_gps = GeoPoint(lat=point.y, lon=point.x)
        problems = exif_problems(taken_at, gps, version.device_time, entry_gps)
    photo.status = PhotoStatus.EXIF_MISMATCH if problems else PhotoStatus.VERIFIED
    await session.commit()
    return photo.status, event_id, True


async def make_variants(session: AsyncSession, photo_id: uuid.UUID) -> dict[str, Any] | None:
    """Write the WebP thumbnail and medium next to the original and record them (task `events.make_variants`).

    Args:
        session: database session (committed here).
        photo_id: the photo.

    Returns:
        The `variants` record, or None when the photo is unknown, a voice note, not verified (checksum
        mismatch or not yet checked) or already has variants.

    Raises:
        botocore.exceptions.ClientError: storage refused a read or write.
        PIL.UnidentifiedImageError: the object is not an image.

    Side effects:
        Two new objects in the evidence bucket (`<key>.thumb.webp`, `<key>.medium.webp`); updates
        `variants` and commits.
    """
    photo = await session.get(EvidencePhoto, photo_id)
    ready = (PhotoStatus.VERIFIED, PhotoStatus.EXIF_MISMATCH)
    if photo is None or photo.variants is not None or photo.status not in ready:
        return None
    if not photo.content_type.startswith("image/"):
        return None
    data = await asyncio.to_thread(_read_object, photo.object_key)
    image = ImageOps.exif_transpose(Image.open(BytesIO(data)))
    base = photo.object_key.removesuffix(".jpg")
    thumb, width, height = webp_variant(image, *THUMB)
    medium, medium_width, medium_height = webp_variant(image, *MEDIUM)
    bucket = get_settings().s3_bucket_evidence
    for key, body in ((f"{base}.thumb.webp", thumb), (f"{base}.medium.webp", medium)):
        # The evidence bucket has object lock, which requires a checksum on every PUT.
        await asyncio.to_thread(
            storage.client().put_object,
            Bucket=bucket,
            Key=key,
            Body=body,
            ContentType="image/webp",
            ChecksumAlgorithm="SHA256",
        )
    photo.variants = {
        "thumb_url": _public_url(f"{base}.thumb.webp"),
        "medium_url": _public_url(f"{base}.medium.webp"),
        "jpeg_url": _public_url(photo.object_key),
        "width": width,
        "height": height,
        "medium_width": medium_width,
        "medium_height": medium_height,
    }
    await session.commit()
    return photo.variants
