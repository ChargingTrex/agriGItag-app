// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IntakePayload extends IntakePayload {
  @override
  final String? moistureReadingId;
  @override
  final PricePerKg? pricePerKg;
  @override
  final String? processorId;
  @override
  final QuantityInput? received;

  factory _$IntakePayload([void Function(IntakePayloadBuilder)? updates]) =>
      (IntakePayloadBuilder()..update(updates))._build();

  _$IntakePayload._(
      {this.moistureReadingId,
      this.pricePerKg,
      this.processorId,
      this.received})
      : super._();
  @override
  IntakePayload rebuild(void Function(IntakePayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IntakePayloadBuilder toBuilder() => IntakePayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IntakePayload &&
        moistureReadingId == other.moistureReadingId &&
        pricePerKg == other.pricePerKg &&
        processorId == other.processorId &&
        received == other.received;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, moistureReadingId.hashCode);
    _$hash = $jc(_$hash, pricePerKg.hashCode);
    _$hash = $jc(_$hash, processorId.hashCode);
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IntakePayload')
          ..add('moistureReadingId', moistureReadingId)
          ..add('pricePerKg', pricePerKg)
          ..add('processorId', processorId)
          ..add('received', received))
        .toString();
  }
}

class IntakePayloadBuilder
    implements Builder<IntakePayload, IntakePayloadBuilder> {
  _$IntakePayload? _$v;

  String? _moistureReadingId;
  String? get moistureReadingId => _$this._moistureReadingId;
  set moistureReadingId(String? moistureReadingId) =>
      _$this._moistureReadingId = moistureReadingId;

  PricePerKgBuilder? _pricePerKg;
  PricePerKgBuilder get pricePerKg =>
      _$this._pricePerKg ??= PricePerKgBuilder();
  set pricePerKg(PricePerKgBuilder? pricePerKg) =>
      _$this._pricePerKg = pricePerKg;

  String? _processorId;
  String? get processorId => _$this._processorId;
  set processorId(String? processorId) => _$this._processorId = processorId;

  QuantityInputBuilder? _received;
  QuantityInputBuilder get received =>
      _$this._received ??= QuantityInputBuilder();
  set received(QuantityInputBuilder? received) => _$this._received = received;

  IntakePayloadBuilder() {
    IntakePayload._defaults(this);
  }

  IntakePayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _moistureReadingId = $v.moistureReadingId;
      _pricePerKg = $v.pricePerKg?.toBuilder();
      _processorId = $v.processorId;
      _received = $v.received?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IntakePayload other) {
    _$v = other as _$IntakePayload;
  }

  @override
  void update(void Function(IntakePayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IntakePayload build() => _build();

  _$IntakePayload _build() {
    _$IntakePayload _$result;
    try {
      _$result = _$v ??
          _$IntakePayload._(
            moistureReadingId: moistureReadingId,
            pricePerKg: _pricePerKg?.build(),
            processorId: processorId,
            received: _received?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pricePerKg';
        _pricePerKg?.build();

        _$failedField = 'received';
        _received?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IntakePayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
