//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pin_change_in.g.dart';

/// Set the office PIN (first time) or change it (the current PIN is then required).
///
/// Properties:
/// * [currentPin] - The PIN in force; required when a PIN is already set.
/// * [pin] - Exactly 4 digits.
@BuiltValue()
abstract class PinChangeIn implements Built<PinChangeIn, PinChangeInBuilder> {
  /// The PIN in force; required when a PIN is already set.
  @BuiltValueField(wireName: r'current_pin')
  String? get currentPin;

  /// Exactly 4 digits.
  @BuiltValueField(wireName: r'pin')
  String get pin;

  PinChangeIn._();

  factory PinChangeIn([void updates(PinChangeInBuilder b)]) = _$PinChangeIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PinChangeInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PinChangeIn> get serializer => _$PinChangeInSerializer();
}

class _$PinChangeInSerializer implements PrimitiveSerializer<PinChangeIn> {
  @override
  final Iterable<Type> types = const [PinChangeIn, _$PinChangeIn];

  @override
  final String wireName = r'PinChangeIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PinChangeIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.currentPin != null) {
      yield r'current_pin';
      yield serializers.serialize(
        object.currentPin,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PinChangeIn object, {
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
    required PinChangeInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currentPin = valueDes;
          break;
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
  PinChangeIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PinChangeInBuilder();
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
