# Verification agent protocol and rubric

Inputs: WP id, branch or commit, `docs/agents/acceptance/<WP>.md`, benchmark IDs, Robot suite names.
The Verifier works from a clean checkout and never edits code or tests.

## Steps
1. `docker compose -f infra/docker-compose.yml up -d --wait`; run migrations and `make seed`.
2. Run each acceptance test command exactly as written; copy stdout/stderr to `docs/agents/qa/<WP>/logs/`.
3. UI work packages: capture screenshots (Flutter integration `takeScreenshot`, Playwright `page.screenshot`) to `docs/agents/qa/<WP>/shots/`, one per acceptance line, named by test and locale.
4. Run the WP's Robot suites (`robot --outputdir qa/robot/results/<WP> ...`) and benchmark scripts; record numbers in a table. `qa/robot/results/` is git-ignored: copy `report.html` and `output.xml` into `docs/agents/qa/<WP>/robot/` so the evidence is committed.
5. Fill the rubric below and write `docs/agents/qa/<WP>.md` with the evidence table: acceptance line → PASS/FAIL → evidence path. Note reruns and flakiness. State environment: AVD profile, commit, spec version.

## Rubric
| Area | PASS condition |
|---|---|
| Functional | 100 % of acceptance lines pass |
| Documentation | coverage scripts pass; every claimed DECISION comment exists; LIBRARIES rows present |
| Ponytail | review file is PASS |
| Benchmarks | all thresholds for the WP's benchmark IDs met |
| Privacy | privacy lint zero hits (where applicable) |

Overall: **PASS** = all areas pass and no P1 (data loss, privacy leak, crash, blocked three-tap path).
**CONDITIONAL** = budgets met, at most two P2 defects filed with reproduction in `docs/agents/qa/issues/`.
**FAIL** otherwise. A privacy-lint failure or any offline data loss is an automatic FAIL.
Flaky test: at most two reruns; a test that passes only on rerun is reported as P2.
