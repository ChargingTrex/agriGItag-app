// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_certified_requires.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LabCertifiedRequires extends LabCertifiedRequires {
  @override
  final ReadingSource? anyParameterSource;
  @override
  final bool? nablNoPresent;

  factory _$LabCertifiedRequires(
          [void Function(LabCertifiedRequiresBuilder)? updates]) =>
      (LabCertifiedRequiresBuilder()..update(updates))._build();

  _$LabCertifiedRequires._({this.anyParameterSource, this.nablNoPresent})
      : super._();
  @override
  LabCertifiedRequires rebuild(
          void Function(LabCertifiedRequiresBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LabCertifiedRequiresBuilder toBuilder() =>
      LabCertifiedRequiresBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LabCertifiedRequires &&
        anyParameterSource == other.anyParameterSource &&
        nablNoPresent == other.nablNoPresent;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyParameterSource.hashCode);
    _$hash = $jc(_$hash, nablNoPresent.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LabCertifiedRequires')
          ..add('anyParameterSource', anyParameterSource)
          ..add('nablNoPresent', nablNoPresent))
        .toString();
  }
}

class LabCertifiedRequiresBuilder
    implements Builder<LabCertifiedRequires, LabCertifiedRequiresBuilder> {
  _$LabCertifiedRequires? _$v;

  ReadingSource? _anyParameterSource;
  ReadingSource? get anyParameterSource => _$this._anyParameterSource;
  set anyParameterSource(ReadingSource? anyParameterSource) =>
      _$this._anyParameterSource = anyParameterSource;

  bool? _nablNoPresent;
  bool? get nablNoPresent => _$this._nablNoPresent;
  set nablNoPresent(bool? nablNoPresent) =>
      _$this._nablNoPresent = nablNoPresent;

  LabCertifiedRequiresBuilder() {
    LabCertifiedRequires._defaults(this);
  }

  LabCertifiedRequiresBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyParameterSource = $v.anyParameterSource;
      _nablNoPresent = $v.nablNoPresent;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LabCertifiedRequires other) {
    _$v = other as _$LabCertifiedRequires;
  }

  @override
  void update(void Function(LabCertifiedRequiresBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LabCertifiedRequires build() => _build();

  _$LabCertifiedRequires _build() {
    final _$result = _$v ??
        _$LabCertifiedRequires._(
          anyParameterSource: anyParameterSource,
          nablNoPresent: nablNoPresent,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
