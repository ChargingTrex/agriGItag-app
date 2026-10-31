//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/value1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'signed_quantity_input.g.dart';

/// A quantity that may be negative, used only for adjustments and differences.
///
/// Properties:
/// * [unit] - Unit code, e.g. `kg`, `acre`, `l`, `count`.
/// * [value]
@BuiltValue()
abstract class SignedQuantityInput
    implements Built<SignedQuantityInput, SignedQuantityInputBuilder> {
  /// Unit code, e.g. `kg`, `acre`, `l`, `count`.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  @BuiltValueField(wireName: r'value')
  Value1 get value;

  SignedQuantityInput._();

  factory SignedQuantityInput([void updates(SignedQuantityInputBuilder b)]) =
      _$SignedQuantityInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SignedQuantityInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SignedQuantityInput> get serializer =>
      _$SignedQuantityInputSerializer();
}

class _$SignedQuantityInputSerializer
    implements PrimitiveSerializer<SignedQuantityInput> {
  @override
  final Iterable<Type> types = const [
    SignedQuantityInput,
    _$SignedQuantityInput
  ];

  @override
  final String wireName = r'SignedQuantityInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SignedQuantityInput object, {
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
      specifiedType: const FullType(Value1),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SignedQuantityInput object, {
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
    required SignedQuantityInputBuilder result,
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
            specifiedType: const FullType(Value1),
          ) as Value1;
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
  SignedQuantityInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SignedQuantityInputBuilder();
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
