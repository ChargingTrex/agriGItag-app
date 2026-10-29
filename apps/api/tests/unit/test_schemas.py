"""Unit tests for the shared schemas, the clock-skew helper and the prod settings guard.

Serves: FR58 (units), Arch §Offline-first (three clocks), CLAUDE.md §6 (no dev secrets in prod), FR53,
FR56, FR60, FR68 (shapes of the JSONB columns).
Callers: pytest (`make test-unit`).
"""

from datetime import UTC, datetime, timedelta
from decimal import Decimal

import pytest
from pydantic import ValidationError

from agritrace.core.config import Settings
from agritrace.core.enums import PracticeTag
from agritrace.core.schemas import (
    Address,
    GeoPoint,
    Page,
    PracticeTags,
    Quantity,
    Reconciliation,
    SignedQuantity,
    ThreeClocks,
    YieldCheck,
)
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


def test_secrets_fail_closed(monkeypatch: pytest.MonkeyPatch) -> None:
    """No JWT secret means no start, and the dev OTP bypass is off unless explicitly set.

    Args:
        monkeypatch: pytest monkeypatch fixture.
    """
    for var in ("ENV", "JWT_SECRET", "OTP_DEV_CODE"):
        monkeypatch.delenv(var, raising=False)
    with pytest.raises(ValidationError, match="jwt_secret"):
        Settings(_env_file=None)
    dev = Settings(_env_file=None, jwt_secret="dev-only-change-me")
    assert (dev.env, dev.otp_dev_code) == ("dev", None)


def test_prod_guard(monkeypatch: pytest.MonkeyPatch) -> None:
    """ENV=prod needs a JWT secret of at least 32 bytes and refuses any dev OTP code.

    Args:
        monkeypatch: pytest monkeypatch fixture.
    """
    monkeypatch.delenv("OTP_DEV_CODE", raising=False)
    with pytest.raises(ValidationError, match="32 bytes"):
        Settings(_env_file=None, env="prod", jwt_secret="x" * 31)
    with pytest.raises(ValidationError, match="OTP_DEV_CODE"):
        Settings(_env_file=None, env="prod", jwt_secret="x" * 32, otp_dev_code="123456")
    assert Settings(_env_file=None, env="prod", jwt_secret="x" * 32).env == "prod"
    # Outside prod a short secret and the OTP bypass are allowed (local stack, tests).
    dev = Settings(_env_file=None, env="dev", jwt_secret="short", otp_dev_code="123456")
    assert dev.otp_dev_code == "123456"


def test_empty_otp_is_off_and_secrets_stay_hidden() -> None:
    """`OTP_DEV_CODE=""` becomes None (one meaning of "off"), and validation errors never echo inputs."""
    assert Settings(_env_file=None, jwt_secret="x", otp_dev_code="").otp_dev_code is None
    assert Settings(_env_file=None, env="prod", jwt_secret="x" * 32, otp_dev_code="").env == "prod"
    with pytest.raises(ValidationError) as err:
        Settings(_env_file=None, env="prod", jwt_secret="topsecret-but-short")
    assert "topsecret-but-short" not in str(err.value)


def test_jsonb_shapes_round_trip_and_validate() -> None:
    """Address, PracticeTags, Reconciliation and YieldCheck validate and round-trip through JSON."""
    address = Address(village="P Thottiyangulam", taluk="Tiruchuli", district="Virudhunagar", pin="626129")
    assert Address.model_validate_json(address.model_dump_json()) == address
    with pytest.raises(ValidationError):
        Address(pin="06261")  # five digits, leading zero
    tags = PracticeTags.model_validate({"declared": ["inorganic", "ipm"], "derived": ["organic"]})
    assert tags.declared == [PracticeTag.INORGANIC, PracticeTag.IPM] and tags.contradiction is False
    with pytest.raises(ValidationError):
        PracticeTags.model_validate({"declared": ["natural"]})
    kg = Quantity(value=Decimal("100"), unit="kg")
    assert Reconciliation(harvested=kg, packed=kg, in_order=True).used is None
    check = YieldCheck(harvested=kg, outcome="unavailable")
    assert YieldCheck.model_validate_json(check.model_dump_json()) == check
    with pytest.raises(ValidationError):
        YieldCheck.model_validate({"outcome": "maybe"})
