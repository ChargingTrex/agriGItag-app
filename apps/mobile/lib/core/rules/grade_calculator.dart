// Grade preview: a line-by-line Dart port of apps/api/agritrace/modules/quality/grade_engine.py
// (`compute`, `rank`, `declared_vs_computed`, `check_plausibility`, `check_trail`, `lot_gate`, `yield_outcome`).
// Requirement: FR44 (visual cap), FR48 (batch grade = worst parameter grade), FR49 (declared vs computed), FR50
//   (plausibility, moisture trail), FR51 (lab-certified), FR68 (yield 20 %/30 %), Dataflow Stages 5, 7, 8,
//   backend-design.md §4.
// Callers: QC grading/intake screens (M11), moisture_limit.dart, yield_check.dart,
//   test/rules/grade_calculator_test.dart (all cases of the shared grade_cases.json).
//
// DECISION D-006: the phone runs the same rules as the server, as an instant offline preview; the server re-runs
//   them and its result is the authority.
//   ADV: instant grade, moisture and yield feedback with no signal.
//   COMPROMISE: two interpreters (Python and Dart) of one JSON, kept equal by test/fixtures/grade_cases.json, a
//     byte-identical copy of apps/api/tests/fixtures/grade_cases.json (tool/check_shared_fixtures.sh in CI).
// DECISION D-015: one generic engine reads the versioned profile JSON; there is no per-crop code.
//   ADV: chilli, turmeric, saffron and coffee profiles all run through the same steps.
//   COMPROMISE: non-tabular standards need engine extensions, on both sides.
//
// Numbers are `Decimal` (package:decimal) because the Python engine uses `Decimal`: a double port gets the
// boundaries wrong (1,950 kg on 1.5 acre is exactly 30 % over and must warn; doubles compute 30.000000000000004).

import 'package:decimal/decimal.dart';

import '../refdata/models/standards.dart';

/// The engine's view of one quality reading (a stored row or a draft on the phone).
class Reading {
  /// Creates a reading of [parameterCode] = [value] [unit] captured at [stage] by [source].
  const Reading({
    this.id,
    required this.parameterCode,
    required this.value,
    required this.unit,
    required this.stage,
    required this.source,
    this.measuredAt,
    this.labNablNo,
  });

  /// Parses the API/fixture reading object [j] (`value` as a JSON number or numeric string).
  ///
  /// Throws: [TypeError] on a missing key, [FormatException] on a bad number or timestamp.
  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
    id: j['id'] as String?,
    parameterCode: j['parameter_code'] as String,
    value: toDecimal(j['value'] as Object),
    unit: j['unit'] as String,
    stage: j['stage'] as String,
    source: j['source'] as String,
    measuredAt: j['measured_at'] == null ? null : DateTime.parse(j['measured_at'] as String),
    labNablNo: j['lab_nabl_no'] as String?,
  );

  /// Reading id (UUIDv7), the tie-break between equal capture times.
  final String? id;

  /// Profile parameter code.
  final String parameterCode;

  /// Measured value.
  final Decimal value;

  /// Unit of [value].
  final String unit;

  /// `drying_end`, `intake`, `grading` or `storage`.
  final String stage;

  /// `lab`, `instrument` or `visual`.
  final String source;

  /// Capture time; the latest wins, null sorts first.
  final DateTime? measuredAt;

  /// NABL accreditation number, for the Lab-certified badge.
  final String? labNablNo;
}

/// One parameter's contribution to a [GradeResult] (API `ParameterResult`).
class ParameterResult {
  /// Creates a result for [parameter] with [outcome].
  const ParameterResult({
    required this.parameter,
    required this.outcome,
    required this.labCertified,
    this.grade,
    this.limit,
    this.cappedBySource = false,
    this.reading,
  });

  /// Parameter code.
  final String parameter;

  /// `graded`, `missing`, `profile_incomplete`, `not_graded` or `exception`.
  final String outcome;

  /// Whether a reading of this parameter meets `lab_certified_requires`.
  final bool labCertified;

  /// Grade reached (graded parameters only).
  final String? grade;

