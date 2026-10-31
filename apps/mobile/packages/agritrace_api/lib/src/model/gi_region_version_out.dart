//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gi_region_version_out.g.dart';

/// Metadata of one region version (the outline itself is served by GET /v1/gi-tags/{id}/region).
///
/// Properties:
/// * [confidence] - How the outline was derived.
/// * [effectiveFrom] - First day checks use it.
/// * [giTagId] - GI tag.
/// * [id] - Region version id.
/// * [licence] - Licence of the source data.
/// * [sourceRef] - Source dataset and build script reference, then `; attribution: …; share_alike: …`.
/// * [taluks] - Taluks this outline unions.
/// * [toleranceBufferM] - GPS-drift buffer in metres.
/// * [versionNo] - Version number, 0 upwards.
@BuiltValue()
abstract class GiRegionVersionOut
    implements Built<GiRegionVersionOut, GiRegionVersionOutBuilder> {
  /// How the outline was derived.
  @BuiltValueField(wireName: r'confidence')
  String get confidence;

  /// First day checks use it.
  @BuiltValueField(wireName: r'effective_from')
  Date get effectiveFrom;

  /// GI tag.
  @BuiltValueField(wireName: r'gi_tag_id')
  String get giTagId;

  /// Region version id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Licence of the source data.
  @BuiltValueField(wireName: r'licence')
  String get licence;

  /// Source dataset and build script reference, then `; attribution: …; share_alike: …`.
  @BuiltValueField(wireName: r'source_ref')
  String get sourceRef;

  /// Taluks this outline unions.
  @BuiltValueField(wireName: r'taluks')
  BuiltList<String>? get taluks;

  /// GPS-drift buffer in metres.
  @BuiltValueField(wireName: r'tolerance_buffer_m')
  String get toleranceBufferM;

  /// Version number, 0 upwards.
  @BuiltValueField(wireName: r'version_no')
  int get versionNo;

  GiRegionVersionOut._();

  factory GiRegionVersionOut([void updates(GiRegionVersionOutBuilder b)]) =
      _$GiRegionVersionOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GiRegionVersionOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GiRegionVersionOut> get serializer =>
      _$GiRegionVersionOutSerializer();
}

class _$GiRegionVersionOutSerializer
    implements PrimitiveSerializer<GiRegionVersionOut> {
  @override
  final Iterable<Type> types = const [GiRegionVersionOut, _$GiRegionVersionOut];

  @override
  final String wireName = r'GiRegionVersionOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GiRegionVersionOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'confidence';
    yield serializers.serialize(
      object.confidence,
      specifiedType: const FullType(String),
    );
    yield r'effective_from';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(Date),
    );
    yield r'gi_tag_id';
    yield serializers.serialize(
      object.giTagId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'licence';
    yield serializers.serialize(
      object.licence,
      specifiedType: const FullType(String),
    );
    yield r'source_ref';
    yield serializers.serialize(
      object.sourceRef,
      specifiedType: const FullType(String),
    );
    yield r'taluks';
    yield object.taluks == null
        ? null
        : serializers.serialize(
            object.taluks,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          );
    yield r'tolerance_buffer_m';
    yield serializers.serialize(
      object.toleranceBufferM,
      specifiedType: const FullType(String),
    );
    yield r'version_no';
    yield serializers.serialize(
      object.versionNo,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GiRegionVersionOut object, {
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
    required GiRegionVersionOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.confidence = valueDes;
          break;
        case r'effective_from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.effectiveFrom = valueDes;
          break;
        case r'gi_tag_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.giTagId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'licence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licence = valueDes;
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
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.taluks.replace(valueDes);
          break;
        case r'tolerance_buffer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toleranceBufferM = valueDes;
          break;
        case r'version_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.versionNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GiRegionVersionOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GiRegionVersionOutBuilder();
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
