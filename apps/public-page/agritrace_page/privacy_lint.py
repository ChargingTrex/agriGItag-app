#!/usr/bin/env python3
"""Scan built public pages and partner payloads for personal data and exact locations.

Purpose: fail when published output leaks a phone number, an Aadhaar-like ID, survey/patta labels
(English or Tamil), precise coordinates, a polygon or walked line, a temp path or a canary string.
This is the project's single privacy linter: W02 wires it into the public-page CI job and extends it
here (with tests in qa/tests) instead of writing a second one (W02 acceptance, Orchestrator amendment).
It lives in agritrace_page so the API image (which ships this package, not infra/) can import it;
infra/scripts/privacy-lint.py is a symlink to this file, so every existing caller runs the same code (B18).
Serves: BM-09 (privacy lint 0 hits), plan §7.4 W02 and §7.5 Q03, gate G4, CLAUDE.md §6 privacy invariants.
Callers: apps/api `publishing.builder.privacy_hits` (`scan_text` on every built page, B18),
qa/tests/test_privacy_lint.py (CI docs job), qa/robot/public/page.robot, W02's public-page CI job,
Verifiers on downloaded `public-pages/batches/<code>/` folders.

Usage: python3 infra/scripts/privacy-lint.py <dir> [--canary STRING ...]
Exit codes: 0 no hits; 1 hits found (printed as path:line:col: rule: excerpt); 2 bad arguments,
missing directory, or no scannable text file under it.
"""

import argparse
import bisect
import codecs
import json
import pathlib
import re
import sys

# Every file is scanned unless its suffix is a binary type below or it fails the text sniff
# (looks_like_text), so .jsonl, .yaml, .vcf, .map and files without a suffix are covered.
BINARY_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".avif", ".bmp", ".tif", ".tiff", ".ico", ".heic",
    ".woff", ".woff2", ".ttf", ".otf", ".eot",
    ".zip", ".gz", ".tgz", ".bz2", ".xz", ".7z", ".rar", ".tar", ".br", ".zst", ".pdf",
    ".mp3", ".ogg", ".opus", ".wav", ".m4a", ".aac", ".flac", ".mp4", ".webm", ".mov", ".avi", ".mkv",
}
JSON_SUFFIXES = {".json", ".geojson", ".webmanifest"}

# Digits are matched on a "shadow" copy of the text with separators removed, so 98765 43210,
# (987) 654-3210, 98765.43210, 98765–43210 (en dash) and zero-width-split numbers all become ten
# plain digits. Dashes U+2010-U+2015, the minus sign U+2212, NBSP, narrow NBSP, thin and figure spaces
# count, and so do the HTML entities for a no-break space, en dash and em dash.
SEPARATORS = set(" \t\u00a0\u2007\u2009\u202f-.()\u2010\u2011\u2012\u2013\u2014\u2015\u2212"
                 "\u200b\u200c\u200d\u2060\ufeff")
SEPARATOR_ENTITIES = re.compile(r"&nbsp;|&#160;|&#x0*a0;|&ndash;|&mdash;|&#821[12];", re.IGNORECASE)
PHONE = re.compile(r"(?<!\d)(?:\+?91|0091|0)?[6-9]\d{9}(?!\d)")
AADHAAR = re.compile(r"(?<!\d)[2-9]\d{11}(?!\d)")
# Spans whose digits are not personal data: http(s) URL paths (hashed evidence names; query strings
# are still scanned), UUIDs and long hex hashes. WhatsApp click-to-chat paths (wa.me/<number>,
# whatsapp.com/...) carry a phone number and are never masked; tel: links are not http(s), so never masked.
NEUTRAL = re.compile(
    r"https?://(?!(?:www\.)?wa\.me/|(?:api\.|web\.|www\.)?whatsapp\.com/)[^\s\"'<>?#]+"
    r"|\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b"
    r"|\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*\d)[0-9a-f]{16,}\b",
    re.IGNORECASE,
)

