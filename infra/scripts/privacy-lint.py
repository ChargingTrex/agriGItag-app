#!/usr/bin/env python3
"""Scan built public pages (HTML and JSON) for personal data and exact locations.

Purpose: fail fast when a public batch page or partner payload leaks a phone number, an
Aadhaar-like ID, survey/patta labels, precise coordinates, a polygon, a temp path or a canary string.
Serves: BM-09 (privacy lint 0 hits), plan §7.4 W02 and §7.5 Q03, gate G4, CLAUDE.md §6 privacy invariants.
Callers: qa/tests/test_privacy_lint.py (CI docs job), qa/robot/public/page.robot, Verifiers run it on
downloaded `public-pages/batches/<code>/` folders; B10/W02 may call it from the publish pipeline.

Usage: python3 infra/scripts/privacy-lint.py <dir> [--canary STRING ...]
Exit codes: 0 no hits; 1 hits found (printed as path:line:col: rule: excerpt); 2 bad arguments,
missing directory, or no .html/.htm/.json file under it.
"""

import argparse
import pathlib
import re
import sys

NUM = r"-?\d{1,3}\.\d+"
PRECISE = r"-?\d{1,3}\.\d{4,}"
PAIR = r"\s*,\s*"
RULES = {
    # Indian mobile: 10 digits starting 6-9, optional +91/91 prefix; word boundaries skip hex hashes.
    "phone": re.compile(r"(?<!\w)(?:\+?91[\s-]?)?[6-9]\d{9}(?!\w)"),
    "aadhaar": re.compile(r"(?<!\w)\d{4}\s?\d{4}\s?\d{4}(?!\w)"),
    "sensitive_label": re.compile(r"\b(?:survey|patta|chitta|aadhaar|phone|mobile)", re.IGNORECASE),
    # A lat/lng pair or a lat/lng key with more than 3 decimal places (~110 m) pinpoints a farm.
    "coordinate_precision": re.compile(
        rf"(?<![\w.])(?:{PRECISE}{PAIR}{NUM}|{NUM}{PAIR}{PRECISE})(?![\d])"
        rf"|\b(?:lat|lng|lon)\w*[\"']?\s*[:=]\s*[\"']?{PRECISE}",
        re.IGNORECASE,
    ),
    # GeoJSON polygon type, WKT polygon, or a ring: an array of at least two [x, y] pairs.
    "polygon": re.compile(
        rf"\"type\"\s*:\s*\"(?:Multi)?Polygon\"|\bPOLYGON\s*\(\("
        rf"|\[\s*\[\s*{NUM}{PAIR}{NUM}\s*\]\s*,\s*\[\s*{NUM}{PAIR}{NUM}\s*\]",
        re.IGNORECASE,
    ),
    "temp_path": re.compile(r"temp_uploads|/tmp/"),
}
REDACTED = {"phone", "aadhaar", "canary"}
SUFFIXES = {".html", ".htm", ".json"}


def scan_line(line: str, canaries: list[str]) -> list[tuple[int, str, str]]:
    """Find every privacy hit in one line of text.

    Args:
        line: one line of an HTML or JSON file.
        canaries: literal strings that must never appear (e.g. a seeded farmer's real name).

    Returns:
        List of (column, rule name, matched text) tuples, column 1-based; empty when clean.
    """
    hits = [(m.start() + 1, rule, m.group()) for rule, rx in RULES.items() for m in rx.finditer(line)]
    for canary in canaries:
        start = line.find(canary)
        while start != -1:
            hits.append((start + 1, "canary", canary))
            start = line.find(canary, start + 1)
    return sorted(hits)


def scan_dir(root: pathlib.Path, canaries: list[str]) -> tuple[int, list[str]]:
    """Scan every .html/.htm/.json file under a directory.

    Args:
        root: directory holding built public pages.
        canaries: literal strings that must never appear.

    Returns:
        (number of files scanned, list of "path:line:col: rule: excerpt" report lines).
        Phone, Aadhaar and canary excerpts are redacted so CI logs do not repeat the leak.

    Raises:
        OSError: a file cannot be read.
    """
    files = sorted(p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in SUFFIXES)
    report = []
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), start=1):
            for col, rule, match in scan_line(line, canaries):
                excerpt = "<redacted>" if rule in REDACTED else match[:60]
                report.append(f"{path}:{lineno}:{col}: {rule}: {excerpt}")
    return len(files), report


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
    parser.add_argument("directory", type=pathlib.Path, help="folder of built pages (html/json)")
    parser.add_argument("--canary", action="append", default=[], help="literal string that must not appear")
    args = parser.parse_args(argv)
    if not args.directory.is_dir():
        print(f"privacy-lint: {args.directory} is not a directory", file=sys.stderr)
        return 2
    count, report = scan_dir(args.directory, args.canary)
    if count == 0:
        # An empty folder usually means a wrong path; passing it silently would hide a leak.
        print(f"privacy-lint: no .html/.htm/.json files under {args.directory}", file=sys.stderr)
        return 2
    print("\n".join(report + [f"privacy-lint: {len(report)} hit(s) in {count} file(s) scanned"]))
    return 1 if report else 0


if __name__ == "__main__":
    sys.exit(main())
