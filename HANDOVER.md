# Handover — AgriTrace build, end of day 2026-10-31 (18:50 IST; user stopped the day with three workers mid-flight)

Written for: whoever resumes the multi-agent build (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §5 and the "Architect-Gate queue" / decision-ledger lines.

## 1. Where things stand

| Area | State |
|---|---|
| Plan | `PLAN.md` (approved 2026-10-29); binding specs in `docs/agents/specs/`; rulings in `docs/agents/gates/rulings-2026-10-31.md` and `rulings-2026-10-31b.md` |
| Progress | `CHECKLIST.md`: **36 % (23/64)** ticked; **25 more packages are merged on main but wait only for the Docker stack** (their reviewer verdicts are PASS-PENDING-STACK); 3 packages in flight; Q01–Q05 not started |
| Decisions | `DECISIONS.md` D-001 … D-053 (D-049 unused; D-018 amended twice: MPL-2.0 build/transitive, GPL-2.0 with Classpath Exception for `desugar_jdk_libs`) |
| Follow-ups | `TODO.md` (~300 lines, grouped; the decision-number ledger line pre-assigns numbers to in-flight branches) |
| Agent protocol | `docs/agents/{roles,checkpoint-protocol,qa-rubric}.md`; every review in `docs/agents/reviews/<WP>-r<n>.md`, every worker report in `docs/agents/reports/<WP>.md` |
| Gates | G0–G4 all unsigned: every gate needs the stack run first (see §2) |
| Main | `git log` ~286 commits; backend 617 unit tests / 768 collected; mobile 793 tests; portal 120 Vitest; public page 76 pytest; 49 error codes; migrations 0001–0004 single head; OpenAPI, TS and Dart clients regenerated after the last backend merge |

### Merged to `main` today (2026-10-31), in order
B07, B08, B09, B10, B11, B15, B16 (backend); M02, M07, M08, M09, M10 (+ follow-up), M11, M12 (mobile); P02, P03, P04, P06, P08 (portal); W03 (public page); B12 (seed, e2e, `make clients`). Plus the three Architect-Gate rulings batches (D-030–D-032, D-040–D-043) and D-033–D-053 from workers.

### In flight at hand-over (worktrees under `.claude/worktrees/`; each worker was told at 18:45 to commit a WIP and stop)

| WP | Branch / state at 18:48 | Tomorrow |
|---|---|---|
| P05 labels PDF + CSV exports | `worktree-agent-a0f7bf849398faf5a` @ `33c3de0` (WIP `8dffe31`: main merged, `readColumns` reused, P2-1 and P3-2..P3-7 done; lint, typecheck and the 11 exports tests pass; NOT yet run: full suite, build+size, gen:check — the round-2 report section waits for them). Review `docs/agents/reviews/P05-r1.md`: PASS, 1 P2 (derived `packed_share` column must be labelled derived + recorded `harvested`/`farm_packed` columns; D-051 wording) + P3s (disable lots CSV until names load, BOM on the audit CSV, spaced phone pattern in the privacy test, Tamil whole-file test, FR9 header, long comments) | `git log`/`git status` in the worktree; if the WIP commit exists, resume the worker with "finish the P05 micro-patch" (agent id in `docs/agents/reports/P05.md` is not stored: spawn a fresh worker if the session is new); on completion Orchestrator confirms the P2 and merges (`AppRoutes.tsx` conflict with P06 by hand) |
| P07 Playwright chain + axe | `worktree-agent-af029d14158299b86` @ `820a080` (no commit yet; 16 uncommitted files = specs, config, CI step). No report yet | if a WIP commit landed, read `docs/agents/reports/P07.md` "State at close"; resume/respawn the worker to finish: mock-mode chain twice with durations, axe per page, CI step; then WEB review → merge; live chain = Verifier (`make up && make seed && cd apps/portal && E2E_LIVE=1 npm run e2e`) |
| M13 hardening & release | `worktree-agent-a94b72ad04155d510` @ `f2ae24b` (WIP code commit `49416be` + report; NOT ready for review: full suite stopped at 366 passed / 14 failed — photo-capture widget tests, likely the new free-space check in `camera_step` `_shoot`; no APK/AAB size measured yet; see `docs/agents/reports/M13.md` "State at 2026-10-31 close"). Brief: APK/AAB size + shrinking, deferred imports for officer/QC, low-storage purge, WorkManager registration test, min-version sheet, D-029 user-switch clearing of pulled rows, rejected-packing `ready_for_sale` fix, Drift v3 dropping Session token columns, unawaited-future error handlers | same: check for the WIP commit and `docs/agents/reports/M13.md`; resume/respawn to finish; MOB review → merge; then the mobile tree is complete and Q01 can start once an AVD and the stack exist |

If a worktree shows uncommitted files and no WIP commit tomorrow, the agent died before committing: inspect `git diff` there, keep what is coherent as a WIP commit yourself, then respawn with the acceptance file and that diff as the starting point.

## 2. Blockers only a human can clear (do these first)

1. **Docker Desktop reset** (Troubleshoot → Clean / Purge data, then start). Everything below has never executed on a stack: ~190 backend integration tests, the 2 e2e tests, `make seed`, the Robot suites, Lighthouse on a quiet host, the portal live chain. After the reset, run Verifiers in this order (each one Opus agent, rubric in `docs/agents/qa-rubric.md`): B00 → B01 → B05 → B03 → B02 → B06 → B13 → B14 → B04 → B07 → B08 → B09 → B15 → B16 → B10 → B11 → B12 (`make seed` + e2e) → then sign G0, G1, G2. Expect a batch of asyncpg/PostGIS typing fixes on the first live `make test`.
2. **Kill stale processes**: `pkill -f graphifyy` (misspelled MCP package in `~/.claude` config; fix the spelling) and `uv cache clean`; the CodeGraph watchers (`~/.codegraph/.../node`, one per worktree) die when worktrees are pruned. Load averages reached 950 on 12 cores during the afternoon; the Flutter test runs are the cost.
3. **Disk**: 11 GB free. Flutter release builds (M13 size check) need several GB.
4. **Product confirmations still open**: GI 883 taluk list from GI Journal 200; 3-dp public map rounding; the 15 % `grading_loss_warn_pct` default (D-030); farm area and grade readings are now `public` in the field YAML (D-034 ruling) — confirm with the FPO.
5. **Firebase/APNs** (M12): project, config files, APNs key and entitlement are human steps; the API has no device-token endpoint yet (`push_notifications` flag off).

## 3. Resume procedure (Orchestrator)

1. `git status` clean on `main`; `git worktree list` shows the three in-flight branches.
2. For each in-flight WP: if its report exists, spawn/resume the reviewer; on PASS confirm the exact fixes yourself when the reviewer specified them, otherwise a round 2 with the same reviewer (resume by `SendMessage`); merge with `git merge --no-ff`.
3. After any backend merge: `cd apps/api && uv run python -m agritrace.export_openapi && JWT_SECRET=x uv run python ../../infra/scripts/gen-error-codes.py && uv run pytest tests/unit -q && uv run lint-imports`, then `cd ../portal && npm run gen:api`, then `cd ../mobile && JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" tool/gen_api.sh` (slow under load; run in the background). After any mobile merge: `flutter analyze --fatal-infos && flutter test -x golden -x perf`. After any portal merge: `npm ci` once if `axe-core` is missing, then `npm run typecheck && npm test -- --no-file-parallelism`.
4. Conflicts: `CHANGELOG.md`/`TODO.md`/`docs/LIBRARIES.md` keep both sides (LIBRARIES: union the files column of a same-row conflict; `DECISIONS.md`: rows in number order); generated files (`openapi.json`, `error-codes.md`, clients) take main's then regenerate; **code files by hand** then lint/typecheck/tests before committing.
5. Bookkeeping per merge: tick/annotate `CHECKLIST.md`, `python3 infra/scripts/checklist-progress.py`, CHANGELOG status suffix, TODO lines from the review, `codegraph sync .`, `git worktree remove -f -f` + `git branch -d`.
6. Then wave 7: Q01–Q05 Verifiers (need the stack and the Go AVD), the `/ponytail-audit` per wave (`docs/agents/audits/wave-<n>.md`, none written yet — waves 3–6 are owed), gates G0–G5.

## 4. Decisions and rulings today that future work must respect

- D-030 grading-loss split; D-031 `farmer` push kind + `FarmerIn.client_id`; D-032 `assist_session` push kind + per-entry `assist_session_id`; D-040 `lot_intake` push kind (QC receives a lot; processor default; moisture gate at intake); D-041 GI-only holds (`plot_outside_gi_region`, `yield_over_ceiling`) do not block non-GI batches; D-042 assist context per kind; D-043 "Log" counts as navigation, next-task card is the 3 (+1) path.
- D-033 intake corrections (pre-batch versions; post-batch void path owed by B10/B11); D-034 page-required fields are `public` and tenant YAML cannot narrow them; D-035 Sell QR `sig` is a checksum; D-044 assist mode is the `/assist/:farmerId` route scope; D-045 schematic map thumbnail; D-046 local reminders; D-047 in-house CSV reader; D-048 seed by direct inserts + real `create_batch`; D-050 `VITE_PUBLIC_BASE_URL`; D-051 per-lot packed kg derived from shares.
- **G5 conditions added**: B15 + M02 r2 + M09 r2 merged before any field device runs onboarding/assist (done); B16 + M11 r2 merged before any device runs QC intake (done); the Verifier must still push `lot_intake`, `farmer` and `assist_session` to a live server.
- Process: decision numbers are assigned by the Orchestrator in the TODO ledger (four workers picked D-044 the same afternoon); the Orchestrator's own `/ponytail-review` passes on merged M10, W03, M08, B11, B12, P06 produced a merged M10 follow-up and four TODO lines.

## 5. Known risks going into tomorrow

- ~190 integration tests, the e2e, `make seed` and every Robot suite have never run. The first stack run will find typing and fixture issues; budget a day.
- Shared-phone data: on user switch M02 clears the cursor and bundles but the previous user's pulled lots/plots/farmers/tasks/flags stay until M13 lands (in flight); reminders (M12) and Sell/Money read them.
- `ready_for_sale` kept by the pull can outlive a rejected packing (fix in M13's brief).
- Dashboard completeness ignores plot-level events logged before a lot existed (TODO from the B11 review); `make seed` re-run after a refused batch dies on the staff phone index (TODO from the B12 review).
- `batch_quantity_unattributed`/`grading_loss_high` 15 % default, the `nm` and `desugar_jdk_libs` licences, and the `mobile_scanner` ML Kit size are all accepted with notes; M13 measures the APK.
- Goldens are macOS-recorded; the Lighthouse 3G gate fails under heavy host load (W03 has ~300 ms margin).
