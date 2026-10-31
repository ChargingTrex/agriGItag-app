// Yield-ceiling preview for a harvest on a plot: the plot's declared area in acres fed to the ported
// `yieldOutcome` (20 % warn / 30 % hold margins from the Standards Profile).
// Requirement: FR57, FR68 (yield ceiling with 20–30 % margin), Dataflow Stage 7; D-006 (phone preview, server
//   re-runs B08 `yield_ceiling`).
// Callers: harvest and sell screens (M07), QC intake (M11); test/rules/preview_rules_test.dart.

import 'package:decimal/decimal.dart';

import '../refdata/models/reference.dart';
import '../refdata/models/standards.dart';
import 'grade_calculator.dart';

/// Previews the yield check of [kg] harvested on [plot] under [rules].
///
/// The plot's `cent` area is converted exactly (100 cents = 1 acre). Returns `pass`, `warn` or `hold`; null when
/// the profile has no yield rule or the area is not positive. Throws: [FormatException] when [kg] is not a number.
String? yieldCheck(StandardsRules rules, {required Object kg, required RefPlot plot}) {
  final area = toDecimal(plot.declaredArea);
  final acres = plot.areaUnit == 'cent' ? (area / Decimal.fromInt(100)).toDecimal() : area;
  return yieldOutcome(rules, kg, acres);
}
