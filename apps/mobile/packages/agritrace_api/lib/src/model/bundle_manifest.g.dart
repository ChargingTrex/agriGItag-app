// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_manifest.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BundleManifest extends BundleManifest {
  @override
  final BuiltMap<String, PartVersion> parts;

  factory _$BundleManifest([void Function(BundleManifestBuilder)? updates]) =>
      (BundleManifestBuilder()..update(updates))._build();

  _$BundleManifest._({required this.parts}) : super._();
  @override
  BundleManifest rebuild(void Function(BundleManifestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BundleManifestBuilder toBuilder() => BundleManifestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BundleManifest && parts == other.parts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, parts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BundleManifest')..add('parts', parts))
        .toString();
  }
}

class BundleManifestBuilder
    implements Builder<BundleManifest, BundleManifestBuilder> {
  _$BundleManifest? _$v;

  MapBuilder<String, PartVersion>? _parts;
  MapBuilder<String, PartVersion> get parts =>
      _$this._parts ??= MapBuilder<String, PartVersion>();
  set parts(MapBuilder<String, PartVersion>? parts) => _$this._parts = parts;

  BundleManifestBuilder() {
    BundleManifest._defaults(this);
  }

  BundleManifestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _parts = $v.parts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BundleManifest other) {
    _$v = other as _$BundleManifest;
  }

  @override
  void update(void Function(BundleManifestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BundleManifest build() => _build();

  _$BundleManifest _build() {
    _$BundleManifest _$result;
    try {
      _$result = _$v ??
          _$BundleManifest._(
            parts: parts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parts';
        parts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BundleManifest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
