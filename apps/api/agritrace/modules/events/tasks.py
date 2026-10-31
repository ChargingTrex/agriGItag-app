"""Celery tasks of the events module: verify an uploaded evidence photo, then build its WebP variants.

Serves: FR61 (checksum and EXIF time/GPS checked against the event), plan §13 B6 (WebP variants), D-009
(Celery; `asyncio.run` per task), D-011.
Callers: the Celery worker (`agritrace.worker` autodiscovers this module); enqueued by name from
`events.service.confirm_photos` (`events.verify_photo`) and from `verify_photo` itself
(`events.make_variants`, `rules.check_event`).
"""

import asyncio
import uuid
from collections.abc import Awaitable, Callable
from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from agritrace.core import task_names
from agritrace.core.config import get_settings
from agritrace.core.enums import PhotoStatus
from agritrace.modules.events import evidence
from agritrace.worker import app


def _run[T](work: Callable[[AsyncSession], Awaitable[T]]) -> T:
    """Run async work with a session on a fresh event loop.

    Args:
        work: coroutine function taking a session.

    Returns:
        What `work` returned.

    Raises:
        Exception: whatever `work` raises (Celery records the failure).
    """

    async def main() -> T:
        """Open a session on a task-local engine, run the work, and close the engine with the loop.

        Returns:
            What `work` returned.
        """
        # DECISION D-009: each task runs `asyncio.run` with its own NullPool engine.
        #   ADV: no asyncpg connection ever crosses event loops, forks or threads (the shared API engine is
        #     never touched, so tests can run a task in a thread next to the app).
        #   COMPROMISE: one new connection per task; photo tasks are few, so pooling buys nothing.
        engine = create_async_engine(get_settings().database_url, poolclass=NullPool)
        try:
            async with async_sessionmaker(engine, expire_on_commit=False)() as session:
                return await work(session)
        finally:
            await engine.dispose()

    return asyncio.run(main())


def _send(name: str, **kwargs: Any) -> None:
    """Enqueue a follow-up task by name.

    Args:
        name: task name from `core.task_names`.
        **kwargs: task keyword arguments.

    Side effects:
        Publishes one Celery message.
    """
    app.send_task(name, kwargs=kwargs)


@app.task(name=task_names.EVENTS_VERIFY_PHOTO)  # type: ignore[untyped-decorator]  # celery ships no stubs
def verify_photo(photo_id: str) -> str:
    """Verify one uploaded photo, then enqueue its variants and the event's rule check.

    Args:
        photo_id: the photo's id.

    Returns:
        The resulting photo status.

    Raises:
        botocore.exceptions.ClientError: the object cannot be read (task fails; confirm can be retried).
        LookupError: unknown photo id.

    Side effects:
        Updates the photo row; enqueues `events.make_variants` (unless the checksum failed) and
        `rules.check_event` with hint `checksum_mismatch` / `exif_mismatch` when not verified.
    """
    status, event_id, changed = _run(lambda s: evidence.verify(s, uuid.UUID(photo_id)))
    if changed:
        if status != PhotoStatus.CHECKSUM_MISMATCH:
            _send(task_names.EVENTS_MAKE_VARIANTS, photo_id=photo_id)
        if event_id is not None:
            hints = [] if status == PhotoStatus.VERIFIED else [status.value]
            _send(task_names.RULES_CHECK_EVENT, event_id=str(event_id), photo_id=photo_id, hints=hints)
    return status.value


@app.task(name=task_names.EVENTS_MAKE_VARIANTS)  # type: ignore[untyped-decorator]  # celery ships no stubs
def make_variants(photo_id: str) -> dict[str, Any] | None:
    """Build and record the WebP variants of one verified photo.

    Args:
        photo_id: the photo's id.

    Returns:
        The `variants` record, or None when there was nothing to do.

    Raises:
        botocore.exceptions.ClientError: storage refused a read or write.

    Side effects:
        Two objects in the evidence bucket; updates `variants`.
    """
    return _run(lambda s: evidence.make_variants(s, uuid.UUID(photo_id)))
