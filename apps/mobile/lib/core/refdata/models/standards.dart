// Typed Standards Profile rules for the phone: the Dart mirror of the API's `StandardsProfileRules`.
// Requirement: FR47–FR50, FR68 (limits, plausibility, trail, yield margins), Dataflow Stages 5, 7, 8,
//   backend-design.md §3 (`standards` bundle part) and §4 (profile JSON), D-015 (versioned profile JSON).
// Callers: bundle_repository.dart (parses the `standards` part), lib/core/rules/grade_calculator.dart,
//   yield_check.dart, moisture_limit.dart, the M11 QC grading form (labels, method, standard edition),
//   test/rules/grade_calculator_test.dart (the shared grade_cases.json).
//
// Defaults equal the Pydantic defaults in apps/api/agritrace/modules/quality/schemas.py, so a trimmed bundle
// part (no `sources_allowed`, no `role`, ...) parses to what the server assumes. Validation stays on the server:
// the phone only reads profiles the server already accepted.

import 'package:decimal/decimal.dart';

/// Parses a JSON number (or numeric string) exactly, like Pydantic's `Decimal(str(x))`.
///
/// [v] is an `int`, `double` or `String`. Returns the exact decimal of its shortest text form (`0.7` → 0.7, not
/// the binary expansion of the double). Throws: [FormatException] when [v] is not a number.
Decimal toDecimal(Object v) => Decimal.parse(v.toString());

/// Like [toDecimal] but returns null for a null [v]. Throws: [FormatException] when [v] is not a number.
Decimal? toDecimalOrNull(Object? v) => v == null ? null : toDecimal(v);

/// All reading sources, in the order of the API's `ReadingSource` enum (default of `sources_allowed`).
const readingSources = ['lab', 'instrument', 'visual'];

/// An inclusive numeric interval; a null bound is open.
class Range {
  /// Creates a range from [min] to [max], both inclusive and optional.
  const Range({this.min, this.max});

  /// Parses `{"min": n?, "max": n?}` from [j]. Throws: [FormatException] on a non-numeric bound.
  factory Range.fromJson(Map<String, dynamic> j) =>
      Range(min: toDecimalOrNull(j['min']), max: toDecimalOrNull(j['max']));

  /// Lowest allowed value, inclusive; null means no lower bound.
  final Decimal? min;

  /// Highest allowed value, inclusive; null means no upper bound.
  final Decimal? max;

  /// True when [value] lies inside the bounds that are set (`min <= value <= max`). Throws nothing.
  bool holds(Decimal value) => (min == null || value >= min!) && (max == null || value <= max!);
}

/// One quality parameter of a profile (API `Parameter`).
class Parameter {
  /// Creates a parameter; prefer [Parameter.fromJson].
  const Parameter({
    required this.code,
    required this.unit,
    this.nameEn,
    this.nameLocal,
    this.methodRef,
    this.required = false,
    this.gradingStage = 'grading',
    this.limits,
    this.plausible,
    this.sourcesAllowed = readingSources,
    this.maxGradeForSource = const {},
    this.role = 'grading',
    this.exceptionFlags = const [],
  });

  /// Parses one parameter object [j] of the profile JSON; missing keys take the API defaults.
  ///
  /// Throws: [TypeError] when a key has the wrong JSON type, [FormatException] on a non-numeric bound.
  factory Parameter.fromJson(Map<String, dynamic> j) => Parameter(
    code: j['code'] as String,
    unit: (j['unit'] as String?) ?? '',
    nameEn: j['name_en'] as String?,
    nameLocal: j['name_local'] as String?,
    methodRef: j['method_ref'] as String?,
    required: (j['required'] as bool?) ?? false,
    gradingStage: (j['grading_stage'] as String?) ?? 'grading',
    limits: (j['limits'] as Map<String, dynamic>?)?.map(
      (grade, r) => MapEntry(grade, Range.fromJson(r as Map<String, dynamic>)),
    ),
    plausible: j['plausible'] == null ? null : Range.fromJson(j['plausible'] as Map<String, dynamic>),
    sourcesAllowed: (j['sources_allowed'] as List<dynamic>?)?.cast<String>() ?? readingSources,
    maxGradeForSource: (j['max_grade_for_source'] as Map<String, dynamic>?)?.cast<String, String>() ?? const {},
    role: (j['role'] as String?) ?? 'grading',
    exceptionFlags: (j['exception_flags'] as List<dynamic>?)?.cast<String>() ?? const [],
  );

