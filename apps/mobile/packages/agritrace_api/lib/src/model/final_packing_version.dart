//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/final_packing_payload.dart';
import 'package:agritrace_api/src/model/event_subject.dart';
import 'package:agritrace_api/src/model/photo_in.dart';
import 'package:agritrace_api/src/model/three_clocks.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'final_packing_version.g.dart';

/// Version of a batch final packing event (Stage 9).
///
/// Properties:
/// * [batchId] - Batch of a processing event.
/// * [changeKind] - `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
/// * [clocks] - Device and GPS clocks at capture; the server adds its own.
/// * [eventId] - Client id of the event, stable across its versions (D-005).
/// * [eventType] - Always `final_packing` for this variant (discriminator).
/// * [gps] - Device position at submission (FR26).
/// * [instanceNo] - 1-based instance of this type on the subject (FR3).
/// * [lotId] - Lot of a farm event; exactly one of lot/batch.
/// * [occurredEndOn] - End date of a span such as drying.
/// * [occurredOn] - Date the activity happened (or started), YYYY-MM-DD.
/// * [payload] - Final packing fields.
/// * [photos] - Evidence photos (FR3, FR61).
/// * [plotId] - Plot where a farm event happened (FR69 GPS check).
/// * [reasonCode] - Coded reason; required for `correct` (422 `reason_required`).
/// * [reasonText] - Free-text reason or comment (FR59).
/// * [subjectType] - `lot` for farm events, `batch` for processing events.
/// * [versionNo] - 1 for a new event; each later version must be max + 1.
@BuiltValue()
abstract class FinalPackingVersion
    implements Built<FinalPackingVersion, FinalPackingVersionBuilder> {
  /// Batch of a processing event.
  @BuiltValueField(wireName: r'batch_id')
  String? get batchId;

  /// `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
  @BuiltValueField(wireName: r'change_kind')
  FinalPackingVersionChangeKindEnum? get changeKind;
  // enum changeKindEnum {  create,  correct,  undo,  };

  /// Device and GPS clocks at capture; the server adds its own.
  @BuiltValueField(wireName: r'clocks')
  ThreeClocks get clocks;

  /// Client id of the event, stable across its versions (D-005).
  @BuiltValueField(wireName: r'event_id')
  String get eventId;

  /// Always `final_packing` for this variant (discriminator).
  @BuiltValueField(wireName: r'event_type')
  FinalPackingVersionEventTypeEnum get eventType;
  // enum eventTypeEnum {  final_packing,  };

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

  /// Final packing fields.
  @BuiltValueField(wireName: r'payload')
  FinalPackingPayload get payload;

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

  FinalPackingVersion._();

  factory FinalPackingVersion([void updates(FinalPackingVersionBuilder b)]) =
      _$FinalPackingVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinalPackingVersionBuilder b) => b
    ..changeKind = FinalPackingVersionChangeKindEnum.valueOf('create')
    ..instanceNo = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinalPackingVersion> get serializer =>
      _$FinalPackingVersionSerializer();
}

class _$FinalPackingVersionSerializer
    implements PrimitiveSerializer<FinalPackingVersion> {
  @override
  final Iterable<Type> types = const [
    FinalPackingVersion,
    _$FinalPackingVersion
  ];

  @override
  final String wireName = r'FinalPackingVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinalPackingVersion object, {
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
        specifiedType: const FullType(FinalPackingVersionChangeKindEnum),
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
      specifiedType: const FullType(FinalPackingVersionEventTypeEnum),
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
      specifiedType: const FullType(FinalPackingPayload),
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
    FinalPackingVersion object, {
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
    required FinalPackingVersionBuilder result,
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
                const FullType.nullable(FinalPackingVersionChangeKindEnum),
          ) as FinalPackingVersionChangeKindEnum?;
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
            specifiedType: const FullType(FinalPackingVersionEventTypeEnum),
          ) as FinalPackingVersionEventTypeEnum;
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
            specifiedType: const FullType(FinalPackingPayload),
          ) as FinalPackingPayload;
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
  FinalPackingVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinalPackingVersionBuilder();
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
class FinalPackingVersionChangeKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'create')
  static const FinalPackingVersionChangeKindEnum create =
      _$finalPackingVersionChangeKindEnum_create;
  @BuiltValueEnumConst(wireName: r'correct')
  static const FinalPackingVersionChangeKindEnum correct =
      _$finalPackingVersionChangeKindEnum_correct;
  @BuiltValueEnumConst(wireName: r'undo')
  static const FinalPackingVersionChangeKindEnum undo =
      _$finalPackingVersionChangeKindEnum_undo;

  static Serializer<FinalPackingVersionChangeKindEnum> get serializer =>
      _$finalPackingVersionChangeKindEnumSerializer;

  const FinalPackingVersionChangeKindEnum._(String name) : super(name);

  static BuiltSet<FinalPackingVersionChangeKindEnum> get values =>
      _$finalPackingVersionChangeKindEnumValues;
  static FinalPackingVersionChangeKindEnum valueOf(String name) =>
      _$finalPackingVersionChangeKindEnumValueOf(name);
}

/// Always `final_packing` for this variant (discriminator).
class FinalPackingVersionEventTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'final_packing')
  static const FinalPackingVersionEventTypeEnum finalPacking =
      _$finalPackingVersionEventTypeEnum_finalPacking;

  static Serializer<FinalPackingVersionEventTypeEnum> get serializer =>
      _$finalPackingVersionEventTypeEnumSerializer;

  const FinalPackingVersionEventTypeEnum._(String name) : super(name);

  static BuiltSet<FinalPackingVersionEventTypeEnum> get values =>
      _$finalPackingVersionEventTypeEnumValues;
  static FinalPackingVersionEventTypeEnum valueOf(String name) =>
      _$finalPackingVersionEventTypeEnumValueOf(name);
}
