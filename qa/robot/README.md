# Robot Framework suites

Plan §9.1. Python 3.12. Suites read like the acceptance tables in plan §7; each acceptance line is one test.

## Install

```sh
uv venv qa/.venv --python 3.12
uv pip install --python qa/.venv/bin/python -r qa/robot/requirements.txt
qa/.venv/bin/rfbrowser init      # Playwright browsers for Browser library (portal, public page)
```

`robotframework-process` in plan §9.1 is Robot's built-in `Process` library; there is no package to install.
DatabaseLibrary uses the `pg8000` driver (psycopg is LGPL-3.0, rejected by D-018).

## Run

```sh
R=qa/.venv/bin/robot
$R --outputdir qa/robot/results/ci --exclude not-ready qa/robot/api/healthz.robot   # CI smoke
$R --outputdir qa/robot/results/B02 --include WP-B02 qa/robot                      # one WP
$R --outputdir qa/robot/results/G2 --exclude not-ready qa/robot/api                # a gate
$R --include smoke qa/robot/mobile qa/robot/public                                  # no stack or emulator needed
$R --dryrun --outputdir /tmp/robot-dryrun qa/robot                                  # syntax check of every suite
```

Environment (defaults in `resources/common.resource`): `API_BASE` (http://localhost:8000/v1), `PORTAL_BASE`
(http://localhost:5173), `PUBLIC_BASE`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DEV_OTP_CODE`.
Mobile suites also use `ANDROID_SERIAL` and `DRY_RUN` (see `qa/scripts/network.sh`).

## Tagging rules

- Every test carries its work package `WP-<id>` (e.g. `WP-B02`) and at least one PRD requirement `FR-<n>`
  (PRD numbering, no zero padding: `FR-1`, `FR-29`). Benchmark tests also carry `BM-<nn>`.
- `not-ready`: placeholder until its WP merges; body is `Not Ready  <WP>` (skips). The WP's worker or the QA Lead
  replaces the body and removes the tag. CI and gates run with `--exclude not-ready`.
- `smoke`: runs in seconds; one per suite. `flaky`: reported as P2 (qa-rubric); at most two reruns.

## Suites

| Suite | Covers | Gate |
|---|---|---|
| `api/healthz.robot` | B00 `/v1/healthz` db/redis/s3 ok (real) | G0 |
| `api/identity.robot` | B02 | G2 |
| `api/registry.robot` | B03, B13 | G2 |
| `api/sync.robot` | B06, B07 | G2 |
| `api/rules.robot` | B08, B04 | G2 |
| `api/quality.robot` | B05 | G2 |
| `api/batches.robot` | B09 | G2 |
| `api/publishing.robot` | B10, B11 | G2/G4 |
| `mobile/offline_matrix.robot` | Q01 9 actions × 5 network states; real smoke parses a Flutter `--machine` log | G3 |
| `mobile/network_profiles.robot` | BM-11..BM-16; real smoke checks profiles.yaml and network.sh (DRY_RUN) | G3 |
| `portal/portal.robot` | P01-P08 and the P07 chain | G4 |
| `public/page.robot` | W01-W03, Q03; real smoke runs privacy-lint on the fixtures | G4 |
| `e2e/reference_batch.robot` | B12 seeded batch `FGP8T4033HM7` | G5 |

API suites start with `Stack Is Healthy` as their smoke test. Keywords: `resources/common.resource`
(`Stack Is Healthy`, `Login As`, `Error Code Should Be`, `Connect To AgriTrace Database`, `Not Ready`) and
`lib/agritrace_keywords.py` (`Load Network Profiles`, `Set Emulator Network`, `Parse Flutter Results`).
