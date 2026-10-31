//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/avg_sale_price_per_kg.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'final_packing_payload.g.dart';

/// Stage 9 final (retail) packing of a batch.
///
/// Properties:
/// * [avgSalePricePerKg]
/// * [packSize] - Size of one retail pack, e.g. `{value: 250, unit: g}`.
/// * [packs] - Number of packs filled.
/// * [quantity] - Packed quantity, unit `kg`.
@BuiltValue()
abstract class FinalPackingPayload
    implements Built<FinalPackingPayload, FinalPackingPayloadBuilder> {
  @BuiltValueField(wireName: r'avg_sale_price_per_kg')
  AvgSalePricePerKg? get avgSalePricePerKg;

  /// Size of one retail pack, e.g. `{value: 250, unit: g}`.
  @BuiltValueField(wireName: r'pack_size')
  QuantityInput? get packSize;

  /// Number of packs filled.
  @BuiltValueField(wireName: r'packs')
  int? get packs;

  /// Packed quantity, unit `kg`.
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  FinalPackingPayload._();

  factory FinalPackingPayload([void updates(FinalPackingPayloadBuilder b)]) =
      _$FinalPackingPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinalPackingPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinalPackingPayload> get serializer =>
      _$FinalPackingPayloadSerializer();
}

class _$FinalPackingPayloadSerializer
    implements PrimitiveSerializer<FinalPackingPayload> {
  @override
  final Iterable<Type> types = const [
    FinalPackingPayload,
    _$FinalPackingPayload
  ];

  @override
  final String wireName = r'FinalPackingPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinalPackingPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.avgSalePricePerKg != null) {
      yield r'avg_sale_price_per_kg';
      yield serializers.serialize(
        object.avgSalePricePerKg,
        specifiedType: const FullType.nullable(AvgSalePricePerKg),
      );
    }
    if (object.packSize != null) {
      yield r'pack_size';
      yield serializers.serialize(
        object.packSize,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
    if (object.packs != null) {
      yield r'packs';
      yield serializers.serialize(
        object.packs,
        specifiedType: const FullType.nullable(int),
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
    FinalPackingPayload object, {
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
    required FinalPackingPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avg_sale_price_per_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AvgSalePricePerKg),
          ) as AvgSalePricePerKg?;
          if (valueDes == null) continue;
          result.avgSalePricePerKg.replace(valueDes);
          break;
        case r'pack_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.packSize.replace(valueDes);
          break;
        case r'packs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.packs = valueDes;
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
  FinalPackingPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinalPackingPayloadBuilder();
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
