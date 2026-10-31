"""Rule `photo_evidence`: photos failing their checks → `photo_checksum_mismatch` or `exif_mismatch`.

`events.verify_photo` (B06) already compared each photo's SHA-256, EXIF time with the device clock and EXIF
GPS with the event GPS, and stored the outcome as the photo status. This rule turns those statuses into flags
and adds the one comparison B06 cannot make: the EXIF date against the day the farmer says the work happened.
Serves: FR26, FR61 (photo time and GPS checked against the event), Stages 1–7.
Callers: `rules.EVENT_RULES` (service `check_event`), tests/unit/test_rules_event.py.
"""

from datetime import timedelta
from typing import Any
from zoneinfo import ZoneInfo

from agritrace.core.enums import FlagSubject, PhotoStatus, Severity
from agritrace.modules.rules_flags.rules.context import EventContext, FlagCandidate

CODES = {"photo_checksum_mismatch", "exif_mismatch"}
# Farmers record a day's work that evening or the next morning; one day either side is normal.
DAY_TOLERANCE = timedelta(days=1)
INDIA = ZoneInfo("Asia/Kolkata")  # occurred_on is a farmer's local calendar day


def run(ctx: EventContext) -> list[FlagCandidate]:
    """Flag each photo of the event version that failed verification or was taken on another day.

    Args:
        ctx: the event with its photos (status and EXIF capture time).

    Returns:
        Per photo at most one flag (warn): `photo_checksum_mismatch` when the stored file is not the one the
        phone hashed; otherwise `exif_mismatch` listing `reasons` (`exif_vs_entry` from B06,
        `exif_vs_occurred_on` when the EXIF day is outside occurred_on … occurred_end_on ± 1 day).
    """
    first, last = ctx.occurred_on - DAY_TOLERANCE, (ctx.occurred_end_on or ctx.occurred_on) + DAY_TOLERANCE
    flags = []
    for photo in ctx.photos:
        if photo.status == PhotoStatus.CHECKSUM_MISMATCH:
            details: dict[str, Any] = {"photo_id": str(photo.id)}
            code = "photo_checksum_mismatch"
        else:
            reasons = ["exif_vs_entry"] if photo.status == PhotoStatus.EXIF_MISMATCH else []
            taken = photo.exif_taken_at.astimezone(INDIA).date() if photo.exif_taken_at else None
            if taken is not None and not first <= taken <= last:
                reasons.append("exif_vs_occurred_on")
            if not reasons:
                continue
            details = {
                "photo_id": str(photo.id),
                "reasons": reasons,
                "exif_date": taken.isoformat() if taken else None,
            }
            code = "exif_mismatch"
        flags.append(
            FlagCandidate(FlagSubject.EVENT, ctx.event_id, code, Severity.WARN, details, str(photo.id))
        )
    return flags
