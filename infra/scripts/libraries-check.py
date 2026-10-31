#!/usr/bin/env python3
"""Fail when a manifest dependency has no row in docs/LIBRARIES.md or a row has a rejected licence.

Purpose: keep the dependency ledger in sync with the manifests (apps/api/pyproject.toml,
apps/public-page/pyproject.toml, apps/mobile/pubspec.yaml, apps/portal/package.json,
qa/robot/requirements.txt; whichever exist) and keep copyleft/non-commercial licences out.
Serves: ADR D-018, CLAUDE.md §3 item 3, plan §3 (every gate: "LIBRARIES.md in sync with the manifests").
Callers: CI job `docs`, the `libraries-check` pre-commit hook, Reviewers and gate reports.

Usage: python3 infra/scripts/libraries-check.py
Exit codes: 0 in sync and no rejected licence; 1 missing rows or rejected licences (names printed).
Needs PyYAML only when apps/mobile/pubspec.yaml exists.
"""

import json
import pathlib
import re
import sys
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[2]
LEDGER = ROOT / "docs" / "LIBRARIES.md"
MANIFESTS = (
    "apps/api/pyproject.toml",
    "apps/public-page/pyproject.toml",
    "apps/mobile/pubspec.yaml",
    "apps/portal/package.json",
    "apps/public-page/package.json",
    "qa/robot/requirements.txt",
)
# DECISION D-018: GPL, AGPL and LGPL are rejected for linked libraries, together with the other copyleft
#   (EUPL, CC-BY-SA), source-available (SSPL, BUSL/Business Source, RSAL) and non-commercial licences.
#   ADV: one simple rule a reviewer can apply; no linking-exception debates per package.
#   COMPROMISE: rules out psycopg (LGPL-3.0); pg8000 (BSD-3-Clause) is used instead in qa/robot.
#   BSL-1.0 (Boost) is permissive and deliberately not matched; only BUSL / "Business Source" is.
REJECTED = re.compile(
    r"\b[AL]?GPL|General Public License|\bSSPL|\bEUPL|\bBUSL|Business Source|\bRSAL"
    r"|\bCC[\s-]BY[\s-](?:\w+[\s-])*?(?:NC|SA)\b|non-?commercial",
    re.IGNORECASE,
)
# DECISION D-018 (amendment 2026-10-31): exact (library, licence) pairs the ADR accepts despite matching REJECTED.
#   ADV: the exception is named per library, so a new GPL row still fails.
#   COMPROMISE: one more list to keep in step with docs/adr/D-018.md.
ACCEPTED_BY_AMENDMENT = {("desugar-jdk-libs", "GPL-2.0-with-classpath-exception")}
NAME_RE = re.compile(r"\s*([A-Za-z0-9@][A-Za-z0-9._/@-]*)")


def normalise(name: str) -> str:
    """Return a comparable package name (lower case; runs of '-', '_', '.' become '-', as in PEP 503).

    Args:
        name: package name as written in a manifest or the ledger.

    Returns:
        The normalised name.
    """
    return re.sub(r"[-_.]+", "-", name.strip().lower())


def requirement_name(spec: str) -> str | None:
    """Extract the distribution name from a PEP 508 requirement string.

    Args:
        spec: e.g. ``"fastapi[standard]>=0.115"``.

    Returns:
        The bare name (``"fastapi"``), or None for blank lines, comments and pip options.
    """
    spec = spec.split("#", 1)[0].strip()
    if not spec or spec.startswith("-"):
        return None
    match = NAME_RE.match(spec)
    return match.group(1) if match else None


def pyproject_deps(path: pathlib.Path) -> set[str]:
    """List third-party dependencies of a pyproject.toml.

    Args:
        path: the pyproject.toml file.

    Returns:
        Names from [project] dependencies and optional-dependencies, [dependency-groups] and
        [tool.uv] dev-dependencies, minus first-party path/workspace sources.

    Raises:
        tomllib.TOMLDecodeError: the file is not valid TOML.
    """
    data = tomllib.loads(path.read_text())
    project = data.get("project", {})
    specs = list(project.get("dependencies", []))
    for group in project.get("optional-dependencies", {}).values():
        specs += group
    for group in data.get("dependency-groups", {}).values():
        specs += [s for s in group if isinstance(s, str)]
    specs += data.get("tool", {}).get("uv", {}).get("dev-dependencies", [])
    sources = data.get("tool", {}).get("uv", {}).get("sources", {})
    local = {normalise(n) for n, s in sources.items() if isinstance(s, dict) and ("path" in s or "workspace" in s)}
    names = {requirement_name(s) for s in specs} - {None}
    return {n for n in names if normalise(n) not in local}


