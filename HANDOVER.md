# Handover — AgriTrace build, end of day 2026-10-30 (00:30 IST)

Written for: whoever resumes the multi-agent build tomorrow (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §5.

## 1. Where things stand

| Area | State |
|---|---|
| Plan | `PLAN.md` at the root (approved 2026-10-29); design specs in `docs/agents/specs/` |
| Progress | `CHECKLIST.md` completion line (17 % at close; see table below for conditional merges that will tick once the stack runs) |
| Decisions | `DECISIONS.md` D-001 … D-025 with ADRs in `docs/adr/` |
| Follow-ups | `TODO.md` (about 100 open items, grouped; §5 is the human to-do list) |
| Agent protocol | `docs/agents/{roles,checkpoint-protocol,qa-rubric}.md`; every review in `docs/agents/reviews/`, every verification in `docs/agents/qa/`, every worker report in `docs/agents/reports/` |
| Gate G0 | Open, `docs/agents/gates/G0.md`, blocked on the Docker stack run |

### Merged to `main`

| WP | Review | Verification | Note |
|---|---|---|---|
| W01 public page renderer | PASS r2 | PASS | fully verified |
| P00 portal skeleton | PASS | PASS | fully verified, screenshots in docs/agents/qa/P00 |
| M00 Flutter skeleton | PASS (+r2 fixes) | PASS | fully verified |
| B00 backend scaffold + infra | PASS-PENDING-STACK | **deferred** | compose stack never ran on this machine |
| Q00 QA harness | r4 closure | CONDITIONAL | Robot smoke on live stack deferred |
| B01 domain schema (39 tables, migration 0001) | Architect-Gate APPROVED-PENDING-STACK | **deferred** | `alembic check` + 8 integration tests not run |
| B05 quality + grade engine | PASS-PENDING-STACK (+r2) | **deferred** | 166 unit tests pass; 7 integration tests not run |
| B03 registry + PostGIS geo | PASS-PENDING-STACK (+r2) | **deferred** | 107 unit tests pass; 6 PostGIS integration tests not run |

`main` at close: backend 192 unit tests green, import-linter 2 kept / 0 broken, interrogate 100 %, 28 registered error codes, OpenAPI spec and portal client regenerated.

### Done but not merged (branches in `.claude/worktrees/`)

| WP | Branch / commit | State at close | Next step |
|---|---|---|---|
| B02 identity + auth | `worktree-agent-a00c8dc116a1aec8e` @ 8a28ba9 | **round 2 done** (R1–R8 fixed: pin_hash redaction, cookie-only refresh, signed_in_at, previous-hash reuse detection, device_in_use, OTP daily cap, current-PIN check, super-admin PIN; 166 unit tests) | spawn SEC re-review of the r1→r2 diff (`git diff eba796c..8a28ba9`) → merge (migration `0002_identity_pin` extended: 3 users + 2 devices columns; `alembic heads` single) → regenerate spec/error table/portal client → P01 adapts the portal to the final contract in `docs/api/conventions.md` → mobile needs a sign-out action (shared phones) |
| W02 public-page gates | `worktree-agent-a38124ac8d38806f2` @ 7b9c6e8 | review r1 in progress | if PASS → verify (no Docker needed) → merge; fix the `D-007`→`D-025` citation in lighthouserc at merge |
| M01 Drift offline store | `worktree-agent-abd04c405cb9f3ca4` @ cba87cf | review r1 in progress | if PASS → verify → merge |
| M05 farmer widget kit | `worktree-agent-afab3dd3b4350ce54` @ 8d5bd91 | **unreviewed** (finished 00:14) | spawn MOB reviewer (use `/ponytail-review`) → verify → merge; conflicts expected with M01 in `docs/LIBRARIES.md`, `CHANGELOG.md`, `pubspec.yaml`, `ios/` files |

## 2. Blockers only a human can clear (do these first tomorrow)

1. **Docker Desktop is broken.** Its container store was corrupted when the disk filled. Fix: Docker Desktop → Troubleshoot → *Clean / Purge data* (deletes all local images and volumes), then start it. After that, run the deferred verifications in this order (each is one Verifier agent): B00 (`make up`, `GET/HEAD /v1/healthz`, `make test`), B01 (`alembic check`, 8 integration tests), B05, B03, then sign G0.
2. **Two stale `uv` processes hold the uv cache lock** (they are graphify MCP servers from `~/.claude` config with a misspelled package `graphifyy`; PIDs 53285 and 66002 at close). `kill 53285 66002 && uv cache clean` frees about 4.9 GB and stops every worker tripping on the lock. Fix the spelling in the MCP config so they do not come back.
3. **Disk.** Free space oscillated between 1.4 and 6 GB all evening. Candidates measured (regenerable): `~/Library/Caches` 28 GB, `~/.gradle` 4.6 GB, `~/.cache/uv` 4.9 GB (after the kill above), `~/Downloads` 11 GB. Flutter release builds need several GB of headroom.
4. Optional but useful: confirm the GI 883 taluk list from GI Journal No. 200 (`infra/scripts/gi_boundary/taluks.json` has `confirmed: false`); decide on the 3-decimal public map rounding (TODO §2).

## 3. Resume procedure (Orchestrator)

1. `git status` clean on `main`; `git worktree list` shows the four branches above.
2. Finish the in-flight reviews: read `docs/agents/reviews/B02-r2.md` / `W02-r1.md` / `M01-r1.md` if they exist (agents may have written them after this handover); otherwise spawn the reviewer per `docs/agents/checkpoint-protocol.md`.
3. Merge order: W02 → M01 → M05 → B02. For each: `git merge --no-ff <branch>`; append-only conflicts in `CHANGELOG.md`, `TODO.md`, `docs/LIBRARIES.md` are resolved by keeping both sides; after any backend merge run `cd apps/api && uv run python -m agritrace.export_openapi && JWT_SECRET=x uv run python ../../infra/scripts/gen-error-codes.py && cd ../portal && npm run gen:api`, then `cd apps/api && uv run pytest tests/unit -q && uv run lint-imports`; then `codegraph sync .`, tick `CHECKLIST.md`, `python3 infra/scripts/checklist-progress.py`, commit.
4. Then start Wave 3 per `PLAN.md` §7.6: **B04 notifications**, **B06 events + sync push** (needs B02 + B03 merged), **B13 config-driven fields + masters**, **M04 capture kit**, **M06 auth** (needs B02 contract in `docs/api/conventions.md`), **M02 sync engine** (needs B06). Worker prompt pattern: role card + acceptance file + spec sections + "DOCUMENTATION RULES ARE NOT OPTIONAL" + Ponytail; keep ≤ 4 workers while disk is tight.
5. Reviewers now invoke the `ponytail:ponytail-review` skill (plugin loaded 2026-10-30); at the end of each wave run `ponytail:ponytail-audit` and file `docs/agents/audits/wave-<n>.md`.

## 4. Decisions taken today that future work must respect

- D-008 LocalStack **4.14.0 pinned** (community MinIO is gone; `latest` LocalStack needs a licence token); D-021 Valkey instead of Redis; D-019 GI boundary from **geoBoundaries (ODbL)** with attribution; D-022 portal and API on one origin (httpOnly refresh cookie for web); D-023 enums as VARCHAR+CHECK; D-024 phone+OTP+PIN session model (pin_hash must be redacted from audit diffs — B02 r2); D-025 BM-03 3G = Lighthouse built-in preset.
- Rulings recorded in TODO/acceptance files: Lab-certified badge = any lab reading with a non-blank NABL number on the batch; visual moisture rejected at entry; 100 MB APK ceiling / 40 MB target / 30 MB AAB download; first-OTP-sets-PIN accepted for pilot; single privacy linter (`infra/scripts/privacy-lint.py`).
- Process deviations (logged in G0.md): Q00 had 4 worker rounds, B00 4, B02 will have 2; several packages merged on PASS-PENDING-STACK because Docker was down.

## 5. Known risks going into tomorrow

- Every backend package since B01 has integration tests that have **never executed**; expect a batch of PostGIS/asyncpg typing fixes on the first live `make test`.
- `audit_log` is append-only: the B02 P1 (PIN hash in audit diffs) must land before any real office PIN is set.
- Goldens are macOS-recorded and skipped on Linux until Q01 re-records them.
- The portal `gen:check` CI step fails whenever a backend merge changes the spec without regenerating the client (procedure in §3 step 3 covers it).
- iOS cannot play `.ogg` voice clips (M05): CAF/AAC copies needed before an iOS pilot.
