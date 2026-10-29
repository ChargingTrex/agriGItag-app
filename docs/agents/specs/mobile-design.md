# Mobile design spec (from the approved plan; binding for M00–M13)

Companion to `docs/agents/plan-summary.md` §7.2 and §13. Flutter, Material 3, Riverpod + go_router (D-013), Drift (D-014), Android 8+ (minSdk 26) and iOS 13+.

## 1. Folder layout (feature-first)
```
apps/mobile/
  pubspec.yaml                 # flavors dev/staging/prod
  lib/main_{dev,staging,prod}.dart  app.dart  bootstrap.dart
  lib/core/
    api/      api_client.dart (dio + auth/idempotency interceptors, timeouts connect 10 s / request 30 s), endpoints.dart
    db/       database.dart, tables/*.dart, daos/*.dart, migrations/
    sync/     sync_service.dart, outbox_processor.dart, photo_uploader.dart, pull_service.dart, connectivity.dart (reachability = HEAD /v1/healthz, 3 s), background_scheduler.dart, metrics.dart
    refdata/  bundle_repository.dart, models/
    rules/    gi_check.dart, yield_check.dart, event_order.dart, moisture_limit.dart, practice_tags.dart, grade_calculator.dart   # previews only (D-006)
    capture/  camera_capture.dart, photo_compressor.dart (long edge 1600 px, JPEG q≈80 stepping down to ≤ 350 KB; EXIF keeps only DateTimeOriginal, GPS, orientation), photo_quality_check.dart, gps_fix.dart, clocks.dart, voice_note_recorder.dart
    voice/    prompt_catalog.dart, voice_player.dart
    theme/    app_theme.dart, farmer_tokens.dart (ThemeExtension: minTarget 56, farmerTarget 64, gap 16), status_glyphs.dart
    l10n/     app_en.arb, app_ta.arb
    router/   app_router.dart (role redirect, /assist/:farmerId scope)
    widgets/  farmer_button, picture_card_grid, big_stepper, number_pad, status_badge, voice_prompt_bar, call_officer_button, confirm_scaffold, cloud_sync_indicator, assist_bar, gps_ring
    util/     ids.dart (UUIDv7), formatters.dart (Indian grouping, "14 Feb"), result.dart
  lib/features/ auth, farmer_home, event_log, problem_report, sell, money, history, settings, onboarding_farmer, officer_home, assist, flags, moisture_reading, qc_home, qc_intake, qc_grading, qc_packing, qc_meter (BLE stub), notifications
  packages/agritrace_api/      # generated dart-dio client from packages/openapi/openapi.json; never hand-edited
  assets/audio/{ta,en}/*.ogg  prompts.json  images/events/*.webp  fonts/NotoSansTamil-sub.ttf
  test/ (unit, widget, goldens/)  integration_test/  tool/ (gen_api.sh, size_check.sh, avd_go.sh)
```

## 2. Drift schema
```
Session   { id=1; userId; role (farmer|field_officer|qc); fpoId; deviceId; accessToken; refreshToken; pinHash?; locale; wifiOnlyPhotos bool (default false) }
Farmers   { farmerId pk; fpoId; name; village; photoPath?; hasSmartphone bool; language; status; json }
Plots     { plotId pk; farmerId; pinLat; pinLng; pinAccuracyM; pinMethod; declaredArea; areaUnit (acre|cent); surveyNoLocalOnly?; boundaryGeoJson?; giStatus; locked bool; version }
Lots      { lotId pk; plotId; farmerId; cropId; season; status; kgHarvested; kgPacked; lastMoisture?; qrPayload?; updatedAt }
Entries   { entryId pk (UUIDv7); rootId; version int; supersedesEntryId?; entryType; lotId?; plotId?; farmerId; instanceNo; payloadJson;
            deviceTime; gpsTime?; serverReceivedAt?; lat?; lng?; accuracyM?; locationStatus (ok|low_accuracy|none);
            enteredByUserId; assistMode bool; enteredRemotely bool; reasonCode?; status (saved|sent|confirmed|rejected|undone); undoDeadline; createdAt }
Media     { mediaId pk; entryId fk; kind; localPath; bytes; sha256; width; height; capturedAt; lat?; lng?; accuracyM?; uploadUrl?; uploadUrlExpiresAt?; uploadStatus (pending|uploading|done|failed); objectKey?; thumbPath; purgedAt? }
Outbox    { seq pk autoinc; kind (entry|media); refId; idempotencyKey; priority (0 entry, 1 media); attempts; nextAttemptAt; lastError?; status (waiting|sending|sent|confirmed|needs_attention); createdAt }
RefBundles{ bundleType pk; version; etag; fetchedAt; bodyJson; assetDir? }
SyncState { key pk; value }     // pull_cursor, last_sync_at, clock_skew_ms, pending_count_cache
SyncMetrics { id pk; entryId; savedAt; ackedAt?; photoUploadMs?; failures; networkType; shipped bool }
Tasks     { taskId pk; farmerId; lotId?; eventType; dueDate; promptId; source; done bool }
Flags     { flagId pk; farmerId; entryId?; plotId?; type; severity; status; detailJson; resolvedReason?; updatedAt }
Instruments { instrumentId pk; kind; label; calibrationDueDate }
FieldConfig { entity pk; json }  // from GET /v1/config/fields (D-017)
```
Indexes: Entries(lotId,status), Outbox(status,nextAttemptAt), Media(entryId), Entries(rootId,version). Schema dump test from day one.