def pubspec_deps(path: pathlib.Path) -> set[str]:
    """List third-party dependencies of a Flutter pubspec.yaml.

    Args:
        path: the pubspec.yaml file.

    Returns:
        Names under dependencies and dev_dependencies, minus SDK packages (``sdk: flutter``)
        and local path packages (e.g. the generated Dart client).

    Raises:
        ModuleNotFoundError: PyYAML is not installed.
        yaml.YAMLError: the file is not valid YAML.
    """
    import yaml  # only needed once the mobile app exists

    data = yaml.safe_load(path.read_text()) or {}
    names = set()
    for section in ("dependencies", "dev_dependencies"):
        for name, spec in (data.get(section) or {}).items():
            if not (isinstance(spec, dict) and ("sdk" in spec or "path" in spec)):
                names.add(name)
    return names


def package_json_deps(path: pathlib.Path) -> set[str]:
    """List third-party dependencies of an npm package.json.

    Args:
        path: the package.json file.

    Returns:
        Names under dependencies and devDependencies, minus workspace/file/link packages.

    Raises:
        json.JSONDecodeError: the file is not valid JSON.
    """
    data = json.loads(path.read_text())
    deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
    return {n for n, v in deps.items() if not str(v).startswith(("workspace:", "file:", "link:"))}


def requirements_deps(path: pathlib.Path) -> set[str]:
    """List the distributions named in a pip requirements file.

    Args:
        path: the requirements.txt file.

    Returns:
        Names of every requirement line (options such as ``-r`` are ignored).
    """
    return {requirement_name(line) for line in path.read_text().splitlines()} - {None}


def ledger_rows() -> dict[str, str]:
    """Read the ledger table from docs/LIBRARIES.md.

    Returns:
        Mapping of normalised library name to its Licence cell. A Library cell may hold several
        comma-separated names, in backticks or as Markdown links.

    Raises:
        FileNotFoundError: docs/LIBRARIES.md is missing.
    """
    rows = {}
    for line in LEDGER.read_text().splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not line.lstrip().startswith("|") or len(cells) < 3 or cells[0] == "Library" or set(cells[0]) <= set("-: "):
            continue
        library = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", cells[0]).replace("`", "")
        for name in library.split(","):
            rows[normalise(name)] = cells[2]
    return rows


def main() -> int:
    """Compare every manifest with the ledger and print what is missing or rejected.

    Returns:
        Process exit code: 1 when a dependency lacks a row or a row has a rejected licence, else 0.

    Raises:
        ModuleNotFoundError: pubspec.yaml exists but PyYAML is not installed.

    Side effects:
        Prints the report to stdout.
    """
    readers = {".toml": pyproject_deps, ".yaml": pubspec_deps, ".json": package_json_deps, ".txt": requirements_deps}
    ledger = ledger_rows()
    failed = False
    for rel in MANIFESTS:
        path = ROOT / rel
        if not path.is_file():
            print(f"skip    {rel} (not on disk)")
            continue
        names = readers[path.suffix](path)
        missing = sorted(n for n in names if normalise(n) not in ledger)
        failed |= bool(missing)
        status = f"MISSING {len(missing)}: {', '.join(missing)}" if missing else "ok"
        print(f"check   {rel}: {len(names)} dependencies, {status}")
    rejected = sorted(
        f"{name} ({lic})"
        for name, lic in ledger.items()
        if REJECTED.search(lic) and (name, lic) not in ACCEPTED_BY_AMENDMENT
    )
    if rejected:
        failed = True
        print("REJECTED licence (D-018): " + ", ".join(rejected))
    print("libraries-check: " + ("FAIL" if failed else "PASS") + f" ({len(ledger)} ledger rows)")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
