"""Command line: build a batch or unavailable page, and check a page against the byte budgets.

Purpose: local and CI builds of the public page without the backend (W01 "CLI build from fixture").
Requirements: plan §13 E1 budgets (CSS < 12 KB, JS < 4 KB, HTML+CSS+JS < 100 KB); D-007; W03
unpublished/404 variant (a static file the CDN serves for unknown codes).
Callers: ``python -m agritrace_page build|unavailable|check``; W02 CI (privacy lint, Lighthouse,
html-validate) reads the output; ops build the CDN 404 page with ``unavailable unknown``.
"""

import argparse
import json
from collections.abc import Sequence
from pathlib import Path

from agritrace_page.render import BUDGETS, Reason, measure, render, render_unavailable


def build(record_path: Path, out_dir: Path) -> None:
    """Render a record JSON file into ``out_dir/index.html`` and ``out_dir/data.json``.

    Args:
        record_path: Path to a ``PublicBatchRecord`` JSON file.
        out_dir: Output directory; created if missing.

    Returns:
        None.

    Raises:
        OSError: When the record cannot be read or the output cannot be written.
        json.JSONDecodeError: When the record file is not JSON.
        pydantic.ValidationError: When the record is invalid or carries personal data.

    Side effects:
        Creates ``out_dir`` and overwrites ``index.html`` and ``data.json`` in it.
    """
    result = render(json.loads(record_path.read_text("utf-8")))
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "index.html").write_text(result.html, "utf-8")
    (out_dir / "data.json").write_text(result.data_json, "utf-8")


def unavailable(reason: Reason, out_dir: Path, code: str | None = None) -> None:
    """Write the unavailable page for ``reason`` to ``out_dir/index.html``.

    Args:
        reason: "unpublished", "withdrawn" or "unknown".
        out_dir: Output directory; created if missing.
        code: Batch code to show, or None for the generic CDN 404 page.

    Returns:
        None.

    Raises:
        ValueError: From ``render_unavailable`` on a bad reason or code.
        OSError: When the output cannot be written.

    Side effects:
        Creates ``out_dir`` and overwrites ``index.html`` in it.
    """
    html = render_unavailable(code, reason)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "index.html").write_text(html, "utf-8")


def check(out_dir: Path) -> bool:
    """Print the page's byte sizes against ``BUDGETS``.

    Args:
        out_dir: Directory holding a built ``index.html``.

    Returns:
        True when every size is under its budget.

    Raises:
        OSError: When ``index.html`` cannot be read.

    Side effects:
        Prints one line per budget to stdout.
    """
    sizes = measure((out_dir / "index.html").read_text("utf-8"))
    ok = True
    for name, limit in BUDGETS.items():
        within = sizes[name] < limit
        ok &= within
        print(f"{name:<6}{sizes[name]:>8} B < {limit:>7} B  {'ok' if within else 'OVER BUDGET'}")
    return ok


def main(argv: Sequence[str] | None = None) -> int:
    """Parse arguments and run ``build``, ``unavailable`` or ``check``.

    Args:
        argv: Arguments without the program name; defaults to ``sys.argv[1:]``.

    Returns:
        Process exit code: 0 on success, 1 when ``check`` finds a budget breach.

    Raises:
        SystemExit: From argparse on bad arguments.
        OSError, json.JSONDecodeError, pydantic.ValidationError: Passed through from ``build``.
        ValueError: Passed through from ``unavailable`` on a bad batch code.
    """
    parser = argparse.ArgumentParser(prog="python -m agritrace_page")
    sub = parser.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build", help="render <record.json> into <out_dir>")
    b.add_argument("record", type=Path)
    b.add_argument("out_dir", type=Path)
    u = sub.add_parser("unavailable", help="write the <reason> page into <out_dir>/index.html")
    u.add_argument("reason", choices=["unpublished", "withdrawn", "unknown"])
    u.add_argument("out_dir", type=Path)
    u.add_argument("--code", help="batch code to show; omit for the generic 404 page")
    c = sub.add_parser("check", help="check <out_dir>/index.html against the byte budgets")
    c.add_argument("out_dir", type=Path)
    args = parser.parse_args(argv)
    if args.cmd == "build":
        build(args.record, args.out_dir)
        return 0
    if args.cmd == "unavailable":
        unavailable(args.reason, args.out_dir, args.code)
        return 0
    return 0 if check(args.out_dir) else 1
