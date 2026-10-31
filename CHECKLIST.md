# AgriTrace — Checklist

Completion: 34 % (22/64 items)

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

- [ ] B00 — Scaffold + infra + test harness — wave 0 — worker: Opus (4 rounds) — reviewer: BE r1/r2 PASS-PENDING-STACK — verifier: PENDING (merged conditionally 2026-10-29; stack run blocked by Docker repair)
- [ ] Q00 — Harness: compose stack, seed, Go AVD profile (API 27, 2 GB, 2 cores, 720×1280), network sc — wave 0 — worker: Opus (4 rounds) — reviewer: QA Lead r1/r2/r3 FAIL, r4 closure — verifier: CONDITIONAL (Docker lines deferred; docs/agents/qa/Q00.md)
- [ ] **Gate G0 signed** (docs/agents/gates/G0.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G1 Contract

- [ ] B01 — Domain contracts (schema-first) — wave 1 — worker: Opus (2 rounds) — reviewer: Architect-Gate APPROVED-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [x] M00 — Skeleton: flavors, M3 theme + tokens, go_router role redirect, l10n en/ta, generated Dart  — wave 1 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 — verifier: PASS (docs/agents/qa/M00.md)
- [x] P00 — Skeleton, auth guard, generated client, MSW from spec, lint/test/e2e config — wave 1 — worker: Opus — reviewer: WEB PASS r1 — verifier: PASS (docs/agents/qa/P00.md)
- [x] W01 — `render(public_batch) -> (html, json)`, Jinja2 `batch.html.j2`, inline CSS < 12 KB, JS < 4 — wave 1 — worker: Opus (2 rounds) — reviewer: WEB r1 FAIL, r2 PASS — verifier: PASS (docs/agents/qa/W01.md)
- [ ] **Gate G1 signed** (docs/agents/gates/G1.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G2 Core backend

- [ ] B02 — Identity — wave 2 — worker: Opus (2 rounds) — reviewer: SEC FAIL r1 / PASS-PENDING-STACK r2 — verifier: PENDING (merged conditionally; integration tests deferred)
- [ ] B03 — Registry + PostGIS geo — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; PostGIS tests deferred)
- [ ] B04 — Notifications — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [ ] B05 — Quality + grade engine — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [x] M01 — Drift store + DAOs + migrations + schema test — wave 2 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 + r2 confirm — verifier: Orchestrator-run db suite PASS; Go-AVD timing → Q01
- [x] M04 — Capture kit: camera (no gallery), compress to long edge 1600 px at JPEG q≈80 stepping down — wave 2 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS; device checks → Q01
- [x] M05 — Farmer widget kit: FarmerButton, PictureCardGrid, BigStepper, NumberPad, StatusBadge, Voic — wave 2 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS (198); device checks → Q01
- [x] M06 — Auth & session: OTP auto-read, device binding, PIN for officer/QC, role routing, restore o — wave 2 — worker: Opus (2 rounds) — reviewer: SEC/MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS (264); device checks → Q01
- [x] W02 — `privacy_lint.py` (canary strings + regexes for phone/Aadhaar/survey/polygon/coordinate pr — wave 2 — worker: Opus — reviewer: WEB PASS r1 — verifier: PASS (docs/agents/qa/W02.md; BM-03 LCP 1530 ms, BM-16 565 ms)
- [ ] B06 — Events + sync push + evidence — wave 3 — worker: Opus (2 rounds) — reviewer: SEC PASS-PENDING-STACK — verifier: PENDING (merged conditionally; 17 integration tests deferred)
- [ ] B13 — Config-driven fields/features + masters + bulk import (from the gap analysis) — wave 3 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [x] M02 — Sync engine (outbox, triggers incl. reachability probe, timeouts 10 s/30 s, retry only on  — wave 3 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / PASS r2 — verifier: Orchestrator-run suite PASS (401); device/network runs → Q01 (BM-11..15); server half of the r2 line → Verifier with B15
- [x] M03 — Ref data + local preview rules (GI point-in-polygon + buffer, yield 20/30, event order, mo — wave 3 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 + r2 confirm — verifier: Orchestrator-run rules suite PASS (63/63 parity)
- [ ] P01 — Members: approvals, roster, farmer/plot detail with MapLibre/OSM + GI outline — wave 3 — worker: Opus (2 rounds) — reviewer: WEB PASS r1 + r2 confirm — verifier: PENDING (acceptance line 'masked phone + audited reveal' waits on B14; live API deferred)
- [ ] P03 — Ready lots → Create batch: tick, running total, share %, greyed lots with reason, non-GI t — wave 3 — worker: Opus (2 rounds) — reviewer: WEB FAIL r1 / r2 Orchestrator confirm — verifier: PENDING (merged 2026-10-31; 77 Vitest green on main; live API deferred)
- [ ] B14 — Registry API gaps found by the portal (phone_masked + audited reveal, reject, farmer plots, village filter/search, FPO bbox) — wave 4 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [ ] B07 — Reference bundle + sync pull — wave 4 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK r1 + r2 confirm — verifier: PENDING (merged conditionally 2026-10-31; 7 integration tests deferred)
- [ ] B08 — Rules & flags — wave 4 — worker: Opus (2 rounds) — reviewer: BE FAIL r1 / r2 confirmed by Orchestrator — verifier: PENDING (merged conditionally 2026-10-31; 14 integration tests deferred)
- [x] M07 — Farmer home + 8 events (F03–F09, F16, F17), out-of-order prompt, lot readiness — wave 4 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 Orchestrator confirm — verifier: suite PASS (605) on the merged branch; device checks (< 20 s log, camera, GPS) → Q01
- [ ] P02 — Flags & plot review — wave 4 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 + micro-patch confirm — verifier: PENDING (merged 2026-10-31; 57 Vitest green; live API deferred)
- [ ] P04 — Batch detail, approve grading, publish, preview iframe, grey-button reasons — wave 4 — worker: Opus (2 rounds) — reviewer: WEB FAIL r1 / r2 Orchestrator confirm — verifier: PENDING (merged 2026-10-31; Vitest green on main; live API and D-041 server side deferred)
- [ ] **Gate G2 signed** (docs/agents/gates/G2.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G3 Mobile core

- [ ] B09 — Lots, intake, batches, gates — wave 5 — worker: Opus (2 rounds) — reviewer: BE FAIL r1 / PASS-PENDING-STACK r2 — verifier: PENDING (merged conditionally 2026-10-31; 8 integration tests deferred)
- [ ] B15 — Backend gaps from B08 review and M09 (grading-loss split D-030, `farmer` push kind + `client_id` D-031, assist_session kind D-032) — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PENDING (merged conditionally 2026-10-31; 22 integration tests deferred)
- [ ] B16 — QC intake via sync (`lot_intake` push kind, `POST /intakes` for QC, processor default, moisture gate at intake; D-040), non-GI holds (D-041), assist_session_id per kind (D-042) — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE/SEC PASS-PENDING-STACK r1 — verifier: PENDING (merged conditionally 2026-10-31; 9 integration tests deferred)
- [x] M08 — Sell QR, Money, History + Undo, Settings — wave 5 — worker: Opus (1 round + 2 micro-patches) — reviewer: MOB PASS r1 — verifier: Orchestrator-run suite PASS (660 on main); device checks → Q01
- [x] M09 — Officer onboarding wizard (9 steps, consent audio, GPS ring, acre/cent stepper, boundary w — wave 5 — worker: Opus (2 rounds + micro-patch) — reviewer: MOB FAIL r1 / PASS r2 — verifier: Orchestrator-run suite (post-merge); device checks → Q01
- [x] M10 — Officer home, assist mode, flags, moisture reading — wave 5 — worker: Opus (2 rounds) — reviewer: MOB/SEC FAIL r1 / r2 Orchestrator confirm — verifier: Orchestrator-run suite PASS (724 on main); device checks → Q01
- [x] M11 — QC mode: scan, intake checks, grading form from profile, grade preview, final packing, BLE — wave 5 — worker: Opus (2 rounds + micro-patch) — reviewer: MOB FAIL r1 / r2 one P2, patch confirmed by Orchestrator — verifier: Orchestrator-run suite PASS (779 on main); device checks → Q01; live lot_intake push → Verifier with B16
- [ ] P05 — Labels PDF + CSV exports (unit column FR58) — wave 5 — worker: Opus (in progress 2026-10-31) — reviewer: — verifier:
- [ ] P06 — Dashboard + FPO settings. Dashboard = stage-progress tiles (Land prep, Nursery, Sowing, In — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS r1 — verifier: PENDING (merged 2026-10-31; 120 Vitest green on main; live API, correction reason (B11) and opt-out preview (B03 route) deferred)
- [ ] P08 — Master data uploads: CSV import for farmers, villages, inputs with template download, dry- — wave 5 — worker: Opus (1 round + micro-patch) — reviewer: WEB PASS-PENDING-STACK r1 — verifier: PENDING (merged 2026-10-31; 87 Vitest green on main; live API deferred)
- [ ] **Gate G3 signed** (docs/agents/gates/G3.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G4 Portal + Publish

- [ ] B10 — Publishing — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE/SEC PASS-PENDING-STACK r1 — verifier: PENDING (merged conditionally 2026-10-31; 8 integration tests deferred)
- [ ] B11 — Reporting + stubs — wave 6 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PENDING (merged conditionally 2026-10-31; 11 integration tests deferred)
- [ ] M12 — Notifications + deep links (FCM/APNs, local reminders from calendar bundle) — wave 6 — worker: Opus (round 2 in progress) — reviewer: MOB FAIL r1 (P1: licence row; P2: "No" ignored on Android 8–12) — verifier:
- [ ] W03 — Tamil/English labels, print CSS, OG tags (no personal data), unpublished/404 variant, stat — wave 6 — worker: Opus (1 round) — reviewer: WEB PASS r1 — verifier: PENDING (merged 2026-10-31; 76 pytest + privacy lint + html-validate green; Lighthouse 3G re-run and print dialogs deferred)
- [ ] **Gate G4 signed** (docs/agents/gates/G4.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G5 Pilot candidate

- [ ] B12 — Demo seed, e2e, client generation — wave 7 — worker: Opus (1 round + micro-patch) — reviewer: BE PASS-PENDING-STACK r1 — verifier: PENDING (merged conditionally 2026-10-31; e2e, make seed and integration tests deferred to the stack)
- [ ] M13 — Hardening & release: low-storage purge, background sync proof, in-app update, size budget, — wave 7 — worker: — reviewer: — verifier:
- [ ] P07 — Playwright e2e chain + axe — wave 7 — worker: Opus (in progress 2026-10-31) — reviewer: — verifier:
- [ ] Q01 — Flutter verification: widget/golden/integration on Go + API 34 AVDs, offline/online matrix — wave 7 — worker: — reviewer: — verifier:
- [ ] Q02 — Portal verification: Vitest ≥ 80 % in features, Playwright chain, axe — wave 7 — worker: — reviewer: — verifier:
- [ ] Q03 — Public page verification: W02 suite + backend-down serve from MinIO + old version retrieva — wave 7 — worker: — reviewer: — verifier:
- [ ] Q04 — Backend verification: full pytest incl. e2e reference batch, locust p95, Schemathesis fuzz — wave 7 — worker: — reviewer: — verifier:
- [ ] Q05 — Release gate: benchmark sweep → `docs/agents/qa/benchmarks.json`, rubric, G5 report — wave 7 — worker: — reviewer: — verifier:
- [ ] **Gate G5 signed** (docs/agents/gates/G5.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)
- [ ] **G5 condition (rulings 2026-10-31 §4):** B15, M02 r2 and M09 r2 all merged before any field device runs onboarding or assist mode; offline onboarding push `[farmer, assist_session, consent, plot]` → 4 × accepted, replay → 4 × duplicate, online timeout then sync → one farmer
- [ ] **G5 condition (rulings 2026-10-31b §1):** B16 and M11 r2 both merged before any field device runs QC intake; P04 live-API run needs B16
