// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'harvest_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HarvestPayload extends HarvestPayload {
  @override
  final int? bags;
  @override
  final QuantityInput? quantity;

  factory _$HarvestPayload([void Function(HarvestPayloadBuilder)? updates]) =>
      (HarvestPayloadBuilder()..update(updates))._build();

  _$HarvestPayload._({this.bags, this.quantity}) : super._();
  @override
  HarvestPayload rebuild(void Function(HarvestPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HarvestPayloadBuilder toBuilder() => HarvestPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HarvestPayload &&
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
    return (newBuiltValueToStringHelper(r'HarvestPayload')
          ..add('bags', bags)
          ..add('quantity', quantity))
        .toString();
  }
}

class HarvestPayloadBuilder
    implements Builder<HarvestPayload, HarvestPayloadBuilder> {
  _$HarvestPayload? _$v;

  int? _bags;
  int? get bags => _$this._bags;
  set bags(int? bags) => _$this._bags = bags;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  HarvestPayloadBuilder() {
    HarvestPayload._defaults(this);
  }

  HarvestPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bags = $v.bags;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HarvestPayload other) {
    _$v = other as _$HarvestPayload;
  }

  @override
  void update(void Function(HarvestPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HarvestPayload build() => _build();

  _$HarvestPayload _build() {
    _$HarvestPayload _$result;
    try {
      _$result = _$v ??
          _$HarvestPayload._(
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
            r'HarvestPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
