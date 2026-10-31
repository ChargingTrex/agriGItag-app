// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sowing_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SowingPayloadMethodEnum _$sowingPayloadMethodEnum_directSeeding =
    const SowingPayloadMethodEnum._('directSeeding');
const SowingPayloadMethodEnum _$sowingPayloadMethodEnum_transplanting =
    const SowingPayloadMethodEnum._('transplanting');

SowingPayloadMethodEnum _$sowingPayloadMethodEnumValueOf(String name) {
  switch (name) {
    case 'directSeeding':
      return _$sowingPayloadMethodEnum_directSeeding;
    case 'transplanting':
      return _$sowingPayloadMethodEnum_transplanting;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SowingPayloadMethodEnum> _$sowingPayloadMethodEnumValues =
    BuiltSet<SowingPayloadMethodEnum>(const <SowingPayloadMethodEnum>[
  _$sowingPayloadMethodEnum_directSeeding,
  _$sowingPayloadMethodEnum_transplanting,
]);

Serializer<SowingPayloadMethodEnum> _$sowingPayloadMethodEnumSerializer =
    _$SowingPayloadMethodEnumSerializer();

class _$SowingPayloadMethodEnumSerializer
    implements PrimitiveSerializer<SowingPayloadMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'directSeeding': 'direct_seeding',
    'transplanting': 'transplanting',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'direct_seeding': 'directSeeding',
    'transplanting': 'transplanting',
  };

  @override
  final Iterable<Type> types = const <Type>[SowingPayloadMethodEnum];
  @override
  final String wireName = 'SowingPayloadMethodEnum';

  @override
  Object serialize(Serializers serializers, SowingPayloadMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SowingPayloadMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SowingPayloadMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SowingPayload extends SowingPayload {
  @override
  final SowingPayloadMethodEnum? method;
  @override
  final String? seedVariety;
  @override
  final QuantityInput? sownArea;

  factory _$SowingPayload([void Function(SowingPayloadBuilder)? updates]) =>
      (SowingPayloadBuilder()..update(updates))._build();

  _$SowingPayload._({this.method, this.seedVariety, this.sownArea}) : super._();
  @override
  SowingPayload rebuild(void Function(SowingPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SowingPayloadBuilder toBuilder() => SowingPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SowingPayload &&
        method == other.method &&
        seedVariety == other.seedVariety &&
        sownArea == other.sownArea;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, seedVariety.hashCode);
    _$hash = $jc(_$hash, sownArea.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SowingPayload')
          ..add('method', method)
          ..add('seedVariety', seedVariety)
          ..add('sownArea', sownArea))
        .toString();
  }
}

class SowingPayloadBuilder
    implements Builder<SowingPayload, SowingPayloadBuilder> {
  _$SowingPayload? _$v;

  SowingPayloadMethodEnum? _method;
  SowingPayloadMethodEnum? get method => _$this._method;
  set method(SowingPayloadMethodEnum? method) => _$this._method = method;

  String? _seedVariety;
  String? get seedVariety => _$this._seedVariety;
  set seedVariety(String? seedVariety) => _$this._seedVariety = seedVariety;

  QuantityInputBuilder? _sownArea;
  QuantityInputBuilder get sownArea =>
      _$this._sownArea ??= QuantityInputBuilder();
  set sownArea(QuantityInputBuilder? sownArea) => _$this._sownArea = sownArea;

  SowingPayloadBuilder() {
    SowingPayload._defaults(this);
  }

  SowingPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _method = $v.method;
      _seedVariety = $v.seedVariety;
      _sownArea = $v.sownArea?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SowingPayload other) {
    _$v = other as _$SowingPayload;
  }

  @override
  void update(void Function(SowingPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SowingPayload build() => _build();

  _$SowingPayload _build() {
    _$SowingPayload _$result;
    try {
      _$result = _$v ??
          _$SowingPayload._(
            method: method,
            seedVariety: seedVariety,
            sownArea: _sownArea?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sownArea';
        _sownArea?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SowingPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
