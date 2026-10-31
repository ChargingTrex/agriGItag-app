// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ceiling_kg_per_acre.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CeilingKgPerAcre extends CeilingKgPerAcre {
  @override
  final AnyOf anyOf;

  factory _$CeilingKgPerAcre(
          [void Function(CeilingKgPerAcreBuilder)? updates]) =>
      (CeilingKgPerAcreBuilder()..update(updates))._build();

  _$CeilingKgPerAcre._({required this.anyOf}) : super._();
  @override
  CeilingKgPerAcre rebuild(void Function(CeilingKgPerAcreBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CeilingKgPerAcreBuilder toBuilder() =>
      CeilingKgPerAcreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CeilingKgPerAcre && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'CeilingKgPerAcre')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class CeilingKgPerAcreBuilder
    implements Builder<CeilingKgPerAcre, CeilingKgPerAcreBuilder> {
  _$CeilingKgPerAcre? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  CeilingKgPerAcreBuilder() {
    CeilingKgPerAcre._defaults(this);
  }

  CeilingKgPerAcreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CeilingKgPerAcre other) {
    _$v = other as _$CeilingKgPerAcre;
  }

  @override
  void update(void Function(CeilingKgPerAcreBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CeilingKgPerAcre build() => _build();

  _$CeilingKgPerAcre _build() {
    final _$result = _$v ??
        _$CeilingKgPerAcre._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'CeilingKgPerAcre', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
