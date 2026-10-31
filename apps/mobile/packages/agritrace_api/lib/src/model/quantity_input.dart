//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quantity_input.g.dart';

/// A non-negative amount with its unit (FR58): never a bare number.
///
/// Properties:
/// * [unit] - Unit code, e.g. `kg`, `acre`, `l`, `count`.
/// * [value]
@BuiltValue()
abstract class QuantityInput
    implements Built<QuantityInput, QuantityInputBuilder> {
  /// Unit code, e.g. `kg`, `acre`, `l`, `count`.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  @BuiltValueField(wireName: r'value')
  Value get value;

  QuantityInput._();

  factory QuantityInput([void updates(QuantityInputBuilder b)]) =
      _$QuantityInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuantityInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuantityInput> get serializer =>
      _$QuantityInputSerializer();
}

class _$QuantityInputSerializer implements PrimitiveSerializer<QuantityInput> {
  @override
  final Iterable<Type> types = const [QuantityInput, _$QuantityInput];

  @override
  final String wireName = r'QuantityInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuantityInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(Value),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    QuantityInput object, {
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
    required QuantityInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Value),
          ) as Value;
          result.value.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  QuantityInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuantityInputBuilder();
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
