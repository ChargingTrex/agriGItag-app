# Changelog

All notable changes to AgriTrace are recorded here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
One line per merged work package: `WP-id — title — reviewer PASS rN, verifier PASS`.

## [Unreleased]

### Added
- Project scaffold: CLAUDE.md, README, tracking files, ADRs D-001 to D-020, agent role docs, acceptance files for 42 work packages (Orchestrator, 2026-10-29).
- WP-W01 — public page renderer `agritrace_page` (schema with privacy validator, Jinja2 template, CLI, 48 tests) — reviewer FAIL r1 / PASS r2, verifier PASS (2026-10-29).
- WP-B00 — Scaffold + infra + test harness (FastAPI app, core kernel, compose stack, Makefile, error registry, conventions) — reviewer pending, verifier pending.
- WP-M00 — Flutter skeleton (M3 theme + FarmerTokens, FarmerButton with 56/64 dp goldens, go_router role redirect, ta/en gen-l10n, generated dart-dio client + dio wrapper, size/lint scripts, CI job) — reviewer pending, verifier pending.
