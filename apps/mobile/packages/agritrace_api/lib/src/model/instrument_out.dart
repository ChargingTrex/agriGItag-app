//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/instrument_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'instrument_out.g.dart';

/// A registered instrument.
///
/// Properties:
/// * [active] - False hides it from new readings.
/// * [calibratedOn] - Date of last calibration (YYYY-MM-DD).
/// * [calibrationCertPhotoId] - Evidence photo of the certificate.
/// * [calibrationDueOn] - Calibration due date; readings measured after it are rejected (FR50).
/// * [fpoId] - Owning FPO.
/// * [id] - Instrument id.
/// * [kind] - Instrument kind.
/// * [makeModel] - Make and model.
/// * [serialNo] - Serial number.
@BuiltValue()
abstract class InstrumentOut
    implements Built<InstrumentOut, InstrumentOutBuilder> {
  /// False hides it from new readings.
  @BuiltValueField(wireName: r'active')
  bool? get active;

  /// Date of last calibration (YYYY-MM-DD).
  @BuiltValueField(wireName: r'calibrated_on')
  Date? get calibratedOn;

  /// Evidence photo of the certificate.
  @BuiltValueField(wireName: r'calibration_cert_photo_id')
  String? get calibrationCertPhotoId;

  /// Calibration due date; readings measured after it are rejected (FR50).
  @BuiltValueField(wireName: r'calibration_due_on')
  Date? get calibrationDueOn;

  /// Owning FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Instrument id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Instrument kind.
  @BuiltValueField(wireName: r'kind')
  InstrumentKind get kind;
  // enum kindEnum {  moisture_meter,  colorimeter,  hygrometer,  scale,  };

  /// Make and model.
  @BuiltValueField(wireName: r'make_model')
  String get makeModel;

  /// Serial number.
  @BuiltValueField(wireName: r'serial_no')
  String get serialNo;

  InstrumentOut._();

  factory InstrumentOut([void updates(InstrumentOutBuilder b)]) =
      _$InstrumentOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InstrumentOutBuilder b) => b..active = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<InstrumentOut> get serializer =>
      _$InstrumentOutSerializer();
}

class _$InstrumentOutSerializer implements PrimitiveSerializer<InstrumentOut> {
  @override
  final Iterable<Type> types = const [InstrumentOut, _$InstrumentOut];

  @override
  final String wireName = r'InstrumentOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InstrumentOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType(bool),
      );
    }
    if (object.calibratedOn != null) {
      yield r'calibrated_on';
      yield serializers.serialize(
        object.calibratedOn,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.calibrationCertPhotoId != null) {
      yield r'calibration_cert_photo_id';
      yield serializers.serialize(
        object.calibrationCertPhotoId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.calibrationDueOn != null) {
      yield r'calibration_due_on';
      yield serializers.serialize(
        object.calibrationDueOn,
        specifiedType: const FullType.nullable(Date),
      );
    }
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
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(InstrumentKind),
    );
    yield r'make_model';
    yield serializers.serialize(
      object.makeModel,
      specifiedType: const FullType(String),
    );
    yield r'serial_no';
    yield serializers.serialize(
      object.serialNo,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InstrumentOut object, {
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
    required InstrumentOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.active = valueDes;
          break;
        case r'calibrated_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.calibratedOn = valueDes;
          break;
        case r'calibration_cert_photo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.calibrationCertPhotoId = valueDes;
          break;
        case r'calibration_due_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.calibrationDueOn = valueDes;
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InstrumentKind),
          ) as InstrumentKind;
          result.kind = valueDes;
          break;
        case r'make_model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.makeModel = valueDes;
          break;
        case r'serial_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serialNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InstrumentOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InstrumentOutBuilder();
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
