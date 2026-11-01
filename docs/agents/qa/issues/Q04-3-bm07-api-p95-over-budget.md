# Q04-3 (P2): BM-07 fails: p95 of sync and batch endpoints is 2.0 to 3.1 s at 50 users (budget 300 ms)

<!-- Purpose: Verifier defect report for WP Q04 benchmark BM-07. Serves: docs/agents/qa-rubric.md (Benchmarks), PLAN §8 BM-07. Readers: Orchestrator, QA Lead, BE Reviewer, infra owner. -->

**Found by:** Q04 Verifier, 2026-11-02, on the compose stack (`agritrace-api:dev` `ed2d0b72`, pre-B20). Host: macOS, i7-8850H, 12 vCPU to Docker, 8 GB. Host load average 12-24 throughout, caused by other processes (IDE, Q06's isolated stack, other agents).
**Severity:** P2, for a benchmark threshold missed. No data loss and 0 request failures, but the plan budget (p95 ≤ 300 ms on the docker stack) is missed by 7 to 10 times.

## Measurements (`docs/agents/qa/Q04/locustfile.py`, locust 2.47.0, 50 users = 30 farmer sync + 20 staff batch reads, spawn 5/s, 3 min)
| Run | Requests | Fails | RPS | p50 | p95 | p99 | api CPU avg/max | worker CPU avg | db CPU avg | Log |
|---|---|---|---|---|---|---|---|---|---|---|
| run 1 | 4009 | 0 | 22.3 | 560 ms | **3100 ms** | 6500 ms | 117 % / 181 % | 332 % | 218 % | logs/02, 03 |
| rerun 1 | 4618 | 0 | 25.7 | 430 ms | **2000 ms** | 3700 ms | 113 % / 189 % | 435 % | 193 % | logs/02b, 03b |
| diag A2: 50 users, batch reads only, worker idle | 1779 | 0 | ~30 | 120 ms | 1700 ms | 2800 ms | ~100-195 % | idle | — | logs/02c |
| diag B: 5 users, both classes | 201 | 0 | ~3.4 | 58 ms | 1300 ms | 3900 ms | — | — | — | logs/02c |

Slowest names: `POST /v1/sync/push (new)` p95 2.9 to 4.4 s; `GET /v1/batches` p95 1.4 to 2.3 s.

## Diagnosis (observations, not a fix)
1. **One API process.** The image runs `uvicorn agritrace.main:app` with no `--workers` (`apps/api/Dockerfile:27`). The api container stays at about 100-190 % CPU, which is one Python process and its threads, even when only reads run (diag A2). At about 25 RPS the event loop is saturated.
2. **Rules work competes for the DB.** Every accepted event queues `rules.check_event`. The two runs queued about 5,400 checks, and the worker (default Celery concurrency = 12) ran at 330-620 % CPU and the DB at about 200 %. One check took 0.26 s at the start and up to 5-9 s at the end, because each check re-reads every event of the lot and the 6 QA lots now carry about 1,000 `problem` events each (6,265 rows added by this test). Reads stayed slow with the worker idle (diag A2), so (1) is the main cause and (2) adds to it.
3. **Default SQLAlchemy pool** (`create_async_engine(..., pool_pre_ping=True)`, `core/db.py:122`): 5 connections + 10 overflow, and a pre-ping round trip on every checkout.
4. **Host noise:** even at 5 users, p95 is 1.3 s with max 4.6 s (diag B), so the host itself adds second-scale stalls. A quiet-host rerun is needed before the number is final, but (1) and (2) would still be there on a quiet host.

## Suggested next steps (owner's choice; the Verifier does not fix)
- Run uvicorn with `--workers N` (or gunicorn with the uvicorn worker) in the compose image, and size the pool per worker. Record it as a DECISION if the pilot deploy differs.
- Make `rules.check_event` incremental (only the rules the event type touches, not a full scan of the lot), or debounce per lot.
- Rerun `docs/agents/qa/Q04/locustfile.py` on a quiet host after the image is rebuilt from main.

## Resolution (B21 `WEB_CONCURRENCY=4`, re-verified by Q05 2026-11-02): budget met, still open as a flaky P2

The test was the shared stack rebuilt from main `06b71f4` (1 uvicorn master + 4 workers), with Q04's locustfile, 50 users and 60 s. Run 1: p95 4200 ms, while the agritrace-q07 project restarted on the same host. Run 2: p95 380 ms, with one ~5 s stall across the whole host. **Run 3: p50 49 / p95 230 / p99 1000 ms, 35.2 RPS, 0 failures → PASS** (`docs/agents/qa/bench-results/BM-07-Q05-run3.json`, `Q05/logs/05-locust-bm07-run3.txt`). The budget was met only on the third run, so the rubric rerun rule keeps this as **P2: sensitive to host noise and to the rules backlog**. Each 60 s run leaves 400–1,000 `rules.check_event` tasks queued against lots of 1,100–1,725 events. The worker then runs at 400–590 % CPU and Postgres at 100–460 %. Remaining fix: the incremental `rules.check_event` (TODO, rules_flags). After that, rerun on the shared stack.
