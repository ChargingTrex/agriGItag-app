// Practice-tag preview: derives Organic / Inorganic from the categories of the inputs a lot used and flags a
// declared tag that contradicts them, or IPM declared without any problem/pest event.
// Requirement: FR56 (tags derived from input categories, contradictions flagged for the FPO Admin), PRD §12 (all
//   lots declared Inorganic + IPM with only organic inputs and no pest event); D-006 (phone preview, server
//   re-runs B08 `practice_tags`; flag codes equal the server's).
// Callers: farmer history / lot summary (M07), officer flags (M10); test/rules/practice_tags_test.dart.

/// Input categories that make a lot Inorganic (FR56); every other category is organic or biological.
const chemicalCategories = {'chemical_fertilizer', 'chemical_pesticide'};

/// The tags the [inputCategories] of a lot support: `inorganic` when any input is chemical, `organic` when there
/// are inputs and none is chemical, nothing when no input was recorded. Throws nothing.
Set<String> derivedPracticeTags(Iterable<String> inputCategories) {
  if (inputCategories.isEmpty) return {};
  return {inputCategories.any(chemicalCategories.contains) ? 'inorganic' : 'organic'};
}

/// Flags for the farmer's [declared] tags (`organic`, `inorganic`, `ipm`) against the lot's [inputCategories] and
/// whether it has a problem/pest event ([hasPestEvent]).
///
/// Returns `practice_tag_contradiction` when a declared Organic or Inorganic tag is not what the inputs support,
/// and `ipm_without_pest_event` when IPM is declared without a problem/pest event; empty when consistent or no
/// input was recorded. Throws nothing.
List<String> practiceFlags({
  required Set<String> declared,
  required Iterable<String> inputCategories,
  required bool hasPestEvent,
}) {
  final derived = derivedPracticeTags(inputCategories);
  final contradicts = derived.isNotEmpty && declared.any((t) => t != 'ipm' && !derived.contains(t));
  return [
    if (contradicts) 'practice_tag_contradiction',
    if (declared.contains('ipm') && !hasPestEvent) 'ipm_without_pest_event',
  ];
}
