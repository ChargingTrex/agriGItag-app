//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refresh_in.g.dart';

/// Rotate the refresh token. Web clients omit the body field and send the httpOnly cookie.
///
/// Properties:
/// * [refreshToken] - The current refresh token; omit when the cookie carries it (web).
@BuiltValue()
abstract class RefreshIn implements Built<RefreshIn, RefreshInBuilder> {
  /// The current refresh token; omit when the cookie carries it (web).
  @BuiltValueField(wireName: r'refresh_token')
  String? get refreshToken;

  RefreshIn._();

  factory RefreshIn([void updates(RefreshInBuilder b)]) = _$RefreshIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefreshInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefreshIn> get serializer => _$RefreshInSerializer();
}

class _$RefreshInSerializer implements PrimitiveSerializer<RefreshIn> {
  @override
  final Iterable<Type> types = const [RefreshIn, _$RefreshIn];

  @override
  final String wireName = r'RefreshIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefreshIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.refreshToken != null) {
      yield r'refresh_token';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RefreshIn object, {
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
    required RefreshInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RefreshIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefreshInBuilder();
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
