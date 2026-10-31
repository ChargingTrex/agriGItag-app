//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'packing_payload.g.dart';

/// Stage 6 on-farm packing.
///
/// Properties:
/// * [bags] - Number of bags packed.
/// * [quantity] - Packed quantity, unit `kg` (FR58).
@BuiltValue()
abstract class PackingPayload
    implements Built<PackingPayload, PackingPayloadBuilder> {
  /// Number of bags packed.
  @BuiltValueField(wireName: r'bags')
  int? get bags;

  /// Packed quantity, unit `kg` (FR58).
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  PackingPayload._();

  factory PackingPayload([void updates(PackingPayloadBuilder b)]) =
      _$PackingPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PackingPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PackingPayload> get serializer =>
      _$PackingPayloadSerializer();
}

class _$PackingPayloadSerializer
    implements PrimitiveSerializer<PackingPayload> {
  @override
  final Iterable<Type> types = const [PackingPayload, _$PackingPayload];

  @override
  final String wireName = r'PackingPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PackingPayload object, {
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
    PackingPayload object, {
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
    required PackingPayloadBuilder result,
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
  PackingPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PackingPayloadBuilder();
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
