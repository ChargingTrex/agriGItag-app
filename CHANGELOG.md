# Changelog

All notable changes to AgriTrace are recorded here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
One line per merged work package: `WP-id — title — reviewer PASS rN, verifier PASS`.

## [Unreleased]

### Added
- Project scaffold: CLAUDE.md, README, tracking files, ADRs D-001 to D-020, agent role docs, acceptance files for 42 work packages (Orchestrator, 2026-10-29).
- WP-W01 — public page renderer `agritrace_page` (schema with privacy validator, Jinja2 template, CLI, 48 tests) — reviewer FAIL r1 / PASS r2, verifier PASS (2026-10-29).
- WP-B00 — Scaffold + infra + test harness (FastAPI app, core kernel, compose stack, Makefile, error registry, conventions) — reviewer r1/r2 PASS-PENDING-STACK, merged conditionally; verifier deferred until Docker repair (2026-10-29).
- WP-Q00 — QA harness: Robot suites (api/mobile/portal/public/e2e), Go + API 34 AVD profiles, emulator network script, privacy-lint, doc-coverage, libraries-check, benchmark collector, CI workflow, pre-commit — reviewer r1/r2/r3 FAIL closed by r4 patch (Orchestrator closure note), verifier CONDITIONAL (Docker lines deferred) (2026-10-29).
- WP-B00 — Scaffold + infra + test harness (FastAPI app, core kernel, compose stack, Makefile, error registry, conventions) — reviewer pending, verifier pending.
- WP-P00 — Portal skeleton (Vite + React 18 + TS strict, MUI shell with 8 placeholder screens, OTP + PIN auth guard on MSW, generated openapi-fetch client + error-message table, cursor-list hook, lint/test/e2e config, 177.9 KB gz initial bundle) — reviewer PASS r1, verifier PASS (2026-10-29).
- WP-B01 — Domain contracts, schema-first (39 SQLAlchemy models, migration 0001 with PostGIS, append-only and reference-version triggers, enums, audit listener, auth signatures, shared JSONB shapes) — reviewer pending, verifier pending (integration tests not yet run: Docker down). — Architect-Gate APPROVED-PENDING-STACK (r1 CHANGES-REQUIRED, r2 closure), merged conditionally; integration tests deferred (2026-10-29).
- WP-M00 — Flutter skeleton (M3 theme + FarmerTokens, FarmerButton with 56/64 dp goldens, go_router role redirect, ta/en gen-l10n, generated dart-dio client + dio wrapper, size/lint scripts, CI job) — reviewer PASS r1 (3 P2 fixed in r2), verifier PASS (2026-10-29).
- WP-M01 — Drift offline store (14 tables per mobile-design.md §2, append-only Entries triggers, 9 DAOs for save/outbox/media/sync/bundles/tasks/flags/config, schema v1 dump + verifier test, 18 tests incl. 500+500 insert timing) — reviewer pending, verifier pending.
