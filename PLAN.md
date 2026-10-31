# AgriTrace — Production Plan

> Root copy of the approved multi-agent production plan (2026-10-29). Live status: `CHECKLIST.md` (completion %), `CHANGELOG.md`, `TODO.md`, `DECISIONS.md`. Agent protocol: `docs/agents/`. Detailed design specs: `docs/agents/specs/`.


## Context

The folder `/Users/fi-it/Documents/projects/agriGitag/` holds four product documents and no code: the PRD (72 functional requirements), the System Architecture, the Dataflow & Action Flow (stage-by-stage data, roles, approval gates), and the User Flows (farmer-first UX rules). The user wants these turned into a working **Pilot release** of AgriTrace by a fleet of coding agents with a strict hierarchy, Opus reviewers at checkpoints, QA/verification agents, measurable benchmarks, and root-level tracking files (`DECISIONS.md`, `CHANGELOG.md`, `CHECKLIST.md`, `TODO.md`) so project completion is visible at a glance.

Decisions the user made during planning (these override the source docs where they conflict):

| Topic | Decision | Source-doc conflict |
|---|---|---|
| Scope | Pilot release = PRD Phase 1 + Phase 2 foundations (offline sync, GI check, yield ceiling, Standards Profile grading, flags). Partner API, IoT probes, WhatsApp/IVR, multi-state i18n are **stubs + TODO** | none |
| Backend | **Python**: FastAPI + Pydantic v2 + SQLAlchemy 2 (async) + Alembic + GeoAlchemy2 + Celery/Redis | Architecture doc says NestJS → recorded as D-001 |
| API contract | OpenAPI 3.1 generated from Pydantic models; Swagger + Redoc served; Dart and TS clients generated from the spec; every model field commented | none |
| Mobile | Flutter, Material Design 3, **Android 8+ and iOS**, offline-first (Drift/SQLite), **app size budget 100 MB** (user raised it from the doc's 30 MB) | Architecture doc leaves iOS open and says 30 MB → D-002 |
| Configuration | Field and feature flags in **YAML** (`apps/api/config/`), per-tenant overrides, so customers can enable/disable data fields without code changes | none → D-017 |
| Libraries | Prefer widely used open-source libraries over hand-written code; every dependency recorded in `docs/LIBRARIES.md` with the files that use it and why | none → D-018 |
| GI boundary | Derived from open administrative boundaries for the Virudhunagar taluks named in the GI journal; stored with honest provenance, not a hand-drawn polygon | none → D-019 |
| Portal | React + TypeScript + Vite | none |
| Infra | Everything in Docker Compose: Postgres 16 + PostGIS, Redis, MinIO (S3 stand-in, versioning + object lock), Mosquitto stub, api, worker, portal | none |
| Worker model | **Opus** for all coding agents; **Opus** for reviewers and gate checks | none |
| Code volume | **Ponytail** ruleset (installed plugin 5.3.2, currently project-scoped to a different project; must be installed for this project) governs how little code is written; `/ponytail-review` runs at every checkpoint | none |
| Code intelligence | **CodeGraph 1.6.0** (installed) initialised in the repo after scaffold; every agent queries it before grep | none |

Local toolchain verified: Python 3.15 + uv, Node 24, Flutter 3.38.4, Docker (installed, **not running**), psql, git, gh, codegraph 1.6.0 (1.6.2 available).

### Gap analysis against the live Virudhai Samba Chilli GI app page

Source: https://virudhaisambachilli.com/services/geographical-indication-gi-app-for-traceability/ (text plus the three screenshots on it). The text describes outcomes (QR authentication, digital records for cultivation/processing/packaging, onboarding of farmers, processors, SHGs and FPOs, "blockchain-based"). The screenshots show the existing GITrace admin portal and the NABARD/MABIF "NABTRACE" farmer app. Features visible there that the four source docs and the plan did not yet cover, and what the plan now does about each:

| Seen on the page | Status in source docs | Plan action |
|---|---|---|
| **Master data uploads** menu (bulk CSV of farmers, villages, inputs) | Not covered | New WP **P08** bulk import with validation report; backend **B13** import endpoints |
| **Stage-progress dashboard**: per-stage tiles (Land prep, Bed prep, Sowing, Harvest, Drying, Packing) with done / in-progress / not-started counts, filtered by crop → district → block → village | FR13/FR20 only say "dashboard" | **P06** spec made explicit: stage tiles + filters + per-farmer table with column show/hide |
| **Land Area Analytics** | Not covered | Added to **P06**: acres by village/block, declared vs walked, GI-confirmed share |
| **Finished Goods** | Only implicit in batches | Added to **P04/P06**: packed batches inventory with remaining quantity and label count |
| **Audit Logs** viewer | Audit export only (FR21) | Added to **P06**: searchable audit log UI over `audit_log` |
| **Processor** management (separate from FPO) | PRD §5 has "Processor / FPO entity"; registry had only `fpos` | **B03**: `processors` table (name, type, FSSAI, GI authorised-user no.) and lot intake references a processor; **P01** screen |
| **State → District → Block → Village → Pincode** masters with LGD codes | FR53 structured address | **B03**: `villages` master (LGD code, taluk, block, pincode) + `/sync/bundle/villages`; onboarding picks from list |
| **Aadhaar / ID number + farmer photo** at registration | Stage 0 "ID proof stored securely" | **B02/B03**: `id_documents` in the encrypted `id-docs` bucket, **off by default** via `features.yaml` (`id_document_capture`), consent-gated |
| **PIN for farmer accounts** (NABTRACE) | User Flows says no passwords for farmers | Kept OTP-only by default; `features.yaml: farmer_pin_login` flag for FPOs that want it |
| **Multiple farm lands per farmer** ("My Farm Lands") | FR2 allows plots (plural) | **M09/M08** acceptance: "Add another plot" path; portal P01 lists all plots |
| **SHG / women producer groups** as a stakeholder | Not covered | `producer_groups` table behind `features.yaml: producer_groups` (off in pilot); TODO.md |
| **Blockchain** claim | PRD §8: out of scope for v1 | Stays out; TODO.md notes the marketing claim and the append-only audit + S3 Object Lock as the v1 answer |
| Capacity building / field coordinator training | Not software | 60-second voice tour and replay (already in M07/M08) |

Nothing on the page contradicts the farmer-first UX in the User Flows doc; the NABTRACE screens are form-heavy (typed name, Aadhaar, lat/long boxes), which the User Flows doc deliberately avoids. The plan keeps the three-tap design and adds the admin-side features above.

---

## 1. Repository layout (monorepo)

```
agriGitag/
├── CLAUDE.md                 # agent operating rules (Ponytail + doc standard + hierarchy)
├── DECISIONS.md              # ADR log: D-001… each with Advantages / Compromises / Revisit-when
├── CHANGELOG.md              # Keep-a-Changelog; one entry per merged work package
├── CHECKLIST.md              # Every WP + gate as checkbox; completion % auto-computed by script
├── TODO.md                   # Deferred items, stubs, open questions from the docs, debt ledger
├── README.md                 # 5-minute start: docker compose up, run tests, run app
├── docs/
│   ├── source/               # the four original .md documents (moved here, unchanged)
│   ├── api/                  # generated openapi.json + Redoc HTML + API conventions + error-codes.md (generated)
│   ├── LIBRARIES.md          # dependency ledger: library, version, licence, files using it, why
│   ├── adr/                  # one file per decision (DECISIONS.md is the index)
│   └── agents/               # role cards, checkpoint protocol, QA rubric, reviews, audits, gates
├── apps/
│   ├── api/                  # Python FastAPI + Celery (one package, two entrypoints)
│   │   └── config/           # fields/<entity>.yaml, features.yaml, tenants/<fpo>.yaml (D-017)
├── qa/
│   └── robot/                # Robot Framework suites, keyword libs, results/<gate>/
│   ├── mobile/               # Flutter app (farmer / field officer / QC modes)
│   ├── portal/               # React + TS FPO admin portal
│   └── public-page/          # Jinja2 templates + CSS for the static batch page (rendered by api worker)
├── packages/
│   ├── openapi/              # openapi.json (source of truth after generation) + codegen configs
│   ├── client-dart/          # generated Dart client
│   └── client-ts/            # generated TS client
├── infra/
│   ├── docker-compose.yml
│   ├── docker-compose.ci.yml
│   └── scripts/              # seed.py, checklist-progress.py, privacy-lint.py, benchmarks/
└── .github/workflows/        # ci.yml (lint, test, build, benchmarks, privacy lint)
```

---

## 2. Agent hierarchy and roles

```
                 ┌──────────────────────────────┐
                 │  ORCHESTRATOR (this session) │  owns CHECKLIST/TODO/CHANGELOG, spawns, merges
                 └──────────────┬───────────────┘
        ┌───────────────────────┼─────────────────────────┐
┌───────┴────────┐    ┌─────────┴─────────┐     ┌─────────┴────────┐
│ ARCHITECT-GATE │    │  REVIEWERS (Opus) │     │  QA LEAD (Opus)  │
│ (Opus)         │    │  one per domain   │     │  owns benchmarks │
│ approves       │    │  BE / MOB / WEB   │     │  + verification  │
│ interfaces,    │    │  SEC / DOCS       │     │  agents          │
│ ADRs           │    └─────────┬─────────┘     └─────────┬────────┘
└───────┬────────┘              │                         │
        │              ┌────────┴─────────┐      ┌────────┴────────┐
        │              │ WORKERS (Opus)   │      │ VERIFIERS       │
        └──────────────┤ one per WP       │      │ run acceptance  │
                       │ BE-xx MOB-xx     │      │ tests, attach   │
                       │ WEB-xx PUB-xx    │      │ evidence        │
                       └──────────────────┘      └─────────────────┘
```

### Role cards (written to `docs/agents/roles.md`, pasted verbatim into each spawn prompt)

| Role | Model | May do | May not do | Deliverable |
|---|---|---|---|---|
| **Orchestrator** | this session (Fable) | Spawn/sequence agents, merge branches, update `CHECKLIST.md`/`CHANGELOG.md`/`TODO.md`, run gate scripts | Write feature code | Running project, green gates |
| **Architect-Gate** | Opus | Review and approve: OpenAPI spec, DB schema, Drift schema, module boundaries, every ADR | Write code | Signed `docs/adr/D-xxx.md`, "APPROVED" line in CHECKLIST |
| **Worker** | Opus | Implement exactly one WP on branch `wp/<id>`, write its tests, its ADR stubs, its CHANGELOG entry. **Prefer a widely used open-source library over new code** (Ponytail ladder step 4); every library it adds or uses gets a row in `docs/LIBRARIES.md` (library, version, files that use it, what for, why this one, alternative rejected) | Touch files outside its WP's declared path list; add a dependency without a `LIBRARIES.md` row and a one-line ADR note; skip tests | Branch + `docs/agents/reports/<WP>.md` (what done, what skipped, risks — Ponytail's closing lines) |
| **Reviewer** (BE/MOB/WEB/SEC/DOCS) | Opus | Run `/ponytail-review branch` per WP, run the WP's acceptance tests, read the diff for the Documentation Standard (§4) including function docs and registered error codes, reject with concrete findings. **At the end of every wave run `/ponytail-audit`** on the merged tree and file its findings as `docs/agents/audits/wave-<n>.md`; P1 findings block the next wave | Fix code (sends back to the worker) | `docs/agents/reviews/<WP>-r<n>.md` with PASS/FAIL + findings; wave audit file |
| **QA Lead** | Opus | Own `infra/scripts/benchmarks/`, define pass thresholds, assign Verifiers, sign Gates. **Write and maintain the Robot Framework suites** in `qa/robot/` (see §9.1) that Verifiers execute | Write feature code | Gate report per milestone; Robot suites |
| **Verifier** | Opus | Execute acceptance tests + benchmark scripts on the docker stack / emulator, capture logs & screenshots, fill rubric | Modify code or tests | `docs/agents/qa/<WP>.md` with evidence paths |

