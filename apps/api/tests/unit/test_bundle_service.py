"""Unit tests of reference bundles: part shapes vs the phone's golden fixture, manifest, ETag, `since`.

Serves: B07 acceptance (bundle shapes per docs/agents/reports/M03.md "Contract for B07", ETag/304, per-part
`since` per TODO F1, gi_region ≤ 50 KB), PLAN §13 C2/C3, D-006, D-016.
Callers: pytest (`make test-unit`); no Docker needed (database calls are faked).
"""

import json
import uuid
from datetime import date
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest
from geoalchemy2 import WKTElement

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser
from agritrace.core.config import get_settings
from agritrace.core.enums import InputCategory, Role
from agritrace.core.errors import GiRegionMissingError, ValidationFailedError
from agritrace.modules.events import bundle_service as bs
from agritrace.modules.events.schemas import BundlePart, PartVersion
from agritrace.modules.events.sync_router import etag_matches
from agritrace.modules.registry.models import Crop, GiRegionVersion, InputMaster, Plot

GOLDEN = json.loads(
    (Path(__file__).parents[4] / "apps/mobile/test/fixtures/reference_bundle.json").read_text(
        encoding="utf-8"
    )
)
SCOPE = bs.Scope(uuid.uuid4(), None)
USER = CurrentUser(user_id=uuid.uuid4(), fpo_id=SCOPE.fpo_id, role=Role.FIELD_OFFICER)


class FakeSession:
    """Answers `scalars` and `scalar` with preset rows, whatever the query."""

    def __init__(self, rows: list[Any], one: Any = None) -> None:
        """Keep the rows.

        Args:
            rows: what `scalars` returns.
            one: what `scalar` returns.
        """
        self.rows, self.one = rows, one

    async def scalars(self, _query: Any) -> list[Any]:
        """Return the preset rows.

        Args:
            _query: ignored.

        Returns:
            The rows.
        """
        return self.rows

    async def scalar(self, _query: Any) -> Any:
        """Return the preset single value.

        Args:
            _query: ignored.

        Returns:
            The value.
        """
        return self.one


def crop() -> Crop:
    """Build the fixture's crop as a row.

    Returns:
        A crop with the nursery/main-field event schema.
    """
    g = GOLDEN["crops"]["crops"][0]
    return Crop(
        id=uuid.uuid4(),
        code=g["code"],
        name_en=g["name_en"],
        name_local=g["name_local"],
        event_schema=g["event_schema"],
    )


def plot() -> Plot:
    """Build a plot row with a WKT pin.

    Returns:
        A 1.5 acre plot at the reference pin.
    """
    return Plot(
        id=uuid.uuid4(),
        farmer_id=uuid.uuid4(),
        code="P-01",
        pin=WKTElement("POINT(78.2 9.55)", srid=4326),
        declared_area_acres=Decimal("1.500"),
    )


def item() -> InputMaster:
    """Build an input row with every optional field set.

    Returns:
        An organic fertilizer with manufacturer and local name.
    """
    return InputMaster(
        id=uuid.uuid4(),
        name_en="Organic Fertilizer Gold",
        name_local="கரிம உரத் தங்கம்",
        manufacturer="Amul",
        category=InputCategory.ORGANIC_FERTILIZER,
        unit="kg",
        photo_key="inputs/ofg.webp",
    )


async def test_crops_part_matches_golden_shape() -> None:
    """`crops` has the golden keys (plus `gi_tag_id`); `event_schema {mandatory, tracks}` passes through."""
    body = await bs._crops(FakeSession([crop()]), SCOPE)  # type: ignore[arg-type]
    assert body.keys() == GOLDEN["crops"].keys()
    ours, golden = body["crops"][0], GOLDEN["crops"]["crops"][0]
    assert set(ours) - {"gi_tag_id"} == set(golden)
    assert ours["event_schema"] == golden["event_schema"]
    assert set(ours["event_schema"]) == {"mandatory", "tracks"}


async def test_inputs_part_matches_golden_shape() -> None:
    """`inputs` items have exactly the golden keys (the first golden input has every optional key)."""
    body = await bs._inputs(FakeSession([item()]), SCOPE)  # type: ignore[arg-type]
    assert body.keys() == GOLDEN["inputs"].keys()
    assert set(body["inputs"][0]) == set(GOLDEN["inputs"]["inputs"][0])
    assert body["inputs"][0]["category"] == "organic_fertilizer"