NUM = r"-?\d{1,3}\.\d+"
PRECISE = r"-?\d{1,3}\.\d{4,}"
# A pair is split by a comma (also URL-encoded), whitespace, `+` or %20 (`GPS 9.5598061 78.1335214`,
# `?q=9.5598061+78.1335214`).
SEP = r"(?:\s*(?:,|%2C)\s*|\s+|\+|%20)"
# Degree sign and arc-minute mark, also as entities, because Jinja autoescape writes ' as &#39;.
DEG = r"(?:°|º|&deg;|&#0*176;|&#x0*b0;)"
MINUTE = r"(?:'|′|’|&#0*39;|&#x0*27;|&apos;|&prime;|&rsquo;)"
# A label word is only a leak signal in context (W01-1: "Mobile-first" in a CSS comment is not data):
# as a JSON key, inside <th>/<dt>/<label>, or followed by the number it labels. Land-record labels
# (survey/patta/chitta, S.F./Sy. No.) take a number right after them, because survey numbers are
# short (`123/4A`, `452`). Phone-type labels take a 4+ digit run within 40 characters. Neither counts
# a year or a date as that number (`Pest survey 2026`, `phone OTP on 2026-10-12`).
WORD = (
    r"(?P<w>\b(?:survey|patta|chitta|aadhaa?r|phone|mobile|S\.?\s?F\.?\s?No|Sy\.?\s?No)"
    r"|தொலைபேசி|அலைபேசி|கைபேசி|பட்டா|சிட்டா|சர்வே|ஆதார்|புல எண்)"
)
# After a bare label (`Pest survey 2026`) a year (19xx/20xx, which also starts an ISO date) or a
# day-first date is not a labelled number. After an explicit No./Number/எண் any number counts, because
# patta and survey numbers run into the thousands (`Patta No. 1987`). Whole month names only, so
# `3 Mariamman Koil Street` is not a date.
NOT_A_NUMBER = (
    r"(?:19|20)\d\d(?!\d)|\d{1,2}[./-]\d{1,2}[./-]\d{2,4}"
    r"|\d{1,2}\s*(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?"
    r"|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\b"
)
LABEL_RULES = [
    # In a JSON key the word needs no boundary: snake_case keys such as "farmer_phone" count.
    re.compile(rf"\"[^\"\n]{{0,40}}?{WORD.replace(r'\b', '')}[^\"\n]{{0,40}}\"\s*:", re.IGNORECASE),
    re.compile(rf"<(?:th|dt|label)\b[^>]*>[^<]{{0,80}}?{WORD}", re.IGNORECASE),
    # Trailing context is a lookahead so neighbouring labels do not swallow each other's digits.
    # Explicit No./Number/எண்: any number counts. R.S./T.S. (re-survey, town survey) only appear
    # here, because a bare `Rs.` is rupees.
    re.compile(
        r"(?P<w>\b(?:survey|patta|chitta|S\.?\s?F\.?|Sy\.?|[RT]\.?\s?S\.?)\s*(?:no\b\.?|number|num\b\.?)"
        r"|(?:சர்வே|பட்டா|சிட்டா|புல)\s*எண்)"
        r"(?=\s*[:#.\-]?\s*\d)",
        re.IGNORECASE,
    ),
    # Bare label: the year/date guard applies.
    re.compile(
        r"(?P<w>\b(?:survey|patta|chitta|S\.?\s?F\.?|Sy\.?)|(?:சர்வே|பட்டா|சிட்டா))"
        rf"(?=\s*[:#.\-]?\s*(?!{NOT_A_NUMBER})\d+(?:/[0-9A-Za-z]+)?)",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?P<w>\b(?:phone|mobile|aadhaa?r)|தொலைபேசி|அலைபேசி|கைபேசி|ஆதார்)"
        rf"(?=[\s\S]{{0,40}}?(?<!\d)(?!{NOT_A_NUMBER})\d{{4}})",
        re.IGNORECASE,
    ),
]
# Bodies the label rule never reads: <style>/<script> elements, CSS/JS block comments, JS line comments
# (`//` not preceded by ':' so URLs survive).
NOT_CONTENT = re.compile(
    r"(<(style|script)\b[^>]*>).*?(?=</\2\s*>)|/\*.*?\*/|(?<![:\"'\w])//[^\n]*", re.IGNORECASE | re.DOTALL
)
TEXT_RULES = {
    # More than 3 decimal places (~110 m) pinpoints a farm. In order: lat/lng pairs (comma, %2C, space,
    # across lines); `zoom/lat/lon` map hashes (OSM `#map=17/9.559806/78.133521`, MapLibre `#17/…`);
    # lat/lng keys or parameters with any prefix (OSM `mlat=`/`mlon=`, `pin_lat`; Q00-1, hence no \b);
    # a whole-word label then a number (`lat 9.536271`); decimal degrees with a degree sign; DMS with
    # seconds or decimal minutes (1" is ~30 m); WKT geometries.
    "coordinate_precision": re.compile(
        rf"(?<![\w.])(?:{PRECISE}{SEP}{NUM}|{NUM}{SEP}{PRECISE})(?!\d)"
        rf"|(?<![\w.])\d{{1,2}}(?:\.\d+)?/(?:{PRECISE}/{NUM}|{NUM}/{PRECISE})(?!\d)"
        rf"|(?:lat|lng|lon)\w*[\"']?\s*[:=]\s*[\"']?{PRECISE}"
        rf"|\b(?:lat|latitude|lng|lon|longitude)\b\.?\s+{PRECISE}"
        rf"|{PRECISE}\s*{DEG}"
        rf"|\d{{1,3}}\s*{DEG}\s*\d{{1,2}}(?:\s*{MINUTE}\s*\d{{1,2}}|\.\d{{2,}})"
        rf"|\b(?:MULTI)?(?:POINT|LINESTRING|POLYGON)\s*Z?\s*\(+[^)]*?{PRECISE}",
        re.IGNORECASE,
    ),
    "polygon": re.compile(
        r"\"type\"\s*:\s*\"(?:Multi)?(?:Polygon|LineString)\""
        r"|\b(?:MULTI)?(?:POLYGON|LINESTRING)\s*Z?\s*\("
        rf"|\[\s*\[\s*{NUM}\s*,\s*{NUM}\s*\]\s*,\s*\[\s*{NUM}",
        re.IGNORECASE,
    ),
    "temp_path": re.compile(r"temp_uploads|/tmp/"),
}
COORD_KEY = re.compile(r"(?:^|[_-])(?:lat|lng|lon|latitude|longitude|coordinates|geometry|geom|boundary|x|y)(?:$|[_-])")
REDACTED = {"phone", "aadhaar", "canary"}


