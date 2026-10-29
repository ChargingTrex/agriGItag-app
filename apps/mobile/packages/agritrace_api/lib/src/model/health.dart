//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health.g.dart';

/// Status of each dependency: `ok` or `error: <ExceptionClass>` (details go to the server log only).
///
/// Properties:
/// * [db] - Postgres: `ok` after `SELECT 1`, else `error: <ExceptionClass>`.
/// * [redis] - Valkey/Redis: `ok` after `PING`, else `error: <ExceptionClass>`.
/// * [s3] - S3: `ok` after HEAD on the evidence bucket, else `error: <ExceptionClass>`.
@BuiltValue()
abstract class Health implements Built<Health, HealthBuilder> {
  /// Postgres: `ok` after `SELECT 1`, else `error: <ExceptionClass>`.
  @BuiltValueField(wireName: r'db')
  String get db;

  /// Valkey/Redis: `ok` after `PING`, else `error: <ExceptionClass>`.
  @BuiltValueField(wireName: r'redis')
  String get redis;

  /// S3: `ok` after HEAD on the evidence bucket, else `error: <ExceptionClass>`.
  @BuiltValueField(wireName: r's3')
  String get s3;

  Health._();

  factory Health([void updates(HealthBuilder b)]) = _$Health;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Health> get serializer => _$HealthSerializer();
}

class _$HealthSerializer implements PrimitiveSerializer<Health> {
  @override
  final Iterable<Type> types = const [Health, _$Health];

  @override
  final String wireName = r'Health';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Health object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'db';
    yield serializers.serialize(
      object.db,
      specifiedType: const FullType(String),
    );
    yield r'redis';
    yield serializers.serialize(
      object.redis,
      specifiedType: const FullType(String),
    );
    yield r's3';
    yield serializers.serialize(
      object.s3,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Health object, {
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
    required HealthBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'db':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.db = valueDes;
          break;
        case r'redis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.redis = valueDes;
          break;
        case r's3':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.s3 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Health deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthBuilder();
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
