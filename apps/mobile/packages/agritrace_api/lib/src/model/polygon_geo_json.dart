//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'polygon_geo_json.g.dart';

/// A GeoJSON Polygon in WGS84, e.g. a walked plot boundary (FR66). First ring is the outer edge.
///
/// Properties:
/// * [coordinates] - Rings of [lon, lat] positions; each ring closed (first = last), at least 4 positions.
/// * [type] - Always `Polygon`.
@BuiltValue()
abstract class PolygonGeoJSON
    implements Built<PolygonGeoJSON, PolygonGeoJSONBuilder> {
  /// Rings of [lon, lat] positions; each ring closed (first = last), at least 4 positions.
  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<BuiltList<num>>> get coordinates;

  /// Always `Polygon`.
  @BuiltValueField(wireName: r'type')
  PolygonGeoJSONTypeEnum get type;
  // enum typeEnum {  Polygon,  };

  PolygonGeoJSON._();

  factory PolygonGeoJSON([void updates(PolygonGeoJSONBuilder b)]) =
      _$PolygonGeoJSON;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PolygonGeoJSONBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PolygonGeoJSON> get serializer =>
      _$PolygonGeoJSONSerializer();
}

class _$PolygonGeoJSONSerializer
    implements PrimitiveSerializer<PolygonGeoJSON> {
  @override
  final Iterable<Type> types = const [PolygonGeoJSON, _$PolygonGeoJSON];

  @override
  final String wireName = r'PolygonGeoJSON';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PolygonGeoJSON object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [
        FullType(BuiltList, [
          FullType(BuiltList, [FullType(num)])
        ])
      ]),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(PolygonGeoJSONTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PolygonGeoJSON object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PolygonGeoJSONBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(BuiltList, [
                FullType(BuiltList, [FullType(num)])
              ])
            ]),
          ) as BuiltList<BuiltList<BuiltList<num>>>;
          result.coordinates.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PolygonGeoJSONTypeEnum),
          ) as PolygonGeoJSONTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PolygonGeoJSON deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PolygonGeoJSONBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

/// Always `Polygon`.
class PolygonGeoJSONTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Polygon')
  static const PolygonGeoJSONTypeEnum polygon =
      _$polygonGeoJSONTypeEnum_polygon;

  static Serializer<PolygonGeoJSONTypeEnum> get serializer =>
      _$polygonGeoJSONTypeEnumSerializer;

  const PolygonGeoJSONTypeEnum._(String name) : super(name);

  static BuiltSet<PolygonGeoJSONTypeEnum> get values =>
      _$polygonGeoJSONTypeEnumValues;
  static PolygonGeoJSONTypeEnum valueOf(String name) =>
      _$polygonGeoJSONTypeEnumValueOf(name);
}
