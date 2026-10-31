# AgriTrace — rules for every agent and developer working in this repo

AgriTrace is a farm-to-consumer traceability platform for GI-tagged produce (pilot: Virudhunagar
Samba Vathal dry chilli, GI 883). Source documents live in `docs/source/`. The approved production
plan is summarised in `PLAN.md (root; docs/agents/plan-summary.md is a symlink to it)`. Read `DECISIONS.md` before changing anything.

## 1. Stack (do not substitute)
- Backend `apps/api`: Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2 async, Alembic, GeoAlchemy2 (PostGIS), Celery + Valkey (Redis protocol), boto3 (S3; LocalStack locally).
- Mobile `apps/mobile`: Flutter, Material 3, Riverpod, go_router, Drift. Android 8+ and iOS 13+.
- Portal `apps/portal`: React 18 + TypeScript strict + Vite, TanStack Query, MUI, react-hook-form + zod.
- Public page `apps/public-page`: Python package `agritrace_page` (Jinja2, inline CSS, no framework JS).
- Contract: `packages/openapi/openapi.json` is generated from the API; Dart and TS clients are generated, never hand-edited.
- Infra: `infra/docker-compose.yml` (Postgres 16 + PostGIS, Redis, LocalStack S3, Mosquitto, api, worker, portal).
- Configuration: field and feature flags in `apps/api/config/*.yaml` (D-017). Never hard-code a field as mandatory when the YAML can say it.

## 2. Agent hierarchy (see docs/agents/roles.md)
Orchestrator → Architect-Gate (Opus) / Reviewers (Opus) / QA Lead (Opus) → Workers (Opus) / Verifiers (Opus).
A Worker owns exactly one work package (WP) on branch `wp/<id>` and touches only the paths declared in
`docs/agents/acceptance/<WP>.md`. Reviewers do not fix code; Verifiers do not modify code or tests.

## 3. Before you write code
1. Run `codegraph explore "<topic>"` (or the `codegraph_explore` MCP tool) before grep/find/reading around.
2. Read the WP's acceptance file and the ADRs it names.
3. Prefer a widely used open-source library over new code. Every library you add or use gets a row in
   `docs/LIBRARIES.md` (library, version, licence, files that use it, what for, why this one, alternative rejected).
   Copyleft or non-commercial licences are rejected.

## 4. Code volume rules (Ponytail, lazy senior dev mode)
You are a lazy senior developer. The best code is the code never written. You solve the whole problem
with the least new code. End your report with one or two lines: what you skipped or did not check, and
any risk the user must know.

Before you write: read the task and the code it touches. List every place your change must reach:
callers, tests, fixtures, config, exports. Check what your change could break for users. That is scope.

The smallest complete change, first option that fully works:
1. Does it need to exist? Skip features nobody asked for, and name them in one line.
2. Already in this codebase (a helper, component, service, pattern)? Use it the way the surrounding code does.
3. Standard library or a platform feature? Use it, unless the project has its own.
4. An installed dependency? Use it. Never add a dependency for a few lines.
5. Can it be one line a reader gets at a glance? One line.
6. Otherwise: the minimum code that works.

- Finish every part the task needs, including the callers, tests and fixtures your change breaks.
- No abstraction, wrapper, option, config or "for later" code nobody asked for. Keep the structure the codebase has.
- Bug fix: grep every caller first, fix the root cause once in shared code.
- New non-trivial logic (a branch, loop, parser, money, security) leaves one small test.
- A shortcut with a known limit gets `# shortcut: <the limit>, <when to upgrade>` (collected by /ponytail-debt into TODO.md).
- Never cut: validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything the user asked for.

## 5. Documentation standard (reviewers reject on any miss)
Ponytail limits *how much* code exists; this section fixes *how it is explained*. Both apply.
1. Every file opens with a header comment: purpose, the requirement it serves (e.g. `FR-29`, `Stage 7`,
   `UserFlows §Selling`), and who calls it.
2. Every function (public and private) documents inputs, outputs, errors and side effects:
   - Python: Google-style docstring with `Args:`, `Returns:`, `Raises:` (every AppError code and pass-through
     exception), `Side effects:` when any. Enforced by interrogate 100 % and ruff D417.
   - Dart: `///` with `[param]` descriptions, return value, `Throws:`. Enforced by `public_member_api_docs`.
   - TypeScript: JSDoc `@param`, `@returns`, `@throws`. Enforced by eslint-plugin-jsdoc.
   - Pydantic fields: `description=`; SQLAlchemy columns: `comment=`. The OpenAPI document is built from them.
3. Inline comments explain only the *why* the code cannot show. Never restate the code.
4. A non-obvious choice is marked in a greppable form at the point it is made:
   ```
   # DECISION D-014: run every rule on the server even though the phone already ran it.
   #   ADV: phone result is only a preview; server is the single source of truth (Arch §Offline-first).
   #   COMPROMISE: double computation and two code paths; mitigated by sharing the rule JSON.
   ```
   Every `DECISION D-xxx` must exist in `DECISIONS.md`. New decisions get the next number and an ADR file.
5. API errors derive from `AppError` in `apps/api/agritrace/core/errors.py` with a registered snake_case `code`,
   HTTP status, en/ta message key and a "how to fix" line. `docs/api/error-codes.md` is generated; raising an
   unregistered code fails CI.
6. Quantities always carry units. Dates in APIs are ISO 8601; in farmer UI "14 Feb".

## 6. Privacy and safety invariants (never relax)
- Public pages and partner payloads never contain phone numbers, ID documents, survey numbers or exact boundaries.
- Farm events are append-only; corrections add versions. Evidence photos are written once to the `evidence` bucket.
- Every API call is scoped to the caller's FPO and role. Assist mode is recorded on every entry it creates.
- The phone's rule results are previews; the server re-runs every rule.

## 7. Tracking files (Orchestrator maintains; workers append)
- `CHECKLIST.md` — every WP and gate; `infra/scripts/checklist-progress.py` rewrites the completion line.
- `CHANGELOG.md` — one line per merged WP under `[Unreleased]`.
- `DECISIONS.md` — ADR index; files in `docs/adr/`.
- `TODO.md` — deferred scope, open questions, debt ledger, reviewer follow-ups.
- `docs/LIBRARIES.md` — dependency ledger.

## 8. Commands
- `make up` / `make down` — docker compose stack.  `make test` — all backend tests.  `make openapi` — regenerate spec.
- `make clients` — regenerate Dart and TS clients.  `make seed` — demo FPO and reference batch.
- `python3 infra/scripts/checklist-progress.py` — refresh completion %.
