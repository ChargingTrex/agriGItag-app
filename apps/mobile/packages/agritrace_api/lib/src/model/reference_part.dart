//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reference_part.g.dart';

/// A changed bundle part with its body.
///
/// Properties:
/// * [body] - The part body, as `GET /v1/sync/bundle/{part}` returns it.
/// * [etag] - Strong ETag of the part body; send it in `If-None-Match` for a 304.
/// * [version] - Part version: from `reference_versions` for database-fed parts (only grows), a content fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`.
@BuiltValue()
abstract class ReferencePart
    implements Built<ReferencePart, ReferencePartBuilder> {
  /// The part body, as `GET /v1/sync/bundle/{part}` returns it.
  @BuiltValueField(wireName: r'body')
  BuiltMap<String, JsonObject?> get body;

  /// Strong ETag of the part body; send it in `If-None-Match` for a 304.
  @BuiltValueField(wireName: r'etag')
  String get etag;

  /// Part version: from `reference_versions` for database-fed parts (only grows), a content fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`.
  @BuiltValueField(wireName: r'version')
  int get version;

  ReferencePart._();

  factory ReferencePart([void updates(ReferencePartBuilder b)]) =
      _$ReferencePart;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReferencePartBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReferencePart> get serializer =>
      _$ReferencePartSerializer();
}

class _$ReferencePartSerializer implements PrimitiveSerializer<ReferencePart> {
  @override
  final Iterable<Type> types = const [ReferencePart, _$ReferencePart];

  @override
  final String wireName = r'ReferencePart';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReferencePart object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
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
    ReferencePart object, {
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
    required ReferencePartBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.body.replace(valueDes);
          break;
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
  ReferencePart deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReferencePartBuilder();
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
