"""Render a public batch record to a static page (index.html) and its data file (data.json).

Purpose: the single renderer behind every public QR page; pure function, no database or network.
Requirements: PRD FR15-FR19, FR30, FR51, FR58, FR62, FR63, FR72; W03 (bilingual labels, OG tags
without personal data, unavailable variant, static map thumbnail); plan §13 E1 (HTML+CSS+JS
< 100 KB, CSS < 12 KB, JS < 4 KB) and E2 (lazy WebP thumbnails, tap to enlarge);
User Flows §Design rules (colour plus shape, "14 Feb" dates, Indian number grouping).
Callers: the backend publishing job (B10) writes ``RenderResult`` to the ``public-pages`` bucket;
the portal preview calls it through the API; ``agritrace_page.cli`` builds from a JSON file.
``render_unavailable``: ``agritrace_page.cli unavailable`` (CDN 404 page) and, once B10 adopts it,
the publishing job for unpublished or withdrawn batches (TODO.md, W03 follow-up).
"""

import datetime as dt
import json
import math
import re
from collections.abc import Iterable
from importlib.resources import files
from typing import Any, Literal, NamedTuple, get_args

from jinja2 import Environment, PackageLoader, StrictUndefined
from markupsafe import Markup

from agritrace_page.schema import Lot, Place, PublicBatchRecord

# Byte budgets from plan §13 E1. "total" is index.html itself, which inlines all CSS and JS.
BUDGETS = {"css": 12 * 1024, "js": 4 * 1024, "total": 100 * 1024}

_LABELS: dict[str, dict[str, str]] = {
    lang: json.loads(files("agritrace_page").joinpath(f"i18n/{lang}.json").read_text("utf-8"))
    for lang in ("ta", "en")
}


# W03 map thumbnail: a shipped district silhouette (assets/district_outline.json, [lon, lat]).
_OUTLINE = json.loads(
    files("agritrace_page").joinpath("assets/district_outline.json").read_text("utf-8")
)
_WEST, _SOUTH, _EAST, _NORTH = _OUTLINE["bbox"]
_MAP_W = 120
# Equirectangular with a cos(mid-latitude) correction, so the district keeps its shape.
_MAP_H = round(
    _MAP_W * (_NORTH - _SOUTH) / ((_EAST - _WEST) * math.cos(math.radians((_NORTH + _SOUTH) / 2)))
)

Reason = Literal["unpublished", "withdrawn", "unknown"]
# Batch codes are system ids (e.g. FGP8T4033HM7); anything else is refused before it reaches a page.
_CODE = re.compile(r"[A-Za-z0-9_-]{1,64}")


class RenderResult(NamedTuple):
    """Output of one render: the page and its machine-readable twin.

    Attributes:
        html: The complete ``index.html``, with all CSS and JS inlined.
        data_json: ``data.json``: the validated record plus computed counts and map links.
    """

    html: str
    data_json: str


# DECISION D-018: Indian grouping and "14 Feb 2026" dates are hand-written, not Babel.
#   ADV: no dependency for a few lines (CLAUDE.md §4 rule 4); output is fixed and tested.
#   COMPROMISE: digits and month names stay Latin/English; other locales would need Babel.
def indian_number(value: float) -> str:
    """Format a number with Indian digit grouping, at most 2 decimals (User Flows §Design rules).

    Args:
        value: The number, e.g. 120000 or 77.6.

    Returns:
        The grouped text, e.g. "1,20,000" or "77.6".

    Raises:
        Nothing.
    """
    sign = "-" if value < 0 else ""
    whole, _, frac = f"{abs(value):.2f}".rstrip("0").rstrip(".").partition(".")
    head, tail = whole[:-3], whole[-3:]
    while head:
        head, tail = head[:-2], f"{head[-2:]},{tail}"
    return sign + tail + (f".{frac}" if frac else "")


def day(value: dt.date) -> str:
    """Format a date as "14 Feb 2026".

    Args:
        value: The date.

    Returns:
        Day without a leading zero, English month abbreviation, year.

    Raises:
        Nothing.
    """
    return f"{value.day} {value:%b %Y}"


def utc(value: dt.datetime) -> str:
    """Format an aware timestamp in UTC as "30 Jul 2026, 09:27 UTC".

    Args:
        value: A timezone-aware datetime.

    Returns:
        The UTC time in page format.

    Raises:
        Nothing.
    """
    value = value.astimezone(dt.UTC)
    return f"{day(value)}, {value:%H:%M} UTC"


def place(value: Place) -> str:
    """Join an address, dropping repeated segments (PRD §12.2 "Tiruchuli, Tiruchuli").

    Args:
        value: Structured address.

    Returns:
        "village, block, district, state" with duplicates removed, order kept.

    Raises:
        Nothing.
    """
    return ", ".join(dict.fromkeys([value.village, value.block, value.district, value.state]))


def _pair(ta: str, en: str) -> Markup:
    """Show the same text in Tamil, then English (User Flows §Design rules: language first).

    Args:
        ta: Tamil (local-language) text.
        en: English text.

    Returns:
        Two escaped ``<span lang=..>`` elements joined by " / ".

    Raises:
        Nothing.
    """
    return Markup('<span lang="ta">{}</span> / <span lang="en">{}</span>').format(ta, en)


