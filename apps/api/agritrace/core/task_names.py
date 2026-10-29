"""Celery task names shared across modules, so one module can enqueue another's task without importing it.

Serves: D-004 (no cross-module imports of `tasks`), D-009 (Celery on Redis).
Callers: modules call `agritrace.worker.app.send_task(task_names.X, ...)`; each module's `tasks.py`
registers its task with `@app.task(name=task_names.X)`.
"""

EVENTS_VERIFY_PHOTO = "events.verify_photo"
EVENTS_MAKE_VARIANTS = "events.make_variants"
RULES_CHECK_EVENT = "rules.check_event"
RULES_CHECK_PLOT = "rules.check_plot"
RULES_CHECK_LOT = "rules.check_lot"
PUBLISHING_BUILD_PAGE = "publishing.build_page"
NOTIFICATIONS_SEND = "notifications.send"