Hierarchy rules: a Worker reports only to its Reviewer; a Reviewer escalates design disagreements to Architect-Gate; QA Lead can block a Gate but not rewrite scope; Orchestrator resolves ties and records the outcome in `DECISIONS.md`.

### Spawn mechanics (what the orchestrator actually does)
- One `Agent` call per Worker with `model: "opus"`, `isolation: "worktree"` (branch `wp/<id>`), prompt = role card + WP spec + Documentation Standard + Ponytail `AGENTS.md` text + "query `codegraph explore` before grep".
- Up to **4 workers in parallel** per wave (WP tables below mark waves); workers in one wave touch disjoint paths.
- Reviewer spawned when the worker's report lands; max **2 review rounds** before escalation to Architect-Gate.
- Verifier spawned after Reviewer PASS; Orchestrator merges only on Verifier PASS, then ticks `CHECKLIST.md` and appends `CHANGELOG.md`.

---

## 3. Checkpoints and gates

| Gate | When | Who signs | Must be true |
|---|---|---|---|
| **G0 Foundation** | after Wave 0 | Architect-Gate | repo scaffold, docker stack up, CI green on empty tests, CodeGraph indexed, Ponytail installed, tracking files exist |
| **G1 Contract** | after OpenAPI + DB schema + Drift schema WPs | Architect-Gate | spec validates, clients generate, every schema field has a description, ADRs D-001…D-010 signed |
| **G2 Core backend** | identity, registry, events+sync, rules, lots/batches, quality | QA Lead + BE Reviewer | all BE acceptance tests pass in CI; seed demo FPO loads; reference batch problems (PRD §12.2) are each caught by a named flag |
| **G3 Mobile core** | offline store, sync engine, farmer home + 8 events, onboarding | QA Lead + MOB Reviewer | offline/online matrix passes on Android Go emulator profile; APK < 30 MB; 3-tap path scripted ≤ 60 s |
| **G4 Portal + Publish** | portal flows, static page, QR | QA Lead + WEB Reviewer | Playwright e2e green; Lighthouse ≥ 90 on 3G profile; privacy lint zero hits |
| **G5 Pilot candidate** | all WPs | All reviewers + SEC + DOCS | `/ponytail-audit` clean of P1; security checklist; docs coverage script 100%; CHECKLIST shows 100% |

Every gate additionally requires: `/ponytail-audit` run on the merged tree with zero P1 findings (report in `docs/agents/audits/`), the Robot Framework suites for the finished WPs green (`qa/robot/results/<gate>/report.html`), `docs/LIBRARIES.md` in sync with the manifests (`infra/scripts/libraries-check.py`), and `docs/api/error-codes.md` regenerated with no unregistered codes.

Each gate produces `docs/agents/gates/G<n>.md` with the evidence list; `CHECKLIST.md` has the gate as a checkbox under its milestone.

---

## 4. Documentation Standard (goes into `CLAUDE.md`; reviewers enforce it)

Ponytail says "comment only the why the code cannot show, in one line". The user wants code that human developers can maintain and change, with the reasoning preserved. These reconcile as follows and the rule is written down so agents do not oscillate:

