# B08-2 (P2): `POST /v1/intakes` answers 500 on a Postgres deadlock with the rules worker

<!-- Purpose: defect found live while building P03/P04 fixtures (docs/agents/qa/P03.md). Serves: docs/agents/qa-rubric.md.
Readers: Orchestrator, BE Reviewer, owners of B08 (rules_flags.store_flags) and B09 (create_intake). -->

**Found by:** WEB Verifier, 2026-11-01, image from `main` `6e99f1f`, isolated compose stack, host load ~6–20.
**Severity:** P2. The intake is rolled back (no partial data) and the client gets `500 internal_error`, not a
retryable code; a QC phone would retry it, the portal user sees "Something went wrong".
**Owner:** B08 (`rules_flags/service.py:176 store_flags`) with B09 (`lots_batches/service.py:805 create_intake`).

## Reproduction (1 of 11 intakes in run 2; seen as 3 deadlock tracebacks in that API log)
Officer pushes a `packing` event on a new lot (enqueues `rules.check_event`); within ~1 s the admin posts a moisture
reading, `POST /lots/{id}/ready` and `POST /v1/intakes`. `create_intake` → `run_gate_checks` → `store_flags` inserts a
flag while the worker's task updates the same lot:
```
ERROR: deadlock detected
Process 239: INSERT INTO flags (...)            -- index uq_flags_dedupe_key
Process 357: UPDATE lots SET gi_eligible=$1, gi_hold_reason=$2 ... WHERE lots.id = $3
```
Evidence: [P03/logs/intake-deadlock-db.txt](../P03/logs/intake-deadlock-db.txt),
[P03/logs/intake-deadlock-api.txt](../P03/logs/intake-deadlock-api.txt). Related to B16-1 (same two writers).
Fix direction: take the lot row lock before inserting flags in both paths (one lock order), or retry the
transaction on `DeadlockDetectedError`.

## Resolution (WP-B20, 2026-11-02)
**Closed by B19 (20/20 clean).** Lock order now: the worker's `check_event` locks the event, stores event-rule
flags (codes disjoint from the lot rules', so never a row or key the intake touches), then waits on the lot lock
in `run_gate_checks` before any lot flag or `UPDATE lots`; `create_intake` holds the lot `FOR UPDATE` first and
takes no batch lock (a lot check without `batch_id`). No cycle remains. Live on the compose stack (api/worker
image with B19's `key_share` locks): 20 runs, no pause, officer pushes harvest + packing then the admin posts
moisture, ready and `POST /v1/intakes` while both `rules.check_event` tasks run → 20/20 intakes 201, 0
`deadlock detected` in api, worker and db logs. Lock order unchanged. As a backstop, a Postgres deadlock or
serialization failure (SQLSTATE 40P01/40001) now answers 503 `retry_later` with `Retry-After: 1` instead of 500
(`core/errors.py` `_db_error`). Details: [docs/agents/reports/B20.md](../../reports/B20.md).
