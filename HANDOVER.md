# Handover — AgriTrace build, state at 2026-11-02 03:55 IST (end of day 4: first live-stack day; wave 7 complete except device work; G5 signed CONDITIONAL)

Written for: whoever resumes the multi-agent build (human or the Orchestrator session). Read this, then `CHECKLIST.md`, then `TODO.md` §4, §6–§8 (follow-ups with owners) and the decision-number ledger line.

## 1. Where things stand

| Area | State |
|---|---|
| Plan | `PLAN.md` (approved 2026-10-29); specs `docs/agents/specs/`; rulings `docs/agents/gates/rulings-2026-10-31*.md`; gate rulings inside `docs/agents/gates/G2.md`–`G4.md` |
| Progress | `CHECKLIST.md`: **94 % (75/80)** before the G5 signature. Every work package is merged, reviewed and verified on the live stack except **Q01** (device checks on an Android Go emulator — not started, no AVD exists). Hotfix WPs added and closed today: B17–B23, M14–M16, P09–P11, D01, Q06, Q07 |
| Gates | **G0, G1, G2, G4 SIGNED.** **G3 BLOCKED** on two human-gated items only: Q01 (offline matrix, 3-tap ≤ 60 s, cold start, WorkManager, storage prompt, BM-01/02/11–15) and the AAB download size (needs the bundletool CLI jar; arm64 APK 30.03 MiB already meets the D-002 budget — PLAN §3's literal "APK < 30 MB" is the superseded source-doc figure). **G5 signed CONDITIONAL** (e79949f, `docs/agents/gates/G5.md`): backend, portal and public page are the pilot candidate; conditions A = Q01 on a Go AVD (incl. AAB ≤ 30 MiB), B = BM-07 first-run pass on main after B22/B23 (→ Q04 PASS), C = the human list in §4 |
| Audits | `docs/agents/audits/wave-0-2.md`, `waves-3-6.md`, `wave-7.md`: all P1s fixed and merged (M14, M16, P09); wave-7 P2 (phones in committed Robot evidence) fixed in Q07 r2; remaining P2/P3 in TODO §6–§8 |
| Security / docs | `docs/agents/reviews/SEC-asvs-l1.md` (ASVS L1 as one document: 2 FAILs → closed by B23 and D01; 16 PARTIALs → `docs/ops/deployment-checklist.md`); `docs/agents/reviews/DOCS-g5.md` (coverage 100 % in all three languages; README fixed by D01); `docs/ops/dpdp-data-subject-runbook.md` (export/erasure; needs B24 routes and an Architect-Gate ruling on redacting copies in append-only tables) |
| Decisions | D-001…D-054 (D-049 unused; D-055–D-064 reserved and unused — the hotfixes needed no new ADRs; D-017, D-018, D-024, D-029, D-034 amended today). Next free number: **D-055** |
| Main | 487 commits; backend **799/799** on the live stack (testcontainers), 51 error codes, migrations 0001–0004; mobile 812 tests + analyzer clean, APK 30.03 MiB; portal 141 Vitest, Playwright mock 6/6, live chain 2/2, bundle 247 KB gz; public page 76 pytest, Lighthouse 3G 98; qa/tests 111; Robot: API 67/67, portal + public 45/45 (only the 10 Q01 mobile lines are placeholders); OpenAPI, TS and Dart clients regenerated and byte-identical at 913c711 |
| Remote | `origin` = https://github.com/ChargingTrex/agriGItag-app (**public**, created by the user; `main` pushed 2026-11-04 at 64299f8). Push after every merge: `git push origin main` |
| Stack | Docker Desktop up; compose stack from main (api image 2026-11-01T22:14Z incl. B22/B23; `WEB_CONCURRENCY=4`) running and healthy on :8000; **DB on host port 5433 and API on host port 8001** (`infra/.env`; another project's Django app owns :8000 on this host). The seed is heavily polluted by Verifier runs (fuzz events, load pushes, QA farmers/batches); **reseed before any demo**: `docker compose -f infra/docker-compose.yml down -v && make up && make seed`. The admin OTP cap (10/day) is spent on this stack until ~21:49 IST 2026-11-02 |

### Merged today (2026-11-01 → 02), in order
P05, P07, M13 → B17 → M15 → B18 → P09 → M14+M16 → B19 → B20 → P10 → P11 → Q06 → Q07 (r1, r2) → B21 → D01 → B22 → B23. Reviews in `docs/agents/reviews/` (68 files), reports in `docs/agents/reports/`, QA evidence in `docs/agents/qa/` (37 verdict files + logs/shots/robot).

## 2. In flight at hand-over

Nothing. No agents running, no worktrees open (`git worktree list` = main only), no stray compose projects or images; disk 8.9 GB free; stack healthy on :8000.

## 3. Next steps (in order)

1. **Human blockers (§4)** — Q01 cannot start without an Android Go AVD; the AAB figure needs the bundletool CLI jar; the repo needs a remote.
2. **Q01** (one Opus Verifier once an AVD exists): Go profile API 27 / 2 GB / 2 cores / 720×1280 (`qa/README.md`, `docs/agents/qa-rubric.md`); run `qa/robot/mobile/*.robot` (offline matrix, BM-11..15 network profiles), BM-01 (3-tap ≤ 60 s), BM-02, cold start < 3 s, WorkManager 15-min firing, storage prompt + purge, clock jump (M16), user switch mid-sync (M16), release smoke on the APK; then G3 and the G5 condition close.
3. Follow-up WPs queued in TODO (Architect-Gate queue / owners): **B24** export/erase endpoints + `otp_challenges` purge (runbook); **P12** portal device-management screen (list + revoke); B13 per-row DataError on CSV import; B14 shared `_audit` helper; D-005 ruling on redacting copies of PII in append-only tables; `check_event` flags-index note (B22); Celery `visibility_timeout`; `S. No.` linter gap; ID-document presign size.
4. Pilot deployment: `docs/ops/deployment-checklist.md` (every SEC PARTIAL), a real SMS provider (`ENV=prod` refuses to start without one), Firebase/APNs, CloudFront invalidation.

## 4. Blockers only a human can clear

1. **Git remote / push** (see §1).
2. **Android Go AVD** for Q01 (system image download, several GB).
3. **bundletool CLI jar** (`bundletool-all-1.18.3.jar` from GitHub releases on PATH as `bundletool`) then `cd apps/mobile && tool/size_check.sh` for the AAB download size (≤ 30 MiB).
4. **Product confirmations:** farmers keep a session **90 days** before re-entering an SMS code (staff 30; B23/D-024, `SESSION_MAX_DAYS_FARMER`); GI 883 taluk list from GI Journal 200; 3-dp public map rounding; 15 % `grading_loss_warn_pct` default (D-030); farm area and grade readings `public` (D-034); the Sell-QR compromise on shared phones (D-029); retention periods in the DPDP runbook (proposals, FPO board signs).
5. **Firebase/APNs** (M12) and an SMS provider (`core/config.py`) before `ENV=prod`.
6. **Docker Desktop**: healthy; if it dies again see the memory note (orphan Virtualization process; truncated containerd snapshots; `docker builder prune -af` when BuildKit says "lease not found"; the GUI purge is refused to the agent).

## 5. Resume procedure (Orchestrator)

1. `git status` clean on `main`; `docker info` ok; `curl localhost:8000/v1/healthz` → `{db,redis,s3: ok}` (else `make up`; after a rebuild check `docker image inspect agritrace-api:dev --format '{{.Created}}'` — a failed BuildKit lease keeps the old image silently).
2. Any new WP or hotfix: one Opus Worker in a worktree with declared paths and a reserved decision number (ledger in TODO; next D-055) → Reviewer with the right hat (`ponytail:ponytail-review`; SEC hat for auth, sync, presign, public payloads, locks) → exact fixes confirmed by the Orchestrator, new logic back to the same reviewer → merge `--no-ff` → regenerate (`export_openapi`, `gen-error-codes.py`, `npm run gen:api`, `tool/gen_api.sh` with `JAVA_HOME`) → `make up` → suites on main → CHECKLIST/CHANGELOG/TODO → `codegraph sync .` → remove worktree + branch.
3. Verifiers run on an **isolated compose project** (`COMPOSE_PROJECT_NAME=agritrace-<wp> API_PORT=80xx DB_PORT=54xx REDIS_PORT=64xx S3_PORT=45xx docker compose -f infra/docker-compose.yml up -d --build --wait`, seed via `exec api`, `down -v` after) when they sign staff in (OTP cap) or mutate seed data; recipe in `docs/agents/reports/Q06.md`.
4. Conflicts: CHANGELOG/TODO/LIBRARIES keep both sides; DECISIONS rows in number order; generated files take main's then regenerate; **code by hand**. Keep G0 = exactly {B00, Q00} in CHECKLIST (`qa/tests` asserts it).
5. Committed evidence must hold no phone outside the seed block `+919000…` (grep before committing Robot output).

## 6. Risks going into the pilot

- Device behaviour is unverified (Q01): offline matrix, background sync firing, storage purge, clock skew and user-switch paths are tested only in unit/widget tests.
- BM-07 passes on a quiet host (p95 230–280 ms) but depends on the rules backlog; B22 cut the per-check cost 3×, the backlog rerun is still owed (Q04-3).
- Publish answers 202 before the page build succeeds; a privacy-lint false positive fails a build (TODO §7, raised to P2 by the wave-7 audit).
- Seed-state pollution on the shared stack; OTP caps make live staff checks scarce (3–4 chain runs per day per stack).
- Goldens are macOS-recorded; Lighthouse 3G has ~300 ms margin; host load from unrelated apps slows every suite 3–5×.