1. **Every module/file** opens with a header: purpose, which doc requirement it serves (`FR-29`, `Stage 7`, `UserFlows §Selling`), and who calls it.
2. **Every function** (public and private, all three languages) is documented with a fixed template so a human can read inputs, outputs and failure paths without opening the body:
   - Python: Google-style docstring with `Args:` (name, type, meaning, units), `Returns:`, `Raises:` (every `AppError` code and every library exception it lets through), and `Side effects:` (DB writes, queue messages, S3 objects) where any exist. Enforced by `interrogate` (100 % including private functions, `-vv`) and `ruff` docstring rules (D417 requires every argument documented).
   - Dart: `///` doc comments with `[param]` descriptions, return value, and `Throws:` lines; enforced by `public_member_api_docs` plus a `dart doc` warnings-as-errors run.
   - TypeScript: JSDoc with `@param`, `@returns`, `@throws`; enforced by `eslint-plugin-jsdoc` (`require-jsdoc` for all functions, `require-param`, `require-returns`, `require-throws`).
   - Pydantic fields and SQLAlchemy columns carry `description=` / `comment=`; the OpenAPI document is generated from them, so API docs never drift from code.
2a. **One error-code registry.** All API errors derive from `AppError` subclasses declared in `apps/api/agritrace/core/errors.py`, each with `code` (snake_case), HTTP status, user-facing message key (en/ta), and a one-line "how to fix" note. `infra/scripts/gen-error-codes.py` renders `docs/api/error-codes.md` (code, status, raised by which endpoints, meaning, fix) and fails CI if a code is raised anywhere but not registered. Mobile and portal map codes to the one-picture-one-sentence error screens from the User Flows doc via this table.
3. **Inline comments only for "why"**, never restating the code (Ponytail rule stands).
4. **Decision comments** at the point of a non-obvious choice use a fixed form so they are greppable and the ADR index can be built from them:
   ```
   # DECISION D-014: run every rule on the server even though the phone already ran it.
   #   ADV: phone result is only a preview; server is the single source of truth (Arch §Offline-first).
   #   COMPROMISE: double computation and a second code path to keep in sync; mitigated by sharing the rule JSON.
   ```
5. **Shortcuts** use Ponytail's form `# shortcut: <limit>, <when to upgrade>`; `/ponytail-debt` collects them into `TODO.md`'s debt section.
6. `infra/scripts/doc-coverage.py` fails CI if any public symbol lacks a docstring (Python: `interrogate`; Dart: `dart doc` warnings as errors + `public_member_api_docs` lint; TS: `eslint-plugin-jsdoc` require-jsdoc on exports).

---

## 5. Root tracking files

**`DECISIONS.md`** — index table (ID, title, date, status, owner) linking to `docs/adr/D-xxx.md`. Each ADR: Context, Decision, Advantages, Compromises, Revisit-when, Linked code (`DECISION D-xxx` grep). Seeded with:

| ID | Decision | Advantages | Compromises |
|---|---|---|---|
| D-001 | Python/FastAPI backend instead of NestJS | user's stack; Pydantic → OpenAPI for free; largest hiring pool in India for Python; GeoAlchemy2 mature | portal no longer shares a language with the API (mitigated by generated TS client); architecture doc must be amended |
| D-002 | Flutter + Material 3, Android and iOS from day one, 100 MB app budget | one codebase; M3 gives large-target theming, dynamic colour off for consistency; 100 MB leaves room for bundled Tamil audio and product pictures | iOS adds signing/CI lanes; a large APK is slow to install on weak 4G, so the target stays ≤ 40 MB with 100 MB as the hard ceiling |
| D-003 | Monorepo with generated clients from OpenAPI | one contract, no drift, docs always current | codegen step in CI; generated code is not hand-edited (enforced by CODEOWNERS/lint) |
| D-004 | Modular monolith, one Python package, two containers (api, worker) | small team can run/debug; modules split later | module boundaries enforced only by import-linter, not by process |
| D-005 | Append-only events with client-generated UUIDv7 IDs | idempotent sync; no overwrite between devices; time-ordered | storage grows; "current version" needs a view; corrections are new rows |
| D-006 | Rules run on phone (preview) and server (authority), sharing a JSON rule bundle | instant feedback offline; server final | two interpreters (Dart, Python) of one JSON; contract tests keep them equal |
| D-007 | Static public page built by worker, served from S3/CDN | survives backend outage; < 2 s on 3G | rebuild on every change; versioned pages pile up (kept by design) |
| D-008 | MinIO locally with versioning + object lock as S3 stand-in | same API as prod; evidence immutability testable locally | object-lock semantics differ slightly from AWS; prod uses real S3 |
| D-009 | Celery + Redis for jobs | most widely used Python job system | heavier than ARQ; needs worker container |
| D-010 | Ponytail ruleset + Documentation Standard §4 | least code, preserved reasoning | agents must hold two rules in tension; reviewers enforce |
| D-017 | **YAML-driven field and feature configuration** (`apps/api/config/fields/<entity>.yaml`, `features.yaml`, `tenants/<fpo_code>.yaml` overrides). Each field row: name, type, required, enabled, visibility (public / partner / internal), label keys en/ta, which stage captures it. The API builds dynamic Pydantic validators from it, serves `GET /config/fields` and `GET /config/features` (also in the sync bundle) so mobile and portal render forms from the same file, and the page builder honours `visibility`. Plain YAML via `pyyaml` + `pydantic-settings`; no flag service | customers can turn fields on/off (Aadhaar, soil type, price, boundary walk, PIN login, SHG groups) without code or deploys; one source for three clients; visibility rules enforce privacy centrally | dynamic validation is harder to type-check and test (mitigated by a schema for the YAML itself and table-driven tests); a disabled required field needs a migration story; per-tenant overrides must be reviewed like code (they live in git) |
| D-018 | **Library-first implementation with a dependency ledger** (`docs/LIBRARIES.md`, checked by `libraries-check.py` against `pyproject.toml`, `pubspec.yaml`, `package.json`) | less code to maintain; well-known libraries have docs and hiring familiarity; the ledger tells future developers which file uses what and why | supply-chain surface grows; version pinning and licence review needed (ledger has a licence column; copyleft or non-commercial licences are rejected) |
| D-019 | **GI region from open administrative boundaries, not a hand-drawn polygon.** The GI Registry publishes boundaries only as prose and map drawings (Application 883, Certificate 693, GI Journal 200). Pilot stores v0 = whole Virudhunagar district outline and v1 = dissolved union of the taluks named in the journal, built by `infra/scripts/gi_boundary/build_virudhunagar.py` from the Datameet / Census 2011 sub-district layer (open licence); GADM 4.1 only as a cross-check because its licence forbids commercial use. Every version carries `source_ref`, `licence`, `confidence: district_derived`, and `taluks[]` | reproducible, legally usable, close to the legal definition (taluks), replaceable by an official file later without schema change | taluk boundaries changed after 2011 and GI taluk list must be confirmed from the journal by the compliance team (TODO); the polygon is still an approximation, so `tolerance_buffer_m` and "near_edge → review" stay on |

**`CHANGELOG.md`** — Keep-a-Changelog format; `[Unreleased]` grows one line per merged WP: `- WP-B03 events + sync endpoints (#branch) — reviewer PASS r1, verifier PASS`.

**`CHECKLIST.md`** — milestone sections (G0…G5), each WP as `- [ ] WP-xx — title — owner — reviewer — verifier`; header line `Completion: NN % (NN/NN items)` rewritten by `infra/scripts/checklist-progress.py` (also run as a pre-commit hook and printed in CI summary).

**`TODO.md`** — sections: Deferred scope (partner API, IoT, IVR…), Open questions carried from the Architecture doc (7 items), Debt ledger (from `/ponytail-debt`), Follow-ups raised by reviewers.

---

## 6. Ponytail and CodeGraph integration

- **Ponytail**: `/plugin install ponytail@ponytail` in this project (one-time, interactive); copy its `AGENTS.md` text into `CLAUDE.md` under "Code volume rules"; `/ponytail full` default; reviewers run `/ponytail-review branch`; G5 runs `/ponytail-audit`; `/ponytail-debt` feeds `TODO.md`. Band on for cost tracking per task.
- **CodeGraph**: `codegraph init .` after Wave 0 scaffold (user-authorised by this request); `codegraph sync` in the post-merge step; every worker/reviewer prompt starts with "run `codegraph explore '<WP topic>'` before any grep". MCP tool `codegraph_explore` is already allowed in settings. Mention: 1.6.2 is available (`codegraph upgrade`), not run automatically.

