// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polygon_geo_json.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PolygonGeoJSONTypeEnum _$polygonGeoJSONTypeEnum_polygon =
    const PolygonGeoJSONTypeEnum._('polygon');

PolygonGeoJSONTypeEnum _$polygonGeoJSONTypeEnumValueOf(String name) {
  switch (name) {
    case 'polygon':
      return _$polygonGeoJSONTypeEnum_polygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PolygonGeoJSONTypeEnum> _$polygonGeoJSONTypeEnumValues =
    BuiltSet<PolygonGeoJSONTypeEnum>(const <PolygonGeoJSONTypeEnum>[
  _$polygonGeoJSONTypeEnum_polygon,
]);

Serializer<PolygonGeoJSONTypeEnum> _$polygonGeoJSONTypeEnumSerializer =
    _$PolygonGeoJSONTypeEnumSerializer();

class _$PolygonGeoJSONTypeEnumSerializer
    implements PrimitiveSerializer<PolygonGeoJSONTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'polygon': 'Polygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Polygon': 'polygon',
  };

  @override
  final Iterable<Type> types = const <Type>[PolygonGeoJSONTypeEnum];
  @override
  final String wireName = 'PolygonGeoJSONTypeEnum';

  @override
  Object serialize(Serializers serializers, PolygonGeoJSONTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PolygonGeoJSONTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PolygonGeoJSONTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PolygonGeoJSON extends PolygonGeoJSON {
  @override
  final BuiltList<BuiltList<BuiltList<num>>> coordinates;
  @override
  final PolygonGeoJSONTypeEnum type;

  factory _$PolygonGeoJSON([void Function(PolygonGeoJSONBuilder)? updates]) =>
      (PolygonGeoJSONBuilder()..update(updates))._build();

  _$PolygonGeoJSON._({required this.coordinates, required this.type})
      : super._();
  @override
  PolygonGeoJSON rebuild(void Function(PolygonGeoJSONBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PolygonGeoJSONBuilder toBuilder() => PolygonGeoJSONBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PolygonGeoJSON &&
        coordinates == other.coordinates &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, coordinates.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PolygonGeoJSON')
          ..add('coordinates', coordinates)
          ..add('type', type))
        .toString();
  }
}

class PolygonGeoJSONBuilder
    implements Builder<PolygonGeoJSON, PolygonGeoJSONBuilder> {
  _$PolygonGeoJSON? _$v;

  ListBuilder<BuiltList<BuiltList<num>>>? _coordinates;
  ListBuilder<BuiltList<BuiltList<num>>> get coordinates =>
      _$this._coordinates ??= ListBuilder<BuiltList<BuiltList<num>>>();
  set coordinates(ListBuilder<BuiltList<BuiltList<num>>>? coordinates) =>
      _$this._coordinates = coordinates;

  PolygonGeoJSONTypeEnum? _type;
  PolygonGeoJSONTypeEnum? get type => _$this._type;
  set type(PolygonGeoJSONTypeEnum? type) => _$this._type = type;

  PolygonGeoJSONBuilder() {
    PolygonGeoJSON._defaults(this);
  }

  PolygonGeoJSONBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _coordinates = $v.coordinates.toBuilder();
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PolygonGeoJSON other) {
    _$v = other as _$PolygonGeoJSON;
  }

  @override
  void update(void Function(PolygonGeoJSONBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PolygonGeoJSON build() => _build();

  _$PolygonGeoJSON _build() {
    _$PolygonGeoJSON _$result;
    try {
      _$result = _$v ??
          _$PolygonGeoJSON._(
            coordinates: coordinates.build(),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'PolygonGeoJSON', 'type'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PolygonGeoJSON', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