async def test_plots_part_matches_golden_shape() -> None:
    """`plots` items carry the golden keys plus `code` and `gi_tag_id`; pin is {lat, lon}; area in acres."""
    body = await bs._plots(FakeSession([plot()]), SCOPE)  # type: ignore[arg-type]
    assert body.keys() == GOLDEN["plots"].keys()
    ours, golden = body["plots"][0], GOLDEN["plots"]["plots"][0]
    assert set(ours) - {"code", "gi_tag_id"} == set(golden)
    assert ours["pin"] == {"lat": 9.55, "lon": 78.2}
    assert (ours["declared_area"], ours["area_unit"]) == (1.5, "acre")


async def test_calendar_part_matches_golden_shape() -> None:
    """`calendar` is the golden top-level shape, empty until a calendar source exists."""
    body = await bs._calendar(FakeSession([]), SCOPE)  # type: ignore[arg-type]
    assert body.keys() == GOLDEN["calendar"].keys()
    assert body == {"calendar": []}


async def test_images_list_only_inputs_with_pictures_on_public_bucket(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """`images` lists pictures by key with a stable public URL (no presigning, so the ETag is stable).

    Args:
        monkeypatch: sets the settings the URL needs.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test")
    get_settings.cache_clear()
    without = item()
    without.photo_key = None
    body = await bs._images(FakeSession([item(), without]), SCOPE)  # type: ignore[arg-type]
    assert len(body["images"]) == 1
    image = body["images"][0]
    assert image["key"] == "inputs/ofg.webp"
    assert image["url"].endswith("/public-pages/inputs/ofg.webp")
    assert "Signature" not in image["url"]


def region(buffer_m: str = "100") -> GiRegionVersion:
    """Build a region version row.

    Args:
        buffer_m: tolerance buffer in metres.

    Returns:
        Version 0 of a region.
    """
    return GiRegionVersion(
        id=uuid.uuid4(),
        gi_tag_id=uuid.uuid4(),
        version_no=0,
        tolerance_buffer_m=Decimal(buffer_m),
        source_ref="fixture",
        licence="CC0-1.0",
        confidence="fixture",
        effective_from=date(2026, 1, 1),
    )


async def test_gi_region_simplifies_further_until_under_50_kb(monkeypatch: pytest.MonkeyPatch) -> None:
    """A 50 m outline over 50 KB is retried at 100 m; the part carries geometry, buffer and provenance.

    Args:
        monkeypatch: replaces `simplify_region`.
    """
    big = {"type": "Polygon", "coordinates": [[[78.0, 9.0]] * 6000]}
    small = {"type": "Polygon", "coordinates": [[[78.0, 9.0], [78.1, 9.0], [78.1, 9.1], [78.0, 9.0]]]}
    calls: list[float] = []

    async def simplify(_s: Any, _id: uuid.UUID, tolerance: float) -> dict[str, Any]:
        calls.append(tolerance)
        return big if tolerance < 100 else small

    monkeypatch.setattr(bs.registry_service, "simplify_region", simplify)
    body = await bs._gi_region(FakeSession([], one=region()), SCOPE)  # type: ignore[arg-type]
    assert body is not None
    assert calls == [50.0, 100.0]
    assert body["geometry"] == small and body["simplified_tolerance_m"] == 100.0
    assert body["tolerance_buffer_m"] == 100.0
    assert {"version_no", "source_ref", "licence", "confidence", "effective_from", "gi_tag_id"} <= set(body)
    assert len(json.dumps(body["geometry"])) <= bs.MAX_REGION_BYTES


async def test_gi_region_absent_without_region() -> None:
    """No region in effect → no part (the manifest leaves it out, the part route answers 404)."""
    assert await bs._gi_region(FakeSession([], one=None), SCOPE) is None  # type: ignore[arg-type]


def fake_builders(monkeypatch: pytest.MonkeyPatch, versions: dict[str, int]) -> None:
    """Replace scope, versions and every builder with constants.

    Args:
        monkeypatch: pytest monkeypatch.
        versions: database versions to report.
    """

    async def scope(_s: Any, _u: Any) -> bs.Scope:
        return SCOPE

    async def db_versions(_s: Any, _fpo: Any) -> dict[str, int]:
        return versions

    def const(body: dict[str, Any] | None) -> Any:
        async def build(_s: Any, _scope: Any) -> dict[str, Any] | None:
            return body

        return build

    builders = {p: const({p.value: [p.value]}) for p in BundlePart}
    builders[BundlePart.GI_REGION] = const(None)
    monkeypatch.setattr(bs, "_scope", scope)
    monkeypatch.setattr(bs, "_db_versions", db_versions)
    monkeypatch.setattr(bs, "BUILDERS", builders)


async def test_manifest_lists_every_part_with_version_and_etag(monkeypatch: pytest.MonkeyPatch) -> None:
    """Every part but a missing gi_region is listed; DB parts take their DB version, others a fingerprint.

    Args:
        monkeypatch: fakes the builders.
    """
    fake_builders(monkeypatch, {"plots": 41, "crops": 7})
    parts = (await bs.manifest(None, USER)).parts  # type: ignore[arg-type]
    assert set(parts) == set(BundlePart) - {BundlePart.GI_REGION}
    assert parts[BundlePart.PLOTS].version == 41
    assert parts[BundlePart.VILLAGES].version == 0  # DB part never bumped yet
    fields = parts[BundlePart.FIELDS]
    assert fields.etag == fieldconfig.etag({"fields": ["fields"]})
    assert fields.version == bs.fingerprint(fields.etag)


async def test_reference_returns_only_changed_parts(monkeypatch: pytest.MonkeyPatch) -> None:
    """A phone holding every current version except `plots` gets `plots` alone, with its body.

    Args:
        monkeypatch: fakes the builders.
    """
    fake_builders(monkeypatch, {"plots": 42, "crops": 7})
    current = (await bs.manifest(None, USER)).parts  # type: ignore[arg-type]
    held = (
        ",".join(f"{p.value}:{v.version}" for p, v in current.items() if p != BundlePart.PLOTS) + ",plots:41"
    )
    out = await bs.reference(None, USER, held)  # type: ignore[arg-type]
    assert list(out.parts) == [BundlePart.PLOTS]
    assert out.parts[BundlePart.PLOTS].body == {"plots": ["plots"]}


async def test_part_body_gi_region_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    """Asking for `gi_region` while none is in effect raises `gi_region_missing`.

    Args:
        monkeypatch: fakes the builders.
    """
    fake_builders(monkeypatch, {})
    with pytest.raises(GiRegionMissingError):
        await bs.part_body(None, USER, BundlePart.GI_REGION)  # type: ignore[arg-type]


def test_etag_is_stable_and_content_bound() -> None:
    """Same content in any key order → same ETag; any change → another ETag; fingerprints are stable ints."""
    a = {"crops": [{"id": "1", "name_en": "Chilli"}], "x": 1}
    b = {"x": 1, "crops": [{"name_en": "Chilli", "id": "1"}]}
    assert fieldconfig.etag(a) == fieldconfig.etag(b)
    assert fieldconfig.etag(a) != fieldconfig.etag({**a, "x": 2})
    assert bs.fingerprint(fieldconfig.etag(a)) == bs.fingerprint(fieldconfig.etag(b)) < 2**48


def test_parse_since() -> None:
    """`<part>:<version>` items separated by commas; empty or missing means nothing held."""
    assert bs.parse_since("plots:41, crops:7") == {"plots": 41, "crops": 7}
    assert bs.parse_since(None) == {} == bs.parse_since("")


@pytest.mark.parametrize("bad", ["plots", "plots:x", "plots:1:2", "42"])
def test_parse_since_rejects_malformed(bad: str) -> None:
    """A bare number or a broken item is a 422, not a silent full download.

    Args:
        bad: malformed `since`.
    """
    with pytest.raises(ValidationFailedError):
        bs.parse_since(bad)


def test_changed_parts_compares_each_part_on_its_own() -> None:
    """F1: a part whose own version moved is returned even when another part holds a higher number."""
    current = {
        BundlePart.PLOTS: PartVersion(version=11, etag='"a"'),
        BundlePart.CROPS: PartVersion(version=12, etag='"b"'),
        BundlePart.FIELDS: PartVersion(version=99, etag='"c"'),
    }
    # The phone saw crops at 12 (a later sequence value) before the plots change (11) committed.
    held = {"plots": 10, "crops": 12, "retired_part": 3}
    assert bs.changed_parts(current, held) == [BundlePart.PLOTS, BundlePart.FIELDS]


def test_etag_matches_if_none_match_forms() -> None:
    """Exact tag, a list containing it, a weak copy and `*` match; another tag or no header does not."""
    tag = '"0123456789abcdef"'
    assert etag_matches(tag, tag)
    assert etag_matches(f'"x", {tag}', tag)
    assert etag_matches(f"W/{tag}", tag)
    assert etag_matches("*", tag)
    assert not etag_matches('"other"', tag)
    assert not etag_matches(None, tag)
