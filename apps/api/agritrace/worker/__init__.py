"""Celery application for background jobs (photo verification, rule checks, page builds, notifications).

Serves: D-009 (Celery on Redis), D-004 (same package as the API, second container), FR7 (notifications
worker, B04), TODO B02-r1 P3-11 (no task arguments in logs: the OTP code travels in `payload.code`),
B24 (daily `otp_challenges` purge on Celery beat, DPDP runbook §3).
Callers: `celery -A agritrace.worker worker` (infra/docker-compose.yml `worker`) and `... beat`, modules'
`tasks.py` (`@app.task(name=task_names.X)` and `run_db_task`), services enqueueing with
`app.send_task(task_names.X, ...)`, tests.
"""

import asyncio
import logging
import pkgutil
from collections.abc import Awaitable, Callable
from typing import Any, Concatenate

from celery import Celery
from celery.schedules import crontab
from celery.signals import worker_process_init
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

import agritrace.modules
from agritrace.core import db
from agritrace.core.config import get_settings

MASKED = "<masked>"

app = Celery("agritrace", broker=get_settings().redis_url)
# DECISION D-009: a task message is acknowledged only after the task finishes, and re-queued if the worker
#   process dies mid-task; no result backend and no `result_extended`, so task arguments are never stored.
#   ADV: a worker crash or deploy restart loses no photo check, rule run or SMS.
#   COMPROMISE: a task can run twice (crash after the side effect, before the ack), so every task must be
#     idempotent or tolerate a duplicate; `notifications.send` may send one SMS twice in that window.
app.conf.update(task_acks_late=True, task_reject_on_worker_lost=True)
# Periodic jobs, run by `celery -A agritrace.worker beat` (or a worker started with `-B`).
PURGE_OTP_CHALLENGES = "registry.purge_otp_challenges"  # DPDP retention, runbook §3 (B24)
app.conf.beat_schedule = {
    "purge-otp-challenges": {"task": PURGE_OTP_CHALLENGES, "schedule": crontab(hour=2, minute=30)},
}
# Lazy: each `agritrace.modules.<name>.tasks` is imported when the worker starts, if the module has one.
MODULES = [f"agritrace.modules.{m.name}" for m in pkgutil.iter_modules(agritrace.modules.__path__)]
app.autodiscover_tasks(MODULES)


class MaskTaskArguments(logging.Filter):
    """Replace task arguments in Celery's received/failure log records with `<masked>`.

    Celery logs `args` and `kwargs` (as reprs) in its failure line context and in the `data` extra that
    JSON formatters print; those can carry an OTP code or a phone number.
    """

    def filter(self, record: logging.LogRecord) -> bool:
        """Mask the arguments in place and keep the record.

        Args:
            record: a record from `celery.app.trace` or `celery.worker.strategy`.

        Returns:
            Always True (the record is logged, without arguments).

        Side effects:
            Overwrites `args` and `kwargs` in the record's context mapping, which is also its `data` extra.
        """
        # Celery passes one dict as the %-mapping, so `record.args` is that dict (and `record.data` too).
        if isinstance(record.args, dict):
            for key in ("args", "kwargs"):
                if key in record.args:
                    record.args[key] = MASKED
        return True


for _name in ("celery.app.trace", "celery.worker.strategy"):
    logging.getLogger(_name).addFilter(MaskTaskArguments())


# DECISION D-009: tasks call the async service layer via `asyncio.run` (`run_db_task`) on a NullPool engine
#   built for that one call; the cached `core.db` engine is also dropped after every fork.
#   ADV: no asyncpg connection is ever shared across a fork or reused on a closed event loop; the same code
#     runs in the worker and eagerly inside a test's thread.
#   COMPROMISE: one new database connection per task run (fine at pilot volume); a busy task type would
#     want a per-process loop with a pooled engine instead.
@worker_process_init.connect  # type: ignore[untyped-decorator]  # celery ships no stubs
def _fresh_engine_per_process(**_: Any) -> None:
    """Drop any engine inherited from the parent so each forked worker process builds its own.

    Args:
        **_: signal keyword arguments (unused).

    Side effects:
        Clears the cached engine and session factory in `agritrace.core.db`.
    """
    db.get_sessionmaker.cache_clear()
    db.get_engine.cache_clear()


def run_db_task[**P, T](
    work: Callable[Concatenate[AsyncSession, P], Awaitable[T]], *args: P.args, **kwargs: P.kwargs
) -> T:
    """Run an async service function with its own session from a synchronous Celery task.

    Args:
        work: coroutine function taking a session first, e.g. `service.deliver`.
        *args: further positional arguments for `work`.
        **kwargs: further keyword arguments for `work`.

    Returns:
        What `work` returned.

    Raises:
        RuntimeError: called from a thread that already runs an event loop (call it via `asyncio.to_thread`).
        Exception: whatever `work` raises, unchanged.

    Side effects:
        Opens one event loop and one database connection, both closed before returning.
    """

    async def _run() -> T:
        """Open a NullPool engine, run `work` in one session, dispose the engine.

        Returns:
            What `work` returned.
        """
        engine = create_async_engine(get_settings().database_url, poolclass=NullPool)
        try:
            async with async_sessionmaker(engine, expire_on_commit=False)() as session:
                return await work(session, *args, **kwargs)
        finally:
            await engine.dispose()

    return asyncio.run(_run())
