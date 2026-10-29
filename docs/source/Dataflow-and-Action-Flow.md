# Dataflow & Action Flow
## AgriTrace — Stage-wise Data, Roles & Approvals

**Companion document to:** PRD-Agri-Traceability-Platform.md
**Purpose:** Define exactly what data is captured at each stage of the farm-to-consumer journey, who enters it, who approves/verifies it, and who triggers the move to the next stage.

---

## 1. How to Read This Document

Each stage below follows the same structure:

- **Data Captured** — the fields/evidence recorded at this stage.
- **Entered By** — the role that physically inputs the data.
- **Verified/Approved By** — the role that checks and unlocks progression (may be automatic in some stages).
- **Moves To Next Stage** — who/what triggers the transition, and what condition must be true.
- **System Action** — what the platform does automatically once the stage is approved.

Roles used throughout:
- **Farmer** — the individual grower.
- **Field Officer (FO)** — FPO/cooperative staff who assists farmers, especially where literacy/connectivity is a barrier.
- **FPO/Processor Admin** — office-based staff at the Farmer Producer Organization or processing unit.
- **QC/Grading Officer** — quality-control staff at the processing stage.
- **Platform (System)** — automated actions requiring no human approval (e.g., ID generation, page publishing).
- **Auditor/Certifier** (occasional) — external GI/organic auditor, read-only unless a formal certification workflow is added.

---

## 2. Stage-by-Stage Flow

### Stage 0 — Farmer & Farm Onboarding
| | |
|---|---|
| **Data Captured** | Farmer name, phone number, village/location, ID proof (Aadhaar/voter ID, stored securely), bank details (for future settlement, optional in v1); **live-GPS pin** taken on the plot (with GPS accuracy and time), **declared land size** (acres), land-record reference (survey number, patta/chitta) where available, **optional walked boundary**, irrigation type (well/canal/rainfed/other), soil type (optional) |
| **Entered By** | Farmer (self-service) or Field Officer (assisted entry) |
| **Verified/Approved By** | FPO/Processor Admin confirms the farmer is a genuine member. The plot location needs **no manual verification**: the system checks the live-GPS pin against the GI region automatically. A Field Officer or FPO Admin reviews the plot only if it is flagged (map-placed pin, poor GPS accuracy, near or outside the GI boundary, or walked area far from declared size) |
| **Moves to Next Stage** | Admin membership approval plus an automatically confirmed location activates the farmer; a flagged plot waits for review before its lots can join a GI-labelled batch |
| **System Action** | Generates a unique Farmer ID and Plot ID; links farmer to FPO tenant; runs the GI-region check on the pin (or walked boundary); stores declared acres for the yield ceiling; if a boundary was walked, computes its area and flags a mismatch with declared size; locks the location after onboarding (corrections only by FPO Admin with a logged reason) |

### Stage 1 — Land Preparation
| | |
|---|---|
| **Data Captured** | Cultivation area (acres), last date of ploughing, photo evidence |
| **Entered By** | Farmer or Field Officer |
| **Verified/Approved By** | No manual approval required — auto-validated if photo + date present; flagged for FO review if area exceeds registered plot size |
| **Moves to Next Stage** | Automatic on submission (system marks "Land Prep: Complete") |
| **System Action** | Opens the "Bed Preparation" event for the same component lot |

### Stage 2 — Bed Preparation / Sowing
| | |
|---|---|
| **Data Captured** | Seed variety, date of seeding, photo; (for multi-round sowing) one entry per sowing instance |
| **Entered By** | Farmer or Field Officer |
| **Verified/Approved By** | Auto-validated; FO spot-checks a sample of entries periodically (not a blocking approval) |
| **Moves to Next Stage** | Automatic on submission |
| **System Action** | Creates the component lot record if not already created; starts the crop-calendar reminder sequence (e.g., expected fertilizer/harvest windows) |

### Stage 3 — Fertilizer & Pesticide Application
| | |
|---|---|
| **Data Captured** | Input name (fertilizer/pesticide, bilingual label), quantity (kg/l), date of application, photo; multiple instances allowed per season |
| **Entered By** | Farmer or Field Officer |
| **Verified/Approved By** | Auto-accepted; if the FPO enforces an organic/GI compliance ruleset, the **QC/Grading Officer** or a compliance rule engine flags any input not on the approved list for that crop |
| **Moves to Next Stage** | No blocking gate — farmer proceeds to harvest when ready; flagged entries require FPO Admin sign-off before the lot can later be marked "compliant" |
| **System Action** | Appends to the lot's practice profile (used later to populate "Farming Practices" on the public page, e.g., Organic/Inorganic/IPM) |

