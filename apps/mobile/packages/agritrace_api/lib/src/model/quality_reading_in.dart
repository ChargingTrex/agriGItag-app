//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/reading_source.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:agritrace_api/src/model/signed_quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quality_reading_in.g.dart';

/// One measured parameter of a lot or batch at a stage (FR42–FR46). Also the sync `quality_reading` data.  Exactly one of `lot_id` and `batch_id` is set.
///
/// Properties:
/// * [batchId] - Batch measured (grading, storage).
/// * [certificatePhotoId] - Evidence photo of the lab certificate.
/// * [clientId] - UUIDv7 from the device; primary and idempotency key (D-005).
/// * [deviceTime] - Phone clock at capture.
/// * [evidencePhotoId] - Photo of the meter display or colour card.
/// * [gps] - Where it was measured (FR42).
/// * [gpsTime] - GPS fix time at capture.
/// * [instrumentId] - Instrument used; required when source=instrument.
/// * [labNablNo] - NABL number; needed for Lab-certified.
/// * [labName] - Laboratory name, for lab results.
/// * [lotId] - Lot measured (drying end, intake).
/// * [measuredAt] - When it was measured, ISO 8601 with offset.
/// * [measurement] - Value with its unit, e.g. {value: 9.8, unit: %}. Negative values pass the schema so the plausibility check can answer `implausible_value`.
/// * [methodRef] - Test method reference (FR42).
/// * [parameterCode] - Profile parameter code.
/// * [reasonCode] - Reason accepted for a trail-rule override, e.g. `rain_exposure`.
/// * [sampleId] - Sample identifier (FR42).
/// * [source_] - lab, instrument or visual (FR42, FR44).
/// * [stage] - drying_end, intake, grading or storage (FR43, FR45).
@BuiltValue()
abstract class QualityReadingIn
    implements Built<QualityReadingIn, QualityReadingInBuilder> {
  /// Batch measured (grading, storage).
  @BuiltValueField(wireName: r'batch_id')
  String? get batchId;

  /// Evidence photo of the lab certificate.
  @BuiltValueField(wireName: r'certificate_photo_id')
  String? get certificatePhotoId;

  /// UUIDv7 from the device; primary and idempotency key (D-005).
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Phone clock at capture.
  @BuiltValueField(wireName: r'device_time')
  DateTime? get deviceTime;

  /// Photo of the meter display or colour card.
  @BuiltValueField(wireName: r'evidence_photo_id')
  String? get evidencePhotoId;

  /// Where it was measured (FR42).
  @BuiltValueField(wireName: r'gps')
  GeoPoint? get gps;

  /// GPS fix time at capture.
  @BuiltValueField(wireName: r'gps_time')
  DateTime? get gpsTime;

  /// Instrument used; required when source=instrument.
  @BuiltValueField(wireName: r'instrument_id')
  String? get instrumentId;

  /// NABL number; needed for Lab-certified.
  @BuiltValueField(wireName: r'lab_nabl_no')
  String? get labNablNo;

  /// Laboratory name, for lab results.
  @BuiltValueField(wireName: r'lab_name')
  String? get labName;

  /// Lot measured (drying end, intake).
  @BuiltValueField(wireName: r'lot_id')
  String? get lotId;

  /// When it was measured, ISO 8601 with offset.
  @BuiltValueField(wireName: r'measured_at')
  DateTime get measuredAt;

  /// Value with its unit, e.g. {value: 9.8, unit: %}. Negative values pass the schema so the plausibility check can answer `implausible_value`.
  @BuiltValueField(wireName: r'measurement')
  SignedQuantityInput get measurement;

  /// Test method reference (FR42).
  @BuiltValueField(wireName: r'method_ref')
  String? get methodRef;

  /// Profile parameter code.
  @BuiltValueField(wireName: r'parameter_code')
  String get parameterCode;

  /// Reason accepted for a trail-rule override, e.g. `rain_exposure`.
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// Sample identifier (FR42).
  @BuiltValueField(wireName: r'sample_id')
  String? get sampleId;

  /// lab, instrument or visual (FR42, FR44).
  @BuiltValueField(wireName: r'source')
  ReadingSource get source_;
  // enum source_Enum {  lab,  instrument,  visual,  };

  /// drying_end, intake, grading or storage (FR43, FR45).
  @BuiltValueField(wireName: r'stage')
  ReadingStage get stage;
  // enum stageEnum {  drying_end,  intake,  grading,  storage,  };

  QualityReadingIn._();

  factory QualityReadingIn([void updates(QualityReadingInBuilder b)]) =
      _$QualityReadingIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QualityReadingInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QualityReadingIn> get serializer =>
      _$QualityReadingInSerializer();
}

class _$QualityReadingInSerializer
    implements PrimitiveSerializer<QualityReadingIn> {
  @override
  final Iterable<Type> types = const [QualityReadingIn, _$QualityReadingIn];

  @override
  final String wireName = r'QualityReadingIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QualityReadingIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.batchId != null) {
      yield r'batch_id';
      yield serializers.serialize(
        object.batchId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.certificatePhotoId != null) {
      yield r'certificate_photo_id';
      yield serializers.serialize(
        object.certificatePhotoId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.deviceTime != null) {
      yield r'device_time';
      yield serializers.serialize(
        object.deviceTime,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.evidencePhotoId != null) {
      yield r'evidence_photo_id';
      yield serializers.serialize(
        object.evidencePhotoId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.gps != null) {
      yield r'gps';
      yield serializers.serialize(
        object.gps,
        specifiedType: const FullType.nullable(GeoPoint),
      );
    }
    if (object.gpsTime != null) {
      yield r'gps_time';
      yield serializers.serialize(
        object.gpsTime,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.instrumentId != null) {
      yield r'instrument_id';
      yield serializers.serialize(
        object.instrumentId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.labNablNo != null) {
      yield r'lab_nabl_no';
      yield serializers.serialize(
        object.labNablNo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.labName != null) {
      yield r'lab_name';
      yield serializers.serialize(
        object.labName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lotId != null) {
      yield r'lot_id';
      yield serializers.serialize(
        object.lotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'measured_at';
    yield serializers.serialize(
      object.measuredAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'measurement';
    yield serializers.serialize(
      object.measurement,
      specifiedType: const FullType(SignedQuantityInput),
    );
    if (object.methodRef != null) {
      yield r'method_ref';
      yield serializers.serialize(
        object.methodRef,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'parameter_code';
    yield serializers.serialize(
      object.parameterCode,
      specifiedType: const FullType(String),
    );
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sampleId != null) {
      yield r'sample_id';
      yield serializers.serialize(
        object.sampleId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    QualityReadingIn object, {
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
    required QualityReadingInBuilder result,
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
        case r'certificate_photo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.certificatePhotoId = valueDes;
          break;
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'device_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deviceTime = valueDes;
          break;
        case r'evidence_photo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.evidencePhotoId = valueDes;
          break;
        case r'gps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GeoPoint),
          ) as GeoPoint?;
          if (valueDes == null) continue;
          result.gps.replace(valueDes);
          break;
        case r'gps_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.gpsTime = valueDes;
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
        case r'measurement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SignedQuantityInput),
          ) as SignedQuantityInput;
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
  QualityReadingIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QualityReadingInBuilder();
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
