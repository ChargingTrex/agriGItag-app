//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/signed_quantity_output.dart';
import 'package:agritrace_api/src/model/reading_source.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quality_reading_out.g.dart';

/// A stored quality reading.
///
/// Properties:
/// * [batchId] - Batch measured.
/// * [calibrationDueOnAtTime] - Instrument's calibration due date when read.
/// * [fpoId] - Owning FPO.
/// * [id] - Reading id (= client_id).
/// * [instrumentId] - Instrument used.
/// * [labNablNo] - NABL number.
/// * [labName] - Laboratory name.
/// * [lotId] - Lot measured.
/// * [measuredAt] - When it was measured.
/// * [measuredByUserId] - Who measured.
/// * [measurement] - Value with its unit.
/// * [methodRef] - Test method reference.
/// * [parameterCode] - Parameter code.
/// * [profileVersionId] - Profile version it was checked against.
/// * [reasonCode] - Trail-override reason, if any.
/// * [sampleId] - Sample identifier.
/// * [serverReceivedAt] - When the server received it.
/// * [source_] - lab, instrument or visual.
/// * [stage] - Stage.
@BuiltValue()
abstract class QualityReadingOut
    implements Built<QualityReadingOut, QualityReadingOutBuilder> {
  /// Batch measured.
  @BuiltValueField(wireName: r'batch_id')
  String? get batchId;

  /// Instrument's calibration due date when read.
  @BuiltValueField(wireName: r'calibration_due_on_at_time')
  Date? get calibrationDueOnAtTime;

  /// Owning FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Reading id (= client_id).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Instrument used.
  @BuiltValueField(wireName: r'instrument_id')
  String? get instrumentId;

  /// NABL number.
  @BuiltValueField(wireName: r'lab_nabl_no')
  String? get labNablNo;

  /// Laboratory name.
  @BuiltValueField(wireName: r'lab_name')
  String? get labName;

  /// Lot measured.
  @BuiltValueField(wireName: r'lot_id')
  String? get lotId;

  /// When it was measured.
  @BuiltValueField(wireName: r'measured_at')
  DateTime get measuredAt;

  /// Who measured.
  @BuiltValueField(wireName: r'measured_by_user_id')
  String get measuredByUserId;

  /// Value with its unit.
  @BuiltValueField(wireName: r'measurement')
  SignedQuantityOutput get measurement;

  /// Test method reference.
  @BuiltValueField(wireName: r'method_ref')
  String? get methodRef;

  /// Parameter code.
  @BuiltValueField(wireName: r'parameter_code')
  String get parameterCode;

  /// Profile version it was checked against.
  @BuiltValueField(wireName: r'profile_version_id')
  String? get profileVersionId;

  /// Trail-override reason, if any.
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// Sample identifier.
  @BuiltValueField(wireName: r'sample_id')
  String? get sampleId;

  /// When the server received it.
  @BuiltValueField(wireName: r'server_received_at')
  DateTime get serverReceivedAt;

  /// lab, instrument or visual.
  @BuiltValueField(wireName: r'source')
  ReadingSource get source_;
  // enum source_Enum {  lab,  instrument,  visual,  };

  /// Stage.
  @BuiltValueField(wireName: r'stage')
  ReadingStage get stage;
  // enum stageEnum {  drying_end,  intake,  grading,  storage,  };

  QualityReadingOut._();

  factory QualityReadingOut([void updates(QualityReadingOutBuilder b)]) =
      _$QualityReadingOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QualityReadingOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QualityReadingOut> get serializer =>
      _$QualityReadingOutSerializer();
}

class _$QualityReadingOutSerializer
    implements PrimitiveSerializer<QualityReadingOut> {
  @override
  final Iterable<Type> types = const [QualityReadingOut, _$QualityReadingOut];

  @override
  final String wireName = r'QualityReadingOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QualityReadingOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batch_id';
    yield object.batchId == null
        ? null
        : serializers.serialize(
            object.batchId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'calibration_due_on_at_time';
    yield object.calibrationDueOnAtTime == null
        ? null
        : serializers.serialize(
            object.calibrationDueOnAtTime,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'instrument_id';
    yield object.instrumentId == null
        ? null
        : serializers.serialize(
            object.instrumentId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lab_nabl_no';
    yield object.labNablNo == null
        ? null
        : serializers.serialize(
            object.labNablNo,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lab_name';
    yield object.labName == null
        ? null
        : serializers.serialize(
            object.labName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lot_id';
    yield object.lotId == null
        ? null
        : serializers.serialize(
            object.lotId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'measured_at';
    yield serializers.serialize(
      object.measuredAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'measured_by_user_id';
    yield serializers.serialize(
      object.measuredByUserId,
      specifiedType: const FullType(String),
    );
    yield r'measurement';
    yield serializers.serialize(
      object.measurement,
      specifiedType: const FullType(SignedQuantityOutput),
    );
    yield r'method_ref';
    yield object.methodRef == null
        ? null
        : serializers.serialize(
            object.methodRef,
            specifiedType: const FullType.nullable(String),
          );
    yield r'parameter_code';
    yield serializers.serialize(
      object.parameterCode,
      specifiedType: const FullType(String),
    );
    yield r'profile_version_id';
    yield object.profileVersionId == null
        ? null
        : serializers.serialize(
            object.profileVersionId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reason_code';
    yield object.reasonCode == null
        ? null
        : serializers.serialize(
            object.reasonCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sample_id';
    yield object.sampleId == null
        ? null
        : serializers.serialize(
            object.sampleId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'server_received_at';
    yield serializers.serialize(
      object.serverReceivedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(ReadingSource),
    );
    yield r'stage';
    yield serializers.serialize(
      object.stage,
      specifiedType: const FullType(ReadingStage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    QualityReadingOut object, {
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
    required QualityReadingOutBuilder result,
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
        case r'calibration_due_on_at_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.calibrationDueOnAtTime = valueDes;
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'instrument_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.instrumentId = valueDes;
          break;
        case r'lab_nabl_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.labNablNo = valueDes;
          break;
        case r'lab_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.labName = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lotId = valueDes;
          break;
        case r'measured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.measuredAt = valueDes;
          break;
        case r'measured_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.measuredByUserId = valueDes;
          break;
        case r'measurement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SignedQuantityOutput),
          ) as SignedQuantityOutput;
          result.measurement.replace(valueDes);
          break;
        case r'method_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.methodRef = valueDes;
          break;
        case r'parameter_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.parameterCode = valueDes;
          break;
        case r'profile_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.profileVersionId = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'sample_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sampleId = valueDes;
          break;
        case r'server_received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverReceivedAt = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadingSource),
          ) as ReadingSource;
          result.source_ = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadingStage),
          ) as ReadingStage;
          result.stage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  QualityReadingOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QualityReadingOutBuilder();
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