---

## 7. Work packages

Each WP = one Opus worker, one session, on branch `wp/<id>`, with a declared path list. "Acceptance" lines are copied verbatim into `docs/agents/acceptance/<WP>.md` and executed by the Verifier. Reconciliations between the two sub-plans: (a) public page templates + privacy linter live in `apps/public-page/` as Python package `agritrace_page`, a path dependency of the API; the publishing module calls it. (b) Photo upload is a single presigned PUT (~300 KB) in the pilot, no resumable protocol (D-011); mobile retries whole. (c) Node side uses npm workspaces (pnpm not installed). (d) Docker images pin Python 3.12 even though local is 3.15.

### 7.1 Backend (`apps/api`, package `agritrace`)

Ground rules: modules import only another module's `models.py` and `service.py` `__all__`; never its router/schemas/tasks (import-linter contract in CI). Cross-module async work via task-name constants in `core/task_names.py`. Every column has `comment=`, every Pydantic field `description=`. Quantities are `{value, unit}` pairs (FR58). Error envelope `{"error": {code, message, details}}`; 422 validation/plausibility, 409 gate violations, 501 stubs. Codes: lot `LOT`+8 hex, batch 12-char Crockford base32 (matches `FGP8T4033HM7`).

| WP | Title | Depends | Wave | Outputs | Acceptance (Verifier runs) |
|---|---|---|---|---|---|
| B00 | Scaffold + infra + test harness | — | 0 | `infra/docker-compose.yml` (postgis 16-3.4, redis 7, minio + `minio-init.sh` creating `evidence` [versioning + object lock governance], `public-pages`, `id-docs`; mosquitto; api; worker), `pyproject.toml` (ruff, mypy, import-linter, interrogate), `core/{config,db,errors,ids,schemas,storage,time,task_names}.py`, `/healthz`, `tests/conftest.py` (testcontainers), `Makefile` | `docker compose up` → `/healthz` `{db,redis,s3: ok}`; `pytest tests/unit` green; `python -m agritrace.export_openapi` writes `packages/openapi/openapi.json` with `openapi: 3.1.0` |
| B01 | Domain contracts (schema-first) | B00 | 1 | All `modules/*/models.py` (tables in backend sub-plan §2: users, memberships, otp_challenges, devices, assist_sessions, consent_records, audit_log; fpos, farmers, plots, plot_revisions, crops, gi_tags, gi_region_versions, inputs_master; events, event_versions, evidence_photos, sync_cursors; lots, lot_intakes, batches, batch_shares, batch_approvals; standards_profiles(+versions), instruments, quality_readings, grade_computations; flags; page_builds, scan_events, notifications), `alembic/versions/0001_initial.py` with append-only triggers, `core/enums.py`, `core/audit.py`, `core/auth.py` signatures, ADR D-012 | `alembic upgrade head && alembic check` no drift; `UPDATE event_versions …` raises `append_only_violation`; plots SRID 4326; import-linter + mypy clean; interrogate 100 % |
| B02 | Identity | B01 | 2 | OTP (dev bypass code), JWT 15 min + per-device refresh, `require_role`, tenant scoping, assist sessions (`X-Assist-Session`), consents, audit listener | OTP request 2× in 60 s → 429; 5 wrong codes → 409 locked; farmer on `GET /flags` → 403; assist header sets `on_behalf_of_farmer_id`; consent writes audit row with actor=officer; logout revokes refresh → 401 |
| B03 | Registry + PostGIS geo | B01, B02 | 2 | `geo.py`: `locate_point()` via `ST_Covers`/`ST_DWithin` with per-tag buffer → inside/near_edge/outside; `event_within_plot()`; shapely walked area; plot corrections with revisions; GI region upload (super-admin) | Fixture polygon + 150 m buffer: `(9.559806, 78.133521)` inside; 100 m outside → near_edge; Madurai → outside; `map_pin` → `needs_review`; correct without reason → 422; cross-FPO read → 404; admin uploading region → 403 |
| B04 | Notifications | B01 | 2 | `notifications.send` task, ConsoleProvider, `SmsProvider` protocol stub, en/ta templates, `GET /notifications` | eager send → row `sent/console`; unknown template → row `failed`, no raise |
| B05 | Quality + grade engine | B01, B03 | 2 | pure `grade_engine.compute()`, `StandardsProfileRules` Pydantic schema, `profiles/dry_chilli_agmark_v1.json` (Special ≤10, Standard ≤11, other AGMARK params `load_from_standard`), readings API with plausibility/calibration/trail checks, instruments, `POST /batches/{id}/grading` | 9.8 → Special; 10.5 → Standard; 11.4 → Below grade; visual 9.8 → Standard (source cap); missing required → incomplete; moisture −1 → 422; expired instrument → 422; grading 12.0 after intake 10.0 without reason → 422, with reason → 201 + flag; declared Special vs computed Standard → `declared_above_computed` |
| B06 | Events + sync push + evidence | B02, B03 | 3 | `POST /v1/sync/push` (≤50 entries or 256 KB, per-entry transactions, `ON CONFLICT DO NOTHING` idempotency, kinds: event_version/quality_reading/plot/consent/flag_resolution, optional `metrics[]` stored in `sync_metrics`), presigned PUT per photo, `POST /v1/sync/photos/confirm`, `events.verify_photo` (sha256 + EXIF, enqueues rules) then `events.make_variants` (WebP thumbnail ~60 KB, medium ~150 KB into `evidence_photos.variants`), discriminated-union event payload schemas, undo ≤24 h, corrections | same `client_id` 2× → 1 row, 2nd `duplicate`; foreign-owned id → `client_id_conflict`; 51 entries → 422; mixed batch: #1,#3 accepted, #2 rejected; wrong checksum → `checksum_mismatch` + flag; undo after 24 h → 409; farmer correction → 403; device clock +3 d → stored + `clock_skew` flag |
| B07 | Reference bundle + sync pull | B03, B05, B06 | 4 | `GET /sync/bundle` manifest (plots, crops, inputs, standards, gi_region, farmer_profile) with ETag/304; simplified GI geometry ≤ 50 KB; `GET /sync/pull?cursor=` | matching `If-None-Match` → 304; standards part has only `lot_gates`, `yield`, `plausible`, `limits`; pull after new flag returns exactly that flag |
| B08 | Rules & flags | B03, B05, B06 | 4 | `rules/` modules: event_location, event_order (nursery vs main field separate), practice_tags, yield_ceiling (20/30), quantity_reconciliation (>5 %), photo_evidence, gps_quality, clock_skew; tasks `rules.check_event/plot/lot`; flags API + resolution; dedupe_key | 600 m off plot → `event_off_plot` warn, re-check no dup; Inorganic with only organic inputs → `practice_tag_contradiction`; IPM w/o pest event → flag; nursery before ploughing → **no** flag; sowing before nursery → flag; 1,150/1,250/1,350 kg on 1 acre → none/warn/hold + `gi_eligible=false`; resolve without reason → 422; officer resolving hold → 403 |
| B09 | Lots, intake, batches, gates | B05, B06, B08 | 5 | lot lifecycle, `ready` gate on moisture, `POST /intakes` (sync gate checks), `POST /batches` + `shares.py` (half-even 3 dp, residual to largest), GI eligibility, grading/approve gate, final-packing ≤ graded, publish gate → enqueue build | ready at 11.5 → 409, at 10.9 → ready; intake 100 vs packed 69 → `quantity_mismatch`; lots {100,200,20} → 31.250/62.500/6.250; ineligible lot + GI requested → `gi_verified=false` with reasons; approve on `declared_above_computed` → 409; pack 25 on 20 graded → 409; publish before approval → 409 listing reasons; after gates → 202 + `page_builds` row |
| B10 | Publishing | B09, W01 | 6 | `builder.py` snapshot (header, GI indicator, FSSAI/GI-user nos FR62, lots with consent-aware names, share %, map link 3 dp, events date-ordered + counts FR63, grade + edition + readings + lab badge, location method FR72, generation stamp), calls `agritrace_page.render`, writes `public-pages/batches/{code}/{index.html,data.json,qr.png}`, labels PDF, rebuild endpoint | after publish objects exist and `generation` matches; HTML has no phone/survey/`temp_uploads`; revoked name consent → "Farmer 2"; correction → new build_no, old S3 versions kept; QR decodes to `{PUBLIC_BASE_URL}/b/<code>`; events ascending |
| B11 | Reporting + stubs | B09 | 6 | dashboard (completeness %, flags, batches), `POST /public/scans` rate-limited, audit CSV export, `storage_monitoring` + `partner_api` routers → 501 `not_implemented_pilot` | completeness = lots with all mandatory events ÷ lots; 100 scans/min → 429; CSV row per version with `entered_by`, `assist_session_id`; partner → 501 |
| B13 | Config-driven fields/features + masters + bulk import (from the gap analysis) | B01, B03 | 3 | `config/fields/*.yaml`, `features.yaml`, `tenants/` with a JSON-schema for the YAML; dynamic validators; `GET /config/fields`, `GET /config/features`; `processors`, `villages` (LGD code, taluk, block, pincode), `id_documents` (encrypted bucket, flag-gated), `producer_groups` (flag-gated) tables in migration `0002_masters`; `POST /imports/{farmers,villages,inputs}` CSV with row-level validation report; `gi_boundary/build_virudhunagar.py` producing region v0/v1 | disabling `farmers.soil_type` in a tenant file makes the field optional and hidden in `/config/fields` for that FPO only; enabling `id_document_capture` exposes the upload endpoint, disabled → 404; CSV with 2 bad rows → 200 with `accepted: n-2, rejected: [{row, code}]` and no partial writes; `build_virudhunagar.py` writes a MultiPolygon covering `(9.559806, 78.133521)` with `source_ref` and `licence` set; YAML failing its schema → app refuses to start with a clear message |
| B12 | Demo seed, e2e, client generation | B10, B11, B13 | 7 | `seed/demo.py` (FPO VIRUDHAI_SCFC_VINOBA_BHAVA_FPO, crop GI 883, fixture polygon labelled non-official, 5 inputs, 3 farmers mirroring PRD §12 lots with the known problems, batch `FGP8T4033HM7`), `tests/e2e/test_reference_batch.py`, `make clients` (openapi-generator dart-dio, openapi-typescript) | seed idempotent; e2e asserts exact flag set: `quantity_mismatch`×3, `practice_tag_contradiction`×3, `ipm_without_pest_event`×3, `yield_check_unavailable`×3, no `event_out_of_order`, `grading_loss_high`×1, no `batch_quantity_unattributed` (rulings 2026-10-31, D-030); grade "A" → 422 `unknown_grade_for_profile`; approve → 409; publish → 409; after fixes publish succeeds with GI verified, shares 31.25/62.5/6.25, units everywhere; both clients compile |

