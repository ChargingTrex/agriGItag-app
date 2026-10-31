"""Rule `practice_tags`: Organic / Inorganic derived from inputs; contradictions; IPM without pests.

Port of apps/mobile/lib/core/rules/practice_tags.dart (same sets, same answers; held equal by
tests/fixtures/rule_cases.json): `inorganic` when any input is chemical, `organic` when at least one input
is organic/bio and none is chemical, nothing otherwise; `other` proves nothing.
Serves: FR56 (tags derived from input categories, contradictions flagged), PRD §12.2 (lots declared
Inorganic + IPM with only organic inputs and no pest event), Stage 3.
Callers: `rules.LOT_RULES` (service `check_lot`, which also stores `derived_tags` on the lot),
tests/unit/test_rules_lot.py and test_rules_shared_cases.py.
"""

from collections.abc import Iterable

from agritrace.core.enums import FlagSubject, Severity
from agritrace.modules.rules_flags.rules.context import FlagCandidate, LotContext

CODES = {"practice_tag_contradiction", "ipm_without_pest_event"}
CHEMICAL = {"chemical_fertilizer", "chemical_pesticide"}
ORGANIC = {"organic_fertilizer", "bio_fertilizer", "bio_pesticide"}


def derived_tags(categories: Iterable[str]) -> set[str]:
    """Derive the practice tags the inputs of a lot support.

    Args:
        categories: `inputs_master.category` of every input applied.

    Returns:
        `{"inorganic"}`, `{"organic"}` or an empty set (no inputs, or only `other`).
    """
    cats = set(categories)
    if cats & CHEMICAL:
        return {"inorganic"}
    return {"organic"} if cats & ORGANIC else set()


def practice_flags(declared: Iterable[str], categories: Iterable[str], has_pest_event: bool) -> list[str]:
    """Rule codes raised by the declared tags against the inputs and pest events.

    Args:
        declared: tags the farmer declared (`organic`, `inorganic`, `ipm`).
        categories: input categories applied on the lot.
        has_pest_event: True when the lot has a problem/pest event.

    Returns:
        `practice_tag_contradiction` when a declared Organic/Inorganic tag is not what the inputs support (no
        contradiction when they support none), then `ipm_without_pest_event` when IPM is declared without one.
    """
    tags, derived = set(declared), derived_tags(categories)
    contradicts = bool(derived) and any(t != "ipm" and t not in derived for t in tags)
    return [
        *(["practice_tag_contradiction"] if contradicts else []),
        *(["ipm_without_pest_event"] if "ipm" in tags and not has_pest_event else []),
    ]


def run(ctx: LotContext) -> list[FlagCandidate]:
    """Flag the lot's practice-tag problems.

    Args:
        ctx: the lot with its declared tags, input categories and whether it has a pest event.

    Returns:
        A warn per code from `practice_flags`, with declared and derived tags in `details`.
    """
    details = {
        "declared": sorted(ctx.declared_tags),
        "derived": sorted(derived_tags(ctx.input_categories)),
        "input_categories": sorted(set(ctx.input_categories)),
    }
    codes = practice_flags(ctx.declared_tags, ctx.input_categories, ctx.has_pest_event)
    return [FlagCandidate(FlagSubject.LOT, ctx.lot_id, code, Severity.WARN, details) for code in codes]
