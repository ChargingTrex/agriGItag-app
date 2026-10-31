// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ParameterResultOutcomeEnum _$parameterResultOutcomeEnum_graded =
    const ParameterResultOutcomeEnum._('graded');
const ParameterResultOutcomeEnum _$parameterResultOutcomeEnum_missing =
    const ParameterResultOutcomeEnum._('missing');
const ParameterResultOutcomeEnum
    _$parameterResultOutcomeEnum_profileIncomplete =
    const ParameterResultOutcomeEnum._('profileIncomplete');
const ParameterResultOutcomeEnum _$parameterResultOutcomeEnum_notGraded =
    const ParameterResultOutcomeEnum._('notGraded');
const ParameterResultOutcomeEnum _$parameterResultOutcomeEnum_exception =
    const ParameterResultOutcomeEnum._('exception');

ParameterResultOutcomeEnum _$parameterResultOutcomeEnumValueOf(String name) {
  switch (name) {
    case 'graded':
      return _$parameterResultOutcomeEnum_graded;
    case 'missing':
      return _$parameterResultOutcomeEnum_missing;
    case 'profileIncomplete':
      return _$parameterResultOutcomeEnum_profileIncomplete;
    case 'notGraded':
      return _$parameterResultOutcomeEnum_notGraded;
    case 'exception':
      return _$parameterResultOutcomeEnum_exception;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ParameterResultOutcomeEnum> _$parameterResultOutcomeEnumValues =
    BuiltSet<ParameterResultOutcomeEnum>(const <ParameterResultOutcomeEnum>[
  _$parameterResultOutcomeEnum_graded,
  _$parameterResultOutcomeEnum_missing,
  _$parameterResultOutcomeEnum_profileIncomplete,
  _$parameterResultOutcomeEnum_notGraded,
  _$parameterResultOutcomeEnum_exception,
]);

Serializer<ParameterResultOutcomeEnum> _$parameterResultOutcomeEnumSerializer =
    _$ParameterResultOutcomeEnumSerializer();

class _$ParameterResultOutcomeEnumSerializer
    implements PrimitiveSerializer<ParameterResultOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'graded': 'graded',
    'missing': 'missing',
    'profileIncomplete': 'profile_incomplete',
    'notGraded': 'not_graded',
    'exception': 'exception',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'graded': 'graded',
    'missing': 'missing',
    'profile_incomplete': 'profileIncomplete',
    'not_graded': 'notGraded',
    'exception': 'exception',
  };

  @override
  final Iterable<Type> types = const <Type>[ParameterResultOutcomeEnum];
  @override
  final String wireName = 'ParameterResultOutcomeEnum';

  @override
  Object serialize(Serializers serializers, ParameterResultOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ParameterResultOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ParameterResultOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ParameterResult extends ParameterResult {
  @override
  final bool? cappedBySource;
  @override
  final String? grade;
  @override
  final bool? labCertified;
  @override
  final RangeOutput? limit;
  @override
  final ParameterResultOutcomeEnum outcome;
  @override
  final String parameter;
  @override
  final String? readingId;
  @override
  final ReadingSource? source_;
  @override
  final String? unit;
  @override
  final String? value;

  factory _$ParameterResult([void Function(ParameterResultBuilder)? updates]) =>
      (ParameterResultBuilder()..update(updates))._build();

  _$ParameterResult._(
      {this.cappedBySource,
      this.grade,
      this.labCertified,
      this.limit,
      required this.outcome,
      required this.parameter,
      this.readingId,
      this.source_,
      this.unit,
      this.value})
      : super._();
  @override
  ParameterResult rebuild(void Function(ParameterResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ParameterResultBuilder toBuilder() => ParameterResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ParameterResult &&
        cappedBySource == other.cappedBySource &&
        grade == other.grade &&
        labCertified == other.labCertified &&
        limit == other.limit &&
        outcome == other.outcome &&
        parameter == other.parameter &&
        readingId == other.readingId &&
        source_ == other.source_ &&
        unit == other.unit &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cappedBySource.hashCode);
    _$hash = $jc(_$hash, grade.hashCode);
    _$hash = $jc(_$hash, labCertified.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, parameter.hashCode);
    _$hash = $jc(_$hash, readingId.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ParameterResult')
          ..add('cappedBySource', cappedBySource)
          ..add('grade', grade)
          ..add('labCertified', labCertified)
          ..add('limit', limit)
          ..add('outcome', outcome)
          ..add('parameter', parameter)
          ..add('readingId', readingId)
          ..add('source_', source_)
          ..add('unit', unit)
          ..add('value', value))
        .toString();
  }
}

class ParameterResultBuilder
    implements Builder<ParameterResult, ParameterResultBuilder> {
  _$ParameterResult? _$v;

  bool? _cappedBySource;
  bool? get cappedBySource => _$this._cappedBySource;
  set cappedBySource(bool? cappedBySource) =>
      _$this._cappedBySource = cappedBySource;

  String? _grade;
  String? get grade => _$this._grade;
  set grade(String? grade) => _$this._grade = grade;

  bool? _labCertified;
  bool? get labCertified => _$this._labCertified;
  set labCertified(bool? labCertified) => _$this._labCertified = labCertified;

  RangeOutputBuilder? _limit;
  RangeOutputBuilder get limit => _$this._limit ??= RangeOutputBuilder();
  set limit(RangeOutputBuilder? limit) => _$this._limit = limit;

  ParameterResultOutcomeEnum? _outcome;
  ParameterResultOutcomeEnum? get outcome => _$this._outcome;
  set outcome(ParameterResultOutcomeEnum? outcome) => _$this._outcome = outcome;

  String? _parameter;
  String? get parameter => _$this._parameter;
  set parameter(String? parameter) => _$this._parameter = parameter;

  String? _readingId;
  String? get readingId => _$this._readingId;
  set readingId(String? readingId) => _$this._readingId = readingId;

  ReadingSource? _source_;
  ReadingSource? get source_ => _$this._source_;
  set source_(ReadingSource? source_) => _$this._source_ = source_;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  ParameterResultBuilder() {
    ParameterResult._defaults(this);
  }

  ParameterResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cappedBySource = $v.cappedBySource;
      _grade = $v.grade;
      _labCertified = $v.labCertified;
      _limit = $v.limit?.toBuilder();
      _outcome = $v.outcome;
      _parameter = $v.parameter;
      _readingId = $v.readingId;
      _source_ = $v.source_;
      _unit = $v.unit;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ParameterResult other) {
    _$v = other as _$ParameterResult;
  }

  @override
  void update(void Function(ParameterResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ParameterResult build() => _build();

  _$ParameterResult _build() {
    _$ParameterResult _$result;
    try {
      _$result = _$v ??
          _$ParameterResult._(
            cappedBySource: cappedBySource,
            grade: grade,
            labCertified: labCertified,
            limit: _limit?.build(),
            outcome: BuiltValueNullFieldError.checkNotNull(
                outcome, r'ParameterResult', 'outcome'),
            parameter: BuiltValueNullFieldError.checkNotNull(
                parameter, r'ParameterResult', 'parameter'),
            readingId: readingId,
            source_: source_,
            unit: unit,
            value: value,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'limit';
        _limit?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ParameterResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
