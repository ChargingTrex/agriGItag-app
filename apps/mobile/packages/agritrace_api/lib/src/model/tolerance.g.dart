// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tolerance.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Tolerance extends Tolerance {
  @override
  final AnyOf anyOf;

  factory _$Tolerance([void Function(ToleranceBuilder)? updates]) =>
      (ToleranceBuilder()..update(updates))._build();

  _$Tolerance._({required this.anyOf}) : super._();
  @override
  Tolerance rebuild(void Function(ToleranceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ToleranceBuilder toBuilder() => ToleranceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Tolerance && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'Tolerance')..add('anyOf', anyOf))
        .toString();
  }
}

class ToleranceBuilder implements Builder<Tolerance, ToleranceBuilder> {
  _$Tolerance? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  ToleranceBuilder() {
    Tolerance._defaults(this);
  }

  ToleranceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Tolerance other) {
    _$v = other as _$Tolerance;
  }

  @override
  void update(void Function(ToleranceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Tolerance build() => _build();

  _$Tolerance _build() {
    final _$result = _$v ??
        _$Tolerance._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'Tolerance', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
