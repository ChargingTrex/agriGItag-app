//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quantity_output.g.dart';

/// A non-negative amount with its unit (FR58): never a bare number.
///
/// Properties:
/// * [unit] - Unit code, e.g. `kg`, `acre`, `l`, `count`.
/// * [value] - Amount; decimal string or number, never negative.
@BuiltValue()
abstract class QuantityOutput
    implements Built<QuantityOutput, QuantityOutputBuilder> {
  /// Unit code, e.g. `kg`, `acre`, `l`, `count`.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  /// Amount; decimal string or number, never negative.
  @BuiltValueField(wireName: r'value')
  String get value;

  QuantityOutput._();

  factory QuantityOutput([void updates(QuantityOutputBuilder b)]) =
      _$QuantityOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuantityOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuantityOutput> get serializer =>
      _$QuantityOutputSerializer();
}

class _$QuantityOutputSerializer
    implements PrimitiveSerializer<QuantityOutput> {
  @override
  final Iterable<Type> types = const [QuantityOutput, _$QuantityOutput];

  @override
  final String wireName = r'QuantityOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuantityOutput object, {
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
    QuantityOutput object, {
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
    required QuantityOutputBuilder result,
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
  QuantityOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuantityOutputBuilder();
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
