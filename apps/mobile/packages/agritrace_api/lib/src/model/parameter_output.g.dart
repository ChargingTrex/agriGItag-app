// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ParameterOutputRoleEnum _$parameterOutputRoleEnum_grading =
    const ParameterOutputRoleEnum._('grading');
const ParameterOutputRoleEnum _$parameterOutputRoleEnum_labelDeclaration =
    const ParameterOutputRoleEnum._('labelDeclaration');
const ParameterOutputRoleEnum _$parameterOutputRoleEnum_contractSpec =
    const ParameterOutputRoleEnum._('contractSpec');

ParameterOutputRoleEnum _$parameterOutputRoleEnumValueOf(String name) {
  switch (name) {
    case 'grading':
      return _$parameterOutputRoleEnum_grading;
    case 'labelDeclaration':
      return _$parameterOutputRoleEnum_labelDeclaration;
    case 'contractSpec':
      return _$parameterOutputRoleEnum_contractSpec;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ParameterOutputRoleEnum> _$parameterOutputRoleEnumValues =
    BuiltSet<ParameterOutputRoleEnum>(const <ParameterOutputRoleEnum>[
  _$parameterOutputRoleEnum_grading,
  _$parameterOutputRoleEnum_labelDeclaration,
  _$parameterOutputRoleEnum_contractSpec,
]);

const ParameterOutputStatusEnum _$parameterOutputStatusEnum_active =
    const ParameterOutputStatusEnum._('active');
const ParameterOutputStatusEnum _$parameterOutputStatusEnum_loadFromStandard =
    const ParameterOutputStatusEnum._('loadFromStandard');

ParameterOutputStatusEnum _$parameterOutputStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$parameterOutputStatusEnum_active;
    case 'loadFromStandard':
      return _$parameterOutputStatusEnum_loadFromStandard;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ParameterOutputStatusEnum> _$parameterOutputStatusEnumValues =
    BuiltSet<ParameterOutputStatusEnum>(const <ParameterOutputStatusEnum>[
  _$parameterOutputStatusEnum_active,
  _$parameterOutputStatusEnum_loadFromStandard,
]);

Serializer<ParameterOutputRoleEnum> _$parameterOutputRoleEnumSerializer =
    _$ParameterOutputRoleEnumSerializer();
Serializer<ParameterOutputStatusEnum> _$parameterOutputStatusEnumSerializer =
    _$ParameterOutputStatusEnumSerializer();

class _$ParameterOutputRoleEnumSerializer
    implements PrimitiveSerializer<ParameterOutputRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grading': 'grading',
    'labelDeclaration': 'label_declaration',
    'contractSpec': 'contract_spec',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grading': 'grading',
    'label_declaration': 'labelDeclaration',
    'contract_spec': 'contractSpec',
  };

  @override
  final Iterable<Type> types = const <Type>[ParameterOutputRoleEnum];
  @override
  final String wireName = 'ParameterOutputRoleEnum';

  @override
  Object serialize(Serializers serializers, ParameterOutputRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ParameterOutputRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ParameterOutputRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ParameterOutputStatusEnumSerializer
    implements PrimitiveSerializer<ParameterOutputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'loadFromStandard': 'load_from_standard',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'load_from_standard': 'loadFromStandard',
  };

  @override
  final Iterable<Type> types = const <Type>[ParameterOutputStatusEnum];
  @override
  final String wireName = 'ParameterOutputStatusEnum';

  @override
  Object serialize(Serializers serializers, ParameterOutputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ParameterOutputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ParameterOutputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ParameterOutput extends ParameterOutput {
  @override
  final BuiltList<ReadingStage>? captureStages;
  @override
  final String code;
  @override
  final BuiltList<String>? declareForGrades;
  @override
  final BuiltList<String>? exceptionFlags;
  @override
  final ReadingStage? gradingStage;
  @override
  final BuiltMap<String, RangeOutput>? limits;
  @override
  final BuiltMap<String, String>? maxGradeForSource;
  @override
  final String? methodRef;
  @override
  final String? nameEn;
  @override
  final String? nameLocal;
  @override
  final RangeOutput? plausible;
  @override
  final bool? required_;
  @override
  final ParameterOutputRoleEnum? role;
  @override
  final BuiltList<ReadingSource>? sourcesAllowed;
  @override
  final ParameterOutputStatusEnum? status;
  @override
  final String unit;

  factory _$ParameterOutput([void Function(ParameterOutputBuilder)? updates]) =>
      (ParameterOutputBuilder()..update(updates))._build();

  _$ParameterOutput._(
      {this.captureStages,
      required this.code,
      this.declareForGrades,
      this.exceptionFlags,
      this.gradingStage,
      this.limits,
      this.maxGradeForSource,
      this.methodRef,
      this.nameEn,
      this.nameLocal,
      this.plausible,
      this.required_,
      this.role,
      this.sourcesAllowed,
      this.status,
      required this.unit})
      : super._();
  @override
  ParameterOutput rebuild(void Function(ParameterOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ParameterOutputBuilder toBuilder() => ParameterOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ParameterOutput &&
        captureStages == other.captureStages &&
        code == other.code &&
        declareForGrades == other.declareForGrades &&
        exceptionFlags == other.exceptionFlags &&
        gradingStage == other.gradingStage &&
        limits == other.limits &&
        maxGradeForSource == other.maxGradeForSource &&
        methodRef == other.methodRef &&
        nameEn == other.nameEn &&
        nameLocal == other.nameLocal &&
        plausible == other.plausible &&
        required_ == other.required_ &&
        role == other.role &&
        sourcesAllowed == other.sourcesAllowed &&
        status == other.status &&
        unit == other.unit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, captureStages.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, declareForGrades.hashCode);
    _$hash = $jc(_$hash, exceptionFlags.hashCode);
    _$hash = $jc(_$hash, gradingStage.hashCode);
    _$hash = $jc(_$hash, limits.hashCode);
    _$hash = $jc(_$hash, maxGradeForSource.hashCode);
    _$hash = $jc(_$hash, methodRef.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, plausible.hashCode);
    _$hash = $jc(_$hash, required_.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, sourcesAllowed.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ParameterOutput')
          ..add('captureStages', captureStages)
          ..add('code', code)
          ..add('declareForGrades', declareForGrades)
          ..add('exceptionFlags', exceptionFlags)
          ..add('gradingStage', gradingStage)
          ..add('limits', limits)
          ..add('maxGradeForSource', maxGradeForSource)
          ..add('methodRef', methodRef)
          ..add('nameEn', nameEn)
          ..add('nameLocal', nameLocal)
          ..add('plausible', plausible)
          ..add('required_', required_)
          ..add('role', role)
          ..add('sourcesAllowed', sourcesAllowed)
          ..add('status', status)
          ..add('unit', unit))
        .toString();
  }
}

class ParameterOutputBuilder
    implements Builder<ParameterOutput, ParameterOutputBuilder> {
  _$ParameterOutput? _$v;

  ListBuilder<ReadingStage>? _captureStages;
  ListBuilder<ReadingStage> get captureStages =>
      _$this._captureStages ??= ListBuilder<ReadingStage>();
  set captureStages(ListBuilder<ReadingStage>? captureStages) =>
      _$this._captureStages = captureStages;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ListBuilder<String>? _declareForGrades;
  ListBuilder<String> get declareForGrades =>
      _$this._declareForGrades ??= ListBuilder<String>();
  set declareForGrades(ListBuilder<String>? declareForGrades) =>
      _$this._declareForGrades = declareForGrades;

  ListBuilder<String>? _exceptionFlags;
  ListBuilder<String> get exceptionFlags =>
      _$this._exceptionFlags ??= ListBuilder<String>();
  set exceptionFlags(ListBuilder<String>? exceptionFlags) =>
      _$this._exceptionFlags = exceptionFlags;

  ReadingStage? _gradingStage;
  ReadingStage? get gradingStage => _$this._gradingStage;
  set gradingStage(ReadingStage? gradingStage) =>
      _$this._gradingStage = gradingStage;

  MapBuilder<String, RangeOutput>? _limits;
  MapBuilder<String, RangeOutput> get limits =>
      _$this._limits ??= MapBuilder<String, RangeOutput>();
  set limits(MapBuilder<String, RangeOutput>? limits) =>
      _$this._limits = limits;

  MapBuilder<String, String>? _maxGradeForSource;
  MapBuilder<String, String> get maxGradeForSource =>
      _$this._maxGradeForSource ??= MapBuilder<String, String>();
  set maxGradeForSource(MapBuilder<String, String>? maxGradeForSource) =>
      _$this._maxGradeForSource = maxGradeForSource;

  String? _methodRef;
  String? get methodRef => _$this._methodRef;
  set methodRef(String? methodRef) => _$this._methodRef = methodRef;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  RangeOutputBuilder? _plausible;
  RangeOutputBuilder get plausible =>
      _$this._plausible ??= RangeOutputBuilder();
  set plausible(RangeOutputBuilder? plausible) => _$this._plausible = plausible;

  bool? _required_;
  bool? get required_ => _$this._required_;
  set required_(bool? required_) => _$this._required_ = required_;

  ParameterOutputRoleEnum? _role;
  ParameterOutputRoleEnum? get role => _$this._role;
  set role(ParameterOutputRoleEnum? role) => _$this._role = role;

  ListBuilder<ReadingSource>? _sourcesAllowed;
  ListBuilder<ReadingSource> get sourcesAllowed =>
      _$this._sourcesAllowed ??= ListBuilder<ReadingSource>();
  set sourcesAllowed(ListBuilder<ReadingSource>? sourcesAllowed) =>
      _$this._sourcesAllowed = sourcesAllowed;

  ParameterOutputStatusEnum? _status;
  ParameterOutputStatusEnum? get status => _$this._status;
  set status(ParameterOutputStatusEnum? status) => _$this._status = status;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  ParameterOutputBuilder() {
    ParameterOutput._defaults(this);
  }

  ParameterOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _captureStages = $v.captureStages?.toBuilder();
      _code = $v.code;
      _declareForGrades = $v.declareForGrades?.toBuilder();
      _exceptionFlags = $v.exceptionFlags?.toBuilder();
      _gradingStage = $v.gradingStage;
      _limits = $v.limits?.toBuilder();
      _maxGradeForSource = $v.maxGradeForSource?.toBuilder();
      _methodRef = $v.methodRef;
      _nameEn = $v.nameEn;
      _nameLocal = $v.nameLocal;
      _plausible = $v.plausible?.toBuilder();
      _required_ = $v.required_;
      _role = $v.role;
      _sourcesAllowed = $v.sourcesAllowed?.toBuilder();
      _status = $v.status;
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ParameterOutput other) {
    _$v = other as _$ParameterOutput;
  }

  @override
  void update(void Function(ParameterOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ParameterOutput build() => _build();

  _$ParameterOutput _build() {
    _$ParameterOutput _$result;
    try {
      _$result = _$v ??
          _$ParameterOutput._(
            captureStages: _captureStages?.build(),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ParameterOutput', 'code'),
            declareForGrades: _declareForGrades?.build(),
            exceptionFlags: _exceptionFlags?.build(),
            gradingStage: gradingStage,
            limits: _limits?.build(),
            maxGradeForSource: _maxGradeForSource?.build(),
            methodRef: methodRef,
            nameEn: nameEn,
            nameLocal: nameLocal,
            plausible: _plausible?.build(),
            required_: required_,
            role: role,
            sourcesAllowed: _sourcesAllowed?.build(),
            status: status,
            unit: BuiltValueNullFieldError.checkNotNull(
                unit, r'ParameterOutput', 'unit'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'captureStages';
        _captureStages?.build();

        _$failedField = 'declareForGrades';
        _declareForGrades?.build();
        _$failedField = 'exceptionFlags';
        _exceptionFlags?.build();

        _$failedField = 'limits';
        _limits?.build();
        _$failedField = 'maxGradeForSource';
        _maxGradeForSource?.build();

        _$failedField = 'plausible';
        _plausible?.build();

        _$failedField = 'sourcesAllowed';
        _sourcesAllowed?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ParameterOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
