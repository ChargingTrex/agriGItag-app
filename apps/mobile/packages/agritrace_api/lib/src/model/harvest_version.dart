//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/harvest_payload.dart';
import 'package:agritrace_api/src/model/event_subject.dart';
import 'package:agritrace_api/src/model/photo_in.dart';
import 'package:agritrace_api/src/model/three_clocks.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'harvest_version.g.dart';

/// Version of a harvest round (Stage 4).
///
/// Properties:
/// * [batchId] - Batch of a processing event.
/// * [changeKind] - `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
/// * [clocks] - Device and GPS clocks at capture; the server adds its own.
/// * [eventId] - Client id of the event, stable across its versions (D-005).
/// * [eventType] - Always `harvest` for this variant (discriminator).
/// * [gps] - Device position at submission (FR26).
/// * [instanceNo] - 1-based instance of this type on the subject (FR3).
/// * [lotId] - Lot of a farm event; exactly one of lot/batch.
/// * [occurredEndOn] - End date of a span such as drying.
/// * [occurredOn] - Date the activity happened (or started), YYYY-MM-DD.
/// * [payload] - Harvest fields.
/// * [photos] - Evidence photos (FR3, FR61).
/// * [plotId] - Plot where a farm event happened (FR69 GPS check).
/// * [reasonCode] - Coded reason; required for `correct` (422 `reason_required`).
/// * [reasonText] - Free-text reason or comment (FR59).
/// * [subjectType] - `lot` for farm events, `batch` for processing events.
/// * [versionNo] - 1 for a new event; each later version must be max + 1.
@BuiltValue()
abstract class HarvestVersion
    implements Built<HarvestVersion, HarvestVersionBuilder> {
  /// Batch of a processing event.
  @BuiltValueField(wireName: r'batch_id')
  String? get batchId;

  /// `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
  @BuiltValueField(wireName: r'change_kind')
  HarvestVersionChangeKindEnum? get changeKind;
  // enum changeKindEnum {  create,  correct,  undo,  };

  /// Device and GPS clocks at capture; the server adds its own.
  @BuiltValueField(wireName: r'clocks')
  ThreeClocks get clocks;

  /// Client id of the event, stable across its versions (D-005).
  @BuiltValueField(wireName: r'event_id')
  String get eventId;

  /// Always `harvest` for this variant (discriminator).
  @BuiltValueField(wireName: r'event_type')
  HarvestVersionEventTypeEnum get eventType;
  // enum eventTypeEnum {  harvest,  };

  /// Device position at submission (FR26).
  @BuiltValueField(wireName: r'gps')
  GeoPoint? get gps;

  /// 1-based instance of this type on the subject (FR3).
  @BuiltValueField(wireName: r'instance_no')
  int? get instanceNo;

  /// Lot of a farm event; exactly one of lot/batch.
  @BuiltValueField(wireName: r'lot_id')
  String? get lotId;

  /// End date of a span such as drying.
  @BuiltValueField(wireName: r'occurred_end_on')
  Date? get occurredEndOn;

  /// Date the activity happened (or started), YYYY-MM-DD.
  @BuiltValueField(wireName: r'occurred_on')
  Date get occurredOn;

  /// Harvest fields.
  @BuiltValueField(wireName: r'payload')
  HarvestPayload get payload;

  /// Evidence photos (FR3, FR61).
  @BuiltValueField(wireName: r'photos')
  BuiltList<PhotoIn>? get photos;

  /// Plot where a farm event happened (FR69 GPS check).
  @BuiltValueField(wireName: r'plot_id')
  String? get plotId;

  /// Coded reason; required for `correct` (422 `reason_required`).
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// Free-text reason or comment (FR59).
  @BuiltValueField(wireName: r'reason_text')
  String? get reasonText;

  /// `lot` for farm events, `batch` for processing events.
  @BuiltValueField(wireName: r'subject_type')
  EventSubject get subjectType;
  // enum subjectTypeEnum {  lot,  batch,  };

  /// 1 for a new event; each later version must be max + 1.
  @BuiltValueField(wireName: r'version_no')
  int get versionNo;

  HarvestVersion._();

  factory HarvestVersion([void updates(HarvestVersionBuilder b)]) =
      _$HarvestVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HarvestVersionBuilder b) => b
    ..changeKind = HarvestVersionChangeKindEnum.valueOf('create')
    ..instanceNo = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<HarvestVersion> get serializer =>
      _$HarvestVersionSerializer();
}

