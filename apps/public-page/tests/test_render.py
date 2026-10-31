"""Tests for the public page renderer, schema privacy rules and CLI.

Purpose: W01 acceptance (valid HTML, bilingual crop, units everywhere, date order, no temporary or
non-evidence paths) plus counts (FR63), budgets (plan §13 E1), consent names, lab badge (FR51).
W02 canaries (end of file): the built page passes the privacy lint with fixtures/canaries.json, each
canary planted in the record never reaches the page, and each canary injected into a template copy
fails the lint (BM-09, "injected phone fails CI").
W03 (end of file): OG tags without personal data, Tamil strings in lang="ta" with system fonts,
print CSS, map thumbnail dots, same-day stage order, and the unavailable page and its CLI.
Requirements: FR15-FR19, FR51, FR58, FR61-FR63, FR72; BM-09; CLAUDE.md §6; W03 acceptance.
Callers: ``uv run pytest`` locally and in the public-page CI job; the W01-W03 Verifiers.
"""

import copy
import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from xml.etree.ElementTree import Element

import html5lib
import pytest
from pydantic import ValidationError

from agritrace_page import BUDGETS, measure, render, render_unavailable
from agritrace_page.cli import main
from agritrace_page.render import day, indian_number
from agritrace_page.schema import Lot, PublicBatchRecord

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "fixtures" / "batch_sample.json"
_SAMPLE = json.loads(FIXTURE.read_text("utf-8"))
MOBILE = re.compile(r"(?<!\d)[6-9]\d{9}(?!\d)")
CANARIES = json.loads((ROOT / "fixtures" / "canaries.json").read_text("utf-8"))["canaries"]
CHECK_OUTPUT = ROOT / "tools" / "check_output.sh"


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


def _check_output(out_dir: Path) -> subprocess.CompletedProcess[str]:
    """Run tools/check_output.sh (privacy lint with the canaries) as CI does.

    Args:
        out_dir: Folder holding a built page.

    Returns:
        The completed process with text stdout and stderr.
    """
    return subprocess.run(
        ["bash", str(CHECK_OUTPUT), str(out_dir)], capture_output=True, text=True, check=False
    )


def test_clean_build_passes_privacy_lint_with_canaries(tmp_path: Path) -> None:
    """The fixture build has zero privacy-lint hits, canaries included ("canary fixture passes").

    Args:
        tmp_path: Output directory.
    """
    assert main(["build", str(FIXTURE), str(tmp_path)]) == 0
    done = _check_output(tmp_path)
    assert done.returncode == 0, done.stdout + done.stderr
    assert "0 hit(s) in 2 file(s) scanned" in done.stdout


@pytest.mark.parametrize("canary", CANARIES, ids=[c["kind"] for c in CANARIES])
def test_canary_planted_in_record_never_reaches_the_page(record: dict, canary: dict) -> None:
    """A canary in a record field is refused by the schema, or (the 6-dp pin) coarsened away.

    Args:
        record: Sample record copy.
        canary: One entry of fixtures/canaries.json.
    """
    *parents, last = canary["plant"]["path"]
    node = record
    for key in parents:
        node = node[key]
    node[last] = canary["plant"]["value"]
    if canary["plant"]["expect"] == "refused":
        with pytest.raises(ValidationError) as caught:
            render(record)
        assert canary["value"] not in str(caught.value)
    else:
        result = render(record)
        assert canary["value"] not in result.html + result.data_json


@pytest.mark.parametrize("canary", CANARIES, ids=[c["kind"] for c in CANARIES])
def test_canary_injected_into_template_fails_privacy_lint(tmp_path: Path, canary: dict) -> None:
    """A template copy that prints a canary builds a page the lint rejects without echoing the leak.

    Args:
        tmp_path: Holds the package copy and its output; the real template is never touched.
        canary: One entry of fixtures/canaries.json.
    """
    package = tmp_path / "pkg"
    shutil.copytree(
        ROOT / "agritrace_page",
        package / "agritrace_page",
        ignore=shutil.ignore_patterns("__pycache__"),
    )
    template = package / "agritrace_page" / "templates" / "batch.html.j2"
    source = template.read_text("utf-8")
    template.write_text(source.replace("</main>", f"<p>{canary['value']}</p>\n</main>"), "utf-8")
    out = tmp_path / "out"
    subprocess.run(
        [sys.executable, "-m", "agritrace_page", "build", str(FIXTURE), str(out)],
        cwd=package,
        env={**os.environ, "PYTHONPATH": str(package)},
        check=True,
    )
    assert canary["value"] in (out / "index.html").read_text("utf-8")  # the copy was used
    done = _check_output(out)
    assert done.returncode == 1, done.stdout
    assert f": {canary['rule']}: " in done.stdout and ": canary: <redacted>" in done.stdout
    assert canary["value"] not in done.stdout


