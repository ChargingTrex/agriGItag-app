# P07-1 (P2, blocks P07 acceptance): the chain's "Publish or Download labels" check fails in strict mode, in mock and live mode

<!-- Purpose: defect found while verifying P07 (docs/agents/qa/P07.md). Serves: docs/agents/qa-rubric.md (defect with
reproduction). Readers: Orchestrator, WEB Reviewer, P07 owner. -->

**Found by:** WEB Verifier, 2026-11-01, `main` `29c40b8`…`6e99f1f` (no portal change in that range), host load 8–40.
**Severity:** P2 by the rubric's P1 list (no data loss, privacy leak or crash), but it fails both P07 acceptance runs and
turns the CI `portal` job red: `npm run e2e` (mock mode, CI) fails deterministically.
**Owner:** P07 (`apps/portal/e2e/chain.spec.ts`).

## Reproduction (3 of 3 runs: mock full suite, mock chain-only rerun, live diagnostic)

```
cd apps/portal && npm run e2e            # or: npx playwright test e2e/chain.spec.ts
✘ chain run 1 … Error: strict mode violation: getByRole('button', { name: 'Publish', exact: true })
  .or(getByRole('button', { name: 'Download labels' })) resolved to 2 elements
  > 269 |   await expect(publish.or(labels)).toBeVisible();
```
Logs: [P07/logs/12-e2e-mock-full.txt](../P07/logs/12-e2e-mock-full.txt) (4 passed, chain run 1 failed, run 2 did not
run), [P07/logs/13-e2e-mock-chain-rerun1.txt](../P07/logs/13-e2e-mock-chain-rerun1.txt), and the live diagnostic
[P07/logs/07-e2e-live-diagnostic-ok-fix.txt](../P07/logs/07-e2e-live-diagnostic-ok-fix.txt).

## Cause

P05 (merged 19:50, `7dd1bbd`) shows the "Download labels" button on every batch page, greyed with its reason before
publishing (`features/exports/BatchExports.tsx`, `GatedButton`). P07 merged main in at 20:11 but its chain was last run
before that; `walkBatchGates` assumes exactly one of the two buttons is on the page. Both are, so `.or()` matches two
elements and the strict-mode `toBeVisible()` throws.

## Fix (one line, P07 path)

`await expect(publish.or(labels).first()).toBeVisible();` (or wait for `publish` only when the page is not yet
published). With that line and P07-2's fixes, a scratch copy of the spec passed the live chain (run 1 14.1 s, run 2
10.9 s) — [P07/logs/08-diagnostic-diff.txt](../P07/logs/08-diagnostic-diff.txt).
