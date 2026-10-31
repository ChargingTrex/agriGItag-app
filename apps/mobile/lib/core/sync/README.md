Sync engine (M02): one `SyncService` (sync_service.dart) runs push → pull → photos → bundles for the signed-in user
only (D-029), one run at a time. Phases are plain functions: outbox_processor.dart (push), pull_service.dart,
photo_uploader.dart, bundle_fetcher.dart; retry.dart holds the retry/backoff policy, metrics.dart the F1 telemetry,
connectivity.dart the network type and the `HEAD /v1/healthz` probe, background_scheduler.dart the 15-min
WorkManager/BGAppRefresh task, enum_wire_names.dart the camelCase → snake_case wire names. Providers live in
lib/core/providers/sync_providers.dart. Tests: test/sync (fake server in harness.dart).