  /// Limit of the grade reached; null for the fail grade.
  final Range? limit;

  /// True when `max_grade_for_source` lowered the grade.
  final bool cappedBySource;

  /// The reading used, when there is one.
  final Reading? reading;
}

/// Outcome of [compute] (FR48, FR51).
class GradeResult {
  /// Creates a result; produced by [compute].
  const GradeResult({
    required this.status,
    required this.grade,
    required this.labCertified,
    required this.perParameter,
    required this.missingRequired,
    required this.profileIncomplete,
    required this.warnings,
  });

  /// `ok`, or `incomplete` when a required reading is missing.
  final String status;

  /// Batch grade (worst parameter grade); null when incomplete.
  final String? grade;

  /// Any reading given meets `lab_certified_requires`.
  final bool labCertified;

  /// Every parameter's contribution, by code, in profile order.
  final Map<String, ParameterResult> perParameter;

  /// Required graded parameters without a reading.
  final List<String> missingRequired;

  /// Grading parameters skipped because their limits are still `load_from_standard`.
  final List<String> profileIncomplete;

  /// Parameters whose limits were waived by an exception flag.
  final List<String> warnings;
}

/// Why a reading is rejected at entry (FR50); [code] equals the API error code.
class Violation {
  /// Creates a violation of [code] on [parameter].
  const Violation({required this.code, required this.parameter, required this.message, this.overridable = false});

  /// `unknown_parameter`, `unit_mismatch`, `implausible_value`, `source_not_allowed` or `moisture_trail_violation`.
  final String code;

  /// Parameter code of the reading.
  final String parameter;

  /// English explanation for logs.
  final String message;

  /// True when a `reason_code` turns the rejection into a flag.
  final bool overridable;
}

/// Position of [grade] under [rules], best first: 0 for the best grade, `grades.length` for the fail grade,
/// null for a name the profile does not know. Throws nothing.
int? rank(StandardsRules rules, String grade) {
  if (grade == rules.failGrade) return rules.grades.length;
  final i = rules.grades.indexOf(grade);
  return i < 0 ? null : i;
}

const _noId = '00000000-0000-0000-0000-000000000000';

/// Orders two readings by `(measuredAt, id)`, null time first, as the Python `_latest` key does.
///
/// [a] and [b] are the readings; returns <0, 0 or >0. UUIDs compare as lower-case hex text, which equals the
/// Python `uuid.UUID` integer order. Throws nothing.
int _byTimeThenId(Reading a, Reading b) {
  final ta = a.measuredAt, tb = b.measuredAt;
  final byTime = ta == null ? (tb == null ? 0 : -1) : (tb == null ? 1 : ta.compareTo(tb));
  return byTime != 0 ? byTime : (a.id ?? _noId).toLowerCase().compareTo((b.id ?? _noId).toLowerCase());
}

/// The most recent of [readings] by `(measuredAt, id)`, independent of input order; null when empty.
///
/// On a full tie the first one wins, like Python's `max`. Throws nothing.
Reading? _latest(Iterable<Reading> readings) =>
    readings.fold<Reading?>(null, (best, r) => best == null || _byTimeThenId(r, best) > 0 ? r : best);

/// True when [reading] is an accredited lab result under [rules]' `lab_certified_requires` (FR51).
///
/// Needs the rule, a parameter in the profile, the required source and, when asked, a non-blank NABL number.
/// Throws nothing.
bool _countsAsLab(StandardsRules rules, Reading reading) {
  final need = rules.labCertifiedRequires;
  if (need == null || rules.parameter(reading.parameterCode) == null) return false;
  final hasNabl = (reading.labNablNo ?? '').trim().isNotEmpty;
  return reading.source == need.anyParameterSource && (hasNabl || !need.nablNoPresent);
}

