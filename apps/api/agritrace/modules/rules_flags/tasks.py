"""Celery tasks of the rules_flags module: run the server rules on an event, a plot, or a lot/batch.

Keyword arguments are the ones the enqueuing modules send: events sync push `{event_id, version_id, hints}`,
`events.verify_photo` `{event_id, photo_id, hints}`, registry `args=[plot_id]`, quality
`{lot_id, batch_id, reading_id, hint}`. Hints only explain why a check runs: every check re-reads the rows.
Serves: Arch §Rules and flags, D-006 (server rules are the authority), D-009, Stages 0–8.
Callers: the Celery worker (`agritrace.worker` autodiscovers this module); enqueued by name
(`core.task_names.RULES_CHECK_*`) from events, registry and quality services (D-004).
"""

import uuid

from sqlalchemy.exc import DBAPIError

from agritrace.core import task_names
from agritrace.modules.rules_flags import service
from agritrace.worker import app, run_db_task


def _uuid(value: str | None) -> uuid.UUID | None:
    """Parse an optional id from task kwargs.

    Args:
        value: the id as text, or None.

    Returns:
        The UUID, or None.

    Raises:
        ValueError: not a UUID.
    """
    return uuid.UUID(value) if value else None


# A database error (deadlock 40P01, serialization 40001, dropped connection: `DBAPIError`; connection refused
#   or timed out at connect during a Postgres restart: plain `OSError`, which SQLAlchemy does not wrap) would
#   otherwise lose a check for good (audit wave-7 #3): retry 3 times with jittered backoff. These tasks do no
#   file or S3 I/O, so an `OSError` can only come from the database connection. Safe because a check is a full
#   re-run that rolls back on error, and `store_flags` dedupes by `dedupe_key`, never reopening a reviewer's
#   same-severity closure, so a second run changes nothing the first committed.
RETRY = {
    "autoretry_for": (DBAPIError, OSError),
    "max_retries": 3,
    "retry_backoff": True,
    "retry_jitter": True,
}


# DECISION D-009: rule checks run as Celery tasks through `run_db_task`, after the entry is committed.
#   ADV: a sync push or photo confirm answers at once; checks retry with the worker, not the phone.
#   COMPROMISE: flags appear seconds later, and a task may run twice; `dedupe_key` makes that harmless.
@app.task(name=task_names.RULES_CHECK_EVENT, **RETRY)  # type: ignore[untyped-decorator]  # celery ships no stubs
def check_event(
    event_id: str,
    version_id: str | None = None,
    photo_id: str | None = None,
    hints: list[str] | None = None,
) -> list[str]:
    """Run the event rules and its lot's (or batch's) rules.

    Args:
        event_id: the event.
        version_id: the version just stored (unused: the current version is checked).
        photo_id: the photo just verified (unused: all photos of the version are checked).
        hints: e.g. `clock_skew`, `checksum_mismatch` (unused: the rules re-derive them).

    Returns:
        Rule codes of the active flags in scope.

    Raises:
        ValueError: `event_id` is not a UUID.
        sqlalchemy.exc.SQLAlchemyError, OSError: passed through (`DBAPIError`, `OSError`: after `RETRY`).

    Side effects:
        Inserts, updates and closes flags; may set `lots.gi_eligible`.
    """
    return run_db_task(service.check_event, uuid.UUID(event_id))


@app.task(name=task_names.RULES_CHECK_PLOT, **RETRY)  # type: ignore[untyped-decorator]  # celery ships no stubs
def check_plot(plot_id: str) -> list[str]:
    """Run the plot review rules.

    Args:
        plot_id: the plot.

    Returns:
        Rule codes of the plot's active flags.

    Raises:
        ValueError: `plot_id` is not a UUID.
        sqlalchemy.exc.SQLAlchemyError, OSError: passed through (`DBAPIError`, `OSError`: after `RETRY`).

    Side effects:
        Inserts, updates and closes plot flags.
    """
    return run_db_task(service.check_plot, uuid.UUID(plot_id))


@app.task(name=task_names.RULES_CHECK_LOT, **RETRY)  # type: ignore[untyped-decorator]  # celery ships no stubs
def check_lot(
    lot_id: str | None = None,
    batch_id: str | None = None,
    reading_id: str | None = None,
    hint: str | None = None,
) -> list[str]:
    """Run the lot and/or batch rules (also sweeps trail overrides whose enqueue was lost).

    Args:
        lot_id: the lot, if any.
        batch_id: the batch, if any.
        reading_id: the reading that triggered it, if any.
        hint: e.g. `moisture_trail_override`.

    Returns:
        Rule codes of the active flags in scope.

    Raises:
        ValueError: an id is not a UUID.
        sqlalchemy.exc.SQLAlchemyError, OSError: passed through (`DBAPIError`, `OSError`: after `RETRY`).

    Side effects:
        Inserts, updates and closes flags; may set `lots.gi_eligible` and `lots.practice_tags`.
    """
    return run_db_task(service.check_lot, _uuid(lot_id), _uuid(batch_id), _uuid(reading_id), hint)
