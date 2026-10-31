//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/tolerance_buffer_m.dart';
import 'package:agritrace_api/src/model/multi_polygon_geo_json.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gi_region_version_in.g.dart';

/// A new version of a GI tag's production-area outline with its provenance (FR27, FR31, FR32, D-019).
///
/// Properties:
/// * [attribution] - Attribution line the source licence requires, e.g. `Boundary data © geoBoundaries contributors, ODbL-1.0; ...`; stored inside `source_ref` (no column for it).
/// * [confidence] - How the outline was derived: official (registry or surveyed file), district_derived (admin boundaries, D-019) or fixture (test data, never for real checks).
/// * [effectiveFrom] - First day checks use it; default today.
/// * [geometry] - Outline in WGS84 [lon, lat].
/// * [licence] - Licence of the source data, e.g. ODbL-1.0.
/// * [shareAlike] - True when the derived outline must be shared under the same licence (ODbL); stored inside `source_ref`.
/// * [sourceRef] - Source dataset, file and build script reference (D-019).
/// * [taluks] - Taluks named in the GI registration that this outline unions (D-019).
/// * [toleranceBufferM]
@BuiltValue()
abstract class GiRegionVersionIn
    implements Built<GiRegionVersionIn, GiRegionVersionInBuilder> {
  /// Attribution line the source licence requires, e.g. `Boundary data © geoBoundaries contributors, ODbL-1.0; ...`; stored inside `source_ref` (no column for it).
  @BuiltValueField(wireName: r'attribution')
  String get attribution;

  /// How the outline was derived: official (registry or surveyed file), district_derived (admin boundaries, D-019) or fixture (test data, never for real checks).
  @BuiltValueField(wireName: r'confidence')
  GiRegionVersionInConfidenceEnum get confidence;
  // enum confidenceEnum {  official,  district_derived,  fixture,  };

  /// First day checks use it; default today.
  @BuiltValueField(wireName: r'effective_from')
  Date? get effectiveFrom;

  /// Outline in WGS84 [lon, lat].
  @BuiltValueField(wireName: r'geometry')
  MultiPolygonGeoJSON get geometry;

  /// Licence of the source data, e.g. ODbL-1.0.
  @BuiltValueField(wireName: r'licence')
  String get licence;

  /// True when the derived outline must be shared under the same licence (ODbL); stored inside `source_ref`.
  @BuiltValueField(wireName: r'share_alike')
  bool get shareAlike;

  /// Source dataset, file and build script reference (D-019).
  @BuiltValueField(wireName: r'source_ref')
  String get sourceRef;

  /// Taluks named in the GI registration that this outline unions (D-019).
  @BuiltValueField(wireName: r'taluks')
  BuiltList<String> get taluks;

  @BuiltValueField(wireName: r'tolerance_buffer_m')
  ToleranceBufferM get toleranceBufferM;

  GiRegionVersionIn._();

  factory GiRegionVersionIn([void updates(GiRegionVersionInBuilder b)]) =
      _$GiRegionVersionIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GiRegionVersionInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GiRegionVersionIn> get serializer =>
      _$GiRegionVersionInSerializer();
}

class _$GiRegionVersionInSerializer
    implements PrimitiveSerializer<GiRegionVersionIn> {
  @override
  final Iterable<Type> types = const [GiRegionVersionIn, _$GiRegionVersionIn];

  @override
  final String wireName = r'GiRegionVersionIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GiRegionVersionIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attribution';
    yield serializers.serialize(
      object.attribution,
      specifiedType: const FullType(String),
    );
    yield r'confidence';
    yield serializers.serialize(
      object.confidence,
      specifiedType: const FullType(GiRegionVersionInConfidenceEnum),
    );
    if (object.effectiveFrom != null) {
      yield r'effective_from';
      yield serializers.serialize(
        object.effectiveFrom,
        specifiedType: const FullType.nullable(Date),
      );
    }
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(MultiPolygonGeoJSON),
    );
    yield r'licence';
    yield serializers.serialize(
      object.licence,
      specifiedType: const FullType(String),
    );
    yield r'share_alike';
    yield serializers.serialize(
      object.shareAlike,
      specifiedType: const FullType(bool),
    );
    yield r'source_ref';
    yield serializers.serialize(
      object.sourceRef,
      specifiedType: const FullType(String),
    );
    yield r'taluks';
    yield serializers.serialize(
      object.taluks,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'tolerance_buffer_m';
    yield serializers.serialize(
      object.toleranceBufferM,
      specifiedType: const FullType(ToleranceBufferM),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GiRegionVersionIn object, {
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
    required GiRegionVersionInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attribution = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GiRegionVersionInConfidenceEnum),
          ) as GiRegionVersionInConfidenceEnum;
          result.confidence = valueDes;
          break;
        case r'effective_from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.effectiveFrom = valueDes;
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MultiPolygonGeoJSON),
          ) as MultiPolygonGeoJSON;
          result.geometry.replace(valueDes);
          break;
        case r'licence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licence = valueDes;
          break;
        case r'share_alike':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.shareAlike = valueDes;
          break;
        case r'source_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceRef = valueDes;
          break;
        case r'taluks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.taluks.replace(valueDes);
          break;
        case r'tolerance_buffer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ToleranceBufferM),
          ) as ToleranceBufferM;
          result.toleranceBufferM.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GiRegionVersionIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GiRegionVersionInBuilder();
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

/// How the outline was derived: official (registry or surveyed file), district_derived (admin boundaries, D-019) or fixture (test data, never for real checks).
class GiRegionVersionInConfidenceEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'official')
  static const GiRegionVersionInConfidenceEnum official =
      _$giRegionVersionInConfidenceEnum_official;
  @BuiltValueEnumConst(wireName: r'district_derived')
  static const GiRegionVersionInConfidenceEnum districtDerived =
      _$giRegionVersionInConfidenceEnum_districtDerived;
  @BuiltValueEnumConst(wireName: r'fixture')
  static const GiRegionVersionInConfidenceEnum fixture =
      _$giRegionVersionInConfidenceEnum_fixture;

  static Serializer<GiRegionVersionInConfidenceEnum> get serializer =>
      _$giRegionVersionInConfidenceEnumSerializer;

  const GiRegionVersionInConfidenceEnum._(String name) : super(name);

  static BuiltSet<GiRegionVersionInConfidenceEnum> get values =>
      _$giRegionVersionInConfidenceEnumValues;
  static GiRegionVersionInConfidenceEnum valueOf(String name) =>
      _$giRegionVersionInConfidenceEnumValueOf(name);
}
