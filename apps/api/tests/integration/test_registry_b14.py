"""Integration tests of the B14 registry additions on a real database (PostGIS).

One test per acceptance line of docs/agents/acceptance/B14.md: masked phone and the audited reveal (403 /
200 + one audit row / 404), reject with reason and 409 `farmer_not_pending`, a farmer's plot list with
`gi_tag_id`, `?village_id=` / `?q=` / `?fields=` on the farmer list, and `bbox` on GET /v1/fpos/{id}
(plots, else the GI region); round 2 (review B14-r1 P2-R): a rejected farmer's old token gets 401 and a
new OTP sign-in gets 403 `account_inactive`. B24 (DPDP runbook, D-065): the export's shape, scope (403/404)
and audit row; erasure (PII replaced, consent withdrawn, id-docs objects gone, append-only rows unchanged,
a repeat is a no-op); the daily `otp_challenges` purge. B24 round 2 (review B24-r1 P1, P3-4): an
officer-farmer's export holds only his own entries, and erasing him keeps his officer account.
Serves: FR8, FR14, FR53, FR70, PLAN gap analysis "Members", D-017, D-020, D-065.
Callers: pytest (`make test`); needs Docker (PostGIS, Valkey, LocalStack from tests/conftest.py `stack`).
Reuses the seeding fixtures and helpers of test_registry.py (same folder, imported by module name).
"""

import asyncio
import secrets
import uuid
from datetime import timedelta
from decimal import Decimal
from typing import Any

import pytest
import test_registry
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select, text
from test_registry import REFERENCE, Caller, _as, _farmer, _plot, _region

from agritrace.core import storage
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import ChangeKind, ConsentType, EventSubject, EventType, PinMethod, Role
from agritrace.core.ids import uuid7
from agritrace.core.time import utcnow
from agritrace.main import create_app
from agritrace.modules.events.models import Event, EventVersion, EvidencePhoto
from agritrace.modules.identity.models import ConsentRecord, Device, Membership, OtpChallenge, User
from agritrace.modules.identity.service import hash_otp
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.registry.models import Crop, Farmer, IdDocument, Plot, Village

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


# --- B24: DPDP export, erasure, OTP purge (docs/ops/dpdp-data-subject-runbook.md, D-065) -----------------


async def _personal_data(farmer: dict[str, Any], ids: dict[str, Any]) -> dict[str, Any]:
    """Give a farmer a consent, an ID document (row and id-docs object) and an expired OTP challenge.

    Args:
        farmer: the created farmer (with a phone).
        ids: the seeded ids.

    Returns:
        The consent id, the document's object key and the farmer's user id.

    Side effects:
        Inserts rows and commits; writes one object to the id-docs bucket.
    """
    async with get_sessionmaker()() as s:
        consent = ConsentRecord(
            id=uuid7(),
            farmer_id=uuid.UUID(farmer["id"]),
            consent_type=ConsentType.DATA_COLLECTION,
            consent_version="v1-ta",
            given_at=utcnow(),
        )
        s.add(consent)
        await s.flush()
        key = f"{ids['fpo_a']}/{farmer['id']}/{uuid7()}.jpeg"
        s.add(
            IdDocument(
                farmer_id=uuid.UUID(farmer["id"]),
                doc_type="aadhaar",
                object_key=key,
                captured_by=ids["admin_a"],
                captured_at=utcnow(),
                consent_record_id=consent.id,
            )
        )
        user_id = await s.scalar(select(Farmer.user_id).where(Farmer.id == uuid.UUID(farmer["id"])))
        phone = await s.scalar(select(User.phone).where(User.id == user_id))
        s.add(OtpChallenge(phone=phone, code_hash="x", expires_at=utcnow() - timedelta(days=40)))
        await s.commit()
    storage.client().put_object(Bucket=get_settings().s3_bucket_iddocs, Key=key, Body=b"\xff\xd8 id card")
    return {"consent": consent.id, "key": key, "user": user_id}


async def _officer(ids: dict[str, Any]) -> tuple[uuid.UUID, str]:
    """Create a field officer of FPO A with a fresh phone (each test gets its own account).

    Args:
        ids: the seeded ids.

    Returns:
        The officer's user id and phone.

    Side effects:
        Inserts a `users` and a `memberships` row; commits.
    """
    phone = _phone()
    async with get_sessionmaker()() as s:
        user = User(phone=phone, name="Officer Ravi")
        s.add(user)
        await s.flush()
        s.add(Membership(user_id=user.id, fpo_id=ids["fpo_a"], role=Role.FIELD_OFFICER))
        await s.commit()
        return user.id, phone


