//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'multi_polygon_geo_json.g.dart';

/// A GeoJSON MultiPolygon in WGS84, e.g. a GI production-area outline (FR27).
///
/// Properties:
/// * [coordinates] - Polygons, each a list of closed rings of [lon, lat] positions.
/// * [type] - Always `MultiPolygon`.
@BuiltValue()
abstract class MultiPolygonGeoJSON
    implements Built<MultiPolygonGeoJSON, MultiPolygonGeoJSONBuilder> {
  /// Polygons, each a list of closed rings of [lon, lat] positions.
  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<BuiltList<BuiltList<num>>>> get coordinates;

  /// Always `MultiPolygon`.
  @BuiltValueField(wireName: r'type')
  MultiPolygonGeoJSONTypeEnum get type;
  // enum typeEnum {  MultiPolygon,  };

  MultiPolygonGeoJSON._();

  factory MultiPolygonGeoJSON([void updates(MultiPolygonGeoJSONBuilder b)]) =
      _$MultiPolygonGeoJSON;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MultiPolygonGeoJSONBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MultiPolygonGeoJSON> get serializer =>
      _$MultiPolygonGeoJSONSerializer();
}

class _$MultiPolygonGeoJSONSerializer
    implements PrimitiveSerializer<MultiPolygonGeoJSON> {
  @override
  final Iterable<Type> types = const [
    MultiPolygonGeoJSON,
    _$MultiPolygonGeoJSON
  ];

  @override
  final String wireName = r'MultiPolygonGeoJSON';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MultiPolygonGeoJSON object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [
        FullType(BuiltList, [
          FullType(BuiltList, [
            FullType(BuiltList, [FullType(num)])
          ])
        ])
      ]),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(MultiPolygonGeoJSONTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MultiPolygonGeoJSON object, {
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
    required MultiPolygonGeoJSONBuilder result,
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
                FullType(BuiltList, [
                  FullType(BuiltList, [FullType(num)])
                ])
              ])
            ]),
          ) as BuiltList<BuiltList<BuiltList<BuiltList<num>>>>;
          result.coordinates.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MultiPolygonGeoJSONTypeEnum),
          ) as MultiPolygonGeoJSONTypeEnum;
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
  MultiPolygonGeoJSON deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MultiPolygonGeoJSONBuilder();
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

/// Always `MultiPolygon`.
class MultiPolygonGeoJSONTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'MultiPolygon')
  static const MultiPolygonGeoJSONTypeEnum multiPolygon =
      _$multiPolygonGeoJSONTypeEnum_multiPolygon;

  static Serializer<MultiPolygonGeoJSONTypeEnum> get serializer =>
      _$multiPolygonGeoJSONTypeEnumSerializer;

  const MultiPolygonGeoJSONTypeEnum._(String name) : super(name);

  static BuiltSet<MultiPolygonGeoJSONTypeEnum> get values =>
      _$multiPolygonGeoJSONTypeEnumValues;
  static MultiPolygonGeoJSONTypeEnum valueOf(String name) =>
      _$multiPolygonGeoJSONTypeEnumValueOf(name);
}
