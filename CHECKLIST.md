# AgriTrace — Checklist

Completion: 19 % (11/59 items)

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
- [ ] B04 — Notifications — wave 2 — worker: — reviewer: — verifier:
- [ ] B05 — Quality + grade engine — wave 2 — worker: Opus (2 rounds) — reviewer: BE PASS-PENDING-STACK — verifier: PENDING (merged conditionally; integration tests deferred)
- [x] M01 — Drift store + DAOs + migrations + schema test — wave 2 — worker: Opus (2 rounds) — reviewer: MOB PASS r1 + r2 confirm — verifier: Orchestrator-run db suite PASS; Go-AVD timing → Q01
- [ ] M04 — Capture kit: camera (no gallery), compress to long edge 1600 px at JPEG q≈80 stepping down — wave 2 — worker: — reviewer: — verifier:
- [x] M05 — Farmer widget kit: FarmerButton, PictureCardGrid, BigStepper, NumberPad, StatusBadge, Voic — wave 2 — worker: Opus (2 rounds) — reviewer: MOB FAIL r1 / r2 confirm — verifier: Orchestrator-run suite PASS (198); device checks → Q01
- [ ] M06 — Auth & session: OTP auto-read, device binding, PIN for officer/QC, role routing, restore o — wave 2 — worker: — reviewer: — verifier:
- [ ] W02 — `privacy_lint.py` (canary strings + regexes for phone/Aadhaar/survey/polygon/coordinate pr — wave 2 — worker: Opus — reviewer: WEB PASS r1 (executed acceptance) — verifier: PENDING (merged conditionally)
- [ ] B06 — Events + sync push + evidence — wave 3 — worker: — reviewer: — verifier:
- [ ] B13 — Config-driven fields/features + masters + bulk import (from the gap analysis) — wave 3 — worker: — reviewer: — verifier:
- [ ] M02 — Sync engine (outbox, triggers incl. reachability probe, timeouts 10 s/30 s, retry only on  — wave 3 — worker: — reviewer: — verifier:
- [ ] M03 — Ref data + local preview rules (GI point-in-polygon + buffer, yield 20/30, event order, mo — wave 3 — worker: — reviewer: — verifier:
- [ ] P01 — Members: approvals, roster, farmer/plot detail with MapLibre/OSM + GI outline — wave 3 — worker: — reviewer: — verifier:
- [ ] P03 — Ready lots → Create batch: tick, running total, share %, greyed lots with reason, non-GI t — wave 3 — worker: — reviewer: — verifier:
- [ ] B07 — Reference bundle + sync pull — wave 4 — worker: — reviewer: — verifier:
- [ ] B08 — Rules & flags — wave 4 — worker: — reviewer: — verifier:
- [ ] M07 — Farmer home + 8 events (F03–F09, F16, F17), out-of-order prompt, lot readiness — wave 4 — worker: — reviewer: — verifier:
- [ ] P02 — Flags & plot review — wave 4 — worker: — reviewer: — verifier:
- [ ] P04 — Batch detail, approve grading, publish, preview iframe, grey-button reasons — wave 4 — worker: — reviewer: — verifier:
- [ ] **Gate G2 signed** (docs/agents/gates/G2.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G3 Mobile core

- [ ] B09 — Lots, intake, batches, gates — wave 5 — worker: — reviewer: — verifier:
- [ ] M08 — Sell QR, Money, History + Undo, Settings — wave 5 — worker: — reviewer: — verifier:
- [ ] M09 — Officer onboarding wizard (9 steps, consent audio, GPS ring, acre/cent stepper, boundary w — wave 5 — worker: — reviewer: — verifier:
- [ ] M10 — Officer home, assist mode, flags, moisture reading — wave 5 — worker: — reviewer: — verifier:
- [ ] M11 — QC mode: scan, intake checks, grading form from profile, grade preview, final packing, BLE — wave 5 — worker: — reviewer: — verifier:
- [ ] P05 — Labels PDF + CSV exports (unit column FR58) — wave 5 — worker: — reviewer: — verifier:
- [ ] P06 — Dashboard + FPO settings. Dashboard = stage-progress tiles (Land prep, Nursery, Sowing, In — wave 5 — worker: — reviewer: — verifier:
- [ ] P08 — Master data uploads: CSV import for farmers, villages, inputs with template download, dry- — wave 5 — worker: — reviewer: — verifier:
- [ ] **Gate G3 signed** (docs/agents/gates/G3.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G4 Portal + Publish

- [ ] B10 — Publishing — wave 6 — worker: — reviewer: — verifier:
- [ ] B11 — Reporting + stubs — wave 6 — worker: — reviewer: — verifier:
- [ ] M12 — Notifications + deep links (FCM/APNs, local reminders from calendar bundle) — wave 6 — worker: — reviewer: — verifier:
- [ ] W03 — Tamil/English labels, print CSS, OG tags (no personal data), unpublished/404 variant, stat — wave 6 — worker: — reviewer: — verifier:
- [ ] **Gate G4 signed** (docs/agents/gates/G4.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)

## G5 Pilot candidate

- [ ] B12 — Demo seed, e2e, client generation — wave 7 — worker: — reviewer: — verifier:
- [ ] M13 — Hardening & release: low-storage purge, background sync proof, in-app update, size budget, — wave 7 — worker: — reviewer: — verifier:
- [ ] P07 — Playwright e2e chain + axe — wave 7 — worker: — reviewer: — verifier:
- [ ] Q01 — Flutter verification: widget/golden/integration on Go + API 34 AVDs, offline/online matrix — wave 7 — worker: — reviewer: — verifier:
- [ ] Q02 — Portal verification: Vitest ≥ 80 % in features, Playwright chain, axe — wave 7 — worker: — reviewer: — verifier:
- [ ] Q03 — Public page verification: W02 suite + backend-down serve from MinIO + old version retrieva — wave 7 — worker: — reviewer: — verifier:
- [ ] Q04 — Backend verification: full pytest incl. e2e reference batch, locust p95, Schemathesis fuzz — wave 7 — worker: — reviewer: — verifier:
- [ ] Q05 — Release gate: benchmark sweep → `docs/agents/qa/benchmarks.json`, rubric, G5 report — wave 7 — worker: — reviewer: — verifier:
- [ ] **Gate G5 signed** (docs/agents/gates/G5.md: acceptance green, /ponytail-audit no P1, Robot suites green, LIBRARIES.md in sync, error-codes.md regenerated)
