# P07-2 (P2, blocks P07 acceptance): live mode (`E2E_LIVE=1`) cannot pass, and does not create a batch

<!-- Purpose: defect found while verifying P07 live (docs/agents/qa/P07.md). Serves: docs/agents/qa-rubric.md.
Readers: Orchestrator, WEB Reviewer, P07 owner. -->

**Found by:** WEB Verifier, 2026-11-01, `main` `29c40b8`…`6e99f1f`, isolated compose stack (project `agritrace-p07qa`,
ports 8010/5443/4576), fresh `make seed` equivalent.
**Severity:** P2 (test-only; no product data at risk). The P07 acceptance line "… twice without reseed" cannot be met live.
**Owner:** P07 (`apps/portal/e2e/chain.spec.ts`, `e2e/support.ts`).

Three independent causes, each deterministic:

1. **`ok()` parses JSON from a 204.** `POST /v1/auth/otp/request` answers `204 No Content` (openapi.json), and
   `liveQcGrade` → `ok()` calls `r.json()` → `SyntaxError: Unexpected end of JSON input` (chain.spec.ts:40). Every live
   run fails in 0.5–2 s before the browser opens. Logs: [04](../P07/logs/04-e2e-live-invocation1.txt),
   [06](../P07/logs/06-e2e-live-rerun2.txt). Fix: read `r.text()` and parse only when non-empty.
2. **OTP rate limit between the two runs.** Both runs sign the QC officer (and the admin) in with a fresh OTP; the API
   allows one OTP per phone per 60 s (`identity/service.py:105 OTP_RESEND_AFTER`). Live run 1 takes ~14 s, so run 2's
   `otp/request` gets `429 rate_limited` ([10](../P07/logs/10-e2e-live-diagnostic-2fixes-fresh.txt)). Run 2 passes
   when started > 60 s later ([11](../P07/logs/11-e2e-live-diagnostic-run2-spaced.txt), 10.9 s). Fix: sign the QC
   officer in once per worker (or refresh), or wait out `retry_after_s`. The 10-OTP-per-day cap also means a developer
   can run the live suite only ~4 times a day per seed.
3. **Live mode skips "create batch"** and works on the reference batch FGP8T4033HM7 (TODO.md:305), so the acceptance
   step "create batch" is never exercised live, and the run grades, packs and publishes the shared reference batch. On
   the shared stack this would alter FGP8T4033HM7 and the chain's PIN 1234 does not match the Verifier PIN 2468 set
   there earlier, so the Verifier ran it only on an isolated stack.

Not a cause: the strict-mode failure in P07-1 also hits live mode (fixed in the same scratch copy).
