"""Shared fixtures of the integration tests that drive the lots/batches/publishing API as one FPO admin.

Serves: B09 and B10 integration tests (Dataflow Stages 4–10); moved here from test_lots_batches.py in B10
round 2 (review B10-r1 P3-5) so test modules share the seeded world without importing each other.
Callers: pytest; tests/integration/test_lots_batches.py and test_publishing.py request `world` (and through it
`migrated` from tests/conftest.py). Needs Docker (containers from tests/conftest.py `stack`).
"""

import secrets
import uuid
from collections.abc import AsyncIterator
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import Any

import pytest
from geoalchemy2 import WKTElement
from httpx import ASGITransport, AsyncClient

from agritrace.core.auth import CurrentUser, get_current_user
from agritrace.core.db import get_sessionmaker
from agritrace.core.enums import InstrumentKind, LocationStatus, OrgKind, PinMethod, Role
from agritrace.core.ids import uuid7
from agritrace.modules.identity.models import User
from agritrace.modules.quality.models import Instrument
from agritrace.modules.quality.profiles.loader import load_profile
from agritrace.modules.registry.models import Crop, Farmer, Fpo, GiTag, Plot, Processor


@dataclass
class World:
    """Ids of one freshly seeded FPO, the caller the API sees and the Celery messages sent."""

    fpo: uuid.UUID
    admin: uuid.UUID
    admin2: uuid.UUID
    plot: uuid.UUID
    crop: uuid.UUID
    processor: uuid.UUID
    instrument: uuid.UUID
    caller: CurrentUser
    sent: list[tuple[str, dict[str, Any]]] = field(default_factory=list)
    clock: int = 0

    def act_as(self, user_id: uuid.UUID, role: Role = Role.FPO_ADMIN) -> None:
        """Switch the caller for the next requests.

        Args:
            user_id: the user to act as.
            role: their role in this FPO.

        Side effects:
            Replaces `caller`.
        """
        self.caller = CurrentUser(user_id=user_id, fpo_id=self.fpo, role=role)

    def tick(self) -> str:
        """Return the next measuring time, one minute after the previous one.

        Returns:
            An ISO 8601 timestamp with offset, so later readings are the latest.

        Side effects:
            Advances the clock.
        """
        self.clock += 1
        return f"2026-07-30T09:{self.clock:02d}:00+05:30"


async def _seed() -> dict[str, uuid.UUID]:
    """Insert an FPO with two admins, a farmer, a plot, a GI crop with its profile, a processor and a meter.

    Returns:
        Ids by name.

    Side effects:
        Commits the rows to the test database.
    """
    async with get_sessionmaker()() as s:
        admin = User(phone=f"+9195{secrets.randbelow(10**8):08d}", name="Admin")
        admin2 = User(phone=f"+9194{secrets.randbelow(10**8):08d}", name="Admin 2")
        fpo = Fpo(code=f"FPO_{secrets.token_hex(4)}", name="Demo FPO", kind=OrgKind.FPO)
        gi = GiTag(gi_number=f"T{secrets.token_hex(4)}", name="Samba Vathal")
        s.add_all([admin, admin2, fpo, gi])
        await s.flush()
        crop = Crop(
            code=f"CHILLI_{secrets.token_hex(4)}", name_en="Samba Vathal", event_schema={}, gi_tag_id=gi.id
        )
        farmer = Farmer(fpo_id=fpo.id, code="F-001", name="Muthu")
        processor = Processor(fpo_id=fpo.id, name="Demo processor", kind=OrgKind.COMPANY)
        meter = Instrument(
            fpo_id=fpo.id,
            kind=InstrumentKind.MOISTURE_METER,
            make_model="Meter A",
            serial_no="A-1",
            calibrated_on=date(2026, 1, 1),
            calibration_due_on=date(2026, 12, 31),
        )
        s.add_all([crop, farmer, processor, meter])
        await s.flush()
        plot = Plot(
            id=uuid7(),
            fpo_id=fpo.id,
            farmer_id=farmer.id,
            code="P-01",
            pin=WKTElement("POINT(77.96 9.58)", srid=4326),
            pin_method=PinMethod.LIVE_GPS,
            pin_device_time=datetime(2026, 3, 4, tzinfo=UTC),
            pin_server_received_at=datetime(2026, 3, 4, tzinfo=UTC),
            declared_area_acres=Decimal("1.5"),
            location_status=LocationStatus.CONFIRMED,
        )
        s.add(plot)
        await s.commit()
        await load_profile(s, crop.id)
        return {
            "fpo": fpo.id,
            "admin": admin.id,
            "admin2": admin2.id,
            "plot": plot.id,
            "crop": crop.id,
            "processor": processor.id,
            "instrument": meter.id,
        }


@pytest.fixture
async def world(migrated: None, monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[tuple[World, AsyncClient]]:
    """Seed a fresh FPO and an HTTP client whose caller is that FPO's admin.

    Args:
        migrated: the migrated database (fixture).
        monkeypatch: replaces the Celery app's `send_task` with a recorder.

    Returns:
        An async iterator yielding the seeded world and the client.

    Side effects:
        Seeds rows; overrides `get_current_user` on a new app instance.
    """
    from agritrace.main import create_app
    from agritrace.worker import app as celery_app

    ids = await _seed()
    w = World(**ids, caller=CurrentUser(user_id=ids["admin"], fpo_id=ids["fpo"], role=Role.FPO_ADMIN))
    monkeypatch.setattr(
        celery_app, "send_task", lambda name, kwargs=None, **_: w.sent.append((name, kwargs or {}))
    )
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: w.caller
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        yield w, client
