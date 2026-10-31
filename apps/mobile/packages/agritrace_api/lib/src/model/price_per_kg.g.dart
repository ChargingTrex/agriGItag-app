// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_per_kg.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PricePerKg extends PricePerKg {
  @override
  final AnyOf anyOf;

  factory _$PricePerKg([void Function(PricePerKgBuilder)? updates]) =>
      (PricePerKgBuilder()..update(updates))._build();

  _$PricePerKg._({required this.anyOf}) : super._();
  @override
  PricePerKg rebuild(void Function(PricePerKgBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PricePerKgBuilder toBuilder() => PricePerKgBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PricePerKg && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'PricePerKg')..add('anyOf', anyOf))
        .toString();
  }
}

class PricePerKgBuilder implements Builder<PricePerKg, PricePerKgBuilder> {
  _$PricePerKg? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PricePerKgBuilder() {
    PricePerKg._defaults(this);
  }

  PricePerKgBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PricePerKg other) {
    _$v = other as _$PricePerKg;
  }

  @override
  void update(void Function(PricePerKgBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PricePerKg build() => _build();

  _$PricePerKg _build() {
    final _$result = _$v ??
        _$PricePerKg._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PricePerKg', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
