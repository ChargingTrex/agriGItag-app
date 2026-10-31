# Backend design spec (from the approved plan; binding for B01–B13)

Companion to `docs/agents/plan-summary.md` §7.1. Where this file and the plan differ, this file is more detailed and wins; where code already on `main` differs, raise it with the Architect-Gate rather than silently diverging.

## 0. Ground rules

- Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2 async (asyncpg), Alembic, GeoAlchemy2, Celery 5 (Valkey broker via redis protocol), boto3 (S3 / LocalStack), Jinja2 via `agritrace_page`, `qrcode` + `reportlab` (labels), Pillow (EXIF, WebP variants), shapely (walked-boundary area).
- One package `agritrace` under `apps/api/`; `agritrace.worker` is the Celery entrypoint.
- Module import rule (import-linter, D-004): a module may import another module's `models.py` and the `service.py` names in that module's `__all__`; never its `router.py`, `schemas.py` or `tasks.py`. Cross-module async work goes through task names in `core/task_names.py`.
- Every table: `id UUID PK` (UUIDv7 server-side unless client-provided), `created_at`, `updated_at` timestamptz. Tenant-scoped tables carry `fpo_id`. Every Pydantic field has `description=`; every column has `comment=`.
- Codes: lot `LOT` + 8 upper hex; batch 12-char Crockford base32 (matches `FGP8T4033HM7`); super-lot `COMBO_LOT_` + 8 hex.
- Error envelope `{"error": {"code", "message", "details"}}`; 422 validation/plausibility, 409 state/gate, 501 stubs. All codes registered in `core/errors.py`.
- Quantities stored as `(value NUMERIC(12,3), unit TEXT)` pairs (FR58); API uses the shared `Quantity` model.
- All routes under `/v1`; additive changes only (D-020).
- Field/feature flags from `apps/api/config/*.yaml` (D-017, built by B13); until B13 lands, modules keep field lists in code but must not hard-code tenant-specific requiredness.

## 1. Module map

| Module | Tables owned | Key endpoints | Celery tasks | Depends on |
|---|---|---|---|---|
| identity | users, memberships, otp_challenges, devices, assist_sessions, consent_records, audit_log (written via core/audit) | POST /auth/otp/request, POST /auth/otp/verify, POST /auth/refresh, POST /auth/logout, GET /me, POST /assist/start, POST /assist/end, POST /consents, GET /farmers/{id}/consents | — | notifications (task name only) |
| registry | fpos, processors, farmers, plots, plot_revisions, crops, gi_tags, gi_region_versions, inputs_master, villages, id_documents (flag-gated), producer_groups (flag-gated) | GET/POST /fpos, GET/POST/PATCH /farmers, POST /farmers/{id}/approve, POST /plots, GET /plots/{id}, POST /plots/{id}/correct, GET /crops, GET /gi-tags/{id}/region, POST /gi-tags/{id}/region-versions (super-admin), GET/POST /inputs, GET /villages | — | identity |
| events | events, event_versions, evidence_photos, sync_cursors, reference_versions, sync_metrics | POST /sync/push, POST /sync/photos/confirm, GET /sync/pull, GET /sync/bundle, GET /sync/bundle/{part}, GET /sync/reference?since=, GET /lots/{id}/events, POST /events/{id}/versions, POST /events/{id}/undo | events.verify_photo, events.make_variants | identity, registry; enqueues rules.check_event |
| rules_flags | flags | GET /flags, GET /flags/{id}, POST /flags/{id}/resolve | rules.check_event, rules.check_plot, rules.check_lot | registry (geo), events, quality (profile yield params), lots_batches models |
| lots_batches | lots, lot_intakes, batches, batch_shares, batch_approvals | GET /lots, GET /lots/{id}, POST /lots/{id}/ready, GET /lots/{id}/qr, POST /intakes, POST /batches, GET /batches, GET /batches/{id}, POST /batches/{id}/grading/approve, POST /batches/{id}/final-packing, POST /batches/{id}/publish | — | registry, events, quality, rules_flags; enqueues publishing.build_page |
| quality | standards_profiles, standards_profile_versions, instruments, quality_readings, grade_computations | GET /standards-profiles, GET /standards-profiles/{id}/versions/{n}, POST /standards-profiles/{id}/versions, GET/POST /instruments, POST /quality-readings, GET /lots/{id}/readings, GET /batches/{id}/readings, POST /batches/{id}/grading, GET /batches/{id}/grade | — | registry, identity |
| storage_monitoring (stub) | none | POST /probes, POST /probe-readings → 501 | — | — |
| publishing | page_builds | POST /batches/{id}/rebuild, GET /batches/{id}/builds, GET /batches/{id}/qr.png, GET /batches/{id}/labels.pdf, GET /public/batches/{code} (dev proxy) | publishing.build_page | lots_batches, quality, registry, events (read via services) + `agritrace_page` |
| notifications | notifications | GET /notifications | notifications.send | — |
| partner_api (stub) | none | GET /partner/v1/batches/{code} → 501, POST /partner/v1/benefits → 501 | — | — |
| reporting | scan_events | GET /dashboard/fpo/{id}, POST /public/scans, GET /batches/{id}/audit-export.csv | — | lots_batches, events, rules_flags (read) |
| config (B13, lives in core) | — | GET /config/fields, GET /config/features, POST /imports/{farmers,villages,inputs} | — | registry |

