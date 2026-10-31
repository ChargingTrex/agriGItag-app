//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drying_payload.g.dart';

/// Stage 5 drying on the farm; several drying runs allowed.  `start` is recorded when drying begins, `end` when it ends; one entry may carry the whole span (`occurred_on` = start, `occurred_end_on` = end). The end-of-drying moisture is a quality reading.
///
/// Properties:
/// * [moistureReadingId] - Client id of the end-of-drying moisture reading (kind `quality_reading`).
/// * [phase] - Which moment this entry records; omit when it carries the whole span.
/// * [quantity] - Quantity spread for drying, unit `kg`.
@BuiltValue()
abstract class DryingPayload
    implements Built<DryingPayload, DryingPayloadBuilder> {
  /// Client id of the end-of-drying moisture reading (kind `quality_reading`).
  @BuiltValueField(wireName: r'moisture_reading_id')
  String? get moistureReadingId;

  /// Which moment this entry records; omit when it carries the whole span.
  @BuiltValueField(wireName: r'phase')
  DryingPayloadPhaseEnum? get phase;
  // enum phaseEnum {  start,  end,  };

  /// Quantity spread for drying, unit `kg`.
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  DryingPayload._();

  factory DryingPayload([void updates(DryingPayloadBuilder b)]) =
      _$DryingPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DryingPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DryingPayload> get serializer =>
      _$DryingPayloadSerializer();
}

class _$DryingPayloadSerializer implements PrimitiveSerializer<DryingPayload> {
  @override
  final Iterable<Type> types = const [DryingPayload, _$DryingPayload];

  @override
  final String wireName = r'DryingPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DryingPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.moistureReadingId != null) {
      yield r'moisture_reading_id';
      yield serializers.serialize(
        object.moistureReadingId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phase != null) {
      yield r'phase';
      yield serializers.serialize(
        object.phase,
        specifiedType: const FullType.nullable(DryingPayloadPhaseEnum),
      );
    }
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DryingPayload object, {
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
    required DryingPayloadBuilder result,
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
        case r'phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DryingPayloadPhaseEnum),
          ) as DryingPayloadPhaseEnum?;
          if (valueDes == null) continue;
          result.phase = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DryingPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DryingPayloadBuilder();
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

/// Which moment this entry records; omit when it carries the whole span.
class DryingPayloadPhaseEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'start')
  static const DryingPayloadPhaseEnum start = _$dryingPayloadPhaseEnum_start;
  @BuiltValueEnumConst(wireName: r'end')
  static const DryingPayloadPhaseEnum end = _$dryingPayloadPhaseEnum_end;

  static Serializer<DryingPayloadPhaseEnum> get serializer =>
      _$dryingPayloadPhaseEnumSerializer;

  const DryingPayloadPhaseEnum._(String name) : super(name);

  static BuiltSet<DryingPayloadPhaseEnum> get values =>
      _$dryingPayloadPhaseEnumValues;
  static DryingPayloadPhaseEnum valueOf(String name) =>
      _$dryingPayloadPhaseEnumValueOf(name);
}
