"""Integration tests of B13 on a real database: migration 0003, imports, field-config hooks, plots.gi_tag_id.

Covers: `alembic upgrade head` + `alembic check` clean with 0003; CSV with 2 bad rows → 200, accepted n-2,
dry run writes nothing, commit writes only the valid rows, a second commit is a no-op (idempotent, rows
reported `import_row_exists` / `farmer_phone_taken`); a NUL cell and a number out of range are row rejections,
not a whole-file error (B25); villages import super-admin only (sample fixture
`seed/fixtures/villages_virudhunagar.csv`, LGD codes `SAMPLE…` are not real codes); demo tenant drops a
disabled plot field; `plots.gi_tag_id` preferred over the single-GI fallback when two GI tags have regions.
Serves: D-017, FR53, FR56, FR64–FR67, PLAN "Gap analysis" (Master data uploads), acceptance/B13.md.
Callers: pytest (`make test`); needs Docker (PostGIS, Valkey, LocalStack from tests/conftest.py `stack`).
"""

import json
import secrets
import subprocess
import sys
import uuid
from collections.abc import AsyncIterator
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import func, select

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import OrgKind, Role
from agritrace.main import create_app
from agritrace.modules.identity.models import Membership, User
from agritrace.modules.registry.models import Farmer, Fpo, GiTag, InputMaster, Plot, Village

pytestmark = pytest.mark.integration

API_DIR = Path(__file__).parents[2]
FIXTURES = API_DIR / "agritrace" / "seed" / "fixtures"
DEMO = "VIRUDHAI_SCFC_VINOBA_BHAVA_FPO"
REFERENCE = {"lat": 9.559806, "lon": 78.133521, "accuracy_m": 6.2}
FAR_AWAY = {
    "type": "MultiPolygon",
    "coordinates": [[[[77.0, 11.0], [77.1, 11.0], [77.1, 11.1], [77.0, 11.0]]]],
}
PROVENANCE = {"tolerance_buffer_m": 150, "source_ref": "fixture", "licence": "CC0-1.0",
              "taluks": ["Tiruchuli"], "confidence": "fixture", "attribution": "project test data",
              "share_alike": False}  # fmt: skip
NOW = datetime(2026, 3, 4, 8, 12, tzinfo=UTC).isoformat()


def _alembic(*args: str) -> subprocess.CompletedProcess[str]:
    """Run the alembic CLI of this environment in apps/api.

    Args:
        *args: alembic arguments.

    Returns:
        The finished process (checked: a non-zero exit fails the test).
    """
    alembic = Path(sys.executable).parent / "alembic"
    return subprocess.run([str(alembic), *args], cwd=API_DIR, check=True, capture_output=True, text=True)  # noqa: S603


@pytest.fixture(scope="module")
async def ids(stack: None) -> dict[str, Any]:
    """Migrate to head (0003), then seed the demo FPO, a second FPO, an admin each, a super-admin, 2 GI tags.

    Args:
        stack: the running containers (fixture).

    Returns:
        Ids by name: demo, other, admin_demo, admin_other, super_admin, gi_a, gi_b.

    Side effects:
        Runs `alembic upgrade head`; inserts rows (the demo FPO is reused if present).
    """
    _alembic("upgrade", "head")
    ids: dict[str, Any] = {}
    async with get_sessionmaker()() as s:
        demo = await s.scalar(select(Fpo).where(Fpo.code == DEMO))
        if demo is None:
            demo = Fpo(code=DEMO, name="Demo FPO", kind=OrgKind.FPO)
            s.add(demo)
        other = Fpo(code=f"T{secrets.token_hex(4).upper()}", name="Other", kind=OrgKind.FPO)
        s.add(other)
        await s.flush()
        ids["demo"], ids["other"] = demo.id, other.id
        for key, fpo, super_admin in (
            ("admin_demo", demo.id, False),
            ("admin_other", other.id, False),
            ("super_admin", demo.id, True),
        ):
            user = User(phone=f"+9191{secrets.randbelow(10**8):08d}", name=key, is_super_admin=super_admin)
            s.add(user)
            await s.flush()
            s.add(Membership(user_id=user.id, fpo_id=fpo, role=Role.FPO_ADMIN))
            ids[key] = user.id
        for key in ("gi_a", "gi_b"):
            tag = GiTag(gi_number=f"T{secrets.token_hex(3)}", name=key)
            s.add(tag)
            await s.flush()
            ids[key] = tag.id
        await s.commit()
    return ids


