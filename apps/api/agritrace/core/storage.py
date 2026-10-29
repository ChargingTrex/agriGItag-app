"""S3 / MinIO access: presigned evidence uploads, evidence reads, public page writes.

Serves: D-008 (MinIO as S3 stand-in; `evidence` write-once, `public-pages` anonymous read),
D-011 (single presigned PUT per photo with SHA-256), D-007 (static public pages in object storage).
Callers: events service (presign, head, read photos; B06), publishing service (put_public; B10),
`agritrace.main` health check (`client`), tests/integration/test_storage.py.
"""

import base64
from functools import lru_cache
from typing import Any

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

from agritrace.core.config import get_settings


@lru_cache
def client() -> Any:
    """Create the process-wide S3 client.

    Returns:
        A boto3 S3 client for `S3_ENDPOINT` using SigV4 and path-style URLs (MinIO needs path style).

    Raises:
        botocore.exceptions.BotoCoreError: invalid endpoint or credentials configuration.
    """
    s = get_settings()
    return boto3.client(
        "s3",
        endpoint_url=s.s3_endpoint,
        aws_access_key_id=s.s3_access_key,
        aws_secret_access_key=s.s3_secret_key,
        region_name="us-east-1",  # MinIO's default; AWS prod sets the real region via the endpoint
        config=Config(signature_version="s3v4", s3={"addressing_style": "path"}, connect_timeout=3),
    )


def presign_put(key: str, content_type: str, sha256: str, expires: int = 900) -> str:
    """Presign a single PUT of an evidence photo that S3 accepts only if the bytes match `sha256`.

    The client must send headers `Content-Type: <content_type>` and
    `x-amz-checksum-sha256: <base64 of the digest>`; S3 rejects the upload on a mismatch.

    Args:
        key: object key inside the evidence bucket.
        content_type: MIME type the client will send, e.g. `image/jpeg`.
        sha256: hex SHA-256 of the file, as computed on the phone.
        expires: URL lifetime in seconds.

    Returns:
        The presigned URL.

    Raises:
        ValueError: `sha256` is not valid hex.
    """
    checksum = base64.b64encode(bytes.fromhex(sha256)).decode()
    url: str = client().generate_presigned_url(
        "put_object",
        Params={
            "Bucket": get_settings().s3_bucket_evidence,
            "Key": key,
            "ContentType": content_type,
            "ChecksumSHA256": checksum,
        },
        ExpiresIn=expires,
    )
    return url


def head(key: str) -> dict[str, Any] | None:
    """Read an evidence object's metadata without downloading it.

    Args:
        key: object key inside the evidence bucket.

    Returns:
        The S3 HEAD response (ContentLength, ContentType, ETag, ...) or None when the object does not exist.

    Raises:
        botocore.exceptions.ClientError: any S3 error other than not-found.
    """
    try:
        meta: dict[str, Any] = client().head_object(Bucket=get_settings().s3_bucket_evidence, Key=key)
    except ClientError as e:
        if e.response["Error"]["Code"] in ("404", "NoSuchKey", "NotFound"):
            return None
        raise
    return meta


def get_stream(key: str) -> Any:
    """Open an evidence object for streaming.

    Args:
        key: object key inside the evidence bucket.

    Returns:
        botocore `StreamingBody`; the caller reads it and closes it.

    Raises:
        botocore.exceptions.ClientError: the object does not exist (`NoSuchKey`) or S3 refused.
    """
    return client().get_object(Bucket=get_settings().s3_bucket_evidence, Key=key)["Body"]


def put_public(key: str, body: bytes, content_type: str, cache_control: str) -> None:
    """Write one public page asset to the anonymous-read bucket.

    Args:
        key: object key inside the public-pages bucket, e.g. `b/FGP8T4033HM7/index.html`.
        body: file content.
        content_type: MIME type served to browsers.
        cache_control: `Cache-Control` header the CDN and browsers honour.

    Raises:
        botocore.exceptions.ClientError: S3 refused the write.

    Side effects:
        Creates a new object version in the public-pages bucket (versioning is on, D-008).
    """
    client().put_object(
        Bucket=get_settings().s3_bucket_public,
        Key=key,
        Body=body,
        ContentType=content_type,
        CacheControl=cache_control,
    )
