"""Unit test of the ID-document consent gate and bucket choice (`registry.service.create_id_document`).

An ID image is accepted only under this farmer's unrevoked `data_collection` consent, and its presigned PUT
targets the private `id-docs` bucket under `{fpo}/{farmer}/` (B13 review r1 P2-2). A stand-in session and
a captured `storage.presign_put` replace the database and S3.
Serves: D-017 (flag `id_document_capture`), CLAUDE.md §6 (ID documents never public), Stage 0.
Callers: pytest (`make test-unit`); no Docker.
"""

import base64
import uuid
from collections.abc import Iterator
from datetime import UTC, datetime
from types import SimpleNamespace
from typing import Any

import pytest

from agritrace.core import storage
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.enums import ConsentType, Role
from agritrace.core.errors import ValidationFailedError
from agritrace.modules.identity.models import ConsentRecord
from agritrace.modules.registry import service
from agritrace.modules.registry.models import Farmer, IdDocument
from agritrace.modules.registry.schemas import IdDocumentIn

FPO, FARMER, OTHER_FARMER, CONSENT = uuid.uuid4(), uuid.uuid4(), uuid.uuid4(), uuid.uuid4()
OFFICER = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FIELD_OFFICER)
SHA = "ab" * 32


class _Session:
    """Stand-in session: `get` returns the prepared farmer or consent; `add` records rows."""

    def __init__(self, consent: Any) -> None:
        """Prepare the rows.

        Args:
            consent: what `get(ConsentRecord, ...)` returns (None = missing).
        """
        self.consent = consent
        self.added: list[Any] = []

    async def get(self, model: type, _key: Any) -> Any:
        """Answer a primary-key lookup.

        Args:
            model: the ORM class.
            _key: the key (ignored).

        Returns:
            The farmer of this FPO, or the prepared consent.
        """
        if model is Farmer:
            return SimpleNamespace(id=FARMER, fpo_id=FPO, user_id=None)
        assert model is ConsentRecord
        return self.consent

    def add(self, row: Any) -> None:
        """Record a new row.

        Args:
            row: the ORM object.
        """
        self.added.append(row)

    async def flush(self) -> None:
        """Pretend to flush."""


def _consent(**changes: Any) -> SimpleNamespace:
    """A valid consent of FARMER, with some attributes changed.

    Args:
        **changes: attributes to override.

    Returns:
        The stand-in consent row.
    """
    base = {
        "id": CONSENT,
        "farmer_id": FARMER,
        "consent_type": ConsentType.DATA_COLLECTION,
        "revoked_at": None,
    }
    return SimpleNamespace(**(base | changes))


@pytest.fixture
def presigned(monkeypatch: pytest.MonkeyPatch) -> Iterator[list[dict[str, Any]]]:
    """Capture `storage.presign_put` calls instead of signing.

    Args:
        monkeypatch: pytest monkeypatch.

    Returns:
        An iterator yielding the list the calls are appended to.

    Side effects:
        Sets a dev JWT_SECRET so the settings load; clears the settings cache.
    """
    calls: list[dict[str, Any]] = []

    def fake(key: str, content_type: str, sha256: str, expires: int = 900, bucket: str | None = None) -> str:
        """Record the call.

        Args:
            key: object key.
            content_type: MIME type.
            sha256: hex digest.
            expires: lifetime in seconds.
            bucket: target bucket.

        Returns:
            A dummy URL.
        """
        calls.append({"key": key, "content_type": content_type, "sha256": sha256, "bucket": bucket})
        return "https://s3.test/put"

    monkeypatch.setenv("JWT_SECRET", "unit-test-secret")
    get_settings.cache_clear()
    monkeypatch.setattr(storage, "presign_put", fake)
    yield calls
    get_settings.cache_clear()


BODY = IdDocumentIn(doc_type="aadhaar", consent_record_id=CONSENT, content_type="image/jpeg", sha256=SHA)


@pytest.mark.parametrize(
    "consent",
    [
        None,
        _consent(farmer_id=OTHER_FARMER),
        _consent(revoked_at=datetime(2026, 3, 1, tzinfo=UTC)),
        _consent(consent_type=ConsentType.PUBLIC_NAME),
    ],
    ids=["missing", "other_farmer", "revoked", "wrong_type"],
)
async def test_consent_must_be_this_farmers_active_data_collection(
    consent: Any, presigned: list[dict[str, Any]]
) -> None:
    """Missing, another farmer's, revoked or wrong-type consent → 422 `validation_error`, nothing signed.

    Args:
        consent: the stand-in consent.
        presigned: captured presign calls.
    """
    session = _Session(consent)
    with pytest.raises(ValidationFailedError) as err:
        await service.create_id_document(session, OFFICER, FARMER, BODY)  # type: ignore[arg-type]
    assert "consent_record_id" in err.value.details
    assert session.added == [] and presigned == []


async def test_valid_consent_presigns_into_the_id_docs_bucket(presigned: list[dict[str, Any]]) -> None:
    """The row records the consent; the PUT goes to `id-docs` under `{fpo}/{farmer}/`, never `evidence`.

    Args:
        presigned: captured presign calls.
    """
    session = _Session(_consent())
    out = await service.create_id_document(session, OFFICER, FARMER, BODY)  # type: ignore[arg-type]
    [call] = presigned
    assert call["bucket"] == get_settings().s3_bucket_iddocs == "id-docs"
    assert call["key"] == f"{FPO}/{FARMER}/{out.id}.jpeg"
    assert out.headers["x-amz-checksum-sha256"] == base64.b64encode(bytes.fromhex(SHA)).decode()
    [row] = session.added
    assert isinstance(row, IdDocument) and row.consent_record_id == CONSENT and row.object_key == call["key"]