  /// Stable snake_case code readings use, e.g. `moisture`.
  final String code;

  /// Unit every reading must carry, e.g. `%`.
  final String unit;

  /// English label for forms (M11 grading form); null falls back to [code].
  final String? nameEn;

  /// Label in the local script (Tamil for the pilot); null falls back to [nameEn].
  final String? nameLocal;

  /// Test method the standard prescribes (FR42), copied onto each reading; null when the profile names none.
  final String? methodRef;

  /// A grading reading is needed for a complete grade (only when [limits] is set).
  final bool required;

  /// Stage whose latest reading is used to compute the grade.
  final String gradingStage;

  /// Interval per grade name; null means not graded yet (`load_from_standard`).
  final Map<String, Range>? limits;

  /// Physically sensible range; readings outside it are rejected at entry (FR50).
  final Range? plausible;

  /// Sources accepted at entry (FR42, FR44).
  final List<String> sourcesAllowed;

  /// Best grade a reading from a source can earn, e.g. visual → Standard (FR44).
  final Map<String, String> maxGradeForSource;

  /// `grading`, `label_declaration` or `contract_spec`; only `grading` takes part in the grade.
  final String role;

  /// Batch attributes (e.g. `monsooned`) under which an out-of-limit value warns instead of failing.
  final List<String> exceptionFlags;
}

/// What makes a grade "Lab-certified" (FR51).
class LabCertifiedRequires {
  /// Creates the rule; defaults are the API's.
  const LabCertifiedRequires({this.anyParameterSource = 'lab', this.nablNoPresent = true});

  /// Parses `{"any_parameter_source", "nabl_no_present"}` from [j]. Throws: [TypeError] on wrong JSON types.
  factory LabCertifiedRequires.fromJson(Map<String, dynamic> j) => LabCertifiedRequires(
    anyParameterSource: (j['any_parameter_source'] as String?) ?? 'lab',
    nablNoPresent: (j['nabl_no_present'] as bool?) ?? true,
  );

  /// Source a reading must have.
  final String anyParameterSource;

  /// Whether that reading must also carry a non-blank NABL number.
  final bool nablNoPresent;
}

/// A reading condition a lot must meet before a lifecycle step, e.g. `ready_for_sale` (Dataflow Stage 5).
class LotGate {
  /// Creates a gate on [parameter] at [stage] with inclusive [min]/[max].
  const LotGate({required this.parameter, required this.stage, this.min, this.max});

  /// Parses one gate object [j]. Throws: [TypeError] on wrong JSON types, [FormatException] on a bad bound.
  factory LotGate.fromJson(Map<String, dynamic> j) => LotGate(
    parameter: j['parameter'] as String,
    stage: j['stage'] as String,
    min: toDecimalOrNull(j['min']),
    max: toDecimalOrNull(j['max']),
  );

  /// Parameter code checked.
  final String parameter;

  /// Stage whose latest reading is checked.
  final String stage;

  /// Lowest passing value, inclusive.
  final Decimal? min;

  /// Highest passing value, inclusive (e.g. moisture ≤ 11 %).
  final Decimal? max;
}

/// How a parameter may change from one capture stage to the next (FR50: moisture must not rise).
class TrailRule {
  /// Creates a trail rule on [parameter] over [stages]; [tolerance] defaults to 0.
  TrailRule({required this.parameter, required this.stages, Decimal? tolerance, this.overrideWithReason = false})
    : tolerance = tolerance ?? Decimal.zero;

  /// Parses one trail rule object [j]. Throws: [TypeError] on wrong JSON types, [FormatException] on a bad number.
  factory TrailRule.fromJson(Map<String, dynamic> j) => TrailRule(
    parameter: j['parameter'] as String,
    stages: (j['stages'] as List<dynamic>).cast<String>(),
    tolerance: toDecimalOrNull(j['tolerance']),
    overrideWithReason: (j['override_with_reason'] as bool?) ?? false,
  );

  /// Parameter code the rule follows.
  final String parameter;

  /// Stages in chain order, earliest first.
  final List<String> stages;

  /// Rise tolerated before it counts as a violation (meter noise).
  final Decimal tolerance;

