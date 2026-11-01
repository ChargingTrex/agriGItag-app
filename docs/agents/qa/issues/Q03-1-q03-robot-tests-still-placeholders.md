# Q03-1 (P2): the two Q03 Robot tests are still `not-ready` placeholders, so `gate-readiness Q03` fails

<!-- Purpose: Verifier defect report for WP Q03. Serves: docs/agents/qa-rubric.md, qa/README.md "Gate rule", PLAN §7.5 Q03. Readers: Orchestrator, QA Lead. -->

**Found by:** Q03 Verifier, 2026-11-02, `main` `af67f30`.
**Severity:** P2. The behaviour itself passes: it was checked by hand, see `docs/agents/qa/Q03.md` lines 2 and 3. But the gate rule needs real tests, and without them G4 cannot show this check again.

## What happens
`qa/robot/public/page.robot` still holds two placeholders tagged `WP-Q03 not-ready`, each with the body `Not Ready Q03`:
- `Page Is Served From Object Storage With The Backend Down` (FR-15)
- `Old Page Version Is Retrievable` (FR-17)

```
$ /tmp/w02rv/bin/python qa/scripts/gate-readiness.py Q03
Q03: 0 real Robot test(s)
NOT READY: 2 placeholder test(s) still tagged not-ready:
gate-readiness Q03: FAIL
```
Log: `docs/agents/qa/Q03/logs/00-gate-readiness.txt`. The Q03 declared paths include `qa/**`, so a Q03 worker owns writing them. A Verifier does not write tests.

## What the tests can do (the commands the Verifier ran)
- Backend down: `docker compose -f infra/docker-compose.yml stop api worker`, then GET `${S3}/public-pages/batches/<code>/index.html` and `qr.png` must return 200 with `text/html` / `image/png`. Then start the services again and wait for healthz. Commands and output: `docs/agents/qa/Q03/logs/04-backend-down-serve.txt`.
- Old version: `POST /v1/batches/{id}/rebuild`, wait until the build is `built`, `list-object-versions` shows 2 versions, and `?versionId=<old>` returns 200 with `Generation: 1`. Script: `docs/agents/qa/Q03/scripts/old-version-retrievable.sh`.