### 7.2 Mobile (`apps/mobile`, Flutter + Material 3, Android 8+/iOS 13+)

Architecture: feature-first `lib/{core,features}`; **Riverpod** + **go_router** (D-013); **Drift** tables: Session, Farmers, Plots, Lots, Entries (append-only, UUIDv7, version chain, three clocks, assist/remote flags, status, undoDeadline), Media (sha256, upload status), Outbox (priority entry 0 / media 1, backoff), RefBundles (ETag), SyncState, Tasks, Flags, Instruments. Sync engine: triggers app-open / after-entry (500 ms debounce) / connectivity / WorkManager 15 min (iOS BGAppRefresh best-effort); entries first, photos second; backoff 1/4/16/64 s cap 15 min; Wi-Fi-only photo option; kill-safety reset; clock-skew record. Voice: recorded `.ogg` clips at `assets/audio/{ta,en}/{promptId}.ogg` + `prompts.json`; no TTS. Theme: `FarmerTokens` ThemeExtension (minTarget 56, farmerTarget 64), `textScaler` clamped 1.0–1.5, status glyphs icon+colour+label, no `TextField` in farmer features (lint script).

| WP | Title | Depends | Wave | Acceptance |
|---|---|---|---|---|
| M00 | Skeleton: flavors, M3 theme + tokens, go_router role redirect, l10n en/ta, generated Dart client script, dio wrapper, CI (analyze, test, size_check) | B00 spec stub | 1 | arm64 APK < 15 MB at skeleton; `gen_api.sh` zero manual edits; locale switch re-renders sample screen in Tamil; `FarmerButton` golden at 56/64 dp |
| M01 | Drift store + DAOs + migrations + schema test | M00 | 2 | 500 entries + 500 media insert < 2 s on Go AVD; `pendingCount` stream emits on insert/confirm; version-chain query returns latest |
| M04 | Capture kit: camera (no gallery), compress to long edge 1600 px at JPEG q≈80 stepping down until ≤ 350 KB, EXIF rewritten to keep only capture time, GPS and orientation, blur/brightness check, GPS ring (≤20 m green, 60 s "Save anyway"), three clocks, voice note ≤30 s | M00 | 2 | 12 MP → ≤ 350 KB, long edge 1600; EXIF has DateTimeOriginal + GPS and no MakerNote/thumbnail; blurry rejected; ring turns green at 15 m; "Save anyway" at 60 s → `low_accuracy`; capture PSS < 250 MB |
| M05 | Farmer widget kit: FarmerButton, PictureCardGrid, BigStepper, NumberPad, StatusBadge, VoicePromptBar, CallFieldOfficerButton, ConfirmScaffold, CloudSyncIndicator, AssistBar, GpsRing | M00 | 2 | goldens en+ta × scale 1.0/1.5 × 360×640/412×915; every control ≥ 56 dp; Semantics on icon controls; no free TextField lint passes |
| M06 | Auth & session: OTP auto-read, device binding, PIN for officer/QC, role routing, restore on new phone | M00, M01, B02 | 2 | OTP autofills on emulator; 5 wrong PINs → 5 min lock; new device pulls history; farmer never reaches officer routes |
| M02 | Sync engine (outbox, triggers incl. reachability probe, timeouts 10 s/30 s, retry only on network/5xx/429 with 2-4-8 s jittered backoff capped 5 min, batches ≤ 50 entries or 256 KB, single-PUT photo upload with whole retry and 1–3 parallel uploads by measured speed, pull, delta bundles, Wi-Fi-only, kill-safety, skew, local `SyncMetrics` shipped with each push, delete full-size photo on confirm) | M01, B06, B07 | 3 | airplane: harvest saved with cloud icon; network back: reaches API ≤ 30 s, icon clears; normal-4G profile: "Sent" ≤ 5 s; weak-4G: ≤ 20 s; kill mid-upload → re-upload completes, 1 server row; duplicate push → 1 row; Wi-Fi-only: entry sent, photo pending until Wi-Fi; 500×3 → 2/4/8 s (±jitter) backoff in logs; 400 → `needs_attention`, no retry; after confirm the full-size file is gone and the thumbnail remains |
| M03 | Ref data + local preview rules (GI point-in-polygon + buffer, yield 20/30, event order, moisture gate, practice tags, grade preview) sharing the server's JSON | M01, B07 | 3 | offline: inside → tick; 10 m outside w/ 50 m buffer → tick; 500 m → orange; 1,150/1,250/1,350 → none/warn/hold; harvest-before-sowing prompts, nursery-before-landprep does not; 11.5 % → "continue drying"; all-organic → Organic; chilli 10.5 → Standard. **Contract test**: same JSON fixtures produce identical outcomes in Dart and Python (D-006) |
| M07 | Farmer home + 8 events (F03–F09, F16, F17), out-of-order prompt, lot readiness | M01, M03, M04, M05 | 4 | each event ≤ 3 taps (+1 optional) with photo/GPS/clocks; 6 bags × 50 → 300 kg; packing at 12 % not `ready`; "Did you already sow?" once; scripted log < 20 s |
| M08 | Sell QR, Money, History + Undo, Settings | M07 | 5 | QR `{lotId, farmerId, packedKg, sig}` scans in M11; undo at 24 h −1 min works, +1 min absent; language toggle flips strings + next voice prompt |
| M09 | Officer onboarding wizard (9 steps, consent audio, GPS ring, acre/cent stepper, boundary walk, GI preview, no-smartphone exit, handoff QR) | M03, M04, M05, M06 | 5 | full wizard offline → farmer + plot + consent + pin (+ boundary) in outbox; 100 m square → 2.47 acres ± 2 %; declared 1 vs walked 2.4 → mismatch note; stop after step 8 → `hasSmartphone=false` |
| M10 | Officer home, assist mode, flags, moisture reading | M07, M09, B08 | 5 | assist bar on every screen; `assistMode=true`; 3 km away → `enteredRemotely`; "Fix it" → correction version + reason; past-due meter blocked |
| M11 | QC mode: scan, intake checks, grading form from profile, grade preview, final packing, BLE stub | M03, M05, M06, B05, B09 | 5 | scan → lot; 230 vs 200 → orange; 11.5 → orange; 4 readings → grade + standard edition; missing → grey |
| M12 | Notifications + deep links (FCM/APNs, local reminders from calendar bundle) | M07, B04 | 6 | reminder tap → F04 harvest preselected; offline reminder scheduled; payload has no phone/ID |
| M13 | Hardening & release: low-storage purge, background sync proof, in-app update, size budget, Go perf, crash-free | all M | 7 | arm64 APK < 100 MB (target ≤ 40); cold start < 3 s on Go AVD; WorkManager 15-min job fires; storage < 100 MB → prompt + purge confirmed photos |