## 2. Core data model

Types: `uuid`, `text`, `numeric(12,3)`, `timestamptz`, `jsonb`, `geography(POINT,4326)`, `geography(MULTIPOLYGON,4326)`. `(cid)` = client-generated id used as PK and idempotency key, UNIQUE.

### identity
- `users`: id, phone (E.164, unique), name, name_local, lang, is_super_admin, status
- `memberships`: user_id, fpo_id, role ∈ {farmer, field_officer, qc_officer, fpo_admin, viewer}; UNIQUE(user_id, fpo_id)
- `otp_challenges`: id, phone, code_hash, expires_at, attempts, consumed_at
- `devices`: id (= device_id from app), user_id, platform, app_version, refresh_token_hash, last_seen_at, revoked_at
- `assist_sessions`: id (cid), officer_user_id, farmer_id, started_at, ended_at, started_gps (point)
- `consent_records`: id (cid), farmer_id, consent_type (data_collection | public_name | partner_share), consent_version, recording_ref, witnessed_by_user_id, given_at, device_id, revoked_at
- `audit_log`: id, at, actor_user_id, on_behalf_of_farmer_id, assist_session_id, device_id, gps (point, nullable), action, entity_type, entity_id, diff jsonb, request_id. Trigger forbids UPDATE/DELETE.

### registry
- `fpos`: id, code, name, kind (fpo | company | coop), address jsonb {village, block, district, state, pin}, fssai_no, gi_authorised_user_no, public_show_farmer_names bool
- `processors`: id, fpo_id nullable, name, kind, address jsonb, fssai_no, gi_authorised_user_no
- `villages`: id, lgd_code, name_en, name_local, block, taluk, district, state, pincode
- `farmers`: id, fpo_id, user_id nullable (feature-phone farmers), code, name, name_local, photo_key, address jsonb, village_id nullable, gi_authorised_user_no, status (pending | active | suspended), approved_by, approved_at, no_smartphone bool, producer_group_id nullable
- `plots`: id (cid), fpo_id, farmer_id, code, pin geography(POINT), pin_accuracy_m, pin_method (live_gps | map_pin), pin_device_time, pin_gps_time, pin_server_received_at, declared_area_acres, land_record_ref, walked_boundary geography(POLYGON) nullable, walked_area_acres, farming_type (irrigated | rainfed), irrigation_source (well | borewell | canal | tank | rain), soil_type, location_status (confirmed | needs_review | outside | near_edge), location_method_label, revision_no, reviewed_at, review_method, review_outcome
- `plot_revisions`: id, plot_id, revision_no, snapshot jsonb, changed_by, reason_code, reason_text, changed_at
- `crops`: id, code, name_en, name_local, lang, gi_tag_id nullable, event_schema jsonb (mandatory event types; date-order rules with nursery/main-field tracks, FR55), active
- `gi_tags`: id, gi_number ("883"), name, name_local, registry_ref
- `gi_region_versions`: id, gi_tag_id, version_no, geom geography(MULTIPOLYGON), tolerance_buffer_m, taluks jsonb, source_ref, licence, confidence, effective_from, created_by; UNIQUE(gi_tag_id, version_no); GiST index on geom
- `inputs_master`: id, fpo_id nullable (null = global), name_en, name_local, manufacturer, category (chemical_fertilizer | organic_fertilizer | bio_fertilizer | chemical_pesticide | bio_pesticide | other), unit, pack_size, photo_key, active
- `id_documents` (flag `id_document_capture`): id, farmer_id, doc_type, object_key (bucket id-docs), captured_by, captured_at, consent_record_id
- `producer_groups` (flag `producer_groups`): id, fpo_id, name, kind (shg | other)