# --- W03: OG tags, lang attributes, print CSS, unavailable page, map thumbnail ---

TAMIL = re.compile(r"[஀-௿]")
SVG = "{http://www.w3.org/2000/svg}"


def _meta(root: Element) -> dict[str, str]:
    """Collect ``<meta>`` contents by their ``property`` or ``name``.

    Args:
        root: A parsed page.

    Returns:
        {"og:title": ..., "description": ..., ...}.
    """
    return {
        m.get("property") or m.get("name"): m.get("content")
        for m in root.iterfind(".//meta")
        if m.get("content") is not None
    }


def test_og_tags_name_crop_gi_and_code(record: dict) -> None:
    """og:title is crop + GI tag + batch code; og:url and og:image are the public URL and QR."""
    meta = _meta(parse(render(record).html))
    assert meta["og:title"] == (
        "விருதுநகர் சம்பா வத்தல் / Virudhunagar Samba Vathal · GI 883 · FGP8T4033HM7"
    )
    assert meta["og:url"] == record["public_url"]
    assert meta["og:image"] == record["qr_url"]
    assert meta["og:type"] == "website" and meta["og:description"] == meta["description"]


def test_no_personal_data_in_any_meta(record: dict) -> None:
    """No farmer name, village, block, lot code or number reaches a <meta> (CLAUDE.md §6)."""
    record["lots"][1]["farmer_name"] = "Murugan Example"
    meta = _meta(parse(render(record).html))
    personal = {record["processor"]["name"]}
    for lot in record["lots"]:
        personal |= {lot["lot_code"], lot["place"]["village"], lot["place"]["block"]}
        personal |= {lot["farmer_name"]} - {None}
    assert "Murugan Example" in personal
    for key, content in meta.items():
        assert not any(p in content for p in personal), key
        assert not MOBILE.search(re.sub(r"[\s-]", "", content)), key
    assert not re.search(r"\d", meta["og:description"])  # no number of any kind


def test_og_url_and_image_are_left_out_without_urls(record: dict) -> None:
    """A record without public_url/qr_url renders no og:url, og:image, QR or page link."""
    del record["public_url"], record["qr_url"]
    root = parse(render(record).html)
    assert {"og:url", "og:image"}.isdisjoint(_meta(root))
    assert root.find(".//*[@class='qr']") is None and root.find(".//footer//a") is None


@pytest.mark.parametrize(
    ("field", "url"),
    [
        ("public_url", "javascript:alert(1)"),
        ("qr_url", "javascript:alert(1)"),
        ("qr_url", "https://x.example/q.png');background:url('https://y.example/t"),
    ],
)
def test_rejects_unsafe_page_urls(record: dict, field: str, url: str) -> None:
    """public_url and qr_url go into href/meta/CSS url(): only plain http(s) URLs are accepted.

    Args:
        record: The sample record.
        field: The URL field under test.
        url: An unsafe value: another scheme, or a quote that would end the CSS url().
    """
    record[field] = url
    with pytest.raises(ValidationError):
        render(record)


def _assert_tamil_is_tagged(el: Element, lang: str) -> None:
    """Check that every text run containing Tamil sits inside an element with lang="ta".

    Args:
        el: Element to check, recursively.
        lang: The language ``el`` inherits from its ancestors.

    Raises:
        AssertionError: Naming the first Tamil text found outside a lang="ta" element.
    """
    lang = el.get("lang", lang)
    if TAMIL.search(el.text or ""):
        assert lang == "ta", el.text
    for child in el:
        _assert_tamil_is_tagged(child, lang)
        if TAMIL.search(child.tail or ""):
            assert lang == "ta", child.tail


def test_tamil_strings_carry_lang_ta_and_use_system_fonts(record: dict) -> None:
    """Tamil strings sit in lang="ta" elements, paired with English; no webfont is downloaded."""
    html = render(record).html
    root = parse(html)
    assert root.get("lang") == "en"
    _assert_tamil_is_tagged(root.find("body"), "en")
    ta = json.loads((ROOT / "agritrace_page" / "i18n" / "ta.json").read_text("utf-8"))
    for key in ("batch", "gi_verified", "map_caption", "public_link", "last_updated"):
        assert f'<span lang="ta">{ta[key]}</span>' in html
    assert "@font-face" not in html and 'rel="stylesheet"' not in html
    assert '"Noto Sans Tamil"' in html and "system-ui" in html


