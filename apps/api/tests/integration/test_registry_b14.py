"""Integration tests of the B14 registry additions on a real database (PostGIS).

One test per acceptance line of docs/agents/acceptance/B14.md: masked phone and the audited reveal (403 /
200 + one audit row / 404), reject with reason and 409 `farmer_not_pending`, a farmer's plot list with
`gi_tag_id`, `?village_id=` / `?q=` / `?fields=` on the farmer list, and `bbox` on GET /v1/fpos/{id}
(plots, else the GI region); round 2 (review B14-r1 P2-R): a rejected farmer's old token gets 401 and a
new OTP sign-in gets 403 `account_inactive`.
Serves: FR8, FR14, FR53, FR70, PLAN gap analysis "Members", D-017, D-020.
Callers: pytest (`make test`); needs Docker (PostGIS, Valkey, LocalStack from tests/conftest.py `stack`).
Reuses the seeding fixtures and helpers of test_registry.py (same folder, imported by module name).
"""

import secrets
import uuid
from datetime import timedelta
from typing import Any

import pytest
import test_registry
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from test_registry import REFERENCE, Caller, _as, _farmer, _plot, _region

from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import Role
from agritrace.core.time import utcnow
from agritrace.main import create_app
from agritrace.modules.identity.models import OtpChallenge
from agritrace.modules.identity.service import hash_otp
from agritrace.modules.registry.models import Village

pytestmark = pytest.mark.integration
ids, api = test_registry.ids, test_registry.api  # the seeding fixtures, shared with B03's tests


def _phone() -> str:
    """Make a fresh Indian mobile number, so reruns do not clash.

    Returns:
        E.164 phone.
    """
    return f"+9198{secrets.randbelow(10**8):08d}"


async def _audit(entity_id: str, action: str) -> list[Any]:
    """Read the audit rows of one action on one farmer.

    Args:
        entity_id: the farmer id.
        action: e.g. `farmer.reject`.

    Returns:
        The `diff` of each matching row.
    """
    async with get_sessionmaker()() as s:
        rows = await s.execute(
            text("SELECT diff FROM audit_log WHERE entity_id = :id AND action = :action"),
            {"id": uuid.UUID(entity_id), "action": action},
        )
        return [r.diff for r in rows]


