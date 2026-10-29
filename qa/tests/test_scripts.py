"""Small tests for the parsing logic in infra/scripts/benchmarks/collect.py and libraries-check.py.

Serves: plan §8 (benchmark judging), D-018 (ledger check), CLAUDE.md §4 ("new parser leaves one small test").
Callers: CI docs job and `pytest qa/tests -q`.
"""

import importlib.util
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]


def load(rel: str):
    """Import a script whose file name is not a valid module name.

    Args:
        rel: path of the script relative to the repo root.

    Returns:
        The loaded module object.
    """
    spec = importlib.util.spec_from_file_location(pathlib.Path(rel).stem.replace("-", "_"), ROOT / rel)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_collect_judges_pass_fail_missing_and_required(tmp_path: pathlib.Path) -> None:
    """A passing, a failing, an absent and a required-but-absent benchmark get the right status and exit code."""
    collect = load("infra/scripts/benchmarks/collect.py")
    results = tmp_path / "results"
    results.mkdir()
    (results / "bm07.json").write_text(json.dumps({"id": "BM-07", "metrics": {"p95_ms": 212}}))
    (results / "bm16.json").write_text(json.dumps({"id": "BM-16", "metrics": {"initial_kb": 100, "lcp_s": 1.9}}))
    out = tmp_path / "benchmarks.json"
    args = ["--results-dir", str(results), "--out", str(out)]

    assert collect.main(args) == 1  # BM-16 initial_kb must be < 100
    merged = json.loads(out.read_text())["benchmarks"]
    assert merged["BM-07"]["status"] == "PASS"
    assert merged["BM-16"]["status"] == "FAIL"
    assert merged["BM-01"]["status"] == "MISSING"

    (results / "bm16.json").write_text(json.dumps({"id": "BM-16", "metrics": {"initial_kb": 99, "lcp_s": 1.9}}))
    assert collect.main(args) == 0
    assert collect.main([*args, "--require", "BM-01"]) == 1


def test_libraries_check_parsers(tmp_path: pathlib.Path) -> None:
    """Requirement names, first-party path sources and rejected licences are handled."""
    check = load("infra/scripts/libraries-check.py")
    assert check.requirement_name("fastapi[standard]>=0.115  # api") == "fastapi"
    assert check.requirement_name("-r other.txt") is None
    assert check.normalise("Ruamel_YAML.clib") == "ruamel-yaml-clib"
    pyproject = tmp_path / "pyproject.toml"
    pyproject.write_text(
        '[project]\ndependencies = ["fastapi>=0.115", "agritrace-page"]\n'
        '[dependency-groups]\ndev = ["pytest>=8"]\n'
        '[tool.uv.sources]\nagritrace-page = { path = "../public-page" }\n'
    )
    assert check.pyproject_deps(pyproject) == {"fastapi", "pytest"}
    assert check.REJECTED.search("LGPL-3.0-only") and check.REJECTED.search("CC-BY-NC-4.0")
    assert not check.REJECTED.search("MIT") and not check.REJECTED.search("MPL-2.0")