Form rendering in M07, M09 and M11 reads `/config/fields` from the sync bundle (D-017): a field disabled for the tenant is not shown, a field marked required blocks the confirm tick, and labels come from the YAML's en/ta keys. Acceptance added to M09: disabling `plots.soil_type` for the demo tenant removes that step; "Add another plot" from My farm registers a second plot through the same wizard.

### 7.3 Portal (`apps/portal`, React 18 + TS strict + Vite, TanStack Query, MUI, react-hook-form + zod, generated `openapi-typescript` client, MSW, Vitest + RTL, Playwright)

| WP | Title | Depends | Wave | Acceptance |
|---|---|---|---|---|
| P00 | Skeleton, auth guard, generated client, MSW from spec, lint/test/e2e config | B00 spec | 1 | build < 60 s; initial bundle < 400 KB gz; login passes with MSW; client regen → zero diff |
| P01 | Members: approvals, roster, farmer/plot detail with MapLibre/OSM + GI outline | P00, B03 | 3 | approve → active without reload; phone masked except audited "reveal" |
| P03 | Ready lots → Create batch: tick, running total, share %, greyed lots with reason, non-GI toggle, second sign-off | P00, B09 | 3 | {100,200,20} → 31.25/62.5/6.25; out-of-GI greyed with tooltip; create → id + QR; threshold → second sign-off state |
| P02 | Flags & plot review | P01, B08 | 4 | review held lot → cleared → tickable in P03; required fields block submit |
| P04 | Batch detail, approve grading, publish, preview iframe, grey-button reasons | P03, B09, B10 | 4 | declared Special/computed Standard → Approve disabled with reason; missing reading → disabled; happy path → published + URL |
| P05 | Labels PDF + CSV exports (unit column FR58) | P04, B11 | 5 | `labels-<batchId>.pdf`; CSV unit on every quantity |
| P06 | Dashboard + FPO settings. Dashboard = stage-progress tiles (Land prep, Nursery, Sowing, Inputs, Harvest, Drying, Packing) with done / in-progress / not-started counts, filters crop → district → block → village, per-farmer table with column show/hide; Land Area Analytics (acres by village/block, declared vs walked, GI-confirmed share); Finished Goods (packed batches, remaining quantity, labels printed); Audit Log viewer (search by actor, entity, date). Settings: name opt-out, FSSAI, GI nos, tenant feature flags view (read-only, edited in git) | P00, B11, B13 | 5 | tiles match seed counts per stage; changing village filter updates tiles and table; column toggle persists; audit search for the seeded correction shows actor + reason; opt-out reflected in preview |
| P08 | Master data uploads: CSV import for farmers, villages, inputs with template download, dry-run preview, row-level error report | P00, B13 | 5 | upload with 2 bad rows → preview shows 2 red rows with codes from `error-codes.md`; confirm → only valid rows created; template matches `/config/fields` |
| P07 | Playwright e2e chain + axe | P01–P06, P08, B12 | 7 | login → approve → review flag → create batch → approve → publish → labels, green < 10 min, twice without reseed; 0 serious axe violations |

### 7.4 Public page (`apps/public-page`, package `agritrace_page`)

| WP | Title | Depends | Wave | Acceptance |
|---|---|---|---|---|
| W01 | `render(public_batch) -> (html, json)`, Jinja2 `batch.html.j2`, inline CSS < 12 KB, JS < 4 KB, all sections incl. GI indicator, grade + edition, share %, location method, compliance ids, lazy photos, generation footer; CLI build from fixture | B00 | 1 | fixture renders valid HTML; bilingual crop; units everywhere; date order; no `temp_uploads`/non-`evidence/` paths |
| W02 | `privacy_lint.py` (canary strings + regexes for phone/Aadhaar/survey/polygon/coordinate precision > 3 dp), `html-validate`, Lighthouse CI slow-3G config | W01 | 2 | canary fixture passes; injected phone fails CI; Lighthouse ≥ 90, < 500 KB, LCP ≤ 2 s; 0 HTML errors |
| W03 | Tamil/English labels, print CSS, OG tags (no personal data), unpublished/404 variant, static map thumbnail | W01, W02 | 6 | Lighthouse still ≥ 90; OG passes linter; Tamil renders with system font |

### 7.5 QA & verification (`infra/scripts`, `docs/agents/qa`)

| WP | Title | Wave | Deliverable |
|---|---|---|---|
| Q00 | Harness: compose stack, seed, Go AVD profile (API 27, 2 GB, 2 cores, 720×1280), network scripts (off/edge/lte), evidence folder convention, `checklist-progress.py`, `doc-coverage.py` | 0 | scripts + `docs/agents/qa-rubric.md` |
| Q01 | Flutter verification: widget/golden/integration on Go + API 34 AVDs, offline/online matrix (9 actions × 5 network states), size, cold start, time-to-log, sync latency | 7 | BM-01, 02, 04, 06 reports |
| Q02 | Portal verification: Vitest ≥ 80 % in features, Playwright chain, axe | 7 | report |
| Q03 | Public page verification: W02 suite + backend-down serve from MinIO + old version retrievable | 7 | BM-03, 09 |
| Q04 | Backend verification: full pytest incl. e2e reference batch, locust p95, Schemathesis fuzz on `/sync/push` | 7 | BM-05, 07, 08 |
| Q05 | Release gate: benchmark sweep → `docs/agents/qa/benchmarks.json`, rubric, G5 report | 7 | G5 |

### 7.6 Wave schedule (max 4 workers per wave; reviewers trail by one wave)

