"""Unit tests of the B14 registry additions, with a stand-in session so no Docker is needed.

Covers: phone masking and that the full phone never reaches `FarmerOut` (D-017 `internal`), the `?fields=`
whitelist from the tenant's field configuration (derived fields hidden with their source) and row trimming,
the `?q=` condition (phone only for a masked-length digit suffix), the reject state machine with its audit
row, membership removal and device revocation (r2 P2-R), the audited phone reveal (`no-store`) and its
FPO-admin-only route, the bbox fallback from plots to GI regions, and who gets `bbox` / another FPO.
Serves: docs/agents/acceptance/B14.md, FR8, FR14, FR53, FR70, PLAN gap analysis "Members".
Callers: pytest (`make test-unit`).
"""

import uuid
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.dialects import postgresql

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_session
from agritrace.core.enums import FarmerStatus, Role
from agritrace.core.errors import FarmerNotPendingError, ValidationFailedError
from agritrace.main import create_app
from agritrace.modules.identity.models import Device, Membership
from agritrace.modules.registry import service
from agritrace.modules.registry.models import Farmer, Fpo
from agritrace.modules.registry.schemas import FarmerReject

FPO = uuid.uuid4()
PHONE = "+919876543210"
ADMIN = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FPO_ADMIN)


def _farmer(status: FarmerStatus = FarmerStatus.PENDING, fpo_id: uuid.UUID = FPO) -> Farmer:
    """Build an in-memory farmer with an account.

    Args:
        status: onboarding status.
        fpo_id: owning FPO.

    Returns:
        A transient `Farmer` with every `FarmerOut` attribute set.
    """
    return Farmer(
        id=uuid.uuid4(), fpo_id=fpo_id, user_id=uuid.uuid4(), code="F00A1B2", name="Muthu", status=status,
        no_smartphone=False,
    )  # fmt: skip


class _Result:
    """Stand-in result of `session.execute`."""

    def __init__(self, rows: list[Any]) -> None:
        """Keep the rows.

        Args:
            rows: rows to return.
        """
        self.rows = rows

    def all(self) -> list[Any]:
        """Return every row.

        Returns:
            The rows.
        """
        return self.rows

    def one_or_none(self) -> Any:
        """Return the first row.

        Returns:
            The first row, or None.
        """
        return self.rows[0] if self.rows else None


class _Session:
    """Stand-in session with prepared answers for get, scalar, scalars and execute; records deletes."""

    def __init__(
        self,
        farmer: Any = None,
        scalar: Any = PHONE,
        results: list[Any] | None = None,
        answers: list[Any] | None = None,
        rows: list[Any] | None = None,
    ):
        """Set the answers.

        Args:
            farmer: what `get` returns (a farmer or an FPO).
            scalar: what `scalar` returns once `answers` is used up (FPO code or phone).
            results: row lists returned by successive `execute` calls; inserts get no rows.
            answers: values returned by the first `scalar` calls, in order.
            rows: what `scalars(...).all()` returns.
        """
        self.farmer, self.scalar_value, self.results = farmer, scalar, list(results or [])
        self.answers, self.rows = list(answers or []), list(rows or [])
        self.statements: list[Any] = []
        self.deleted: list[Any] = []

    async def get(self, *_: Any) -> Farmer | None:
        """Answer a primary-key lookup.

        Args:
            *_: entity and key (ignored).

        Returns:
            The farmer.
        """
        return self.farmer

    async def scalar(self, *_: Any) -> Any:
        """Answer a scalar query.

        Args:
            *_: the statement (ignored).

        Returns:
            The next prepared answer, else the configured value.
        """
        return self.answers.pop(0) if self.answers else self.scalar_value

    async def scalars(self, *_: Any) -> _Result:
        """Answer a row query.

        Args:
            *_: the statement (ignored).

        Returns:
            The prepared rows.
        """
        return _Result(self.rows)

    async def delete(self, obj: Any) -> None:
        """Record a deletion.

        Args:
            obj: the deleted object.
        """
        self.deleted.append(obj)

    async def execute(self, statement: Any, *_: Any) -> _Result:
        """Record a statement and answer the next prepared rows.

        Args:
            statement: the statement.
            *_: parameters (ignored).

        Returns:
            The next prepared result, or an empty one.
        """
        self.statements.append(statement)
        return _Result(self.results.pop(0) if self.results else [])

    async def flush(self) -> None:
        """Do nothing."""

    async def refresh(self, *_: Any) -> None:
        """Do nothing.

        Args:
            *_: the object (ignored).
        """

    async def commit(self) -> None:
        """Do nothing."""


def _audit_rows(session: _Session) -> list[dict[str, Any]]:
    """Read the values of the `audit_log` inserts the session saw.

    Args:
        session: the stand-in session.

    Returns:
        One dict of compiled parameters per audit insert.
    """
    return [
        s.compile(dialect=postgresql.dialect()).params
        for s in session.statements
        if getattr(getattr(s, "table", None), "name", None) == "audit_log"
    ]


