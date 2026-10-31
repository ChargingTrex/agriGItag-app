// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avg_sale_price_per_kg.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AvgSalePricePerKg extends AvgSalePricePerKg {
  @override
  final AnyOf anyOf;

  factory _$AvgSalePricePerKg(
          [void Function(AvgSalePricePerKgBuilder)? updates]) =>
      (AvgSalePricePerKgBuilder()..update(updates))._build();

  _$AvgSalePricePerKg._({required this.anyOf}) : super._();
  @override
  AvgSalePricePerKg rebuild(void Function(AvgSalePricePerKgBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvgSalePricePerKgBuilder toBuilder() =>
      AvgSalePricePerKgBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AvgSalePricePerKg && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AvgSalePricePerKg')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class AvgSalePricePerKgBuilder
    implements Builder<AvgSalePricePerKg, AvgSalePricePerKgBuilder> {
  _$AvgSalePricePerKg? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  AvgSalePricePerKgBuilder() {
    AvgSalePricePerKg._defaults(this);
  }

  AvgSalePricePerKgBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AvgSalePricePerKg other) {
    _$v = other as _$AvgSalePricePerKg;
  }

  @override
  void update(void Function(AvgSalePricePerKgBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AvgSalePricePerKg build() => _build();

  _$AvgSalePricePerKg _build() {
    final _$result = _$v ??
        _$AvgSalePricePerKg._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'AvgSalePricePerKg', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