async def _entry_with_photo(
    ids: dict[str, Any], farmer_id: str, entered_by: uuid.UUID, on_behalf: str | None
) -> tuple[uuid.UUID, str]:
    """Insert a plot, lot, event, version and evidence photo for one farmer, entered by `entered_by`.

    Args:
        ids: the seeded ids.
        farmer_id: owner of the plot and lot.
        entered_by: the user who entered the version.
        on_behalf: the farmer the entry was made for in assist mode, or None.

    Returns:
        The version id and the photo's object key.

    Side effects:
        Inserts a crop, plot, lot, event, event version and evidence photo; commits.
    """
    now = utcnow()
    async with get_sessionmaker()() as s:
        crop = Crop(
            code=f"C_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={}, gi_tag_id=ids["gi_tag"]
        )
        plot = Plot(
            id=uuid7(),
            fpo_id=ids["fpo_a"],
            farmer_id=uuid.UUID(farmer_id),
            code="P-01",
            pin=WKTElement("POINT(78.13 9.56)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=now,
            pin_server_received_at=now,
            declared_area_acres=Decimal("1.5"),
        )
        s.add_all([crop, plot])
        await s.flush()
        lot = Lot(
            fpo_id=ids["fpo_a"],
            farmer_id=plot.farmer_id,
            plot_id=plot.id,
            crop_id=crop.id,
            season_label="2026",
            code=f"LOT{secrets.token_hex(4).upper()}",
        )
        s.add(lot)
        await s.flush()
        event = Event(
            id=uuid7(),
            fpo_id=ids["fpo_a"],
            subject_type=EventSubject.LOT,
            lot_id=lot.id,
            plot_id=plot.id,
            event_type=EventType.HARVEST,
            occurred_on=now.date(),
        )
        s.add(event)
        await s.flush()
        version = EventVersion(
            id=uuid7(),
            event_id=event.id,
            version_no=1,
            payload={},
            occurred_on=now.date(),
            device_time=now,
            server_received_at=now,
            entered_by_user_id=entered_by,
            on_behalf_of_farmer_id=uuid.UUID(on_behalf) if on_behalf else None,
            change_kind=ChangeKind.CREATE,
        )
        s.add(version)
        await s.flush()
        key = f"{ids['fpo_a']}/{version.id}.jpg"
        s.add(
            EvidencePhoto(
                event_version_id=version.id,
                bucket=get_settings().s3_bucket_evidence,
                object_key=key,
                content_type="image/jpeg",
                size_bytes=10,
                sha256_client="0" * 64,
            )
        )
        await s.commit()
        return version.id, key


async def _rows(sql: str, **params: Any) -> list[dict[str, Any]]:
    """Read rows as dicts.

    Args:
        sql: a SELECT.
        **params: its bind values.

    Returns:
        Every row, as a column-to-value dict.
    """
    async with get_sessionmaker()() as s:
        return [dict(r._mapping) for r in await s.execute(text(sql), params)]


async def test_export_shape_scope_and_audit(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """Admin gets the whole record with file links and one `farmer.export` row; officer/farmer 403; FPO B 404.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    phone = _phone()
    farmer = await _farmer(client, caller, ids, phone=phone)
    data = await _personal_data(farmer, ids)
    out = await client.get(f"/v1/farmers/{farmer['id']}/export")
    assert out.status_code == 200, out.text
    assert out.headers["Cache-Control"] == "no-store"
    doc = out.json()
    assert doc["farmer"]["id"] == farmer["id"] and doc["user"]["phone"] == phone
    assert "pin_hash" not in doc["user"]
    assert [c["id"] for c in doc["consents"]] == [str(data["consent"])]
    [iddoc] = doc["id_documents"]
    assert iddoc["object_key"] == data["key"] and f"/id-docs/{data['key']}" in iddoc["url"]
    assert iddoc["url"].split("?")[1].count("X-Amz-Signature") == 1
    empty = (
        "plots",
        "lots",
        "intakes",
        "batch_shares",
        "event_versions",
        "evidence_photos",
        "quality_readings",
    )
    for section in empty + ("notifications", "devices"):
        assert doc[section] == []
    assert doc["links_expire_at"]
    [diff] = await _audit(farmer["id"], "farmer.export")
    assert diff["rows"]["id_documents"] == 1 and phone not in str(diff)
    _as(caller, ids, "officer_a", "fpo_a", Role.FIELD_OFFICER)
    assert (await client.get(f"/v1/farmers/{farmer['id']}/export")).status_code == 403
    caller.user = CurrentUser(user_id=data["user"], fpo_id=ids["fpo_a"], role=Role.FARMER)
    assert (await client.get(f"/v1/farmers/{farmer['id']}/export")).status_code == 403
    _as(caller, ids, "admin_b", "fpo_b", Role.FPO_ADMIN)
    assert (await client.get(f"/v1/farmers/{farmer['id']}/export")).status_code == 404


async def test_officer_farmer_export_holds_only_own_entries(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """An officer-farmer's export has his own version and photo, not those he entered for other farmers.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    officer, phone = await _officer(ids)
    own_farmer = await _farmer(client, caller, ids, phone=phone)  # linked to the officer's account
    other = await _farmer(client, caller, ids)
    own_version, own_key = await _entry_with_photo(ids, own_farmer["id"], officer, None)
    other_version, other_key = await _entry_with_photo(ids, other["id"], officer, other["id"])
    out = await client.get(f"/v1/farmers/{own_farmer['id']}/export")
    assert out.status_code == 200, out.text
    doc = out.json()
    assert doc["user"]["id"] == str(officer)
    assert [v["id"] for v in doc["event_versions"]] == [str(own_version)]
    [photo] = doc["evidence_photos"]
    assert photo["object_key"] == own_key and f"/evidence/{own_key}" in photo["url"]
    assert str(other_version) not in out.text and other_key not in out.text


async def test_erase_keeps_an_account_with_another_membership(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Erasing an officer's farmer record anonymises the farmer but keeps the officer's login and devices.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    officer, phone = await _officer(ids)
    farmer = await _farmer(client, caller, ids, phone=phone)
    async with get_sessionmaker()() as s:
        s.add(Device(id=uuid.uuid4(), user_id=officer, platform="android", refresh_token_hash="h"))
        await s.commit()
    body = {"reason": "DPDP-2026-003", "confirm": True}
    assert (await client.post(f"/v1/farmers/{farmer['id']}/erase", json=body)).status_code == 204
    [diff] = await _audit(farmer["id"], "farmer.erase")
    assert diff["user_erased"] is False and diff["devices_revoked"] == 0
    [u] = await _rows("SELECT phone, name, status FROM users WHERE id = :u", u=officer)
    assert (u["phone"], u["status"]) == (phone, "active")
    [d] = await _rows("SELECT revoked_at, refresh_token_hash FROM devices WHERE user_id = :u", u=officer)
    assert d == {"revoked_at": None, "refresh_token_hash": "h"}
    [f] = await _rows("SELECT name FROM farmers WHERE id = :f", f=uuid.UUID(farmer["id"]))
    assert f["name"] == f"Erased {farmer['code']}"


async def test_erase_anonymises_and_keeps_append_only_rows(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Erase: PII replaced, consent withdrawn, id-docs gone, OTP gone; append-only rows unchanged; repeat 204.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    await _region(client, caller, ids)
    phone = _phone()
    address = {"village": "PM Pudhupatti", "district": "Virudhunagar", "state": "Tamil Nadu", "pin": "626129"}
    farmer = await _farmer(
        client, caller, ids, phone=phone, address=address, gi_authorised_user_no="GI-883-7"
    )
    plot = _plot(farmer["id"], ids, REFERENCE, land_record_ref="Survey No. 45/2")
    assert (await client.post("/v1/plots", json=plot)).status_code == 201
    data = await _personal_data(farmer, ids)
    fid, uid = uuid.UUID(farmer["id"]), data["user"]
    audit_sql = "SELECT * FROM audit_log WHERE entity_id IN (:f, :u, :p) ORDER BY id"
    audit_ids = {"f": fid, "u": uid, "p": uuid.UUID(plot["client_id"])}
    audit_before = await _rows(audit_sql, **audit_ids)
    consents_before = await _rows("SELECT * FROM consent_records WHERE farmer_id = :f", f=fid)
    versions_before = await _rows(
        "SELECT md5(string_agg(v::text, ',' ORDER BY id)) AS h FROM event_versions v"
    )
    url = f"/v1/farmers/{farmer['id']}/erase"
    body = {"reason": "DPDP-2026-001, approved by the data officer", "confirm": True}
    assert (await client.post(url, json={"reason": "DPDP-2026-001", "confirm": False})).status_code == 422
    _as(caller, ids, "officer_a", "fpo_a", Role.FIELD_OFFICER)
    assert (await client.post(url, json=body)).status_code == 403
    _as(caller, ids, "admin_b", "fpo_b", Role.FPO_ADMIN)
    assert (await client.post(url, json=body)).status_code == 404
    _as(caller, ids, "admin_a", "fpo_a", Role.FPO_ADMIN)
    erased = await client.post(url, json=body)
    assert erased.status_code == 204, erased.text

    [f] = await _rows("SELECT * FROM farmers WHERE id = :f", f=fid)
    assert (f["name"], f["status"]) == (f"Erased {farmer['code']}", "suspended")
    assert f["address"] == {k: v for k, v in address.items() if k != "pin"}  # village level stays (D-065)
    assert f["gi_authorised_user_no"] is None and f["name_local"] is None
    [u] = await _rows("SELECT * FROM users WHERE id = :u", u=uid)
    assert (u["phone"], u["name"], u["status"]) == (f"erased:{uid}", "Erased farmer", "suspended")
    assert await _rows("SELECT id FROM memberships WHERE user_id = :u", u=uid) == []
    [p] = await _rows("SELECT land_record_ref FROM plots WHERE farmer_id = :f", f=fid)
    assert p["land_record_ref"] is None
    assert await _rows("SELECT id FROM id_documents WHERE farmer_id = :f", f=fid) == []
    assert await _rows("SELECT id FROM otp_challenges WHERE phone = :p", p=phone) == []
    listed = storage.client().list_objects_v2(
        Bucket=get_settings().s3_bucket_iddocs, Prefix=f"{ids['fpo_a']}/{fid}/"
    )
    assert listed.get("KeyCount", 0) == 0
    # Append-only: earlier audit rows and every event version unchanged; consents differ only in revoked_at.
    audit_after = await _rows(audit_sql, **audit_ids)
    assert audit_after[: len(audit_before)] == audit_before
    for value in (phone, "Muthu", "Survey No. 45/2", "GI-883-7", "626129"):  # no PII copied (D-065)
        assert value not in str(audit_after[len(audit_before) :])
    assert (
        await _rows("SELECT md5(string_agg(v::text, ',' ORDER BY id)) AS h FROM event_versions v")
        == versions_before
    )
    [consent] = await _rows("SELECT * FROM consent_records WHERE farmer_id = :f", f=fid)
    assert consent["revoked_at"] is not None
    skip = {"revoked_at", "updated_at"}
    assert {k: v for k, v in consent.items() if k not in skip} == {
        k: v for k, v in consents_before[0].items() if k not in skip
    }
    [diff] = await _audit(farmer["id"], "farmer.erase")
    assert diff["reason"] == body["reason"] and diff["user_erased"] is True
    assert (diff["consents_revoked"], diff["id_documents_deleted"], diff["id_doc_objects_deleted"]) == (
        1,
        1,
        1,
    )
    assert diff["otp_challenges_deleted"] == 1 and diff["plots_scrubbed"] == 1
    assert (await client.post(url, json=body)).status_code == 204
    assert len(await _audit(farmer["id"], "farmer.erase")) == 1


@pytest.mark.usefixtures("ids")  # the migrated database
async def test_purge_otp_challenges_keeps_recent() -> None:
    """The daily task deletes challenges expired over `OTP_RETENTION_DAYS` (30) ago and keeps newer ones."""
    from agritrace.modules.registry import tasks  # late: importing the worker reads the settings

    old, recent = _phone(), _phone()
    async with get_sessionmaker()() as s:
        s.add(OtpChallenge(phone=old, code_hash="x", expires_at=utcnow() - timedelta(days=31)))
        s.add(OtpChallenge(phone=recent, code_hash="x", expires_at=utcnow() - timedelta(days=29)))
        await s.commit()
    assert await asyncio.to_thread(tasks.purge_otp_challenges) >= 1
    left = await _rows("SELECT phone FROM otp_challenges WHERE phone IN (:a, :b)", a=old, b=recent)
    assert left == [{"phone": recent}]
