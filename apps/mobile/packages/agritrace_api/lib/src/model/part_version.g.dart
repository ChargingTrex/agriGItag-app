// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PartVersion extends PartVersion {
  @override
  final String etag;
  @override
  final int version;

  factory _$PartVersion([void Function(PartVersionBuilder)? updates]) =>
      (PartVersionBuilder()..update(updates))._build();

  _$PartVersion._({required this.etag, required this.version}) : super._();
  @override
  PartVersion rebuild(void Function(PartVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PartVersionBuilder toBuilder() => PartVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PartVersion &&
        etag == other.etag &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PartVersion')
          ..add('etag', etag)
          ..add('version', version))
        .toString();
  }
}

class PartVersionBuilder implements Builder<PartVersion, PartVersionBuilder> {
  _$PartVersion? _$v;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PartVersionBuilder() {
    PartVersion._defaults(this);
  }

  PartVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _etag = $v.etag;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PartVersion other) {
    _$v = other as _$PartVersion;
  }

  @override
  void update(void Function(PartVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PartVersion build() => _build();

  _$PartVersion _build() {
    final _$result = _$v ??
        _$PartVersion._(
          etag: BuiltValueNullFieldError.checkNotNull(
              etag, r'PartVersion', 'etag'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'PartVersion', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
