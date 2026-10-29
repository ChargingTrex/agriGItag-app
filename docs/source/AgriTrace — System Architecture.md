# AgriTrace — System Architecture

Oct 29, 2026 · @Sathya

## Summary

AgriTrace is one offline-first mobile app (Flutter), one web portal (React) and a set of backend services (Node.js/TypeScript) on PostgreSQL with PostGIS, hosted in AWS Mumbai. Public traceability pages are pre-built static pages served from a CDN, so a QR scan loads almost instantly on 4G and keeps working even if the backend is down.

Three choices shape everything else:

- **Offline first.** The phone is the first place data lives. Every entry is saved on the device and synced later, because farms and godowns often have no signal.
- **Location is first-class data.** PostGIS stores pins, walked boundaries and GI regions, so the GI-region check, event-location check and taluk matching are database queries, not app code.
- **Evidence is immutable.** Photos and certificates go to versioned, write-once storage the moment they arrive; records are corrected by adding new versions, never by overwriting.

## System at a glance

&#91;embedded content: system architecture · 4 layers\]

The mobile app is the heart of the system: it works offline and syncs to the backend when it can. The public QR page is the one part that never touches the backend at scan time — it is a pre-built page served from the CDN.

## Tech stack

The stack favours tools a small Indian team can hire for and run cheaply, with every piece chosen to serve low-end phones and patchy networks.

| Layer | Choice | Why |
| --- | --- | --- |
| Mobile app | Flutter (Dart) | One codebase for Android and iOS; runs smoothly on 2 GB Android Go phones; full control over large-button, voice-first UI |
| On-phone database | SQLite via Drift | Stores every entry, photo reference and sync state offline |
| Web portal | React + TypeScript | FPO admin and partner screens; shares data types with the backend |
| Backend services | Node.js + TypeScript (NestJS) | Same language as the web portal; strong typing for validation rules |
| Main database | PostgreSQL + PostGIS | Relational data plus spatial queries for pins, boundaries and GI regions |
| Sensor data | PostgreSQL partitioned tables (TimescaleDB later if volume demands) | Storage-probe readings over time in the same database; Amazon RDS does not offer TimescaleDB, so moving to it is a later step only if needed |
| Evidence files | Amazon S3 with versioning and Object Lock | Photos, certificates and lab reports can't be silently changed or deleted |
| Public pages | Static HTML on S3 + CloudFront CDN | Fast QR scans anywhere; pages survive backend outages |
| Background jobs | Redis + BullMQ | Page building, notifications, rule checks off the request path |
| Device data in | MQTT broker (AWS IoT Core or EMQX) | Receives base-station uploads from godowns over TLS |
| Maps | OpenStreetMap tiles + satellite layer | Plot review and map pins without per-load map fees at scale |
| Messages | Indian SMS, WhatsApp Business and voice-call (IVR) provider | OTP, reminders, voice call-backs for feature-phone farmers |
| Hosting | AWS ap-south-1 (Mumbai) | Keeps data in India; low latency for Indian users |

## Offline-first mobile design

The app targets 4G: with signal, an entry and its photo reach the server within seconds of saving, and the farmer sees "Sent" almost at once. Offline saving stays because fields and godowns still have 4G dead zones.

Every entry is saved on the phone first, given a permanent ID there, and sent later by a background queue, so nothing a farmer records is lost to bad signal and nothing is recorded twice when a send is retried.

- **Permanent ID at creation:** each entry gets a unique ID on the phone. If the same entry arrives twice after a retry, the server keeps one.
- **Outbox queue:** entries sit in the on-phone database marked waiting, sent or confirmed. The grey cloud in the app is simply "anything still waiting".
- **Small first, photos second:** the entry's details (a few hundred bytes) are sent first; photos follow as resumable uploads straight to storage, so a dropped connection restarts where it stopped.
- **Photos made light:** compressed on the phone to about 300 KB before saving — sharp enough to serve as evidence, and a second or two to upload on 4G. Originals are not kept, which saves space on cheap phones.
- **Three clocks:** the phone time, the GPS time and the server's received time are all stored, so a phone with a wrong clock is detected.
- **Append-only facts:** farm events are never edited in place. Undo and corrections add a new version, so two devices can never overwrite each other.
- **Reference data travels to the phone:** the farmer's plots, the FPO's crop list, product pictures, voice prompts, Standards Profile limits and the GI region outline are downloaded as small versioned bundles. That is why the GI-region check and yield warning can show instantly, even with no signal.
- **Server has the final word:** every rule the phone runs is run again on the server; the phone's result is only a preview.
- **When it syncs:** on app open, right after each entry, when signal returns, and in the background every 15 minutes. An option holds photos until Wi-Fi for farmers with small data packs.

## Backend services

The backend starts as one deployable application split into clear modules (a "modular monolith"), which a small team can run and debug easily; any module that later needs to scale on its own can be split out without changing the others.

| Module | What it owns |
| --- | --- |
| Identity and access | Phone + SMS-code login; roles (farmer, field officer, QC officer, FPO admin, super-admin, partner); assist-mode sessions; consent records |
| Registry | Farmers, plots (pin, optional walked boundary, declared area, land-record reference), FPOs, processors, crops, GI tags and GI regions, input master list |
| Events | Farm and processing events with versions, photo links and sync endpoints for the app |
| Rules and flags | GI-region and event-location checks, yield ceiling with 20% / 30% margins, event-order checks, practice tags from inputs, quantity reconciliation; raises flags to field officers |
| Lots and batches | Lots, sales to processor, batch creation, each farmer's share, batch IDs and QR codes |
| Quality | Standards Profiles, quality readings, instruments and calibration dates, grade calculation |
| Storage monitoring | Probe and base-station registry, deployments to batches, sensor data intake, storage alerts |
| Publishing | Builds and updates the static public page and printable QR labels for each batch |
| Notifications | Push, SMS, WhatsApp and voice call-backs in the user's language |
| Partner API | Scoped access for marketplaces, FPO networks and government bodies; webhooks; producer benefit records |
| Reporting | FPO dashboards, audit exports, scan analytics |

