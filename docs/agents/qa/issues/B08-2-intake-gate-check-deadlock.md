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
