// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tolerance_buffer_m.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ToleranceBufferM extends ToleranceBufferM {
  @override
  final AnyOf anyOf;

  factory _$ToleranceBufferM(
          [void Function(ToleranceBufferMBuilder)? updates]) =>
      (ToleranceBufferMBuilder()..update(updates))._build();

  _$ToleranceBufferM._({required this.anyOf}) : super._();
  @override
  ToleranceBufferM rebuild(void Function(ToleranceBufferMBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ToleranceBufferMBuilder toBuilder() =>
      ToleranceBufferMBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ToleranceBufferM && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'ToleranceBufferM')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class ToleranceBufferMBuilder
    implements Builder<ToleranceBufferM, ToleranceBufferMBuilder> {
  _$ToleranceBufferM? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  ToleranceBufferMBuilder() {
    ToleranceBufferM._defaults(this);
  }

  ToleranceBufferMBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ToleranceBufferM other) {
    _$v = other as _$ToleranceBufferM;
  }

  @override
  void update(void Function(ToleranceBufferMBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ToleranceBufferM build() => _build();

  _$ToleranceBufferM _build() {
    final _$result = _$v ??
        _$ToleranceBufferM._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'ToleranceBufferM', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
