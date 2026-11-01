# B16-1 (P2): a rules task that started before an intake closes the intake's fresh `quantity_mismatch` as `rule_passed`

<!-- Purpose: P2 defect found live while verifying B16 acceptance line 1 (G5 condition, rulings 2026-10-31b §1).
Serves: docs/agents/qa/B16.md, docs/agents/qa-rubric.md (P2 with reproduction). Readers: Orchestrator, BE Reviewer,
owners of B08 (rules_flags.store_flags) and B16. -->

**Found by:** BE Verifier, 2026-11-01, `main` `c0962da`, compose stack (real Celery worker), host load average 10–60.
**Severity:** P2. A warn flag that FR11/FR60 needs on the lot disappears (closed by the system, not by a person),
so the lot's flag list, the dashboard and the QC phone show no mismatch. No data is lost and nothing is published
wrongly: any later check on the lot reopens the flag (`reopens`: a `rule_passed` close reopens when the rule fires
again), and `create_batch`/`approve_grading`/`publish` run `run_gate_checks` first. Until then the lot looks clean.
**Owner:** B08 (`rules_flags.service.store_flags` / the task's read of the lot context); seen through B16's push path.

## Reproduction (3 of 3 without a pause, 0 of 2 with a 20 s pause)

Script: [B16/logs/live_b16_race.py](../B16/logs/live_b16_race.py), output [B16/logs/03-live-b16-race.log](../B16/logs/03-live-b16-race.log).

1. Field officer pushes a `packing` event (200 kg) on a QA lot. The push enqueues `rules.check_event`.
2. Within about a second: FPO admin posts a drying-end reading (10.0 %) and `POST /lots/{id}/ready`; the QC officer
   pushes `[quality_reading (intake), lot_intake 230 kg]`.
3. `create_intake` raises `quantity_mismatch` (warn, packed 200 → received 230, 15 %) and commits.
4. The `check_event` task, which read the lot's quantities before step 3 committed (no intake yet), reaches
   `store_flags`; its "stale" query runs after the commit, finds the new open `quantity_mismatch` in its scope and
   sets it `fixed` / `rule_passed`.

```
RESULT run 1 pause  0 s: after intake: fixed:rule_passed raised 17:29:54.52064 closed 17:29:54.559759 | after a later event check: open
RESULT run 2 pause  0 s: after intake: fixed:rule_passed raised 17:30:02.876104 closed 17:30:02.905483 | after a later event check: open
RESULT run 3 pause  0 s: after intake: fixed:rule_passed raised 17:30:11.326877 closed 17:30:11.37714 | after a later event check: open
RESULT run 4 pause 20 s: after intake: open:- raised 17:30:39.742461 closed - | after a later event check: open
RESULT run 5 pause 20 s: after intake: open:- raised 17:31:08.031778 closed - | after a later event check: open
```

The first live run of acceptance line 1 ([B16/logs/02-live-b16.log](../B16/logs/02-live-b16.log) §1) failed the
same way: the flag was raised at 17:27:45.617 and closed at 17:27:45.641 by `rules.check_event` (worker log
excerpt in that log's DB rows and `docker compose logs worker`). The integration test
`test_qc_push_receives_lot_idempotently` passes because the testcontainers world records tasks instead of running them.

## Cause

`store_flags` (apps/api/agritrace/modules/rules_flags/service.py:131–) closes every active flag of its subjects
and codes that this run did not raise. The run's facts were read earlier in the same READ COMMITTED transaction,
so a flag committed in between by another check (here `create_intake` → `run_gate_checks`) is closed by a run that
never saw the intake. Two checks of the same lot are not serialised.

## Fix options (for the owner; the Verifier changes nothing)

- Serialise checks per lot: take `SELECT … FOR UPDATE` on the lot (or batch) row at the start of
  `run_gate_checks`, before reading its context, as `create_batch` already does for merges.
- Or close only flags whose `raised_at` is older than the run's start (a run cannot close what it could not see).
- Add an integration test that runs a stale `check_event` after an intake commits (two sessions).

**Resolution (Orchestrator, 2026-11-02 00:30 IST, main 72c52b5 + B19):** live rerun of `live_b16_race.py` against the rebuilt stack: 5/5 runs (3 × no pause, 2 × 20 s) leave `quantity_mismatch` `open` after the intake and after a later check; log `../B16/logs/04-live-b16-race-after-B19.log`. Full backend suite on main 780/780.
