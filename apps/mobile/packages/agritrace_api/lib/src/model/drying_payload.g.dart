// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drying_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DryingPayloadPhaseEnum _$dryingPayloadPhaseEnum_start =
    const DryingPayloadPhaseEnum._('start');
const DryingPayloadPhaseEnum _$dryingPayloadPhaseEnum_end =
    const DryingPayloadPhaseEnum._('end');

DryingPayloadPhaseEnum _$dryingPayloadPhaseEnumValueOf(String name) {
  switch (name) {
    case 'start':
      return _$dryingPayloadPhaseEnum_start;
    case 'end':
      return _$dryingPayloadPhaseEnum_end;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DryingPayloadPhaseEnum> _$dryingPayloadPhaseEnumValues =
    BuiltSet<DryingPayloadPhaseEnum>(const <DryingPayloadPhaseEnum>[
  _$dryingPayloadPhaseEnum_start,
  _$dryingPayloadPhaseEnum_end,
]);

Serializer<DryingPayloadPhaseEnum> _$dryingPayloadPhaseEnumSerializer =
    _$DryingPayloadPhaseEnumSerializer();

class _$DryingPayloadPhaseEnumSerializer
    implements PrimitiveSerializer<DryingPayloadPhaseEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'start': 'start',
    'end': 'end',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'start': 'start',
    'end': 'end',
  };

  @override
  final Iterable<Type> types = const <Type>[DryingPayloadPhaseEnum];
  @override
  final String wireName = 'DryingPayloadPhaseEnum';

  @override
  Object serialize(Serializers serializers, DryingPayloadPhaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DryingPayloadPhaseEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DryingPayloadPhaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DryingPayload extends DryingPayload {
  @override
  final String? moistureReadingId;
  @override
  final DryingPayloadPhaseEnum? phase;
  @override
  final QuantityInput? quantity;

  factory _$DryingPayload([void Function(DryingPayloadBuilder)? updates]) =>
      (DryingPayloadBuilder()..update(updates))._build();

  _$DryingPayload._({this.moistureReadingId, this.phase, this.quantity})
      : super._();
  @override
  DryingPayload rebuild(void Function(DryingPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DryingPayloadBuilder toBuilder() => DryingPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DryingPayload &&
        moistureReadingId == other.moistureReadingId &&
        phase == other.phase &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, moistureReadingId.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DryingPayload')
          ..add('moistureReadingId', moistureReadingId)
          ..add('phase', phase)
          ..add('quantity', quantity))
        .toString();
  }
}

class DryingPayloadBuilder
    implements Builder<DryingPayload, DryingPayloadBuilder> {
  _$DryingPayload? _$v;

  String? _moistureReadingId;
  String? get moistureReadingId => _$this._moistureReadingId;
  set moistureReadingId(String? moistureReadingId) =>
      _$this._moistureReadingId = moistureReadingId;

  DryingPayloadPhaseEnum? _phase;
  DryingPayloadPhaseEnum? get phase => _$this._phase;
  set phase(DryingPayloadPhaseEnum? phase) => _$this._phase = phase;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  DryingPayloadBuilder() {
    DryingPayload._defaults(this);
  }

  DryingPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _moistureReadingId = $v.moistureReadingId;
      _phase = $v.phase;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DryingPayload other) {
    _$v = other as _$DryingPayload;
  }

  @override
  void update(void Function(DryingPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DryingPayload build() => _build();

  _$DryingPayload _build() {
    _$DryingPayload _$result;
    try {
      _$result = _$v ??
          _$DryingPayload._(
            moistureReadingId: moistureReadingId,
            phase: phase,
            quantity: _quantity?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'quantity';
        _quantity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DryingPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