| Wave | Workers (parallel) | Gate after |
|---|---|---|
| 0 | B00, Q00 (+ orchestrator: git init, tracking files, CLAUDE.md, codegraph init) | G0 |
| 1 | B01, M00, P00, W01 | G1 (Architect-Gate signs schema, spec, Drift schema) |
| 2 | B02, B03, B05, B04 · then M01, M04, M05, M06 · W02 | — |
| 3 | B06, B13, M02, M03 · P01, P03 | — |
| 4 | B07, B08, M07, P02 · P04 | G2 (backend core) |
| 5 | B09, M08, M09, M10 · M11, P05, P06 | G3 (mobile core) |
| 6 | B10, B11, M12, W03 | G4 (portal + publish) |
| 7 | B12, M13, P07, Q01–Q05 | G5 (pilot candidate) |

Additional ADRs seeded from the sub-plans (appended to §5 table): D-011 single presigned PUT, no resumable upload in pilot (ADV simple, no byte proxying; COMPROMISE whole-retry, arch doc promise deferred to TODO); D-012 schema-first single `0001_initial` migration before module agents (ADV no Alembic head conflicts; COMPROMISE follow-up migrations reviewed centrally); D-013 Riverpod + go_router (ADV least boilerplate, Drift streams map to providers; COMPROMISE codegen, provider discipline); D-014 one `Entries`/`event_versions` table with typed JSON payload, both on phone and server (ADV one sync/undo/audit path; COMPROMISE weaker column typing, JSONB indexes); D-015 Standards Profile as versioned JSON + generic "worst per-parameter grade" engine with source caps (ADV compliance edits without deploys, same JSON on phone; COMPROMISE non-tabular standards need engine extensions, `load_from_standard` markers); D-016 Tamil+English voice/icons bundled in APK, everything else as downloadable bundles (ADV offline first run, < 30 MB; COMPROMISE first sync must pull bundles).

---

## 8. Benchmarks (owned by QA Lead; scripts in `infra/scripts/benchmarks/`)

| ID | PRD metric | Script | Threshold |
|---|---|---|---|
| BM-01 | Median time to log an event < 60 s | Flutter integration test drives 3-tap harvest flow 10× | p50 ≤ 60 s, p95 ≤ 90 s on Android Go emulator (2 GB, 4-core throttled) |
| BM-02 | Entry reaches server within seconds on 4G | integration test with network throttle 4G profile | entry ≤ 5 s, 300 KB photo ≤ 10 s |
| BM-03 | Public page < 2 s on 3G | Lighthouse CI, "Slow 3G" preset | performance ≥ 90, LCP ≤ 2 s, transfer ≤ 500 KB first view |
| BM-04 | App size | `flutter build apk --release --analyze-size` | arm64 APK ≤ 100 MB (user budget; target ≤ 40 MB so bundled Tamil audio and images fit); iOS IPA reported |
| BM-05 | Traceability completeness | seed batch → completeness % computed | 100 % on demo batch; reference batch (PRD §12.2) flags all 9 listed problems |
| BM-06 | Sync idempotency | replay same outbox 3× | row count unchanged; photo checksum unchanged |
| BM-07 | API latency | `locust` 50 users on sync + batch endpoints | p95 ≤ 300 ms on docker stack |
| BM-08 | Grade engine correctness | table-driven tests from Standards Profile | 100 % of PRD seed rows (chilli, turmeric, saffron, coffee) |
| BM-09 | Privacy lint | `privacy-lint.py` over built public pages + partner stub output | 0 hits for phone, ID, survey no., polygon |
| BM-10 | Doc coverage | interrogate / dart doc / eslint-jsdoc | 100 % public symbols |

---

## 9.1 Robot Framework suites (written by the QA Lead, run by Verifiers and CI)

Location `qa/robot/`, Python 3.12, `robotframework` + `robotframework-requests` (API), `robotframework-browser` (Playwright-based, portal and public page), `robotframework-databaselibrary` (PostGIS assertions), `robotframework-process` (drives `flutter test integration_test` and `adb` for the mobile suite and parses its JSON result). Keyword libraries in `qa/robot/lib/*.py` wrap the generated TS/Python clients so suites read like the acceptance tables in §7. Suites:

| Suite | Covers | Gate |
|---|---|---|
| `api/identity.robot`, `api/registry.robot`, `api/sync.robot`, `api/rules.robot`, `api/batches.robot`, `api/quality.robot`, `api/publishing.robot` | Every acceptance line in §7.1 as one test case each, tagged `WP-Bxx` | G2 |
| `mobile/offline_matrix.robot` | the 9 × 5 offline/online matrix, each cell shelling to a Flutter integration test with the network script | G3 |
| `portal/*.robot` | P01–P06 acceptance, the P07 chain | G4 |
| `public/page.robot` | render, privacy lint, backend-down serve, Lighthouse JSON thresholds | G4 |
| `e2e/reference_batch.robot` | seeded `FGP8T4033HM7` scenario end to end | G5 |

Rules: every test tagged with its WP and the PRD requirement (`FR-29`), `robot --output` reports archived under `qa/robot/results/<gate>/`, flaky tests tagged `flaky` and counted as P2.

## 9. Verification agent protocol (`docs/agents/qa-rubric.md`)

A Verifier receives: WP id, branch, acceptance test list, benchmark IDs. It must:
1. `docker compose -f infra/docker-compose.yml up -d --wait`, run migrations and seed.
2. Run each acceptance test command exactly as listed; copy stdout/stderr to `docs/agents/qa/<WP>/logs/`.
3. For UI WPs, capture screenshots (Flutter integration test `takeScreenshot`, Playwright `page.screenshot`) to `docs/agents/qa/<WP>/shots/`.
4. Run the WP's benchmark IDs; record numbers in a table.
5. Fill the rubric: Functional (all acceptance tests pass), Docs (coverage script passes, DECISION comments present for each ADR the WP claims), Ponytail (review file PASS), Benchmarks (thresholds met), Privacy (lint zero). Any FAIL → whole WP FAIL with the failing command quoted.
6. Write `docs/agents/qa/<WP>.md`; never edit code.

---

## 10. Execution order (what happens after plan approval)

Follows the wave table in §7.6. Concretely:

