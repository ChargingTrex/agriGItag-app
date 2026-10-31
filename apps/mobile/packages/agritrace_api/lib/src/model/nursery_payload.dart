//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'nursery_payload.g.dart';

/// Nursery preparation, split from main-field sowing (FR55); seeding date is `occurred_on`.
///
/// Properties:
/// * [nurseryArea] - Nursery bed area, e.g. unit `cent`.
/// * [seedVariety] - Seed variety, e.g. `K2`.
@BuiltValue()
abstract class NurseryPayload
    implements Built<NurseryPayload, NurseryPayloadBuilder> {
  /// Nursery bed area, e.g. unit `cent`.
  @BuiltValueField(wireName: r'nursery_area')
  QuantityInput? get nurseryArea;

  /// Seed variety, e.g. `K2`.
  @BuiltValueField(wireName: r'seed_variety')
  String? get seedVariety;

  NurseryPayload._();

  factory NurseryPayload([void updates(NurseryPayloadBuilder b)]) =
      _$NurseryPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NurseryPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NurseryPayload> get serializer =>
      _$NurseryPayloadSerializer();
}

class _$NurseryPayloadSerializer
    implements PrimitiveSerializer<NurseryPayload> {
  @override
  final Iterable<Type> types = const [NurseryPayload, _$NurseryPayload];

  @override
  final String wireName = r'NurseryPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NurseryPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.nurseryArea != null) {
      yield r'nursery_area';
      yield serializers.serialize(
        object.nurseryArea,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
    if (object.seedVariety != null) {
      yield r'seed_variety';
      yield serializers.serialize(
        object.seedVariety,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NurseryPayload object, {
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
    required NurseryPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nursery_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.nurseryArea.replace(valueDes);
          break;
        case r'seed_variety':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.seedVariety = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NurseryPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NurseryPayloadBuilder();
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
