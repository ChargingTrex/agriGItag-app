// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warn_margin_pct.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WarnMarginPct extends WarnMarginPct {
  @override
  final AnyOf anyOf;

  factory _$WarnMarginPct([void Function(WarnMarginPctBuilder)? updates]) =>
      (WarnMarginPctBuilder()..update(updates))._build();

  _$WarnMarginPct._({required this.anyOf}) : super._();
  @override
  WarnMarginPct rebuild(void Function(WarnMarginPctBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WarnMarginPctBuilder toBuilder() => WarnMarginPctBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WarnMarginPct && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'WarnMarginPct')..add('anyOf', anyOf))
        .toString();
  }
}

class WarnMarginPctBuilder
    implements Builder<WarnMarginPct, WarnMarginPctBuilder> {
  _$WarnMarginPct? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  WarnMarginPctBuilder() {
    WarnMarginPct._defaults(this);
  }

  WarnMarginPctBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WarnMarginPct other) {
    _$v = other as _$WarnMarginPct;
  }

  @override
  void update(void Function(WarnMarginPctBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WarnMarginPct build() => _build();

  _$WarnMarginPct _build() {
    final _$result = _$v ??
        _$WarnMarginPct._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'WarnMarginPct', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
