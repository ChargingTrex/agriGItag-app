// Drying moisture preview: tells the farmer whether a drying-end moisture reading opens the profile's
// `ready_for_sale` lot gate ("Ready") or not ("Continue drying").
// Requirement: Dataflow Stage 5 (ready-for-sale lot gate, moisture ≤ 11 % for chilli), FR43, FR50; D-006 (phone
//   preview through the ported `lotGate`, server authority).
// Callers: drying / moisture reading screens (M07; features/moisture_reading), QC intake (M11);
//   test/rules/preview_rules_test.dart.

import '../refdata/models/standards.dart';
import 'grade_calculator.dart';

/// What the farmer is told after a drying-end moisture reading.
enum MoistureVerdict {
  /// The lot may be offered for sale.
  ready,

  /// Above the gate's limit: keep drying.
  continueDrying,
}

/// The verdict for the newest [moisture] reading (a JSON number or numeric string, in %) under [rules].
///
/// The reading is taken at the gate's own stage (drying end for chilli), so it is the latest one `lotGate` sees.
/// A profile without a `ready_for_sale` gate never blocks. Returns [MoistureVerdict.ready] or
/// [MoistureVerdict.continueDrying]. Throws: [FormatException] when [moisture] is not a number.
MoistureVerdict moistureVerdict(StandardsRules rules, Object moisture) {
  final gate = rules.lotGates['ready_for_sale'];
  if (gate == null) return MoistureVerdict.ready;
  final reading = Reading(
    parameterCode: gate.parameter,
    value: toDecimal(moisture),
    unit: '%',
    stage: gate.stage,
    source: 'instrument',
  );
  return lotGate(rules, 'ready_for_sale', [reading]) ? MoistureVerdict.ready : MoistureVerdict.continueDrying;
}