1. **Orchestrator, before any worker**: `git init` + first commit of the four source docs moved to `docs/source/`; write `CLAUDE.md` (hierarchy, Documentation Standard §4, Ponytail `AGENTS.md` text, "codegraph before grep"), `DECISIONS.md` with D-001…D-016 and `docs/adr/` files, `CHANGELOG.md`, `CHECKLIST.md` (every WP and gate from §7 as checkboxes, `Completion: 0 %`), `TODO.md` (deferred scope, the architecture doc's 7 open questions, items from §12), `docs/agents/{roles,checkpoint-protocol,qa-rubric}.md`.
2. **Wave 0**: spawn B00 and Q00; on merge run `codegraph init .` and ask the user to run the Ponytail plugin install (see §12). → **G0**.
3. **Waves 1–7** as scheduled; each wave: spawn ≤ 4 Opus workers in worktrees → Opus Reviewer per WP (`/ponytail-review branch`, acceptance tests, Documentation Standard) → Verifier → merge → `codegraph sync`, `checklist-progress.py`, CHANGELOG line, TODO updates. Gates G1–G5 signed where marked.
4. **G5 extras**: SEC review (OWASP ASVS L1 checklist over identity, sync, presigned URLs, tenant scoping), DOCS review (coverage script, README 5-minute start works from a clean clone), `/ponytail-audit`, `/ponytail-debt` → `TODO.md`.

## 11. Verification of the plan itself (end-to-end)

- `docker compose up` → `curl localhost:8000/docs` shows Swagger with every schema field described.
- `pytest` green; `flutter test` + integration test on emulator green; `pnpm test` + Playwright green.
- Seed script creates the demo FPO and the reference batch; `GET /batches/<id>/flags` lists the PRD §12.2 problems by name.
- Publish the demo batch → static page in MinIO → Lighthouse ≥ 90 → privacy lint 0.
- `CHECKLIST.md` header reads `Completion: 100 %`; `/ponytail-audit` has no P1.

## 13. 4G optimisation brief: mapping and adoption

The user supplied a "Retrofit: optimise AgriTrace for 4G" brief. There is no code yet, so the brief's step 1 (audit the repo) becomes this mapping; its items are adopted as requirements of the WPs named, and where its numbers are tighter than the plan's earlier numbers, **the brief's numbers win**. Stack equivalents, as the brief asks: NestJS → FastAPI (D-001); S3 → MinIO locally, S3 in production; CloudFront → none locally (MinIO serves the bucket), CloudFront in production; Flutter unchanged. Backward compatibility: every public route is under `/v1`, changes are additive only, and `packages/openapi/` keeps the last season's spec so the contract test fails on a breaking change (D-020).

| Item | Plan status before | Adoption (WP) |
|---|---|---|
| A1 sync right after save, with **real reachability** (not just connectivity type), 15-min and app-open fallbacks | partly (debounced after-entry + `connectivity_plus`) | M02: reachability = `HEAD /v1/healthz` with 3 s timeout before a run; connectivity change only triggers the probe |
| A2 outbox waiting → sent → confirmed, tick only on server ack, grey cloud while anything waits | done | M02, M05 |
| A3 client UUID idempotency, server returns original result | done | B06 (`duplicate` returns `server_id`) |
| A4 entries first, batched **≤ 50 entries or 256 KB** | partly (50 entries, ~100 KB) | B06 request limit 256 KB; M02 batch builder stops at either limit |
| A5 **1–3 parallel photo uploads by measured upload speed** | missing | M02: measure throughput of the last upload; ≥ 1 Mbps up → 3 parallel, else 1; metric recorded (F1) |
| A6 timeouts connect 10 s / request 30 s; retry only on network errors, 5xx, 429; backoff **2, 4, 8 … capped 5 min with jitter** | partly (1/4/16/64 s cap 15 min) | M02 adopts the brief's policy; dio interceptor; 4xx other than 429 go to `needs_attention` |
| B1 compress to **long edge 1600 px, JPEG q≈80, step down until ≤ 350 KB** | partly (1280 px, q70) | M04 adopts the brief's ladder |
| B2 **keep EXIF time + GPS, strip the rest** (thumbnails, maker notes) | missing | M04 rewrites EXIF with only DateTimeOriginal, GPS block, orientation; test asserts no MakerNote/thumbnail bytes remain |
| B3 presigned PUT + SHA-256, whole-PUT retry | done | B06, M02 (D-011) |
| B4 **delete local full-size after confirm, keep thumbnail** | partly (7-day purge) | M02: delete on `confirmed`; ~10 KB thumbnail kept for History |
| B5 "Send photos on Wi-Fi only", **default OFF** | done | M08 setting default false |
| B6 **server WebP variants: thumbnail ~60 KB, medium ~150 KB** | missing | B06: `events.make_variants` task after verify (Pillow WebP) → `evidence_photos.variants` jsonb; used by B10 page and portal |
| C1 **gzip/brotli responses, HTTP/2 keep-alive** | missing | B00: `brotli-asgi` middleware (gzip fallback); HTTP/2 terminates at ALB/CloudFront in prod, documented in `infra/README` |
| C2 reference bundles **with delta sync `?since=<version>`** + ETag/304 | partly (ETag only) | B07: `GET /v1/sync/reference?since=<part>:<version>,…` returns only parts whose version differs per part; 304 when none |
| C3 product pictures **WebP ≤ 50 KB**, voice prompts low-bitrate Opus **per language only**, simplified GI outlines, server authoritative | mostly done | B13 import rejects product pictures > 50 KB after conversion; M00 ships only ta+en audio, other packs on demand; B07 `ST_SimplifyPreserveTopology` |
| C4 lean lists: pagination, no deep nesting, per-screen fields | partly | API conventions in `docs/api/conventions.md`: cursor pagination everywhere, `?fields=` on list endpoints, enforced by reviewer checklist |
| D1 **download under 30 MB** via AAB per-ABI splits, resource shrinking, on-demand voice packs | **conflict** with user's 100 MB budget | Resolution: 30 MB is the **download target** (AAB device-specific size, measured by `bundletool get-size total`); 100 MB is the **hard ceiling** on the universal APK (BM-04). M13 enforces both |
| D2 cold start < 3 s on 2 GB phone, lazy-load non-home screens | done | M13 + deferred imports for officer/QC features |
| D3 cache map tiles for the FPO area, satellite only when a reviewer opens it | missing | P01/P02: MapLibre with tile cache for the FPO bounding box; satellite layer toggle off by default; farmer app has no map |
| E1 initial HTML + CSS + JS **< 100 KB** | done (CSS < 12 KB, JS < 4 KB) | W01 budget stated as < 100 KB total |
| E2 WebP thumbnails lazy, tap to enlarge to medium | partly | W01 uses B6 variants; `<picture>` with WebP + JPEG fallback |
| E3 long cache headers on assets, invalidate batch page on publish | missing | B10 sets `Cache-Control: public, max-age=31536000, immutable` on hashed assets and `max-age=60` on `index.html`; production publish calls CloudFront `CreateInvalidation` for `/b/<code>*` (no-op locally) |
| E4 LCP < 2.5 s on a 4G mobile profile | done (≤ 2 s on 3G) | BM-03 adds the 4G profile row |
| F1 per-entry telemetry: save→ack time, photo upload time, failures, network type + dashboard | missing | M02 writes `SyncMetrics` rows locally and ships them in the push envelope (`metrics[]`); B06 stores `sync_metrics` table; P06 dashboard tile "Sync health" (p50/p95 save→ack, photo time, failure rate by network type) |
| G1–G6 acceptance under simulated profiles | partly | BM-11 to BM-16 below; Robot `mobile/network_profiles.robot` drives the emulator console (`network speed <up>:<down>`, `network delay`) |

New benchmarks appended to §8:

| ID | Test | Threshold |
|---|---|---|
| BM-11 | Normal 4G (10 Mbps down / 5 Mbps up / 60 ms RTT): entry + 1 photo | "Sent" within 5 s |
| BM-12 | Weak 4G (1 Mbps / 0.5 Mbps / 300 ms RTT): entry + 1 photo | "Sent" within 20 s |
| BM-13 | Airplane mode: save, then restore network | saved instantly with grey cloud; sent automatically, no user action |
| BM-14 | Kill app mid-upload, relaunch | upload completes; exactly one entry and one photo on server |
| BM-15 | Replay the same push 5× | exactly one record |
| BM-16 | Public page on the normal 4G profile | initial HTML+CSS+JS < 100 KB; LCP < 2.5 s |

The brief notes its network profile speeds and the 50-entry / 256 KB batch limit are defaults, not field readings. They are stored as constants in `qa/robot/profiles.yaml` and `config/features.yaml` so they can be replaced with field measurements without code changes.

Added decision: **D-020 API versioning and one-season compatibility.** All routes under `/v1`; only additive changes; previous season's `openapi.json` kept and diffed in CI (`oasdiff` breaking-change check). ADV: old app versions keep working, as the User Flows doc promises. COMPROMISE: deprecated fields linger for a season; removals need a dated TODO entry.

## 12. Things the user must do by hand (cannot be automated from here)

- Start Docker Desktop.
- Run `/plugin install ponytail@ponytail` in this project (interactive plugin install).
- Provide SMS/OTP provider credentials later (pilot uses a console/dev OTP sender; recorded in TODO).
- Record Tamil voice prompts (pilot ships placeholder clips; TODO).
- Confirm the taluk list for GI 883 from GI Journal No. 200 (Intellectual Property India public search) so `build_virudhunagar.py` dissolves the right taluks; until then v1 uses Sattur, Aruppukottai and Tiruchuli from the user's note plus the rest of the district as v0 (D-019).
- Decide on the Datameet / Census 2011 sub-district file as the pilot source (open licence) versus buying or commissioning a surveyed boundary later.
