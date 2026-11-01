# AgriTrace — Checklist

Completion: 84 % (62/74 items)

Tick an item only after Reviewer PASS and Verifier PASS and the branch is merged. `python3 infra/scripts/checklist-progress.py` rewrites the line above.

## Pre-wave (Orchestrator)

- [x] Git repository initialised; source documents moved to docs/source/
- [x] CLAUDE.md with hierarchy, Ponytail rules, Documentation Standard
- [x] DECISIONS.md and docs/adr/D-001…D-020
- [x] CHECKLIST.md, CHANGELOG.md, TODO.md, docs/LIBRARIES.md
- [x] docs/agents: roles, checkpoint protocol, QA rubric, acceptance files
- [x] CodeGraph initialised (`codegraph init .`) — 2026-10-29, re-run `codegraph sync` after every merge
- [x] Ponytail plugin installed for this project (user reloaded plugins 2026-10-30; reviewers run `/ponytail-review` from here on)

## G0 Foundation

- [x] B00 — Scaffold + infra + test harness — wave 0 — worker: Opus (4 rounds) — reviewer: BE r1/r2 PASS-PENDING-STACK → stack run 2026-11-01 — verifier: CONDITIONAL → PASS 2026-11-01 (docs/agents/qa/B00.md: all 4 lines pass live; the 2 P2 harness flakes B00-1/B00-2 fixed and merged in B17, combined suite 768/768)
- [x] Q00 — Harness: compose stack, seed, Go AVD profile (API 27, 2 GB, 2 cores, 720×1280), network sc — wave 0 — worker: Opus (4 rounds) — reviewer: QA Lead r1/r2/r3 FAIL, r4 closure — verifier: CONDITIONAL → deferred Docker lines closed 2026-11-01 (docs/agents/qa/Q00.md: stack, seed, healthz.robot, robot-smoke re-enactment PASS; Q00-2 checklist-structure test fixed by moving the B17 row; identity.robot `not-ready` tags → G2 work)
- [x] **Gate G0 signed** 2026-11-01 by the Architect-Gate (docs/agents/gates/G0.md; audit wave-0-2 no P1 in scope: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G1 Contract

- [x] B01 — Domain contracts (schema-first) — wave 1 — worker: Opus (2 rounds) — reviewer: Architect-Gate APPROVED-PENDING-STACK → live 2026-11-01 — verifier: PASS 5/5 (docs/agents/qa/B01.md; append-only trigger live, SRID 4326, alembic check clean)
- [x] M00 — Skeleton: flavors, M3 theme + tokens, go_router role redirect, l10n en/ta, generated Dart  — wave 1 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 — verifier: PASS (docs/agents/qa/M00.md)
- [x] P00 — Skeleton, auth guard, generated client, MSW from spec, lint/test/e2e config — wave 1 — worker: Opus — reviewer: WEB PASS r1 — verifier: PASS (docs/agents/qa/P00.md) + Robot headless-browser test PASS 1/1 live 2026-11-01 (G1 blocker cleared)
- [x] W01 — `render(public_batch) -> (html, json)`, Jinja2 `batch.html.j2`, inline CSS < 12 KB, JS < 4 — wave 1 — worker: Opus (2 rounds) — reviewer: WEB r1 FAIL, r2 PASS — verifier: PASS (docs/agents/qa/W01.md)
- [x] **Gate G1 signed** 2026-11-02 by the Architect-Gate (docs/agents/gates/G1.md; P00 Robot headless-browser test PASS; spec validates, clients byte-identical, D-001…D-012 accepted) (docs/agents/gates/G1.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G2 Core backend

- [x] B02 — Identity — wave 2 — worker: Opus (2 rounds) — reviewer: SEC FAIL r1 / PASS-PENDING-STACK r2 — verifier: PASS 6/6 (docs/agents/qa/B02.md; live 429/409/403/401 with the dev OTP)
- [x] B03 — Registry + PostGIS geo — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PASS 7/7 (docs/agents/qa/B03.md; live locate_point inside/near_edge/outside)
- [x] B04 — Notifications — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PASS 2/2 (docs/agents/qa/B04.md; live broker + worker; P3 visibility_timeout note → TODO)
- [x] B05 — Quality + grade engine — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PASS 9/9, BM-08 65/65 (docs/agents/qa/B05.md)
- [x] M01 — Drift store + DAOs + migrations + schema test — wave 2 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 + r2 confirm — verifier: Orchestrator-run db suite PASS; Go-AVD timing → Q01
- [x] M04 — Capture kit: camera (no gallery), compress to long edge 1600 px at JPEG q≈80 stepping down — wave 2 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS; device checks → Q01
- [x] M05 — Farmer widget kit: FarmerButton, PictureCardGrid, BigStepper, NumberPad, StatusBadge, Voic — wave 2 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS (198); device checks → Q01
- [x] M06 — Auth & session: OTP auto-read, device binding, PIN for officer/QC, role routing, restore o — wave 2 — worker: Opus (2 rounds) — reviewer: SEC/MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS (264); device checks → Q01
- [x] W02 — `privacy_lint.py` (canary strings + regexes for phone/Aadhaar/survey/polygon/coordinate pr — wave 2 — worker: Opus — reviewer: WEB PASS r1 — verifier: PASS (docs/agents/qa/W02.md; BM-03 LCP 1530 ms, BM-16 565 ms)
- [x] B06 — Events + sync push + evidence — wave 3 — worker: Opus (2 rounds) — reviewer: SEC PASS-PENDING-STACK — verifier: PASS 8/8, BM-06 + BM-15 live (docs/agents/qa/B06.md, 2026-11-01)
- [x] B13 — Config-driven fields/features + masters + bulk import (from the gap analysis) — wave 3 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PASS 5/5 (docs/agents/qa/B13.md; flag gate + YAML schema refusal live, build_virudhunagar.py run)
- [x] M02 — Sync engine (outbox, triggers incl. reachability probe, timeouts 10 s/30 s, retry only on  — wave 3 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / PASS r2 — verifier: Orchestrator-run suite PASS (401); device/network runs → Q01 (BM-11..15); server half of the r2 line → Verifier with B15
- [x] M14 — Sync engine audit P1 fixes (outbox retries in strict order + ordering rejections retried; refresh token re-read from secure storage so background sync does not sign farmers out) — wave 3 hotfix (audit waves-3-6 P1-1/P1-2, blocks G2) — worker: Opus (1 round + micro-patch) — reviewer: MOB/SEC PASS r1, micro-patch confirmed in M16-r1 — verifier: full Flutter suite 812/812 on main after merge (2026-11-01); device/WorkManager runs → Q01
- [x] M16 — Sync engine: upload-URL expiry vs phone clock skew; running sync stops on user switch (audit wave-0-2 P1s, blocks G2) — wave 3 hotfix — worker: Opus (same branch as M14, 1 round + P3 patch) — reviewer: MOB/SEC PASS r1 (0 P1/P2) — verifier: full Flutter suite 812/812 on main after merge (2026-11-01); clock-jump and user-switch device runs → Q01
- [x] M03 — Ref data + local preview rules (GI point-in-polygon + buffer, yield 20/30, event order, mo — wave 3 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 + r2 confirm — verifier: Orchestrator-run rules suite PASS (63/63 parity)
- [ ] P01 — Members: approvals, roster, farmer/plot detail with MapLibre/OSM + GI outline — wave 3 — worker: Opus (2 rounds) — reviewer: WEB PASS r1 + r2 confirm — verifier: FAIL 1/2 live (docs/agents/qa/P01.md: approve → active OK; masked phone + audited Reveal never built on B14's endpoint → built in P10, re-verify live at Q02)
- [x] P09 — Shared-PC device lockout (`device_in_use` → new device id + retry; sign-out failure surfaced; refresh keeps session on 5xx/429) — wave 3 hotfix (audit wave-0-2 P1 + 2 P2, blocks G2) — worker: Opus (2 rounds) — reviewer: WEB/SEC FAIL r1 → r2 exact fix confirmed by Orchestrator — verifier: auth tests 19/19 on the branch; full Vitest on main after merge (merged 2026-11-01)
- [x] P10 — Portal live fixes: masked phone + audited Reveal (P01 on B14), P07 chain assertion (P07-1) and live mode (P07-2: 204 body, OTP limit, create a batch on QA lots) — wave 7 hotfix — worker: Opus (1 round + micro-patch) — reviewer: WEB/SEC PASS r1 + micro-patch confirmed by Orchestrator — verifier: Vitest 138, Playwright mock 6/6 ×2, live chain 2/2 (15.4 s / 59.8 s) on the branch; P01/P07 live lines re-verify at Q02 (merged 2026-11-02)
- [x] P03 — Ready lots → Create batch: tick, running total, share %, greyed lots with reason, non-GI t — wave 3 — worker: Opus (2 rounds) — reviewer: WEB FAIL r1 / r2 Orchestrator confirm — verifier: PASS 4/4 live incl. shares 31.25/62.5/6.25 (docs/agents/qa/P03.md)
- [x] B14 — Registry API gaps found by the portal (phone_masked + audited reveal, reject, farmer plots, village filter/search, FPO bbox) — wave 4 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PASS 5/5 (docs/agents/qa/B14.md)
- [x] B07 — Reference bundle + sync pull — wave 4 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK r1 + r2 confirm — verifier: PASS 3/3 (docs/agents/qa/B07.md; 304 on 11 parts live)
- [x] B08 — Rules & flags — wave 4 — worker: Opus (2 rounds) — reviewer: BE FAIL r1 / r2 confirmed by Orchestrator (B08-r2.md filed 2026-11-01) — verifier: CONDITIONAL → PASS 8/8 (docs/agents/qa/B08.md; B08-1 closed by the r2 file)
- [x] M07 — Farmer home + 8 events (F03–F09, F16, F17), out-of-order prompt, lot readiness — wave 4 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 Orchestrator confirm — verifier: suite PASS (605) on the merged branch; device checks (< 20 s log, camera, GPS) → Q01
- [x] P02 — Flags & plot review — wave 4 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 + micro-patch confirm — verifier: PASS 2/2 live (docs/agents/qa/P02.md, 2026-11-01)
- [x] P04 — Batch detail, approve grading, publish, preview iframe, grey-button reasons — wave 4 — worker: Opus (2 rounds) — reviewer: WEB FAIL r1 / r2 Orchestrator confirm — verifier: PASS 4/4 live incl. D-041 non-GI line (docs/agents/qa/P04.md)
- [x] Q06 — Robot API suites implemented and green (48 placeholders in qa/robot/api → real tests on an isolated stack; G2 blocker) — wave 7 — worker: Opus QA Lead (1 round) — reviewer: Orchestrator (QA code; 67/67 twice, interrogate 100 %, qa/tests 110) — verifier: robot run docs/agents/qa/Q06/robot/ (merged 2026-11-02); Q06-1 P3 filed (consent audit rows lack fpo_id)
- [ ] **Gate G2 signed** — readiness filed BLOCKED 2026-11-02 (Robot API suites green via Q06 ✓; B08-2 closed via B20 ✓; P01 live line built in P10, re-verify at Q02; mobile/portal Robot placeholders belong to G3/G4 scope) (docs/agents/gates/G2.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G3 Mobile core

- [x] B09 — Lots, intake, batches, gates — wave 5 — worker: Opus (2 rounds) — reviewer: BE FAIL r1 / PASS-PENDING-STACK r2 — verifier: PASS 8/8 (docs/agents/qa/B09.md; seeded shares 31.250/62.500/6.250 live, 2026-11-01)
- [x] B15 — Backend gaps from B08 review and M09 (grading-loss split D-030, `farmer` push kind + `client_id` D-031, assist_session kind D-032) — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PASS (docs/agents/qa/B15.md; live push [farmer, assist_session, consent, plot] 4× accepted, replay 4× duplicate, timeout-then-sync → one farmer)
- [x] B16 — QC intake via sync (`lot_intake` push kind, `POST /intakes` for QC, processor default, moisture gate at intake; D-040), non-GI holds (D-041), assist_session_id per kind (D-042) — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE/SEC PASS-PENDING-STACK r1 — verifier: CONDITIONAL → PASS 2026-11-02 (docs/agents/qa/B16.md; live lot_intake pushes OK; B16-1 race closed by B19, live rerun 5/5 open, log 04-live-b16-race-after-B19.log)
- [x] B19 — Stale rules run must not close a flag it could not see (B16-1 race in `store_flags`) — wave 6 hotfix — worker: Opus (2 rounds) — reviewer: BE FAIL r1 (deadlock + lock scope) → r2 exact fixes confirmed by Orchestrator — verifier: integration 53 + unit 623 on the branch; main 780/780 after merge; live race script 5/5 open (2026-11-02)
- [x] B20 — Backend live fixes: `event.correct` audit row keeps `reason_code` (P06), optional `farming_type` must not fail a page build (B10-1), B08-2 intake/rules deadlock verified closed by B19 or fixed — wave 7 hotfix — worker: Opus (1 round + patch) — reviewer: BE PASS r1 + patch confirmed by Orchestrator — verifier: unit 624, integration 63, public page 76 on the branch; B08-2 0/20 live (docs/agents/qa/B20/logs); P06 line 5 re-verify at Q02 (merged 2026-11-02)
- [x] M08 — Sell QR, Money, History + Undo, Settings — wave 5 — worker: Opus (1 round + 2 micro-patches) — reviewer: MOB PASS r1 — verifier: Orchestrator-run suite PASS (660 on main); device checks → Q01
- [x] M09 — Officer onboarding wizard (9 steps, consent audio, GPS ring, acre/cent stepper, boundary w — wave 5 — worker: Opus (2 rounds + micro-patch) — reviewer: MOB FAIL r1 / PASS r2 — verifier: Orchestrator-run suite (post-merge); device checks → Q01
- [x] M10 — Officer home, assist mode, flags, moisture reading — wave 5 — worker: Opus (2 rounds) — reviewer: MOB/SEC FAIL r1 / r2 Orchestrator confirm — verifier: Orchestrator-run suite PASS (724 on main); device checks → Q01
- [x] M11 — QC mode: scan, intake checks, grading form from profile, grade preview, final packing, BLE — wave 5 — worker: Opus (2 rounds + micro-patch) — reviewer: MOB FAIL r1 / r2 one P2, patch confirmed by Orchestrator — verifier: Orchestrator-run suite PASS (779 on main); device checks → Q01; live lot_intake push → Verifier with B16
- [x] M15 — QC pick-lot fallback lists open/drying lots (audit waves-3-6 finding 5, P2) — wave 5 hotfix — worker: Opus (1 round) — reviewer: Orchestrator (audit-specified one-line fix) — verifier: qc suite 53/53 on the branch; full suite 812/812 on main (merged 2026-11-01)
- [x] P05 — Labels PDF + CSV exports (unit column FR58) — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 + micro-patch confirmed by Orchestrator — verifier: PASS 2/2 live (docs/agents/qa/P05.md)
- [ ] P06 — Dashboard + FPO settings. Dashboard = stage-progress tiles (Land prep, Nursery, Sowing, In — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 — verifier: FAIL 4/5 live (docs/agents/qa/P06.md: audit search shows actor but B11's event.correct row drops reason_code → fixed in B20, re-verify live at Q02)
- [x] P08 — Master data uploads: CSV import for farmers, villages, inputs with template download, dry- — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS-PENDING-STACK r1 — verifier: PASS 3/3 live (docs/agents/qa/P08.md)
- [ ] **Gate G3 signed** (docs/agents/gates/G3.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G4 Portal + Publish

- [x] B10 — Publishing — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE/SEC PASS-PENDING-STACK r1 — verifier: PASS 6/6, BM-09 0 hits on the published page (docs/agents/qa/B10.md)
- [x] B18 — Audit P2 fixes at trust boundaries (presigned PUT bound to declared Content-Length + size ceiling; publish runs the privacy linter and fails the build on a hit; linter patterns for R.S. No., Tamil survey label, spaced coordinates, dotted phones) — wave 6 hotfix — worker: Opus (1 round + micro-patch) — reviewer: BE/SEC PASS r1 + micro-patch confirmed by Orchestrator — verifier: unit 623 + integration 29 + qa 109 on the branch; live lint-on-publish check → next stack rebuild (merged 2026-11-01)
- [x] B11 — Reporting + stubs — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PASS 4/4, BM-05 100 % completeness, 9 reference problems flagged (docs/agents/qa/B11.md)
- [x] M12 — Notifications + deep links (FCM/APNs, local reminders from calendar bundle) — wave 6 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 Orchestrator confirm — verifier: Orchestrator-run suite PASS (793 on main); device checks → Q01
- [x] W03 — Tamil/English labels, print CSS, OG tags (no personal data), unpublished/404 variant, stat — wave 6 — worker: Opus (1 round) — reviewer: WEB PASS r1 — verifier: PASS live (docs/agents/qa/W03.md: 3G perf 0.98, LCP 1743 ms, 19.7 KB; 4G LCP 548 ms; privacy lint 0; og:url/og:image → B10 TODO)
- [ ] **Gate G4 signed** (docs/agents/gates/G4.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G5 Pilot candidate

- [x] B12 — Demo seed, e2e, client generation — wave 7 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PASS (docs/agents/qa/B12.md; e2e 2/2 with the ruling flag set, seed idempotent, both clients regenerate clean)
- [x] B17 — First live-stack fixes (seed `gi_eligible`, B13 head assertion, B14 audit payload, stack fixture env leak + idempotent CreateBucket) — wave 7 hotfix — worker: Opus (1 round) — reviewer: Orchestrator (test-only + 1-line seed diff) — verifier: combined `pytest tests` 768/768 on the branch (merged 2026-11-01)
- [x] M13 — Hardening & release: low-storage purge, background sync proof, in-app update, size budget, — wave 7 — worker: Opus (1 round + micro-patch) — reviewer: MOB/SEC PASS r1 + 2 P2 micro-patches confirmed by Orchestrator — verifier: size PASS 30.03 MiB arm64 APK (Orchestrator run 2026-11-02, docs/agents/qa/M13.md); AAB download unmeasured (no bundletool); device checks → Q01
- [ ] P07 — Playwright e2e chain + axe — wave 7 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 + micro-patch confirmed by Orchestrator — verifier: FAIL live + mock (docs/agents/qa/P07.md: P07-1 chain assertion, P07-2 live mode 204/OTP limit/no batch; fixed in P10: chain green mock 6/6 and live 2/2 on the branch; re-verify at Q02; axe 0 serious PASS)
- [ ] Q01 — Flutter verification: widget/golden/integration on Go + API 34 AVDs, offline/online matrix — wave 7 — worker: — reviewer: — verifier:
- [ ] Q02 — Portal verification: Vitest ≥ 80 % in features, Playwright chain, axe — wave 7 — worker: — reviewer: — verifier:
- [ ] Q03 — Public page verification: W02 suite + backend-down serve from MinIO + old version retrieva — wave 7 — worker: — reviewer: — verifier:
- [ ] Q04 — Backend verification: full pytest incl. e2e reference batch, locust p95, Schemathesis fuzz — wave 7 — worker: — reviewer: — verifier:
- [ ] Q05 — Release gate: benchmark sweep → `docs/agents/qa/benchmarks.json`, rubric, G5 report — wave 7 — worker: — reviewer: — verifier:
- [ ] **Gate G5 signed** (docs/agents/gates/G5.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)
- [x] **G5 condition (rulings 2026-10-31 §4) — met live 2026-11-01 (docs/agents/qa/B15.md):** B15, M02 r2 and M09 r2 all merged before any field device runs onboarding or assist mode; offline onboarding push `[farmer, assist_session, consent, plot]` → 4 × accepted, replay → 4 × duplicate, online timeout then sync → one farmer
- [x] **G5 condition (rulings 2026-10-31b §1) — met live 2026-11-01 (docs/agents/qa/B16.md; P04 live-API run → WEB Verifier):** B16 and M11 r2 both merged before any field device runs QC intake; P04 live-API run needs B16