class _Num(float):
    """A JSON float that remembers its source text, so decimal places are counted as written."""

    src = ""


def _parse_float(text: str) -> _Num:
    """Build a `_Num` for json.loads.

    Args:
        text: the number as written in the JSON source.

    Returns:
        The float value carrying its source text in ``.src``.
    """
    num = _Num(text)
    num.src = text
    return num


def _precise(num: object) -> bool:
    """Tell whether a JSON value is a float written with more than 3 decimal places.

    Args:
        num: any decoded JSON value.

    Returns:
        True for a `_Num` with 4 or more digits after the point.
    """
    return isinstance(num, _Num) and len(num.src.partition(".")[2].split("e")[0].split("E")[0]) > 3


def digit_hits(text: str) -> list[tuple[int, str, str]]:
    """Find phone and Aadhaar numbers, tolerant of separators, prefixes and zero-width characters.

    Args:
        text: whole file content.

    Returns:
        List of (offset in text, rule, matched shadow digits). An Aadhaar match inside a phone match
        (e.g. +919876543210) is dropped so one number reports once.
    """
    masked = [False] * len(text)
    for m in NEUTRAL.finditer(text):
        masked[m.start() : m.end()] = [True] * (m.end() - m.start())
    dropped = [False] * len(text)
    for m in SEPARATOR_ENTITIES.finditer(text):
        dropped[m.start() : m.end()] = [True] * (m.end() - m.start())
    chars, index = [], []
    for i, ch in enumerate(text):
        if ch not in SEPARATORS and not dropped[i]:
            chars.append("#" if masked[i] else ch)
            index.append(i)
    shadow = "".join(chars)
    phones = [(m.start(), m.end()) for m in PHONE.finditer(shadow)]
    hits = [(index[s], "phone", shadow[s:e]) for s, e in phones]
    for m in AADHAAR.finditer(shadow):
        if not any(s < m.end() and m.start() < e for s, e in phones):
            hits.append((index[m.start()], "aadhaar", m.group()))
    return hits


