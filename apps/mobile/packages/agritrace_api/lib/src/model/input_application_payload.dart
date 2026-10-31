//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input_application_payload.g.dart';

/// Stage 3 fertiliser or pesticide application, many instances per season (FR56).
///
/// Properties:
/// * [inputId] - Input from the master list (`GET /v1/inputs`); practice tags derive from it.
/// * [inputName] - Name as written by the farmer when the input is not in the list.
/// * [quantity] - Amount applied, e.g. `{value: 25, unit: kg}`.
@BuiltValue()
abstract class InputApplicationPayload
    implements Built<InputApplicationPayload, InputApplicationPayloadBuilder> {
  /// Input from the master list (`GET /v1/inputs`); practice tags derive from it.
  @BuiltValueField(wireName: r'input_id')
  String? get inputId;

  /// Name as written by the farmer when the input is not in the list.
  @BuiltValueField(wireName: r'input_name')
  String? get inputName;

  /// Amount applied, e.g. `{value: 25, unit: kg}`.
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  InputApplicationPayload._();

  factory InputApplicationPayload(
          [void updates(InputApplicationPayloadBuilder b)]) =
      _$InputApplicationPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InputApplicationPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InputApplicationPayload> get serializer =>
      _$InputApplicationPayloadSerializer();
}

class _$InputApplicationPayloadSerializer
    implements PrimitiveSerializer<InputApplicationPayload> {
  @override
  final Iterable<Type> types = const [
    InputApplicationPayload,
    _$InputApplicationPayload
  ];

  @override
  final String wireName = r'InputApplicationPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InputApplicationPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.inputId != null) {
      yield r'input_id';
      yield serializers.serialize(
        object.inputId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.inputName != null) {
      yield r'input_name';
      yield serializers.serialize(
        object.inputName,
        specifiedType: const FullType.nullable(String),
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
    InputApplicationPayload object, {
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
    required InputApplicationPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'input_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.inputId = valueDes;
          break;
        case r'input_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.inputName = valueDes;
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
  InputApplicationPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InputApplicationPayloadBuilder();
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
