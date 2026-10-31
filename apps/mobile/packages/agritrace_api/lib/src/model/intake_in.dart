//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/price_per_kg.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'intake_in.g.dart';

/// A processor receives a ready lot, or a wrong intake is corrected (Stage 7, FR9, D-033).
///
/// Properties:
/// * [clientId] - UUIDv7 made by the client; intake id and idempotency key.
/// * [correctionReason] - Why the superseded intake was wrong.
/// * [intakeMoistureReadingId] - Moisture reading (`moisture`, stage `intake`) of this lot (`POST /v1/quality-readings`)
/// * [lotId] - Lot received; `ready_for_sale`, or `open`/`drying` with a drying-end moisture that passes the ready gate (run here, D-040).
/// * [pricePerKg]
/// * [processorId] - Receiving processor (own or shared); absent → the FPO's only own processor (D-040), zero or several own processors → `field_required`.
/// * [received] - Quantity received, unit `kg`.
/// * [saleDate] - Date of sale, YYYY-MM-DD.
/// * [supersedesIntakeId] - Correct this intake (the lot's current one, lot not yet batched); needs a reason.
@BuiltValue()
abstract class IntakeIn implements Built<IntakeIn, IntakeInBuilder> {
  /// UUIDv7 made by the client; intake id and idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Why the superseded intake was wrong.
  @BuiltValueField(wireName: r'correction_reason')
  String? get correctionReason;

  /// Moisture reading (`moisture`, stage `intake`) of this lot (`POST /v1/quality-readings`)
  @BuiltValueField(wireName: r'intake_moisture_reading_id')
  String? get intakeMoistureReadingId;

  /// Lot received; `ready_for_sale`, or `open`/`drying` with a drying-end moisture that passes the ready gate (run here, D-040).
  @BuiltValueField(wireName: r'lot_id')
  String get lotId;

  @BuiltValueField(wireName: r'price_per_kg')
  PricePerKg? get pricePerKg;

  /// Receiving processor (own or shared); absent → the FPO's only own processor (D-040), zero or several own processors → `field_required`.
  @BuiltValueField(wireName: r'processor_id')
  String? get processorId;

  /// Quantity received, unit `kg`.
  @BuiltValueField(wireName: r'received')
  QuantityInput get received;

  /// Date of sale, YYYY-MM-DD.
  @BuiltValueField(wireName: r'sale_date')
  Date get saleDate;

  /// Correct this intake (the lot's current one, lot not yet batched); needs a reason.
  @BuiltValueField(wireName: r'supersedes_intake_id')
  String? get supersedesIntakeId;

  IntakeIn._();

  factory IntakeIn([void updates(IntakeInBuilder b)]) = _$IntakeIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IntakeInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IntakeIn> get serializer => _$IntakeInSerializer();
}

class _$IntakeInSerializer implements PrimitiveSerializer<IntakeIn> {
  @override
  final Iterable<Type> types = const [IntakeIn, _$IntakeIn];

  @override
  final String wireName = r'IntakeIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IntakeIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.correctionReason != null) {
      yield r'correction_reason';
      yield serializers.serialize(
        object.correctionReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.intakeMoistureReadingId != null) {
      yield r'intake_moisture_reading_id';
      yield serializers.serialize(
        object.intakeMoistureReadingId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lot_id';
    yield serializers.serialize(
      object.lotId,
      specifiedType: const FullType(String),
    );
    if (object.pricePerKg != null) {
      yield r'price_per_kg';
      yield serializers.serialize(
        object.pricePerKg,
        specifiedType: const FullType.nullable(PricePerKg),
      );
    }
    if (object.processorId != null) {
      yield r'processor_id';
      yield serializers.serialize(
        object.processorId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'received';
    yield serializers.serialize(
      object.received,
      specifiedType: const FullType(QuantityInput),
    );
    yield r'sale_date';
    yield serializers.serialize(
      object.saleDate,
      specifiedType: const FullType(Date),
    );
    if (object.supersedesIntakeId != null) {
      yield r'supersedes_intake_id';
      yield serializers.serialize(
        object.supersedesIntakeId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IntakeIn object, {
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
    required IntakeInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'correction_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.correctionReason = valueDes;
          break;
        case r'intake_moisture_reading_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.intakeMoistureReadingId = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lotId = valueDes;
          break;
        case r'price_per_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PricePerKg),
          ) as PricePerKg?;
          if (valueDes == null) continue;
          result.pricePerKg.replace(valueDes);
          break;
        case r'processor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.processorId = valueDes;
          break;
        case r'received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityInput),
          ) as QuantityInput;
          result.received.replace(valueDes);
          break;
        case r'sale_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.saleDate = valueDes;
          break;
        case r'supersedes_intake_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supersedesIntakeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IntakeIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IntakeInBuilder();
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
