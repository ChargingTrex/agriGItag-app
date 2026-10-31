// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standards_profile_rules_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandardsProfileRulesInputSchemaVersionEnum
    _$standardsProfileRulesInputSchemaVersionEnum_number1 =
    const StandardsProfileRulesInputSchemaVersionEnum._('number1');

StandardsProfileRulesInputSchemaVersionEnum
    _$standardsProfileRulesInputSchemaVersionEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$standardsProfileRulesInputSchemaVersionEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandardsProfileRulesInputSchemaVersionEnum>
    _$standardsProfileRulesInputSchemaVersionEnumValues = BuiltSet<
        StandardsProfileRulesInputSchemaVersionEnum>(const <StandardsProfileRulesInputSchemaVersionEnum>[
  _$standardsProfileRulesInputSchemaVersionEnum_number1,
]);

Serializer<StandardsProfileRulesInputSchemaVersionEnum>
    _$standardsProfileRulesInputSchemaVersionEnumSerializer =
    _$StandardsProfileRulesInputSchemaVersionEnumSerializer();

class _$StandardsProfileRulesInputSchemaVersionEnumSerializer
    implements
        PrimitiveSerializer<StandardsProfileRulesInputSchemaVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[
    StandardsProfileRulesInputSchemaVersionEnum
  ];
  @override
  final String wireName = 'StandardsProfileRulesInputSchemaVersionEnum';

  @override
  Object serialize(Serializers serializers,
          StandardsProfileRulesInputSchemaVersionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandardsProfileRulesInputSchemaVersionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandardsProfileRulesInputSchemaVersionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StandardsProfileRulesInput extends StandardsProfileRulesInput {
  @override
  final String failGrade;
  @override
  final BuiltList<String> grades;
  @override
  final LabCertifiedRequires? labCertifiedRequires;
  @override
  final BuiltMap<String, LotGateInput>? lotGates;
  @override
  final BuiltList<ParameterInput> parameters;
  @override
  final String? publicNote;
  @override
  final StandardsProfileRulesInputSchemaVersionEnum schemaVersion;
  @override
  final StandardRef standard;
  @override
  final BuiltList<TrailRuleInput>? trailRules;
  @override
  final YieldRuleInput? yield_;

  factory _$StandardsProfileRulesInput(
          [void Function(StandardsProfileRulesInputBuilder)? updates]) =>
      (StandardsProfileRulesInputBuilder()..update(updates))._build();

  _$StandardsProfileRulesInput._(
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
  StandardsProfileRulesInput rebuild(
          void Function(StandardsProfileRulesInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardsProfileRulesInputBuilder toBuilder() =>
      StandardsProfileRulesInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandardsProfileRulesInput &&
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
    return (newBuiltValueToStringHelper(r'StandardsProfileRulesInput')
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

class StandardsProfileRulesInputBuilder
    implements
        Builder<StandardsProfileRulesInput, StandardsProfileRulesInputBuilder> {
  _$StandardsProfileRulesInput? _$v;

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

  MapBuilder<String, LotGateInput>? _lotGates;
  MapBuilder<String, LotGateInput> get lotGates =>
      _$this._lotGates ??= MapBuilder<String, LotGateInput>();
  set lotGates(MapBuilder<String, LotGateInput>? lotGates) =>
      _$this._lotGates = lotGates;

  ListBuilder<ParameterInput>? _parameters;
  ListBuilder<ParameterInput> get parameters =>
      _$this._parameters ??= ListBuilder<ParameterInput>();
  set parameters(ListBuilder<ParameterInput>? parameters) =>
      _$this._parameters = parameters;

  String? _publicNote;
  String? get publicNote => _$this._publicNote;
  set publicNote(String? publicNote) => _$this._publicNote = publicNote;

  StandardsProfileRulesInputSchemaVersionEnum? _schemaVersion;
  StandardsProfileRulesInputSchemaVersionEnum? get schemaVersion =>
      _$this._schemaVersion;
  set schemaVersion(
          StandardsProfileRulesInputSchemaVersionEnum? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  StandardRefBuilder? _standard;
  StandardRefBuilder get standard => _$this._standard ??= StandardRefBuilder();
  set standard(StandardRefBuilder? standard) => _$this._standard = standard;

  ListBuilder<TrailRuleInput>? _trailRules;
  ListBuilder<TrailRuleInput> get trailRules =>
      _$this._trailRules ??= ListBuilder<TrailRuleInput>();
  set trailRules(ListBuilder<TrailRuleInput>? trailRules) =>
      _$this._trailRules = trailRules;

  YieldRuleInputBuilder? _yield_;
  YieldRuleInputBuilder get yield_ =>
      _$this._yield_ ??= YieldRuleInputBuilder();
  set yield_(YieldRuleInputBuilder? yield_) => _$this._yield_ = yield_;

  StandardsProfileRulesInputBuilder() {
    StandardsProfileRulesInput._defaults(this);
  }

  StandardsProfileRulesInputBuilder get _$this {
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
  void replace(StandardsProfileRulesInput other) {
    _$v = other as _$StandardsProfileRulesInput;
  }

  @override
  void update(void Function(StandardsProfileRulesInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandardsProfileRulesInput build() => _build();

  _$StandardsProfileRulesInput _build() {
    _$StandardsProfileRulesInput _$result;
    try {
      _$result = _$v ??
          _$StandardsProfileRulesInput._(
            failGrade: BuiltValueNullFieldError.checkNotNull(
                failGrade, r'StandardsProfileRulesInput', 'failGrade'),
            grades: grades.build(),
            labCertifiedRequires: _labCertifiedRequires?.build(),
            lotGates: _lotGates?.build(),
            parameters: parameters.build(),
            publicNote: publicNote,
            schemaVersion: BuiltValueNullFieldError.checkNotNull(
                schemaVersion, r'StandardsProfileRulesInput', 'schemaVersion'),
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
            r'StandardsProfileRulesInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
