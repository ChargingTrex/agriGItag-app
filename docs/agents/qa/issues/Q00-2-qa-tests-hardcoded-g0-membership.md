# Q00-2 (P2, CI red): `qa/tests` fails on main because a test pins the G0 WP list

**Found by:** Q00 Verifier, 2026-11-01, main @ `c0962da`, while closing the deferred lines.
**Severity:** P2. The CI `qa` step (`.github/workflows/ci.yml:45`) is red on main. The harness logic is right; the test is brittle.
**Owner:** Q00 harness (test only). One-line fix.

## Reproduction
```
uv run --no-project --with pytest --with pyyaml --with robotframework==7.5 pytest qa/tests -q
# 1 failed, 101 passed
# qa/tests/test_scripts.py:153  assert gate.resolve(["G0"], gates) == {"B00", "Q00"}
# AssertionError: assert {'B00', 'B17', 'Q00'} == {'B00', 'Q00'}
```
Evidence: `docs/agents/qa/Q00/logs/32-qa-tests.txt`.

## Cause
`test_gate_readiness_reads_checklist_and_flags_placeholders` reads the real `CHECKLIST.md` and asserts that G0 is exactly `{B00, Q00}`. Commit `38c5922` (2026-11-01) added the hotfix row B17 under `## G0 Foundation`, so `resolve(["G0"])` now correctly returns `{B00, B17, Q00}`. `gate-readiness.py G0` itself still passes (log 33).

## Fix options
- Make the assertion a superset, like the G1 line below it already is: `assert gate.resolve(["G0"], gates) >= {"B00", "Q00"}`.
- Or have the test write its own small CHECKLIST fixture so the WP list can change freely.

## Also seen (not a Q00 defect)
`gate-readiness.py B02` exits 1: the six `qa/robot/api/identity.robot` tests are still tagged `not-ready`, even though B02 is verified PASS (commit `c0962da`). That test's `gate.main(["B02"]) == 1` assertion is still true for now, but a G2 gate run will flag B02 until those placeholders are turned into real tests (log 33).