class Caller:
    """Mutable stand-in for `get_current_user`, so one client can act as different users."""

    def __init__(self) -> None:
        """Start with no caller."""
        self.user: CurrentUser | None = None

    def __call__(self) -> CurrentUser:
        """Return the current caller.

        Returns:
            The user set by the test.
        """
        assert self.user is not None
        return self.user


@pytest.fixture
async def api(ids: dict[str, Any]) -> AsyncIterator[tuple[AsyncClient, Caller]]:
    """An in-process client whose caller is chosen per request via `Caller`.

    Args:
        ids: the seeded ids.

    Returns:
        An async iterator yielding (client, caller holder).
    """
    app = create_app()
    caller = Caller()
    app.dependency_overrides[get_current_user] = caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield client, caller


def _as(caller: Caller, ids: dict[str, Any], who: str, fpo: str, super_admin: bool = False) -> None:
    """Switch the caller to an FPO admin.

    Args:
        caller: the holder.
        ids: the seeded ids.
        who: key of the user id in `ids`.
        fpo: key of the FPO id in `ids`.
        super_admin: the token's super-admin flag.
    """
    caller.user = CurrentUser(
        user_id=ids[who], fpo_id=ids[fpo], role=Role.FPO_ADMIN, is_super_admin=super_admin
    )


async def _count(model: Any, *where: Any) -> int:
    """Count rows.

    Args:
        model: ORM class.
        *where: filter clauses.

    Returns:
        The row count.
    """
    async with get_sessionmaker()() as s:
        return int(await s.scalar(select(func.count()).select_from(model).where(*where)) or 0)


async def _upload(client: AsyncClient, kind: str, body: bytes, dry_run: bool) -> dict[str, Any]:
    """POST a CSV import.

    Args:
        client: API client.
        kind: farmers, villages or inputs.
        body: CSV bytes.
        dry_run: query flag.

    Returns:
        The report (asserting 200).
    """
    response = await client.post(
        f"/v1/imports/{kind}",
        params={"dry_run": str(dry_run).lower()},
        files={"file": (f"{kind}.csv", body, "text/csv")},
    )
    assert response.status_code == 200, response.text
    result: dict[str, Any] = response.json()
    return result


def test_migration_0003_applies_and_alembic_check_is_clean(ids: dict[str, Any]) -> None:
    """The database is at the script head (0003_masters or later) and the models match the schema (no drift).

    Args:
        ids: the seeded ids (fixture ran `alembic upgrade head`).
    """
    # Read the head from the scripts, so the next migration does not break this test (B17).
    head = _alembic("heads").stdout.split()[0]
    assert head in _alembic("current").stdout
    _alembic("check")


