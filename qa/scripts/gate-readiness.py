#!/usr/bin/env python3
"""Fail when a gate or WP still has Robot placeholder tests (tagged `not-ready`).

Purpose: a gate run uses `--exclude not-ready`, so a WP that merged without turning its placeholders
into real tests would leave the gate green with nothing tested. This check closes that gap.
Serves: plan §3 (every gate: Robot suites for the finished WPs green), §9.1 tagging rules, Q00 review
r1 P2-5. Callers: Verifiers before a WP verdict, the QA Lead and Architect-Gate before signing
docs/agents/gates/G<n>.md.

Usage: qa/.venv/bin/python qa/scripts/gate-readiness.py <WP|gate> [...]     e.g. B02   G2   B02 B03
A gate G<n> means every WP listed under the "## G0" .. "## G<n>" headings of CHECKLIST.md.
Exit codes: 0 no placeholder left for those WPs; 1 placeholders listed; 2 unknown gate or WP.
Needs robotframework (qa/robot/requirements.txt).
"""

import pathlib
import re
import sys

from robot.api import TestSuiteBuilder

ROOT = pathlib.Path(__file__).resolve().parents[2]
ITEM = re.compile(r"^- \[[ xX]\] ([A-Z]\d\d) ")
GATE = re.compile(r"^## G(\d)\b")


def checklist_gates() -> dict[str, int]:
    """Map each WP id to the gate heading it sits under in CHECKLIST.md.

    Returns:
        e.g. {"B00": 0, "W01": 1, "B02": 2, ...}.

    Raises:
        FileNotFoundError: CHECKLIST.md is missing.
    """
    gates, current = {}, None
    for line in (ROOT / "CHECKLIST.md").read_text().splitlines():
        if heading := GATE.match(line):
            current = int(heading.group(1))
        elif (item := ITEM.match(line)) and current is not None:
            gates[item.group(1)] = current
    return gates


def resolve(targets: list[str], gates: dict[str, int]) -> set[str]:
    """Turn command-line targets into WP ids.

    Args:
        targets: WP ids (``B02``) and gates (``G2``, meaning G0..G2 cumulatively).
        gates: output of checklist_gates.

    Returns:
        The set of WP ids to check.

    Raises:
        KeyError: a target is neither a known WP nor a gate with WPs.
    """
    wps = set()
    for target in targets:
        if re.fullmatch(r"G\d", target):
            found = {wp for wp, gate in gates.items() if gate <= int(target[1])}
            if not found:
                raise KeyError(target)
            wps |= found
        elif target in gates:
            wps.add(target)
        else:
            raise KeyError(target)
    return wps


def main(argv: list[str]) -> int:
    """List placeholder tests for the requested WPs.

    Args:
        argv: targets (WP ids or gates).

    Returns:
        Process exit code: 0 ready, 1 placeholders remain, 2 bad arguments.

    Raises:
        robot.errors.DataError: a suite file cannot be parsed.

    Side effects:
        Prints a report to stdout.
    """
    if not argv:
        print(__doc__.split("\n\n")[2], file=sys.stderr)
        return 2
    try:
        wps = resolve(argv, checklist_gates())
    except KeyError as unknown:
        print(f"gate-readiness: unknown WP or gate {unknown}", file=sys.stderr)
        return 2
    suite = TestSuiteBuilder().build(str(ROOT / "qa" / "robot"))
    real, pending = {}, []
    for test in suite.all_tests:
        for wp in wps & {tag[3:] for tag in test.tags if tag.startswith("WP-")}:
            if "not-ready" in test.tags:
                pending.append(f"  {wp}  {test.source.relative_to(ROOT)}  {test.name}")
            else:
                real[wp] = real.get(wp, 0) + 1
    for wp in sorted(wps):
        print(f"{wp}: {real.get(wp, 0)} real Robot test(s)")
    if pending:
        print(f"NOT READY: {len(pending)} placeholder test(s) still tagged not-ready:\n" + "\n".join(sorted(pending)))
    print(f"gate-readiness {' '.join(argv)}: {'FAIL' if pending else 'PASS'}")
    return 1 if pending else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