### events
- `events`: id (cid, stable across versions), fpo_id, subject_type (lot | batch), lot_id nullable, batch_id nullable, plot_id nullable, event_type (land_preparation | nursery | sowing | input_application | harvest | drying | packing | problem | intake | grading | final_packing), instance_no, status (draft | submitted | undone | superseded | locked), current_version_id, occurred_on date; CHECK exactly one of lot_id/batch_id
- `event_versions` (append-only, trigger): id (cid), event_id, version_no, payload jsonb (per-type schema; quantities {value, unit}), occurred_on, occurred_end_on, device_time, gps_time, server_received_at, gps geography(POINT), gps_accuracy_m, entered_by_user_id, on_behalf_of_farmer_id, assist_session_id, entered_remotely bool, device_id, app_version, change_kind (create | correct | undo | system), reason_code, reason_text, supersedes_version_id, is_system_generated bool; UNIQUE(event_id, version_no)
- `evidence_photos` (append-only): id (cid), event_version_id nullable, quality_reading_id nullable, bucket, object_key (`evidence/{fpo_id}/{yyyy}/{event_id}/{photo_id}.jpg`), s3_version_id, content_type, size_bytes, sha256_client, sha256_server, exif_taken_at, exif_gps geography(POINT), status (pending_upload | uploaded | verified | checksum_mismatch | exif_mismatch), variants jsonb {thumb_url, medium_url, jpeg_url, width, height}, upload_url_expires_at, uploaded_at, verified_at
- `sync_cursors`: device_id PK, last_pull_cursor, last_push_at
- `reference_versions`: part, fpo_id, version (bumped by trigger on owning tables)
- `sync_metrics`: id, device_id, entry_client_id, saved_at, acked_at, photo_upload_ms, failures, network_type, app_version

### lots_batches
- `lots`: id, fpo_id, farmer_id, plot_id, crop_id, season_label, code, status (open | drying | ready_for_sale | received | batched | closed), practice_tags jsonb {declared, derived, contradiction}, harvested_kg, packed_kg, ready_at, gi_eligible bool, gi_hold_reason
- `lot_intakes`: id (cid), lot_id, fpo_id, processor_id, sale_date, received_kg, price_per_kg nullable, intake_moisture_reading_id, accepted_by_user_id, reconciliation jsonb, yield_check jsonb
- `batches`: id, fpo_id, crop_id, processor_id, code, superlot_code, status (created | graded | packed | published), gi_label_requested, gi_verified, gi_block_reasons jsonb, total_received_kg, graded_kg, packed_kg, computed_grade, standards_profile_version_id, pack_date, best_before_date, current_build_no, created_by, second_signoff_by nullable
- `batch_shares`: batch_id, lot_id, kg_contributed, share_pct numeric(6,3), farmer_id; PK(batch_id, lot_id); Σ share_pct = 100 ± 0.01
- `batch_approvals`: id, batch_id, stage (intake | grading | final_packing | publish), approved_by, approved_at, blocked_reasons jsonb

