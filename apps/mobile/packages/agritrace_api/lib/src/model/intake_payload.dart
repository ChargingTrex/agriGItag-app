//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/price_per_kg.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'intake_payload.g.dart';

/// Stage 7 sale of a lot to the processor, as a note on the lot's timeline only.  It does not receive the lot: no `lot_intakes` row, no status change (D-040). To receive a lot use push kind `lot_intake` or `POST /v1/intakes`.
///
/// Properties:
/// * [moistureReadingId] - Client id of the intake moisture reading taken at the gate (note only).
/// * [pricePerKg]
/// * [processorId] - Processor named in the note (the lot is received only by `lot_intake`).
/// * [received] - Quantity noted, unit `kg` (not used for shares or reconciliation).
@BuiltValue()
abstract class IntakePayload
    implements Built<IntakePayload, IntakePayloadBuilder> {
  /// Client id of the intake moisture reading taken at the gate (note only).
  @BuiltValueField(wireName: r'moisture_reading_id')
  String? get moistureReadingId;

  @BuiltValueField(wireName: r'price_per_kg')
  PricePerKg? get pricePerKg;

  /// Processor named in the note (the lot is received only by `lot_intake`).
  @BuiltValueField(wireName: r'processor_id')
  String? get processorId;

  /// Quantity noted, unit `kg` (not used for shares or reconciliation).
  @BuiltValueField(wireName: r'received')
  QuantityInput? get received;

  IntakePayload._();

  factory IntakePayload([void updates(IntakePayloadBuilder b)]) =
      _$IntakePayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IntakePayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IntakePayload> get serializer =>
      _$IntakePayloadSerializer();
}

class _$IntakePayloadSerializer implements PrimitiveSerializer<IntakePayload> {
  @override
  final Iterable<Type> types = const [IntakePayload, _$IntakePayload];

  @override
  final String wireName = r'IntakePayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IntakePayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.moistureReadingId != null) {
      yield r'moisture_reading_id';
      yield serializers.serialize(
        object.moistureReadingId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    if (object.received != null) {
      yield r'received';
      yield serializers.serialize(
        object.received,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IntakePayload object, {
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
    required IntakePayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'moisture_reading_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.moistureReadingId = valueDes;
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
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.received.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IntakePayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IntakePayloadBuilder();
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
