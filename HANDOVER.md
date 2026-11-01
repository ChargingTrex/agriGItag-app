# Handover — AgriTrace build, state at 2026-11-02 01:50 IST (day 4: first live-stack day; Verifier wave 7 in progress)

Written for: whoever resumes the multi-agent build (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §6–§7 (audit follow-ups, gate blockers) and the decision-number ledger line.

## 1. Where things stand

| Area | State |
|---|---|
| Plan | `PLAN.md` (approved 2026-10-29); specs in `docs/agents/specs/`; rulings `docs/agents/gates/rulings-2026-10-31*.md` |
| Progress | `CHECKLIST.md`: **84 % (64/76)**. Backend B00–B20 verified live; mobile M00–M16 merged, reviewed, 812 tests green, APK 30.03 MiB; portal P01–P10 and W03 verified live (P06 line 5 re-check pending); Q02 CONDITIONAL (members coverage → P11), Q03 CONDITIONAL (2 Robot placeholders), Q04 FAIL (BM-07 p95 3.1 s, push 5xx on NUL/int32 → B21), Q06 Robot API suites 67/67 merged, Q07 portal Robot suites in flight |
| Gates | **G0 and G1 SIGNED** (2026-11-01/02). **G2** readiness filed BLOCKED (`docs/agents/gates/G2.md`): Robot API suites now green (Q06), P01 live line PASS (P10), B08-2 closed (B20) — remaining: the portal/mobile Robot placeholders the readiness script counts (Q07 in flight; mobile ones are Q01/G3 scope → Architect-Gate ruling). G3–G5 unsigned |
| Audits | `docs/agents/audits/wave-0-2.md` (3 P1, 11 P2, 6 P3) and `waves-3-6.md` (2 P1, 5 P2, 9 P3). **All five P1s are fixed and merged** (M14, M16, P09); P2s fixed: M15, B18, B19; the rest are TODO §6/§7 lines |
| Decisions | D-001…D-054 (D-049 unused; D-055–D-058 reserved, unused: B18/B19/P09/M16 needed no ADR) |
| Main | 391 commits; backend 623 unit / 780 total (full suite green on the live stack); mobile 812 tests, analyzer clean; portal 135 Vitest, bundle 243 KB gz; public page 76 pytest; qa/tests 109; 49 error codes; migrations 0001–0004; OpenAPI, TS and Dart clients regenerated and byte-identical after the last backend merge (B18) |
| Remote | **none.** No `origin`; creating `ChargingTrex/agriGitag` and pushing was denied by the permission classifier. Human step: `gh repo create ChargingTrex/agriGitag --private --source . --remote origin --push` |
| Stack | Docker Desktop up; compose stack running from main **rebuilt 01:41 IST incl. B20** (a stuck BuildKit lease had blocked `make up` four times; `docker builder prune -af` cleared it), seeded; Verifiers added many QA rows (incl. 6,269 fuzz events on farmers +919000000091/92) — reseed (`down -v && make up && make seed`) before any demo. **Admin OTP cap (10/day) is exhausted on this stack until ~21:49 IST 2026-11-02**: staff sign-ins for live checks must use a fresh isolated compose project (recipe in `docs/agents/reports/Q06.md`). DB on host port 5433 via `infra/.env` |

### Merged today (2026-11-01), in order
P05, P07, M13 (yesterday's in-flight branches) → B17 (first live-stack fixes) → M15 → B18 → P09 → M14+M16 → B19. Reviews for every one in `docs/agents/reviews/`; reports in `docs/agents/reports/`.

### Verified live today
B00 (CONDITIONAL → PASS after B17), Q00 deferred lines closed, B01–B05, B06, B13, B14, B07, B08 (B08-r2 filed), B09, B15, B16 (CONDITIONAL → PASS after B19), B10, B11, B12 (e2e with the ruling flag set; both clients compile). The three G5-condition pushes (`lot_intake`, `farmer`+`assist_session`+`consent`+`plot`, timeout-then-sync) succeeded live. BM-05, BM-06, BM-08, BM-09, BM-15 met.

## 2. In flight at hand-over

| Agent | What | Resume |
|---|---|---|
| Q07 QA Lead | 11 portal Robot placeholders (P01–P04) → real `robotframework-browser` tests on isolated project `agritrace-q07` (:8030, portal :5183); report `docs/agents/reports/Q07.md` | if missing: respawn with the Q06 recipe; then also the 2 `qa/robot/public/page.robot` placeholders (Q03-1) |
| P11 Worker | `PlotMap.tsx` Vitest test so `members` coverage ≥ 80 % (Q02-1) | small; Orchestrator confirms + merges, then Q02 → PASS |
| B21 Worker | Q04-1/2 push validation (NUL, int32, per-entry DB-error rejection, telemetry 422) + Q04-3 BM-07 (profile, uvicorn workers, pool) on its own project `agritrace-b21` (:8040); may change `openapi.json` → regenerate TS + Dart clients at merge | BE review (SEC hat) → merge → `make up` → Q05 reruns locust + fuzz |

No other worktrees should exist (`git worktree list`). Shared-stack live checks are blocked by the admin OTP cap until ~21:49 IST; use an isolated project.

## 3. Next steps (in order)

1. Merge P11 (Q02 → PASS), Q07 (then G4 Robot condition met), B21 (then Q04 rerun). After B21: `make up` (if the build fails with a BuildKit "lease not found", run `docker builder prune -af` first).
2. Architect-Gate: sign G2 (rule on the mobile Robot placeholders belonging to G3/Q01), evaluate G3 (needs the P06 line-5 re-check: correction reason in the portal Audit Log, on a fresh stack) and G4 (B10/B11/W03 verified; Robot portal/public suites from Q07).
3. Q05 release gate: benchmark sweep with `collect.py --results-dir docs/agents/qa/bench-results/` (see TODO), rerun BM-07 + the Schemathesis fuzz after B21, the P06 line-5 check, `/ponytail-audit` on the final tree if anything but tests changed, G5 report — Q01 (device checks) will stay open until an Android Go AVD exists, so G5 can only be CONDITIONAL.
4. Human blockers in §4; open P2/P3 follow-ups in `TODO.md` §4, §6, §7 with owners.

## 4. Blockers only a human can clear

1. **Git remote / push** (see §1).
2. **Android Go AVD** for Q01 (system-image download, several GB; disk has ~8 GB free).
3. **Product confirmations still open**: GI 883 taluk list from GI Journal 200; 3-dp public map rounding; 15 % `grading_loss_warn_pct` default (D-030); farm area and grade readings `public` in the field YAML (D-034); the Sell-QR compromise on shared phones (D-029 amendment in M13: the next user sees the previous farmer's ready lot until intake).
4. **Firebase/APNs** (M12): project, config files, APNs key and entitlement; the API has no device-token endpoint (`push_notifications` off).
5. **Docker Desktop**: healthy now; if it dies again see the memory note (orphan `com.apple.Virtualization` process; truncated containerd snapshots fixed with `ctr` from a helper container; GUI "Clean / Purge data" refused to the agent).

## 5. Resume procedure (Orchestrator)

1. `git status` clean on `main`; `docker info` ok; `curl localhost:8000/v1/healthz` → `{db,redis,s3: ok}` (else `make up`; DB port 5433 is already in `infra/.env`).
2. Hotfix WPs come from Verifier P2 issues (`docs/agents/qa/issues/`) and audit findings: one Opus Worker per WP in a worktree, declared paths, then BE/MOB/WEB(+SEC) Reviewer with `ponytail:ponytail-review`; exact reviewer fixes are confirmed by the Orchestrator, new logic goes back to the same reviewer (SendMessage). Decision numbers come from the TODO ledger (next free: D-055).
3. After any backend merge: `cd apps/api && uv run python -m agritrace.export_openapi && JWT_SECRET=x uv run python ../../infra/scripts/gen-error-codes.py && uv run pytest tests/unit -q -p no:cacheprovider && uv run lint-imports`, then `cd ../portal && npm run gen:api`, then `cd ../mobile && JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" tool/gen_api.sh`; **rebuild the stack** (`make up`) so live checks run main's code. After any mobile merge: `flutter analyze --fatal-infos && flutter test -x perf -j 1` (~40 min under load, 8 min quiet). After any portal merge: `npm run typecheck && npm test -- --no-file-parallelism`.
4. Conflicts: CHANGELOG/TODO/LIBRARIES keep both sides (`python3` regex keep-both is fine for these three); DECISIONS rows in number order; generated files take main's then regenerate; **code by hand**.
5. Bookkeeping per merge: CHECKLIST row + `python3 infra/scripts/checklist-progress.py`, CHANGELOG suffix, TODO lines, `codegraph sync .`, `git worktree remove -f -f` + `git branch -d`. Keep G0 = exactly {B00, Q00} in CHECKLIST (qa/tests asserts it); hotfix rows live under the section of the WP they fix or under G5.

## 6. Risks going forward

- Robot API suites (`qa/robot/api/*.robot` except healthz) have never run and several are tagged `not-ready`; G2 requires them green.
- APK/AAB size unmeasured (M13); mobile device checks (cold start, WorkManager firing, storage prompt, clock jump, user switch mid-sync) all wait for Q01.
- Publish answers 202 before the page build succeeds (TODO P3); a privacy-lint false positive now fails a page build (B18, by design).
- Celery `visibility_timeout` default (TODO); `check_event`/`verify_photo` tasks never retry on failure (B19 report).
- Host load from unrelated apps (WhatsApp at 300 % CPU) made every suite 3–5× slower; Lighthouse 3G has ~300 ms margin.
