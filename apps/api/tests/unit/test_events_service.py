"""Unit tests of the pure event-version rules: idempotency owner, version number, correct/undo, clock skew.

Serves: B06 deliverable 6 (idempotency decision, version_no rule), acceptance "undo after 24 h → 409",
"farmer correction → 403", "device clock +3 d → clock_skew"; D-005, FR6, FR25; TODO B06/B07 (SQLSTATE
23001 → `append_only_violation`).
Callers: pytest (`make test-unit`); no Docker needed.
"""

import uuid
from datetime import UTC, datetime, timedelta

import pytest

from agritrace.core.auth import CurrentUser
from agritrace.core.enums import Role
from agritrace.core.errors import (
    AppendOnlyViolationError,
    ClientIdConflictError,
    ForbiddenError,
    ReasonRequiredError,
    StaleVersionError,
    UndoWindowClosedError,
    append_only_error,
)
from agritrace.core.schemas import ThreeClocks
from agritrace.modules.events.service import check_change, check_owner, check_version_no, skew_hints

FPO = uuid.uuid4()
FARMER = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FARMER)
OFFICER = CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FIELD_OFFICER)
T0 = datetime(2026, 3, 4, 8, 0, tzinfo=UTC)


def test_resent_id_of_the_same_user_is_a_duplicate() -> None:
    """The caller's own record passes (the push answers `duplicate`)."""
    check_owner(FARMER.user_id, FPO, FARMER)


@pytest.mark.parametrize("owner", [(uuid.uuid4(), FPO), (FARMER.user_id, uuid.uuid4())])
def test_foreign_id_is_a_conflict(owner: tuple[uuid.UUID, uuid.UUID]) -> None:
    """Another user's or another FPO's record → `client_id_conflict`.

    Args:
        owner: (entered_by, fpo_id) of the stored record.
    """
    with pytest.raises(ClientIdConflictError):
        check_owner(*owner, FARMER)


@pytest.mark.parametrize(
    ("sent", "current_max", "ok"), [(1, None, True), (3, 2, True), (2, 2, False), (4, 2, False)]
)
def test_version_no_must_be_max_plus_one(sent: int, current_max: int | None, ok: bool) -> None:
    """Only max + 1 is accepted; anything else is `stale_version` with the expected number.

    Args:
        sent: version sent.
        current_max: highest stored version.
        ok: whether it passes.
    """
    if ok:
        check_version_no(sent, current_max)
        return
    with pytest.raises(StaleVersionError) as exc:
        check_version_no(sent, current_max)
    assert exc.value.details["expected_version_no"] == (current_max or 0) + 1


def test_farmer_correction_is_forbidden() -> None:
    """Farmers cannot correct (FR25: officer or admin with reason)."""
    with pytest.raises(ForbiddenError):
        check_change("correct", FARMER, "typo", FARMER.user_id, T0, T0)


def test_correction_needs_a_reason() -> None:
    """An officer's correction without reason → `reason_required`."""
    with pytest.raises(ReasonRequiredError):
        check_change("correct", OFFICER, "  ", FARMER.user_id, T0, T0)
    check_change("correct", OFFICER, "wrong_quantity", FARMER.user_id, T0, T0)


def test_undo_window_is_24_hours() -> None:
    """The farmer's own undo passes at 24 h and fails after it (`undo_window_closed`)."""
    check_change("undo", FARMER, None, FARMER.user_id, T0, T0 + timedelta(hours=24))
    with pytest.raises(UndoWindowClosedError):
        check_change("undo", FARMER, None, FARMER.user_id, T0, T0 + timedelta(hours=24, seconds=1))


@pytest.mark.parametrize("who", [OFFICER, CurrentUser(user_id=uuid.uuid4(), fpo_id=FPO, role=Role.FARMER)])
def test_undo_only_by_the_farmer_who_entered_it(who: CurrentUser) -> None:
    """An officer, or another farmer, cannot undo.

    Args:
        who: the caller.
    """
    with pytest.raises(ForbiddenError):
        check_change("undo", who, None, FARMER.user_id, T0, T0)


@pytest.mark.parametrize(
    ("device", "gps", "hint"),
    [
        (T0 + timedelta(days=3), None, True),  # phone clock 3 days ahead of the server
        (T0 - timedelta(days=3), None, False),  # synced 3 days late: normal offline
        (T0 - timedelta(days=3), T0, True),  # GPS time disagrees with the phone
        (T0 + timedelta(minutes=10), None, False),  # within the limit
    ],
)
def test_clock_skew_hint(device: datetime, gps: datetime | None, hint: bool) -> None:
    """Future device time (vs server) or any large GPS difference hints `clock_skew`; late sync does not.

    Args:
        device: device time.
        gps: GPS time, if any.
        hint: whether the hint is expected.
    """
    clocks = ThreeClocks(device_time=device, gps_time=gps, server_received_at=T0)
    assert skew_hints(clocks) == (["clock_skew"] if hint else [])


def test_sqlstate_23001_maps_to_append_only_violation() -> None:
    """The append-only trigger's SQLSTATE 23001 becomes the registered AppError; others do not."""

    class Orig(Exception):
        """Stand-in for the driver error."""

        def __init__(self, sqlstate: str) -> None:
            """Store the SQLSTATE.

            Args:
                sqlstate: the code.
            """
            self.sqlstate = sqlstate

    class Wrapped(Exception):
        """Stand-in for `sqlalchemy.exc.DBAPIError`."""

        def __init__(self, sqlstate: str) -> None:
            """Wrap a driver error.

            Args:
                sqlstate: the code.
            """
            self.orig = Orig(sqlstate)

    assert isinstance(append_only_error(Wrapped("23001")), AppendOnlyViolationError)
    assert append_only_error(Wrapped("23505")) is None
    assert append_only_error(ValueError()) is None
