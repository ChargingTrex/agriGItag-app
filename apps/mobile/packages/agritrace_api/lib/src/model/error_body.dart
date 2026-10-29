//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_body.g.dart';

/// Inner object of the error envelope.
///
/// Properties:
/// * [code] - Registered snake_case error code (docs/api/error-codes.md).
/// * [details] - Context such as failing fields, ids or limits; may be null.
/// * [message] - English message; clients show their own en/ta text for `code`.
@BuiltValue()
abstract class ErrorBody implements Built<ErrorBody, ErrorBodyBuilder> {
  /// Registered snake_case error code (docs/api/error-codes.md).
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Context such as failing fields, ids or limits; may be null.
  @BuiltValueField(wireName: r'details')
  JsonObject? get details;

  /// English message; clients show their own en/ta text for `code`.
  @BuiltValueField(wireName: r'message')
  String get message;

  ErrorBody._();

  factory ErrorBody([void updates(ErrorBodyBuilder b)]) = _$ErrorBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorBody> get serializer => _$ErrorBodySerializer();
}

class _$ErrorBodySerializer implements PrimitiveSerializer<ErrorBody> {
  @override
  final Iterable<Type> types = const [ErrorBody, _$ErrorBody];

  @override
  final String wireName = r'ErrorBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorBody object, {
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
    required ErrorBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorBodyBuilder();
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
