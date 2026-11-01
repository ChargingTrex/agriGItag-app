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
(http://localhost:4566/public-pages), `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `OTP_DEV_CODE` (no default: set it to the stack's dev code, 123456 for the local
compose stack; any sign-in with it unset stops the run with a Fatal Error before a code is requested, so a stack
without the dev OTP never texts a real phone). Test phones come from the seed's `+919000…` block (`New Phone`),
and user phone numbers are compared inside `Page Leaks Any User Phone`, which returns only a count: no phone number
reaches a Robot log or report (CLAUDE.md §6).
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

### Portal suite (gate G4, Q07)

`portal/portal.robot` drives the real portal in headless Chromium. Serve it in live mode (no `VITE_MSW`) against
the stack under test; the dev server proxies `/v1` to `API_URL`, and `VITE_PUBLIC_BASE_URL` must equal the API's
`PUBLIC_BASE_URL` (the published link and the QR are compared with `PUBLIC_BASE_URL`):

```sh
cd apps/portal && API_URL=http://localhost:8044 VITE_PUBLIC_BASE_URL=http://localhost:4596/public-pages \
  npx vite --port 5183 --strictPort
export API_BASE=http://localhost:8044/v1 PORTAL_BASE=http://localhost:5183 \
       PUBLIC_BASE_URL=http://localhost:4596/public-pages OFFICE_PIN=1234
qa/.venv/bin/robot --outputdir qa/robot/results/G4 --exclude not-ready qa/robot/portal/
```

The FPO admin signs in once per run through the login form (on a fresh seed the form chooses `OFFICE_PIN`); the
farmers, plots, packed lots and QC gradings each line needs are made over the API with the keywords below. With
`rfbrowser init --skip-browsers`, set `PLAYWRIGHT_BROWSERS_PATH` to a Playwright cache that holds the Browser
library's Chromium revision (e.g. `~/Library/Caches/ms-playwright`). "Happy Path Publishes And Shows The URL" uses
the batch that "Create Batch Returns An Id And A QR" makes, and the P05/P06 batch lines use that published batch, so
run the suite whole. The suite also needs the database (`DB_PORT`): it gives the admin the super-admin flag for the
villages import and switches the FPO's farmer-name setting (no API does either) and restores both at the end. The
P07 lines run `npx playwright test e2e/chain.spec.ts` / `e2e/axe.spec.ts` in mock mode (`npm ci` in apps/portal;
Playwright starts `npm run dev:mock` on :5174).

### Public page and reference batch (gates G4/G5, Q07 round 2)

`public/page.robot` W03 lines use the fixture build (the Tamil font line needs `rfbrowser init`); its two Q03 lines need
the live stack and `COMPOSE`, and stop and restart the stack's api and worker. Lighthouse lines need `npm ci` in
apps/public-page and a Chrome (`CHROME_PATH`, or an installed Google Chrome). `e2e/reference_batch.robot` is the live
form of B12's e2e test: the "before fixes" lines skip unless FGP8T4033HM7 is still as seeded (fresh seed), and the
clients line needs node_modules in apps/portal, Java 11+ (`JAVA_HOME`) and `dart`.

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
| `portal/portal.robot` | P00 smoke, P01-P08 and the P07 chain/axe (real, Q07) | G4/G5 |
| `public/page.robot` | W01-W03, Q03; real smoke runs privacy-lint on the fixtures | G4 |
| `e2e/reference_batch.robot` | B12 seeded batch `FGP8T4033HM7` | G5 |

Keywords: `resources/common.resource`
(`Stack Is Healthy`, `Error Code Should Be`, `Gate Reasons Should Be`, `Second FPO Admin`, `Publish Batch`,
`Connect To AgriTrace Database`, `Not Ready`) and `lib/agritrace_keywords.py` (`Load Network Profiles`,
`Set Emulator Network`, `Parse Flutter Results`, `Read Public Page`; API: `Login As`, `Call API`, `QA World`,
`New Farmer`, `New Plot`, `New Lot`, `New Instrument`, `Start Assist`, `New Consent`, `Moisture`, `Event`, `Push`,
`Received Lot`, `Receive`, `Packed Lot`, `Grade Batch`, `Fix Reference Batch`, `Template CSV`, `Unitless Quantity Columns`, `Unitless Quantities`, `New Batch`, `Packing`, `Flags Of`, `Wait For Flag`, `Wait For Build`, `Drain Pull`,
`Compose`, `S3 Get`, `S3 Versions`, `S3 Put`, `Decode QR`, `Days Ago`, `New Phone`).