### Stage 4 — Harvest
| | |
|---|---|
| **Data Captured** | Harvest date(s), photo; supports multiple harvest rounds per lot |
| **Entered By** | Farmer or Field Officer |
| **Verified/Approved By** | Auto-validated |
| **Moves to Next Stage** | Automatic — opens Drying/Post-harvest handling event |
| **System Action** | Locks land-prep/sowing/input fields for that lot instance (no further edits without a reason code) |

### Stage 5 — Drying / Post-Harvest Processing (on-farm)
| | |
|---|---|
| **Data Captured** | Start date, end date, photo; multiple drying batches allowed; **end-of-drying moisture reading (%)** with moisture-meter ID |
| **Entered By** | Farmer or Field Officer (FO carries the calibrated moisture meter where farmers don't own one) |
| **Verified/Approved By** | Auto-validated against the crop's Standards Profile moisture limit (e.g., ≤11% for dry chilli Standard grade) |
| **Moves to Next Stage** | Automatic only when moisture is at or under the limit; otherwise the lot stays in "Drying" and the farmer is prompted to continue drying |
| **System Action** | Enables the "Packing" event; stores the reading as the first point in the lot's moisture trail |

### Stage 6 — On-Farm Packing
| | |
|---|---|
| **Data Captured** | Date of packing, packed quantity, photo |
| **Entered By** | Farmer or Field Officer |
| **Verified/Approved By** | **FPO Admin** cross-checks packed quantity against expected yield (area × typical yield); large deviations are flagged, not blocked |
| **Moves to Next Stage** | Farmer/FO marks the lot "Ready for Sale"; FPO Admin confirms readiness |
| **System Action** | Component lot status changes to "Ready for Procurement" |

### Stage 7 — Sale to Processor (Lot → Super Lot / Batch Merge)
| | |
|---|---|
| **Data Captured** | Sale date, quantity sold per component lot, price (optional), which component lots are being merged; **intake moisture reading per lot** (re-checked at the processor's gate) |
| **Entered By** | **FPO/Processor Admin** (this is an office-side transaction, not a farmer entry) |
| **Verified/Approved By** | **FPO/Processor Admin** (self-approving role) — a second Admin/Manager sign-off is recommended for batches above a configurable value/quantity threshold |
| **Moves to Next Stage** | Approval merges the named component lots into a new **Super Lot / Batch** |
| **System Action** | Generates a new **Batch ID**; sums component-lot quantities against total procured quantity; runs a **quantity-reconciliation check** (flags variance beyond threshold, e.g., >5%); runs the **yield-ceiling check** (lot quantity vs. declared acres × the crop's plausible yield per acre, with a 20–30% error margin): up to 20% over passes, 20–30% over passes with a warning to the FPO Admin, more than 30% over is held out of the GI-labelled batch until reviewed |

### Stage 8 — Grading / Sorting
| | |
|---|---|
| **Data Captured** | Date, quantity, photo; **all quality parameters required by the crop's Standards Profile** — moisture %, colour value (ASTA units / crocin / curcuminoid % as applicable, or visual colour-card grade with standardised photo), extraneous matter, broken/defective %, insect damage, and any crop-specific markers; storage humidity & temperature at the time of grading; lab certificate (if tested) with lab name and NABL number; declared grade |
| **Entered By** | **QC/Grading Officer** at the processing unit (instrument readings); **accredited lab** results uploaded by QC Officer or pushed by the lab via API |
| **Verified/Approved By** | **System** computes the grade from the readings against the Standards Profile; **FPO/Processor Admin** approves — but cannot approve if the declared grade is higher than the computed grade, or if a required parameter is missing |
| **Moves to Next Stage** | Admin approval opens the final Packing event |
| **System Action** | Updates batch status to "Graded" with the computed grade and standard edition; graded quantity becomes the ceiling for final packing quantity; quality readings become visible on the public page |

### Stage 9 — Final (Retail) Packing
| | |
|---|---|
| **Data Captured** | Date of packing, quantity, average sale price (optional), photo; **storage humidity & temperature log** for the period between grading and packing (manual entries or sensor feed) |
| **Entered By** | **QC/Grading Officer** or **FPO/Processor Admin** |
| **Verified/Approved By** | **FPO/Processor Admin** — final sign-off that the batch is complete and ready for market |
| **Moves to Next Stage** | Admin approval **publishes the public traceability page** for the Batch ID and enables QR code generation |
| **System Action** | Generates/refreshes the public traceability URL; generates downloadable QR codes for physical labeling; stamps "Last updated" timestamp |

### Stage 10 — Public Consumption (Consumer/Buyer)
| | |
|---|---|
| **Data Captured** | Scan event (timestamp, approximate location — for analytics only, no personal data collected from the scanner) |
| **Entered By** | N/A — passive action by consumer/buyer scanning the QR code |
| **Verified/Approved By** | N/A (public, read-only page) |
| **Moves to Next Stage** | N/A — this is the terminal, ongoing stage; the page remains live and can be updated if the FPO later adds an amendment (with visible edit history) |
| **System Action** | Logs scan analytics to the FPO's dashboard |

### Stage 11 — Audit / Compliance Review (parallel, on-demand)
| | |
|---|---|
| **Data Captured** | N/A — this stage reads existing records; may add an "Audit Note" or "Certification Status" field |
| **Entered By** | Auditor/Certifier (read access) raises findings; **FPO Admin** enters remediation notes |
| **Verified/Approved By** | Auditor/Certifier signs off the audit; recorded as a non-editable attestation linked to the batch or season |
| **Moves to Next Stage** | N/A — informational overlay on existing batches |
| **System Action** | Attaches audit outcome/certificate reference to the batch/season record for future reference |

---

## 3. Consolidated Role → Responsibility Matrix

| Role | Enters Data At | Approves/Verifies At | Can Trigger Stage Transition? |
|---|---|---|---|
| Farmer | Land prep, bed prep/sowing, inputs, harvest, drying, on-farm packing | — | Marks lot "Ready for Sale" (soft trigger) |
| Field Officer | Any farmer-stage event, on farmer's behalf | Spot-checks (non-blocking) | Same as farmer, assisted |
| FPO/Processor Admin | Sale-to-processor, batch merge | On-farm packing quantity check, sale-to-processor approval, grading approval, final packing sign-off | Yes — batch creation, page publishing |
| QC/Grading Officer | Grading/sorting with quality readings, storage humidity log, final packing | — (system computes grade; Admin approves) | No — hands off to Admin for approval |
| Accredited Lab | Lab test results (moisture, colour markers, curcuminoids, etc.) via upload or API | — | No — results feed the grade computation |
| Auditor/Certifier | Audit notes (read-mostly) | Certification sign-off | No — overlay only, does not block commercial flow |
| Platform (System) | Auto-generated IDs, timestamps, reconciliation flags | Auto-validation of well-formed submissions | Auto-advances non-gated stages (0–6) |
| Consumer/Buyer | Scan event only | — | — |

---

## 4. Approval Gates Summary (Where a Human Must Act)

Most farm-level events (Stages 1–6) are **self-service and auto-advancing** — the farmer's own submission is sufficient, since the goal is to minimize friction. Formal human approval gates exist only at the **commercial/compliance-critical transitions**:

1. **Farmer/Plot onboarding** — FPO Admin approval of the farmer's membership. The plot's live-GPS pin is checked against the GI region automatically; manual review happens only for flagged plots, and walking the boundary is optional.
2. **Sale to Processor (batch creation)** — FPO/Processor Admin approval, second sign-off above threshold.
3. **Grading/Sorting result** — FPO/Processor Admin approval before it's attached to the batch; blocked automatically if readings don't support the declared grade.
3a. **Drying completion (automatic gate)** — no human approval, but a lot cannot move to sale until its moisture reading meets the crop's limit.
4. **Final Packing → Public Page Publish** — FPO/Processor Admin final sign-off (this is the point of no easy return, since the page becomes publicly visible and may be printed on physical packaging).

Everything else is designed to be lightweight for the farmer, with **exception-based review** (the system flags anomalies — quantity mismatches, non-approved inputs — for an Admin to look at, rather than blocking every entry).

---

## 5. Notes for the Prototype

- In a prototype/demo, Stages 0–6 can be simulated as pre-seeded data (as in the reference sample) since the goal is to demonstrate the **output** (public traceability page) rather than the full data-entry UX.
- Stages 7–9 (merge, grading, packing, publish) are the best candidates for a **live clickable demo**, since they show the "approval → next stage" logic most clearly.
- The **quantity reconciliation check** (Stage 7) and **input compliance flag** (Stage 3) are good candidates to visibly demo as "smart" platform behavior in a sales prototype.
