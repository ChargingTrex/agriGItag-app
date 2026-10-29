"""Unit tests for the shared schemas, the clock-skew helper and the prod settings guard.

Serves: FR58 (units), Arch §Offline-first (three clocks), CLAUDE.md §6 (no dev secrets in prod).
Callers: pytest (`make test-unit`).
"""

from datetime import UTC, datetime, timedelta
from decimal import Decimal

import pytest
from pydantic import ValidationError

from agritrace.core.config import Settings
from agritrace.core.schemas import GeoPoint, Page, Quantity, SignedQuantity, ThreeClocks
from agritrace.core.time import clock_skew


def test_quantity_rejects_negative_unless_signed() -> None:
    """Quantity refuses negative values and a missing unit; SignedQuantity allows negatives."""
    assert Quantity(value=Decimal("12.5"), unit="kg").value == Decimal("12.5")
    with pytest.raises(ValidationError):
        Quantity(value=Decimal("-1"), unit="kg")
    with pytest.raises(ValidationError):
        Quantity(value=Decimal("1"), unit="")
    assert SignedQuantity(value=Decimal("-3"), unit="kg").value == Decimal("-3")


@pytest.mark.parametrize(
    ("lat", "lon", "accuracy"), [(91, 0, None), (-91, 0, None), (0, 181, None), (0, -181, None), (0, 0, -1)]
)
def test_geopoint_range(lat: float, lon: float, accuracy: float | None) -> None:
    """Out-of-range coordinates and negative accuracy are rejected.

    Args:
        lat: latitude under test.
        lon: longitude under test.
        accuracy: accuracy under test.
    """
    with pytest.raises(ValidationError):
        GeoPoint(lat=lat, lon=lon, accuracy_m=accuracy)


def test_geopoint_valid() -> None:
    """A Virudhunagar point with accuracy is accepted."""
    assert GeoPoint(lat=9.58, lon=77.96, accuracy_m=8).accuracy_m == 8


def test_three_clocks_require_timezone() -> None:
    """Naive timestamps are rejected so every clock is unambiguous."""
    with pytest.raises(ValidationError):
        ThreeClocks(device_time=datetime(2026, 2, 14, 9, 0))  # naive on purpose


def test_clock_skew() -> None:
    """Skew is reported against GPS time first, server time second, only beyond the limit."""
    t = datetime(2026, 2, 14, 9, 0, tzinfo=UTC)
    day = timedelta(days=1)
    assert clock_skew(ThreeClocks(device_time=t + 3 * day, server_received_at=t), day) == 3 * day
    assert clock_skew(ThreeClocks(device_time=t, gps_time=t, server_received_at=t + 3 * day), day) is None
    assert clock_skew(ThreeClocks(device_time=t), day) is None


def test_page_shape() -> None:
    """A page carries items, next_cursor and has_more."""
    page = Page[int](items=[1, 2], next_cursor="abc", has_more=True)
    assert page.model_dump() == {"items": [1, 2], "next_cursor": "abc", "has_more": True}


def test_prod_refuses_dev_secrets() -> None:
    """ENV=prod with the default JWT secret or a dev OTP code does not start."""
    with pytest.raises(ValidationError):
        Settings(env="prod")
    with pytest.raises(ValidationError):
        Settings(env="prod", jwt_secret="x" * 32)
    assert Settings(env="prod", jwt_secret="x" * 32, otp_dev_code=None).env == "prod"