## Data model

&#91;embedded content: data model · 6 core entities, 9 attached records\]

The left column is the backbone every query follows; the boxes on the right attach to one link of it. A lot can feed several batches and a batch draws on several lots, so the link between them is a share record holding each lot's kilograms and percentage.

## From farm event to public page

A farm event becomes part of a published page in nine steps; steps 1–4 happen for every event, steps 5–9 once per sale and batch.

1. **Capture:** the phone saves the entry with its ID, photo, GPS, accuracy and time, and puts it in the outbox.
2. **Receive:** the sync endpoint accepts the entry, ignores duplicates by ID, stores it, and hands back a one-time upload link for the photo.
3. **Store evidence:** the photo goes straight to write-once storage; its fingerprint (checksum) and the photo's own time and GPS are recorded and compared with the entry.
4. **Check:** a background job runs the rules — inside the plot, sensible order, practice tags from inputs — and raises flags to the field officer.
5. **Sale:** the QR scan at the collection centre records weight and intake moisture; reconciliation, the yield ceiling and the moisture limit run on the spot.
6. **Batch:** the FPO admin combines lots; the system works out each farmer's share and which lots qualify for the GI name.
7. **Grade:** quality readings are checked against the crop's Standards Profile, the grade is calculated, and the admin approves.
8. **Publish:** a job builds the batch's static page and its data file, uploads them under the batch ID, refreshes the CDN, and produces printable QR labels.
9. **Keep current:** later storage readings, partner sales or benefits add to the batch record; the page is rebuilt with a new version stamp and the old versions are kept.

## Security, privacy and consent

Farmer phone numbers, ID documents and exact plot locations are personal data under India's Digital Personal Data Protection Act, 2023, so they are collected with recorded consent, kept in India, and never appear on the public page or in partner data without a matching consent.

- **Login:** phone number plus one-time SMS code; the session stays on the phone and is tied to that device. Field officers and admins add a 4-digit PIN.
- **Roles:** every API call is checked against the user's role and FPO; an FPO can only see its own farmers. Assist mode is recorded on every entry it creates.
- **What the public page shows:** farmer name (unless the FPO opts out), village, farm size, practices, a map link and event photos. Never: phone, ID documents, survey number or exact boundary.
- **Consent:** stored per farmer with date, the recording played, and who witnessed it; partner data-sharing checks consent per partner and per data type.
- **Sensitive files:** ID proofs sit in a separate, encrypted bucket that only the registry module can read.
- **In transit and at rest:** TLS everywhere; database and storage encrypted; keys in AWS KMS.
- **Audit trail:** every change records who, when, from which device and location; nothing is hard-deleted except on a valid data-deletion request.
- **Devices:** storage probes and base stations use per-device keys and certificates (see the hardware plan).

## Hosting, scale and integrations

Everything runs on managed AWS services in Mumbai, sized small at launch; at the scale of 10,000 farmers the data is modest, so cost is driven by messages and storage, not computing power.

**Hosting**

- **Application:** containers on AWS ECS Fargate — one for the API, one for background jobs — with auto-scaling.
- **Database:** Amazon RDS for PostgreSQL with PostGIS, Multi-AZ, daily snapshots and point-in-time restore.
- **Queue and cache:** Amazon ElastiCache for Redis.
- **Files and pages:** S3 (evidence with Object Lock; public pages separately) behind CloudFront.
- **Device data:** AWS IoT Core for base-station MQTT uploads.
- **Environments:** development, staging (with seeded demo FPOs) and production.
- **Monitoring:** CloudWatch for servers; a crash-reporting tool in the mobile app to catch problems on low-end phones.

**Rough data size (illustrative, 10,000 farmers)**

- About 15 events per farmer per season with 1–2 photos each at about 300 KB: roughly 300,000 photos and 90 GB of photos per season.
- 1,000 storage probes reporting every 30 minutes: about 48,000 readings a day, about 17.5 million a year — well within a partitioned PostgreSQL table.

**Integrations**

| Integration | Direction | Purpose |
| --- | --- | --- |
| SMS, WhatsApp and voice-call provider | Out | Login codes, reminders, results, voice call-backs |
| Map tiles and satellite imagery | In | Plot review and map pins |
| GI region outlines | In (digitised by our team) | GI-region checks |
| Storage base stations | In (MQTT) | Godown and in-stack readings |
| Moisture meters | In (Bluetooth to the QC app) | Intake and grading moisture |
| Accredited labs | In (upload or API) | Lab certificates and readings |
| Marketplaces, FPO networks, government bodies | Both (Partner API and webhooks) | Traceability data out; sales, subsidies and premiums back in |
| FPO accounting (e.g. Tally export) | In (later phase) | Payment status for the farmer's Money screen |

## Open questions

- [ ] Will we build on or migrate data from the existing GITrace records the reference pages come from, or start fresh?
- [ ] Who records the Tamil voice prompts, and how many languages are needed at launch?
- [ ] Which SMS, WhatsApp and voice-call provider, and who pays per message — the FPO or AgriTrace?
- [ ] Which crops' GI region outlines do we digitise first, and from which official source?
- [ ] Does an FPO need iPhone support at launch, or is Android-only enough for the pilot?
- [ ] Will farmers' payments come from the FPO's accounting system, and in what format?
- [ ] What is the minimum Android version and phone we support (proposed: Android 8, 2 GB memory)?
