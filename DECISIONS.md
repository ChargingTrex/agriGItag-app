# Decisions (ADR index)

Each decision records its advantages and compromises so future developers know why the code is the way it is.
Code that embodies a decision carries a `DECISION D-xxx` comment (grep for it). New decisions take the next number and a file in `docs/adr/`.

| ID | Title | Date | Status | File |
|---|---|---|---|---|
| D-001 | Python/FastAPI backend instead of NestJS | 2026-10-29 | Accepted | [D-001.md](docs/adr/D-001.md) |
| D-002 | Flutter + Material 3 for Android and iOS, 100 MB hard size ceiling, 30 MB download target | 2026-10-29 | Accepted | [D-002.md](docs/adr/D-002.md) |
| D-003 | Monorepo with clients generated from one OpenAPI contract | 2026-10-29 | Accepted | [D-003.md](docs/adr/D-003.md) |
| D-004 | Modular monolith: one Python package, two containers (api, worker) | 2026-10-29 | Accepted | [D-004.md](docs/adr/D-004.md) |
| D-005 | Append-only events with client-generated UUIDs as primary and idempotency keys | 2026-10-29 | Accepted | [D-005.md](docs/adr/D-005.md) |
| D-006 | Rules run on the phone as a preview and on the server as the authority, sharing one JSON rule bundle | 2026-10-29 | Accepted | [D-006.md](docs/adr/D-006.md) |
| D-007 | Static public page built by a worker job, served from object storage behind a CDN | 2026-10-29 | Accepted | [D-007.md](docs/adr/D-007.md) |
| D-008 | MinIO locally as the S3 stand-in with versioning and object lock | 2026-10-29 | Accepted | [D-008.md](docs/adr/D-008.md) |
| D-009 | Celery on Redis for background jobs | 2026-10-29 | Accepted | [D-009.md](docs/adr/D-009.md) |
| D-010 | Ponytail ruleset plus the Documentation Standard | 2026-10-29 | Accepted | [D-010.md](docs/adr/D-010.md) |
| D-011 | Single presigned PUT for photos, no resumable upload in the pilot | 2026-10-29 | Accepted | [D-011.md](docs/adr/D-011.md) |
| D-012 | Schema-first: one initial migration before module agents start | 2026-10-29 | Accepted | [D-012.md](docs/adr/D-012.md) |
| D-013 | Riverpod and go_router in the Flutter app | 2026-10-29 | Accepted | [D-013.md](docs/adr/D-013.md) |
| D-014 | One Entries/event_versions table with typed JSON payloads, on phone and server | 2026-10-29 | Accepted | [D-014.md](docs/adr/D-014.md) |
| D-015 | Standards Profiles as versioned JSON interpreted by one generic grade engine | 2026-10-29 | Accepted | [D-015.md](docs/adr/D-015.md) |
| D-016 | Tamil and English voice and icons bundled in the app; everything else as downloadable bundles | 2026-10-29 | Accepted | [D-016.md](docs/adr/D-016.md) |
| D-017 | YAML-driven field and feature configuration with per-tenant overrides | 2026-10-29 | Accepted | [D-017.md](docs/adr/D-017.md) |
| D-018 | Library-first implementation with a dependency ledger | 2026-10-29 | Accepted | [D-018.md](docs/adr/D-018.md) |
| D-019 | GI region derived from open administrative boundaries with recorded provenance | 2026-10-29 | Accepted | [D-019.md](docs/adr/D-019.md) |
| D-020 | API versioning under /v1 with one-season backward compatibility | 2026-10-29 | Accepted | [D-020.md](docs/adr/D-020.md) |
