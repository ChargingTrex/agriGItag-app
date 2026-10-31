//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/part_version.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bundle_manifest.g.dart';

/// Every bundle part available to the caller, with version and ETag (FR4, plan §13 C2).
///
/// Properties:
/// * [parts] - Part name -> version and ETag. `gi_region` is absent while no region is in effect.
@BuiltValue()
abstract class BundleManifest
    implements Built<BundleManifest, BundleManifestBuilder> {
  /// Part name -> version and ETag. `gi_region` is absent while no region is in effect.
  @BuiltValueField(wireName: r'parts')
  BuiltMap<String, PartVersion> get parts;

  BundleManifest._();

  factory BundleManifest([void updates(BundleManifestBuilder b)]) =
      _$BundleManifest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BundleManifestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BundleManifest> get serializer =>
      _$BundleManifestSerializer();
}

class _$BundleManifestSerializer
    implements PrimitiveSerializer<BundleManifest> {
  @override
  final Iterable<Type> types = const [BundleManifest, _$BundleManifest];

  @override
  final String wireName = r'BundleManifest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BundleManifest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'parts';
    yield serializers.serialize(
      object.parts,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(PartVersion)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BundleManifest object, {
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
    required BundleManifestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'parts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType(PartVersion)]),
          ) as BuiltMap<String, PartVersion>;
          result.parts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BundleManifest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BundleManifestBuilder();
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
