"""partner_api HTTP routes: the planned partner (buyer / exporter) API, stubbed in the pilot with 501.

Serves: plan §7.1 B11 (`partner_api` router → 501 `not_implemented_pilot`), backend-design.md §1 partner_api
row, D-020 (the routes are reserved now so the contract only grows), TODO.md deferred scope (partner API).
Callers: `agritrace.main.create_app` mounts `router` (module discovery, D-004); partners after the pilot.
"""

from typing import Annotated

from fastapi import APIRouter, Path

from agritrace.core.errors import NotImplementedPilotError
from agritrace.core.schemas import ErrorEnvelope

router = APIRouter(
    prefix="/partner",
    tags=["partner_api"],
    responses={
        501: {"model": ErrorEnvelope, "description": "`not_implemented_pilot`: planned after the pilot."}
    },
)


@router.get(
    "/batches/{code}",
    summary="Read a batch for a partner (planned)",
    description="Planned: a partner with the farmers' `partner_share` consent reads a batch's traceability "
    "record (lots, shares, grade, GI status) at `partner` visibility (D-017). Pilot: always 501.",
)
async def get_partner_batch(code: Annotated[str, Path(max_length=32, description="Batch code.")]) -> None:
    """Refuse: the partner API is not part of the pilot.

    \f
    Args:
        code: the batch code (unused).

    Raises:
        NotImplementedPilotError: always (`not_implemented_pilot`, 501).
    """
    raise NotImplementedPilotError()


@router.post(
    "/benefits",
    summary="Report a partner benefit payment (planned)",
    description="Planned: a partner reports a premium or benefit paid against a batch, shared back to its "
    "farmers by lot share. Pilot: always 501.",
)
async def post_partner_benefit() -> None:
    """Refuse: the partner API is not part of the pilot.

    \f
    Raises:
        NotImplementedPilotError: always (`not_implemented_pilot`, 501).
    """
    raise NotImplementedPilotError()