async def test_inputs_import_dry_run_commit_and_rerun(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """2 bad rows → accepted n-2; dry run writes nothing; commit writes n-2; re-run writes nothing.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    _as(caller, ids, "admin_other", "other")
    csv_body = (
        b"name_en,manufacturer,category,unit,pack_size\n"
        b"Urea,IFFCO,chemical_fertilizer,kg,50\n"
        b"Neem cake,,organic_fertilizer,,25\n"
        b"Trichoderma,,bio_pesticide,kg,1\n"
        b"Mystery,,magic_dust,kg,1\n"
        b"Vermicompost,,organic_fertilizer,kg,40\n"
    )
    mine = InputMaster.fpo_id == ids["other"]
    before = await _count(InputMaster, mine)
    dry = await _upload(client, "inputs", csv_body, dry_run=True)
    assert dry["accepted"] == 3 and dry["dry_run"] is True
    assert [(r["row"], r["code"]) for r in dry["rejected"]] == [
        (3, "field_required"),
        (5, "import_row_invalid"),
    ]
    assert await _count(InputMaster, mine) == before
    done = await _upload(client, "inputs", csv_body, dry_run=False)
    assert (done["accepted"], len(done["rejected"])) == (3, 2)
    assert await _count(InputMaster, mine) == before + 3
    again = await _upload(client, "inputs", csv_body, dry_run=False)
    assert again["accepted"] == 0
    assert [r["code"] for r in again["rejected"]].count("import_row_exists") == 3
    assert await _count(InputMaster, mine) == before + 3


async def test_database_data_errors_are_row_rejections(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """A NUL cell and a pack size beyond NUMERIC(12,3) (SQLSTATE class 22) reject only their rows (B25).

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    _as(caller, ids, "admin_other", "other")
    tag = secrets.token_hex(4)
    csv_body = (
        f"name_en,category,unit,pack_size\n"
        f"Good A {tag},chemical_fertilizer,kg,50\n"
        f"Bad\0name {tag},chemical_fertilizer,kg,1\n"
        f"Huge {tag},chemical_fertilizer,kg,10000000000000\n"
        f"Good B {tag},organic_fertilizer,kg,25\n"
    ).encode()
    mine = InputMaster.fpo_id == ids["other"]
    before = await _count(InputMaster, mine)
    report = await _upload(client, "inputs", csv_body, dry_run=False)
    assert report["accepted"] == 2
    rejected = [(r["row"], r["code"], r["field"]) for r in report["rejected"]]
    assert rejected == [(3, "validation_error", None), (4, "validation_error", None)]
    assert await _count(InputMaster, mine) == before + 2


async def test_villages_then_farmers_import(api: tuple[AsyncClient, Caller], ids: dict[str, Any]) -> None:
    """Villages: admin 403, super-admin imports the sample; farmers pick villages by LGD code.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    villages = (FIXTURES / "villages_virudhunagar.csv").read_bytes()
    _as(caller, ids, "admin_demo", "demo")
    denied = await client.post("/v1/imports/villages", files={"file": ("v.csv", villages, "text/csv")})
    assert denied.status_code == 403
    _as(caller, ids, "super_admin", "demo", super_admin=True)
    first = await _upload(client, "villages", villages, dry_run=False)
    rerun = await _upload(client, "villages", villages, dry_run=False)
    assert first["accepted"] + len(first["rejected"]) == 5
    assert rerun["accepted"] == 0 and {r["code"] for r in rerun["rejected"]} == {"import_row_exists"}
    assert await _count(Village, Village.lgd_code.like("SAMPLE%")) == 5

    _as(caller, ids, "admin_demo", "demo")
    phone = f"+9192{secrets.randbelow(10**8):08d}"
    farmers = (
        "name,phone,lang,village_lgd_code\n"
        f"Muthu,{phone},ta,SAMPLE0001\n"
        ",+919000000001,ta,SAMPLE0001\n"
        "Selvi,98765,ta,SAMPLE0002\n"
        "Kannan,,en,NOPE\n"
        f"Muthu again,{phone},ta,\n"
        "Lakshmi,,ta,SAMPLE0003\n"
    ).encode()
    report = await _upload(client, "farmers", farmers, dry_run=False)
    assert report["accepted"] == 2
    assert [(r["row"], r["code"], r["field"]) for r in report["rejected"]] == [
        (3, "field_required", "name"),
        (4, "import_row_invalid", "phone"),
        (5, "validation_error", "village_lgd_code"),
        (6, "farmer_phone_taken", "phone"),
    ]
    async with get_sessionmaker()() as s:
        muthu = await s.scalar(select(Farmer).where(Farmer.fpo_id == ids["demo"], Farmer.name == "Muthu"))
    assert muthu is not None and muthu.address and muthu.address["district"] == "Virudhunagar"


async def _region(client: AsyncClient, caller: Caller, ids: dict[str, Any], tag: str, geometry: Any) -> None:
    """Upload a region for a GI tag as super-admin.

    Args:
        client: API client.
        caller: caller holder.
        ids: the seeded ids.
        tag: `gi_a` or `gi_b`.
        geometry: MultiPolygon GeoJSON.
    """
    _as(caller, ids, "super_admin", "demo", super_admin=True)
    response = await client.post(
        f"/v1/gi-tags/{ids[tag]}/region-versions", json={"geometry": geometry, **PROVENANCE}
    )
    assert response.status_code == 201, response.text


async def test_plot_gi_tag_is_stored_and_preferred(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """Two GI tags with regions: a plot's stored gi_a is used on create and on correction.

    The single-GI fallback would give needs_review; the demo tenant's disabled soil type is not stored.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    fixture = json.loads((FIXTURES / "gi_region_fixture.geojson").read_text())["features"][0]["geometry"]
    await _region(client, caller, ids, "gi_a", fixture)
    await _region(client, caller, ids, "gi_b", FAR_AWAY)
    _as(caller, ids, "admin_demo", "demo")
    farmer = (await client.post("/v1/farmers", json={"name": "Ravi"})).json()
    body = {
        "client_id": str(uuid.uuid4()),
        "farmer_id": farmer["id"],
        "gi_tag_id": str(ids["gi_a"]),
        "pin": REFERENCE,
        "device_time": NOW,
        "declared_area": {"value": "1", "unit": "acre"},
        "soil_type": "red loam",
    }
    created = await client.post("/v1/plots", json=body)
    assert created.status_code == 201, created.text
    assert created.json()["gi_tag_id"] == str(ids["gi_a"])
    assert created.json()["location_status"] == "confirmed"
    assert created.json()["soil_type"] is None  # disabled for the demo tenant: dropped
    corrected = await client.post(f"/v1/plots/{body['client_id']}/correct", json={"reason_code": "gps_drift"})
    assert corrected.json()["location_status"] == "confirmed"  # stored gi_a used, not the fallback
    no_tag = await client.post("/v1/plots", json={**body, "client_id": str(uuid.uuid4()), "gi_tag_id": None})
    assert no_tag.json()["location_status"] == "needs_review"  # fallback: two tags have regions
    unknown = await client.post(
        "/v1/plots", json={**body, "client_id": str(uuid.uuid4()), "gi_tag_id": str(uuid.uuid4())}
    )
    assert unknown.status_code == 422
    async with get_sessionmaker()() as s:
        stored = await s.get(Plot, uuid.UUID(body["client_id"]))
    assert stored is not None and stored.gi_tag_id == ids["gi_a"]


async def test_config_endpoints_for_the_demo_tenant(
    api: tuple[AsyncClient, Caller], ids: dict[str, Any]
) -> None:
    """The demo FPO (real FPO row) gets plot fields without soil type; another FPO gets it.

    Args:
        api: client and caller holder.
        ids: the seeded ids.
    """
    client, caller = api
    _as(caller, ids, "admin_demo", "demo")
    demo = await client.get("/v1/config/fields", params={"entity": "plot"})
    _as(caller, ids, "admin_other", "other")
    other = await client.get("/v1/config/fields", params={"entity": "plot"})
    features = await client.get("/v1/config/features")
    assert "soil_type" not in [f["name"] for f in demo.json()["plot"]]
    assert "soil_type" in [f["name"] for f in other.json()["plot"]]
    assert features.json()["producer_groups"] is False
    assert (await client.get("/v1/producer-groups")).json()["error"]["code"] == "feature_disabled"
