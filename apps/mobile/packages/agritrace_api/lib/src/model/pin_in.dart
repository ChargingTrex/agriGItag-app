//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pin_in.g.dart';

/// A 4-digit office PIN.
///
/// Properties:
/// * [pin] - Exactly 4 digits.
@BuiltValue()
abstract class PinIn implements Built<PinIn, PinInBuilder> {
  /// Exactly 4 digits.
  @BuiltValueField(wireName: r'pin')
  String get pin;

  PinIn._();

  factory PinIn([void updates(PinInBuilder b)]) = _$PinIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PinInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PinIn> get serializer => _$PinInSerializer();
}

class _$PinInSerializer implements PrimitiveSerializer<PinIn> {
  @override
  final Iterable<Type> types = const [PinIn, _$PinIn];

  @override
  final String wireName = r'PinIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PinIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PinIn object, {
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
    required PinInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PinIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PinInBuilder();
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