def _client(session: _Session, role: Role) -> AsyncClient:
    """In-process client for a caller with `role` in `FPO`, backed by `session`.

    Args:
        session: the stand-in session.
        role: the caller's role.

    Returns:
        HTTP client for the app.
    """
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: CurrentUser(
        user_id=uuid.uuid4(), fpo_id=FPO, role=role
    )
    app.dependency_overrides[get_session] = lambda: session
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test")


@pytest.mark.parametrize(("phone", "masked"), [(PHONE, "XXXXXX3210"), (None, None), ("", None)])
def test_mask_phone(phone: str | None, masked: str | None) -> None:
    """Only the last 4 digits survive.

    Args:
        phone: stored phone.
        masked: expected masked value.
    """
    assert service.mask_phone(phone) == masked


def test_farmer_out_never_carries_the_full_phone() -> None:
    """`FarmerOut` holds `phone_masked`; the number itself appears nowhere in the JSON."""
    out = service.farmer_out(_farmer(), PHONE)
    assert out.phone_masked == "XXXXXX3210"
    assert "9876543210" not in out.model_dump_json()


def test_fields_whitelist_follows_the_tenant(monkeypatch: pytest.MonkeyPatch) -> None:
    """Response fields are allowed, `phone` is not; a field the tenant disables drops out.

    Args:
        monkeypatch: pytest monkeypatch.
    """
    allowed = service.farmer_fields(None)
    assert {"id", "code", "name", "status", "phone_masked", "address_line", "photo_key"} <= allowed
    assert "phone" not in allowed
    assert service.parse_fields(" code, name ", allowed) == {"code", "name"}
    for bad in ("code,phone", ",,"):
        with pytest.raises(ValidationFailedError):
            service.parse_fields(bad, allowed)
    enabled = fieldconfig.fields_for("farmer", None)
    monkeypatch.setattr(
        fieldconfig, "fields_for", lambda *_: [f for f in enabled if f.name != "photo_key"]
    )  # fmt: skip
    assert "photo_key" not in service.farmer_fields("ANY")
    hide = {"address", "phone"}
    monkeypatch.setattr(fieldconfig, "fields_for", lambda *_: [f for f in enabled if f.name not in hide])
    allowed = service.farmer_fields("ANY")
    assert not {"address", "address_line", "phone_masked"} & allowed  # derived fields go with their source


@pytest.mark.parametrize(
    ("q", "phone"), [("3210", True), ("0", True), ("Muthu", False), ("12345", False), ("௧௨", False)]
)
def test_search_matches_phone_only_by_masked_suffix(q: str, phone: bool) -> None:
    """Name and code always; the phone only for 1–4 ASCII digits.

    Args:
        q: search text.
        phone: whether the phone condition is expected.
    """
    sql = str(service.farmer_search(q).compile(dialect=postgresql.dialect()))
    assert "farmers.name" in sql and "farmers.code" in sql
    assert ("users.phone" in sql) is phone


async def test_reject_pending_suspends_drops_membership_and_revokes_devices() -> None:
    """Pending → suspended; the farmer membership is deleted and, with none left, devices are revoked.

    The audit row `farmer.reject` carries the reason, `membership_removed` and `devices_revoked`.
    """
    farmer = _farmer()
    membership = Membership(user_id=farmer.user_id, fpo_id=FPO, role=Role.FARMER)
    device = Device(id=uuid.uuid4(), user_id=farmer.user_id, refresh_token_hash="h", revoked_at=None)
    # scalar answers: the membership, then "no membership left", then the phone for the view
    session = _Session(farmer, answers=[membership, None], rows=[device])
    body = FarmerReject(reason_code="duplicate", reason_text="Same person as F00A1B1")
    out = await service.reject_farmer(session, ADMIN, farmer.id, body)  # type: ignore[arg-type]
    assert out.status == FarmerStatus.SUSPENDED
    assert session.deleted == [membership]
    assert device.revoked_at is not None and device.refresh_token_hash is None
    [row] = _audit_rows(session)
    assert row["action"] == "farmer.reject"
    assert row["entity_id"] == farmer.id and row["actor_user_id"] == ADMIN.user_id
    assert row["diff"] == {
        "reason_code": "duplicate",
        "reason_text": "Same person as F00A1B1",
        "membership_removed": True,
        "devices_revoked": 1,
    }


async def test_reject_keeps_devices_while_another_membership_remains() -> None:
    """A user still in another FPO keeps their devices; only this FPO's farmer membership goes."""
    farmer = _farmer()
    membership = Membership(user_id=farmer.user_id, fpo_id=FPO, role=Role.FARMER)
    device = Device(id=uuid.uuid4(), user_id=farmer.user_id, refresh_token_hash="h", revoked_at=None)
    session = _Session(farmer, answers=[membership, uuid.uuid4()], rows=[device])
    await service.reject_farmer(session, ADMIN, farmer.id, FarmerReject(reason_code="x"))  # type: ignore[arg-type]
    assert session.deleted == [membership]
    assert device.revoked_at is None
    assert _audit_rows(session)[0]["diff"]["devices_revoked"] == 0


