# Handover — AgriTrace build, state at 2026-11-02 00:40 IST (day 4: first live-stack day)

Written for: whoever resumes the multi-agent build (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §6–§7 (audit follow-ups, gate blockers) and the decision-number ledger line.

## 1. Where things stand

| Area | State |
|---|---|
| Plan | `PLAN.md` (approved 2026-10-29); specs in `docs/agents/specs/`; rulings `docs/agents/gates/rulings-2026-10-31*.md` |
| Progress | `CHECKLIST.md`: **72 % (51/71)**. Every backend package B00–B19 is **verified on the live stack** (`docs/agents/qa/B*.md`); every mobile package M00–M16 is merged, reviewed and green on main (device runs → Q01); portal P01–P08 and W03 are merged and reviewed, their live-API verification is **in flight** (see §2) |
| Gates | **G0 SIGNED** 2026-11-01 (`docs/agents/gates/G0.md`). **G1 BLOCKED** only by the P00 Robot headless-browser test never having run (the WEB Verifier is running it). G2–G5 unsigned |
| Audits | `docs/agents/audits/wave-0-2.md` (3 P1, 11 P2, 6 P3) and `waves-3-6.md` (2 P1, 5 P2, 9 P3). **All five P1s are fixed and merged** (M14, M16, P09); P2s fixed: M15, B18, B19; the rest are TODO §6/§7 lines |
| Decisions | D-001…D-054 (D-049 unused; D-055–D-058 reserved, unused: B18/B19/P09/M16 needed no ADR) |
| Main | 391 commits; backend 623 unit / 780 total (full suite green on the live stack); mobile 812 tests, analyzer clean; portal 135 Vitest, bundle 243 KB gz; public page 76 pytest; qa/tests 109; 49 error codes; migrations 0001–0004; OpenAPI, TS and Dart clients regenerated and byte-identical after the last backend merge (B18) |
| Remote | **none.** No `origin`; creating `ChargingTrex/agriGitag` and pushing was denied by the permission classifier. Human step: `gh repo create ChargingTrex/agriGitag --private --source . --remote origin --push` |
| Stack | Docker Desktop up (engine 29.3.1); compose stack running from main @ 72c52b5+ (api/worker rebuilt after B19), seeded (reference batch `FGP8T4033HM7` untouched; Verifiers added QA farmers +919000000091/92/151/152, staff PINs 2468 for +919000000001 and +919000000003, QA batches incl. published `GQ6QTKYZYVEP`). **DB on host port 5433** via git-ignored `infra/.env` (Homebrew Postgres owns 5432) |

### Merged today (2026-11-01), in order
P05, P07, M13 (yesterday's in-flight branches) → B17 (first live-stack fixes) → M15 → B18 → P09 → M14+M16 → B19. Reviews for every one in `docs/agents/reviews/`; reports in `docs/agents/reports/`.

### Verified live today
B00 (CONDITIONAL → PASS after B17), Q00 deferred lines closed, B01–B05, B06, B13, B14, B07, B08 (B08-r2 filed), B09, B15, B16 (CONDITIONAL → PASS after B19), B10, B11, B12 (e2e with the ruling flag set; both clients compile). The three G5-condition pushes (`lot_intake`, `farmer`+`assist_session`+`consent`+`plot`, timeout-then-sync) succeeded live. BM-05, BM-06, BM-08, BM-09, BM-15 met.

## 2. In flight at hand-over

| Agent | What | Resume |
|---|---|---|
| WEB Verifier (one Opus agent) | P00 Robot `Portal Loads In A Headless Browser` (G1 blocker) → `docs/agents/qa/P00.md` section; P07 live chain `E2E_LIVE=1` twice without reseed; P01–P06, P08 live-API acceptance lines with screenshots; W03 Lighthouse 3G on a published page; writes `docs/agents/qa/P0x.md`, `W03.md` | If the session is new: check `git log -- docs/agents/qa/P0*` and `docs/agents/qa/W03.md`; respawn for whatever is missing (brief: same as `docs/agents/qa-rubric.md`, portal in live mode via `VITE_API_BASE_URL`, do not touch the reference batch) |

No worktrees are open (`git worktree list` = main only). If the WEB Verifier's report exists: tick the P rows, resume the Architect-Gate for G1 (its brief: `docs/agents/gates/G1.md` conditions; P00 Robot PASS clears the block), then open G2 (`docs/agents/gates/G2.md`: B02–B08, B13, B14 verified ✓; M01–M07 ✓; P01–P04 live ✓ pending; audits: all P1 closed on main; Robot API suites must be un-`not-ready`-tagged and run — TODO line "Robot API suites still tagged not-ready").

## 3. Next steps (in order)

1. Portal/public-page Verifier report → tick P01–P08, W03 → G1 sign → G2 gate agent (also writes `docs/agents/audits/` nothing new; the two audits exist) → G3/G4 need the same plus M13 size.
2. **M13 size measurement** on a quiet host: `cd apps/mobile && tool/size_check.sh` (bundletool shim per `docs/agents/reports/M13.md`; needs ~3 GB disk, 25+ min; host must not be running Lighthouse). Budgets: APK ≤ 100 MiB hard / 40 warn, AAB download ≤ 30 MiB.
3. Wave 7 Verifiers: Q01 (needs an Android Go AVD: API 27, 2 GB, 2 cores, 720×1280 — none exists; `Medium_Phone_API_36.1` only), Q02 (portal: Vitest coverage ≥ 80 % in features + the P07 live chain), Q03 (public page backend-down serve from S3 + old version retrievable), Q04 (locust p95 BM-07, Schemathesis fuzz on `/sync/push`), Q05 (benchmark sweep → `docs/agents/qa/benchmarks.json`, G5 report).
4. Open P2/P3 follow-ups from the audits and Verifiers are all in `TODO.md` §4, §6, §7 with owners.

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
