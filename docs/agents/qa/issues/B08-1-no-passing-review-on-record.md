# B08-1 (P2, process): B08 has no passing review on record

<!-- Purpose: Verifier defect report for WP B08. Serves: docs/agents/qa-rubric.md, Ponytail row ("review file is
PASS") and the P2-with-reproduction rule. Readers: Orchestrator, BE Reviewer. -->

**Found by:** BE Verifier (B06/B13/B14/B07/B08), 2026-11-01, on commit `321b852` (main).
**Severity:** P2, process only. The code is not affected: every B08 acceptance line passes in tests and live ([B08.md](../B08.md)). The gap is that the rubric's Ponytail row ("review file is PASS") cannot be met from the files on record.
**Owner:** Orchestrator / BE Reviewer.

## What is on record

- `docs/agents/reviews/` holds only `B08-r1.md`, whose verdict is **FAIL (1 P1, 5 P2, 6 P3)**.
- No `B08-r2.md` exists. The round 2 fixes are described in `docs/agents/reports/B08.md` § Round 2.
- The only sign-off for round 2 is the merge commit message: `2f54ae9 merge: WP-B08 rules & flags (review FAIL r1 → r2 reopen fix confirmed by Orchestrator; integration tests deferred)`.

## Reproduction

```sh
ls docs/agents/reviews/B08-*            # -> docs/agents/reviews/B08-r1.md only
grep -n "Verdict" docs/agents/reviews/B08-r1.md   # -> ## Verdict: **FAIL** (1 P1, 5 P2, 6 P3)
git show -s --format=%s 2f54ae9         # -> "... review FAIL r1 → r2 reopen fix confirmed by Orchestrator ..."
```

## What the Verifier could confirm in its place (not a substitute for a review)

| r1 finding | Evidence today |
|---|---|
| P1-1: closed flags never come back | integration `test_hold_comes_back_after_auto_close` passes ([B08/logs/01](../B08/logs/01-pytest-integration-rules.log)) |
| P2-1: no auto-close / hold-sync test | the test above plus unit `test_closed_flag_reopens_when_the_system_closed_it_or_it_got_worse` and `test_apply_hold_keeps_another_modules_reason` pass ([02](../B08/logs/02-pytest-unit-rules.log)) |
| P2-3: contradictions go to the field officer | live: every `practice_tag_contradiction` flag has `assigned_role = fpo_admin` ([05](../B08/logs/05-live-assignees.log)) |
| P2-4 / P2-5 | recorded in TODO.md by the worker. Live seed: `yield_check_unavailable` appears 3 times, which matches PRD §12.2, not the §5 count of 2 |

## Fix

The BE Reviewer writes `docs/agents/reviews/B08-r2.md`, a round 2 review of `2f54ae9` against the r1 findings with its own verdict. The Orchestrator can also record a ruling that its merge-time confirmation stands in for the r2 file. Once either exists, B08 can be raised from CONDITIONAL to PASS without a rerun.

**Resolution (Orchestrator, 2026-11-01, commit a343b04):** `docs/agents/reviews/B08-r2.md` filed, recording the 2026-10-31 round-2 confirmation; B08 verdict CONDITIONAL → PASS, no rerun needed.
