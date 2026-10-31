"""publishing service: build and store a batch's static public page, its QR code and its labels.

Serves: FR12 (QR on the pack), FR15-FR17 (public page regenerated on rebuild, last-updated stamp,
generation marker), FR62 (labels carry pack and best-before dates, FSSAI number), plan §13 E3 (cache
headers; CDN invalidation), Dataflow Stage 10, D-007 (static page in object storage, built by a worker
job), D-009 (idempotent task), CLAUDE.md §6.
Callers: `publishing.router`, `publishing.tasks.build_page`, `lots_batches.router` (`qr_png` for the lot QR);
tests/unit/test_publishing_builder.py, tests/integration/test_publishing.py.
"""

import asyncio
import json
import logging
import uuid
from io import BytesIO

import boto3
import qrcode
from agritrace_page import RenderResult, render
from botocore.exceptions import ClientError
from PIL import Image, ImageDraw, ImageFont
from pydantic import ValidationError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import storage
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.enums import BatchStatus
from agritrace.core.errors import GateNotMetError, NotFoundError, PublicRecordInvalidError
from agritrace.core.schemas import Page
from agritrace.core.time import utcnow
from agritrace.modules.lots_batches import service as lots_service
from agritrace.modules.lots_batches.models import Batch
from agritrace.modules.publishing import builder
from agritrace.modules.publishing.models import PageBuild
from agritrace.modules.publishing.schemas import BuildOut
from agritrace.modules.registry.models import Crop, Fpo, Processor

__all__ = ["qr_png"]

log = logging.getLogger(__name__)

# DECISION D-034: index.html and data.json are re-fetched within a minute; content-addressed photo copies and
#   the QR (a pure function of the batch code) are cached for a year (plan §13 E3).
#   ADV: a rebuilt page reaches buyers within 60 s even without a CDN invalidation; assets cost one fetch.
#   COMPROMISE: a phone may show the previous page for up to 60 s after a rebuild.
PAGE_CACHE = "public, max-age=60"
IMMUTABLE = "public, max-age=31536000, immutable"


def public_url(code: str) -> str:
    """Build the URL printed in a batch's QR code (FR12).

    Args:
        code: the batch code.

    Returns:
        `{PUBLIC_BASE_URL}/b/<code>`.
    """
    return f"{get_settings().public_base_url.rstrip('/')}/b/{code}"


def qr_png(text: str) -> bytes:
    """Encode text as a QR code image.

    Args:
        text: what the code says, e.g. a page URL or a lot code.

    Returns:
        PNG bytes (black on white, 4-module quiet zone, error correction M).
    """
    buf = BytesIO()
    qrcode.make(text).save(buf)
    return buf.getvalue()


