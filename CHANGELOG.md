# Changelog

All notable changes to AgriTrace are recorded here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
One line per merged work package: `WP-id — title — reviewer PASS rN, verifier PASS`.

## [Unreleased]

### Added
- Project scaffold: CLAUDE.md, README, tracking files, ADRs D-001 to D-020, agent role docs, acceptance files for 42 work packages (Orchestrator, 2026-10-29).
- WP-W01 — public page renderer `agritrace_page` (schema with privacy validator, Jinja2 template, CLI, 48 tests) — reviewer FAIL r1 / PASS r2, verifier PASS (2026-10-29).
- WP-B00 — Scaffold + infra + test harness (FastAPI app, core kernel, compose stack, Makefile, error registry, conventions) — reviewer r1/r2 PASS-PENDING-STACK, merged conditionally; verifier deferred until Docker repair (2026-10-29).
- WP-Q00 — QA harness: Robot suites (api/mobile/portal/public/e2e), Go + API 34 AVD profiles, emulator network script, privacy-lint, doc-coverage, libraries-check, benchmark collector, CI workflow, pre-commit — reviewer r1/r2/r3 FAIL closed by r4 patch (Orchestrator closure note), verifier CONDITIONAL (Docker lines deferred) (2026-10-29).
- WP-W02 — public page validators and CI gates: privacy-lint catches OSM `mlat/mlon` and `#map=z/lat/lon`, degree, DMS and space-separated coordinates (Q00-1, Q00-r2 P2-3); canary check `tools/check_output.sh`; html-validate; Lighthouse CI 3G (BM-03) and normal 4G (BM-16); `public-page` CI job; real Robot public-page tests — reviewer pending, verifier pending (2026-10-30).
- WP-B00 — Scaffold + infra + test harness (FastAPI app, core kernel, compose stack, Makefile, error registry, conventions) — reviewer pending, verifier pending.
- WP-P00 — Portal skeleton (Vite + React 18 + TS strict, MUI shell with 8 placeholder screens, OTP + PIN auth guard on MSW, generated openapi-fetch client + error-message table, cursor-list hook, lint/test/e2e config, 177.9 KB gz initial bundle) — reviewer PASS r1, verifier PASS (2026-10-29).