def _label(key: str, **fmt: Any) -> Markup:
    """Look up a bilingual UI label from i18n/ta.json and i18n/en.json.

    Args:
        key: Label key, e.g. "stage.harvest".
        **fmt: Values for ``{placeholders}`` in the label, e.g. ``n=2``.

    Returns:
        The label in Tamil, then English.

    Raises:
        KeyError: When a label file lacks ``key`` (fails the build rather than show a gap).
    """
    return _pair(_LABELS["ta"][key].format(**fmt), _LABELS["en"][key].format(**fmt))


def _plain(key: str) -> str:
    """Look up a bilingual label as plain text, for attributes such as ``<meta content>`` or alt.

    Args:
        key: Label key, e.g. "og_description".

    Returns:
        "Tamil / English" as one unescaped string (Jinja autoescape escapes it on output).

    Raises:
        KeyError: When a label file lacks ``key``.
    """
    return f"{_LABELS['ta'][key]} / {_LABELS['en'][key]}"


def _xy(lat: float, lon: float) -> tuple[int, int]:
    """Project a coordinate onto the map thumbnail's grid of whole units.

    Args:
        lat: Latitude in decimal degrees.
        lon: Longitude in decimal degrees.

    Returns:
        (x, y) in SVG user units, rounded to whole units (about 1.1 km each), y growing south.

    Raises:
        Nothing.
    """
    x = (lon - _WEST) / (_EAST - _WEST) * _MAP_W
    y = (_NORTH - lat) / (_NORTH - _SOUTH) * _MAP_H
    return round(x), round(y)


# DECISION D-045: the map thumbnail is an inline SVG of a shipped district silhouette with one
#   whole-unit (~1 km) dot per lot village, not a map tile or an embedded map.
#   ADV: no third-party request or tile licence, prints, works offline; the dot is coarser than the
#   3 dp map link, so it can never become a plot pin or boundary (CLAUDE.md §6).
#   COMPROMISE: the silhouette is schematic until the record carries an official outline.
_MAP = {
    "w": _MAP_W,
    "h": _MAP_H,
    "d": "M" + "L".join("{},{}".format(*_xy(lat, lon)) for lon, lat in _OUTLINE["outline"]) + "Z",
}


def map_dots(lots: Iterable[Lot]) -> list[tuple[int, int]]:
    """Give the distinct village dots of a batch's lots that fall on the thumbnail.

    Args:
        lots: The record's lots; each ``map_point`` is already rounded to 3 dp by the schema.

    Returns:
        Sorted, de-duplicated (x, y) whole-unit positions inside the map; lots outside the shipped
        outline's box are left off rather than pinned to its edge.

    Raises:
        Nothing.
    """
    dots = (_xy(lot.map_point.lat, lot.map_point.lon) for lot in lots)
    return sorted({(x, y) for x, y in dots if 0 <= x <= _MAP_W and 0 <= y <= _MAP_H})


# DECISION D-007: the page is plain server-rendered HTML with inline CSS/JS, built once per publish.
#   ADV: one request, no framework JS, readable with JS off; fits the < 100 KB budget (plan §13 E1).
#   COMPROMISE: every change needs a rebuild; long timelines use native <details>, not JS paging.
_ENV = Environment(
    loader=PackageLoader("agritrace_page"),
    autoescape=True,
    undefined=StrictUndefined,
    trim_blocks=True,
    lstrip_blocks=True,
)
_ENV.filters.update(num=indian_number, day=day, utc=utc, place=place)
_ENV.globals.update(t=_label, pair=_pair, plain=_plain, map=_MAP, map_dots=map_dots)


def render(record: PublicBatchRecord | dict) -> RenderResult:
    """Render one batch's public page and data file.

    Args:
        record: A dict or a ``PublicBatchRecord``; both are (re)validated and privacy-checked here.

    Returns:
        ``RenderResult(html, data_json)``; ``data_json`` includes the computed counts and map links.

    Raises:
        pydantic.ValidationError: When the record is invalid or carries personal data.
        KeyError: When a label key is missing from a label file.
    """
    rec = PublicBatchRecord.model_validate(record)
    html = _ENV.get_template("batch.html.j2").render(r=rec)
    return RenderResult(html=html, data_json=rec.model_dump_json())


def render_unavailable(code: str | None, reason: Reason) -> str:
    """Render the page shown instead of a batch page that is not published, withdrawn or unknown.

    Args:
        code: The batch code to show, or None for a generic page (e.g. the CDN's 404 for any code).
        reason: "unpublished" (not yet published), "withdrawn" (taken down after publishing) or
            "unknown" (no batch has this code).

    Returns:
        A complete, ``noindex`` ``index.html`` with inline CSS and no batch data.

    Raises:
        ValueError: When ``reason`` is not one of the three, or ``code`` is not 1-64 letters,
            digits, "_" or "-".
    """
    if reason not in get_args(Reason):
        raise ValueError(f"reason must be one of {get_args(Reason)}")
    if code is not None and not _CODE.fullmatch(code):
        raise ValueError("code must be 1-64 letters, digits, '_' or '-'")
    return _ENV.get_template("unavailable.html.j2").render(code=code, reason=reason)


def measure(html: str) -> dict[str, int]:
    """Measure a rendered page against ``BUDGETS``.

    Args:
        html: A page produced by ``render``.

    Returns:
        UTF-8 byte sizes: {"css": inline <style>, "js": inline <script>, "total": whole page}.

    Raises:
        Nothing.
    """
    css = sum(len(s.encode()) for s in re.findall(r"<style>(.*?)</style>", html, re.S))
    js = sum(len(s.encode()) for s in re.findall(r"<script>(.*?)</script>", html, re.S))
    return {"css": css, "js": js, "total": len(html.encode())}
