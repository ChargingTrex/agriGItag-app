# Q02-2 (P2, environment): the shared stack's `api` runs an image built before B20, so the P06 audit reason is still missing live

<!-- Purpose: environment defect found while verifying Q02 (docs/agents/qa/Q02.md). Serves: docs/agents/qa-rubric.md
(defect with reproduction), P06 line 5 re-verification. Readers: Orchestrator, QA Lead, BE/WEB Verifiers (Q03, Q04). -->

**Found by:** WEB Verifier, 2026-11-02 01:23 IST, shared compose project `agritrace` (:8000).
**Severity:** P2. Not a code defect: main is right. But every live check on the shared stack runs pre-B20 API
code, which includes Q03/Q04's evidence from today.
**Owner:** Orchestrator (stack), no WP.

## Reproduction

```
docker inspect agritrace-api-1 --format '{{.Config.Image}} {{.Image}}'   # agritrace-api:dev sha256:ed2d0b72…
docker images agritrace-api                                             # dev  created 2026-11-01 23:53:31 +0530
git log -1 --format='%h %ci' -- apps/api/agritrace/modules/events/service.py   # 906ad92 2026-11-02 00:41:50 +0530 (B20)
docker exec agritrace-api-1 cat /app/agritrace/modules/events/service.py | diff - apps/api/agritrace/modules/events/service.py
# 544a545,546  > # B20: the audit search shows why a correction or undo was made (P06); ...
#               > **{k: r for k, r in (("reason_code", v.reason_code), ("reason_text", v.reason_text)) if r},
```
Effect, live: a field-officer correction (`reason_code wrong_quantity`) through `:8000` writes an `event.correct` audit
row without the reason, and the portal's Audit log shows "Reason: not in the audit log yet"
([Q02/logs/09-reverify-live-run1.txt](../Q02/logs/09-reverify-live-run1.txt),
[Q02/shots/P06-audit-search-correction-actor-and-reason_en.png](../Q02/shots/P06-audit-search-correction-actor-and-reason_en.png)).
The same correction sent to a side API container running main's source on the same DB stores
`reason_code` and `reason_text` in the diff ([Q02/logs/15-p06-b20-correction-data.txt](../Q02/logs/15-p06-b20-correction-data.txt)).
B20 itself works.

## Fix

Rebuild and restart the shared stack's app services from main when no other Verifier is mid-run:
`docker compose -f infra/docker-compose.yml up -d --build api worker`. B20 has no migration (DB head stays
`0004_lots_append_only`). Then re-run P06 line 5 in the portal (see Q02.md "Still open") once an admin OTP is
available again. The admin hit the 10/day cap at 01:28 IST; the oldest of those codes leaves the 24 h window at
21:49 IST on 2026-11-02.