async def test_phone_masked_and_audited_reveal(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """List shows `phone_masked`, never the phone; reveal: officer 403, admin 200 + one audit row, FPO B 404.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    phone = _phone()
    farmer = await _farmer(client, caller, ids, phone=phone)
    listed = await client.get("/v1/farmers", params={"limit": 200})
    assert phone not in listed.text
    [row] = [f for f in listed.json()["items"] if f["id"] == farmer["id"]]
    assert row["phone_masked"] == "XXXXXX" + phone[-4:]
    _as(caller, ids, "officer_a", "fpo_a", Role.FIELD_OFFICER)
    assert (await client.get(f"/v1/farmers/{farmer['id']}/phone")).status_code == 403
    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    shown = await client.get(f"/v1/farmers/{farmer['id']}/phone")
    assert shown.status_code == 200
    assert shown.json()["phone"] == phone
    assert len(await _audit(farmer["id"], "farmer.phone_reveal")) == 1
    _as(caller, ids, "admin_b", "fpo_b", Role.FPO_ADMIN)
    assert (await client.get(f"/v1/farmers/{farmer['id']}/phone")).status_code == 404


async def test_reject_pending_and_refuse_active(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """Reject a pending farmer → suspended with an audit reason; reject an active farmer → 409.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    pending = await _farmer(client, caller, ids)
    body = {"reason_code": "duplicate", "reason_text": "Registered twice"}
    rejected = await client.post(f"/v1/farmers/{pending['id']}/reject", json=body)
    assert rejected.status_code == 200, rejected.text
    assert rejected.json()["status"] == "suspended"
    # Registered without a phone, so there is no account whose membership or devices reject could end.
    assert await _audit(pending["id"], "farmer.reject") == [
        {**body, "devices_revoked": 0, "membership_removed": False}
    ]
    active = await _farmer(client, caller, ids)
    assert (await client.post(f"/v1/farmers/{active['id']}/approve")).status_code == 200
    again = await client.post(f"/v1/farmers/{active['id']}/reject", json=body)
    assert again.status_code == 409
    assert again.json()["error"]["code"] == "farmer_not_pending"


async def test_farmer_plots_only_that_farmer(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """GET /v1/farmers/{id}/plots lists only that farmer's plots, each with `gi_tag_id`.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    await _region(client, caller, ids)
    mine = await _farmer(client, caller, ids)
    other = await _farmer(client, caller, ids)
    for owner in (mine, mine, other):
        assert (await client.post("/v1/plots", json=_plot(owner["id"], ids, REFERENCE))).status_code == 201
    page = await client.get(f"/v1/farmers/{mine['id']}/plots")
    assert page.status_code == 200
    items = page.json()["items"]
    assert len(items) == 2
    assert {p["farmer_id"] for p in items} == {mine["id"]}
    assert {p["gi_tag_id"] for p in items} == {str(ids["gi_tag"])}


async def test_farmer_list_village_q_and_fields(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """`?village_id=` and `?q=` filter on the server; `?fields=code,name` trims the rows.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    async with get_sessionmaker()() as s:
        village = Village(name_en=f"V{secrets.token_hex(3)}", district="Virudhunagar", state="Tamil Nadu")
        s.add(village)
        await s.commit()
    name = f"Selvi{secrets.token_hex(3)}"
    phone = _phone()
    here = await _farmer(client, caller, ids, name=name, village_id=str(village.id), phone=phone)
    await _farmer(client, caller, ids, name=name)
    by_village = await client.get("/v1/farmers", params={"village_id": str(village.id)})
    assert [f["id"] for f in by_village.json()["items"]] == [here["id"]]
    assert len((await client.get("/v1/farmers", params={"q": name.lower()})).json()["items"]) == 2
    by_code = await client.get("/v1/farmers", params={"q": here["code"]})
    assert here["id"] in [f["id"] for f in by_code.json()["items"]]
    by_suffix = await client.get("/v1/farmers", params={"q": phone[-4:], "limit": 200})
    assert here["id"] in [f["id"] for f in by_suffix.json()["items"]]
    lean = await client.get("/v1/farmers", params={"village_id": str(village.id), "fields": "code,name"})
    assert lean.json()["items"] == [{"code": here["code"], "name": name}]


async def test_fpo_bbox(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """GET /v1/fpos/{id} carries `bbox` from the plots, or from the GI region when the FPO has none.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    await _region(client, caller, ids)
    farmer = await _farmer(client, caller, ids)
    assert (await client.post("/v1/plots", json=_plot(farmer["id"], ids, REFERENCE))).status_code == 201
    own = await client.get(f"/v1/fpos/{ids['fpo_a']}")
    assert own.status_code == 200
    min_lon, min_lat, max_lon, max_lat = own.json()["bbox"]
    assert min_lon <= REFERENCE["lon"] <= max_lon and min_lat <= REFERENCE["lat"] <= max_lat
    assert (await client.get(f"/v1/fpos/{ids['fpo_b']}")).status_code == 404  # not the caller's FPO
    _as(caller, ids, "admin_b", "fpo_b", Role.FPO_ADMIN)
    empty = await client.get(f"/v1/fpos/{ids['fpo_b']}")  # no plots → region extent
    lon0, lat0, lon1, lat1 = empty.json()["bbox"]
    assert lon0 < lon1 and lat0 < lat1


async def test_rejected_farmer_loses_sign_in(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """Rejecting a signed-in farmer: old token → 401 on push; a new OTP → 403 `account_inactive`.

    Args:
        api: client and caller holder (admin side, caller overridden).
        ids: the seeded ids.
    """
    client, caller = api
    phone, code = _phone(), "123456"  # tests/conftest.py sets OTP_DEV_CODE=123456
    farmer = await _farmer(client, caller, ids, phone=phone)
    otp = {"phone": phone, "code": code, "platform": "android"}
    async with AsyncClient(transport=ASGITransport(app=create_app()), base_url="http://test") as real:
        assert (await real.post("/v1/auth/otp/request", json={"phone": phone})).status_code == 204
        signed_in = await real.post("/v1/auth/otp/verify", json=otp | {"device_id": str(uuid.uuid4())})
        assert signed_in.status_code == 200, signed_in.text
        bearer = {"Authorization": f"Bearer {signed_in.json()['access_token']}"}
        body = {"reason_code": "not_a_member"}
        assert (await client.post(f"/v1/farmers/{farmer['id']}/reject", json=body)).status_code == 200
        [diff] = await _audit(farmer["id"], "farmer.reject")
        assert diff["membership_removed"] is True and diff["devices_revoked"] == 1
        assert (await real.post("/v1/sync/push", json={}, headers=bearer)).status_code == 401
        async with get_sessionmaker()() as s:  # a second request within 60 s would be 429 `rate_limited`
            expires = utcnow() + timedelta(minutes=5)
            s.add(OtpChallenge(phone=phone, code_hash=hash_otp(phone, code), expires_at=expires))
            await s.commit()
        again = await real.post("/v1/auth/otp/verify", json=otp | {"device_id": str(uuid.uuid4())})
        assert (again.status_code, again.json()["error"]["code"]) == (403, "account_inactive")
