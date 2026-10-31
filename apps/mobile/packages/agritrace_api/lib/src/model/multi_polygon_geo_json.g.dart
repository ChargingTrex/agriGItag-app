// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_polygon_geo_json.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MultiPolygonGeoJSONTypeEnum _$multiPolygonGeoJSONTypeEnum_multiPolygon =
    const MultiPolygonGeoJSONTypeEnum._('multiPolygon');

MultiPolygonGeoJSONTypeEnum _$multiPolygonGeoJSONTypeEnumValueOf(String name) {
  switch (name) {
    case 'multiPolygon':
      return _$multiPolygonGeoJSONTypeEnum_multiPolygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MultiPolygonGeoJSONTypeEnum>
    _$multiPolygonGeoJSONTypeEnumValues =
    BuiltSet<MultiPolygonGeoJSONTypeEnum>(const <MultiPolygonGeoJSONTypeEnum>[
  _$multiPolygonGeoJSONTypeEnum_multiPolygon,
]);

Serializer<MultiPolygonGeoJSONTypeEnum>
    _$multiPolygonGeoJSONTypeEnumSerializer =
    _$MultiPolygonGeoJSONTypeEnumSerializer();

class _$MultiPolygonGeoJSONTypeEnumSerializer
    implements PrimitiveSerializer<MultiPolygonGeoJSONTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'multiPolygon': 'MultiPolygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MultiPolygon': 'multiPolygon',
  };

  @override
  final Iterable<Type> types = const <Type>[MultiPolygonGeoJSONTypeEnum];
  @override
  final String wireName = 'MultiPolygonGeoJSONTypeEnum';

  @override
  Object serialize(Serializers serializers, MultiPolygonGeoJSONTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MultiPolygonGeoJSONTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MultiPolygonGeoJSONTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MultiPolygonGeoJSON extends MultiPolygonGeoJSON {
  @override
  final BuiltList<BuiltList<BuiltList<BuiltList<num>>>> coordinates;
  @override
  final MultiPolygonGeoJSONTypeEnum type;

  factory _$MultiPolygonGeoJSON(
          [void Function(MultiPolygonGeoJSONBuilder)? updates]) =>
      (MultiPolygonGeoJSONBuilder()..update(updates))._build();

  _$MultiPolygonGeoJSON._({required this.coordinates, required this.type})
      : super._();
  @override
  MultiPolygonGeoJSON rebuild(
          void Function(MultiPolygonGeoJSONBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MultiPolygonGeoJSONBuilder toBuilder() =>
      MultiPolygonGeoJSONBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MultiPolygonGeoJSON &&
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
    return (newBuiltValueToStringHelper(r'MultiPolygonGeoJSON')
          ..add('coordinates', coordinates)
          ..add('type', type))
        .toString();
  }
}

class MultiPolygonGeoJSONBuilder
    implements Builder<MultiPolygonGeoJSON, MultiPolygonGeoJSONBuilder> {
  _$MultiPolygonGeoJSON? _$v;

  ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>? _coordinates;
  ListBuilder<BuiltList<BuiltList<BuiltList<num>>>> get coordinates =>
      _$this._coordinates ??=
          ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>();
  set coordinates(
          ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>? coordinates) =>
      _$this._coordinates = coordinates;

  MultiPolygonGeoJSONTypeEnum? _type;
  MultiPolygonGeoJSONTypeEnum? get type => _$this._type;
  set type(MultiPolygonGeoJSONTypeEnum? type) => _$this._type = type;

  MultiPolygonGeoJSONBuilder() {
    MultiPolygonGeoJSON._defaults(this);
  }

  MultiPolygonGeoJSONBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _coordinates = $v.coordinates.toBuilder();
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MultiPolygonGeoJSON other) {
    _$v = other as _$MultiPolygonGeoJSON;
  }

  @override
  void update(void Function(MultiPolygonGeoJSONBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MultiPolygonGeoJSON build() => _build();

  _$MultiPolygonGeoJSON _build() {
    _$MultiPolygonGeoJSON _$result;
    try {
      _$result = _$v ??
          _$MultiPolygonGeoJSON._(
            coordinates: coordinates.build(),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'MultiPolygonGeoJSON', 'type'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MultiPolygonGeoJSON', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
