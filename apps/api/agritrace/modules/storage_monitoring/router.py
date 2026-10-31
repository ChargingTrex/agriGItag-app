"""storage_monitoring HTTP routes: planned warehouse probes and their readings, stubbed in the pilot with 501.

Serves: plan §7.1 B11 (`storage_monitoring` router → 501 `not_implemented_pilot`), backend-design.md §1
storage_monitoring row, D-020 (the routes are reserved now so the contract only grows), TODO.md deferred
scope (IoT).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); storage probes after the
pilot.
"""

from fastapi import APIRouter

from agritrace.core.errors import NotImplementedPilotError
from agritrace.core.schemas import ErrorEnvelope

router = APIRouter(
    tags=["storage_monitoring"],
    responses={
        501: {"model": ErrorEnvelope, "description": "`not_implemented_pilot`: planned after the pilot."}
    },
)


@router.post(
    "/probes",
    summary="Register a storage probe (planned)",
    description="Planned: an FPO admin registers a temperature / humidity probe in a warehouse where packed "
    "batches are stored. Pilot: always 501.",
)
async def post_probe() -> None:
    """Refuse: storage monitoring is not part of the pilot.

    \f
    Raises:
        NotImplementedPilotError: always (`not_implemented_pilot`, 501).
    """
    raise NotImplementedPilotError()


@router.post(
    "/probe-readings",
    summary="Send storage probe readings (planned)",
    description="Planned: a probe sends temperature (°C) and relative humidity (%) readings; out-of-range "
    "storage raises a flag on the stored batches. Pilot: always 501.",
)
async def post_probe_readings() -> None:
    """Refuse: storage monitoring is not part of the pilot.

    \f
    Raises:
        NotImplementedPilotError: always (`not_implemented_pilot`, 501).
    """
    raise NotImplementedPilotError()