## 3. Sync engine (plan §13 A1–A6, B1–B5, F1)
- Triggers: app open/resume; after each save (500 ms debounce) if reachable (HEAD /v1/healthz within 3 s); connectivity change → probe; WorkManager 15 min (Android), BGAppRefresh (iOS, best effort).
- One run, mutex-guarded: push entries oldest-first in batches ≤ 50 or ≤ 256 KB → ack writes serverReceivedAt, status confirmed, stores presigned URLs; push media for confirmed entries, 1–3 uploads in parallel by measured upload speed (≥ 1 Mbps up → 3), SHA-256 header, whole-PUT retry; skip media when wifiOnly && !onWifi; then pull with cursor; then `GET /v1/sync/reference?since=`.
- Retry only on network errors, 5xx, 429; backoff 2, 4, 8 … s with jitter, capped 5 min; other 4xx → needs_attention. Entries never die; after 7 days unsent → red triangle + voice prompt.
- Cloud icon = count(Outbox status != confirmed) as a stream.
- Clock skew: |deviceTime − serverReceivedAt| > 10 min → record clock_skew_ms.
- Storage: delete full-size file on confirm; keep ~10 KB thumbnail; "Phone is full" prompt purges confirmed media.
- Kill-safety: Outbox.sending older than 5 min → waiting on start.
- Metrics: SyncMetrics rows shipped in the next push envelope (`metrics[]`).

## 4. Screens (see plan-summary.md §7.2 and the User Flows doc)
Farmer F01–F17, Officer O01–O10, QC Q01–Q07 as in the plan. Every farmer screen: one job, ≥ 56 dp targets, icon + ≤ 2-word label + speaker, no free text (lint), Tamil first.
Form fields and their requiredness come from `FieldConfig` (D-017): disabled fields are not shown; required fields block the confirm tick.

## 5. Localisation and voice
`flutter gen-l10n`; `app_ta.arb` default, `app_en.arb`; voice prompt id = string key; Opus `.ogg` mono 24 kbps at `assets/audio/{locale}/{promptId}.ogg` with `prompts.json`; missing clip → text only + counter, no TTS. Other languages as downloadable bundles (D-016). `intl` en_IN grouping; dates `d MMM`.

## 6. Theming and accessibility
`useMaterial3: true`, `ColorScheme.fromSeed` (green), dynamic colour off, `materialTapTargetSize: padded`; `FarmerTokens` ThemeExtension; `textScaler` clamped 1.0–1.5; `Semantics(label)` on icon-only controls; contrast ≥ 4.5:1 in goldens; office roles minTarget 48.

## 7. Budgets (plan §13 D1–D2, BM-01/02/04)
Universal APK ≤ 100 MB hard ceiling; per-ABI AAB download target ≤ 30 MB; cold start < 3 s on the Go AVD; scripted event log < 20 s; "Sent" ≤ 5 s on normal 4G, ≤ 20 s on weak 4G.
