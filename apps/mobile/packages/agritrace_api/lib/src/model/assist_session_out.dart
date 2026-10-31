//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assist_session_out.g.dart';

/// An assist session; send its `id` as `X-Assist-Session` on every request made for the farmer.
///
/// Properties:
/// * [endedAt] - When it ended; null while open.
/// * [farmerId] - Farmer being assisted.
/// * [id] - Assist session id (the client id it was started with).
/// * [officerUserId] - Field officer doing the entries.
/// * [startedAt] - When the session started.
@BuiltValue()
abstract class AssistSessionOut
    implements Built<AssistSessionOut, AssistSessionOutBuilder> {
  /// When it ended; null while open.
  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  /// Farmer being assisted.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// Assist session id (the client id it was started with).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Field officer doing the entries.
  @BuiltValueField(wireName: r'officer_user_id')
  String get officerUserId;

  /// When the session started.
  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  AssistSessionOut._();

  factory AssistSessionOut([void updates(AssistSessionOutBuilder b)]) =
      _$AssistSessionOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssistSessionOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssistSessionOut> get serializer =>
      _$AssistSessionOutSerializer();
}

class _$AssistSessionOutSerializer
    implements PrimitiveSerializer<AssistSessionOut> {
  @override
  final Iterable<Type> types = const [AssistSessionOut, _$AssistSessionOut];

  @override
  final String wireName = r'AssistSessionOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssistSessionOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ended_at';
    yield object.endedAt == null
        ? null
        : serializers.serialize(
            object.endedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'officer_user_id';
    yield serializers.serialize(
      object.officerUserId,
      specifiedType: const FullType(String),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AssistSessionOut object, {
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
    required AssistSessionOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'officer_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.officerUserId = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssistSessionOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssistSessionOutBuilder();
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
