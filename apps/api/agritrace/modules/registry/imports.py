"""Master data CSV imports: farmers, villages, inputs, each with a row-level report; templates from the YAML.

One parser per kind shares `_run`, the row-report helper. Every row runs inside a SAVEPOINT, so a rejected
row leaves nothing behind; the router commits the whole file in one transaction, or rolls it back for a
dry run (same code path, so the dry run sees exactly what a commit would do).

Serves: PLAN "Gap analysis" (Master data uploads: bulk CSV of farmers, villages, inputs), P08 (preview with
row codes from docs/api/error-codes.md), FR53 (villages with LGD code, taluk, block, PIN), FR56 (inputs),
D-017 (columns and required fields from apps/api/config/fields/*.yaml).
Callers: registry router (`POST /v1/imports/{kind}`, `GET /v1/imports/{kind}/template.csv`); tests.
"""

import csv
import io
from collections.abc import Awaitable, Callable
from typing import Any, Literal

from pydantic import ValidationError
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from agritrace.core import fieldconfig
from agritrace.core.auth import CurrentUser
from agritrace.core.errors import (
    AppError,
    ImportRowExistsError,
    ImportRowInvalidError,
    ImportTooLargeError,
    ValidationFailedError,
)
from agritrace.modules.registry import service
from agritrace.modules.registry.models import InputMaster, Village
from agritrace.modules.registry.schemas import (
    FarmerIn,
    ImportReport,
    ImportRowError,
    InputIn,
    VillageIn,
)

Kind = Literal["farmers", "villages", "inputs"]
ENTITY: dict[str, str] = {"farmers": "farmer", "villages": "village", "inputs": "input"}
MAX_BYTES = 2 * 1024 * 1024
MAX_ROWS = 5000
# Value kinds a CSV cell can carry; ids, addresses, photos and shapes are not imported.
CSV_TYPES = {"text", "number", "integer", "boolean", "date", "phone", "choice"}
# Farmers pick their village by LGD code (people know it; nobody knows our UUIDs), resolved to village_id.
FARMER_VILLAGE_COLUMN = "village_lgd_code"
EXTRA_CELLS = "\0extra"  # DictReader key for cells beyond the header (cannot clash with a name)


def template_columns(kind: Kind, fpo_code: str | None) -> list[str]:
    """CSV header for a kind: the tenant's enabled, CSV-capable fields in YAML order (D-017).

    Args:
        kind: farmers, villages or inputs.
        fpo_code: the caller's FPO code (villages ignore it: they are global).

    Returns:
        Column names; farmers add `village_lgd_code`.
    """
    tenant = None if kind == "villages" else fpo_code
    columns = [f.name for f in fieldconfig.fields_for(ENTITY[kind], tenant) if f.type in CSV_TYPES]
    return columns + [FARMER_VILLAGE_COLUMN] if kind == "farmers" else columns


def template_csv(kind: Kind, fpo_code: str | None) -> str:
    """The downloadable template: one header line.

    Args:
        kind: farmers, villages or inputs.
        fpo_code: the caller's FPO code.

    Returns:
        CSV text with CRLF line ending (what spreadsheet programs write).
    """
    out = io.StringIO()
    csv.writer(out).writerow(template_columns(kind, fpo_code))
    return out.getvalue()


def parse_csv(raw: bytes) -> list[tuple[int, dict[str, str]]]:
    """Decode and split an uploaded CSV, enforcing the size limits.

    Args:
        raw: the uploaded bytes (UTF-8, with or without the BOM spreadsheet programs add).

    Returns:
        (line number, {column: stripped value}) per data row; blank cells and blank lines are left out.

    Raises:
        ImportTooLargeError: over 2 MB or over 5,000 data rows (`import_too_large`).
        ValidationFailedError: not UTF-8, no header, or a row with more cells than the header.
    """
    if len(raw) > MAX_BYTES:
        raise ImportTooLargeError(details={"max_bytes": MAX_BYTES})
    try:
        text = raw.decode("utf-8-sig")
    except UnicodeDecodeError as e:
        raise ValidationFailedError(details={"file": "save the CSV as UTF-8"}) from e
    reader = csv.DictReader(io.StringIO(text), restkey=EXTRA_CELLS)
    if not reader.fieldnames:
        raise ValidationFailedError(details={"file": "the first line must be the column names"})
    reader.fieldnames = [name.strip() for name in reader.fieldnames]
    rows: list[tuple[int, dict[str, str]]] = []
    for row in reader:
        # Spreadsheets add trailing commas: blank-named columns and blank extra cells are ignored.
        spill = [*(row.pop(EXTRA_CELLS, None) or []), row.pop("", None)]
        if any(v and v.strip() for v in spill):
            raise ValidationFailedError(details={"row": reader.line_num, "file": "more cells than columns"})
        cells = {k: v.strip() for k, v in row.items() if v and v.strip()}
        if cells:
            rows.append((reader.line_num, cells))
        if len(rows) > MAX_ROWS:
            raise ImportTooLargeError(details={"max_rows": MAX_ROWS})
    return rows


def _field(details: Any) -> str | None:
    """Pick the column a registered error points at.

    Args:
        details: the error's `details`.

    Returns:
        `details["field"]`, else the only other key of a dict, else None.
    """
    if not isinstance(details, dict):
        return None
    if "field" in details:
        return str(details["field"])
    keys = [k for k in details if k != "entity"]
    return str(keys[0]) if len(keys) == 1 else None


