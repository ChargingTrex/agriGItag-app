//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/grading_version.dart';
import 'package:agritrace_api/src/model/sowing_version.dart';
import 'package:agritrace_api/src/model/packing_version.dart';
import 'package:agritrace_api/src/model/drying_version.dart';
import 'package:agritrace_api/src/model/final_packing_version.dart';
import 'package:agritrace_api/src/model/event_subject.dart';
import 'package:agritrace_api/src/model/input_application_version.dart';
import 'package:agritrace_api/src/model/three_clocks.dart';
import 'package:agritrace_api/src/model/land_preparation_version.dart';
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/harvest_version.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/final_packing_payload.dart';
import 'package:agritrace_api/src/model/photo_in.dart';
import 'package:agritrace_api/src/model/intake_version.dart';
import 'package:agritrace_api/src/model/nursery_version.dart';
import 'package:agritrace_api/src/model/problem_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'data.g.dart';

/// The full corrected version; `change_kind` must be `correct`.
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
abstract class Data implements Built<Data, DataBuilder> {
  /// One Of [DryingVersion], [FinalPackingVersion], [GradingVersion], [HarvestVersion], [InputApplicationVersion], [IntakeVersion], [LandPreparationVersion], [NurseryVersion], [PackingVersion], [ProblemVersion], [SowingVersion]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'event_type';

  static const Map<String, Type> discriminatorMapping = {
    r'drying': DryingVersion,
    r'final_packing': FinalPackingVersion,
    r'grading': GradingVersion,
    r'harvest': HarvestVersion,
    r'input_application': InputApplicationVersion,
    r'intake': IntakeVersion,
    r'land_preparation': LandPreparationVersion,
    r'nursery': NurseryVersion,
    r'packing': PackingVersion,
    r'problem': ProblemVersion,
    r'sowing': SowingVersion,
  };

  Data._();

  factory Data([void updates(DataBuilder b)]) = _$Data;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Data> get serializer => _$DataSerializer();
}

extension DataDiscriminatorExt on Data {
  String? get discriminatorValue {
    if (this is DryingVersion) {
      return r'drying';
    }
    if (this is FinalPackingVersion) {
      return r'final_packing';
    }
    if (this is GradingVersion) {
      return r'grading';
    }
    if (this is HarvestVersion) {
      return r'harvest';
    }
    if (this is InputApplicationVersion) {
      return r'input_application';
    }
    if (this is IntakeVersion) {
      return r'intake';
    }
    if (this is LandPreparationVersion) {
      return r'land_preparation';
    }
    if (this is NurseryVersion) {
      return r'nursery';
    }
    if (this is PackingVersion) {
      return r'packing';
    }
    if (this is ProblemVersion) {
      return r'problem';
    }
    if (this is SowingVersion) {
      return r'sowing';
    }
    return null;
  }
}

extension DataBuilderDiscriminatorExt on DataBuilder {
  String? get discriminatorValue {
    if (this is DryingVersionBuilder) {
      return r'drying';
    }
    if (this is FinalPackingVersionBuilder) {
      return r'final_packing';
    }
    if (this is GradingVersionBuilder) {
      return r'grading';
    }
    if (this is HarvestVersionBuilder) {
      return r'harvest';
    }
    if (this is InputApplicationVersionBuilder) {
      return r'input_application';
    }
    if (this is IntakeVersionBuilder) {
      return r'intake';
    }
    if (this is LandPreparationVersionBuilder) {
      return r'land_preparation';
    }
    if (this is NurseryVersionBuilder) {
      return r'nursery';
    }
    if (this is PackingVersionBuilder) {
      return r'packing';
    }
    if (this is ProblemVersionBuilder) {
      return r'problem';
    }
    if (this is SowingVersionBuilder) {
      return r'sowing';
    }
    return null;
  }
}

class _$DataSerializer implements PrimitiveSerializer<Data> {
  @override
  final Iterable<Type> types = const [Data, _$Data];

  @override
  final String wireName = r'Data';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Data object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Data object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  Data deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DataBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(Data.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex],
        specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [
      DryingVersion,
      FinalPackingVersion,
      GradingVersion,
      HarvestVersion,
      InputApplicationVersion,
      IntakeVersion,
      LandPreparationVersion,
      NurseryVersion,
      PackingVersion,
      ProblemVersion,
      SowingVersion,
    ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'drying':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(DryingVersion),
        ) as DryingVersion;
        oneOfType = DryingVersion;
        break;
      case r'final_packing':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(FinalPackingVersion),
        ) as FinalPackingVersion;
        oneOfType = FinalPackingVersion;
        break;
      case r'grading':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(GradingVersion),
        ) as GradingVersion;
        oneOfType = GradingVersion;
        break;
      case r'harvest':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(HarvestVersion),
        ) as HarvestVersion;
        oneOfType = HarvestVersion;
        break;
      case r'input_application':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(InputApplicationVersion),
        ) as InputApplicationVersion;
        oneOfType = InputApplicationVersion;
        break;
      case r'intake':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(IntakeVersion),
        ) as IntakeVersion;
        oneOfType = IntakeVersion;
        break;
      case r'land_preparation':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(LandPreparationVersion),
        ) as LandPreparationVersion;
        oneOfType = LandPreparationVersion;
        break;
      case r'nursery':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(NurseryVersion),
        ) as NurseryVersion;
        oneOfType = NurseryVersion;
        break;
      case r'packing':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(PackingVersion),
        ) as PackingVersion;
        oneOfType = PackingVersion;
        break;
      case r'problem':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ProblemVersion),
        ) as ProblemVersion;
        oneOfType = ProblemVersion;
        break;
      case r'sowing':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SowingVersion),
        ) as SowingVersion;
        oneOfType = SowingVersion;
        break;
      default:
        throw UnsupportedError(
            "Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(
        typeIndex: oneOfTypes.indexOf(oneOfType),
        types: oneOfTypes,
        value: oneOfResult);
    return result.build();
  }
}

/// `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after.
class DataChangeKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'create')
  static const DataChangeKindEnum create = _$dataChangeKindEnum_create;
  @BuiltValueEnumConst(wireName: r'correct')
  static const DataChangeKindEnum correct = _$dataChangeKindEnum_correct;
  @BuiltValueEnumConst(wireName: r'undo')
  static const DataChangeKindEnum undo = _$dataChangeKindEnum_undo;

  static Serializer<DataChangeKindEnum> get serializer =>
      _$dataChangeKindEnumSerializer;

  const DataChangeKindEnum._(String name) : super(name);

  static BuiltSet<DataChangeKindEnum> get values => _$dataChangeKindEnumValues;
  static DataChangeKindEnum valueOf(String name) =>
      _$dataChangeKindEnumValueOf(name);
}

/// Always `final_packing` for this variant (discriminator).
class DataEventTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'final_packing')
  static const DataEventTypeEnum finalPacking =
      _$dataEventTypeEnum_finalPacking;

  static Serializer<DataEventTypeEnum> get serializer =>
      _$dataEventTypeEnumSerializer;

  const DataEventTypeEnum._(String name) : super(name);

  static BuiltSet<DataEventTypeEnum> get values => _$dataEventTypeEnumValues;
  static DataEventTypeEnum valueOf(String name) =>
      _$dataEventTypeEnumValueOf(name);
}
