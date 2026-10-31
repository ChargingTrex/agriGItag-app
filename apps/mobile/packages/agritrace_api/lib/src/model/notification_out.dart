//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/notification_status.dart';
import 'package:agritrace_api/src/model/notification_channel.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_out.g.dart';

/// One message sent (or attempted) to the caller.
///
/// Properties:
/// * [channel] - push, sms, whatsapp or console.
/// * [createdAt] - When the message was queued, ISO 8601 UTC.
/// * [id] - Notification id (UUIDv7, so newer ids sort later).
/// * [lang] - Language the message was rendered in: `ta` or `en`.
/// * [payload] - Template variables; secrets (the OTP code) appear as `***`.
/// * [status] - queued, sent or failed.
/// * [templateKey] - Template, e.g. `harvest_reminder`; the app may show its own text.
@BuiltValue()
abstract class NotificationOut
    implements Built<NotificationOut, NotificationOutBuilder> {
  /// push, sms, whatsapp or console.
  @BuiltValueField(wireName: r'channel')
  NotificationChannel get channel;
  // enum channelEnum {  push,  sms,  whatsapp,  console,  };

  /// When the message was queued, ISO 8601 UTC.
  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  /// Notification id (UUIDv7, so newer ids sort later).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Language the message was rendered in: `ta` or `en`.
  @BuiltValueField(wireName: r'lang')
  String get lang;

  /// Template variables; secrets (the OTP code) appear as `***`.
  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?> get payload;

  /// queued, sent or failed.
  @BuiltValueField(wireName: r'status')
  NotificationStatus get status;
  // enum statusEnum {  queued,  sent,  failed,  };

  /// Template, e.g. `harvest_reminder`; the app may show its own text.
  @BuiltValueField(wireName: r'template_key')
  String get templateKey;

  NotificationOut._();

  factory NotificationOut([void updates(NotificationOutBuilder b)]) =
      _$NotificationOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationOut> get serializer =>
      _$NotificationOutSerializer();
}

class _$NotificationOutSerializer
    implements PrimitiveSerializer<NotificationOut> {
  @override
  final Iterable<Type> types = const [NotificationOut, _$NotificationOut];

  @override
  final String wireName = r'NotificationOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'channel';
    yield serializers.serialize(
      object.channel,
      specifiedType: const FullType(NotificationChannel),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lang';
    yield serializers.serialize(
      object.lang,
      specifiedType: const FullType(String),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(NotificationStatus),
    );
    yield r'template_key';
    yield serializers.serialize(
      object.templateKey,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationOut object, {
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
    required NotificationOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationChannel),
          ) as NotificationChannel;
          result.channel = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lang = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.payload.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationStatus),
          ) as NotificationStatus;
          result.status = valueDes;
          break;
        case r'template_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.templateKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationOutBuilder();
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
