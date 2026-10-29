# TODO

Four sections. The Orchestrator keeps this file current; reviewers and `/ponytail-debt` append.

## 1. Deferred scope (out of the pilot, in the PRD)
- [ ] Partner API and webhooks (FR33–FR41): `partner_api` module returns 501 `not_implemented_pilot`.
- [ ] Producer Benefit Records (FR37) and the farmer "Money" screen's benefit list (stub list in pilot).
- [ ] IoT storage probes and MQTT intake (FR45 sensors, FR52): `storage_monitoring` stub; Mosquitto runs but nothing consumes.
- [ ] WhatsApp and IVR voice call-backs for feature-phone farmers: `SmsProvider` protocol stub, console provider only.
- [ ] Multi-state localisation beyond Tamil + English: voice packs on demand (D-016).
- [ ] Bluetooth moisture meter pairing in the QC app (manual entry in pilot).
- [ ] Resumable (multipart) photo upload (D-011) when photo size or failure rates justify it.
- [ ] TimescaleDB for sensor data if volume demands (Architecture doc).
- [ ] FPO accounting (Tally) import for payment status.
- [ ] Blockchain anchoring (PRD §8 out of scope; the Virudhai GI page markets "blockchain-based"; pilot answer is append-only audit + S3 Object Lock).
- [ ] SHG / producer groups: `producer_groups` table exists behind `features.yaml: producer_groups=false`.

## 2. Open questions (carried from the source documents and planning)
- [ ] Build on or migrate data from the existing GITrace records, or start fresh? (Architecture doc)
- [ ] Who records the Tamil voice prompts; how many languages at launch? Pilot ships placeholder clips.
- [ ] Which SMS/WhatsApp/IVR provider, and who pays per message?
- [ ] Which crops' GI outlines to digitise first, from which official source?
- [ ] Does an FPO need iPhone support at launch? (Both platforms are built; release decision open.)
- [ ] Payment data source and format for the farmer's Money screen.
- [ ] Minimum Android version and phone (proposed Android 8, 2 GB; the app targets Android 8+).
- [ ] GI 883 taluk list: confirm from GI Journal No. 200 before `gi_region_versions` v1 is marked usable (D-019). Working list: Sattur, Aruppukottai, Tiruchuli.
- [ ] Coordinate rounding on the public map link (3 dp ≈ 100 m): product/privacy sign-off needed.
- [ ] Replace illustrative numbers before go-live: yield ceiling 1,000 kg/acre, 5 % reconciliation threshold, AGMARK parameters marked `load_from_standard`, the 4G test profiles in `qa/robot/profiles.yaml`.

## 3. Debt ledger (from `shortcut:` comments; refreshed by /ponytail-debt)
- [ ] B03 `registry/service.py` `create_farmer`: farmer code is `F` + 6 random hex per FPO (a collision is a 500 on UNIQUE(fpo_id, code)); switch to a per-FPO sequence before an FPO passes ~1,000 farmers.
- [ ] B03 `registry/service.py` `_check_region`: plots do not store their GI tag; a request without `gi_tag_id` uses the only GI tag that has a region. Add `plots.gi_tag_id` (B13 migration) before a second GI crop is onboarded.