async def _run(
    session: AsyncSession,
    rows: list[tuple[int, dict[str, str]]],
    handle: Callable[[dict[str, str]], Awaitable[None]],
    dry_run: bool,
) -> ImportReport:
    """Import rows one by one, each in a SAVEPOINT, and collect the row-level report.

    Args:
        session: open database session (the caller commits or rolls back the whole file).
        rows: (line number, cells) from `parse_csv`.
        handle: validates and writes one row; raises an `AppError` or `ValidationError` to reject it.
        dry_run: copied into the report.

    Returns:
        Accepted count and rejected rows with their registered code and column.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: unexpected database failure; the caller's rollback then discards
            every row (no partial writes).

    Side effects:
        Writes the accepted rows into the session's transaction.
    """
    accepted, rejected = 0, []
    for line, cells in rows:
        try:
            async with session.begin_nested():
                await handle(cells)
        except AppError as e:
            rejected.append(ImportRowError(row=line, code=e.code, field=_field(e.details)))
        except ValidationError as e:
            loc = e.errors()[0]["loc"]
            rejected.append(
                ImportRowError(row=line, code=ImportRowInvalidError.code, field=str(loc[0]) if loc else None)
            )
        else:
            accepted += 1
    return ImportReport(dry_run=dry_run, accepted=accepted, rejected=rejected)


async def import_farmers(session: AsyncSession, user: CurrentUser, raw: bytes, dry_run: bool) -> ImportReport:
    """Import farmers through `service.create_farmer` (same rules as onboarding, pending approval).

    Args:
        session: open database session.
        user: the caller (FPO admin).
        raw: the uploaded CSV.
        dry_run: only report.

    Returns:
        The row-level report. Row codes: `field_required`, `field_unknown`, `import_row_invalid`,
        `farmer_phone_taken` (also for a phone repeated inside the file), `validation_error` (unknown
        `village_lgd_code`).

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.

    Side effects:
        Inserts farmers and, for phones, users and memberships (audited).
    """
    rows = parse_csv(raw)
    code = await service.fpo_code(session, user.fpo_id)

    async def handle(cells: dict[str, str]) -> None:
        """Create one farmer.

        Args:
            cells: the row.

        Raises:
            AppError: rejected (see `import_farmers`).
            ValidationError: a value of the wrong kind.
        """
        lgd = cells.pop(FARMER_VILLAGE_COLUMN, None)
        data: dict[str, Any] = fieldconfig.validate_payload("farmer", code, cells)
        if lgd:
            data["village_id"] = await session.scalar(select(Village.id).where(Village.lgd_code == lgd))
            if data["village_id"] is None:
                raise ValidationFailedError(details={"field": FARMER_VILLAGE_COLUMN})
        # shortcut: farmers without a phone have no natural key, so re-importing them creates duplicates;
        #   re-upload only the fixed rows (conventions.md §Config). Add a key column if FPOs need re-runs.
        await service.create_farmer(session, user, FarmerIn.model_validate(data))

    return await _run(session, rows, handle, dry_run)


async def import_villages(session: AsyncSession, raw: bytes, dry_run: bool) -> ImportReport:
    """Import villages into the global directory; `lgd_code` is the key (super-admin, checked by the router).

    Args:
        session: open database session.
        raw: the uploaded CSV.
        dry_run: only report.

    Returns:
        The row-level report. Row codes: `field_required`, `field_unknown`, `import_row_invalid`,
        `import_row_exists` (LGD code already in the directory or earlier in the file).

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.

    Side effects:
        Inserts `villages` rows (the trigger bumps the `villages` bundle part).
    """
    rows = parse_csv(raw)

    async def handle(cells: dict[str, str]) -> None:
        """Create one village.

        Args:
            cells: the row.

        Raises:
            AppError: rejected (see `import_villages`).
            ValidationError: a value of the wrong kind.
        """
        body = VillageIn.model_validate(fieldconfig.validate_payload("village", None, cells))
        if await session.scalar(select(Village.id).where(Village.lgd_code == body.lgd_code)):
            raise ImportRowExistsError(details={"field": "lgd_code"})
        session.add(Village(**body.model_dump()))
        await session.flush()

    return await _run(session, rows, handle, dry_run)


async def import_inputs(session: AsyncSession, user: CurrentUser, raw: bytes, dry_run: bool) -> ImportReport:
    """Import inputs into the caller's FPO list through `service.create_input`; key = name + manufacturer.

    Args:
        session: open database session.
        user: the caller (FPO admin).
        raw: the uploaded CSV.
        dry_run: only report.

    Returns:
        The row-level report. Row codes: `field_required`, `field_unknown`, `import_row_invalid` (e.g.
        unknown category), `import_row_exists` (same English name and manufacturer, ignoring case, already
        in the FPO's or the global list, or earlier in the file).

    Raises:
        ImportTooLargeError: over 2 MB or 5,000 rows.
        ValidationFailedError: unreadable CSV.

    Side effects:
        Inserts `inputs_master` rows (the trigger bumps the `inputs` bundle part).
    """
    rows = parse_csv(raw)
    code = await service.fpo_code(session, user.fpo_id)

    async def handle(cells: dict[str, str]) -> None:
        """Create one input.

        Args:
            cells: the row.

        Raises:
            AppError: rejected (see `import_inputs`).
            ValidationError: a value of the wrong kind.
        """
        body = InputIn.model_validate(fieldconfig.validate_payload("input", code, cells))
        same = await session.scalar(
            select(InputMaster.id).where(
                or_(InputMaster.fpo_id == user.fpo_id, InputMaster.fpo_id.is_(None)),
                func.lower(InputMaster.name_en) == body.name_en.lower(),
                func.lower(func.coalesce(InputMaster.manufacturer, "")) == (body.manufacturer or "").lower(),
            )
        )
        if same:
            raise ImportRowExistsError(details={"field": "name_en"})
        await service.create_input(session, user, body)

    return await _run(session, rows, handle, dry_run)
