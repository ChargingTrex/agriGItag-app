# Q02-1 (P2): `src/features/members` Vitest coverage is 72.3 % statements / 74.0 % lines, below the 80 % bar

<!-- Purpose: defect found while verifying Q02 (docs/agents/qa/Q02.md). Serves: docs/agents/qa-rubric.md (defect with
reproduction), PLAN.md §7.5 Q02 "Vitest ≥ 80 % in features". Readers: Orchestrator, QA Lead, WEB Reviewer, P01 owner. -->

**Found by:** WEB Verifier, 2026-11-02, `main` `a51d071` (no `apps/` change up to `0814a25`), load 15–21.
**Severity:** P2 (no data loss, privacy leak or crash; a test-depth gap against the Q02 threshold).
**Owner:** P01 (`apps/portal/src/features/members/`).

## Reproduction (2 of 2 runs, same numbers)

```
cd apps/portal && npx vitest run --coverage --no-file-parallelism
 ...atures/members |   72.32 |    70.71 |   86.79 |   73.97 |
  PlotMap.tsx      |       0 |        0 |       0 |       0 | 25-146
```
Logs: [Q02/logs/01-vitest-coverage.txt](../Q02/logs/01-vitest-coverage.txt),
[Q02/logs/03-coverage-per-feature.txt](../Q02/logs/03-coverage-per-feature.txt) (members 115/159 statements,
108/146 lines; every other feature is ≥ 93 %; all features together 93.2 % / 94.5 %).

## Cause

`PlotMap.tsx` (39 statements, the lazily loaded MapLibre map: GI area bounds, pin, outline, satellite toggle) has
no Vitest test at all; `PlotPage` lazy-loads it and the tests never render it (jsdom has no WebGL). Without it,
members is 115/120 statements = 95.8 %. Its behaviour is exercised only by the mock Playwright test
`e2e/members.spec.ts` "plot page: the map chunk loads lazily and satellite tiles wait for the toggle", which v8
coverage does not count.

## Fix options (owner's choice)

1. A small Vitest for `PlotMap` with `maplibre-gl` mocked (`vi.mock`): bounds padded by `AREA_PAD_DEG`, the
   satellite source added only after the toggle. Covers the logic, not the WebGL drawing.
2. Or exclude `PlotMap.tsx` from the coverage `include` in `vite.config.ts` with a comment that the Playwright
   members spec covers it, and have the QA Lead accept that in the Q02 gate.

**Resolution (Orchestrator, 2026-11-02):** P11 merged — `PlotMap.test.tsx` (2 tests); members 95.6 % statements / 99.3 % lines; full Vitest 141/141. Q02 → PASS on the coverage line.
