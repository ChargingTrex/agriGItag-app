"""Celery task `publishing.build_page`: build one batch's static public page off the request path.

Kwargs contract (B09 `enqueue_page_build`): `batch_id`, `page_build_id` (str UUIDs), `build_no` (int).
Serves: D-007 (static page built by a worker job), D-009 (Celery; idempotent task), D-004 (enqueued by name
from `core.task_names`), FR15-FR17.
Callers: Celery worker (autodiscovered); `lots_batches` publish and `publishing` rebuild via
`app.send_task(task_names.PUBLISHING_BUILD_PAGE, kwargs=...)`; tests/integration/test_publishing.py.
"""

import uuid

from agritrace.core import task_names
from agritrace.modules.publishing import service
from agritrace.worker import app, run_db_task


@app.task(name=task_names.PUBLISHING_BUILD_PAGE)  # type: ignore[untyped-decorator]  # celery ships no stubs
def build_page(batch_id: str, page_build_id: str, build_no: int) -> str | None:
    """Build the page of one `page_builds` row (see the module docstring for the kwargs contract).

    Args:
        batch_id: batch id (informational; the row names its batch).
        page_build_id: the build row to fill.
        build_no: build number (informational; the row holds it).

    Returns:
        The build's final status (`built`, `superseded`, ...), or None for an unknown row.

    Raises:
        ValueError: malformed `page_build_id`.
        PublicRecordInvalidError: the record failed the allow-list or privacy check (row marked `failed`).
        botocore.exceptions.ClientError: S3 or CloudFront refused; the row stays `queued` for a rebuild.

    Side effects:
        See `service.build_page`: S3 objects, the build row, a CDN invalidation.
    """
    build = run_db_task(service.build_page, uuid.UUID(page_build_id))
    return build.status if build else None
