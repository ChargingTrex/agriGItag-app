# Product Requirements Document
## AgriTrace — Farm-to-Consumer Traceability Platform for GI-Tagged & Specialty Agri Produce

**Version:** 1.0 (Draft)
**Status:** Draft for review
**Reference basis:** Public traceability record analyzed at `gitrace.s3.amazonaws.com/traceability/FGP8T4033HM7.html` (dry chilli / Virudhunagar Samba Vathal, GI Tag #883)

---

## 1. Background & Problem Statement

GI-tagged and premium agricultural produce (spices, millets, rice varieties, etc.) in India is frequently sold without verifiable proof of origin, farming practices, or processing history. This creates three problems:

- **Consumers/buyers** cannot verify authenticity, organic/inorganic claims, or GI-tag legitimacy at the point of purchase.
- **FPOs (Farmer Producer Organizations) and processors** cannot demonstrate compliance, quality lineage, or premium positioning to B2B buyers, exporters, or certification bodies.
- **Farmers** get no visible credit or premium attribution for the specific practices they follow (irrigation type, organic inputs, farm size), which weakens price discovery and trust.

The referenced sample shows a working pattern: a public, QR-linked webpage per batch that stitches together multiple farmer lots into one processed batch, with full event-level history (land prep → sowing → fertilizer application → harvest → drying → packing → sale to processor → grading → final packing).

## 2. Product Vision

A platform that lets FPOs, cooperatives, and processors capture farm and processing events as they happen, automatically compose them into traceable lots and batches, and publish a consumer-facing, QR-scannable traceability page for every unit sold — with zero manual documentation effort for farmers.

## 3. Goals & Success Metrics

| Goal | Metric |
|---|---|
| Increase buyer/consumer trust | % of packages with QR scanned at least once; average scans per batch |
| Reduce data-entry burden on farmers/FPOs | Median time to log a farming event (target: <60 seconds, mobile) |
| Improve traceability completeness | % of batches with zero missing mandatory events before sale |
| Support GI-tag / certification compliance | # of audits passed without manual reconciliation |
| Drive adoption across FPOs | # of active FPOs/processors onboarded; # of farmers actively logging events |
| Enable premium pricing for farmers | Reported price uplift for traced vs. untraced produce (survey-based, secondary metric) |
| Guarantee GI authenticity | % of GI-labeled batches with all component plots verified inside the official GI boundary; # of out-of-boundary attempts caught before publish |
| Make grades evidence-based | % of published batches whose grade was computed from measured readings (vs. declared only); % with an accredited lab certificate; # of declared-vs-computed grade mismatches caught before publish |
| Connect producers to buyers/benefits without manual re-entry | # of active API partners (marketplaces, FPO networks, government bodies); # and value of Producer Benefit Records attributed back to farmers |

## 4. Target Users & Personas

1. **Farmer** — logs farming events (land prep, sowing, inputs, harvest, drying, packing) for their plot(s), usually via a simple mobile app, often in a regional language, sometimes semi-literate. Needs minimal typing, photo-based evidence, offline support.
2. **FPO / Processor Admin** — manages farmer rosters, receives raw produce (creates "Sale to Processor" events), merges multiple farmer lots into a super-lot, and records processing events (grading, sorting, packing) against a batch.
3. **Field Officer / Extension Worker** — assists farmers with data entry where farmers can't use the app themselves; may input on farmer's behalf.
4. **Brand / Exporter / B2B Buyer** — views aggregated traceability and compliance data across many batches before purchase or certification decisions.
5. **End Consumer** — scans a QR code on the retail pack and views the public traceability page (no login required).
6. **Government / GI Authority / Certifier** — audits traceability records for GI-tag or organic-certification enforcement; may also consume data via API for scheme administration, subsidy targeting, or export certification.
7. **API Partner (Marketplace / FPO Network / Institution)** — an external platform or organization (online marketplace, FPO-to-buyer network, exporter platform, or government/institutional system) that integrates via API to read traceability data and/or report back sales, orders, subsidies, or premiums earned by specific producers.

## 5. Core Concepts & Data Model

- **Farmer** — name, location, contact, associated farms.
- **Farm / Plot** — GPS coordinates, area (acres), irrigation type (well/canal/rainfed), farming practice tags (organic/inorganic/IPM).
- **Crop** — crop name (bilingual/local-language support), GI tag reference, variety.
- **Component Lot** — one farmer's harvested quantity of a crop from one season/plot; carries its own full event history.
- **Super Lot / Batch** — a merge of multiple component lots (from one or more farmers) once sold to a processor; identified by a unique Batch ID.
- **Farming Event** (per component lot): Land Preparation, Bed Preparation, Sowing, Fertilizer & Pesticide Application (multi-instance), Harvest (multi-instance), Drying (multi-instance, start/end dates), Packing (date + quantity), Sale to Processor (date).
- **Processing Event** (per batch, at processor level): Grading/Sorting (grade, date, quantity), Packing (date, quantity, avg. sale price optional).
- **Processor / FPO entity** — name, type (FPO/company/co-op), location.
- **Media** — photo attached to each event as evidence, stored and served via object storage (e.g., S3), immutable once submitted.
- **Public Traceability Record** — a generated, versioned, publicly accessible page/API keyed by Batch ID, aggregating all of the above; includes a "last updated" timestamp and generation marker for cache-busting.
- **GI Geographical Boundary** — the officially registered production-area polygon for a given GI tag (e.g., the notified taluks/villages for "Virudhunagar Samba Vathal"), stored as GeoJSON; used to validate that a farm/plot and its events actually fall inside the area entitled to use the GI name.
- **API Consumer / Partner** — a registered external system (marketplace, government body, exporter platform, certifying agency) with credentials, scope, and rate limits, consuming traceability and benefit data via the platform's API.
- **Quality Reading** — one measured parameter (moisture, colour value, humidity, curcuminoid %, etc.) with value, unit, method, measurement source, instrument/lab details and evidence, linked to a component lot or batch at a specific stage.
- **Standards Profile** — the versioned rule set for a crop (e.g., "AGMARK Dry Chillies, Schedule IV") mapping parameter limits to grades; used to compute the grade automatically.
- **Instrument** — a registered moisture meter, colorimeter or sensor with its calibration certificate and due date.
- **Producer Benefit Record** — a record linking a scheme, subsidy, premium-price payout, or market access event back to the specific farmer(s)/component lot(s) that earned it, sourced from a partner via the API.

## 6. Functional Requirements

### 6.1 Farmer Mobile App
- FR1: Farmer can register/login (phone-number based, OTP) and be linked to their FPO.
- FR2: Farmer can create a new plot/farm with GPS auto-capture and manual override.
- FR3: Farmer can log each farming event type with structured fields + mandatory photo capture; supports multiple instances of an event (e.g., 2 harvest rounds).
- FR4: Offline-first — events queue locally and sync when connectivity resumes.
- FR5: Support regional-language UI and bilingual field labels (e.g., Tamil + English), matching local input names (fertilizer brand names in local script).
- FR6: Farmer can view their own submitted event history and edit/correct before the lot is sold.
- FR7: Push/SMS reminders for expected next event based on crop calendar (e.g., "harvest window approaching").

### 6.2 FPO / Processor Web Portal
- FR8: Admin can manage farmer roster, plots, and crop-season assignments.
- FR9: Admin can record "Sale to Processor" against one or more component lots, generating/merging them into a Super Lot with an auto-generated Batch ID.
- FR10: Admin can log processing events (grading/sorting, packing) against a batch, with quantity reconciliation against incoming component-lot quantities.
- FR11: System auto-flags quantity mismatches (e.g., procured vs. packed quantity variance beyond threshold).
- FR12: Admin can generate/download QR codes per batch/package for physical labeling.
- FR13: Admin dashboard: view all batches, lot completeness status, pending events, farmer participation stats.
- FR14: Role-based access (Admin, Field Officer, Viewer).

### 6.3 Public Traceability Page
- FR15: Publicly accessible, no-login page per Batch ID (mobile-responsive), reachable via QR scan or direct URL.
- FR16: Displays: batch summary, all component lots with farmer name/location/quantity/farm practices/map link, crop & GI-tag info, processor info, full chronological timeline of farming + processing events with photos.
- FR17: Page reflects "last updated" timestamp and is regenerated whenever new events are added to the batch (static-generation or cached-with-invalidation pattern acceptable).
- FR18: Map links open farm GPS coordinates in Google Maps (or embedded map view).
- FR19: Page must load fast on low-bandwidth mobile connections typical in rural retail contexts.

### 6.4 Analytics & Compliance
- FR20: FPO/brand-level dashboard showing traceability completeness %, farmer participation, and scan analytics (# scans, geography of scans) per batch.
- FR21: Exportable audit reports (PDF/Excel) per batch or per season for GI/certification audits.
- FR22: Configurable mandatory-event checklist per crop type (e.g., dry chilli requires drying event; some crops may not).

### 6.5 Platform / Admin
- FR23: Super-admin can onboard new FPOs, define crop types, event schemas, and required fields per crop.
- FR24: Multi-tenant support — each FPO/processor's data is isolated but reportable at a network/aggregator level.
- FR25: Audit trail — every event immutable once submitted, with edit history if corrections are permitted (with reason code).

### 6.6 Location Tagging & GI Geographical Boundary Validation
- FR26: Every farming event that captures a photo also silently captures device GPS coordinates and timestamp at the moment of submission (not just the plot's registered coordinates), to corroborate that the activity happened where and roughly when it was logged.
- FR27: Each GI-tagged crop type has an associated **GI Geographical Boundary** — the officially notified production area (village/taluk/district polygon) — loaded into the platform as GeoJSON per GI tag, sourced from the GI Registry application/journal for that tag.
- FR28: On plot registration, the system checks the plot's GPS coordinates against the relevant GI boundary polygon and flags (does not silently block) plots that fall outside it, so an FPO Admin can review before the plot is allowed to contribute to a GI-labeled batch.
- FR29: At batch-merge (Sale to Processor) stage, the system re-validates that every component lot's plot(s) fall within the GI boundary for the crop being claimed; a batch with any out-of-boundary component lot is blocked from being labeled/published as GI-certified (it can still be traced as a normal, non-GI batch).
- FR30: The public traceability page displays a "GI boundary verified" indicator (with the boundary map) for batches that pass this check, giving buyers/auditors a visible authenticity signal beyond the farmer-entered address.
- FR31: Boundary definitions are versioned and editable only by Super-admin/compliance team (not by FPOs), since they represent a legal/regulatory fact, not an operational preference.
- FR32: Configurable tolerance buffer (e.g., a small margin in meters) to accommodate GPS drift near boundary edges, set per GI tag by the compliance team.

### 6.7 API & Third-Party Integration Layer
- FR33: A documented, versioned REST/GraphQL API exposes traceability data (batches, component lots, farmer/farm summaries, events, GI-boundary-verification status) to registered external systems, with field-level visibility controlled by consumer type (see FR38).
- FR34: **Marketplace/e-commerce integration** — partners (e.g., online agri-marketplaces, D2C platforms, export trading platforms) can pull batch/product traceability data via API to display on their own listings, and can push back sale/order confirmations tied to a Batch ID so a sale event is reflected in the farmer's/FPO's record.
- FR35: **FPO-network integration** — other platforms that connect FPOs to buyers (aggregator networks, state agri-marketing boards, commodity exchanges) can query available/ready-for-sale batches and their compliance status via API, enabling cross-platform discovery without manual re-entry.
- FR36: **Government/institutional integration** — designated government bodies (e.g., APEDA, state agriculture departments, GI Registry, subsidy/scheme administrators) and certifying agencies can be granted scoped API/portal access to pull compliance, production, and GI-boundary-verification data for scheme administration, subsidy disbursement, GI enforcement, or export certification, subject to data-sharing agreements and farmer consent settings.
- FR37: **Producer benefit pass-through** — when a partner (marketplace, government scheme, exporter) reports a premium payment, subsidy, bonus, or preferential order tied to a Batch ID, the system attributes and records it against the specific component lot(s)/farmer(s) that contributed, and surfaces it to the farmer (via app/SMS) as a **Producer Benefit Record**, so the value created by traceability is visibly returned to the grower, not only captured by intermediaries.
- FR38: API access is credentialed and scoped by partner type (Marketplace, FPO-network, Government/Institutional, Certifier) with per-scope field visibility (e.g., a marketplace sees product/quality/GI data but not farmer phone numbers; a government scheme administrator may see farmer-identifying data only where legally required and consented to).
- FR39: Webhook/event-notification support so partners can subscribe to events (new batch published, GI-verification status change, benefit disbursed) instead of polling.
- FR40: API usage dashboard for Super-admin: which partners are calling which endpoints, rate-limit status, and data-sharing consent status per FPO/farmer.
- FR41: Farmer/FPO-level consent controls — an FPO (and optionally an individual farmer) can opt in/out of specific partner integrations or data categories being shared (e.g., allow government scheme data-sharing but not a specific private marketplace).

### 6.8 Quality Parameters & Standards-Based Validation

Today the grading stage records only a grade label typed in by a person. This section replaces that with measured quality parameters (colour, moisture/water content, storage humidity and crop-specific markers) that the platform checks against the published industry standard for that crop, so the grade on the public page is computed from evidence rather than asserted.

**Quality parameters captured**

- FR42: Each quality reading is stored as a structured record: parameter name, measured value, unit, test method reference (e.g., "ISO 6673", "ISO 3632-2"), measurement source (Lab / Calibrated instrument / Visual), instrument ID and last calibration date, sample ID, lab name and NABL accreditation number (for lab results), who measured it, timestamp and GPS, and an attached certificate or photo.
- FR43: **Moisture / water content (%)** — captured at three points: end of drying (on-farm), intake at the processor (Sale to Processor), and final grading. Required for every crop that has a moisture limit in its standard.
- FR44: **Colour** — captured as an instrument reading wherever the standard defines one (e.g., ASTA extractable colour units for chilli, crocin colouring strength at 440 nm for saffron, curcuminoid % for turmeric). Where no instrument is available, a visual colour grade against a reference colour card plus a standardised photo (fixed lighting and white-balance card in frame) is accepted, but is marked as "Visual" and cannot by itself earn the top grade.
- FR45: **Storage humidity and temperature** — relative humidity and temperature of the storage area, logged manually at defined intervals or via an optional sensor (see FR52), because damp storage raises mould and aflatoxin risk in dried produce even after the produce itself passed its moisture test.
- FR46: **Crop-specific parameters** — each crop's standards profile adds its own required fields (extraneous matter, broken or defective pieces, insect damage, ash, water extract, defect count, grain length, etc.), so the form shown at grading always matches the standard being applied.

**Standards profiles and validation engine**

- FR47: A **Standards Profile** is configured per crop (and per grade scheme where a crop has more than one, e.g., AGMARK for domestic sale and ISO for export). It lists each parameter, its limit (min/max), unit, test method and the grade each limit maps to. Profiles are versioned, cite the exact standard edition and clause, and can be edited only by the Super-admin/compliance team.
- FR48: **Automatic grade computation** — the system compares every measured value against the profile and assigns the grade the batch actually qualifies for. Where a standard grades on several parameters, the batch gets the lowest grade that all parameters meet (the approach ISO 3632 uses for saffron).
- FR49: **Declared vs. computed grade check** — if the QC officer's declared grade is higher than the computed grade, the record is flagged and the FPO Admin cannot approve the grading stage until the readings are corrected, re-tested, or the grade is lowered.
- FR50: **Plausibility checks** — readings outside a physically sensible range (e.g., negative moisture, moisture higher at grading than at intake without a recorded reason) are rejected at entry; instruments past their calibration due date cannot be selected.
- FR51: **Public display** — the public traceability page shows the computed grade, the standard it was graded against (with edition), the key readings (moisture, colour value) and the measurement source, with a "Lab-certified" badge only when an accredited lab result is attached.
- FR52: **Optional sensor/IoT path (later phase)** — Bluetooth moisture meters, colorimeters and storage humidity/temperature loggers can push readings directly through the API, removing manual entry; sensor readings carry device ID and calibration status like any other instrument reading.

**Seed standards profiles for the prototype**

The table below is the starting configuration. Values marked "load from standard" must be entered from a purchased or officially published copy of that standard before go-live, not from this table.

| Crop group (GI examples) | Standard to apply | Moisture limit | Colour / key quality marker | Grade output |
|---|---|---|---|---|
| Dry chillies (Virudhunagar Samba Vathal, Guntur Sannam, Byadgi, Ramnad Mundu) | AGMARK Grading & Marking Rules — Dry Chillies & Capsicums (Schedule IV) | Special ≤10%, Standard ≤11% | Capsaicinoid content (to be declared on label for Special grade); ASTA colour value as a buyer/contract specification; limits on extraneous matter, unripe/marked and broken fruits, ash, insect damage | Special / Standard / Below grade |
| Turmeric (Erode Manjal, Sangli, Waigaon, Kandhamal Haladi, Lakadong) | AGMARK — Turmeric Whole (Schedule II) | Special ≤11%, Standard ≤12% | Curcuminoid content (dry basis) min 3.0% Special / 2.0% Standard; lead chromate test must be negative; limits on extraneous matter, defective rhizomes, insect damage | Special / Standard / Below grade |
| Saffron (Kashmir Saffron) | ISO 3632-1 (specification, current edition) with ISO 3632-2 (UV-Vis test methods) | ≤12% filaments, ≤10% powder | Crocin (colouring strength, 440 nm), picrocrocin (bitterness, 257 nm), safranal (aroma, 330 nm); category thresholds — load from standard | ISO category; lowest category across the three markers |
| Coffee (Coorg Arabica, Chikmagalur Arabica, Araku Valley, Wayanaad Robusta, Monsooned Malabar) | ICO Resolution 420; moisture by ISO 6673 | 8%–12.5% (green coffee) | Defect count per ICO/ISO 10470 defect chart | S / XM (moisture fail) / XD (defect fail) / XDM. Monsooned coffees are a recognised high-moisture exception — flag, do not reject |
| Tea (Darjeeling, Assam Orthodox, Nilgiri Orthodox, Kangra) | ISO 3720 / FSSAI tea standard / IS 3633 | No moisture limit in ISO 3720 — captured as an internal process parameter with an FPO-set limit | Water extract ≥32%, total ash 4–8%, water-soluble ash ≥45% of total ash; leaf/liquor colour as a taster's sensory note | Pass / Fail plus taster grade |
| Basmati rice | FSSAI identity standard for Basmati Rice (2023 amendment, in force from 1 Aug 2023) | Maximum specified in the regulation — load from standard | Grain length and elongation ratio after cooking, amylose content, damaged grains, admixture of non-basmati rice | Pass / Fail |
| Wheat & other grains (Sharbati Gehu, Bhalia Wheat, millets) | AGMARK grade schedule for the commodity | Wheat ≤12% | Uniform size, shape and colour; foreign matter and damaged grain limits by grade | Grade I–IV per schedule |
| Any GI product without a published standard | FPO/consortium "GI Specification" from the GI Registry application, entered as a custom profile | As defined by the GI applicant | As defined in the GI application | Pass / Fail |

**Drying-stage validation example (chilli):** chillies are harvested at roughly 65–80% moisture and must reach ≤10% (Special) or ≤11% (Standard) before sale. The platform records the moisture reading at the end of each drying event; a lot cannot be marked "Ready for Sale" until a reading at or under the limit is logged, which also prevents produce being sold wet to gain weight.

### 6.9 Plot Location Capture & Checks

A plot is registered at farmer onboarding with a **live-GPS pin and the farmer's declared land size**; the pin is checked automatically against the GI region, with no manual verification step. Walking the boundary is **optional**, for FPOs that want stronger proof (e.g. for export buyers). The main GI fraud risk — passing off outside produce as GI by inflating land size — is handled by a yield ceiling, with land-record checks and manual review only when something is flagged.

**Capture at onboarding**

- FR64: **Pin (required)** — dropped from the phone's live GPS while standing on the plot. The app stores the coordinates, the GPS accuracy reported by the phone, time, and device. A pin placed by hand on a map is allowed only as an assisted fallback and is marked "Map pin — needs review"; it cannot contribute to a GI-labelled batch until reviewed.
- FR65: **Declared land size (required)** — entered by the farmer in acres, with the land-record reference (survey number; patta/chitta in Tamil Nadu) recorded where available.
- FR66: **Walked boundary (optional)** — the farmer or field officer walks the plot edge with the app recording GPS points. The app computes the walked area and flags a gap with the declared size above a set tolerance. A walked plot shows a "Boundary walked" badge on the public page.

**Automatic checks**

- FR67: **GI region check** — the pin (or walked boundary) is checked automatically against the GI geographical boundary and the taluks named in the GI registration (FR27–FR29, FR53). A live-GPS pin inside the region with acceptable accuracy is marked **Location confirmed** with no manual step, and the farmer is activated.
- FR68: **Yield ceiling with a 20–30% error margin** — each crop's Standards Profile holds a plausible maximum yield per acre for its region. Because declared land sizes and seasonal yields vary, the check allows a margin before acting:
    - Up to **20%** above declared acres × ceiling: accepted, no flag.
    - **20–30%** above: accepted with a soft warning shown to the FPO Admin; the lot can still join a GI-labelled batch.
    - More than **30%** above: held out of the GI-labelled batch until reviewed (FR70).
    - Example (illustrative ceiling of 1,000 kg/acre on a declared 1-acre plot): up to 1,200 kg passes, 1,200–1,300 kg is warned, above 1,300 kg is held.
    - The 20% and 30% thresholds are stored in the Standards Profile so the compliance team can tune them per crop after the first season (extends FR57 and FR60).
- FR69: **Event GPS check** — event-time GPS (FR26) must fall inside the walked boundary, or within a set radius of the pin, plus the GPS-drift buffer (FR32). Events outside are flagged, not rejected.

**Manual review only on flags**

- FR70: A Field Officer or FPO Admin reviews a plot only when it is flagged — map-placed pin, pin outside or near the GI boundary edge, poor GPS accuracy, yield more than 30% above the ceiling, repeated off-plot events, or walked area far from declared size. The reviewer compares against the land record (declared area vs. patta/chitta area), satellite imagery or a field visit, and records the outcome, method, date and reason.
- FR71: The plot location is set once at onboarding. A farmer who adds a new plot registers it the same way. A correction to an onboarded plot can be made only by the FPO Admin with a logged reason; the previous version is kept.
- FR72: The public page shows how each plot's location was established — "Live GPS pin" or "Boundary walked" — and, if reviewed after a flag, the review method and date.

## 7. Non-Functional Requirements

- **Scalability:** support thousands of FPOs and millions of farming events; public pages must handle traffic spikes (e.g., retail season QR scans).
- **Reliability:** public traceability pages should have high availability (retail-facing); event capture must tolerate rural connectivity (offline sync, retry).
- **Localization:** multi-language (minimum: English + major regional languages of operating states), bilingual labels as seen in the reference sample.
- **Data integrity:** quantity conservation checks across the farm → lot → batch → package chain.
- **Security & Privacy:** farmer personal data (name, location, contact) should be access-controlled on the admin side; public page may show farmer name/village/quantity but should allow an opt-out/anonymization setting per FPO's policy or local regulation.
- **Storage:** durable, versioned object storage for photos (immutable evidence trail).
- **Performance:** public traceability page should target sub-2-second load on 3G/4G rural networks.
- **Auditability:** every record traceable to a submitting user, device, and timestamp.
- **API security:** OAuth2/API-key based authentication, per-partner rate limiting, request logging, and field-level authorization so partners only ever receive data within their granted scope.
- **Geo-data accuracy:** GI boundary polygons must be kept current with official GI Registry notifications/amendments; a process (manual or semi-automated) is needed to refresh boundaries when a GI application is amended.
- **Consent management:** every external data share (government, marketplace, certifier) must be traceable to an explicit FPO/farmer consent record, not assumed.

## 8. Out of Scope (v1)

- Blockchain-based immutability (may be considered later for high-value export compliance; v1 relies on append-only audit logs).
- Payment/settlement between farmers and processors.
- IoT sensor integration (soil, weather) — future enhancement.
- Consumer loyalty/rewards program tied to scans.
- Automated, real-time ingestion of GI Registry boundary updates (v1 uses periodically refreshed, manually verified boundary files rather than a live government feed).
- Direct financial settlement/payment-rail integration with government subsidy disbursement systems (v1 records and displays benefit attribution; it does not move money).

## 9. User Flows (Summary)

1. **Farmer logs a season:** creates plot → logs land prep → bed prep → sowing → fertilizer applications (as they happen) → harvest event(s) → drying → packing → marks lot ready for sale.
2. **FPO receives produce:** admin records sale-to-processor for one or more component lots → system generates/merges into a Super Lot batch with new Batch ID.
3. **Processor processes batch:** logs grading/sorting → packing with final quantity → system generates QR codes for retail packs.
4. **Retail/Consumer:** buyer scans QR on pack → views public traceability page → sees farmer-level story, GI tag, and full event history.
5. **Auditor/Brand:** logs into portal → pulls compliance report for a season/batch set → cross-checks against GI/organic certification requirements.

## 10. Phased Rollout Plan

| Phase | Scope |
|---|---|
| Phase 1 (MVP) | Farmer mobile event capture (single crop type), FPO portal for batch merge + processing events, public traceability page, QR generation |
| Phase 2 | Multi-crop configurability, offline sync hardening, analytics dashboard, audit export, quality parameters with manual/instrument entry and standards-based grade computation (FR42–FR51), live-GPS pin plus declared area with automatic GI-region and yield checks, optional walked boundary, review only on flags (FR64–FR72) |
| Phase 3 | Multi-tenant scaling across FPOs/states, localization expansion, anomaly/quantity-variance detection, GI geo-boundary validation (FR26–FR32) |
| Phase 4 | Sensor/IoT quality capture (FR52), partner API & integration layer (marketplaces, FPO networks, government/institutional access, producer benefit pass-through — FR33–FR41), export-compliance features, optional blockchain anchoring for high-value export batches |

## 11. Risks & Open Questions

- **Data entry burden on farmers:** requires strong UX simplification and/or field-officer-assisted entry to avoid drop-off — needs field validation.
- **Photo/data authenticity:** photos alone don't prove event authenticity (backdating, wrong plot); may need geo/time-stamping enforcement on capture.
- **Connectivity in rural areas:** offline-first is a hard requirement, not a nice-to-have.
- **Privacy vs. transparency trade-off:** how much farmer personal data (name, exact GPS) should be public vs. anonymized — needs policy decision, possibly per-FPO configurable.
- **Quantity reconciliation edge cases:** multi-farmer super-lots make exact quantity attribution complex (e.g., proportional attribution when packed quantity ≠ sum of procured quantity).
- **Who owns/hosts the public page long-term?** (domain, uptime SLA, since retail packaging may reference the URL for years).
- **Source of truth for GI boundaries:** official GI Registry journal entries describe boundaries in prose (village/taluk names), not always as ready-to-use GeoJSON — digitizing them accurately for each GI tag is manual, ongoing work and a potential bottleneck to onboarding new crops.
- **GPS reliability near boundary edges:** rural GPS accuracy can legitimately place a genuine in-boundary farm just outside a strict polygon; the tolerance buffer (FR32) needs field calibration per region, and a human-review fallback for edge cases.
- **Data-sharing governance:** government/institutional API access raises questions of what farmer-identifying data can legally be shared without explicit consent, and who is liable if a partner misuses data — needs a legal/compliance review before FR36 is enabled for any given partner.
- **Access to standards text:** ISO standards (ISO 3632, ISO 3720, ISO 6673) are copyrighted and must be purchased; AGMARK and FSSAI schedules are public but get amended. Each Standards Profile needs a named owner who checks for new editions — the saffron standard, for example, was revised in 2025, and published category thresholds differ between editions.
- **Cost of lab testing for small farmers:** accredited lab tests (especially saffron UV-Vis and curcumin) cost money per sample. Testing should happen at batch level (paid by the FPO/processor), with only a quick moisture-meter reading required at farm level.
- **Visual colour grading is weak evidence:** phone-camera colour varies with lighting and device; it is useful for flagging obvious problems but should never be the sole basis for a premium grade.
- **Instrument calibration discipline:** cheap moisture meters drift; without enforced calibration dates, readings lose credibility with buyers and auditors.
- **Benefit attribution disputes:** when a batch is a merged super-lot from multiple farmers, attributing a marketplace premium or government subsidy (FR37) proportionally back to individual farmers needs a clear, agreed formula (e.g., by quantity contributed) to avoid disputes.

## 12. Appendix — Reference Sample: Full Field Inventory and Gaps

Source: GITrace public page for Batch FGP8T4033HM7 (Virudhunagar Samba Vathal, GI 883), last updated 2026-07-30 09:27:58 UTC. Re-checked field by field.

### 12.1 Every field on the reference page

| Section | Field | Example from sample | Covered in this PRD? |
|---|---|---|---|
| Batch header | Product | dry-chilly | Yes |
| | Super-lot ID | COMBO_LOT_6C1DCCFE | Yes |
| | Batch ID | FGP8T4033HM7 | Yes |
| | Batch quantity | 20.00 kg | Yes |
| | Super-lot label and lot count | Multiple Farmers (3 lots) | Yes |
| Component lot | Lot ID | LOTD02DADB6 | Yes |
| | Farmer name | muthu murugan | Yes |
| | Location (village, block, district, state) | PM Pudhupatti, Tiruchuli, Virudhunagar, Tamil Nadu | Partly — PRD had one free-text location (FR53) |
| | Quantity used | 100.00 kg | Yes |
| | Farm area | 0.5 acres | Yes |
| | Farming type | Irrigation | Partly — PRD merged it with irrigation source (FR54) |
| | Farming practices (several tags) | Inorganic, IPM | Yes |
| | Irrigation source | Well | Yes |
| | Farm GPS / map link | 9.559806, 78.133521 | Yes |
| Processor | Name, type, location | VIRUDHAI_SCFC_VINOBA_BHAVA_FPO, FPO, P Thottiyangulam, Tiruchuli | Yes |
| Crop | Crop name (English + Tamil) | VIRUDHUNAGAR SAMBA VATHAL (விருதுநகர் சம்பா வத்தல்) | Yes |
| | GI tag number | 883 | Yes |
| | Procured quantity | 320.00 kg | Yes |
| Timeline summary | Event counts (farming / processing; per lot) | 21 / 2; 7 per lot | No (FR63) |
| Land Preparation | Cultivation area, last ploughing date, photo | 0.5 acres, 2025-08-24 | Yes |
| Bed Preparation | Seed variety, nursery seeding date, photo, system comment | K2, 2025-09-19, "Status was automatically updated to COMPLETE after land preparation" | Partly — no event status/comment; nursery merged with sowing (FR55, FR59) |
| Sowing | Seed variety, sowing date per instance, photo | K2, 2025-11-11 | Yes |
| Fertilizer & Pesticide | Instance no., input name (English + Tamil), maker, quantity (kg), date, photo | Organic Fertilizer Gold (கரிம உரத் தங்கம்)-Amul, 25 kg, 2025-12-05 | Partly — maker not a separate field (FR56) |
| Harvest | Instance no., date, photo | 2026-02-14 and 2026-03-04 | Yes — but no harvest quantity (FR57) |
| Drying | Instance no., start date, end date, photo | 2026-02-15 to 2026-02-21 | Yes |
| Packing (farm) | Instance no., date, quantity, photo | 2026-03-12, 69 | Yes — unit missing on page (FR58) |
| Sale to Processor | Sale date | May 02, 2026 | Yes |
| Grading/Sorting | Grade, date, quantity, photo | A, 2026-07-30, 20 | Yes (FR42–FR51 extend it) |
| Processing Packing | Date, quantity, average sale price, photo | 2026-07-30, 20, N/A | Yes |
| Footer | Last updated (UTC), generation number | 2026-07-30 09:27:58 UTC, Gen 1785403678.099 | Yes |
| Photo storage | Farmer photos in `temp_uploads/`; processor photos in `fpos/260/` | — | No (FR61) |

### 12.2 Data problems visible in the sample

These are exactly the issues the platform's validations should catch before a page is published.

- **Quantities don't reconcile.** Lot LOTD02DADB6 packed 69 kg but 100 kg is "used"; LOT3072CB6A packed 140 kg but 200 kg is "used"; LOT0EF81415 packed 272.6 kg (77.6 + 195) but only 20 kg is "used". The 320 kg procured equals the sum of "used", but the 20 kg batch is never attributed back to the three farmers.
- **Practice tag contradicts the inputs.** All three lots are tagged "Inorganic", yet every input recorded is organic or biological (Organic Fertilizer Gold, Panjakavya, Azospirillum, Phospho Bacteria, Effective Micro Organism). Either the tag is wrong or chemical inputs were not logged.
- **IPM is claimed but no pest-management event exists** on any lot.
- **Units missing** on farm packing and processing quantities.
- **Instances shown out of order** (fertilizer instance 3 listed before 1 and 2).
- **Duplicated text** in the processor location ("Tiruchuli, Tiruchuli").
- **Evidence photos live in a `temp_uploads/` folder** — a temporary path that could be cleaned up, breaking the evidence trail on a page printed on packaging.
- **No harvest quantity**, so yield per acre can't be sanity-checked.
- **Nursery before ploughing:** LOT3072CB6A's bed seeding (2025-09-05) precedes main-field ploughing (2025-09-30). This is normal for chilli nurseries, so date-order rules must treat nursery and main field separately rather than flag it.
- **Missing for a buyer:** no grading standard or quality readings, no processor FSSAI licence number, no GI authorised-user registration, no pack or best-before date, and no GI-boundary verification.

### 12.3 New requirements from this review

- FR53: Structured address for farmer, farm and processor — village, block/taluk, district, state and PIN — used also as a second GI check against the taluks named in the GI registration.
- FR54: Separate "Farming type" (irrigated / rainfed) from "Irrigation source" (well, borewell, canal, tank).
- FR55: Split the nursery from the main field: Nursery Preparation (seed variety, nursery seeding date) and Sowing/Transplanting (date per instance), with date-order rules defined per crop.
- FR56: An input master list — name in English and the local language, manufacturer, category (chemical fertilizer, organic fertilizer, bio-fertilizer, chemical pesticide, bio-pesticide) and unit. Farmers pick from the list; practice tags (Organic / Inorganic / IPM) are derived from the categories, and contradictions are flagged for the FPO Admin.
- FR57: Harvest quantity (kg) per harvest instance, with a yield-per-acre plausibility check.
- FR58: Every quantity stored and displayed with its unit.
- FR59: Event status and a comment trail stored and shown, marking which entries were made by the system and which by a person.
- FR60: Per-lot reconciliation — harvested ≥ packed ≥ sold to processor ≥ quantity used — plus each farmer's share (%) of every batch shown on the public page.
- FR61: Evidence photos copied to permanent, versioned storage on submission; the public page never links to a temporary path; photo time and GPS metadata checked against the event.
- FR62: Compliance identifiers on the public page — processor FSSAI licence number, GI authorised-user registration numbers (producer and processor), pack date and best-before date.
- FR63: Event instances listed in date order, with event counts per lot and per batch.
