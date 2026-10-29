"""Celery application for background jobs (photo verification, rule checks, page builds, notifications).

Serves: D-009 (Celery on Redis), D-004 (same package as the API, second container).
Callers: `celery -A agritrace.worker worker` (infra/docker-compose.yml `worker`), modules' `tasks.py`
(`@app.task(name=task_names.X)`), services enqueueing with `app.send_task(task_names.X, ...)`, tests.
"""

import pkgutil
from typing import Any

from celery import Celery
from celery.signals import worker_process_init

import agritrace.modules
from agritrace.core import db
from agritrace.core.config import get_settings

app = Celery("agritrace", broker=get_settings().redis_url)
# Lazy: each `agritrace.modules.<name>.tasks` is imported when the worker starts, if the module has one.
MODULES = [f"agritrace.modules.{m.name}" for m in pkgutil.iter_modules(agritrace.modules.__path__)]
app.autodiscover_tasks(MODULES)


# DECISION D-009: tasks call the async service layer via `asyncio.run` with a fresh engine per process.
#   ADV: no asyncpg connection is ever shared across a fork.
#   COMPROMISE: each `asyncio.run` opens a new event loop, so the first WP that adds a DB task must
#   `await db.get_engine().dispose()` before returning (or switch the worker engine to NullPool).
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