### quality
- `standards_profiles`: id, crop_id, scheme (agmark | iso | fssai | custom), name, standard_ref, owner_user_id
- `standards_profile_versions`: id, profile_id, version_no, edition, clause_ref, rules jsonb (§5), status (draft | published | retired), published_at, published_by; UNIQUE(profile_id, version_no)
- `instruments`: id, fpo_id, kind (moisture_meter | colorimeter | hygrometer | scale), make_model, serial_no, calibrated_on, calibration_due_on, calibration_cert_photo_id, active
- `quality_readings`: id (cid), fpo_id, lot_id nullable, batch_id nullable, stage (drying_end | intake | grading | storage), parameter_code, value numeric, unit, method_ref, source (lab | instrument | visual), instrument_id nullable, calibration_due_on_at_time, lab_name, lab_nabl_no, sample_id, certificate_photo_id, evidence_photo_id, measured_by_user_id, measured_at, device_time, gps_time, server_received_at, gps, reason_code, profile_version_id
- `grade_computations`: id, batch_id, profile_version_id, computed_grade, declared_grade, declared_by, per_parameter jsonb, status (incomplete | ok | declared_above_computed), lab_certified bool, computed_at

### rules_flags
- `flags`: id, fpo_id, subject_type (plot | event | lot | batch | reading), subject_id, rule_code, severity (info | warn | hold), details jsonb, dedupe_key UNIQUE, status (open | cleared | fixed | escalated), assigned_role, raised_at, resolved_by, resolution_reason_code, resolution_note, resolved_at

### publishing / reporting / notifications
- `page_builds`: id, batch_id, build_no, generation, snapshot jsonb, html_key, json_key, qr_key, status, built_at, trigger
- `scan_events`: id, batch_code, scanned_at, approx_location (point, nullable), user_agent_hash
- `notifications`: id, user_id, channel (push | sms | whatsapp | console), template_key, lang, payload jsonb, status (queued | sent | failed), provider_ref, sent_at

## 3. Sync protocol (B06, B07; mirrored by mobile M02)

Auth: Bearer access token + `X-Device-Id` + optional `X-Assist-Session`. Client ids are UUIDs generated on the phone.

### POST /v1/sync/push (≤ 50 entries or 256 KB)
```json
{ "device_id": "…", "app_version": "1.0.3", "device_time": "2026-03-04T08:12:10+05:30",
  "metrics": [ { "entry_client_id": "…", "saved_at": "…", "acked_at": null, "network_type": "lte" } ],
  "entries": [
    { "client_id": "018f…", "kind": "event_version",
      "data": { "event_id": "018f…", "version_no": 1, "subject_type": "lot", "lot_id": "…", "plot_id": "…",
                "event_type": "harvest", "instance_no": 2, "occurred_on": "2026-03-04",
                "payload": { "quantity": { "value": 195, "unit": "kg" }, "bags": 13 },
                "clocks": { "device_time": "…", "gps_time": "…" },
                "gps": { "lat": 9.5598, "lon": 78.1335, "accuracy_m": 6.2 },
                "photos": [ { "client_id": "018f…", "sha256": "…", "size_bytes": 287311, "content_type": "image/jpeg",
                              "exif_taken_at": "…", "exif_gps": { "lat": 9.5598, "lon": 78.1335 } } ] } },
    { "client_id": "…", "kind": "quality_reading", "data": { } },
    { "client_id": "…", "kind": "plot", "data": { } },
    { "client_id": "…", "kind": "consent", "data": { } },
    { "client_id": "…", "kind": "flag_resolution", "data": { } },
    { "client_id": "…", "kind": "farmer", "data": { } },
    { "client_id": "…", "kind": "assist_session", "data": { "farmer_id": "…", "started_at": "…", "started_gps": { } } },
    { "client_id": "…", "kind": "consent", "assist_session_id": "…", "data": { } } ] }
```

