# Verification evidence

Verifiers write here; nobody else edits these files. Procedure: `docs/agents/qa-rubric.md`. Tools and the full
evidence convention: [`qa/README.md`](../../../qa/README.md).

| Path | Content |
|---|---|
| `<WP>.md` | Verification report: rubric, acceptance line → PASS/FAIL → evidence path, environment (AVD, network profile, commit, spec version) |
| `<WP>/logs/<step>.log` | stdout/stderr of each acceptance command, copied verbatim |
| `<WP>/shots/<test>-<locale>-<device>.png` | screenshots, one per UI acceptance line (`locale` en/ta; `device` e.g. `go_api27`, `desktop-1280x800`) |
| `<WP>/robot/{report.html,output.xml}` | Robot evidence copied from the ignored `qa/robot/results/<WP>/` |
| `benchmarks.json` | merged benchmark results, written only by `infra/scripts/benchmarks/collect.py` |
| `issues/<WP>-<n>.md` | defects (P1/P2) with reproduction steps |

Robot runs write to `qa/robot/results/<gate-or-WP>/`, which is not committed; only the copies above are.
