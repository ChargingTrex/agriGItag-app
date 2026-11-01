"""Timing script (not a test): one `rules.check_event` and one `rules.check_lot` on a lot of 1,500 events.

Seeds the `test_rules` world, bulk-inserts 1,500 live events with one version each (problem events with a
QA-sized payload, inputs, harvests, the crop track), then times the task bodies and the lot-context load.
Not collected by `pytest tests` (the name does not start with `test_`); run it by path:
`uv run pytest tests/integration/bench_check_event.py -q -s -p no:cacheprovider`.
Serves: B22 (QA issue Q04-3, BM-07 rules backlog); timings go to docs/agents/reports/B22.md.
Callers: a developer, by hand. Needs Docker (containers from tests/conftest.py `stack`).
"""

import statistics
import time
from datetime import UTC, date, datetime, timedelta

import test_rules
from sqlalchemy import insert, select, text, update
from test_rules import NOW, PIN, World

from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import ChangeKind, EventStatus, EventSubject, EventType
from agritrace.core.ids import uuid7
from agritrace.modules.events.models import Event, EventVersion
from agritrace.modules.lots_batches.models import Lot
from agritrace.modules.rules_flags import rules, service

migrated, world = test_rules.migrated, test_rules.world  # the seeding fixtures, shared with test_rules
N = 1500
NOTE = "Leaf curl seen on the eastern rows after the rain; sprayed neem oil, will check again next week. " * 3


def _kind(i: int) -> tuple[EventType, dict[str, object]]:
    """Pick the type and payload of the i-th seeded event (a QA-like mix, mostly problem events).

    Args:
        i: position in the lot.

    Returns:
        (event type, payload).
    """
    if i < 4:
        return [EventType.LAND_PREPARATION, EventType.NURSERY, EventType.SOWING, EventType.DRYING][i], {}
    if i % 50 == 0:
        return EventType.HARVEST, {"quantity": {"value": 12.5, "unit": "kg"}}
    if i % 20 == 0:
        return EventType.INPUT_APPLICATION, {"input_id": None, "quantity": {"value": 2, "unit": "kg"}}
    return EventType.PROBLEM, {"problem_code": "leaf_curl", "severity": "medium", "notes": NOTE}


async def _seed(w: World) -> list[str]:
    """Bulk-insert N live events of the world's lot, each with one current version.

    Args:
        w: the seeded world.

    Returns:
        The event ids, oldest first.

    Side effects:
        Commits the rows (Core inserts: no audit rows, which a timing run does not need).
    """
    start = date(2025, 9, 1)
    events, versions = [], []
    for i in range(N):
        kind, payload = _kind(i)
        if kind == EventType.INPUT_APPLICATION:
            payload = payload | {"input_id": str(w.inputs[i % 2])}
        day = start + timedelta(days=i // 10)
        eid, vid = uuid7(), uuid7()
        events.append(
            dict(id=eid, fpo_id=w.fpo, subject_type=EventSubject.LOT, lot_id=w.lot, plot_id=w.plot,
                 event_type=kind, occurred_on=day, status=EventStatus.SUBMITTED)
        )  # fmt: skip
        versions.append(
            dict(id=vid, event_id=eid, version_no=1, payload=payload, occurred_on=day,
                 device_time=datetime.combine(day, datetime.min.time(), UTC), server_received_at=NOW,
                 gps=f"SRID=4326;POINT({PIN[1]} {PIN[0]})", gps_accuracy_m=6.0, entered_by_user_id=w.officer,
                 change_kind=ChangeKind.CREATE)
        )  # fmt: skip
    async with get_sessionmaker()() as s:
        await s.execute(insert(Event), events)
        await s.execute(insert(EventVersion), versions)
        await s.execute(
            update(Event)
            .where(Event.lot_id == w.lot)
            .values(current_version_id=select(EventVersion.id).where(EventVersion.event_id == Event.id))
        )
        for table in ("events", "event_versions", "flags"):
            await s.execute(text(f"ANALYZE {table}"))
        await s.commit()
    return [e["id"] for e in events]


async def _ms(fn, *args, runs: int = 5) -> str:  # type: ignore[no-untyped-def]
    """Time an awaitable factory several times in fresh sessions.

    Args:
        fn: async function taking a session first.
        *args: the rest of its arguments.
        runs: how many timed runs (after one warm-up).

    Returns:
        `median (min–max) ms`.
    """
    times = []
    for _ in range(runs + 1):
        async with get_sessionmaker()() as s:
            t = time.perf_counter()
            await fn(s, *args)
            times.append((time.perf_counter() - t) * 1000)
    timed = times[1:]
    return f"{statistics.median(timed):.0f} ms ({min(timed):.0f}–{max(timed):.0f})"


async def test_bench_check_event_1500(world: World) -> None:
    """Print the timings of check_event, check_lot and the lot-rule pieces at 1,500 events.

    Args:
        world: the seeded FPO (fixture from test_rules).
    """
    ids = await _seed(world)

    async def lot_context(s, lot_id):  # type: ignore[no-untyped-def]
        """Load the lot context only."""
        await service._lot_context(s, await s.get(Lot, lot_id))

    async def lot_rules(s, lot_id):  # type: ignore[no-untyped-def]
        """Load the lot context and run the pure lot rules."""
        rules.run_all(rules.LOT_RULES, await service._lot_context(s, await s.get(Lot, lot_id)))

    print(f"\n[B22] {N} events in the lot")
    print("[B22] check_event (problem event, mid-lot):", await _ms(service.check_event, ids[N // 2]))
    print("[B22] check_lot:", await _ms(service.check_lot, world.lot))
    print("[B22] _lot_context:", await _ms(lot_context, world.lot))
    print("[B22] _lot_context + LOT_RULES:", await _ms(lot_rules, world.lot))