  /// A violating reading is accepted with a `reason_code` (then flagged).
  final bool overrideWithReason;
}

/// Plausible yield per acre with the warn and hold margins (FR68, Stage 7).
class YieldRule {
  /// Creates the rule from [ceilingKgPerAcre] and the two margins in %.
  const YieldRule({required this.ceilingKgPerAcre, required this.warnMarginPct, required this.holdMarginPct});

  /// Parses `{"ceiling_kg_per_acre", "warn_margin_pct", "hold_margin_pct"}` from [j].
  ///
  /// Throws: [TypeError] when a key is missing, [FormatException] on a non-numeric value.
  factory YieldRule.fromJson(Map<String, dynamic> j) => YieldRule(
    ceilingKgPerAcre: toDecimal(j['ceiling_kg_per_acre'] as Object),
    warnMarginPct: toDecimal(j['warn_margin_pct'] as Object),
    holdMarginPct: toDecimal(j['hold_margin_pct'] as Object),
  );

  /// Plausible maximum harvest, kg/acre.
  final Decimal ceilingKgPerAcre;

  /// Excess over the ceiling still passing silently, %.
  final Decimal warnMarginPct;

  /// Excess above which the lot is held out of GI, %.
  final Decimal holdMarginPct;
}

/// The rules JSON of one Standards Profile version (API `StandardsProfileRules`). Grades are best first.
class StandardsRules {
  /// Creates rules; prefer [StandardsRules.fromJson].
  const StandardsRules({
    required this.grades,
    required this.failGrade,
    required this.parameters,
    this.standardName = '',
    this.standardEdition = '',
    this.labCertifiedRequires,
    this.lotGates = const {},
    this.trailRules = const [],
    this.yieldRule,
  });

  /// Parses a profile rules object [j] (full profile JSON or the `standards` bundle entry).
  ///
  /// Throws: [TypeError] when a key has the wrong JSON type, [FormatException] on a non-numeric value.
  factory StandardsRules.fromJson(Map<String, dynamic> j) => StandardsRules(
    grades: (j['grades'] as List<dynamic>?)?.cast<String>() ?? const [],
    failGrade: (j['fail_grade'] as String?) ?? '',
    parameters: [
      for (final p in j['parameters'] as List<dynamic>? ?? const []) Parameter.fromJson(p as Map<String, dynamic>),
    ],
    standardName: ((j['standard'] as Map<String, dynamic>?)?['name'] as String?) ?? '',
    standardEdition: ((j['standard'] as Map<String, dynamic>?)?['edition'] as String?) ?? '',
    labCertifiedRequires: j['lab_certified_requires'] == null
        ? null
        : LabCertifiedRequires.fromJson(j['lab_certified_requires'] as Map<String, dynamic>),
    lotGates: (j['lot_gates'] as Map<String, dynamic>? ?? const {}).map(
      (name, g) => MapEntry(name, LotGate.fromJson(g as Map<String, dynamic>)),
    ),
    trailRules: [
      for (final t in j['trail_rules'] as List<dynamic>? ?? const []) TrailRule.fromJson(t as Map<String, dynamic>),
    ],
    yieldRule: j['yield'] == null ? null : YieldRule.fromJson(j['yield'] as Map<String, dynamic>),
  );

  /// Grade names, best first, e.g. `[Special, Standard]`.
  final List<String> grades;

  /// Grade given when a limit is not met, e.g. `Below grade`.
  final String failGrade;

  /// Every parameter of the standard.
  final List<Parameter> parameters;

  /// Name of the standard the limits come from (`standard.name`, FR47); empty when the part omits it.
  final String standardName;

  /// Edition cited (`standard.edition`, FR47, FR51), shown beside the grade preview (M11); empty when omitted.
  final String standardEdition;

  /// Condition for the Lab-certified badge; null means never lab-certified.
  final LabCertifiedRequires? labCertifiedRequires;

  /// Named lot gates, e.g. `ready_for_sale`.
  final Map<String, LotGate> lotGates;

  /// Stage-to-stage rules (FR50).
  final List<TrailRule> trailRules;

  /// Yield-ceiling rule (FR68); null means no yield check for the crop.
  final YieldRule? yieldRule;

  /// The parameter with [code], or null when the profile has none. Throws nothing.
  Parameter? parameter(String code) => parameters.where((p) => p.code == code).firstOrNull;
}
