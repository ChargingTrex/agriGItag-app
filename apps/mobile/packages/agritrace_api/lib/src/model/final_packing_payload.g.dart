// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'final_packing_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinalPackingPayload extends FinalPackingPayload {
  @override
  final AvgSalePricePerKg? avgSalePricePerKg;
  @override
  final QuantityInput? packSize;
  @override
  final int? packs;
  @override
  final QuantityInput? quantity;

  factory _$FinalPackingPayload(
          [void Function(FinalPackingPayloadBuilder)? updates]) =>
      (FinalPackingPayloadBuilder()..update(updates))._build();

  _$FinalPackingPayload._(
      {this.avgSalePricePerKg, this.packSize, this.packs, this.quantity})
      : super._();
  @override
  FinalPackingPayload rebuild(
          void Function(FinalPackingPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinalPackingPayloadBuilder toBuilder() =>
      FinalPackingPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinalPackingPayload &&
        avgSalePricePerKg == other.avgSalePricePerKg &&
        packSize == other.packSize &&
        packs == other.packs &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgSalePricePerKg.hashCode);
    _$hash = $jc(_$hash, packSize.hashCode);
    _$hash = $jc(_$hash, packs.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinalPackingPayload')
          ..add('avgSalePricePerKg', avgSalePricePerKg)
          ..add('packSize', packSize)
          ..add('packs', packs)
          ..add('quantity', quantity))
        .toString();
  }
}

class FinalPackingPayloadBuilder
    implements Builder<FinalPackingPayload, FinalPackingPayloadBuilder> {
  _$FinalPackingPayload? _$v;

  AvgSalePricePerKgBuilder? _avgSalePricePerKg;
  AvgSalePricePerKgBuilder get avgSalePricePerKg =>
      _$this._avgSalePricePerKg ??= AvgSalePricePerKgBuilder();
  set avgSalePricePerKg(AvgSalePricePerKgBuilder? avgSalePricePerKg) =>
      _$this._avgSalePricePerKg = avgSalePricePerKg;

  QuantityInputBuilder? _packSize;
  QuantityInputBuilder get packSize =>
      _$this._packSize ??= QuantityInputBuilder();
  set packSize(QuantityInputBuilder? packSize) => _$this._packSize = packSize;

  int? _packs;
  int? get packs => _$this._packs;
  set packs(int? packs) => _$this._packs = packs;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  FinalPackingPayloadBuilder() {
    FinalPackingPayload._defaults(this);
  }

  FinalPackingPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgSalePricePerKg = $v.avgSalePricePerKg?.toBuilder();
      _packSize = $v.packSize?.toBuilder();
      _packs = $v.packs;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinalPackingPayload other) {
    _$v = other as _$FinalPackingPayload;
  }

  @override
  void update(void Function(FinalPackingPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinalPackingPayload build() => _build();

  _$FinalPackingPayload _build() {
    _$FinalPackingPayload _$result;
    try {
      _$result = _$v ??
          _$FinalPackingPayload._(
            avgSalePricePerKg: _avgSalePricePerKg?.build(),
            packSize: _packSize?.build(),
            packs: packs,
            quantity: _quantity?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'avgSalePricePerKg';
        _avgSalePricePerKg?.build();
        _$failedField = 'packSize';
        _packSize?.build();

        _$failedField = 'quantity';
        _quantity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinalPackingPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
