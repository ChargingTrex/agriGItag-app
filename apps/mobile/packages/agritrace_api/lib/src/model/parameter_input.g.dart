// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ParameterInputRoleEnum _$parameterInputRoleEnum_grading =
    const ParameterInputRoleEnum._('grading');
const ParameterInputRoleEnum _$parameterInputRoleEnum_labelDeclaration =
    const ParameterInputRoleEnum._('labelDeclaration');
const ParameterInputRoleEnum _$parameterInputRoleEnum_contractSpec =
    const ParameterInputRoleEnum._('contractSpec');

ParameterInputRoleEnum _$parameterInputRoleEnumValueOf(String name) {
  switch (name) {
    case 'grading':
      return _$parameterInputRoleEnum_grading;
    case 'labelDeclaration':
      return _$parameterInputRoleEnum_labelDeclaration;
    case 'contractSpec':
      return _$parameterInputRoleEnum_contractSpec;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ParameterInputRoleEnum> _$parameterInputRoleEnumValues =
    BuiltSet<ParameterInputRoleEnum>(const <ParameterInputRoleEnum>[
  _$parameterInputRoleEnum_grading,
  _$parameterInputRoleEnum_labelDeclaration,
  _$parameterInputRoleEnum_contractSpec,
]);

const ParameterInputStatusEnum _$parameterInputStatusEnum_active =
    const ParameterInputStatusEnum._('active');
const ParameterInputStatusEnum _$parameterInputStatusEnum_loadFromStandard =
    const ParameterInputStatusEnum._('loadFromStandard');

ParameterInputStatusEnum _$parameterInputStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$parameterInputStatusEnum_active;
    case 'loadFromStandard':
      return _$parameterInputStatusEnum_loadFromStandard;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ParameterInputStatusEnum> _$parameterInputStatusEnumValues =
    BuiltSet<ParameterInputStatusEnum>(const <ParameterInputStatusEnum>[
  _$parameterInputStatusEnum_active,
  _$parameterInputStatusEnum_loadFromStandard,
]);

Serializer<ParameterInputRoleEnum> _$parameterInputRoleEnumSerializer =
    _$ParameterInputRoleEnumSerializer();
Serializer<ParameterInputStatusEnum> _$parameterInputStatusEnumSerializer =
    _$ParameterInputStatusEnumSerializer();

class _$ParameterInputRoleEnumSerializer
    implements PrimitiveSerializer<ParameterInputRoleEnum> {
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
  final Iterable<Type> types = const <Type>[ParameterInputRoleEnum];
  @override
  final String wireName = 'ParameterInputRoleEnum';

  @override
  Object serialize(Serializers serializers, ParameterInputRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ParameterInputRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ParameterInputRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ParameterInputStatusEnumSerializer
    implements PrimitiveSerializer<ParameterInputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'loadFromStandard': 'load_from_standard',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'load_from_standard': 'loadFromStandard',
  };

  @override
  final Iterable<Type> types = const <Type>[ParameterInputStatusEnum];
  @override
  final String wireName = 'ParameterInputStatusEnum';

  @override
  Object serialize(Serializers serializers, ParameterInputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ParameterInputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ParameterInputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ParameterInput extends ParameterInput {
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
  final BuiltMap<String, RangeInput>? limits;
  @override
  final BuiltMap<String, String>? maxGradeForSource;
  @override
  final String? methodRef;
  @override
  final String? nameEn;
  @override
  final String? nameLocal;
  @override
  final RangeInput? plausible;
  @override
  final bool? required_;
  @override
  final ParameterInputRoleEnum? role;
  @override
  final BuiltList<ReadingSource>? sourcesAllowed;
  @override
  final ParameterInputStatusEnum? status;
  @override
  final String unit;

  factory _$ParameterInput([void Function(ParameterInputBuilder)? updates]) =>
      (ParameterInputBuilder()..update(updates))._build();

  _$ParameterInput._(
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
  ParameterInput rebuild(void Function(ParameterInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ParameterInputBuilder toBuilder() => ParameterInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ParameterInput &&
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
    return (newBuiltValueToStringHelper(r'ParameterInput')
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

class ParameterInputBuilder
    implements Builder<ParameterInput, ParameterInputBuilder> {
  _$ParameterInput? _$v;

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

  MapBuilder<String, RangeInput>? _limits;
  MapBuilder<String, RangeInput> get limits =>
      _$this._limits ??= MapBuilder<String, RangeInput>();
  set limits(MapBuilder<String, RangeInput>? limits) => _$this._limits = limits;

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

  RangeInputBuilder? _plausible;
  RangeInputBuilder get plausible => _$this._plausible ??= RangeInputBuilder();
  set plausible(RangeInputBuilder? plausible) => _$this._plausible = plausible;

  bool? _required_;
  bool? get required_ => _$this._required_;
  set required_(bool? required_) => _$this._required_ = required_;

  ParameterInputRoleEnum? _role;
  ParameterInputRoleEnum? get role => _$this._role;
  set role(ParameterInputRoleEnum? role) => _$this._role = role;

  ListBuilder<ReadingSource>? _sourcesAllowed;
  ListBuilder<ReadingSource> get sourcesAllowed =>
      _$this._sourcesAllowed ??= ListBuilder<ReadingSource>();
  set sourcesAllowed(ListBuilder<ReadingSource>? sourcesAllowed) =>
      _$this._sourcesAllowed = sourcesAllowed;

  ParameterInputStatusEnum? _status;
  ParameterInputStatusEnum? get status => _$this._status;
  set status(ParameterInputStatusEnum? status) => _$this._status = status;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  ParameterInputBuilder() {
    ParameterInput._defaults(this);
  }

  ParameterInputBuilder get _$this {
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
  void replace(ParameterInput other) {
    _$v = other as _$ParameterInput;
  }

  @override
  void update(void Function(ParameterInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ParameterInput build() => _build();

  _$ParameterInput _build() {
    _$ParameterInput _$result;
    try {
      _$result = _$v ??
          _$ParameterInput._(
            captureStages: _captureStages?.build(),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ParameterInput', 'code'),
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
                unit, r'ParameterInput', 'unit'),
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
            r'ParameterInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
