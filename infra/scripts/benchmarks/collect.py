#!/usr/bin/env python3
"""Merge per-benchmark result files and judge them against the thresholds.

Purpose: read every `qa/results/benchmarks/*.json` (one benchmark run each), compare its metrics with
`infra/scripts/benchmarks/thresholds.yaml`, write the merged evidence to `docs/agents/qa/benchmarks.json`
and print a PASS/FAIL table.
Serves: plan §8 (BM-01..BM-10), §13 (BM-11..BM-16), §7.5 Q05 (benchmark sweep), qa-rubric "Benchmarks".
Callers: Verifiers after running a WP's benchmarks, Q05 for the G5 report.

Result file format (written by each benchmark script or by hand from a tool's report):
    {"id": "BM-07", "metrics": {"p95_ms": 212}, "commit": "<sha>", "env": "docker stack", "measured_at": "<ISO 8601>"}

Usage: python3 infra/scripts/benchmarks/collect.py [--require BM-07 ...] [--results-dir D] [--thresholds F] [--out F]
Exit codes: 0 every reported benchmark passes; 1 any FAIL (a --require'd benchmark without results is a FAIL).
Benchmarks without results and not required are listed as MISSING and do not fail the run.
"""

import argparse
import datetime
import json
import operator
import pathlib
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[3]
OPS = {"max": (operator.le, "<="), "min": (operator.ge, ">="), "lt": (operator.lt, "<"), "equals": (operator.eq, "==")}


def load_results(results_dir: pathlib.Path) -> dict[str, dict]:
    """Read every result file, keyed by benchmark id.

    Args:
        results_dir: folder of `*.json` result files; may be missing.

    Returns:
        Mapping of benchmark id to its result dict plus a ``source`` key with the file name.
        When two files share an id, the one whose name sorts last wins.

    Raises:
        json.JSONDecodeError: a file is not valid JSON.
        KeyError: a file has no ``id``.
    """
    results = {}
    for path in sorted(results_dir.glob("*.json")) if results_dir.is_dir() else []:
        data = json.loads(path.read_text())
        results[data["id"]] = {**data, "source": str(path.relative_to(ROOT) if path.is_relative_to(ROOT) else path)}
    return results


def judge(thresholds: dict, results: dict[str, dict], required: set[str]) -> tuple[list[tuple], dict]:
    """Compare results with thresholds.

    Args:
        thresholds: parsed thresholds.yaml (id -> {"title", "metrics": {name: {op: limit}}}).
        results: output of load_results.
        required: benchmark ids that must have results.

    Returns:
        (table rows of (id, metric, value, threshold, status), merged dict id -> {"title", "status",
        "result", "checks"}). Status is PASS, FAIL or MISSING; a missing metric inside a result is FAIL.

    Raises:
        ValueError: a threshold uses an unknown operator.
    """
    rows, merged = [], {}
    for bm_id, spec in thresholds.items():
        result = results.get(bm_id)
        checks = []
        for metric, rule in spec["metrics"].items():
            ((op_name, limit),) = rule.items()
            if op_name not in OPS:
                raise ValueError(f"{bm_id}.{metric}: unknown operator {op_name}")
            compare, symbol = OPS[op_name]
            value = None if result is None else result.get("metrics", {}).get(metric)
            if result is None:
                status = "FAIL" if bm_id in required else "MISSING"
            else:
                status = "PASS" if value is not None and compare(value, limit) else "FAIL"
            checks.append({"metric": metric, "value": value, "threshold": f"{symbol} {limit}", "status": status})
            rows.append((bm_id, metric, "-" if value is None else str(value), f"{symbol} {limit}", status))
        statuses = {c["status"] for c in checks}
        overall = "FAIL" if "FAIL" in statuses else "MISSING" if "MISSING" in statuses else "PASS"
        merged[bm_id] = {"title": spec["title"], "status": overall, "result": result, "checks": checks}
    return rows, merged


def main(argv: list[str] | None = None) -> int:
    """Collect, judge, write docs/agents/qa/benchmarks.json and print the table.

    Args:
        argv: command-line arguments without the program name; defaults to sys.argv[1:].

    Returns:
        Process exit code: 1 when any row is FAIL, else 0.

    Raises:
        FileNotFoundError: the thresholds file is missing.

    Side effects:
        Overwrites the output JSON file (creating its folder) and prints to stdout.
    """
    parser = argparse.ArgumentParser(description="Merge benchmark results and judge them (BM-01..BM-16).")
    parser.add_argument("--results-dir", type=pathlib.Path, default=ROOT / "qa/results/benchmarks")
    parser.add_argument("--thresholds", type=pathlib.Path, default=ROOT / "infra/scripts/benchmarks/thresholds.yaml")
    parser.add_argument("--out", type=pathlib.Path, default=ROOT / "docs/agents/qa/benchmarks.json")
    parser.add_argument("--require", action="append", default=[], help="benchmark id that must have results")
    args = parser.parse_args(argv)

    thresholds = yaml.safe_load(args.thresholds.read_text())
    rows, merged = judge(thresholds, load_results(args.results_dir), set(args.require))
    now = datetime.datetime.now(datetime.UTC).isoformat(timespec="seconds")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps({"generated_at": now, "benchmarks": merged}, indent=2) + "\n")

    header = ("Benchmark", "Metric", "Value", "Threshold", "Status")
    width = [max(len(str(r[i])) for r in rows + [header]) for i in range(5)]
    for row in [header, *rows]:
        print("  ".join(f"{cell!s:<{width[i]}}" for i, cell in enumerate(row)))
    failed = any(r[4] == "FAIL" for r in rows)
    print(f"collect: {'FAIL' if failed else 'PASS'}; merged into {args.out}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
