// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Value1 extends Value1 {
  @override
  final AnyOf anyOf;

  factory _$Value1([void Function(Value1Builder)? updates]) =>
      (Value1Builder()..update(updates))._build();

  _$Value1._({required this.anyOf}) : super._();
  @override
  Value1 rebuild(void Function(Value1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Value1Builder toBuilder() => Value1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Value1 && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'Value1')..add('anyOf', anyOf))
        .toString();
  }
}

class Value1Builder implements Builder<Value1, Value1Builder> {
  _$Value1? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  Value1Builder() {
    Value1._defaults(this);
  }

  Value1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Value1 other) {
    _$v = other as _$Value1;
  }

  @override
  void update(void Function(Value1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Value1 build() => _build();

  _$Value1 _build() {
    final _$result = _$v ??
        _$Value1._(
          anyOf:
              BuiltValueNullFieldError.checkNotNull(anyOf, r'Value1', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
