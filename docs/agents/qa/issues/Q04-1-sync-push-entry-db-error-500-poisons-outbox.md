# Q04-1 (P2): one entry whose insert fails in Postgres turns the whole `/v1/sync/push` into a 500, and the retry fails the same way

<!-- Purpose: Verifier defect report for WP Q04 (Schemathesis fuzz on /sync/push). Serves: docs/agents/qa-rubric.md (P2 with reproduction), PLAN §7.5 Q04. Readers: Orchestrator, BE Reviewer, B06/B15 owners (sync push), M-series owners (outbox). -->

**Found by:** Q04 Verifier, 2026-11-02. Schemathesis 4.33.0 (`--checks all -n 200`), confirmed with minimal hand-made bodies. Tree `main` `af67f30`/`a51d071`; the running api image is `agritrace-api:dev` `ed2d0b72` (built 23:53 IST, before B20). The code path below is the same on main (`apps/api/agritrace/modules/events/service.py` `push`, lines 996-1011).
**Severity:** P2. No row is lost or corrupted on the server. But the push contract says "each entry is its own transaction, one bad entry never rejects the batch" (`SyncEntry`/`SyncPushIn` descriptions), and here one bad entry rejects the batch. The entries after it never get processed. The phone's retry sends the same batch and gets the same 500, so a phone holding such an entry is stuck: nothing captured after it reaches the server. **This becomes P1 if the outbox keeps retrying the head of the queue for ever, or drops it after N failures** (M-series outbox behaviour, not checked here).

## What happens
`push()` catches `AppError`, plus the `DBAPIError`s that `append_only_error()` maps. Any other `DBAPIError` is re-raised (`if (mapped := append_only_error(e)) is None: raise`), so the request ends in the generic 500 `internal_error`. Entries before the bad one are already committed. Entries after it are never run.

Two input shapes pass Pydantic validation but are refused by Postgres:
1. **NUL (`\u0000`) in any string that reaches jsonb or text.** Example: `payload.description` of an event. asyncpg raises `UntranslatableCharacterError: unsupported Unicode escape sequence` at `service.py:490 _add_version`, on the INSERT into `event_versions`.
2. **An integer above int32**, e.g. `instance_no: 3000000000`. `EventVersionIn.instance_no` is `Field(1, ge=1)` and has no upper bound, while the column is `INTEGER`. The same applies to every other unbounded `int` that ends in an INTEGER column.

## Reproduction (farmer +919000000091 on their own open lot; log `docs/agents/qa/Q04/logs/05-sync-push-5xx-repro.txt`, R3, R5, R9)
```
POST /v1/sync/push   (Authorization: Bearer <farmer>)
{"device_id":"bac968ee-782a-454f-8bc4-6d14a3a687ec","app_version":"1.0.3","device_time":"2026-11-01T20:00:21Z",
 "entries":[{"client_id":"01a198b2-dfe4-73f7-ad83-666a695e9e5f","kind":"event_version","data":{
   "event_id":"01a198b2-dfe4-731c-a1b8-895315a731b9","version_no":1,"subject_type":"lot",
   "lot_id":"45d6230a-20e8-4c1b-a578-c496127d802e","plot_id":"4c50d79a-c871-4ded-8a27-17a65358c4cb",
   "event_type":"problem","instance_no":1,"occurred_on":"2026-11-02",
   "payload":{"problem_type":"pest","description":"Q04 NUL\u0000probe"},
   "clocks":{"device_time":"2026-11-01T20:00:21Z"},"gps":{"lat":9.585,"lon":78.105,"accuracy_m":6}}}]}
-> HTTP 500 {"error":{"code":"internal_error",...}}
```
R5 sends `[clean, NUL, clean]` twice and gets 500 both times. The DB then holds only the first event: `Q04 R5 first (clean)`. The third event never landed.
R9 sends `[clean, instance_no=3000000000, clean]`, with the same result.

## Fix options (the Verifier does not fix)
- Root cause, in shared code: in `push()`, turn an unmapped `DBAPIError` (asyncpg `DataError` family: `UntranslatableCharacterError`, `CharacterNotInRepertoireError`, `NumericValueOutOfRangeError`, int overflow) into a per-entry `rejected` with a registered code, e.g. `validation_error`, and let the batch continue.
- Validate at the trust boundary as well: a shared Pydantic string type that rejects `\x00`, and `le=2**31-1` on every int that maps to an INTEGER column (`instance_no`, `version_no`, `failures`, `photo_upload_ms`, ...). Add one integration test per shape.

## Resolution (B21, re-verified by Q05 2026-11-02)

**Closed.** B21 rejects a NUL or an int32 overflow per entry at the push boundary, with a class-22 DB backstop. On the rebuilt shared stack (image `sha256:39b06091`, main `06b71f4`), R3 → `rejected`. R5 `[clean, NUL, clean]`, R9 `[clean, instance_no 3e9, clean]` and D1 (5,000 lists deep with a NUL) each → accepted/rejected/accepted with HTTP 200, and psql holds exactly the clean events. Schemathesis: 3 runs, 1,004 cases, 0 × 5xx. Evidence: `docs/agents/qa/Q05/logs/02*.txt`, `03-sync-push-probes.txt`; `docs/agents/qa/Q04.md` §"Re-verified after B21".
