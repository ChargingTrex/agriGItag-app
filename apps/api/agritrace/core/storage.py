"""S3 access (LocalStack locally, AWS in prod): presigned evidence uploads, evidence reads, public pages.

Serves: D-008 (local S3 stand-in; `evidence` write-once, `public-pages` anonymous read),
D-011 (single presigned PUT per photo with SHA-256), D-007 (static public pages in object storage).
Callers: events service (presign, head, read photos; B06), events evidence (`presign_get` for variant URLs in
the lot timeline and `/sync/pull`; B07), publishing service (put_public; photo copies and the page proxy
via `client`; B10),
`agritrace.main` health check (`client`), registry ID documents (presign into id-docs; B13),
tests/integration/test_storage.py.
"""

import base64
from functools import lru_cache
from typing import Any

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

from agritrace.core.config import get_settings


@lru_cache
def _client_for(endpoint: str) -> Any:
    """Create one cached S3 client per endpoint.

    Args:
        endpoint: S3 endpoint URL.

    Returns:
        A boto3 S3 client using SigV4 and path-style URLs (LocalStack and the compose host names need
        path style; bucket-subdomain DNS does not exist locally).

    Raises:
        botocore.exceptions.BotoCoreError: invalid endpoint or credentials configuration.
    """
    s = get_settings()
    return boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=s.s3_access_key,
        aws_secret_access_key=s.s3_secret_key,
        region_name=s.s3_region,
        # Short timeouts, 2 retries (3 attempts): a hung S3 must not pin threads (health probe, presign, head
        # run in the default executor) for botocore's default 60 s read timeout x 5 legacy attempts.
        config=Config(
            signature_version="s3v4",
            s3={"addressing_style": "path"},
            connect_timeout=3,
            read_timeout=10,
            retries={"max_attempts": 2, "mode": "standard"},
        ),
    )


def client() -> Any:
    """Return the S3 client the API and worker use to talk to storage (`S3_ENDPOINT`).

    Returns:
        The cached boto3 S3 client.
    """
    return _client_for(get_settings().s3_endpoint)


def presign_put(
    key: str,
    content_type: str,
    sha256: str,
    expires: int = 900,
    bucket: str | None = None,
    size_bytes: int | None = None,
) -> str:
    """Presign a single PUT of a file that S3 accepts only if the bytes match `sha256` (and `size_bytes`).

    The client must send headers `Content-Type: <content_type>` and
    `x-amz-checksum-sha256: <base64 of the digest>`; S3 rejects the upload on a mismatch. With `size_bytes`
    the `Content-Length` is signed too, so S3 refuses a body of any other length (B18, audit waves 3-6 #4).

    Args:
        key: object key inside the evidence bucket.
        content_type: MIME type the client will send, e.g. `image/jpeg`.
        sha256: hex SHA-256 of the file, as computed on the phone.
        expires: URL lifetime in seconds.
        bucket: target bucket; default the evidence bucket (ID documents pass `S3_BUCKET_IDDOCS`).
        size_bytes: the declared length to sign as `Content-Length`; None leaves the length unsigned.

    Returns:
        The presigned URL on `S3_PUBLIC_ENDPOINT`, the host the phone can reach (signing needs no network).

    Raises:
        ValueError: `sha256` is not 64 hex characters (a 32-byte SHA-256 digest).
    """
    digest = bytes.fromhex(sha256)
    if len(digest) != 32:
        raise ValueError("sha256 must be 64 hex characters")
    checksum = base64.b64encode(digest).decode()
    params = {
        "Bucket": bucket or get_settings().s3_bucket_evidence,
        "Key": key,
        "ContentType": content_type,
        "ChecksumSHA256": checksum,
    }
    if size_bytes is not None:
        params["ContentLength"] = size_bytes
    url: str = _client_for(get_settings().s3_public_endpoint).generate_presigned_url(
        "put_object", Params=params, ExpiresIn=expires
    )
    return url


def presign_get(key: str, expires: int) -> str:
    """Presign a GET of an evidence object, so phones and the portal can show it without S3 credentials.

    Args:
        key: object key inside the evidence bucket.
        expires: URL lifetime in seconds.

    Returns:
        The presigned URL on `S3_PUBLIC_ENDPOINT` (signing needs no network).
    """
    url: str = _client_for(get_settings().s3_public_endpoint).generate_presigned_url(
        "get_object",
        Params={"Bucket": get_settings().s3_bucket_evidence, "Key": key},
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
        key: object key inside the public-pages bucket, e.g. `batches/FGP8T4033HM7/index.html`.
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
