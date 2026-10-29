"""Unit tests for identifier formats and UUIDv7 ordering.

Serves: plan §7.1 ground rules (lot, batch, super-lot code formats), D-005 (time-ordered UUIDs).
Callers: pytest (`make test-unit`).
"""

import re

from agritrace.core import ids


def test_lot_code_format() -> None:
    """Lot codes are LOT + 8 upper-case hex characters."""
    assert all(re.fullmatch(r"LOT[0-9A-F]{8}", ids.lot_code()) for _ in range(200))


def test_batch_code_is_crockford_without_ilou() -> None:
    """Batch codes are 12 Crockford base32 characters and match the PRD reference batch shape."""
    pattern = re.compile(r"[0-9A-HJKMNP-TV-Z]{12}")
    assert pattern.fullmatch("FGP8T4033HM7")
    assert all(pattern.fullmatch(ids.batch_code()) for _ in range(200))


def test_superlot_code_format() -> None:
    """Super-lot codes are COMBO_LOT_ + 8 upper-case hex characters."""
    assert re.fullmatch(r"COMBO_LOT_[0-9A-F]{8}", ids.superlot_code())


def test_uuid7_is_version_7_and_monotonic() -> None:
    """Consecutive UUIDv7 values sort in creation order, even within one millisecond."""
    values = [ids.uuid7() for _ in range(1000)]
    assert all(v.version == 7 for v in values)
    assert values == sorted(values)
    assert len(set(values)) == len(values)
