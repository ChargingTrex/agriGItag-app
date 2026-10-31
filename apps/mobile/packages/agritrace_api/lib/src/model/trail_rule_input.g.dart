// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trail_rule_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrailRuleInputRuleEnum _$trailRuleInputRuleEnum_nonIncreasing =
    const TrailRuleInputRuleEnum._('nonIncreasing');

TrailRuleInputRuleEnum _$trailRuleInputRuleEnumValueOf(String name) {
  switch (name) {
    case 'nonIncreasing':
      return _$trailRuleInputRuleEnum_nonIncreasing;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrailRuleInputRuleEnum> _$trailRuleInputRuleEnumValues =
    BuiltSet<TrailRuleInputRuleEnum>(const <TrailRuleInputRuleEnum>[
  _$trailRuleInputRuleEnum_nonIncreasing,
]);

Serializer<TrailRuleInputRuleEnum> _$trailRuleInputRuleEnumSerializer =
    _$TrailRuleInputRuleEnumSerializer();

class _$TrailRuleInputRuleEnumSerializer
    implements PrimitiveSerializer<TrailRuleInputRuleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'nonIncreasing': 'non_increasing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'non_increasing': 'nonIncreasing',
  };

  @override
  final Iterable<Type> types = const <Type>[TrailRuleInputRuleEnum];
  @override
  final String wireName = 'TrailRuleInputRuleEnum';

  @override
  Object serialize(Serializers serializers, TrailRuleInputRuleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrailRuleInputRuleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrailRuleInputRuleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrailRuleInput extends TrailRuleInput {
  @override
  final bool? overrideWithReason;
  @override
  final String parameter;
  @override
  final TrailRuleInputRuleEnum rule;
  @override
  final BuiltList<ReadingStage> stages;
  @override
  final Tolerance? tolerance;

  factory _$TrailRuleInput([void Function(TrailRuleInputBuilder)? updates]) =>
      (TrailRuleInputBuilder()..update(updates))._build();

  _$TrailRuleInput._(
      {this.overrideWithReason,
      required this.parameter,
      required this.rule,
      required this.stages,
      this.tolerance})
      : super._();
  @override
  TrailRuleInput rebuild(void Function(TrailRuleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrailRuleInputBuilder toBuilder() => TrailRuleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrailRuleInput &&
        overrideWithReason == other.overrideWithReason &&
        parameter == other.parameter &&
        rule == other.rule &&
        stages == other.stages &&
        tolerance == other.tolerance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, overrideWithReason.hashCode);
    _$hash = $jc(_$hash, parameter.hashCode);
    _$hash = $jc(_$hash, rule.hashCode);
    _$hash = $jc(_$hash, stages.hashCode);
    _$hash = $jc(_$hash, tolerance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrailRuleInput')
          ..add('overrideWithReason', overrideWithReason)
          ..add('parameter', parameter)
          ..add('rule', rule)
          ..add('stages', stages)
          ..add('tolerance', tolerance))
        .toString();
  }
}

class TrailRuleInputBuilder
    implements Builder<TrailRuleInput, TrailRuleInputBuilder> {
  _$TrailRuleInput? _$v;

  bool? _overrideWithReason;
  bool? get overrideWithReason => _$this._overrideWithReason;
  set overrideWithReason(bool? overrideWithReason) =>
      _$this._overrideWithReason = overrideWithReason;

  String? _parameter;
  String? get parameter => _$this._parameter;
  set parameter(String? parameter) => _$this._parameter = parameter;

  TrailRuleInputRuleEnum? _rule;
  TrailRuleInputRuleEnum? get rule => _$this._rule;
  set rule(TrailRuleInputRuleEnum? rule) => _$this._rule = rule;

  ListBuilder<ReadingStage>? _stages;
  ListBuilder<ReadingStage> get stages =>
      _$this._stages ??= ListBuilder<ReadingStage>();
  set stages(ListBuilder<ReadingStage>? stages) => _$this._stages = stages;

  ToleranceBuilder? _tolerance;
  ToleranceBuilder get tolerance => _$this._tolerance ??= ToleranceBuilder();
  set tolerance(ToleranceBuilder? tolerance) => _$this._tolerance = tolerance;

  TrailRuleInputBuilder() {
    TrailRuleInput._defaults(this);
  }

  TrailRuleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _overrideWithReason = $v.overrideWithReason;
      _parameter = $v.parameter;
      _rule = $v.rule;
      _stages = $v.stages.toBuilder();
      _tolerance = $v.tolerance?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrailRuleInput other) {
    _$v = other as _$TrailRuleInput;
  }

  @override
  void update(void Function(TrailRuleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrailRuleInput build() => _build();

  _$TrailRuleInput _build() {
    _$TrailRuleInput _$result;
    try {
      _$result = _$v ??
          _$TrailRuleInput._(
            overrideWithReason: overrideWithReason,
            parameter: BuiltValueNullFieldError.checkNotNull(
                parameter, r'TrailRuleInput', 'parameter'),
            rule: BuiltValueNullFieldError.checkNotNull(
                rule, r'TrailRuleInput', 'rule'),
            stages: stages.build(),
            tolerance: _tolerance?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stages';
        stages.build();
        _$failedField = 'tolerance';
        _tolerance?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrailRuleInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