## 4. Reviewer and worker follow-ups
- [ ] W01: a native Tamil speaker should review `apps/public-page/agritrace_page/i18n/ta.json`.
- [ ] W03: the print stylesheet must open or expand the `<details>` timelines so printed pages are complete.
- [ ] W02: the schema's number checks skip http(s) URLs to avoid false hits on hashed evidence URLs; the built-output privacy lint is the second line of defence and must stay in CI.
- [ ] Q00: Robot `common.resource` DB_* defaults and CI `DATABASE_URL/REDIS_URL/S3_*` are guesses marked `TODO(B00)`; align with apps/api/.env.example after B00 merges.
- [ ] Q00: `doc-coverage.py` fails (not skips) when apps/mobile or apps/portal exist without Flutter/Node on PATH; M00 and P00 must add toolchain setup to the CI `docs` job.
- [ ] Q00: the Go AVD profile copies the hardware budget (2 GB, 2 cores) but does not enable Android Go low-RAM mode (`ro.config.low_ram`); BM-01 text says 4 cores, profile uses 2 (Q00 title wins).
- [ ] Q00: privacy-lint is line-based regex, biased to false positives; minified JSON hits report as line 1.
- [ ] D-018 wording: libraries-check rejects LGPL as copyleft (psycopg replaced by pg8000 in qa). Orchestrator to decide whether DECISIONS.md should name LGPL explicitly.
- [x] B00: healthz error text trimmed to exception class names (round 3).
- [ ] B00/B01: Celery tasks run `asyncio.run` per task; the first DB task must dispose the engine or use NullPool (see DECISION D-009 comment in worker).
- [ ] W01: opted-out farmer names are a consent decision the schema cannot see; B10 must set `farmer_name` from consent and never change it afterwards.
- [ ] W01: 3-decimal pin rounding and "Farmer N" numbering currently cite D-017; write a small ADR (D-021 privacy rendering rules) when the product sign-off on rounding arrives.
- [ ] B10: map `agritrace_page` `ValidationError` to a registered AppError (`public_record_invalid`, 409) so privacy rejections are visible, never silent.
- [ ] B06: `events.make_variants` records width and height per variant and keeps the original JPEG URL (public page schema expects `thumb_url`, `medium_url`, `jpeg_url`, `width`, `height`).
- [ ] W01 P3s for W03: rarer phone formats (`0091 98765 43210`, `(987) 654-3210`, `98765.43210`, zero-width space) rely on the shared privacy linter; polygon pattern lost its word boundary (rejects "Polygonum"); phone pattern also scans system ids; pin `boundary_map_url` host once B07/B13 fix the GI asset host.
- [ ] Q00/W02 (P2, do first in W02): OSM map links with 6-dp coordinates slip the linter (`?mlat=…&mlon=…`, `#map=17/lat/lon`), issue docs/agents/qa/issues/Q00-1-privacy-lint-osm-map-coordinates.md (one-token fix: drop the `\b` before lat/lon and add the slash form). Also degree-sign, DMS and bare space-separated pairs outside WKT (Q00-r2 P2-3).
- [ ] Q00: gate-readiness is silent for a WP with no Robot tests at all; a survey number under a neutral JSON key (e.g. `land_record_ref`) passes the linter; `hw.keyboard=yes` on the Go AVD still open.
- [ ] B00 (before B02 merges): fail-open dev defaults for OTP code and JWT secret are being removed in B00 round 3; B02 must not reintroduce them.
- [ ] B00: Celery `acks_late` and the per-process engine disposal are owned by B04 (first module with real tasks).
- [ ] Orchestration deviation record: Q00 received a third review round (two-round rule) because the round-2 reviewer supplied exact regex fixes for two regressions; B00 received a third worker round before verification to clear six security-relevant P2s. Both noted in docs/agents/gates/G0.md when signed.
- [ ] G1 readiness: W01 merged with 6 Robot placeholder tests (public/page.robot ×5, BM-16); W02/Q03 must write them before G1 is signed (gate-readiness.py G1 enforces).
- [ ] B00 (before first prod deploy): pass S3 keys only when set so an IAM role can be used (review B00-r1 P3-5); enforce a router tag per module (P3-6); let `AppError` carry headers so 429 can send `Retry-After`.
- [ ] B06: request size cap for `/v1/sync/push` (256 KB) and 413 `payload_too_large` mapping.
- [ ] B10: use a real key prefix for `storage.put_public` (`public-pages/batches/<code>/…`).
- [ ] Ledger note: `certifi` and `pathspec` are MPL-2.0 transitive dependencies (file-level copyleft, unmodified use; accepted, record in LIBRARIES.md when they appear as direct deps).
- [ ] B02: treat `OTP_DEV_CODE` None/empty as "off"; never add a code default (B00 r2 P3-1).
- [ ] Q00 (W02 owner): `t.me/+91…` links stay masked; a phone number in a non-WhatsApp URL path stays masked (X17, by decision); two fail-closed false positives (`Pest survey: 3 traps checked`, `Mobile app build 1500`); privacy-lint.py is ~400 lines and should be split when W02 touches it. (Done in r4: `.jsonl/.yaml/.vcf/.map`, `R.S./T.S. No.`, `&ndash;`/U+2212.)
- [ ] P00: `apps/portal/ci-job.yml` must be pasted under `jobs:` in `.github/workflows/ci.yml` (Orchestrator, at merge).
- [ ] B12: `make clients` must call `npm run gen:api` (writes `apps/portal/src/api/generated/schema.d.ts`) and the Dart generator.
- [ ] P00/B02: portal token storage is sessionStorage (`shortcut:` comment); upgrade path is an httpOnly refresh cookie once B02 decides.
- [ ] Infra: no `portal` service in docker-compose yet; production must serve the portal and `/v1` from one origin (CORS/cookie decision with B02).
- [ ] Ledger: `lightningcss` (Vite build dependency) is MPL-2.0, build-time only, not shipped; accepted under D-018 as file-level copyleft in unmodified use (same reasoning as certifi/pathspec).
- [ ] B09: enforce Σ `batch_shares.share_pct` = 100 ± 0.01 in the service (spans rows; not a CHECK).
- [ ] B02: replace `core/auth.get_current_user` placeholder body and call `set_audit_context` per request.
- [ ] B06/B07: map SQLSTATE 23001 (`append_only_violation` trigger) to the registered AppError.
- [ ] B01 risk: first live `alembic check` may show drift on geography reflection, VARCHAR enums or NULLS NOT DISTINCT; fix model or migration, never env.py. `alembic check` ignores CHECK constraints (enum values pinned by unit test instead).
- [ ] Tests on append-only tables cannot DELETE; use fresh rows or TRUNCATE.
- [x] M00 size gate decision: the "15 MB at skeleton" acceptance line was indicative; binding budgets are 40 MB target / 100 MB ceiling (arm64 APK) and 30 MB per-ABI AAB download. Native libs stay uncompressed (installed size matters on 2 GB phones). Skeleton measured 14.68 MiB arm64 (7.06 MB gzipped).
- [ ] M13: choose a crash-reporting vendor and plug it into the `_report` seam in `apps/mobile/lib/bootstrap.dart`.
- [ ] Orchestrator at merge: move `apps/mobile/ci-job.yml` and `apps/portal/ci-job.yml` into `.github/workflows/ci.yml` (replace the Q00 stubs) and delete the files.
- [ ] M05: consider a bold Tamil weight in the subset font.
- [ ] M00 risk: goldens recorded on macOS; if the first Linux CI run fails, regenerate goldens on Linux rather than raising tolerance. `gen_api.sh` needs network (npx + generator download) in CI.
- [ ] Dev machine: Android cmdline-tools missing and SDK licences unaccepted; system Java is 1.8 (Android Studio JDK 21 via JAVA_HOME works). Not needed for CI.
- [ ] B06/B07 (B01 review F1): `GET /v1/sync/reference?since=` must compare versions per part, because one global sequence number is not commit-ordered; a part can be missed until it changes again.
- [ ] B06/B07 (F4): the sync write path uses Core `INSERT … ON CONFLICT`, which the ORM audit listener does not see; those writes must insert audit rows explicitly.
- [ ] Compliance (F5, DPDP Act 2023): append-only tables need an erasure runbook for valid deletion requests; the API's database role must not own the tables (so it cannot disable triggers); consider redacting phone, plot pin and survey number from audit diffs. Owner: SEC review before G5.
- [x] B03 (F7, Architect-Gate ruling): create a `users` row for every farmer who has a phone, including feature-phone farmers, so the phone has exactly one home.
- [x] B01 r2 / B03 (F8): the shared `Address` schema needs a `taluk` field for FR53's taluk check.
- [ ] B10: keep lot order stable between rebuilds, because "Farmer N" numbering for opted-out farmers follows the order lots are sent.
- [ ] B03 → Architect-Gate (D-019 wording): the Datameet maps repo has no sub-district layer (only Census 2011 districts) and Datameet village boundaries skip Tamil Nadu; open Census-2011 taluk files found are CC BY-NC-SA (rejected) or restricted. `infra/scripts/gi_boundary/README.md` therefore recommends geoBoundaries gbOpen IND ADM3 + ADM2 (ODbL-1.0, LGD-derived, commit 9469f09); measured v0 40.7 KB / v1 33.1 KB, reference point inside both. Amend D-019's source sentence, and decide the ODbL attribution line on the public page (B10).
- [ ] B03 → B06: the sync push `plot` entry kind should reuse `registry.service.create_plot` + `enqueue_plot_check` (after the per-entry commit); `create_plot` takes the registry `PlotIn` schema, which other modules may not import (D-004), so B06 needs a service entry that accepts the entry's dict (add it to `service.__all__` then).
- [ ] B03 → B08: `rules.check_plot` owns the checks the plot API does not do: GPS accuracy threshold (FR67 "acceptable accuracy"), farmer/plot taluk vs `gi_region_versions.taluks` (FR53 second GI check), the walked-vs-declared gap flag (the API only reports `area_gap_exceeds`).
- [ ] B03 product question: FR67 says a confirmed location activates the farmer; the pilot activates only on `POST /v1/farmers/{id}/approve` (Stage 0 "admin approval plus confirmed location"). Decide whether approval should also require a confirmed plot.
- [ ] B03 → B02: `CurrentUser` carries no super-admin flag, so the registry reads `users.is_super_admin` per super-admin call; if B02 adds it to the token, switch `registry.service._is_super_admin` to it.
- [ ] B03: the plot API does not return the walked outline (internal only) and a correction cannot remove a walked boundary; concurrent first inserts of one plot `client_id` surface as 500 (IntegrityError) instead of a duplicate (rare; sync retries are sequential per device).
- [ ] B03: integration tests `apps/api/tests/integration/test_registry.py` were written but not run (Docker daemon down); the Verifier runs them with `make test`.

## 5. Manual steps for the user
- [ ] Start Docker Desktop (needed for the compose stack and integration tests).
- [ ] Run `/plugin install ponytail@ponytail` in this project.
- [ ] Provide SMS/OTP provider credentials when moving past the console OTP sender.
- [ ] Record Tamil voice prompts (about 150 clips).
- [ ] Decide on the Datameet / Census 2011 sub-district file versus a surveyed GI boundary.
- [ ] Allow the `localstack/localstack` image to run if a permission prompt appears for the Verifier (replaces MinIO, D-008).
