// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'max.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Max extends Max {
  @override
  final AnyOf anyOf;

  factory _$Max([void Function(MaxBuilder)? updates]) =>
      (MaxBuilder()..update(updates))._build();

  _$Max._({required this.anyOf}) : super._();
  @override
  Max rebuild(void Function(MaxBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaxBuilder toBuilder() => MaxBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Max && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'Max')..add('anyOf', anyOf))
        .toString();
  }
}

class MaxBuilder implements Builder<Max, MaxBuilder> {
  _$Max? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  MaxBuilder() {
    Max._defaults(this);
  }

  MaxBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Max other) {
    _$v = other as _$Max;
  }

  @override
  void update(void Function(MaxBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Max build() => _build();

  _$Max _build() {
    final _$result = _$v ??
        _$Max._(
          anyOf: BuiltValueNullFieldError.checkNotNull(anyOf, r'Max', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
