//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assist_start_in.g.dart';

/// Start entering data on a farmer's behalf; `client_id` becomes the assist session id (D-005).
///
/// Properties:
/// * [clientId] - UUIDv7 generated on the device; resending it is a no-op.
/// * [farmerId] - Farmer being assisted; must be in the officer's FPO.
/// * [startedAt] - Device time the session started (offline start); defaults to server time.
/// * [startedGps] - Where the session started, if a fix was taken.
@BuiltValue()
abstract class AssistStartIn
    implements Built<AssistStartIn, AssistStartInBuilder> {
  /// UUIDv7 generated on the device; resending it is a no-op.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Farmer being assisted; must be in the officer's FPO.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// Device time the session started (offline start); defaults to server time.
  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  /// Where the session started, if a fix was taken.
  @BuiltValueField(wireName: r'started_gps')
  GeoPoint? get startedGps;

  AssistStartIn._();

  factory AssistStartIn([void updates(AssistStartInBuilder b)]) =
      _$AssistStartIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssistStartInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssistStartIn> get serializer =>
      _$AssistStartInSerializer();
}

class _$AssistStartInSerializer implements PrimitiveSerializer<AssistStartIn> {
  @override
  final Iterable<Type> types = const [AssistStartIn, _$AssistStartIn];

  @override
  final String wireName = r'AssistStartIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssistStartIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.startedGps != null) {
      yield r'started_gps';
      yield serializers.serialize(
        object.startedGps,
        specifiedType: const FullType.nullable(GeoPoint),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AssistStartIn object, {
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
    required AssistStartInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'started_gps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GeoPoint),
          ) as GeoPoint?;
          if (valueDes == null) continue;
          result.startedGps.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssistStartIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssistStartInBuilder();
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
