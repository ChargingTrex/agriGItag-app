#!/usr/bin/env python3
"""Run the Documentation Standard gates for every app that exists on disk.

Purpose: one command that fails when code is undocumented: interrogate for Python packages,
`flutter analyze` with `public_member_api_docs` for Dart, eslint-plugin-jsdoc for TypeScript, plus
two repo-wide checks: every `DECISION D-xxx` comment names an ADR in DECISIONS.md, and every
source file under apps/ opens with a header comment in its first 5 lines.
Serves: BM-10 (doc coverage 100 %), plan §4 item 6 and §3 (G5 "docs coverage script 100%"),
CLAUDE.md §5, ADR D-010.
Callers: CI job `docs` (.github/workflows/ci.yml), Reviewers and Verifiers (qa-rubric "Documentation").

Usage: python3 infra/scripts/doc-coverage.py
Exit codes: 0 every gate passed or was skipped (app absent); 1 any gate failed.
Missing apps are reported as SKIP; a missing tool for an app that exists is a FAIL.
"""

import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
PYTHON_APPS = {"apps/api": "agritrace", "apps/public-page": "agritrace_page"}
DECISION_SCAN_DIRS = ("apps", "packages", "infra", "qa")
SKIP_DIRS = {"node_modules", ".dart_tool", "build", "dist", ".venv", "__pycache__", "coverage", "results", ".git", ".data"}
HEADER_STARTS = {".py": ('"""', "'''", 'r"""', "#"), ".dart": ("//", "/*"), ".ts": ("//", "/*"), ".tsx": ("//", "/*")}
DECISION_RE = re.compile(r"DECISION (D-\d{3})")


def run(cmd: list[str], cwd: pathlib.Path) -> tuple[bool, str]:
    """Run a gate command and condense its output.

    Args:
        cmd: the command and its arguments.
        cwd: working directory (the app folder).

    Returns:
        (passed, detail) where passed is True on exit code 0 and detail is the last output line,
        or "tool not found: <name>" when the executable is missing.
    """
    try:
        done = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, check=False)
    except FileNotFoundError:
        return False, f"tool not found: {cmd[0]}"
    # stderr first: uv build chatter goes there, so the tool's own verdict on stdout ends the detail.
    tail = (done.stderr + done.stdout).strip().splitlines()[-1:]
    return done.returncode == 0, " | ".join(tail)


def walk(base: pathlib.Path):
    """Yield every file under a folder, skipping dependency, build and result folders.

    Args:
        base: folder to walk; a missing folder yields nothing.

    Returns:
        Generator of file paths.
    """
    if not base.is_dir():
        return
    for path in sorted(base.rglob("*")):
        if path.is_file() and not SKIP_DIRS.intersection(path.relative_to(ROOT).parts):
            yield path


def language_gates() -> list[tuple[str, str, str, str]]:
    """Run interrogate, flutter analyze and eslint for the apps that exist.

    Returns:
        Table rows (check, target, PASS|FAIL|SKIP, detail).

    Side effects:
        Runs `uv run interrogate`, `flutter analyze` and `npx eslint` as subprocesses.
    """
    rows = []
    for app, package in PYTHON_APPS.items():
        if not (ROOT / app).is_dir():
            rows.append(("python docstrings", app, "SKIP", "app not on disk yet"))
            continue
        # interrogate counts __init__ methods by default; the plan's `--ignore-init-method=false`
        # is not a valid interrogate flag (it is an on/off switch), so leaving it out is equivalent.
        ok, detail = run(["uv", "run", "interrogate", "-vv", "--fail-under", "100", package], ROOT / app)
        rows.append(("python docstrings", app, "PASS" if ok else "FAIL", detail))

    mobile = ROOT / "apps/mobile"
    options = mobile / "analysis_options.yaml"
    if not mobile.is_dir():
        rows.append(("dart doc comments", "apps/mobile", "SKIP", "app not on disk yet"))
    elif not options.is_file() or "public_member_api_docs" not in options.read_text(errors="ignore"):
        rows.append(("dart doc comments", "apps/mobile", "FAIL", "public_member_api_docs not in analysis_options.yaml"))
    else:
        # --fatal-infos: public_member_api_docs reports at info level, so infos must fail the gate.
        ok, detail = run(["flutter", "analyze", "--fatal-infos"], mobile)
        rows.append(("dart doc comments", "apps/mobile", "PASS" if ok else "FAIL", detail))

    portal = ROOT / "apps/portal"
    if not portal.is_dir():
        rows.append(("ts jsdoc", "apps/portal", "SKIP", "app not on disk yet"))
    else:
        cmd = ["npx", "--no-install", "eslint", "--rule", "jsdoc/require-jsdoc: error", "src"]
        ok, detail = run(cmd, portal)
        rows.append(("ts jsdoc", "apps/portal", "PASS" if ok else "FAIL", detail))
    return rows


