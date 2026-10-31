//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'signed_quantity_output.g.dart';

/// A quantity that may be negative, used only for adjustments and differences.
///
/// Properties:
/// * [unit] - Unit code, e.g. `kg`, `acre`, `l`, `count`.
/// * [value] - Amount; negative allowed (adjustment or difference).
@BuiltValue()
abstract class SignedQuantityOutput
    implements Built<SignedQuantityOutput, SignedQuantityOutputBuilder> {
  /// Unit code, e.g. `kg`, `acre`, `l`, `count`.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  /// Amount; negative allowed (adjustment or difference).
  @BuiltValueField(wireName: r'value')
  String get value;

  SignedQuantityOutput._();

  factory SignedQuantityOutput([void updates(SignedQuantityOutputBuilder b)]) =
      _$SignedQuantityOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SignedQuantityOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SignedQuantityOutput> get serializer =>
      _$SignedQuantityOutputSerializer();
}

class _$SignedQuantityOutputSerializer
    implements PrimitiveSerializer<SignedQuantityOutput> {
  @override
  final Iterable<Type> types = const [
    SignedQuantityOutput,
    _$SignedQuantityOutput
  ];

  @override
  final String wireName = r'SignedQuantityOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SignedQuantityOutput object, {
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
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SignedQuantityOutput object, {
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
    required SignedQuantityOutputBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SignedQuantityOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SignedQuantityOutputBuilder();
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