class _$HarvestVersionSerializer
    implements PrimitiveSerializer<HarvestVersion> {
  @override
  final Iterable<Type> types = const [HarvestVersion, _$HarvestVersion];

  @override
  final String wireName = r'HarvestVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HarvestVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.batchId != null) {
      yield r'batch_id';
      yield serializers.serialize(
        object.batchId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.changeKind != null) {
      yield r'change_kind';
      yield serializers.serialize(
        object.changeKind,
        specifiedType: const FullType(HarvestVersionChangeKindEnum),
      );
    }
    yield r'clocks';
    yield serializers.serialize(
      object.clocks,
      specifiedType: const FullType(ThreeClocks),
    );
    yield r'event_id';
    yield serializers.serialize(
      object.eventId,
      specifiedType: const FullType(String),
    );
    yield r'event_type';
    yield serializers.serialize(
      object.eventType,
      specifiedType: const FullType(HarvestVersionEventTypeEnum),
    );
    if (object.gps != null) {
      yield r'gps';
      yield serializers.serialize(
        object.gps,
        specifiedType: const FullType.nullable(GeoPoint),
      );
    }
    if (object.instanceNo != null) {
      yield r'instance_no';
      yield serializers.serialize(
        object.instanceNo,
        specifiedType: const FullType(int),
      );
    }
    if (object.lotId != null) {
      yield r'lot_id';
      yield serializers.serialize(
        object.lotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.occurredEndOn != null) {
      yield r'occurred_end_on';
      yield serializers.serialize(
        object.occurredEndOn,
        specifiedType: const FullType.nullable(Date),
      );
    }
    yield r'occurred_on';
    yield serializers.serialize(
      object.occurredOn,
      specifiedType: const FullType(Date),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(HarvestPayload),
    );
    if (object.photos != null) {
      yield r'photos';
      yield serializers.serialize(
        object.photos,
        specifiedType: const FullType(BuiltList, [FullType(PhotoIn)]),
      );
    }
    if (object.plotId != null) {
      yield r'plot_id';
      yield serializers.serialize(
        object.plotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonText != null) {
      yield r'reason_text';
      yield serializers.serialize(
        object.reasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'subject_type';
    yield serializers.serialize(
      object.subjectType,
      specifiedType: const FullType(EventSubject),
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
    HarvestVersion object, {
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
    required HarvestVersionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.batchId = valueDes;
          break;
        case r'change_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(HarvestVersionChangeKindEnum),
          ) as HarvestVersionChangeKindEnum?;
          if (valueDes == null) continue;
          result.changeKind = valueDes;
          break;
        case r'clocks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreeClocks),
          ) as ThreeClocks;
          result.clocks.replace(valueDes);
          break;
        case r'event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventId = valueDes;
          break;
        case r'event_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HarvestVersionEventTypeEnum),
          ) as HarvestVersionEventTypeEnum;
          result.eventType = valueDes;
          break;
        case r'gps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GeoPoint),
          ) as GeoPoint?;
          if (valueDes == null) continue;
          result.gps.replace(valueDes);
          break;
        case r'instance_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.instanceNo = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lotId = valueDes;
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
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HarvestPayload),
          ) as HarvestPayload;
          result.payload.replace(valueDes);
          break;
        case r'photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(PhotoIn)]),
          ) as BuiltList<PhotoIn>?;
          if (valueDes == null) continue;
          result.photos.replace(valueDes);
          break;
        case r'plot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.plotId = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonText = valueDes;
          break;
        case r'subject_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EventSubject),
          ) as EventSubject;
          result.subjectType = valueDes;
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
  HarvestVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HarvestVersionBuilder();
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

/// `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
class HarvestVersionChangeKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'create')
  static const HarvestVersionChangeKindEnum create =
      _$harvestVersionChangeKindEnum_create;
  @BuiltValueEnumConst(wireName: r'correct')
  static const HarvestVersionChangeKindEnum correct =
      _$harvestVersionChangeKindEnum_correct;
  @BuiltValueEnumConst(wireName: r'undo')
  static const HarvestVersionChangeKindEnum undo =
      _$harvestVersionChangeKindEnum_undo;

  static Serializer<HarvestVersionChangeKindEnum> get serializer =>
      _$harvestVersionChangeKindEnumSerializer;

  const HarvestVersionChangeKindEnum._(String name) : super(name);

  static BuiltSet<HarvestVersionChangeKindEnum> get values =>
      _$harvestVersionChangeKindEnumValues;
  static HarvestVersionChangeKindEnum valueOf(String name) =>
      _$harvestVersionChangeKindEnumValueOf(name);
}

/// Always `harvest` for this variant (discriminator).
class HarvestVersionEventTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'harvest')
  static const HarvestVersionEventTypeEnum harvest =
      _$harvestVersionEventTypeEnum_harvest;

  static Serializer<HarvestVersionEventTypeEnum> get serializer =>
      _$harvestVersionEventTypeEnumSerializer;

  const HarvestVersionEventTypeEnum._(String name) : super(name);

  static BuiltSet<HarvestVersionEventTypeEnum> get values =>
      _$harvestVersionEventTypeEnumValues;
  static HarvestVersionEventTypeEnum valueOf(String name) =>
      _$harvestVersionEventTypeEnumValueOf(name);
}
