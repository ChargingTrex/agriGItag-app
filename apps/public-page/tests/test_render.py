"""Tests for the public page renderer, schema privacy rules and CLI.

Purpose: W01 acceptance (valid HTML, bilingual crop, units everywhere, date order, no temporary or
non-evidence paths) plus counts (FR63), budgets (plan §13 E1), consent names, lab badge (FR51).
Requirements: FR15-FR19, FR51, FR58, FR61-FR63, FR72; CLAUDE.md §6.
Callers: ``uv run pytest`` locally and in CI; the W01 Verifier.
"""

import copy
import datetime as dt
import json
import re
from pathlib import Path
from xml.etree.ElementTree import Element

import html5lib
import pytest
from pydantic import ValidationError

from agritrace_page import BUDGETS, measure, render
from agritrace_page.cli import main
from agritrace_page.render import day, indian_number
from agritrace_page.schema import Lot, PublicBatchRecord

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "fixtures" / "batch_sample.json"
_SAMPLE = json.loads(FIXTURE.read_text("utf-8"))
MOBILE = re.compile(r"(?<!\d)[6-9]\d{9}(?!\d)")


@pytest.fixture
def record() -> dict:
    """Give each test its own copy of the sample batch record.

    Returns:
        A deep copy of fixtures/batch_sample.json.
    """
    return copy.deepcopy(_SAMPLE)


def parse(html: str) -> Element:
    """Parse HTML5 strictly; any parse error fails the test.

    Args:
        html: A rendered page.

    Returns:
        The document root (no XHTML namespace on tag names).

    Raises:
        html5lib.html5parser.ParseError: On the first HTML5 parse error.
    """
    parser = html5lib.HTMLParser(
        tree=html5lib.getTreeBuilder("etree"), strict=True, namespaceHTMLElements=False
    )
    return parser.parse(html)


def text(el: Element) -> str:
    """Collapse an element's text content.

    Args:
        el: Any element.

    Returns:
        Its text with whitespace runs collapsed to single spaces.
    """
    return " ".join("".join(el.itertext()).split())


def test_fixture_renders_valid_html5(record: dict) -> None:
    """The sample batch renders to HTML5 with no parse errors."""
    parse(render(record).html)


def test_crop_name_is_bilingual_tamil_first(record: dict) -> None:
    """The heading shows the Tamil crop name before the English one."""
    h1 = text(parse(render(record).html).find(".//h1"))
    assert h1 == "விருதுநகர் சம்பா வத்தல் / Virudhunagar Samba Vathal"


def test_every_quantity_carries_a_unit(record: dict) -> None:
    """Every quantity in the record is rendered as a number followed by a unit (FR58)."""
    events = record["processing_events"] + [e for lot in record["lots"] for e in lot["events"]]
    expected = (
        2  # batch quantity, procured quantity
        + len(record["grade"]["readings"])
        + 3 * len(record["lots"])  # lot quantity, share %, farm area
        + sum(bool(e.get("quantity")) + bool(e.get("moisture")) for e in events)
    )
    quantities = [text(q) for q in parse(render(record).html).iterfind(".//data[@class='q']")]
    assert len(quantities) == expected
    for q in quantities:
        assert re.fullmatch(r"-?[\d,]+(\.\d+)? \S+", q), q


def test_events_render_in_ascending_date_order(record: dict) -> None:
    """Timelines are date-ordered even when the input is not (FR63, PRD §12.2)."""
    for lot in record["lots"]:
        lot["events"].reverse()
    record["processing_events"].reverse()
    lists = parse(render(record).html).findall(".//ol[@class='tl']")
    assert len(lists) == 4
    for ol in lists:
        dates = [li.find(".//time").get("datetime") for li in ol.iterfind("li")]
        assert dates == sorted(dates)


