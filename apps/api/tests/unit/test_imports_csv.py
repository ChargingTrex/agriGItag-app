"""Unit tests of the CSV import parser, the row-level report and the templates (no database).

Covers B13 acceptance "CSV with 2 bad rows → accepted n-2, rejected [{row, code}]" at the report level
(the real field-config and Pydantic checks run; writes are replaced by a stand-in), the 2 MB / 5,000-row
limits, BOM and blank-line handling, line numbering, and template columns per tenant.
Serves: PLAN "Gap analysis" (Master data uploads), P08, D-017. Callers: pytest (`make test-unit`).
"""

import re
import uuid
from contextlib import asynccontextmanager
from typing import Any

import pytest

from agritrace.core import fieldconfig
from agritrace.core.errors import AppError
from agritrace.modules.registry import imports, service
from agritrace.modules.registry.schemas import InputIn


class _Savepoints:
    """Stand-in session offering only `begin_nested`; counts savepoints rolled back."""

    def __init__(self) -> None:
        """Start with no rollbacks."""
        self.rolled_back = 0

    @asynccontextmanager
    async def begin_nested(self) -> Any:
        """Open a pretend savepoint; an exception counts as a rollback and propagates.

        Returns:
            An async context manager yielding None.

        Raises:
            Exception: whatever the body raised, after counting it.
        """
        try:
            yield None
        except Exception:
            self.rolled_back += 1
            raise


def test_parse_csv_handles_bom_blank_lines_and_line_numbers() -> None:
    """Excel's BOM is stripped, blank lines skipped, blank cells dropped, rows keep their file line."""
    raw = "﻿name_en, category ,unit\r\nUrea,chemical_fertilizer,kg\r\n\r\nNeem,, l \r\n".encode()
    rows = imports.parse_csv(raw)
    assert rows == [(2, {"name_en": "Urea", "category": "chemical_fertilizer", "unit": "kg"}),
                    (4, {"name_en": "Neem", "unit": "l"})]  # fmt: skip


@pytest.mark.parametrize(
    ("raw", "code"),
    [
        (b"a\n" + b"x\n" * (imports.MAX_ROWS + 1), "import_too_large"),
        (b"a\n" + b"x" * imports.MAX_BYTES, "import_too_large"),
        ("name_en\nUrea\n".encode("utf-16"), "validation_error"),
        (b"", "validation_error"),
        (b"a,b\n1,2,3\n", "validation_error"),
    ],
)
def test_parse_csv_refuses_whole_files(raw: bytes, code: str) -> None:
    """Too many rows, too many bytes, not UTF-8, no header, or a row wider than the header.

    Args:
        raw: the upload.
        code: expected error code.
    """
    with pytest.raises(AppError) as err:
        imports.parse_csv(raw)
    assert err.value.code == code


async def test_two_bad_rows_give_n_minus_2_accepted_and_row_codes() -> None:
    """5 rows, 2 bad (missing required unit, unknown category) → accepted 3, rejected rows 3 and 5."""
    raw = (
        b"name_en,manufacturer,category,unit,pack_size\n"
        b"Urea,IFFCO,chemical_fertilizer,kg,50\n"
        b"Neem cake,,organic_fertilizer,,25\n"
        b"Trichoderma,,bio_pesticide,kg,1\n"
        b"Mystery,,magic_dust,kg,1\n"
        b"Vermicompost,,organic_fertilizer,kg,40\n"
    )
    written: list[InputIn] = []

    async def handle(cells: dict[str, str]) -> None:
        """Validate like `import_inputs` and record instead of writing.

        Args:
            cells: the row.
        """
        written.append(InputIn.model_validate(fieldconfig.validate_payload("input", None, cells)))

    session = _Savepoints()
    report = await imports._run(
        session,  # type: ignore[arg-type]  # stand-in offers only begin_nested
        imports.parse_csv(raw),
        handle,
        dry_run=True,
    )
    assert report.accepted == 3
    assert [(r.row, r.code, r.field) for r in report.rejected] == [
        (3, "field_required", "unit"),
        (5, "import_row_invalid", "category"),
    ]
    assert session.rolled_back == 2  # each bad row's savepoint is rolled back: no partial row
    assert [w.name_en for w in written] == ["Urea", "Trichoderma", "Vermicompost"]


async def test_unknown_column_is_rejected_per_row_for_forbid_entities() -> None:
    """Inputs forbid extras: a `global_entry` column cannot sneak a global list entry in."""
    raw = b"name_en,category,unit,global_entry\nUrea,chemical_fertilizer,kg,true\n"

    async def handle(cells: dict[str, str]) -> None:
        """Validate like `import_inputs`.

        Args:
            cells: the row.
        """
        fieldconfig.validate_payload("input", None, cells)

    report = await imports._run(_Savepoints(), imports.parse_csv(raw), handle, False)  # type: ignore[arg-type]
    assert [(r.code, r.field) for r in report.rejected] == [("field_unknown", "global_entry")]


def test_templates_follow_the_tenant_config() -> None:
    """Farmers: CSV-capable enabled fields plus `village_lgd_code`; villages: the LGD key first."""
    farmers = imports.template_columns("farmers", "VIRUDHAI_SCFC_VINOBA_BHAVA_FPO")
    assert farmers[0] == "name" and farmers[-1] == "village_lgd_code"
    assert "village_id" not in farmers and "photo_key" not in farmers
    assert imports.template_columns("villages", None)[0] == "lgd_code"
    assert imports.template_csv("inputs", None).startswith("name_en,name_local,manufacturer,category,unit")


async def test_farmer_code_is_redrawn_on_collision() -> None:
    """A bulk import must not die on UNIQUE(fpo_id, code): a taken code is drawn again."""
    answers: list[uuid.UUID | None] = [uuid.uuid4(), None]  # first code taken, second free

    class _Codes:
        """Stand-in session answering the code-exists query from `answers`."""

        async def scalar(self, *_: Any) -> uuid.UUID | None:
            """Answer one existence query.

            Args:
                *_: the statement (ignored).

            Returns:
                The next prepared answer.
            """
            return answers.pop(0)

    code = await service._new_farmer_code(_Codes(), uuid.uuid4())  # type: ignore[arg-type]
    assert re.fullmatch(r"F[0-9A-F]{6}", code)
    assert answers == []
