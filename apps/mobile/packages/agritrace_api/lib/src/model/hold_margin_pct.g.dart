// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hold_margin_pct.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HoldMarginPct extends HoldMarginPct {
  @override
  final AnyOf anyOf;

  factory _$HoldMarginPct([void Function(HoldMarginPctBuilder)? updates]) =>
      (HoldMarginPctBuilder()..update(updates))._build();

  _$HoldMarginPct._({required this.anyOf}) : super._();
  @override
  HoldMarginPct rebuild(void Function(HoldMarginPctBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HoldMarginPctBuilder toBuilder() => HoldMarginPctBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HoldMarginPct && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'HoldMarginPct')..add('anyOf', anyOf))
        .toString();
  }
}

class HoldMarginPctBuilder
    implements Builder<HoldMarginPct, HoldMarginPctBuilder> {
  _$HoldMarginPct? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  HoldMarginPctBuilder() {
    HoldMarginPct._defaults(this);
  }

  HoldMarginPctBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HoldMarginPct other) {
    _$v = other as _$HoldMarginPct;
  }

  @override
  void update(void Function(HoldMarginPctBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HoldMarginPct build() => _build();

  _$HoldMarginPct _build() {
    final _$result = _$v ??
        _$HoldMarginPct._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'HoldMarginPct', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