Kinds `farmer` and `assist_session` and the optional per-entry `assist_session_id` were added by rulings 2026-10-31
(D-031, D-032; implemented by B15): `farmer` is idempotent on `client_id`, officer/admin only, stored pending;
`assist_session` goes through the idempotent `start_assist`; an entry's `assist_session_id` must belong to the caller
(ended sessions accepted) and to the entry's farmer, and it records assist mode on that entry and its audit row.
The `X-Assist-Session` header keeps working for online calls.
Response always 200 if the envelope parses; per-entry outcome:
```json
{ "server_time": "…", "results": [
  { "client_id": "…", "status": "accepted", "server_id": "…",
    "photo_uploads": [ { "photo_client_id": "…", "method": "PUT", "url": "https://…", "headers": { "Content-Type": "image/jpeg", "x-amz-checksum-sha256": "…" }, "expires_at": "…" } ] },
  { "client_id": "…", "status": "duplicate", "server_id": "…", "photo_uploads": [ ] },
  { "client_id": "…", "status": "rejected", "error": { "code": "validation_error", "details": { } } } ] }
```
Rules: entries processed in order, each in its own transaction; `entered_by` from the token, never the body; `server_received_at` set server-side; idempotency = `INSERT … ON CONFLICT (id) DO NOTHING` then re-read; duplicate owned by another user → `client_id_conflict`; `version_no` must be max+1 else `stale_version`; entries without photos enqueue `rules.check_event` immediately.

### Photo upload and confirm
Single presigned PUT (15-min expiry, SHA-256 and Content-Type bound; D-011). `POST /v1/sync/photos/confirm` `{ "photos": [ { "client_id": "…" } ] }` → `[ { "client_id", "status": "received" | "missing" } ]`; server HEADs, stores `s3_version_id`, enqueues `events.verify_photo` (sha256 + EXIF) then `events.make_variants` (WebP thumb ~60 KB, medium ~150 KB, record width/height, keep original JPEG URL) then `rules.check_event`. Photos unconfirmed after 24 h appear on the last page of `/sync/pull` as `photo_pending`.

### GET /v1/sync/pull?cursor=&limit=200
`{ "changes": [ { "entity": "flag | lot | event | intake | notification | photo_pending", "op": "upsert", "data": { } } ], "next_cursor": "…", "has_more": false }`; scoped to the caller (farmer) or the FPO's farmers (officer).

### Reference bundles
`GET /v1/sync/bundle` → manifest of parts {plots, crops, inputs, standards, gi_region, farmer_profile, villages, fields (B13), prompts, images} with `version` and `etag`. `GET /v1/sync/bundle/{part}` honours `If-None-Match` → 304. `GET /v1/sync/reference?since=plots:41,crops:7,…` returns only parts whose version **differs** from the one the phone lists (per part; a bare number is 422; unlisted parts are returned) (plan §13 C2, B07). `standards` carries the **full** `standards_profile_versions.rules` JSON for each active profile version (Orchestrator decision 2026-10-31 after M03: the on-device grade preview needs `grades`, `fail_grade`, `trail_rules`, `lab_certified_requires` and the per-parameter fields; the JSON is a few KB); `gi_region` carries simplified geometry (≤ 50 KB) + buffer.

## 4. Grade computation (B05, mirrored by mobile M03)

