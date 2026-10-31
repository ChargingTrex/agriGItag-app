//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/instrument_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'instrument_in.g.dart';

/// A moisture meter, colorimeter, hygrometer or scale registered by the FPO (FR42, FR50).
///
/// Properties:
/// * [active] - False hides it from new readings.
/// * [calibratedOn] - Date of last calibration (YYYY-MM-DD).
/// * [calibrationCertPhotoId] - Evidence photo of the certificate.
/// * [calibrationDueOn] - Calibration due date; readings measured after it are rejected (FR50).
/// * [kind] - Instrument kind.
/// * [makeModel] - Make and model.
/// * [serialNo] - Serial number.
@BuiltValue()
abstract class InstrumentIn
    implements Built<InstrumentIn, InstrumentInBuilder> {
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

  InstrumentIn._();

  factory InstrumentIn([void updates(InstrumentInBuilder b)]) = _$InstrumentIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InstrumentInBuilder b) => b..active = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<InstrumentIn> get serializer => _$InstrumentInSerializer();
}

class _$InstrumentInSerializer implements PrimitiveSerializer<InstrumentIn> {
  @override
  final Iterable<Type> types = const [InstrumentIn, _$InstrumentIn];

  @override
  final String wireName = r'InstrumentIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InstrumentIn object, {
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
    InstrumentIn object, {
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
    required InstrumentInBuilder result,
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
  InstrumentIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InstrumentInBuilder();
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
