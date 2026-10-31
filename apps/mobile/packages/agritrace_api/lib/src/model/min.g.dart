// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'min.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Min extends Min {
  @override
  final AnyOf anyOf;

  factory _$Min([void Function(MinBuilder)? updates]) =>
      (MinBuilder()..update(updates))._build();

  _$Min._({required this.anyOf}) : super._();
  @override
  Min rebuild(void Function(MinBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MinBuilder toBuilder() => MinBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Min && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'Min')..add('anyOf', anyOf))
        .toString();
  }
}

class MinBuilder implements Builder<Min, MinBuilder> {
  _$Min? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  MinBuilder() {
    Min._defaults(this);
  }

  MinBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Min other) {
    _$v = other as _$Min;
  }

  @override
  void update(void Function(MinBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Min build() => _build();

  _$Min _build() {
    final _$result = _$v ??
        _$Min._(
          anyOf: BuiltValueNullFieldError.checkNotNull(anyOf, r'Min', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