def decision_refs() -> tuple[tuple[str, str, str, str], list[str]]:
    """Check that every `DECISION D-xxx` comment names an ADR listed in DECISIONS.md.

    Returns:
        (table row, list of "path:line: D-xxx" offenders).

    Raises:
        FileNotFoundError: DECISIONS.md is missing.
        OSError: a scanned file cannot be read (compose volumes under infra/.data/ are skipped).
    """
    known = set(re.findall(r"\bD-\d{3}\b", (ROOT / "DECISIONS.md").read_text()))
    bad, seen = [], 0
    for base in DECISION_SCAN_DIRS:
        for path in walk(ROOT / base):
            for lineno, line in enumerate(path.read_text(errors="ignore").splitlines(), start=1):
                for adr in DECISION_RE.findall(line):
                    seen += 1
                    if adr not in known:
                        bad.append(f"{path.relative_to(ROOT)}:{lineno}: {adr}")
    detail = f"{seen} comment(s) in {', '.join(DECISION_SCAN_DIRS)}; {len(bad)} unknown"
    return ("DECISION ids", "DECISIONS.md", "FAIL" if bad else "PASS", detail), bad


def headers() -> tuple[tuple[str, str, str, str], list[str]]:
    """Check that every non-empty .py/.dart/.ts/.tsx file under apps/ has a header comment.

    Returns:
        (table row, list of offending paths). A header is a comment or docstring opening
        within the first 5 lines; a shebang line does not count. Empty files are exempt.

    Raises:
        OSError: a file under apps/ cannot be read.
    """
    apps = ROOT / "apps"
    if not apps.is_dir():
        return ("file headers", "apps/", "SKIP", "apps/ not on disk yet"), []
    bad, seen = [], 0
    for path in walk(apps):
        starts = HEADER_STARTS.get(path.suffix)
        text = path.read_text(errors="ignore") if starts else ""
        if not text.strip():
            continue
        seen += 1
        first = [line.lstrip() for line in text.splitlines()[:5] if not line.startswith("#!")]
        if not any(line.startswith(starts) for line in first):
            bad.append(str(path.relative_to(ROOT)))
    return ("file headers", "apps/", "FAIL" if bad else "PASS", f"{seen} file(s); {len(bad)} without header"), bad


def main() -> int:
    """Run every gate, print a table and the offending items.

    Returns:
        Process exit code: 1 when any row is FAIL, else 0.

    Side effects:
        Prints to stdout; runs the language tools as subprocesses.
    """
    rows = language_gates()
    extra = []
    for row, offenders in (decision_refs(), headers()):
        rows.append(row)
        extra += [f"  {row[0]}: {item}" for item in offenders]
    width = [max(len(r[i]) for r in rows + [("Check", "Target", "Result", "")]) for i in range(3)]
    print(f"{'Check':<{width[0]}}  {'Target':<{width[1]}}  {'Result':<{width[2]}}  Detail")
    for check, target, result, detail in rows:
        print(f"{check:<{width[0]}}  {target:<{width[1]}}  {result:<{width[2]}}  {detail[:160]}")
    if extra:
        print("\nOffenders:\n" + "\n".join(extra))
    return 1 if any(r[2] == "FAIL" for r in rows) else 0


if __name__ == "__main__":
    sys.exit(main())
