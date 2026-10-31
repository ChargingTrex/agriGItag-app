//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audit_row.g.dart';

/// One `audit_log` row; device id and GPS columns are left out, location values in `diff` are hidden.
///
/// Properties:
/// * [action] - `create`, `update`, `delete` or a named action such as `event.correct`.
/// * [actorUserId] - User who made the change; null for system jobs.
/// * [assistSessionId] - Assist session in force, if any.
/// * [at] - When the change was written (UTC).
/// * [diff] - What changed, as stored; secret columns read `[redacted]`, location, boundary and land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, ...) read `[hidden]`.
/// * [entityId] - Primary key of the changed row.
/// * [entityType] - Table name of the changed row, e.g. `farmers`, `event_versions`.
/// * [id] - Audit row id (UUIDv7, time-ordered).
/// * [onBehalfOfFarmerId] - Farmer the actor entered data for.
/// * [requestId] - Request id for correlating with API logs.
@BuiltValue()
abstract class AuditRow implements Built<AuditRow, AuditRowBuilder> {
  /// `create`, `update`, `delete` or a named action such as `event.correct`.
  @BuiltValueField(wireName: r'action')
  String get action;

  /// User who made the change; null for system jobs.
  @BuiltValueField(wireName: r'actor_user_id')
  String? get actorUserId;

  /// Assist session in force, if any.
  @BuiltValueField(wireName: r'assist_session_id')
  String? get assistSessionId;

  /// When the change was written (UTC).
  @BuiltValueField(wireName: r'at')
  DateTime get at;

  /// What changed, as stored; secret columns read `[redacted]`, location, boundary and land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, ...) read `[hidden]`.
  @BuiltValueField(wireName: r'diff')
  BuiltMap<String, JsonObject?> get diff;

  /// Primary key of the changed row.
  @BuiltValueField(wireName: r'entity_id')
  String? get entityId;

  /// Table name of the changed row, e.g. `farmers`, `event_versions`.
  @BuiltValueField(wireName: r'entity_type')
  String get entityType;

  /// Audit row id (UUIDv7, time-ordered).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Farmer the actor entered data for.
  @BuiltValueField(wireName: r'on_behalf_of_farmer_id')
  String? get onBehalfOfFarmerId;

  /// Request id for correlating with API logs.
  @BuiltValueField(wireName: r'request_id')
  String? get requestId;

  AuditRow._();

  factory AuditRow([void updates(AuditRowBuilder b)]) = _$AuditRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuditRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuditRow> get serializer => _$AuditRowSerializer();
}

class _$AuditRowSerializer implements PrimitiveSerializer<AuditRow> {
  @override
  final Iterable<Type> types = const [AuditRow, _$AuditRow];

  @override
  final String wireName = r'AuditRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuditRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'actor_user_id';
    yield object.actorUserId == null
        ? null
        : serializers.serialize(
            object.actorUserId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'assist_session_id';
    yield object.assistSessionId == null
        ? null
        : serializers.serialize(
            object.assistSessionId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'at';
    yield serializers.serialize(
      object.at,
      specifiedType: const FullType(DateTime),
    );
    yield r'diff';
    yield serializers.serialize(
      object.diff,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'entity_id';
    yield object.entityId == null
        ? null
        : serializers.serialize(
            object.entityId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'on_behalf_of_farmer_id';
    yield object.onBehalfOfFarmerId == null
        ? null
        : serializers.serialize(
            object.onBehalfOfFarmerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'request_id';
    yield object.requestId == null
        ? null
        : serializers.serialize(
            object.requestId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuditRow object, {
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
    required AuditRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'actor_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorUserId = valueDes;
          break;
        case r'assist_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assistSessionId = valueDes;
          break;
        case r'at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.at = valueDes;
          break;
        case r'diff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.diff.replace(valueDes);
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityId = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityType = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'on_behalf_of_farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.onBehalfOfFarmerId = valueDes;
          break;
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuditRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuditRowBuilder();
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