def test_event_counts_match_rendered_events(record: dict) -> None:
    """Per-lot and per-batch counts equal the events shown (FR63)."""
    doc = parse(render(record).html)
    lots = doc.findall(".//article[@class='lot']")
    assert int(doc.find(".//dd[@id='n-lots']").text) == len(lots) == 3
    per_lot = []
    for lot in lots:
        shown = len(lot.findall(".//li[@class='ev']"))
        assert int(lot.find(".//summary/span[@class='n']").text) == shown
        per_lot.append(shown)
    assert per_lot == [11, 11, 8]
    assert int(doc.find(".//span[@id='n-farm']").text) == sum(per_lot)
    processing = doc.find(".//section[@aria-labelledby='h-pev']")
    assert int(doc.find(".//span[@id='n-proc']").text) == len(processing.findall(".//li")) == 2


def test_footer_has_generation_and_utc_time(record: dict) -> None:
    """The footer shows the generation marker and the UTC last-updated time (FR17)."""
    doc = parse(render(record).html)
    assert doc.find(".//span[@id='gen']").text == "Gen 1785403678.099"
    assert text(doc.find(".//footer//time")) == "30 Jul 2026, 09:27 UTC"


def test_no_temp_or_non_evidence_photo_paths(record: dict) -> None:
    """Photos come only from the evidence bucket; no temporary path appears (FR61)."""
    result = render(record)
    assert "temp_uploads" not in result.html + result.data_json
    doc = parse(result.html)
    urls = [a.get("href") for a in doc.iterfind(".//a[@class='ph']")]
    urls += [s.get("srcset") for s in doc.iterfind(".//source")]
    urls += [i.get("src") for i in doc.iterfind(".//img")]
    assert len(urls) == 3 * 32
    assert all("/evidence/" in u for u in urls)


def test_photos_are_lazy_webp_with_jpeg_fallback(record: dict) -> None:
    """Every photo is a <picture> with WebP source, JPEG fallback, size and lazy loading (E2)."""
    for pic in parse(render(record).html).iterfind(".//picture"):
        assert pic.find("source").get("type") == "image/webp"
        img = pic.find("img")
        assert img.get("src").endswith(".jpg") and img.get("loading") == "lazy"
        assert img.get("width") and img.get("height") and img.get("alt")


def test_no_mobile_number_in_html_or_json(record: dict) -> None:
    """No 10-digit Indian mobile pattern appears anywhere in the output (CLAUDE.md §6)."""
    result = render(record)
    assert not MOBILE.search(result.html)
    assert not MOBILE.search(result.data_json)


def test_size_budgets(record: dict) -> None:
    """Inline CSS < 12 KB, JS < 4 KB, whole page < 100 KB (plan §13 E1)."""
    sizes = measure(render(record).html)
    assert sizes["css"] > 0 and sizes["js"] > 0
    for name, limit in BUDGETS.items():
        assert sizes[name] < limit, (name, sizes[name])


def test_rejects_phone_number_without_echoing_it(record: dict) -> None:
    """A phone number anywhere is refused, and the error does not repeat it."""
    record["lots"][0]["events"][0]["comment"] = "Call 98765 43210 for details"
    with pytest.raises(ValidationError) as err:
        render(record)
    assert "phone number" in str(err.value)
    assert "43210" not in str(err.value)


PHONE, LAND = "privacy: phone number", "privacy: land record reference"


@pytest.mark.parametrize(
    ("where", "value", "match"),
    [
        # Unknown keys and coordinate arrays are refused by extra="forbid" and the field types.
        ("boundary", [[78.20, 9.53], [78.21, 9.53], [78.21, 9.54]], "Extra inputs"),
        ("survey_number", "45/2", "Extra inputs"),
        ("practice_tags", [9.536, 78.202], "practice_tags"),
        ("review_note", "Walked POLYGON((78.2 9.5, 78.3 9.5))", "privacy: boundary polygon"),
        ("review_note", "Pin at 9.536271, 78.201934", "privacy: precise coordinates"),
        ("review_note", "Checked against patta records", LAND),
        ("review_note", "Plot S.F. No. 123/4A", LAND),
        ("review_note", "Plot Sy. No. 45", LAND),
        ("review_note", "ID 2345 6789 0123 verified", "privacy: Aadhaar-like number"),
        ("review_note", "Spoke to farmer on 09876543210", PHONE),
        ("review_note", "phone9876543210", PHONE),
        ("review_note", "அழைக்க9876543210", PHONE),
        ("review_note", "Call 987 654 3210", PHONE),
        ("review_note", "Call 987-654-3210", PHONE),
        ("review_note", "Call +91-98765-43210", PHONE),
    ],
)
def test_rejects_polygon_and_other_personal_data(
    record: dict, where: str, value, match: str
) -> None:
    """Polygons, coordinate arrays, precise pins, land records, ID and phone numbers are refused.

    Args:
        record: Sample record.
        where: Lot key to set.
        value: Offending value.
        match: Expected text in the error.
    """
    record["lots"][0][where] = value
    with pytest.raises(ValidationError, match=match):
        render(record)


