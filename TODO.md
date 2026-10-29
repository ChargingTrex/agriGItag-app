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

## 4. Reviewer follow-ups
_(empty)_

## 5. Manual steps for the user
- [ ] Start Docker Desktop (needed for the compose stack and integration tests).
- [ ] Run `/plugin install ponytail@ponytail` in this project.
- [ ] Provide SMS/OTP provider credentials when moving past the console OTP sender.
- [ ] Record Tamil voice prompts (about 150 clips).
- [ ] Decide on the Datameet / Census 2011 sub-district file versus a surveyed GI boundary.
