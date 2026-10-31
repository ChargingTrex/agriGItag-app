// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gi_region_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GiRegionOut extends GiRegionOut {
  @override
  final BuiltMap<String, JsonObject?> geometry;
  @override
  final num simplifiedToleranceM;
  @override
  final GiRegionVersionOut version;

  factory _$GiRegionOut([void Function(GiRegionOutBuilder)? updates]) =>
      (GiRegionOutBuilder()..update(updates))._build();

  _$GiRegionOut._(
      {required this.geometry,
      required this.simplifiedToleranceM,
      required this.version})
      : super._();
  @override
  GiRegionOut rebuild(void Function(GiRegionOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GiRegionOutBuilder toBuilder() => GiRegionOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GiRegionOut &&
        geometry == other.geometry &&
        simplifiedToleranceM == other.simplifiedToleranceM &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, geometry.hashCode);
    _$hash = $jc(_$hash, simplifiedToleranceM.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GiRegionOut')
          ..add('geometry', geometry)
          ..add('simplifiedToleranceM', simplifiedToleranceM)
          ..add('version', version))
        .toString();
  }
}

class GiRegionOutBuilder implements Builder<GiRegionOut, GiRegionOutBuilder> {
  _$GiRegionOut? _$v;

  MapBuilder<String, JsonObject?>? _geometry;
  MapBuilder<String, JsonObject?> get geometry =>
      _$this._geometry ??= MapBuilder<String, JsonObject?>();
  set geometry(MapBuilder<String, JsonObject?>? geometry) =>
      _$this._geometry = geometry;

  num? _simplifiedToleranceM;
  num? get simplifiedToleranceM => _$this._simplifiedToleranceM;
  set simplifiedToleranceM(num? simplifiedToleranceM) =>
      _$this._simplifiedToleranceM = simplifiedToleranceM;

  GiRegionVersionOutBuilder? _version;
  GiRegionVersionOutBuilder get version =>
      _$this._version ??= GiRegionVersionOutBuilder();
  set version(GiRegionVersionOutBuilder? version) => _$this._version = version;

  GiRegionOutBuilder() {
    GiRegionOut._defaults(this);
  }

  GiRegionOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _geometry = $v.geometry.toBuilder();
      _simplifiedToleranceM = $v.simplifiedToleranceM;
      _version = $v.version.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GiRegionOut other) {
    _$v = other as _$GiRegionOut;
  }

  @override
  void update(void Function(GiRegionOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GiRegionOut build() => _build();

  _$GiRegionOut _build() {
    _$GiRegionOut _$result;
    try {
      _$result = _$v ??
          _$GiRegionOut._(
            geometry: geometry.build(),
            simplifiedToleranceM: BuiltValueNullFieldError.checkNotNull(
                simplifiedToleranceM, r'GiRegionOut', 'simplifiedToleranceM'),
            version: version.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'geometry';
        geometry.build();

        _$failedField = 'version';
        version.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GiRegionOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