def test_rejects_instance_mutated_after_validation(record: dict) -> None:
    """A validated record changed afterwards is re-checked by render() (review r1 P1-1)."""
    rec = PublicBatchRecord.model_validate(record)
    rec.lots[0].review_note = "Farmer phone 9876543210"
    with pytest.raises(ValidationError, match=PHONE):
        render(rec)


@pytest.mark.parametrize(
    ("url", "match"),
    [
        ("javascript:alert(document.cookie)", "boundary_map_url"),
        ("http://static.example/gi/883/boundary-v1.webp", "boundary_map_url"),
        ("https://maps.example/static?path=9.536271,78.201934", "privacy: precise coordinates"),
        ("https://static.example/polygon/farm-123.geojson", "privacy: boundary polygon"),
    ],
)
def test_rejects_unsafe_boundary_map_url(record: dict, url: str, match: str) -> None:
    """The boundary map link must be https and carry no coordinates or polygon (review r1 P1-2).

    Args:
        record: Sample record.
        url: Offending URL.
        match: Expected text in the error.
    """
    record["boundary_map_url"] = url
    with pytest.raises(ValidationError, match=match):
        render(record)


def test_rejects_phone_inside_nested_model(record: dict) -> None:
    """The privacy check also covers nested models a caller built itself."""
    record["lots"][0]["review_note"] = "Farmer phone 9876543210"
    record["lots"][0] = Lot.model_validate(record["lots"][0])
    with pytest.raises(ValidationError, match="privacy: phone number"):
        PublicBatchRecord(**record)


def test_rejects_temporary_photo_path(record: dict) -> None:
    """A temp_uploads URL is refused even though it looks like a valid URL (FR61)."""
    photo = record["lots"][0]["events"][0]["photos"][0]
    photo["jpeg_url"] = "https://cdn.example/temp_uploads/a.jpg"
    with pytest.raises(ValidationError, match="temporary storage path"):
        render(record)


def test_rejects_photo_outside_evidence_bucket(record: dict) -> None:
    """Photo URLs must live under an evidence/ path."""
    record["lots"][0]["events"][0]["photos"][0]["thumb_url"] = "https://cdn.example/fpos/260/a.webp"
    with pytest.raises(ValidationError, match="thumb_url"):
        render(record)


def test_rejects_unknown_field(record: dict) -> None:
    """Fields outside the public allow-list are refused (D-017)."""
    record["lots"][0]["notes"] = "internal only"
    with pytest.raises(ValidationError, match="notes"):
        render(record)


def test_rejects_shares_not_adding_to_100(record: dict) -> None:
    """Lot shares must reconcile to 100 % (FR60)."""
    record["lots"][2]["share_pct"] = 10
    with pytest.raises(ValidationError, match="share_pct"):
        render(record)


def test_opted_out_farmer_shows_as_farmer_n(record: dict) -> None:
    """A lot without name consent shows "Farmer 2" and no name in data.json."""
    result = render(record)
    names = [text(h) for h in parse(result.html).iterfind(".//article/h3")]
    assert names[1] == "விவசாயி 2 / Farmer 2 LOT3072CB6A"
    assert json.loads(result.data_json)["lots"][1]["farmer_name"] is None


