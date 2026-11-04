"""Celery task `registry.purge_otp_challenges`: delete OTP challenges past the DPDP retention, once a day.

Serves: docs/ops/dpdp-data-subject-runbook.md §3 (retention: `otp_challenges` purged 30 days after expiry),
DPDP Act 2023 (TODO §4 Compliance), D-009 (Celery; the task is idempotent).
Callers: Celery beat via `agritrace.worker` `beat_schedule` (daily); Celery worker (autodiscovered);
tests/unit/test_registry_b24.py, tests/integration/test_registry_b14.py.
"""

from agritrace.modules.registry import service
from agritrace.worker import PURGE_OTP_CHALLENGES, app, run_db_task


@app.task(name=PURGE_OTP_CHALLENGES)  # type: ignore[untyped-decorator]  # celery ships no stubs
def purge_otp_challenges() -> int:
    """Delete the expired OTP challenges older than `OTP_RETENTION_DAYS`.

    Returns:
        How many rows were deleted.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: database failure; beat runs it again the next day.

    Side effects:
        See `service.purge_otp_challenges`: deletes rows and commits.
    """
    return run_db_task(service.purge_otp_challenges)