Profile JSON (`standards_profile_versions.rules`), validated by `StandardsProfileRules`:
```json
{
  "schema_version": 1,
  "standard": { "name": "AGMARK Grading and Marking Rules — Dry Chillies and Capsicums", "schedule": "IV", "edition": "LOAD_FROM_STANDARD", "clause_ref": "LOAD_FROM_STANDARD" },
  "grades": ["Special", "Standard"],
  "fail_grade": "Below grade",
  "parameters": [
    { "code": "moisture", "name_en": "Moisture", "name_local": "ஈரப்பதம்", "unit": "%", "method_ref": "AGMARK Sch. IV moisture method",
      "required": true, "grading_stage": "grading", "capture_stages": ["drying_end", "intake", "grading"],
      "limits": { "Special": { "max": 10.0 }, "Standard": { "max": 11.0 } },
      "plausible": { "min": 0, "max": 100 },
      "sources_allowed": ["instrument", "lab"], "max_grade_for_source": { "visual": "Standard" } },
    { "code": "extraneous_matter", "unit": "%", "required": true, "limits": null, "status": "load_from_standard", "plausible": { "min": 0, "max": 100 } },
    { "code": "unripe_marked_fruits", "unit": "%", "required": true, "limits": null, "status": "load_from_standard" },
    { "code": "broken_fruits", "unit": "%", "required": true, "limits": null, "status": "load_from_standard" },
    { "code": "insect_damaged", "unit": "%", "required": true, "limits": null, "status": "load_from_standard" },
    { "code": "total_ash", "unit": "%", "required": false, "limits": null, "status": "load_from_standard" },
    { "code": "capsaicinoid", "unit": "%", "required": false, "role": "label_declaration", "declare_for_grades": ["Special"] },
    { "code": "asta_colour", "unit": "ASTA", "required": false, "role": "contract_spec" }
  ],
  "lab_certified_requires": { "any_parameter_source": "lab", "nabl_no_present": true },
  "lot_gates": { "ready_for_sale": { "parameter": "moisture", "stage": "drying_end", "max": 11.0 } },
  "trail_rules": [ { "parameter": "moisture", "stages": ["drying_end", "intake", "grading"], "rule": "non_increasing", "tolerance": 0.5, "override_with_reason": true } ],
  "yield": { "ceiling_kg_per_acre": 1000, "warn_margin_pct": 20, "hold_margin_pct": 30, "note": "illustrative; calibrate after season 1" }
}
```
Engine `grade_engine.compute(rules, readings) -> GradeResult`, pure: pick latest reading per parameter at `grading_stage`; missing required with non-null limits → `incomplete`; per parameter the best grade whose limits hold, else `fail_grade`, capped by `max_grade_for_source`; batch grade = worst per-parameter grade (FR48); `lab_certified` when any reading source=lab with NABL number. Parameters with `limits: null` are skipped and raise an `info` flag `profile_incomplete`. Plausibility at entry (FR50): range, instrument calibration, trail rule (override with reason → flag), unknown parameter, unit mismatch → 422.

## 5. Seed data (B12) — mirrors PRD §12 reference batch with its known problems
FPO `VIRUDHAI_SCFC_VINOBA_BHAVA_FPO` (P Thottiyangulam, Tiruchuli, Virudhunagar, TN; FSSAI/GI numbers `DEMO-…`); crop VIRUDHUNAGAR SAMBA VATHAL / விருதுநகர் சம்பா வத்தல், GI 883; region v0 district outline and v1 taluk union from `infra/scripts/gi_boundary/build_virudhunagar.py` (D-019), buffer 150 m; inputs Organic Fertilizer Gold (Amul), Panjakavya, Azospirillum, Phospho Bacteria, Effective Micro Organism; users 1 admin, 1 field officer, 1 QC, 3 farmers with consents; lots `LOTD02DADB6` (packed 69 / used 100), `LOT3072CB6A` (140 / 200; nursery 2025-09-05 before ploughing 2025-09-30), `LOT0EF81415` (77.6 + 195 / 20); all declared Inorganic + IPM; batch `FGP8T4033HM7`, super-lot `COMBO_LOT_6C1DCCFE`, procured 320 kg, grading "A" 20 kg 2026-07-30 without readings. Expected flags: `quantity_mismatch` ×3, `practice_tag_contradiction` ×3, `ipm_without_pest_event` ×3, `yield_check_unavailable` ×3 (no lot has a harvest quantity, PRD §12.2), no `event_out_of_order`, `grading_loss_high` ×1 (320 kg received → 20 kg graded = 93.75 % loss), no `batch_quantity_unattributed` (Σ shares 320 kg = received 320 kg) (Architect-Gate rulings 2026-10-31, D-030); warns never block publish, holds do; grade "A" → 422 `unknown_grade_for_profile`; approve → 409; publish → 409; after fixes publish succeeds (GI verified, shares 31.25/62.5/6.25, units everywhere).
