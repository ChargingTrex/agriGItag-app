"""Small tests for the parsing logic in the QA scripts.

Covers benchmarks/collect.py, libraries-check.py, gate-readiness.py and the Flutter result parser in
qa/robot/lib/agritrace_keywords.py.

Serves: plan §8 (benchmark judging), D-018 (ledger check), plan §9.1 (Flutter results, gate readiness),
CLAUDE.md §4 ("new parser leaves one small test"). Callers: CI docs job and `pytest qa/tests -q`.
"""

import importlib.util
import json
import os
import pathlib

import pytest

ROOT = pathlib.Path(__file__).resolve().parents[2]
FLUTTER = ROOT / "qa" / "fixtures" / "flutter"


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
    """A passing, a failing, an absent and a required-but-absent benchmark get the right status and exit code.

    Args:
        tmp_path: pytest's per-test folder.
    """
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


def test_collect_newest_run_wins_even_when_it_fails(tmp_path: pathlib.Path) -> None:
    """Review r1 P2-1: an older passing run (whose name sorts last) must not hide a newer failing one.

    Args:
        tmp_path: pytest's per-test folder.
    """
    collect = load("infra/scripts/benchmarks/collect.py")
    results = tmp_path / "results"
    results.mkdir()
    newer = {"id": "BM-07", "metrics": {"p95_ms": 450}, "recorded_at": "2026-12-01T10:00:00+00:00"}
    older = {"id": "BM-07", "metrics": {"p95_ms": 200}, "recorded_at": "2026-11-01T10:00:00+00:00"}
    (results / "BM-07-G5.json").write_text(json.dumps(newer))
    (results / "BM-07-Q04.json").write_text(json.dumps(older))
    args = ["--results-dir", str(results), "--out", str(tmp_path / "out.json")]
    assert collect.main(args) == 1

    # Without recorded_at the file modification time decides.
    for name, data, mtime in (("BM-07-G5.json", newer, 2_000_000_000), ("BM-07-Q04.json", older, 1_000_000_000)):
        data = {k: v for k, v in data.items() if k != "recorded_at"}
        (results / name).write_text(json.dumps(data))
        os.utime(results / name, (mtime, mtime))
    assert collect.main(args) == 1


def test_libraries_check_parsers(tmp_path: pathlib.Path) -> None:
    """Requirement names, first-party path sources, ledger cells and rejected licences are handled.

    Args:
        tmp_path: pytest's per-test folder.
    """
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
    for bad in ("LGPL-3.0-only", "CC-BY-NC-4.0", "CC BY-NC 4.0", "CC-BY-SA-4.0", "SSPL-1.0", "EUPL-1.2", "BUSL-1.1", "RSALv2"):
        assert check.REJECTED.search(bad), bad
    for good in ("MIT", "Apache-2.0", "BSD-3-Clause", "BSL-1.0"):
        assert not check.REJECTED.search(good), good
    ledger = tmp_path / "LIBRARIES.md"
    ledger.write_text(
        "| Library | Version | Licence |\n|---|---|---|\n"
        "| [`Jinja2`](https://x), markupsafe | 3 | BSD-3-Clause |\n| `@tanstack/react-query` | 5 | MIT |\n"
    )
    check.LEDGER = ledger
    assert check.ledger_rows() == {"jinja2": "BSD-3-Clause", "markupsafe": "BSD-3-Clause", "@tanstack/react-query": "MIT"}


def test_flutter_parser_counts_finished_runs_and_fails_crashed_ones() -> None:
    """Review r1 P2-8: a truncated log, an empty log or a non-zero exit code is a failure, never green."""
    keywords = load("qa/robot/lib/agritrace_keywords.py")
    full = keywords.parse_flutter_results(str(FLUTTER / "sample_machine.jsonl"))
    assert (full["passed"], full["failed"], full["skipped"], full["success"]) == (1, 1, 1, False)

    cut = keywords.parse_flutter_results(str(FLUTTER / "truncated_machine.jsonl"))
    assert cut["success"] is False and cut["failed"] == 1
    assert "harvest reaches server after network returns (did not finish)" in cut["failures"]
    assert "run did not finish (no done event)" in cut["failures"]


def test_flutter_parser_empty_log_and_exit_code(tmp_path: pathlib.Path) -> None:
    """An empty log fails; a complete green log fails when the process exit code was non-zero.

    Args:
        tmp_path: pytest's per-test folder.
    """
    keywords = load("qa/robot/lib/agritrace_keywords.py")
    empty = tmp_path / "empty.jsonl"
    empty.write_text("")
    assert keywords.parse_flutter_results(str(empty))["failed"] == 1
    green = tmp_path / "green.jsonl"
    green.write_text(
        '{"test":{"id":1,"name":"t"},"type":"testStart"}\n'
        '{"testID":1,"result":"success","hidden":false,"type":"testDone"}\n'
        '{"success":true,"type":"done"}\n'
    )
    assert keywords.parse_flutter_results(str(green))["success"] is True
    crashed = keywords.parse_flutter_results(str(green), exit_code="1")
    assert crashed["success"] is False and crashed["failed"] == 1


def test_gate_readiness_reads_checklist_and_flags_placeholders() -> None:
    """Review r1 P2-5: gates resolve cumulatively from CHECKLIST.md; a WP with placeholders fails."""
    pytest.importorskip("robot.api", reason="gate-readiness needs robotframework (qa/robot/requirements.txt)")
    gate = load("qa/scripts/gate-readiness.py")
    gates = gate.checklist_gates()
    assert gate.resolve(["G0"], gates) == {"B00", "Q00"}
    assert gate.resolve(["G1"], gates) >= {"B00", "Q00", "B01", "W01"}
    assert gate.main(["G0"]) == 0
    assert gate.main(["B02"]) == 0  # identity.robot made real by Q06
    assert gate.main(["M02"]) == 1  # mobile network suites stay placeholders until Q01
    assert gate.main(["X99"]) == 2


def test_api_body_builders_need_no_stack(monkeypatch: pytest.MonkeyPatch) -> None:
    """Q06 keywords: settings fall back to the environment outside Robot; event clocks and fixes shift as asked.

    Args:
        monkeypatch: pytest's environment patcher.
    """
    keywords = load("qa/robot/lib/agritrace_keywords.py")
    monkeypatch.setenv("API_BASE", "http://example.test/v1")
    assert keywords._var("API_BASE", "unused") == "http://example.test/v1"
    plot = {"id": "p1", "pin": {"lat": 9.5, "lon": 78.1}}
    e = keywords.event("l1", plot, "harvest", "2026-10-20", lat_shift="0.0054", clock_shift_hours=72)
    assert e["kind"] == "event_version" and e["data"]["gps"]["lat"] == pytest.approx(9.5054)
    ahead = keywords.datetime.fromisoformat(e["data"]["clocks"]["device_time"]) - keywords.datetime.now(keywords.UTC)
    assert 71.9 < ahead.total_seconds() / 3600 <= 72
    assert keywords.packing("20")["packed"] == {"value": 20, "unit": "kg"}
