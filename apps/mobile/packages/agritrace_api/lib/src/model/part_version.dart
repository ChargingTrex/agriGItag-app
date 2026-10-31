//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'part_version.g.dart';

/// Version and ETag of one bundle part as the caller would download it now.
///
/// Properties:
/// * [etag] - Strong ETag of the part body; send it in `If-None-Match` for a 304.
/// * [version] - Part version: from `reference_versions` for database-fed parts (only grows), a content fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`.
@BuiltValue()
abstract class PartVersion implements Built<PartVersion, PartVersionBuilder> {
  /// Strong ETag of the part body; send it in `If-None-Match` for a 304.
  @BuiltValueField(wireName: r'etag')
  String get etag;

  /// Part version: from `reference_versions` for database-fed parts (only grows), a content fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`.
  @BuiltValueField(wireName: r'version')
  int get version;

  PartVersion._();

  factory PartVersion([void updates(PartVersionBuilder b)]) = _$PartVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PartVersionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PartVersion> get serializer => _$PartVersionSerializer();
}

class _$PartVersionSerializer implements PrimitiveSerializer<PartVersion> {
  @override
  final Iterable<Type> types = const [PartVersion, _$PartVersion];

  @override
  final String wireName = r'PartVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PartVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'etag';
    yield serializers.serialize(
      object.etag,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PartVersion object, {
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
    required PartVersionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'etag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.etag = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PartVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PartVersionBuilder();
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