def label_hits(text: str) -> list[tuple[int, str, str]]:
    """Find sensitive labels (English and Tamil) used as labels, not as ordinary words.

    Args:
        text: whole file content.

    Returns:
        List of (offset, "sensitive_label", label word). The excerpt is only the word, so a phone
        number next to it is never echoed. <style>/<script> bodies and CSS/JS comments are blanked
        first (same length, so offsets stay valid).
    """
    blank = NOT_CONTENT.sub(lambda m: (m.group(1) or "") + " " * (m.end() - m.start() - len(m.group(1) or "")), text)
    return [(m.start("w"), "sensitive_label", m.group("w")) for rx in LABEL_RULES for m in rx.finditer(blank)]


def json_hits(text: str) -> list[tuple[int, str, str]]:
    """Walk a JSON document for precise coordinates and coordinate rings, whatever the formatting.

    Args:
        text: whole content of a .json/.geojson/.webmanifest file.

    Returns:
        List of (offset, rule, excerpt): ``coordinate_precision`` for a float with more than 3 decimals
        under a coordinate-like key or in a 2-3 number array; ``polygon`` for an array of two or more
        numeric pairs. Empty when the text is not valid JSON (the text rules still run).
    """
    try:
        data = json.loads(text, parse_float=_parse_float)
    except ValueError:
        return []
    hits, cursor = [], [0]

    def locate(num: _Num) -> int:
        """Advance the cursor to a number's source text; walk order equals document order.

        Args:
            num: the number to find.

        Returns:
            Its offset in text (the cursor if not found).
        """
        found = text.find(num.src, cursor[0])
        if found >= 0:
            cursor[0] = found + len(num.src)
        return found if found >= 0 else cursor[0]

    def walk(node: object, coord_key: bool) -> None:
        """Visit every value, recording hits.

        Args:
            node: current JSON value.
            coord_key: True when some enclosing key looks like a coordinate key.

        Side effects:
            Appends to ``hits`` and moves ``cursor``.
        """
        if isinstance(node, dict):
            for key, value in node.items():
                walk(value, coord_key or bool(COORD_KEY.search(str(key).lower())))
        elif isinstance(node, list):
            start = max(text.find("[", cursor[0]), 0)
            numeric = [n for n in node if isinstance(n, (int, float)) and not isinstance(n, bool)]
            pairs = [p for p in node if isinstance(p, list) and 2 <= len(p) <= 3 and all(isinstance(n, _Num) for n in p)]
            if len(pairs) >= 2:
                hits.append((start, "polygon", f"array of {len(pairs)} coordinate pairs"))
            for item in node:
                if isinstance(item, _Num):
                    offset = locate(item)
                    if _precise(item) and (coord_key or len(numeric) in (2, 3)):
                        hits.append((offset, "coordinate_precision", item.src))
                else:
                    walk(item, coord_key)
        elif isinstance(node, _Num):
            offset = locate(node)
            if coord_key and _precise(node):
                hits.append((offset, "coordinate_precision", node.src))

    walk(data, False)
    return hits


