# Benchmarks BM-01 to BM-16

Owned by the QA Lead (plan §8 and §13). Thresholds below are copied from the plan; the machine-readable
copy is [`thresholds.yaml`](thresholds.yaml), which [`collect.py`](collect.py) uses. Where the 4G brief
(§13) is tighter than §8, the brief wins.

| ID | What | How it is measured (owner WP) | Threshold |
|---|---|---|---|
| BM-01 | Median time to log an event | Flutter integration test drives the 3-tap harvest flow 10× on the Go AVD (M07, Q01) | p50 ≤ 60 s, p95 ≤ 90 s |
| BM-02 | Entry reaches the server on 4G | integration test with the `normal_4g` profile (M02, Q01) | entry ≤ 5 s, 300 KB photo ≤ 10 s |
| BM-03 | Public page on 3G | Lighthouse CI, "Slow 3G" preset (W02, Q03) | performance ≥ 90, LCP ≤ 2 s, first-view transfer ≤ 500 KB |
| BM-04 | App size | `flutter build apk --release --analyze-size`; `bundletool get-size total` (M13, Q01) | arm64 APK ≤ 100 MB (hard ceiling); download ≤ 30 MB (target, §13 D1); iOS IPA reported |
| BM-05 | Traceability completeness | seed batch → completeness % (B11, B12, Q04) | 100 % on the demo batch; reference batch (PRD §12.2) flags all 9 listed problems |
| BM-06 | Sync idempotency | replay the same outbox 3× (B06, M02, Q01) | row count unchanged; photo checksum unchanged |
| BM-07 | API latency | `locust`, 50 users on sync + batch endpoints (Q04) | p95 ≤ 300 ms on the docker stack |
| BM-08 | Grade engine correctness | table-driven tests from the Standards Profile (B05, Q04) | 100 % of PRD seed rows (chilli, turmeric, saffron, coffee) |
| BM-09 | Privacy lint | `infra/scripts/privacy-lint.py` over built public pages + partner stub output (W02, B10, Q03) | 0 hits for phone, ID, survey no., polygon |
| BM-10 | Doc coverage | `infra/scripts/doc-coverage.py` (interrogate / dart doc / eslint-jsdoc) | 100 % public symbols |
| BM-11 | Normal 4G (10 Mbps down / 5 Mbps up / 60 ms RTT): entry + 1 photo | `qa/robot/mobile/network_profiles.robot` with `normal_4g` (M02, Q01) | "Sent" within 5 s |
| BM-12 | Weak 4G (1 Mbps / 0.5 Mbps / 300 ms RTT): entry + 1 photo | same suite, `weak_4g` | "Sent" within 20 s |
| BM-13 | Airplane mode: save, then restore network | same suite, `offline` then `on` | saved instantly with grey cloud; sent automatically, no user action |
| BM-14 | Kill app mid-upload, relaunch | same suite | upload completes; exactly one entry and one photo on the server |
| BM-15 | Replay the same push 5× | same suite / `qa/robot/api/sync.robot` (B06) | exactly one record |
| BM-16 | Public page on the normal 4G profile | Lighthouse with the `normal_4g` numbers (W01, Q03) | initial HTML+CSS+JS < 100 KB; LCP < 2.5 s |

Network numbers for BM-11..BM-16 live in `qa/robot/profiles.yaml`; they are simulator defaults from the 4G
brief, not field readings. BM-01 in §8 says "4-core throttled"; the Q00 Go AVD (`qa/avd/go_profile.ini`) has
2 cores as the Q00 title requires, which is the stricter setting.

## Recording a result

Each benchmark run writes one JSON file to `qa/results/benchmarks/` (name it `<BM-id>-<WP-or-gate>.json`):

```json
{"id": "BM-07", "metrics": {"p95_ms": 212}, "commit": "<sha>", "env": "docker stack, 8 CPU", "measured_at": "2026-11-02T10:00:00Z"}
```

Metric names and units are the keys in `thresholds.yaml` (`_s` seconds, `_ms` ms, `_kb` KB, `_mb` MB, `_pct` %).

## Judging

```sh
uv run --with pyyaml python infra/scripts/benchmarks/collect.py --require BM-07   # a WP's benchmark ids
uv run --with pyyaml python infra/scripts/benchmarks/collect.py                   # Q05 sweep
```

The script merges every result into `docs/agents/qa/benchmarks.json` and prints Benchmark / Metric / Value /
Threshold / Status. A benchmark without results is MISSING (not a failure) unless named with `--require`.
Exit code 1 on any FAIL.
