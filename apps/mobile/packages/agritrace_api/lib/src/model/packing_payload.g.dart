// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PackingPayload extends PackingPayload {
  @override
  final int? bags;
  @override
  final QuantityInput? quantity;

  factory _$PackingPayload([void Function(PackingPayloadBuilder)? updates]) =>
      (PackingPayloadBuilder()..update(updates))._build();

  _$PackingPayload._({this.bags, this.quantity}) : super._();
  @override
  PackingPayload rebuild(void Function(PackingPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PackingPayloadBuilder toBuilder() => PackingPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PackingPayload &&
        bags == other.bags &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bags.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PackingPayload')
          ..add('bags', bags)
          ..add('quantity', quantity))
        .toString();
  }
}

class PackingPayloadBuilder
    implements Builder<PackingPayload, PackingPayloadBuilder> {
  _$PackingPayload? _$v;

  int? _bags;
  int? get bags => _$this._bags;
  set bags(int? bags) => _$this._bags = bags;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  PackingPayloadBuilder() {
    PackingPayload._defaults(this);
  }

  PackingPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bags = $v.bags;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PackingPayload other) {
    _$v = other as _$PackingPayload;
  }

  @override
  void update(void Function(PackingPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PackingPayload build() => _build();

  _$PackingPayload _build() {
    _$PackingPayload _$result;
    try {
      _$result = _$v ??
          _$PackingPayload._(
            bags: bags,
            quantity: _quantity?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'quantity';
        _quantity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PackingPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