def scan_text(text: str, canaries: list[str], as_json: bool) -> list[tuple[int, str, str]]:
    """Run every rule over one file's content.

    Args:
        text: whole file content.
        canaries: literal strings that must never appear (e.g. a seeded farmer's real name).
        as_json: also walk the content as JSON.

    Returns:
        List of (offset, rule, matched text), unsorted.
    """
    hits = digit_hits(text) + label_hits(text)
    hits += [(m.start(), rule, m.group()) for rule, rx in TEXT_RULES.items() for m in rx.finditer(text)]
    for canary in filter(None, canaries):
        start = text.find(canary)
        while start != -1:
            hits.append((start, "canary", canary))
            start = text.find(canary, start + 1)
    return hits + (json_hits(text) if as_json else [])


def looks_like_text(path: pathlib.Path) -> bool:
    """Tell whether a file is text: its first 512 bytes hold no NUL and decode as UTF-8.

    Args:
        path: the file to sniff.

    Returns:
        True for text. A multi-byte character cut at byte 512 does not count against it.

    Raises:
        OSError: the file cannot be read.
    """
    with path.open("rb") as handle:
        head = handle.read(512)
    try:
        codecs.getincrementaldecoder("utf-8")().decode(head, final=False)
    except UnicodeDecodeError:
        return False
    return b"\0" not in head


def scan_dir(root: pathlib.Path, canaries: list[str]) -> tuple[int, int, list[str]]:
    """Scan every text file under a directory.

    Args:
        root: directory holding built public pages.
        canaries: literal strings that must never appear.

    Returns:
        (files scanned, files skipped as non-text, report lines "path:line:col: rule: excerpt").
        A rule reports once per line. Phone, Aadhaar and canary excerpts are redacted so CI logs do not
        repeat the leak.

    Raises:
        OSError: a file cannot be read.
    """
    files = sorted(p for p in root.rglob("*") if p.is_file())
    texts = [p for p in files if p.suffix.lower() not in BINARY_SUFFIXES and looks_like_text(p)]
    report = []
    for path in texts:
        text = path.read_text(encoding="utf-8", errors="replace")
        starts = [0] + [i + 1 for i, ch in enumerate(text) if ch == "\n"]
        seen = set()
        for offset, rule, match in sorted(scan_text(text, canaries, path.suffix.lower() in JSON_SUFFIXES)):
            line = bisect.bisect_right(starts, offset)
            if (line, rule) in seen:
                continue
            seen.add((line, rule))
            excerpt = "<redacted>" if rule in REDACTED else " ".join(match.split())[:60]
            report.append(f"{path}:{line}:{offset - starts[line - 1] + 1}: {rule}: {excerpt}")
    return len(texts), len(files) - len(texts), report


def main(argv: list[str] | None = None) -> int:
    """Parse arguments, scan the directory and print hits.

    Args:
        argv: command-line arguments without the program name; defaults to sys.argv[1:].

    Returns:
        Process exit code: 0 clean, 1 hits found, 2 missing directory or nothing to scan.

    Raises:
        SystemExit: argparse exits with code 2 on invalid arguments.

    Side effects:
        Prints hit lines and a summary to stdout, errors to stderr.
    """
    parser = argparse.ArgumentParser(description="Privacy lint for built public pages (BM-09).")
    parser.add_argument("directory", type=pathlib.Path, help="folder of built pages")
    parser.add_argument("--canary", action="append", default=[], help="literal string that must not appear")
    args = parser.parse_args(argv)
    if not args.directory.is_dir():
        print(f"privacy-lint: {args.directory} is not a directory", file=sys.stderr)
        return 2
    scanned, skipped, report = scan_dir(args.directory, args.canary)
    if scanned == 0:
        # An empty folder usually means a wrong path; passing it silently would hide a leak.
        print(f"privacy-lint: no text files under {args.directory}", file=sys.stderr)
        return 2
    print("\n".join(report + [f"privacy-lint: {len(report)} hit(s) in {scanned} file(s) scanned, {skipped} non-text skipped"]))
    return 1 if report else 0


if __name__ == "__main__":
    sys.exit(main())
