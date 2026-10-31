//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/gi_region_version_out.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gi_region_out.g.dart';

/// The current region of a GI tag: version metadata plus a simplified outline (≤ 50 KB).
///
/// Properties:
/// * [geometry] - Simplified GeoJSON outline (MultiPolygon or Polygon), [lon, lat], 6 decimal places.
/// * [simplifiedToleranceM] - Simplification tolerance used, in metres.
/// * [version] - The region version in effect today.
@BuiltValue()
abstract class GiRegionOut implements Built<GiRegionOut, GiRegionOutBuilder> {
  /// Simplified GeoJSON outline (MultiPolygon or Polygon), [lon, lat], 6 decimal places.
  @BuiltValueField(wireName: r'geometry')
  BuiltMap<String, JsonObject?> get geometry;

  /// Simplification tolerance used, in metres.
  @BuiltValueField(wireName: r'simplified_tolerance_m')
  num get simplifiedToleranceM;

  /// The region version in effect today.
  @BuiltValueField(wireName: r'version')
  GiRegionVersionOut get version;

  GiRegionOut._();

  factory GiRegionOut([void updates(GiRegionOutBuilder b)]) = _$GiRegionOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GiRegionOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GiRegionOut> get serializer => _$GiRegionOutSerializer();
}

class _$GiRegionOutSerializer implements PrimitiveSerializer<GiRegionOut> {
  @override
  final Iterable<Type> types = const [GiRegionOut, _$GiRegionOut];

  @override
  final String wireName = r'GiRegionOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GiRegionOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'simplified_tolerance_m';
    yield serializers.serialize(
      object.simplifiedToleranceM,
      specifiedType: const FullType(num),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(GiRegionVersionOut),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GiRegionOut object, {
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
    required GiRegionOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.geometry.replace(valueDes);
          break;
        case r'simplified_tolerance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.simplifiedToleranceM = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GiRegionVersionOut),
          ) as GiRegionVersionOut;
          result.version.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GiRegionOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GiRegionOutBuilder();
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
