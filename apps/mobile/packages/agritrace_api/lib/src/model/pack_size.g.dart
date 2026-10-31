// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_size.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PackSize extends PackSize {
  @override
  final AnyOf anyOf;

  factory _$PackSize([void Function(PackSizeBuilder)? updates]) =>
      (PackSizeBuilder()..update(updates))._build();

  _$PackSize._({required this.anyOf}) : super._();
  @override
  PackSize rebuild(void Function(PackSizeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PackSizeBuilder toBuilder() => PackSizeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PackSize && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'PackSize')..add('anyOf', anyOf))
        .toString();
  }
}

class PackSizeBuilder implements Builder<PackSize, PackSizeBuilder> {
  _$PackSize? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PackSizeBuilder() {
    PackSize._defaults(this);
  }

  PackSizeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PackSize other) {
    _$v = other as _$PackSize;
  }

  @override
  void update(void Function(PackSizeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PackSize build() => _build();

  _$PackSize _build() {
    final _$result = _$v ??
        _$PackSize._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PackSize', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