@pytest.mark.parametrize("status", [FarmerStatus.ACTIVE, FarmerStatus.SUSPENDED])
async def test_reject_not_pending_is_refused(status: FarmerStatus) -> None:
    """Only a pending farmer can be rejected; nothing is audited otherwise.

    Args:
        status: a non-pending status.
    """
    farmer = _farmer(status)
    session = _Session(farmer)
    with pytest.raises(FarmerNotPendingError):
        await service.reject_farmer(session, ADMIN, farmer.id, FarmerReject(reason_code="x"))  # type: ignore[arg-type]
    assert _audit_rows(session) == []


async def test_reveal_phone_route_admin_only_and_audited() -> None:
    """Field officer → 403; FPO admin → 200 with the number and one audit row; other FPO → 404."""
    farmer = _farmer()
    session = _Session(farmer)
    async with _client(session, Role.FIELD_OFFICER) as client:
        denied = await client.get(f"/v1/farmers/{farmer.id}/phone")
    async with _client(session, Role.FPO_ADMIN) as client:
        shown = await client.get(f"/v1/farmers/{farmer.id}/phone")
    async with _client(_Session(_farmer(fpo_id=uuid.uuid4())), Role.FPO_ADMIN) as client:
        foreign = await client.get(f"/v1/farmers/{farmer.id}/phone")
    assert denied.status_code == 403
    assert shown.status_code == 200 and shown.json() == {"farmer_id": str(farmer.id), "phone": PHONE}
    assert shown.headers["cache-control"] == "no-store"
    assert [r["action"] for r in _audit_rows(session)] == ["farmer.phone_reveal"]
    assert foreign.status_code == 404


async def test_farmer_list_fields_trims_rows_and_masks() -> None:
    """`?fields=code,name` keeps only those keys; the default list shows `phone_masked`, never the phone."""
    farmer = _farmer()
    session = _Session(scalar=None, results=[[(farmer, PHONE)], [(farmer, PHONE)]])
    async with _client(session, Role.FPO_ADMIN) as client:
        lean = await client.get("/v1/farmers", params={"fields": "code,name", "q": "Mu"})
        full = await client.get("/v1/farmers", params={"village_id": str(uuid.uuid4())})
        bad = await client.get("/v1/farmers", params={"fields": "code,phone"})
    assert lean.status_code == 200, lean.text
    assert lean.json() == {
        "items": [{"code": "F00A1B2", "name": "Muthu"}],
        "next_cursor": None,
        "has_more": False,
    }
    assert full.json()["items"][0]["phone_masked"] == "XXXXXX3210"
    assert PHONE not in full.text
    assert bad.status_code == 422 and bad.json()["error"]["code"] == "validation_error"


async def test_bbox_falls_back_to_regions_only_without_plots() -> None:
    """Plots give the frame when there are any; an empty plot extent falls back to the GI regions."""
    with_plots = _Session(results=[[(78.1, 9.5, 78.2, 9.6)]])
    assert await service.fpo_bbox(with_plots, FPO) == [78.1, 9.5, 78.2, 9.6]  # type: ignore[arg-type]
    assert len(with_plots.statements) == 1
    no_plots = _Session(results=[[(None, None, None, None)], [(77.9, 9.3, 78.4, 9.7)]])
    assert await service.fpo_bbox(no_plots, FPO) == [77.9, 9.3, 78.4, 9.7]  # type: ignore[arg-type]
    nothing = _Session(results=[[(None, None, None, None)], [(None, None, None, None)]])
    assert await service.fpo_bbox(nothing, FPO) is None  # type: ignore[arg-type]


@pytest.mark.parametrize(
    ("role", "super_admin", "own", "status", "has_bbox"),
    [
        (Role.FPO_ADMIN, False, True, 200, True),
        (Role.QC_OFFICER, False, True, 200, True),
        (Role.FARMER, False, True, 200, False),
        (Role.VIEWER, False, True, 200, False),
        (Role.FPO_ADMIN, False, False, 404, False),
        (Role.FPO_ADMIN, True, False, 200, True),
    ],
)
async def test_get_fpo_scope_and_bbox_roles(
    role: Role, super_admin: bool, own: bool, status: int, has_bbox: bool
) -> None:
    """Own FPO → 200; another FPO → 404 unless super-admin; `bbox` only for staff and super-admins.

    Args:
        role: the caller's role.
        super_admin: `users.is_super_admin` of the caller.
        own: whether the FPO is the caller's.
        status: expected HTTP status.
        has_bbox: whether `bbox` is expected.
    """
    fpo = Fpo(
        id=FPO if own else uuid.uuid4(), code="T1", name="FPO", kind="fpo", public_show_farmer_names=False
    )
    session = _Session(fpo, scalar=super_admin, results=[[(78.1, 9.5, 78.2, 9.6)]])
    async with _client(session, role) as client:
        response = await client.get(f"/v1/fpos/{fpo.id}")
    assert response.status_code == status, response.text
    if status == 200:
        assert (response.json()["bbox"] == [78.1, 9.5, 78.2, 9.6]) is has_bbox
        assert (response.json()["bbox"] is None) is not has_bbox