def test_pin_is_rounded_to_three_decimals(record: dict) -> None:
    """The exact pin never reaches the page; the map link uses 3 dp."""
    result = render(record)
    assert "9.536271" not in result.html + result.data_json
    assert "https://www.google.com/maps?q=9.536,78.202" in result.html


def test_lab_badge_only_when_certified(record: dict) -> None:
    """The Lab-certified badge and lab name appear only with an accredited lab result (FR51)."""
    assert "Lab-certified" not in render(record).html
    record["grade"].update(lab_certified=True, lab_name="Demo Spice Lab")
    record["grade"]["readings"][0]["source"] = "lab"
    html = render(record).html
    assert "Lab-certified" in html and "Demo Spice Lab" in html


def test_lab_certified_without_lab_reading_is_rejected(record: dict) -> None:
    """The badge needs at least one reading whose source is a lab (FR51)."""
    record["grade"]["lab_certified"] = True
    with pytest.raises(ValidationError, match="source 'lab'"):
        render(record)


def test_procured_and_batch_quantity_shown_and_checked(record: dict) -> None:
    """The header shows both quantities; procured below the batch quantity is refused."""
    dds = [text(dd) for dd in parse(render(record).html).iterfind(".//section//dd")]
    assert "20 kg" in dds and "320 kg" in dds
    record["procured_quantity"]["value"] = 10
    with pytest.raises(ValidationError, match="procured_quantity"):
        render(record)


def test_lab_name_without_certification_is_rejected(record: dict) -> None:
    """A lab name may not appear on an uncertified grade."""
    record["grade"]["lab_name"] = "Demo Spice Lab"
    with pytest.raises(ValidationError, match="lab_name"):
        render(record)


def test_gi_indicator_uses_shape_and_text_not_colour_alone(record: dict) -> None:
    """GI status has an icon shape and words in both states (User Flows §Design rules)."""
    assert "✓" in text(parse(render(record).html).find(".//p[@id='gi']"))
    record["gi_verified"] = False
    gi = text(parse(render(record).html).find(".//p[@id='gi']"))
    assert "▲" in gi and "GI boundary not verified" in gi


def test_address_segments_are_not_repeated(record: dict) -> None:
    """Duplicate address parts collapse ("Tiruchuli, Tiruchuli", PRD §12.2)."""
    record["processor"]["place"]["village"] = "Tiruchuli"
    assert "Tiruchuli, Virudhunagar, Tamil Nadu" in render(record).html
    assert "Tiruchuli, Tiruchuli" not in render(record).html


def test_number_and_date_formats() -> None:
    """Indian grouping and "14 Feb 2026" dates (User Flows §Design rules)."""
    assert indian_number(120000) == "1,20,000"
    assert indian_number(12345678.9) == "1,23,45,678.9"
    assert indian_number(77.6) == "77.6"
    assert indian_number(320.0) == "320"
    assert indian_number(0.25) == "0.25"
    assert day(dt.date(2026, 2, 14)) == "14 Feb 2026"


def test_label_files_have_the_same_keys() -> None:
    """Every label exists in both Tamil and English."""
    i18n = ROOT / "agritrace_page" / "i18n"
    ta = json.loads((i18n / "ta.json").read_text("utf-8"))
    en = json.loads((i18n / "en.json").read_text("utf-8"))
    assert ta.keys() == en.keys()


def test_cli_build_and_check(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    """The CLI writes index.html and data.json and reports budgets with exit code 0.

    Args:
        tmp_path: Output directory.
        capsys: Captured stdout.
    """
    assert main(["build", str(FIXTURE), str(tmp_path)]) == 0
    assert (tmp_path / "index.html").exists() and (tmp_path / "data.json").exists()
    assert main(["check", str(tmp_path)]) == 0
    assert "OVER BUDGET" not in capsys.readouterr().out


def test_cli_check_fails_over_budget(tmp_path: Path) -> None:
    """Check exits non-zero when the page is over budget.

    Args:
        tmp_path: Output directory.
    """
    (tmp_path / "index.html").write_text("<p>" + "x" * BUDGETS["total"] + "</p>", "utf-8")
    assert main(["check", str(tmp_path)]) == 1
