//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'otp_request_in.g.dart';

/// Ask for a one-time code by SMS.
///
/// Properties:
/// * [phone] - Mobile number in E.164 form, e.g. `+919876543210`.
@BuiltValue()
abstract class OtpRequestIn
    implements Built<OtpRequestIn, OtpRequestInBuilder> {
  /// Mobile number in E.164 form, e.g. `+919876543210`.
  @BuiltValueField(wireName: r'phone')
  String get phone;

  OtpRequestIn._();

  factory OtpRequestIn([void updates(OtpRequestInBuilder b)]) = _$OtpRequestIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OtpRequestInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OtpRequestIn> get serializer => _$OtpRequestInSerializer();
}

class _$OtpRequestInSerializer implements PrimitiveSerializer<OtpRequestIn> {
  @override
  final Iterable<Type> types = const [OtpRequestIn, _$OtpRequestIn];

  @override
  final String wireName = r'OtpRequestIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OtpRequestIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OtpRequestIn object, {
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
    required OtpRequestInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OtpRequestIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OtpRequestInBuilder();
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
