"""Unit tests of the config routes (ETag, tenant from token) and of the feature-gated registry routes.

Covers B13 acceptance "enabling `id_document_capture` exposes the upload endpoint, disabled → 404" (and the
same for producer groups), `GET /v1/config/fields` hiding a field disabled for the caller's FPO only, 304 on
a matching `If-None-Match`, and 413 `import_too_large` before any database work. A stand-in session answers
the one FPO-code read, so no Docker is needed.
Serves: D-017, PLAN "Gap analysis". Callers: pytest (`make test-unit`).
"""

import shutil
import uuid
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import Role
from agritrace.main import create_app
from agritrace.modules.registry import imports

DEMO = "VIRUDHAI_SCFC_VINOBA_BHAVA_FPO"
GATED = "GATED_FPO"


class _Rows:
    """Stand-in result of `session.scalars`: no rows."""

    def all(self) -> list[Any]:
        """Return the rows.

        Returns:
            An empty list.
        """
        return []


class _Session:
    """Stand-in session: the FPO-code read answers `code`; lookups find nothing."""

    def __init__(self, code: str | None) -> None:
        """Remember the FPO code to answer.

        Args:
            code: FPO code returned by every `scalar` call.
        """
        self.code = code

    async def scalar(self, *_: Any) -> str | None:
        """Answer a scalar query.

        Args:
            *_: the statement (ignored).

        Returns:
            The FPO code.
        """
        return self.code

    async def scalars(self, *_: Any) -> _Rows:
        """Answer a row query.

        Args:
            *_: the statement (ignored).

        Returns:
            No rows.
        """
        return _Rows()

    async def get(self, *_: Any) -> None:
        """Answer a primary-key lookup.

        Args:
            *_: entity and key (ignored).

        Returns:
            None (not found).
        """
        return None


def _client(code: str | None, role: Role = Role.FPO_ADMIN) -> AsyncClient:
    """In-process client whose caller has `role` in an FPO whose code is `code`.

    Args:
        code: the caller's FPO code.
        role: the caller's role.

    Returns:
        HTTP client for the app.
    """
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: CurrentUser(
        user_id=uuid.uuid4(), fpo_id=uuid.uuid4(), role=role
    )
    app.dependency_overrides[get_session] = lambda: _Session(code)
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test")


@pytest.fixture
def gated_tenant(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Add a tenant file `GATED_FPO.yaml` switching on ID capture and producer groups.

    Args:
        tmp_path: pytest temporary folder.
        monkeypatch: pytest monkeypatch.

    Returns:
        An iterator yielding once.

    Side effects:
        Points `fieldconfig.CONFIG_DIR` at a copy with the extra tenant; clears the load cache around it.
    """
    target = tmp_path / "config"
    shutil.copytree(fieldconfig.CONFIG_DIR, target)
    (target / "tenants" / f"{GATED}.yaml").write_text(
        f"fpo_code: {GATED}\nfeatures:\n  id_document_capture: true\n  producer_groups: true\n"
    )
    monkeypatch.setattr(fieldconfig, "CONFIG_DIR", target)
    fieldconfig.load.cache_clear()
    yield
    fieldconfig.load.cache_clear()


async def test_config_fields_follow_the_callers_tenant_with_etag() -> None:
    """Demo FPO: soil type hidden; other FPO: shown; same ETag → 304; unknown entity → 422."""
    async with _client(DEMO) as client:
        demo = await client.get("/v1/config/fields", params={"entity": "plot"})
        again = await client.get(
            "/v1/config/fields", params={"entity": "plot"}, headers={"If-None-Match": demo.headers["etag"]}
        )
        unknown = await client.get("/v1/config/fields", params={"entity": "plots"})
        everything = await client.get("/v1/config/fields")
    async with _client("OTHER_FPO") as client:
        other = await client.get("/v1/config/fields", params={"entity": "plot"})
    assert demo.status_code == 200
    assert "soil_type" not in [f["name"] for f in demo.json()["plot"]]
    assert "soil_type" in [f["name"] for f in other.json()["plot"]]
    assert demo.headers["etag"] != other.headers["etag"]
    assert again.status_code == 304
    assert unknown.status_code == 422
    assert unknown.json()["error"]["code"] == "validation_error"
    assert {"farmer", "event_harvest", "village"} <= set(everything.json())


async def test_config_features() -> None:
    """Defaults for an FPO without a tenant file, with an ETag."""
    async with _client("OTHER_FPO", Role.FARMER) as client:
        response = await client.get("/v1/config/features")
    assert response.status_code == 200
    assert response.json()["id_document_capture"] is False
    assert response.json()["sync_push_max_entries"] == 50
    assert response.json()["grading_loss_warn_pct"] == 15
    assert response.headers["etag"]


ID_DOC = {"doc_type": "aadhaar", "consent_record_id": str(uuid.uuid4()), "content_type": "image/jpeg",
          "sha256": "a" * 64}  # fmt: skip


async def test_flagged_routes_are_404_feature_disabled_when_off() -> None:
    """Flags off (defaults): every gated route answers 404 `feature_disabled`, even for an FPO admin."""
    async with _client(DEMO) as client:
        responses = [
            await client.post(f"/v1/farmers/{uuid.uuid4()}/id-documents", json=ID_DOC),
            await client.get("/v1/producer-groups"),
            await client.post("/v1/producer-groups", json={"name": "Mahalir SHG"}),
        ]
    assert [r.status_code for r in responses] == [404, 404, 404]
    assert {r.json()["error"]["code"] for r in responses} == {"feature_disabled"}


async def test_flagged_routes_are_exposed_when_on(gated_tenant: None) -> None:
    """Flags on for the tenant: the routes run (unknown farmer → plain `not_found`; empty group list).

    Args:
        gated_tenant: tenant file switching both flags on.
    """
    async with _client(GATED, Role.FIELD_OFFICER) as client:
        upload = await client.post(f"/v1/farmers/{uuid.uuid4()}/id-documents", json=ID_DOC)
        groups = await client.get("/v1/producer-groups")
        create = await client.post("/v1/producer-groups", json={"name": "Mahalir SHG"})
    assert upload.status_code == 404
    assert upload.json()["error"]["code"] == "not_found"
    assert groups.status_code == 200
    assert groups.json() == []
    assert create.status_code == 403  # route exists; creating groups is for the FPO admin


async def test_import_over_2_mb_is_413_before_any_row_work() -> None:
    """A file over the limit is refused with `import_too_large`."""
    big = b"name_en,category,unit\n" + b"x" * (imports.MAX_BYTES + 1)
    async with _client(DEMO) as client:
        response = await client.post("/v1/imports/inputs", files={"file": ("inputs.csv", big, "text/csv")})
        denied = await client.post(
            "/v1/imports/villages", files={"file": ("v.csv", b"lgd_code\n1\n", "text/csv")}
        )
    assert response.status_code == 413
    assert response.json()["error"]["code"] == "import_too_large"
    assert denied.status_code == 403  # villages are global: super-admin only


async def test_import_template_matches_config_fields() -> None:
    """The template header is the tenant's enabled CSV columns (P08: template matches /config/fields)."""
    async with _client(DEMO) as client:
        template = await client.get("/v1/imports/farmers/template.csv")
        fields = await client.get("/v1/config/fields", params={"entity": "farmer"})
    assert template.status_code == 200
    assert template.headers["content-type"].startswith("text/csv")
    header = template.text.strip().split(",")
    assert header[-1] == "village_lgd_code"
    assert set(header[:-1]) <= {f["name"] for f in fields.json()["farmer"]}
    assert "photo_key" not in header and "address" not in header
