//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/event_photo_out.dart';
import 'package:agritrace_api/src/model/change_kind.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/event_status.dart';
import 'package:agritrace_api/src/model/event_type.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_out.g.dart';

/// One event with its latest version, lean for 2G timelines (FR63).
///
/// Properties:
/// * [changeKind] - How the latest version came about.
/// * [enteredByUserId] - Who entered the latest version.
/// * [eventType] - Event type.
/// * [id] - Event id.
/// * [instanceNo] - Instance of this type on the lot.
/// * [isSystemGenerated] - True for platform entries (FR59).
/// * [occurredEndOn] - End date for spans.
/// * [occurredOn] - Date of the latest version.
/// * [onBehalfOfFarmerId] - Farmer assisted, in assist mode.
/// * [payload] - Typed payload of the latest version (D-014).
/// * [photos] - Photos of the latest version.
/// * [reasonCode] - Reason of a correction or undo.
/// * [status] - submitted, undone, ... (FR59).
/// * [versionNo] - Number of the latest version.
@BuiltValue()
abstract class EventOut implements Built<EventOut, EventOutBuilder> {
  /// How the latest version came about.
  @BuiltValueField(wireName: r'change_kind')
  ChangeKind get changeKind;
  // enum changeKindEnum {  create,  correct,  undo,  system,  };

  /// Who entered the latest version.
  @BuiltValueField(wireName: r'entered_by_user_id')
  String get enteredByUserId;

  /// Event type.
  @BuiltValueField(wireName: r'event_type')
  EventType get eventType;
  // enum eventTypeEnum {  land_preparation,  nursery,  sowing,  input_application,  harvest,  drying,  packing,  problem,  intake,  grading,  final_packing,  };

  /// Event id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Instance of this type on the lot.
  @BuiltValueField(wireName: r'instance_no')
  int get instanceNo;

  /// True for platform entries (FR59).
  @BuiltValueField(wireName: r'is_system_generated')
  bool get isSystemGenerated;

  /// End date for spans.
  @BuiltValueField(wireName: r'occurred_end_on')
  Date? get occurredEndOn;

  /// Date of the latest version.
  @BuiltValueField(wireName: r'occurred_on')
  Date get occurredOn;

  /// Farmer assisted, in assist mode.
  @BuiltValueField(wireName: r'on_behalf_of_farmer_id')
  String? get onBehalfOfFarmerId;

  /// Typed payload of the latest version (D-014).
  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?> get payload;

  /// Photos of the latest version.
  @BuiltValueField(wireName: r'photos')
  BuiltList<EventPhotoOut> get photos;

  /// Reason of a correction or undo.
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// submitted, undone, ... (FR59).
  @BuiltValueField(wireName: r'status')
  EventStatus get status;
  // enum statusEnum {  draft,  submitted,  undone,  superseded,  locked,  };

  /// Number of the latest version.
  @BuiltValueField(wireName: r'version_no')
  int get versionNo;

  EventOut._();

  factory EventOut([void updates(EventOutBuilder b)]) = _$EventOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventOut> get serializer => _$EventOutSerializer();
}

class _$EventOutSerializer implements PrimitiveSerializer<EventOut> {
  @override
  final Iterable<Type> types = const [EventOut, _$EventOut];

  @override
  final String wireName = r'EventOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'change_kind';
    yield serializers.serialize(
      object.changeKind,
      specifiedType: const FullType(ChangeKind),
    );
    yield r'entered_by_user_id';
    yield serializers.serialize(
      object.enteredByUserId,
      specifiedType: const FullType(String),
    );
    yield r'event_type';
    yield serializers.serialize(
      object.eventType,
      specifiedType: const FullType(EventType),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'instance_no';
    yield serializers.serialize(
      object.instanceNo,
      specifiedType: const FullType(int),
    );
    yield r'is_system_generated';
    yield serializers.serialize(
      object.isSystemGenerated,
      specifiedType: const FullType(bool),
    );
    yield r'occurred_end_on';
    yield object.occurredEndOn == null
        ? null
        : serializers.serialize(
            object.occurredEndOn,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'occurred_on';
    yield serializers.serialize(
      object.occurredOn,
      specifiedType: const FullType(Date),
    );
    yield r'on_behalf_of_farmer_id';
    yield object.onBehalfOfFarmerId == null
        ? null
        : serializers.serialize(
            object.onBehalfOfFarmerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'photos';
    yield serializers.serialize(
      object.photos,
      specifiedType: const FullType(BuiltList, [FullType(EventPhotoOut)]),
    );
    yield r'reason_code';
    yield object.reasonCode == null
        ? null
        : serializers.serialize(
            object.reasonCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EventStatus),
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
    EventOut object, {
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
    required EventOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'change_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChangeKind),
          ) as ChangeKind;
          result.changeKind = valueDes;
          break;
        case r'entered_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.enteredByUserId = valueDes;
          break;
        case r'event_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EventType),
          ) as EventType;
          result.eventType = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'instance_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.instanceNo = valueDes;
          break;
        case r'is_system_generated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSystemGenerated = valueDes;
          break;
        case r'occurred_end_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.occurredEndOn = valueDes;
          break;
        case r'occurred_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.occurredOn = valueDes;
          break;
        case r'on_behalf_of_farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.onBehalfOfFarmerId = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.payload.replace(valueDes);
          break;
        case r'photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EventPhotoOut)]),
          ) as BuiltList<EventPhotoOut>;
          result.photos.replace(valueDes);
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EventStatus),
          ) as EventStatus;
          result.status = valueDes;
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
  EventOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventOutBuilder();
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
