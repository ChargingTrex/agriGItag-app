# Q04-2 (P2): `/v1/sync/push` telemetry fails the request with a 500 after the entries are already committed

<!-- Purpose: Verifier defect report for WP Q04 (Schemathesis fuzz on /sync/push). Serves: docs/agents/qa-rubric.md (P2 with reproduction), PLAN §7.5 Q04, §13 F1. Readers: Orchestrator, BE Reviewer, B15 owner (sync metrics). -->

**Found by:** Q04 Verifier, 2026-11-02. Schemathesis found it first (test case `c0uwm9` in `docs/agents/qa/Q04/logs/04-schemathesis-sync-push.txt`, and the second 500 in `04b-…-continue.txt`), and minimal bodies confirmed it. The running image predates B20, but the code is unchanged on main (`service.py` `_store_metrics`, lines 1023-1035; `schemas.py` `SyncMetricIn` lines 247-255).
**Severity:** P2. Entries pushed in the same request are committed first. The phone then sees a 500, retries, and gets `duplicate` for them, so nothing is lost. But the push keeps failing for as long as the phone keeps sending the bad telemetry, and `sync_cursors.last_push_at` is never updated.

## What happens
`_store_metrics` inserts `metrics[]` together with `body.app_version` into `sync_metrics`. The envelope validation accepts values that Postgres then refuses:
- a NUL in `app_version` (`SyncPushIn.app_version` has only `maxLength 32`) or in `network_type`. Error: `CharacterNotInRepertoireError: invalid byte sequence for encoding "UTF8": 0x00`.
- `failures` or `photo_upload_ms` above 2^31-1. These are `int` with `ge=0` and no upper bound, while the columns are INTEGER. Error: `DataError: value out of int32 range`.

## Reproduction (field officer +919000000002; log `docs/agents/qa/Q04/logs/05-sync-push-5xx-repro.txt`, R1, R4, R6, R7, with controls R2 and R8)
```
POST /v1/sync/push
{"device_id":"a213283a-e290-452f-ba6a-f94adf65b3bf","app_version":"1.0.3\u0000","device_time":"2026-11-01T20:00:21Z",
 "entries":[],"metrics":[{"entry_client_id":"3b1f9e4f-c9d6-46e6-baf7-2b6aecf87729","saved_at":"2026-11-01T20:00:21Z"}]}
-> HTTP 500 internal_error            (R2: the same app_version without metrics -> 200)

{"device_id":"…","app_version":"1.0.3","device_time":"…","entries":[],
 "metrics":[{"entry_client_id":"…","saved_at":"…","failures":3000000000}]}
-> HTTP 500 internal_error            (R8: failures 2147483647 -> 200; R7: photo_upload_ms 3000000000 -> 500)
```
Also seen in the fuzz run: `saved_at` years 0001 and 5383 were accepted and stored (13 `sync_metrics` rows). This is not a 5xx, but implausible telemetry is stored unchecked.

## Fix options (the Verifier does not fix)
- Bound the fields in `SyncMetricIn`/`SyncPushIn` (`le=2**31-1`, a no-NUL string type, plausible `saved_at`/`acked_at`). Each fix then becomes a 422 at the boundary. The same shared types fix Q04-1.
- Or treat telemetry as best effort: store it in its own savepoint and drop bad rows with a log line, so a broken metric never fails a push.

## Resolution (B21, re-verified by Q05 2026-11-02)

**Closed.** A NUL in `app_version`/`network_type` and `failures`/`photo_upload_ms` above 2^31-1 now get 422 `validation_error` at the envelope (R1, R4, R6, R7), before any entry is written. The controls R2 and R8 (`failures` = 2147483647) get 200. Not covered: the plausibility of `saved_at` years 0001/5383. That is not a 5xx and is still listed in TODO. Evidence: `docs/agents/qa/Q05/logs/03-sync-push-probes.txt`.
