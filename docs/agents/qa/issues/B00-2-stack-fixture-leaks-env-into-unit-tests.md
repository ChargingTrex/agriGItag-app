# B00-2 (P2): `stack` fixture leaves its env vars in `os.environ`, so `pytest tests` fails a unit test that passes alone

<!-- Purpose: Verifier defect report for WP B00. Serves: docs/agents/qa-rubric.md (P2 with reproduction). Readers: Orchestrator, BE Reviewer, B00 and B04 owners. -->

**Found by:** B00 Verifier, 2026-11-01, commit 5b091fd (main).
**Severity:** P2. `make test` (the B00 Makefile target, `uv run pytest`) is red on a clean tree because of test order; no product defect.
**Owner:** B00 (tests/conftest.py `stack`). Co-owner: B04 (tests/unit/test_notifications_service.py is not hermetic).

## What happens
`tests/conftest.py::stack` does `os.environ.update(ENV="test", …, JWT_SECRET=…, OTP_DEV_CODE="123456")` and never restores the old values (its docstring declares the side effect).
pytest collects `tests/e2e` and `tests/integration` before `tests/unit`, so every unit test that runs afterwards sees those variables.
`test_prod_refuses_missing_or_console_sms_provider` builds `Settings(_env_file=None, env="prod", jwt_secret="x"*32, sms_provider=…)`. `_env_file=None` skips the `.env` file but not `os.environ`, so `OTP_DEV_CODE=123456` reaches the prod validator, which fails first on "no OTP_DEV_CODE" (apps/api/agritrace/core/config.py:98) instead of the SMS-provider message the test expects.

## Reproduction
```
cd apps/api
uv run pytest tests/unit -q -p no:cacheprovider          # 617 passed      (logs/04-pytest-unit.log)
uv run pytest tests -q -p no:cacheprovider -rfE          # 5 failed, 763 passed (logs/full-suite.log)
FAILED tests/unit/test_notifications_service.py::test_prod_refuses_missing_or_console_sms_provider[None]
FAILED tests/unit/test_notifications_service.py::test_prod_refuses_missing_or_console_sms_provider[console]
E   Expected regex: 'requires a real SMS_PROVIDER'
E   Actual message: '1 validation error for Settings\n  Value error, ENV=prod requires JWT_SECRET of at least 32 bytes and no OTP_DEV_CODE [type=value_error]'
```
Shorter, confirmed: `OTP_DEV_CODE=123456 uv run pytest tests/unit/test_notifications_service.py -q -k prod_refuses` gives 2 failed; without the variable 2 passed (`docs/agents/qa/B00/logs/13-env-leak-repro.log`).

## Fix options (pick one; the Verifier does not fix)
- Fixture: save and restore the keys it sets (`pytest.MonkeyPatch.context()` in a session fixture, or `mock.patch.dict(os.environ, …)`), and clear the cached settings again on teardown.
- Test (B04): `monkeypatch.delenv("OTP_DEV_CODE", raising=False)` before building the prod `Settings`.
