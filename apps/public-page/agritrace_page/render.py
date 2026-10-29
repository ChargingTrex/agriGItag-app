"""Render a public batch record to a static page (index.html) and its data file (data.json).

Purpose: the single renderer behind every public QR page; pure function, no database or network.
Requirements: PRD FR15-FR19, FR30, FR51, FR58, FR62, FR63, FR72; plan §13 E1 (HTML+CSS+JS
< 100 KB, CSS < 12 KB, JS < 4 KB) and E2 (lazy WebP thumbnails, tap to enlarge);
User Flows §Design rules (colour plus shape, "14 Feb" dates, Indian number grouping).
Callers: the backend publishing job (B10) writes ``RenderResult`` to the ``public-pages`` bucket;
the portal preview calls it through the API; ``agritrace_page.cli`` builds from a JSON file.
"""

import datetime as dt
import json
import re
from importlib.resources import files
from typing import Any, NamedTuple

from jinja2 import Environment, PackageLoader, StrictUndefined
from markupsafe import Markup

from agritrace_page.schema import Place, PublicBatchRecord

# Byte budgets from plan §13 E1. "total" is index.html itself, which inlines all CSS and JS.
BUDGETS = {"css": 12 * 1024, "js": 4 * 1024, "total": 100 * 1024}

_LABELS: dict[str, dict[str, str]] = {
    lang: json.loads(files("agritrace_page").joinpath(f"i18n/{lang}.json").read_text("utf-8"))
    for lang in ("ta", "en")
}


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
_ENV.globals.update(t=_label, pair=_pair)


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
