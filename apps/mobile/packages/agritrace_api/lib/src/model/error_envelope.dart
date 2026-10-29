//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/error_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_envelope.g.dart';

/// Shape of every error response: `{\"error\": {\"code\", \"message\", \"details\"}}`.
///
/// Properties:
/// * [error] - The error.
@BuiltValue()
abstract class ErrorEnvelope
    implements Built<ErrorEnvelope, ErrorEnvelopeBuilder> {
  /// The error.
  @BuiltValueField(wireName: r'error')
  ErrorBody get error;

  ErrorEnvelope._();

  factory ErrorEnvelope([void updates(ErrorEnvelopeBuilder b)]) =
      _$ErrorEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorEnvelope> get serializer =>
      _$ErrorEnvelopeSerializer();
}

class _$ErrorEnvelopeSerializer implements PrimitiveSerializer<ErrorEnvelope> {
  @override
  final Iterable<Type> types = const [ErrorEnvelope, _$ErrorEnvelope];

  @override
  final String wireName = r'ErrorEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(ErrorBody),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorEnvelope object, {
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
    required ErrorEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorBody),
          ) as ErrorBody;
          result.error.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorEnvelopeBuilder();
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
