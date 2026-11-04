"""Unit tests of B24 without Docker: the daily OTP purge is on the beat schedule, and erasure needs `confirm`.

Serves: docs/ops/dpdp-data-subject-runbook.md §2-3 (erasure confirmation, `otp_challenges` retention), D-065.
Callers: pytest (`make test-unit`). The database side is in tests/integration/test_registry_b14.py.
"""

import pytest
from celery.schedules import crontab
from pydantic import ValidationError

from agritrace.core.config import get_settings
from agritrace.modules.registry.schemas import FarmerErase


def test_otp_purge_runs_daily_as_a_registered_task(monkeypatch: pytest.MonkeyPatch) -> None:
    """The beat entry names the task `registry.tasks` registers, once a day.

    Args:
        monkeypatch: sets the secret the settings need to load.
    """
    monkeypatch.setenv("JWT_SECRET", "unit-test")
    get_settings.cache_clear()
    from agritrace.modules.registry import tasks  # late: importing the worker reads the settings
    from agritrace.worker import app

    [entry] = app.conf.beat_schedule.values()
    assert entry["task"] == tasks.purge_otp_challenges.name in app.tasks
    assert isinstance(entry["schedule"], crontab)
    assert entry["schedule"].hour == {2} and entry["schedule"].minute == {30}


@pytest.mark.parametrize(
    "body", [{"reason": "DPDP-1"}, {"reason": "DPDP-1", "confirm": False}, {"confirm": True}]
)
def test_erase_needs_a_reason_and_confirm_true(body: dict[str, object]) -> None:
    """Without `confirm: true` or without a reason the request is refused (422 `validation_error`).

    Args:
        body: a request body missing one of the two.
    """
    with pytest.raises(ValidationError):
        FarmerErase.model_validate(body)