def labels_pdf(lines: list[str], url: str) -> bytes:
    """Draw an A4 sheet of eight identical pack labels: QR code plus label text (FR12, FR62).

    Args:
        lines: label text, one entry per line (English; Latin script only).
        url: what the QR code encodes.

    Returns:
        PDF bytes: one A4 page at 150 dpi, 2 x 4 labels of 4 x 2.8 inches.
    """
    # DECISION D-034: labels are drawn with Pillow (already a dependency) and saved as PDF, not reportlab.
    #   ADV: no new library for one fixed sheet layout (CLAUDE.md §4 rule 4).
    #   COMPROMISE: raster PDF and the default font only, so no Tamil text on the label (TODO.md B10).
    page = Image.new("RGB", (1240, 1754), "white")
    draw = ImageDraw.Draw(page)
    font = ImageFont.load_default(size=26)
    qr = qrcode.make(url, box_size=6, border=2).get_image().convert("RGB")
    for n in range(8):
        x, y = 30 + (n % 2) * 600, 40 + (n // 2) * 420
        draw.rectangle((x, y, x + 590, y + 400), outline="black")
        page.paste(qr, (x + 10, y + 10))
        for i, text in enumerate(lines):
            draw.text((x + qr.width + 20, y + 20 + i * 40), text, fill="black", font=font)
    buf = BytesIO()
    page.save(buf, "PDF", resolution=150)
    return buf.getvalue()


async def _batch_in_scope(
    session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID, lock: bool = False
) -> Batch:
    """Load a batch of the caller's FPO.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.
        lock: hold a row lock until commit, so two rebuilds cannot draw the same build number.

    Returns:
        The batch.

    Raises:
        NotFoundError: no such batch in the caller's FPO (404).
    """
    batch = await session.get(Batch, batch_id, with_for_update=lock)
    if batch is None or batch.fpo_id != user.fpo_id:
        raise NotFoundError(details={"batch_id": str(batch_id)})
    return batch


def build_out(build: PageBuild) -> BuildOut:
    """Render a build row for the API.

    Args:
        build: the row.

    Returns:
        The response model; `error` comes from the snapshot of a failed build.
    """
    return BuildOut(
        id=build.id,
        batch_id=build.batch_id,
        build_no=build.build_no,
        generation=build.generation,
        status=build.status,
        trigger=build.trigger,
        built_at=build.built_at,
        html_key=build.html_key,
        json_key=build.json_key,
        qr_key=build.qr_key,
        error=build.snapshot.get("error") if build.status == "failed" else None,
    )


async def rebuild(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> PageBuild:
    """Queue a new build of a published batch's page, e.g. after a correction (FR15).

    Args:
        session: database session.
        user: the FPO admin.
        batch_id: the batch.

    Returns:
        The new `queued` build (flushed), numbered `current_build_no + 1`.

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) with reason `not_published`: publish the batch first.

    Side effects:
        Locks the batch row, bumps `current_build_no`, inserts a `page_builds` row (trigger `rebuild`); every
        earlier build row stays as it was (append-only history); flushes.
    """
    batch = await _batch_in_scope(session, user, batch_id, lock=True)
    if batch.status != BatchStatus.PUBLISHED:
        reason = lots_service.reason(
            "not_published", "Publish the batch first: POST /v1/batches/{id}/publish."
        )
        raise GateNotMetError(details={"reasons": [reason]})
    batch.current_build_no += 1
    build = PageBuild(
        batch_id=batch.id,
        build_no=batch.current_build_no,
        generation=batch.current_build_no,
        snapshot={},
        status="queued",
        trigger="rebuild",
    )
    session.add(build)
    await session.flush()
    return build


async def list_builds(
    session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID, cursor: uuid.UUID | None, limit: int
) -> Page[BuildOut]:
    """List a batch's page builds, oldest first.

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.
        cursor: id of the last build of the previous page, or None.
        limit: page size.

    Returns:
        One page of builds.

    Raises:
        NotFoundError: not in the caller's FPO (404).
    """
    await _batch_in_scope(session, user, batch_id)
    query = select(PageBuild).where(PageBuild.batch_id == batch_id)
    if cursor is not None:
        query = query.where(PageBuild.id > cursor)
    rows = list((await session.scalars(query.order_by(PageBuild.id).limit(limit + 1))).all())
    more = len(rows) > limit
    rows = rows[:limit]
    return Page(
        items=[build_out(b) for b in rows], next_cursor=str(rows[-1].id) if more else None, has_more=more
    )


def _write(code: str, page: RenderResult, qr: bytes, copies: list[tuple[str, str]]) -> dict[str, str]:
    """Write one build's objects to the public-pages bucket.

    Args:
        code: the batch code.
        page: the rendered page and data file.
        qr: QR PNG bytes.
        copies: `(evidence key, public key)` pairs of photo variants to copy.

    Returns:
        Keys by kind: `html`, `json`, `qr`.

    Raises:
        botocore.exceptions.ClientError: S3 refused a copy or write.

    Side effects:
        Adds a new object version for every key (bucket versioning keeps the previous build's objects, D-008).
        index.html is written last, so a page never points at a photo that is not there yet.
    """
    s = get_settings()
    for src, dst in copies:
        storage.client().copy_object(
            Bucket=s.s3_bucket_public,
            Key=dst,
            CopySource={"Bucket": s.s3_bucket_evidence, "Key": src},
            ContentType="image/webp",
            CacheControl=IMMUTABLE,
            MetadataDirective="REPLACE",
        )
    keys = {
        k: f"batches/{code}/{name}"
        for k, name in (("qr", "qr.png"), ("json", "data.json"), ("html", "index.html"))
    }
    storage.put_public(keys["qr"], qr, "image/png", IMMUTABLE)
    storage.put_public(keys["json"], page.data_json.encode(), "application/json", PAGE_CACHE)
    storage.put_public(keys["html"], page.html.encode(), "text/html; charset=utf-8", PAGE_CACHE)
    return keys


def _invalidate(code: str, build_no: int) -> None:
    """Ask the CDN to drop its cached copy of a batch page (plan §13 E3); a no-op without a CDN (local).

    Args:
        code: the batch code.
        build_no: the build, used as the idempotent caller reference.

    Raises:
        botocore.exceptions.ClientError: CloudFront refused the request.

    Side effects:
        One CloudFront `CreateInvalidation` for `/b/<code>*` when `CLOUDFRONT_DISTRIBUTION_ID` is set.
    """
    if distribution := get_settings().cloudfront_distribution_id:
        boto3.client("cloudfront").create_invalidation(
            DistributionId=distribution,
            InvalidationBatch={
                "Paths": {"Quantity": 1, "Items": [f"/b/{code}*"]},
                "CallerReference": f"{code}-{build_no}",
            },
        )


async def build_page(session: AsyncSession, page_build_id: uuid.UUID) -> PageBuild | None:
    """Build one queued page: snapshot, render, privacy check, write to S3 (task `publishing.build_page`).

    Args:
        session: database session (committed here).
        page_build_id: the `page_builds` row.

    Returns:
        The build row, or None for an unknown id. A build already done, or older than the latest build,
        is not rebuilt (status stays `built`, or becomes `superseded`).

    Raises:
        PublicRecordInvalidError: `public_record_invalid` when the renderer's allow-list or privacy check
            refuses the record; the row is `failed` with the reasons (paths, never values) before raising.
        botocore.exceptions.ClientError: S3 or CloudFront refused; the row stays `queued` for a retry.
        KeyError: a page label is missing (renderer bug).

    Side effects:
        Copies photo variants and writes `batches/<code>/{index.html,data.json,qr.png}` to public-pages; sets
        `snapshot`, the keys, `status` and `built_at`; commits; invalidates the CDN path.
    """
    build = await session.get(PageBuild, page_build_id)
    if build is None:
        return None
    batch = await session.get(Batch, build.batch_id)
    assert batch is not None  # foreign key
    # A duplicate delivery (D-009) or a delayed older build must never overwrite the latest page.
    if build.status != "queued" or build.build_no < batch.current_build_no:
        if build.status == "queued":
            build.status = "superseded"
            await session.commit()
        return build
    rows = await builder.load(session, batch)
    record = builder.assemble(rows, build, utcnow())
    try:
        page = render(record)
    except ValidationError as exc:
        errors = [
            {"loc": list(e["loc"]), "msg": e["msg"], "type": e["type"]}
            for e in exc.errors(include_input=False)
        ]
        build.status, build.snapshot = (
            "failed",
            {"error": {"code": PublicRecordInvalidError.code, "details": errors}},
        )
        await session.commit()
        raise PublicRecordInvalidError(details=errors) from exc
    copies = [
        pair
        for photos in rows.photos.values()
        for p in photos
        for pair in builder.photo_copies(p, batch.code)
    ]
    keys = await asyncio.to_thread(_write, batch.code, page, qr_png(public_url(batch.code)), copies)
    build.snapshot = json.loads(page.data_json)
    build.html_key, build.json_key, build.qr_key = keys["html"], keys["json"], keys["qr"]
    build.status, build.built_at = "built", utcnow()
    await session.commit()
    await asyncio.to_thread(_invalidate, batch.code, build.build_no)
    log.info("built public page %s build %s", batch.code, build.build_no)
    return build


async def labels(session: AsyncSession, user: CurrentUser, batch_id: uuid.UUID) -> bytes:
    """Make the pack label sheet of a packed batch (FR12, FR62).

    Args:
        session: database session.
        user: the caller.
        batch_id: the batch.

    Returns:
        PDF bytes (see `labels_pdf`).

    Raises:
        NotFoundError: not in the caller's FPO (404).
        GateNotMetError: `gate_not_met` (409) with reason `final_packing_missing`: no pack date yet.
    """
    batch = await _batch_in_scope(session, user, batch_id)
    if batch.pack_date is None or batch.best_before_date is None:
        reason = lots_service.reason("final_packing_missing", "Final packing has not been signed off.")
        raise GateNotMetError(details={"reasons": [reason]})
    crop, processor, fpo = (
        await session.get(Crop, batch.crop_id),
        await session.get(Processor, batch.processor_id),
        await session.get(Fpo, batch.fpo_id),
    )
    fssai = (processor and processor.fssai_no) or (fpo and fpo.fssai_no)
    lines = [
        crop.name_en if crop else "",
        f"Batch {batch.code}",
        f"Net {batch.packed_kg.normalize():f} kg" if batch.packed_kg is not None else "",
        f"Packed {batch.pack_date:%d %b %Y}",
        f"Best before {batch.best_before_date:%d %b %Y}",
        f"FSSAI {fssai}" if fssai else "",
    ]
    return labels_pdf([line for line in lines if line], public_url(batch.code))


def page_html(code: str) -> tuple[bytes, str]:
    """Read the latest built page of a batch from public-pages (dev proxy; production serves S3 via the CDN).

    Args:
        code: the batch code (validated by the route).

    Returns:
        `(index.html bytes, its Cache-Control)`.

    Raises:
        NotFoundError: in production, or no page has been built for this code (404).
        botocore.exceptions.ClientError: any other S3 error.
    """
    s = get_settings()
    if s.env == "prod":
        raise NotFoundError()
    try:
        obj = storage.client().get_object(Bucket=s.s3_bucket_public, Key=f"batches/{code}/index.html")
    except ClientError as e:
        if e.response["Error"]["Code"] in ("404", "NoSuchKey", "NotFound"):
            raise NotFoundError(details={"code": code}) from e
        raise
    return obj["Body"].read(), obj.get("CacheControl", PAGE_CACHE)
