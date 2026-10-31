//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'harvest_payload.g.dart';

/// Stage 4 harvest round; several rounds per lot (FR3, FR57).
///
/// Properties:
/// * [bags] - Number of bags filled.
/// * [quantity] - Harvested quantity, unit `kg` (FR57 yield check).
@BuiltValue()
abstract class HarvestPayload
    implements Built<HarvestPayload, HarvestPayloadBuilder> {
  /// Number of bags filled.
  @BuiltValueField(wireName: r'bags')
  int? get bags;

  /// Harvested quantity, unit `kg` (FR57 yield check).
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  HarvestPayload._();

  factory HarvestPayload([void updates(HarvestPayloadBuilder b)]) =
      _$HarvestPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HarvestPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HarvestPayload> get serializer =>
      _$HarvestPayloadSerializer();
}

class _$HarvestPayloadSerializer
    implements PrimitiveSerializer<HarvestPayload> {
  @override
  final Iterable<Type> types = const [HarvestPayload, _$HarvestPayload];

  @override
  final String wireName = r'HarvestPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HarvestPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bags != null) {
      yield r'bags';
      yield serializers.serialize(
        object.bags,
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
    HarvestPayload object, {
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
    required HarvestPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.bags = valueDes;
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
  HarvestPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HarvestPayloadBuilder();
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
