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
_(empty)_

## 4. Reviewer and worker follow-ups
- [ ] W01: a native Tamil speaker should review `apps/public-page/agritrace_page/i18n/ta.json`.
- [ ] W03: the print stylesheet must open or expand the `<details>` timelines so printed pages are complete.
- [ ] W02: the schema's number checks skip http(s) URLs to avoid false hits on hashed evidence URLs; the built-output privacy lint is the second line of defence and must stay in CI.
- [ ] Q00: Robot `common.resource` DB_* defaults and CI `DATABASE_URL/REDIS_URL/S3_*` are guesses marked `TODO(B00)`; align with apps/api/.env.example after B00 merges.
- [ ] Q00: `doc-coverage.py` fails (not skips) when apps/mobile or apps/portal exist without Flutter/Node on PATH; M00 and P00 must add toolchain setup to the CI `docs` job.
- [ ] Q00: the Go AVD profile copies the hardware budget (2 GB, 2 cores) but does not enable Android Go low-RAM mode (`ro.config.low_ram`); BM-01 text says 4 cores, profile uses 2 (Q00 title wins).
- [ ] Q00: privacy-lint is line-based regex, biased to false positives; minified JSON hits report as line 1.
- [ ] D-018 wording: libraries-check rejects LGPL as copyleft (psycopg replaced by pg8000 in qa). Orchestrator to decide whether DECISIONS.md should name LGPL explicitly.
- [ ] B00: healthz returns raw error text to anonymous callers (may reveal internal hostnames); SEC review to decide whether to trim.
- [ ] B00/B01: Celery tasks run `asyncio.run` per task; the first DB task must dispose the engine or use NullPool (see DECISION D-009 comment in worker).
- [ ] W01: opted-out farmer names are a consent decision the schema cannot see; B10 must set `farmer_name` from consent and never change it afterwards.
- [ ] W01: 3-decimal pin rounding and "Farmer N" numbering currently cite D-017; write a small ADR (D-021 privacy rendering rules) when the product sign-off on rounding arrives.
- [ ] B10: keep lot order stable between rebuilds, because "Farmer N" numbering for opted-out farmers follows the order lots are sent.

## 5. Manual steps for the user
- [ ] Start Docker Desktop (needed for the compose stack and integration tests).
- [ ] Run `/plugin install ponytail@ponytail` in this project.
- [ ] Provide SMS/OTP provider credentials when moving past the console OTP sender.
- [ ] Record Tamil voice prompts (about 150 clips).
- [ ] Decide on the Datameet / Census 2011 sub-district file versus a surveyed GI boundary.
- [ ] Allow the `localstack/localstack` image to run if a permission prompt appears for the Verifier (replaces MinIO, D-008).
