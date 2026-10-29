"""Load a seed Standards Profile JSON (e.g. dry_chilli_agmark_v1.json) into the database as version 1.

Serves: PRD §6.8 seed standards table (dry chillies: AGMARK Schedule IV, Special ≤10 %, Standard ≤11 %),
FR47, FR51 (public note while the full schedule is pending), D-015, backend-design.md §4 and §5 (seed).
Callers: the B12 seed (`make seed`) with a session and the crop id; tests/integration/test_quality.py.
The JSON files beside this module carry no header comment because JSON has none and the rules model
rejects unknown keys; this docstring is their header.
"""

import json
import uuid
from pathlib import Path

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core.enums import ProfileVersionStatus, StandardsScheme
from agritrace.modules.quality.models import StandardsProfile, StandardsProfileVersion
from agritrace.modules.quality.schemas import StandardsProfileRules
from agritrace.modules.quality.service import add_profile_version

HERE = Path(__file__).parent


def read_profile(name: str) -> StandardsProfileRules:
    """Read and validate a seed profile file.

    Args:
        name: file name without `.json`, e.g. `dry_chilli_agmark_v1`.

    Returns:
        The validated rules.

    Raises:
        FileNotFoundError: no such file.
        pydantic.ValidationError: the JSON breaks `StandardsProfileRules`.
    """
    return StandardsProfileRules.model_validate(json.loads((HERE / f"{name}.json").read_text()))


async def load_profile(
    session: AsyncSession,
    crop_id: uuid.UUID,
    name: str = "dry_chilli_agmark_v1",
    scheme: StandardsScheme = StandardsScheme.AGMARK,
) -> StandardsProfileVersion:
    """Upsert the crop's profile (keyed by crop and standard name) and publish the file as version 1 once.

    Idempotent: running the seed twice returns the existing version 1 unchanged. The seed profile still has
    `load_from_standard` parameters, so it is published with `allow_incomplete` and gets the public note
    "Graded on moisture only — full schedule pending".

    Args:
        session: database session.
        crop_id: the crop the profile grades (e.g. Virudhunagar Samba Vathal).
        name: seed file name without `.json`.
        scheme: grading scheme of the profile.

    Returns:
        Version 1 of the profile.

    Raises:
        FileNotFoundError: no such seed file.
        pydantic.ValidationError: the seed JSON is invalid.

    Side effects:
        Inserts the profile and its version (with audit rows) and commits.
    """
    rules = read_profile(name)
    standard = rules.standard
    ref = f"{standard.name}, Schedule {standard.schedule}" if standard.schedule else standard.name
    profile = await session.scalar(
        select(StandardsProfile).where(
            StandardsProfile.crop_id == crop_id, StandardsProfile.name == standard.name
        )
    )
    if profile is None:
        profile = StandardsProfile(crop_id=crop_id, scheme=scheme, name=standard.name, standard_ref=ref)
        session.add(profile)
        await session.flush()
    version = await session.scalar(
        select(StandardsProfileVersion).where(
            StandardsProfileVersion.profile_id == profile.id, StandardsProfileVersion.version_no == 1
        )
    )
    if version is None:
        version = await add_profile_version(
            session,
            profile.id,
            rules,
            status=ProfileVersionStatus.PUBLISHED,
            allow_incomplete=True,
            published_by=None,
        )
    await session.commit()
    return version
