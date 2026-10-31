"""Celery tasks of the events module: verify an uploaded evidence photo, then build its WebP variants.

Serves: FR61 (checksum and EXIF time/GPS checked against the event), plan §13 B6 (WebP variants), D-009
(Celery; each task runs through `worker.run_db_task`: own loop, NullPool engine), D-011.
Callers: the Celery worker (`agritrace.worker` autodiscovers this module); enqueued by name from
`events.service.confirm_photos` (`events.verify_photo`) and from `verify_photo` itself
(`events.make_variants`, `rules.check_event`).
"""

import uuid
from typing import Any

from agritrace.core import task_names
from agritrace.core.enums import PhotoStatus
from agritrace.modules.events import evidence
from agritrace.worker import app, run_db_task


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
    status, event_id, changed = run_db_task(evidence.verify, uuid.UUID(photo_id))
    if changed:
        if status != PhotoStatus.CHECKSUM_MISMATCH:
            app.send_task(task_names.EVENTS_MAKE_VARIANTS, kwargs={"photo_id": photo_id})
        if event_id is not None:
            hints = [] if status == PhotoStatus.VERIFIED else [status.value]
            kwargs = {"event_id": str(event_id), "photo_id": photo_id, "hints": hints}
            app.send_task(task_names.RULES_CHECK_EVENT, kwargs=kwargs)
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
    return run_db_task(evidence.make_variants, uuid.UUID(photo_id))
