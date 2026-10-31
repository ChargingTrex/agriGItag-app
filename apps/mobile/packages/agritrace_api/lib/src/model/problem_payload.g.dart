// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProblemPayloadProblemTypeEnum _$problemPayloadProblemTypeEnum_pest =
    const ProblemPayloadProblemTypeEnum._('pest');
const ProblemPayloadProblemTypeEnum _$problemPayloadProblemTypeEnum_disease =
    const ProblemPayloadProblemTypeEnum._('disease');
const ProblemPayloadProblemTypeEnum _$problemPayloadProblemTypeEnum_weather =
    const ProblemPayloadProblemTypeEnum._('weather');
const ProblemPayloadProblemTypeEnum _$problemPayloadProblemTypeEnum_other =
    const ProblemPayloadProblemTypeEnum._('other');

ProblemPayloadProblemTypeEnum _$problemPayloadProblemTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'pest':
      return _$problemPayloadProblemTypeEnum_pest;
    case 'disease':
      return _$problemPayloadProblemTypeEnum_disease;
    case 'weather':
      return _$problemPayloadProblemTypeEnum_weather;
    case 'other':
      return _$problemPayloadProblemTypeEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProblemPayloadProblemTypeEnum>
    _$problemPayloadProblemTypeEnumValues = BuiltSet<
        ProblemPayloadProblemTypeEnum>(const <ProblemPayloadProblemTypeEnum>[
  _$problemPayloadProblemTypeEnum_pest,
  _$problemPayloadProblemTypeEnum_disease,
  _$problemPayloadProblemTypeEnum_weather,
  _$problemPayloadProblemTypeEnum_other,
]);

Serializer<ProblemPayloadProblemTypeEnum>
    _$problemPayloadProblemTypeEnumSerializer =
    _$ProblemPayloadProblemTypeEnumSerializer();

class _$ProblemPayloadProblemTypeEnumSerializer
    implements PrimitiveSerializer<ProblemPayloadProblemTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pest': 'pest',
    'disease': 'disease',
    'weather': 'weather',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pest': 'pest',
    'disease': 'disease',
    'weather': 'weather',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[ProblemPayloadProblemTypeEnum];
  @override
  final String wireName = 'ProblemPayloadProblemTypeEnum';

  @override
  Object serialize(
          Serializers serializers, ProblemPayloadProblemTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProblemPayloadProblemTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProblemPayloadProblemTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProblemPayload extends ProblemPayload {
  @override
  final QuantityInput? affectedArea;
  @override
  final String? description;
  @override
  final ProblemPayloadProblemTypeEnum? problemType;

  factory _$ProblemPayload([void Function(ProblemPayloadBuilder)? updates]) =>
      (ProblemPayloadBuilder()..update(updates))._build();

  _$ProblemPayload._({this.affectedArea, this.description, this.problemType})
      : super._();
  @override
  ProblemPayload rebuild(void Function(ProblemPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProblemPayloadBuilder toBuilder() => ProblemPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProblemPayload &&
        affectedArea == other.affectedArea &&
        description == other.description &&
        problemType == other.problemType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, affectedArea.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, problemType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProblemPayload')
          ..add('affectedArea', affectedArea)
          ..add('description', description)
          ..add('problemType', problemType))
        .toString();
  }
}

class ProblemPayloadBuilder
    implements Builder<ProblemPayload, ProblemPayloadBuilder> {
  _$ProblemPayload? _$v;

  QuantityInputBuilder? _affectedArea;
  QuantityInputBuilder get affectedArea =>
      _$this._affectedArea ??= QuantityInputBuilder();
  set affectedArea(QuantityInputBuilder? affectedArea) =>
      _$this._affectedArea = affectedArea;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ProblemPayloadProblemTypeEnum? _problemType;
  ProblemPayloadProblemTypeEnum? get problemType => _$this._problemType;
  set problemType(ProblemPayloadProblemTypeEnum? problemType) =>
      _$this._problemType = problemType;

  ProblemPayloadBuilder() {
    ProblemPayload._defaults(this);
  }

  ProblemPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _affectedArea = $v.affectedArea?.toBuilder();
      _description = $v.description;
      _problemType = $v.problemType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProblemPayload other) {
    _$v = other as _$ProblemPayload;
  }

  @override
  void update(void Function(ProblemPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProblemPayload build() => _build();

  _$ProblemPayload _build() {
    _$ProblemPayload _$result;
    try {
      _$result = _$v ??
          _$ProblemPayload._(
            affectedArea: _affectedArea?.build(),
            description: description,
            problemType: problemType,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'affectedArea';
        _affectedArea?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProblemPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
