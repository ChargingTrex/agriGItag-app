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
qa/.venv/bin/python qa/scripts/gate-readiness.py G2                                 # gate rule first
$R --outputdir qa/robot/results/G2 --exclude not-ready qa/robot/api                # a gate
$R --include smoke qa/robot/mobile qa/robot/public                                  # no stack or emulator needed
$R --dryrun --outputdir /tmp/robot-dryrun qa/robot                                  # syntax check of every suite
```

Environment (defaults in `resources/common.resource`, names as in B00's compose file): `API_BASE`
(http://localhost:8000/v1), `PORTAL_BASE` (http://localhost:5173), `S3_ENDPOINT` (LocalStack, http://localhost:4566),
`S3_REGION` (ap-south-1), `S3_ACCESS_KEY` / `S3_SECRET_KEY` (test/test), `PUBLIC_BASE_URL`
(http://localhost:4566/public-pages), `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `OTP_DEV_CODE` (123456).
Mobile suites also use `ANDROID_SERIAL` and `DRY_RUN` (see `qa/scripts/network.sh`).

### API suites (gate G2, Q06)

`api/*.robot` run against a live, freshly seeded stack (`make up`, `alembic upgrade head`, `make seed`) and need
`docker` on the Robot host: S3 versions, the worker's Celery calls and one-off api containers (B13 config lines) go
through `COMPOSE` (default `docker compose -f infra/docker-compose.yml`; set it with `-p <project>` and any `-f`
override when the stack runs under another project name). Other variables: `OFFICE_PIN` (2468, set by the first PIN
verify of a fresh seed), `FLAG_ON_PORT` (8098, host port of the throw-away api container with
`id_document_capture` on). A stack on remapped ports, e.g.:

```sh
export API_BASE=http://localhost:8020/v1 PUBLIC_BASE_URL=http://localhost:4586/public-pages DB_PORT=5453 \
       COMPOSE="docker compose -p agritrace-q06 -f infra/docker-compose.yml"
qa/.venv/bin/robot --outputdir qa/robot/results/G2 --exclude not-ready qa/robot/api
```

The suites only add data: a QA farmer with a random `+9197…` phone, plots, lots and batches; the seeded batch
`FGP8T4033HM7` is only read. The API allows 10 OTPs per phone per 24 h, so sessions are kept in
`qa/robot/results/.api-sessions.json` and refreshed on reruns; the identity suite still spends one or two OTPs
on seeded farmers `+919000000011..13` per run, so after about five runs a day reseed the stack.

## Tagging rules

- Every test carries its work package `WP-<id>` (e.g. `WP-B02`) and at least one PRD requirement `FR-<n>`
  (PRD numbering, no zero padding: `FR-1`, `FR-29`). Benchmark tests also carry `BM-<nn>`.
- `not-ready`: placeholder until its WP merges; body is `Not Ready  <WP>` (skips). The WP's worker or the QA Lead
  replaces the body and removes the tag. CI and gates run with `--exclude not-ready`.
- `smoke`: runs in seconds; `api/healthz.robot` holds the stack smoke test, the mobile and public suites hold
  ones that need no stack. `flaky`: reported as P2 (qa-rubric); at most two reruns.
- Before a gate or WP verdict, `qa/scripts/gate-readiness.py <WP|G<n>>` must PASS (no placeholder left).
- Evidence: copy `report.html` and `output.xml` from `qa/robot/results/<WP>/` to `docs/agents/qa/<WP>/robot/`.

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

Keywords: `resources/common.resource`
(`Stack Is Healthy`, `Error Code Should Be`, `Gate Reasons Should Be`, `Second FPO Admin`,
`Connect To AgriTrace Database`, `Not Ready`) and `lib/agritrace_keywords.py` (`Load Network Profiles`,
`Set Emulator Network`, `Parse Flutter Results`, `Read Public Page`; API: `Login As`, `Call API`, `QA World`,
`New Farmer`, `New Plot`, `New Lot`, `New Instrument`, `Start Assist`, `New Consent`, `Moisture`, `Event`, `Push`,
`Received Lot`, `Receive`, `New Batch`, `Packing`, `Flags Of`, `Wait For Flag`, `Wait For Build`, `Drain Pull`,
`Compose`, `S3 Get`, `S3 Versions`, `S3 Put`, `Decode QR`, `Days Ago`, `New Phone`).
