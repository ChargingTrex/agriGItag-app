// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finished_goods.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinishedGoods extends FinishedGoods {
  @override
  final int batches;
  @override
  final BuiltList<FinishedBatch> items;
  @override
  final QuantityOutput packed;

  factory _$FinishedGoods([void Function(FinishedGoodsBuilder)? updates]) =>
      (FinishedGoodsBuilder()..update(updates))._build();

  _$FinishedGoods._(
      {required this.batches, required this.items, required this.packed})
      : super._();
  @override
  FinishedGoods rebuild(void Function(FinishedGoodsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinishedGoodsBuilder toBuilder() => FinishedGoodsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinishedGoods &&
        batches == other.batches &&
        items == other.items &&
        packed == other.packed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batches.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinishedGoods')
          ..add('batches', batches)
          ..add('items', items)
          ..add('packed', packed))
        .toString();
  }
}

class FinishedGoodsBuilder
    implements Builder<FinishedGoods, FinishedGoodsBuilder> {
  _$FinishedGoods? _$v;

  int? _batches;
  int? get batches => _$this._batches;
  set batches(int? batches) => _$this._batches = batches;

  ListBuilder<FinishedBatch>? _items;
  ListBuilder<FinishedBatch> get items =>
      _$this._items ??= ListBuilder<FinishedBatch>();
  set items(ListBuilder<FinishedBatch>? items) => _$this._items = items;

  QuantityOutputBuilder? _packed;
  QuantityOutputBuilder get packed =>
      _$this._packed ??= QuantityOutputBuilder();
  set packed(QuantityOutputBuilder? packed) => _$this._packed = packed;

  FinishedGoodsBuilder() {
    FinishedGoods._defaults(this);
  }

  FinishedGoodsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batches = $v.batches;
      _items = $v.items.toBuilder();
      _packed = $v.packed.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinishedGoods other) {
    _$v = other as _$FinishedGoods;
  }

  @override
  void update(void Function(FinishedGoodsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinishedGoods build() => _build();

  _$FinishedGoods _build() {
    _$FinishedGoods _$result;
    try {
      _$result = _$v ??
          _$FinishedGoods._(
            batches: BuiltValueNullFieldError.checkNotNull(
                batches, r'FinishedGoods', 'batches'),
            items: items.build(),
            packed: packed.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'packed';
        packed.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinishedGoods', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
