// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standards_profile_rules_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandardsProfileRulesOutputSchemaVersionEnum
    _$standardsProfileRulesOutputSchemaVersionEnum_number1 =
    const StandardsProfileRulesOutputSchemaVersionEnum._('number1');

StandardsProfileRulesOutputSchemaVersionEnum
    _$standardsProfileRulesOutputSchemaVersionEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$standardsProfileRulesOutputSchemaVersionEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandardsProfileRulesOutputSchemaVersionEnum>
    _$standardsProfileRulesOutputSchemaVersionEnumValues = BuiltSet<
        StandardsProfileRulesOutputSchemaVersionEnum>(const <StandardsProfileRulesOutputSchemaVersionEnum>[
  _$standardsProfileRulesOutputSchemaVersionEnum_number1,
]);

Serializer<StandardsProfileRulesOutputSchemaVersionEnum>
    _$standardsProfileRulesOutputSchemaVersionEnumSerializer =
    _$StandardsProfileRulesOutputSchemaVersionEnumSerializer();

class _$StandardsProfileRulesOutputSchemaVersionEnumSerializer
    implements
        PrimitiveSerializer<StandardsProfileRulesOutputSchemaVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[
    StandardsProfileRulesOutputSchemaVersionEnum
  ];
  @override
  final String wireName = 'StandardsProfileRulesOutputSchemaVersionEnum';

  @override
  Object serialize(Serializers serializers,
          StandardsProfileRulesOutputSchemaVersionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandardsProfileRulesOutputSchemaVersionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandardsProfileRulesOutputSchemaVersionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StandardsProfileRulesOutput extends StandardsProfileRulesOutput {
  @override
  final String failGrade;
  @override
  final BuiltList<String> grades;
  @override
  final LabCertifiedRequires? labCertifiedRequires;
  @override
  final BuiltMap<String, LotGateOutput>? lotGates;
  @override
  final BuiltList<ParameterOutput> parameters;
  @override
  final String? publicNote;
  @override
  final StandardsProfileRulesOutputSchemaVersionEnum schemaVersion;
  @override
  final StandardRef standard;
  @override
  final BuiltList<TrailRuleOutput>? trailRules;
  @override
  final YieldRuleOutput? yield_;

  factory _$StandardsProfileRulesOutput(
          [void Function(StandardsProfileRulesOutputBuilder)? updates]) =>
      (StandardsProfileRulesOutputBuilder()..update(updates))._build();

  _$StandardsProfileRulesOutput._(
      {required this.failGrade,
      required this.grades,
      this.labCertifiedRequires,
      this.lotGates,
      required this.parameters,
      this.publicNote,
      required this.schemaVersion,
      required this.standard,
      this.trailRules,
      this.yield_})
      : super._();
  @override
  StandardsProfileRulesOutput rebuild(
          void Function(StandardsProfileRulesOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardsProfileRulesOutputBuilder toBuilder() =>
      StandardsProfileRulesOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandardsProfileRulesOutput &&
        failGrade == other.failGrade &&
        grades == other.grades &&
        labCertifiedRequires == other.labCertifiedRequires &&
        lotGates == other.lotGates &&
        parameters == other.parameters &&
        publicNote == other.publicNote &&
        schemaVersion == other.schemaVersion &&
        standard == other.standard &&
        trailRules == other.trailRules &&
        yield_ == other.yield_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, failGrade.hashCode);
    _$hash = $jc(_$hash, grades.hashCode);
    _$hash = $jc(_$hash, labCertifiedRequires.hashCode);
    _$hash = $jc(_$hash, lotGates.hashCode);
    _$hash = $jc(_$hash, parameters.hashCode);
    _$hash = $jc(_$hash, publicNote.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, standard.hashCode);
    _$hash = $jc(_$hash, trailRules.hashCode);
    _$hash = $jc(_$hash, yield_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandardsProfileRulesOutput')
          ..add('failGrade', failGrade)
          ..add('grades', grades)
          ..add('labCertifiedRequires', labCertifiedRequires)
          ..add('lotGates', lotGates)
          ..add('parameters', parameters)
          ..add('publicNote', publicNote)
          ..add('schemaVersion', schemaVersion)
          ..add('standard', standard)
          ..add('trailRules', trailRules)
          ..add('yield_', yield_))
        .toString();
  }
}

class StandardsProfileRulesOutputBuilder
    implements
        Builder<StandardsProfileRulesOutput,
            StandardsProfileRulesOutputBuilder> {
  _$StandardsProfileRulesOutput? _$v;

  String? _failGrade;
  String? get failGrade => _$this._failGrade;
  set failGrade(String? failGrade) => _$this._failGrade = failGrade;

  ListBuilder<String>? _grades;
  ListBuilder<String> get grades => _$this._grades ??= ListBuilder<String>();
  set grades(ListBuilder<String>? grades) => _$this._grades = grades;

  LabCertifiedRequiresBuilder? _labCertifiedRequires;
  LabCertifiedRequiresBuilder get labCertifiedRequires =>
      _$this._labCertifiedRequires ??= LabCertifiedRequiresBuilder();
  set labCertifiedRequires(LabCertifiedRequiresBuilder? labCertifiedRequires) =>
      _$this._labCertifiedRequires = labCertifiedRequires;

  MapBuilder<String, LotGateOutput>? _lotGates;
  MapBuilder<String, LotGateOutput> get lotGates =>
      _$this._lotGates ??= MapBuilder<String, LotGateOutput>();
  set lotGates(MapBuilder<String, LotGateOutput>? lotGates) =>
      _$this._lotGates = lotGates;

  ListBuilder<ParameterOutput>? _parameters;
  ListBuilder<ParameterOutput> get parameters =>
      _$this._parameters ??= ListBuilder<ParameterOutput>();
  set parameters(ListBuilder<ParameterOutput>? parameters) =>
      _$this._parameters = parameters;

  String? _publicNote;
  String? get publicNote => _$this._publicNote;
  set publicNote(String? publicNote) => _$this._publicNote = publicNote;

  StandardsProfileRulesOutputSchemaVersionEnum? _schemaVersion;
  StandardsProfileRulesOutputSchemaVersionEnum? get schemaVersion =>
      _$this._schemaVersion;
  set schemaVersion(
          StandardsProfileRulesOutputSchemaVersionEnum? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  StandardRefBuilder? _standard;
  StandardRefBuilder get standard => _$this._standard ??= StandardRefBuilder();
  set standard(StandardRefBuilder? standard) => _$this._standard = standard;

  ListBuilder<TrailRuleOutput>? _trailRules;
  ListBuilder<TrailRuleOutput> get trailRules =>
      _$this._trailRules ??= ListBuilder<TrailRuleOutput>();
  set trailRules(ListBuilder<TrailRuleOutput>? trailRules) =>
      _$this._trailRules = trailRules;

  YieldRuleOutputBuilder? _yield_;
  YieldRuleOutputBuilder get yield_ =>
      _$this._yield_ ??= YieldRuleOutputBuilder();
  set yield_(YieldRuleOutputBuilder? yield_) => _$this._yield_ = yield_;

  StandardsProfileRulesOutputBuilder() {
    StandardsProfileRulesOutput._defaults(this);
  }

  StandardsProfileRulesOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _failGrade = $v.failGrade;
      _grades = $v.grades.toBuilder();
      _labCertifiedRequires = $v.labCertifiedRequires?.toBuilder();
      _lotGates = $v.lotGates?.toBuilder();
      _parameters = $v.parameters.toBuilder();
      _publicNote = $v.publicNote;
      _schemaVersion = $v.schemaVersion;
      _standard = $v.standard.toBuilder();
      _trailRules = $v.trailRules?.toBuilder();
      _yield_ = $v.yield_?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandardsProfileRulesOutput other) {
    _$v = other as _$StandardsProfileRulesOutput;
  }

  @override
  void update(void Function(StandardsProfileRulesOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandardsProfileRulesOutput build() => _build();

  _$StandardsProfileRulesOutput _build() {
    _$StandardsProfileRulesOutput _$result;
    try {
      _$result = _$v ??
          _$StandardsProfileRulesOutput._(
            failGrade: BuiltValueNullFieldError.checkNotNull(
                failGrade, r'StandardsProfileRulesOutput', 'failGrade'),
            grades: grades.build(),
            labCertifiedRequires: _labCertifiedRequires?.build(),
            lotGates: _lotGates?.build(),
            parameters: parameters.build(),
            publicNote: publicNote,
            schemaVersion: BuiltValueNullFieldError.checkNotNull(
                schemaVersion, r'StandardsProfileRulesOutput', 'schemaVersion'),
            standard: standard.build(),
            trailRules: _trailRules?.build(),
            yield_: _yield_?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'grades';
        grades.build();
        _$failedField = 'labCertifiedRequires';
        _labCertifiedRequires?.build();
        _$failedField = 'lotGates';
        _lotGates?.build();
        _$failedField = 'parameters';
        parameters.build();

        _$failedField = 'standard';
        standard.build();
        _$failedField = 'trailRules';
        _trailRules?.build();
        _$failedField = 'yield_';
        _yield_?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandardsProfileRulesOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
