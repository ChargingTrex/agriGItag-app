// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GeoPoint extends GeoPoint {
  @override
  final num? accuracyM;
  @override
  final num lat;
  @override
  final num lon;

  factory _$GeoPoint([void Function(GeoPointBuilder)? updates]) =>
      (GeoPointBuilder()..update(updates))._build();

  _$GeoPoint._({this.accuracyM, required this.lat, required this.lon})
      : super._();
  @override
  GeoPoint rebuild(void Function(GeoPointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoPointBuilder toBuilder() => GeoPointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoPoint &&
        accuracyM == other.accuracyM &&
        lat == other.lat &&
        lon == other.lon;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accuracyM.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lon.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoPoint')
          ..add('accuracyM', accuracyM)
          ..add('lat', lat)
          ..add('lon', lon))
        .toString();
  }
}

class GeoPointBuilder implements Builder<GeoPoint, GeoPointBuilder> {
  _$GeoPoint? _$v;

  num? _accuracyM;
  num? get accuracyM => _$this._accuracyM;
  set accuracyM(num? accuracyM) => _$this._accuracyM = accuracyM;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lon;
  num? get lon => _$this._lon;
  set lon(num? lon) => _$this._lon = lon;

  GeoPointBuilder() {
    GeoPoint._defaults(this);
  }

  GeoPointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accuracyM = $v.accuracyM;
      _lat = $v.lat;
      _lon = $v.lon;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoPoint other) {
    _$v = other as _$GeoPoint;
  }

  @override
  void update(void Function(GeoPointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoPoint build() => _build();

  _$GeoPoint _build() {
    final _$result = _$v ??
        _$GeoPoint._(
          accuracyM: accuracyM,
          lat: BuiltValueNullFieldError.checkNotNull(lat, r'GeoPoint', 'lat'),
          lon: BuiltValueNullFieldError.checkNotNull(lon, r'GeoPoint', 'lon'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
