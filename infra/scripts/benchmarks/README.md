# Benchmarks BM-01 to BM-16

Owned by the QA Lead (plan §8 and §13). The pass/fail numbers live in one place,
[`thresholds.yaml`](thresholds.yaml), copied from plan §8 and §13; where the 4G brief (§13) is tighter, it wins.
[`collect.py`](collect.py) judges results against that file.

| ID | What | How it is measured (owner WP) |
|---|---|---|
| BM-01 | Time to log an event | Flutter integration test drives the 3-tap harvest flow 10× on the Go AVD (M07, Q01) |
| BM-02 | Entry and photo reach the server on 4G | integration test with the `normal_4g` profile (M02, Q01) |
| BM-03 | Public page on Slow 3G | Lighthouse CI, "Slow 3G" preset (W02, Q03) |
| BM-04 | App size | `flutter build apk --release --analyze-size`; `bundletool get-size total` (M13, Q01) |
| BM-05 | Traceability completeness | seed batch → completeness %; reference batch flags (B11, B12, Q04) |
| BM-06 | Sync idempotency | replay the same outbox 3× (B06, M02, Q01) |
| BM-07 | API latency | `locust`, 50 users on sync + batch endpoints (Q04) |
| BM-08 | Grade engine correctness | table-driven tests from the Standards Profile (B05, Q04) |
| BM-09 | Privacy lint | `infra/scripts/privacy-lint.py` over built public pages + partner stub output (W02, B10, Q03) |
| BM-10 | Doc coverage | `infra/scripts/doc-coverage.py` (interrogate / dart doc / eslint-jsdoc) |
| BM-11 | Normal 4G entry + 1 photo | `qa/robot/mobile/network_profiles.robot`, `normal_4g` (M02, Q01) |
| BM-12 | Weak 4G entry + 1 photo | same suite, `weak_4g` |
| BM-13 | Airplane mode, then network restored | same suite, `offline` then `normal_4g` |
| BM-14 | Kill app mid-upload, relaunch | same suite |
| BM-15 | Same push replayed 5× | same suite / `qa/robot/api/sync.robot` (B06) |
| BM-16 | Public page on the normal 4G profile | Lighthouse with the `normal_4g` numbers (W01, Q03) |

Network numbers for BM-11..BM-16 live in `qa/robot/profiles.yaml`. They are simulator defaults from the 4G
brief, not field readings. BM-01 in §8 says "4-core throttled"; the Q00 Go AVD (`qa/avd/go_profile.ini`) has
2 cores as the Q00 title requires, which is the stricter setting.

## Recording a result

Each benchmark run writes one JSON file to `qa/results/benchmarks/` (name it `<BM-id>-<WP-or-gate>.json`):

```json
{"id": "BM-07", "metrics": {"p95_ms": 212}, "commit": "<sha>", "env": "docker stack, 8 CPU", "recorded_at": "2026-11-02T10:00:00+00:00"}
```

Metric names and units are the keys in `thresholds.yaml` (`_s` seconds, `_ms` ms, `_kb` KB, `_mb` MB, `_pct` %).
When several files share an id, the newest run wins: by `recorded_at`, else by file modification time. An older
passing run therefore never hides a newer failing one.

## Judging

```sh
uv run --with pyyaml python infra/scripts/benchmarks/collect.py --require BM-07   # a WP's benchmark ids
uv run --with pyyaml python infra/scripts/benchmarks/collect.py                   # Q05 sweep
```

The script merges the results into `docs/agents/qa/benchmarks.json` and prints Benchmark / Metric / Value /
Threshold / Status. A benchmark without results is MISSING, which is not a failure unless it is named with
`--require`. Exit code is 1 on any FAIL.
