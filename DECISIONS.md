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
| D-008 | LocalStack locally as the S3 stand-in (amended from MinIO) | 2026-10-29 | Accepted | [D-008.md](docs/adr/D-008.md) |
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
| D-019 | GI region derived from open administrative boundaries (geoBoundaries ODbL, amended) with recorded provenance | 2026-10-29 | Accepted | [D-019.md](docs/adr/D-019.md) |
| D-020 | API versioning under /v1 with one-season backward compatibility | 2026-10-29 | Accepted | [D-020.md](docs/adr/D-020.md) |
| D-021 | Valkey instead of Redis for broker and cache | 2026-10-29 | Accepted | [D-021.md](docs/adr/D-021.md) |
| D-022 | Portal and API served from one origin | 2026-10-29 | Accepted | [D-022.md](docs/adr/D-022.md) |
| D-023 | Enum columns as VARCHAR(32) + CHECK, not PostgreSQL ENUM | 2026-10-29 | Accepted | [D-023.md](docs/adr/D-023.md) |
| D-025 | BM-03 "3G" means Lighthouse's built-in 3G preset | 2026-10-30 | Accepted | [D-025.md](docs/adr/D-025.md) |
| D-024 | Phone + OTP + PIN session model | 2026-10-29 | Accepted | [D-024.md](docs/adr/D-024.md) |
| D-026 | Drift stores dates as ISO-8601 text with ms precision | 2026-10-30 | Accepted | [D-026.md](docs/adr/D-026.md) |
| D-027 | Tokens live in the platform keystore, not in SQLite | 2026-10-30 | Accepted | [D-027.md](docs/adr/D-027.md) |
| D-028 | OTP auto-read via Android SMS User Consent prompt | 2026-10-31 | Accepted | [D-028.md](docs/adr/D-028.md) |
| D-029 | Offline outbox is per user on a shared phone | 2026-10-31 | Accepted | [D-029.md](docs/adr/D-029.md) |
| D-030 | Batch attribution (Σ shares vs received, 5 %) and grading loss (`grading_loss_high`, features.yaml limit) are separate warns | 2026-10-31 | Accepted | [D-030.md](docs/adr/D-030.md) |
| D-031 | Offline-registered farmers sync as a `farmer` push kind; `FarmerIn.client_id` makes REST and sync idempotent | 2026-10-31 | Accepted | [D-031.md](docs/adr/D-031.md) |
| D-032 | Assist context travels per sync entry (`assist_session` push kind + `SyncEntry.assist_session_id`), not only via the request header | 2026-10-31 | Accepted | [D-032.md](docs/adr/D-032.md) |
| D-033 | Lifecycle gates answer one 409 listing every unmet reason; gate records are append-only | 2026-10-31 | Accepted | [D-033.md](docs/adr/D-033.md) |
| D-034 | Public page publishing: W01 schema is the allow-list (page-required fields are public in YAML and no tenant may narrow them; tenant YAML hides optional fields only), WebP-only photo copies in public-pages, 60 s / immutable cache policy, Pillow labels | 2026-10-31 | Accepted | [D-034.md](docs/adr/D-034.md) |
| D-035 | Sell QR `sig` is an unkeyed SHA-256 checksum, not an HMAC; authenticity comes from the server's lot record | 2026-10-31 | Accepted | [D-035.md](docs/adr/D-035.md) |
| D-036 | QC mode records intake on the lot (offline) and grading / final packing on the batch (batch list online); the scan fallback is a ready-lot list, not a typed code | 2026-10-31 | Accepted | [D-036.md](docs/adr/D-036.md) |
| D-037 | Dashboard completeness and stage progress derived from live events and the crop's `event_schema` (complete = every mandatory type live; tile = furthest stage while in the field) | 2026-10-31 | Accepted | [D-037.md](docs/adr/D-037.md) |
| D-038 | Public scans: body-less `POST /v1/public/scans?batch_code=` (sendBeacon, no CORS), fixed 1-minute window per IP hash in Valkey, no IP stored | 2026-10-31 | Accepted | [D-038.md](docs/adr/D-038.md) |
| D-039 | Audit log viewer scoped to an FPO by ownership of the described row (`audit_log` has no `fpo_id`) | 2026-10-31 | Accepted | [D-039.md](docs/adr/D-039.md) |
| D-040 | QC phone receives a lot with push kind `lot_intake` (`IntakeIn`, QC officer or FPO admin, FPO's only processor by default, ready gate run at intake); `lot_intakes` stays the one intake record | 2026-10-31 | Accepted | [D-040.md](docs/adr/D-040.md) |
| D-041 | GI-only holds (`plot_outside_gi_region`, `yield_over_ceiling`) do not block the gates of a non-GI batch; every other hold still blocks | 2026-10-31 | Accepted | [D-041.md](docs/adr/D-041.md) |
| D-042 | Per-entry assist context applies only to entries about one farmer's records: lot readings checked, batch entries forbidden, officer-own kinds ignore it | 2026-10-31 | Accepted | [D-042.md](docs/adr/D-042.md) |
| D-043 | Farmer tap counts start at the chosen event; "Log" is navigation; the next-task card opens its lot | 2026-10-31 | Accepted | [D-043.md](docs/adr/D-043.md) |
| D-044 | Assist mode is a route scope over the farmer screens (`/assist/:farmerId`, guarded by the running session) with one app-level assist bar | 2026-10-31 | Accepted | [D-044.md](docs/adr/D-044.md) |
| D-045 | Public page W03: schematic inline-SVG district map with ~1 km village dots (no tiles, no pin); builder sends `public_url`/`qr_url` for OG and the print-only QR; `render_unavailable` page for unpublished/withdrawn/unknown codes; page default `lang="en"` with every Tamil string tagged | 2026-10-31 | Accepted | [D-045.md](docs/adr/D-045.md) |
| D-046 | Reminders are scheduled on the phone from the Tasks table (cancel all and reschedule on every change, tap opens `/log/<event>?lot=`); push is a no-op provider behind `push_notifications` until Firebase exists | 2026-10-31 | Accepted | [D-046.md](docs/adr/D-046.md) |
| D-047 | Portal reads import CSVs with a small in-house reader numbered like the server (`line_num`); no CSV library | 2026-10-31 | Accepted | [D-047.md](docs/adr/D-047.md) |
| D-048 | Demo seed writes the PRD §12 history by direct model inserts (audited models, system actor); only the batch goes through `create_batch` (fixed `client_id`), then reference codes, legacy grading "A" 20 kg and `graded_kg` are set; the batch (`BATCH_ID`) marks "already seeded", an existing bare FPO is reused | 2026-10-31 | Accepted | [D-048.md](docs/adr/D-048.md) |
| D-050 | Portal public page origin from `VITE_PUBLIC_BASE_URL`; preview iframe sandboxed, dev proxy in development; QR and labels fetched with the token | 2026-10-31 | Accepted | [D-050.md](docs/adr/D-050.md) |
| D-051 | Portal CSV exports written in the browser (BOM, formula guard, unit column per quantity, farmer-column allow-list); a lot's share of the final packed kg is derived (batch packed kg × share %) and labelled `final_packed_share_derived` | 2026-10-31 | Accepted | [D-051.md](docs/adr/D-051.md) |
| D-052 | Portal e2e chain: MSW mock mode in CI with the mock state exposed as `agritraceMock` so the chain plays the QC phone (grade); live mode (`E2E_LIVE=1`) on the B12 seed posts the QC grading over the API, skips batch creation and skips gates already passed; axe-core injected with `addScriptTag`, serious/critical fail | 2026-10-31 | Accepted | [D-052.md](docs/adr/D-052.md) |
| D-053 | M13 release config: no `deferred as` imports (Flutter splits them only with Play deferred components; Dart AOT globals are lazy); size relies on Flutter's default R8 + resource shrinking and AAB splits; free space for the "Phone is full" check from a 3-line `StatFs` method channel, no plugin | 2026-10-31 | Accepted | [D-053.md](docs/adr/D-053.md) |
| D-054 | Outbox strict FIFO: `nextBatch` stops at the first row still `sending` or not yet due, one backoff per failed batch; per-entry `not_found` / `assist_session_invalid` retried once like `stale_version` | 2026-11-01 | Accepted | [D-054.md](docs/adr/D-054.md) |
