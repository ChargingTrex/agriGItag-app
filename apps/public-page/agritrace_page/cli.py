"""Command line: build a page from a record file, and check a built page against the byte budgets.

Purpose: local and CI builds of the public page without the backend (W01 "CLI build from fixture").
Requirements: plan §13 E1 budgets (CSS < 12 KB, JS < 4 KB, HTML+CSS+JS < 100 KB); D-007.
Callers: ``python -m agritrace_page build|check``; W02 CI (privacy lint, Lighthouse) reads output.
"""

import argparse
import json
from collections.abc import Sequence
from pathlib import Path

from agritrace_page.render import BUDGETS, measure, render


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
    """Parse arguments and run ``build`` or ``check``.

    Args:
        argv: Arguments without the program name; defaults to ``sys.argv[1:]``.

    Returns:
        Process exit code: 0 on success, 1 when ``check`` finds a budget breach.

    Raises:
        SystemExit: From argparse on bad arguments.
        OSError, json.JSONDecodeError, pydantic.ValidationError: Passed through from ``build``.
    """
    parser = argparse.ArgumentParser(prog="python -m agritrace_page")
    sub = parser.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build", help="render <record.json> into <out_dir>")
    b.add_argument("record", type=Path)
    b.add_argument("out_dir", type=Path)
    c = sub.add_parser("check", help="check <out_dir>/index.html against the byte budgets")
    c.add_argument("out_dir", type=Path)
    args = parser.parse_args(argv)
    if args.cmd == "build":
        build(args.record, args.out_dir)
        return 0
    return 0 if check(args.out_dir) else 1
