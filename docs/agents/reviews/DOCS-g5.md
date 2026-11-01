<!-- Purpose: G5 DOCS review: the documentation-coverage gates run as CI runs them, the DECISION comment audit,
and the README "Five-minute start" walked from a clean clone. Serves: PLAN.md §10 step 4 (G5 extras), §3 G5
("docs coverage script 100 %"), BM-10, CLAUDE.md §5, D-010. Readers: Orchestrator (applies the README fixes),
Architect-Gate (G5 sign-off). -->

# DOCS review for G5

- **Reviewer:** DOCS Reviewer (Opus), read-only on code
- **Date:** 2026-11-02
- **Tree:** `main` @ `4b7d1e6`
- **Verdict:**
  - (a) The coverage gates PASS.
  - (b) The DECISION audit PASS.
  - (c) The README "Five-minute start" needs **8 docs-only fixes**. Two of them would stop a new developer:
    the port clash (R3) and the `flutter run` target (R5).
  - Replacement text is at the end; the Orchestrator can apply it directly.

## (a) Documentation-coverage gates, run as CI runs them

These are the commands from `.github/workflows/ci.yml` job `docs`:
`uv run --no-project python infra/scripts/doc-coverage.py`, after `flutter pub get` and `npm ci`. The run
used the main checkout at `4b7d1e6` (exit 0, 1 min 40 s). Per-tool counts were re-run in the clean clone.

| Gate | Target | Result | Count |
|---|---|---|---|
| interrogate 100 % (Google docstrings) | `apps/api` (`agritrace`) | PASS | 1029 of 1029 items, 100.0 % |
| interrogate 100 % | `apps/public-page` (`agritrace_page`) | PASS | 59 of 59, 100.0 % |
| interrogate 100 % (CI docs job, QA layer) | `infra/scripts qa/robot/lib qa/scripts` | PASS | 95 of 95, 100.0 % |
| `flutter analyze --fatal-infos` (incl. `public_member_api_docs: true`, `analysis_options.yaml:23`) | `apps/mobile` | PASS | "No issues found!" (11.0 s) |
| `npm run lint` (eslint strictTypeChecked + `eslint-plugin-jsdoc` flat/recommended-typescript-error, `--max-warnings 0`, then Prettier) | `apps/portal` | PASS | 71 files linted, 0 errors, 0 warnings; Prettier clean |
| DECISION ids named in DECISIONS.md (doc-coverage.py) | apps, packages, infra, qa | PASS | 163 comments, 0 unknown |
| File header in the first 5 lines (doc-coverage.py) | `apps/` | PASS | 912 files, 0 without a header |

## (b) DECISION comment audit

This is a small read-only script, not committed:
`/private/tmp/claude-501/-Users-fi-it-Documents-projects-agriGitag/1234289e-8332-4673-8beb-a187a8f85a38/scratchpad/decision_audit.py`.
It reads `git ls-files apps packages infra qa`, collects every `DECISION D-\d{3}`, and compares them with the
`DECISIONS.md` index rows and the `docs/adr/D-*.md` files.

| Check | Result |
|---|---|
| DECISION ids cited in code / comments | 50 distinct ids, 165 occurrences |
| Cited in code but not indexed in DECISIONS.md | none |
| Indexed but no ADR file | none |
| ADR file not indexed | none |
| Index link to a missing file | none |
| Gap in numbering | `D-049`. Intended: TODO.md:210 ledger, "D-049 P06 (unused)". D-055…D-063 are reserved there and none is in code yet. |
| Indexed but never cited in code (informational) | `D-001`, `D-010`, `D-043`. These are process or architecture decisions with no single code site; not a defect. |

The 165 vs 163 difference against doc-coverage.py is expected: my script also counts `DECISION D-` inside
documentation files under `apps/`.

## (c) README "Five-minute start" from a clean clone