/// Computes the grade [readings] earn under [rules] (backend-design.md §4, FR48).
///
/// Steps as in Python: latest reading per parameter at its grading stage; a missing required parameter with limits
/// makes the result incomplete; each parameter gets the best grade whose limits hold, else the fail grade, capped
/// by `max_grade_for_source`; the batch grade is the worst parameter grade; lab-certified when any reading meets
/// the rule. [exceptionFlags] (e.g. `monsooned`) turn an out-of-limit value of a parameter listing that flag into
/// a warning. Returns the result with a per-parameter breakdown. Throws nothing.
GradeResult compute(StandardsRules rules, List<Reading> readings, [Iterable<String> exceptionFlags = const []]) {
  final flags = exceptionFlags.toSet();
  final per = <String, ParameterResult>{};
  final missing = <String>[], pending = <String>[], warnings = <String>[];
  var worst = -1; // rank of the worst graded parameter so far
  final n = rules.grades.length;
  for (final p in rules.parameters) {
    final reading = _latest(readings.where((r) => r.parameterCode == p.code && r.stage == p.gradingStage));
    final lab = readings.any((r) => r.parameterCode == p.code && _countsAsLab(rules, r));
    ParameterResult result(String outcome, {String? grade, Range? limit, bool capped = false}) => ParameterResult(
      parameter: p.code,
      outcome: outcome,
      labCertified: lab,
      grade: grade,
      limit: limit,
      cappedBySource: capped,
      reading: reading,
    );
    if (p.role != 'grading') {
      per[p.code] = result('not_graded');
      continue;
    }
    final limits = p.limits;
    if (limits == null) {
      pending.add(p.code);
      per[p.code] = result('profile_incomplete');
      continue;
    }
    if (reading == null) {
      if (p.required) missing.add(p.code);
      per[p.code] = result('missing');
      continue;
    }
    var position = n;
    for (var i = 0; i < n; i++) {
      if (limits[rules.grades[i]]?.holds(reading.value) ?? false) {
        position = i;
        break;
      }
    }
    if (position == n && p.exceptionFlags.any(flags.contains)) {
      // "Flag, do not reject" (PRD §6.8 monsooned coffee): the parameter stops limiting the grade.
      warnings.add(p.code);
      if (worst < 0) worst = 0;
      per[p.code] = result('exception');
      continue;
    }
    var limit = position < n ? limits[rules.grades[position]] : null;
    final cap = p.maxGradeForSource[reading.source];
    final capped = cap != null && rules.grades.indexOf(cap) > position;
    if (capped) {
      position = rules.grades.indexOf(cap);
      limit = limits[cap];
    }
    if (position > worst) worst = position;
    per[p.code] = result(
      'graded',
      grade: position < n ? rules.grades[position] : rules.failGrade,
      limit: limit,
      capped: capped,
    );
  }
  final complete = missing.isEmpty && worst >= 0;
  return GradeResult(
    status: complete ? 'ok' : 'incomplete',
    grade: complete ? (worst < n ? rules.grades[worst] : rules.failGrade) : null,
    labCertified: readings.any((r) => _countsAsLab(rules, r)),
    perParameter: per,
    missingRequired: missing,
    profileIncomplete: pending,
    warnings: warnings,
  );
}

/// Compares the officer's [declared] grade with the [computed] one under [rules] (FR49).
///
/// [computed] is null when incomplete (only the name is checked then). Returns `unknown_grade_for_profile` when
/// the profile has no such grade, `declared_above_computed` when the declared grade is better, else `ok`.
/// Throws nothing.
String declaredVsComputed(StandardsRules rules, String declared, String? computed) {
  final declaredRank = rank(rules, declared);
  if (declaredRank == null) return 'unknown_grade_for_profile';
  final computedRank = computed == null ? null : rank(rules, computed);
  return computedRank != null && declaredRank < computedRank ? 'declared_above_computed' : 'ok';
}