def test_print_css_shows_qr_and_link_hides_extra_photos(record: dict) -> None:
    """Print: black on white, QR shown, one photo per event, whole lot cards, timelines opened."""
    html = render(record).html
    css = html[html.index("@media print{") :]
    for rule in ("--fg:#000", ".qr{display:block", ".ph~.ph{display:none}", "break-inside:avoid"):
        assert rule in css, rule
    assert ".qr{display:none}" in html  # the screen view hides the QR the buyer just scanned
    assert 'addEventListener("beforeprint"' in html
    footer = parse(html).find(".//footer")
    qr = footer.find(".//*[@class='qr']")
    assert qr.get("style") == f"background-image:url('{record['qr_url']}')"
    assert qr.get("role") == "img" and qr.get("aria-label")
    assert footer.find(".//a").get("href") == record["public_url"]


def test_map_thumbnail_marks_villages_with_coarse_dots(record: dict) -> None:
    """One whole-unit dot per distinct lot village inside the outline's box; no coordinates."""
    record["lots"][1]["map_point"] = dict(record["lots"][0]["map_point"])  # same village twice
    record["lots"][2]["map_point"] = {"lat": 13.08, "lon": 80.27}  # Chennai: off the map
    root = parse(render(record).html)
    svg = root.find(f".//{SVG}svg")
    w, h = (int(v) for v in svg.get("viewBox").split()[2:])
    dots = [(c.get("cx"), c.get("cy")) for c in svg.iter(f"{SVG}circle")]
    assert len(dots) == 1
    assert all(v.isdigit() for dot in dots for v in dot)  # whole units (~1 km), never a pin
    assert 0 <= int(dots[0][0]) <= w and 0 <= int(dots[0][1]) <= h
    assert re.fullmatch(r"M[\d,L]+Z", svg.find(f"{SVG}path").get("d"))
    assert svg.get("aria-labelledby") == root.find(".//figcaption").get("id")


def test_same_day_events_keep_stage_order(record: dict) -> None:
    """Same-day events of different stages follow the crop cycle, not instance numbers (B10)."""
    first = record["lots"][0]["events"][0]
    base = {k: first[k] for k in ("date", "status", "system_generated")}
    drying = {**base, "stage": "drying", "instance_no": 1}
    harvest = {**base, "stage": "harvest", "instance_no": 3}
    lot = Lot.model_validate({**record["lots"][0], "events": [drying, harvest]})
    assert [e.stage for e in lot.events] == ["harvest", "drying"]


@pytest.mark.parametrize("reason", ["unpublished", "withdrawn", "unknown"])
def test_unavailable_page_variants(reason: str) -> None:
    """Each reason renders a valid, noindex, bilingual page with the code and no batch data.

    Args:
        reason: The unavailable reason under test.
    """
    html = render_unavailable("FGP8T4033HM7", reason)
    root = parse(html)
    assert _meta(root)["robots"] == "noindex"
    ta = json.loads((ROOT / "agritrace_page" / "i18n" / "ta.json").read_text("utf-8"))
    assert f'<span lang="ta">{ta["unavailable." + reason]}</span>' in html
    assert "FGP8T4033HM7" in text(root.find(".//main"))
    _assert_tamil_is_tagged(root.find("body"), root.get("lang"))
    assert measure(html)["total"] < BUDGETS["total"] and "<script>" not in html


def test_unavailable_page_without_code_and_bad_input() -> None:
    """The generic 404 page shows no code; a bad reason or a code that is not an id is refused."""
    assert "<strong>" not in render_unavailable(None, "unknown")
    with pytest.raises(ValueError):
        render_unavailable("FGP8T4033HM7", "deleted")  # type: ignore[arg-type]
    with pytest.raises(ValueError):
        render_unavailable("<script>", "unknown")


def test_cli_unavailable(tmp_path: Path) -> None:
    """``python -m agritrace_page unavailable`` writes the page the CDN serves for unknown codes.

    Args:
        tmp_path: Output directory.
    """
    assert main(["unavailable", "unknown", str(tmp_path)]) == 0
    assert 'content="noindex"' in (tmp_path / "index.html").read_text("utf-8")