`git clone /Users/fi-it/Documents/projects/agriGitag /tmp/agritrace-clean-clone` (local, no network). I then
followed README.md, `apps/portal/README.md` and `apps/mobile/README.md` literally. The full log is in the
session scratchpad (`clone.log`). The clone has been deleted.

| Step (as documented) | Command run in the clone | Result |
|---|---|---|
| Toolchain | `uv 0.12.1`, `python3.12`, `node v24.7.0`/npm 11.5.1, `Flutter 3.38.4`, system `java 1.8.0_202` | README names no versions (R2) |
| Clean clone has no env files | `infra/.env`, `apps/api/.env` | both absent, as intended (git-ignored) |
| `make up` | **not run from the clone** (instructed) | The shared stack already runs on the default ports (`agritrace-api-1` on 8000, `agritrace-db-1` on 5433 through the main checkout's untracked `infra/.env` `DB_PORT=5433`). I verified it against the running stack: `GET /v1/healthz` → `{"db":"ok","redis":"ok","s3":"ok"}`, `GET /docs` → 200. On this machine a Homebrew Postgres listens on `127.0.0.1:5432`, so `make up` from a clean clone would fail to bind the `db` port (R3). |
| `make seed` | not run (needs `make up`) | Verifier evidence: `docs/agents/qa/B12.md:8, 40` (`make seed` twice on the live stack, idempotent, exit 0) |
| `open http://localhost:8000/docs` | `curl` on the running stack | 200 |
| `make test` | not run (full suite, needs Docker; instructed) | README offers no Docker-free check (R4) |
| (backend unit tests) | `cd apps/api && uv sync` then `make test-unit` | PASS, 631 passed in 100.7 s. No `apps/api/.env` was needed (the tests set their own settings). |
| Portal `npm install && npm run dev` | `npm ci` (per apps/portal/README), `npm run typecheck`, `npm run lint` | PASS / PASS / PASS. `npm ci` prints `EBADENGINE`: `jsdom@30.1.3` and `@asamuzakjp/*` need node `^24.15.0`, the machine has 24.7.0 (R2). README says `npm install` (R6). `npm run dev` was not started (it needs the stack's API on 8000; same reasoning as `make up`). |
| Mobile `cd apps/mobile && flutter run` | `flutter pub get`, `flutter analyze --fatal-infos` | PASS / PASS. `flutter run` as written cannot work: there is no `lib/main.dart`, only `main_dev.dart`, `main_staging.dart` and `main_prod.dart` (R5). Not run: no emulator. |
| Public page | `cd apps/public-page && uv sync && uv run pytest -q` | PASS, 76 passed |
| Client generation (`make clients`, CLAUDE.md §8) | `java -version` → 1.8 | Not run (needs network for npx and the generator). `apps/mobile/tool/gen_api.sh:24-25` refuses Java < 11. The README does not mention it; only the Makefile comment names `JAVA_HOME` (R7). |

### Findings (README fixes, docs-only)

| # | Severity | What is wrong | Fix |
|---|---|---|---|
| R1 | P2 | README line 10 says "Postgres+PostGIS, Redis, MinIO, …". The stack runs LocalStack S3 (D-008) and Valkey (D-021); there is no MinIO. | "Postgres+PostGIS, Valkey, LocalStack S3, Mosquitto, api, worker" |
| R2 | P2 | No prerequisites or versions. | Add a "You need" line: Docker with Compose v2; `uv` (it fetches Python 3.12); Node **≥ 24.15** and npm; Flutter **3.38.4**; Java 11+ only for `make clients`. |
| R3 | **P1 for a new developer** | A host Postgres on 5432 (common with Homebrew), or another stack on 6379, 4566 or 8000, makes `make up` fail. The remedy (`DB_PORT=…` in `infra/.env`) is only in infra/README. Host-side tools then also need the port changed in `apps/api/.env`. | Add: "Port taken? Put `DB_PORT=5433` (or `REDIS_PORT`, `S3_PORT`, `API_PORT`) in `infra/.env` (git-ignored). For host-side `uv run alembic`/`uvicorn`, `cp apps/api/.env.example apps/api/.env` and change the port in `DATABASE_URL`. See infra/README.md." |
| R4 | P2 | `make test` is the full suite. It needs Docker (testcontainers) and takes far longer than five minutes. | Lead with `make test-unit  # 630+ unit tests, no Docker, ~2 min`, then `make test  # everything; needs Docker`. |
| R5 | **P1 for a new developer** | `cd apps/mobile && flutter run` fails: no `lib/main.dart`. | `cd apps/mobile && flutter pub get && flutter run -t lib/main_dev.dart` (Android emulator → host API at 10.0.2.2:8000; see apps/mobile/README.md) |
| R6 | P3 | Portal: `npm install` rewrites the lockfile, while CI and apps/portal/README use `npm ci`. Nothing says how to sign in. | `cd apps/portal && npm ci && npm run dev` → http://localhost:5173. Sign in as the seeded FPO admin `9000000001`, code `123456` (`OTP_DEV_CODE`); the first sign-in chooses the 4-digit PIN. `npm run dev:mock` runs without the stack. |
| R7 | P3 | Client regeneration is missing, and it needs Java 11+ through `JAVA_HOME` when the system Java is older (here 1.8). | "After an API change: `make openapi && JAVA_HOME=<JDK 11+> make clients` (macOS: Android Studio's JBR, see the Makefile)." |
| R8 | P3 | "Where things are" table: `docs/api/` is described as holding the "OpenAPI spec", but it holds only `conventions.md` and `error-codes.md`; the spec is `packages/openapi/openapi.json`. "First line of CHECKLIST.md" is the title, and the status is on line 3. | `docs/api/` → "API conventions, generated error-code table". Add a row `packages/openapi/openapi.json` → "Generated OpenAPI spec (D-003)". Status: "the `Completion:` line at the top of `CHECKLIST.md`". |

### Replacement for README.md lines 8-17 (Orchestrator to apply)

````markdown
## Five-minute start

You need Docker (Compose v2), [uv](https://docs.astral.sh/uv/) (it fetches Python 3.12), Node ≥ 24.15 with npm,
and Flutter 3.38.4. Java 11+ is needed only for `make clients`.

```bash
make up            # Postgres+PostGIS, Valkey, LocalStack S3, Mosquitto, api, worker (waits until healthy)
make seed          # migrate the DB, then the demo FPO with three farmers and the reference batch
open http://localhost:8000/docs   # Swagger UI (every field documented)
make test-unit     # backend unit tests, no Docker needed (~2 min)
make test          # every backend test; integration tests start their own containers (Docker)
```

Port taken (for example a local Postgres on 5432)? Put `DB_PORT=5433` (or `REDIS_PORT`, `S3_PORT`, `API_PORT`)
in `infra/.env`, which is git-ignored. For host-side tools, `cp apps/api/.env.example apps/api/.env` and
change the port in `DATABASE_URL`. See `infra/README.md`.

- Portal: `cd apps/portal && npm ci && npm run dev`, then open http://localhost:5173. Sign in as the seeded
  FPO admin `9000000001` with code `123456`; the first sign-in chooses the PIN. `npm run dev:mock` needs no
  stack.
- Mobile: `cd apps/mobile && flutter pub get && flutter run -t lib/main_dev.dart` (an Android emulator
  reaches the API at 10.0.2.2:8000). See `apps/mobile/README.md`.
- After an API change: `make openapi && make clients`. `make clients` needs Java 11+; set `JAVA_HOME` if
  `java` is older (see the Makefile).
````

## What I did not run

- `make up`, `make seed` and `npm run dev` from the clone. The shared stack occupies the ports, so these were
  verified on the running stack and from the B12 Verifier evidence.
- `make test` (full suite) and `flutter test`, as instructed.
- `make clients` / `gen_api.sh` (needs network and JDK 11+).
- `flutter run` (no emulator).

Risk: none of R1-R8 touches code. R3 and R5 are the two a newcomer would hit first.