/// Checks [reading] at entry against its parameter in [rules] (FR50): known code, unit, range, source.
///
/// Returns every violation in the order unknown parameter, unit, range, source; an unknown parameter is
/// reported alone; empty when acceptable. Throws nothing.
List<Violation> checkPlausibility(StandardsRules rules, Reading reading) {
  final p = rules.parameter(reading.parameterCode);
  if (p == null) {
    return [Violation(code: 'unknown_parameter', parameter: reading.parameterCode, message: 'Not in the profile.')];
  }
  final plausible = p.plausible;
  return [
    if (reading.unit != p.unit)
      Violation(code: 'unit_mismatch', parameter: p.code, message: "Unit must be '${p.unit}'."),
    if (plausible != null && !plausible.holds(reading.value))
      Violation(code: 'implausible_value', parameter: p.code, message: 'Outside [${plausible.min}, ${plausible.max}].'),
    if (!p.sourcesAllowed.contains(reading.source))
      Violation(code: 'source_not_allowed', parameter: p.code, message: 'Allowed: ${p.sourcesAllowed.join(', ')}.'),
  ];
}

/// Applies [rules]' trail rules to [newReading] given the [priorReadings] of the lot or batch (FR50).
///
/// The baseline is the highest value among the readings at the latest earlier stage that has any (component lots
/// feed one batch, so the most lenient is used). Returns a `moisture_trail_violation` (overridable when the rule
/// allows a reason) if the value rises above baseline + tolerance, else null. Throws nothing.
Violation? checkTrail(StandardsRules rules, List<Reading> priorReadings, Reading newReading) {
  for (final rule in rules.trailRules) {
    if (rule.parameter != newReading.parameterCode || !rule.stages.contains(newReading.stage)) continue;
    final earlierStages = rule.stages.sublist(0, rule.stages.indexOf(newReading.stage));
    final earlier = priorReadings
        .where((r) => r.parameterCode == rule.parameter && earlierStages.contains(r.stage))
        .toList();
    if (earlier.isEmpty) continue;
    final lastStage = earlier.map((r) => rule.stages.indexOf(r.stage)).reduce((a, b) => a > b ? a : b);
    final baseline = earlier
        .where((r) => rule.stages.indexOf(r.stage) == lastStage)
        .map((r) => r.value)
        .reduce((a, b) => a > b ? a : b);
    if (newReading.value > baseline + rule.tolerance) {
      return Violation(
        code: 'moisture_trail_violation',
        parameter: rule.parameter,
        message:
            '${newReading.value} at ${newReading.stage} is above $baseline at ${rule.stages[lastStage]} '
            '(+${rule.tolerance} tolerated).',
        overridable: rule.overrideWithReason,
      );
    }
  }
  return null;
}

/// Tells whether a lot's [readings] pass the gate named [gate] in [rules] (e.g. `ready_for_sale`, Stage 5).
///
/// Returns true when the profile has no such gate, or the latest reading of the gate's parameter at the gate's
/// stage lies within its bounds; false when there is no such reading or it is out of bounds. Throws nothing.
bool lotGate(StandardsRules rules, String gate, List<Reading> readings) {
  final g = rules.lotGates[gate];
  if (g == null) return true;
  final latest = _latest(readings.where((r) => r.parameterCode == g.parameter && r.stage == g.stage));
  return latest != null && Range(min: g.min, max: g.max).holds(latest.value);
}

/// Compares a harvest of [kg] with [declaredAcres] × the yield ceiling of [rules] (FR68, Dataflow Stage 7).
///
/// [kg] and [declaredAcres] are `num` or numeric `String`, read exactly via their text form. Returns `pass` up to
/// `warn_margin_pct` over the ceiling, `warn` up to `hold_margin_pct`, `hold` above; null when the profile has no
/// yield rule or the area is not positive. Throws: [FormatException] when an input is not a number.
String? yieldOutcome(StandardsRules rules, Object kg, Object declaredAcres) {
  final y = rules.yieldRule;
  final kgD = toDecimal(kg), acres = toDecimal(declaredAcres);
  if (y == null || acres <= Decimal.zero) return null;
  // Rational is exact; Python rounds the quotient to 28 significant digits, which can only differ within 1e-26 %
  // of a margin.
  final excessPct = (kgD / (y.ceilingKgPerAcre * acres) - Decimal.one.toRational()) * Decimal.fromInt(100).toRational();
  if (excessPct <= y.warnMarginPct.toRational()) return 'pass';
  return excessPct <= y.holdMarginPct.toRational() ? 'warn' : 'hold';
}
