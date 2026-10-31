//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'otp_verify_in.g.dart';

/// Trade the SMS code for a session (farmers) or a `pin_token` (office roles).
///
/// Properties:
/// * [appVersion] - App version, e.g. `1.0.3`.
/// * [code] - The 6-digit code from the SMS.
/// * [deviceId] - UUID the app generated once per installation; the session is tied to it (D-005).
/// * [phone] - The number the code was sent to, E.164.
/// * [platform] - Client platform of this device.
@BuiltValue()
abstract class OtpVerifyIn implements Built<OtpVerifyIn, OtpVerifyInBuilder> {
  /// App version, e.g. `1.0.3`.
  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  /// The 6-digit code from the SMS.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// UUID the app generated once per installation; the session is tied to it (D-005).
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  /// The number the code was sent to, E.164.
  @BuiltValueField(wireName: r'phone')
  String get phone;

  /// Client platform of this device.
  @BuiltValueField(wireName: r'platform')
  OtpVerifyInPlatformEnum get platform;
  // enum platformEnum {  android,  ios,  web,  };

  OtpVerifyIn._();

  factory OtpVerifyIn([void updates(OtpVerifyInBuilder b)]) = _$OtpVerifyIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OtpVerifyInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OtpVerifyIn> get serializer => _$OtpVerifyInSerializer();
}

class _$OtpVerifyInSerializer implements PrimitiveSerializer<OtpVerifyIn> {
  @override
  final Iterable<Type> types = const [OtpVerifyIn, _$OtpVerifyIn];

  @override
  final String wireName = r'OtpVerifyIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OtpVerifyIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(OtpVerifyInPlatformEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OtpVerifyIn object, {
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
    required OtpVerifyInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OtpVerifyInPlatformEnum),
          ) as OtpVerifyInPlatformEnum;
          result.platform = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OtpVerifyIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OtpVerifyInBuilder();
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

/// Client platform of this device.
class OtpVerifyInPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'android')
  static const OtpVerifyInPlatformEnum android =
      _$otpVerifyInPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const OtpVerifyInPlatformEnum ios = _$otpVerifyInPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'web')
  static const OtpVerifyInPlatformEnum web = _$otpVerifyInPlatformEnum_web;

  static Serializer<OtpVerifyInPlatformEnum> get serializer =>
      _$otpVerifyInPlatformEnumSerializer;

  const OtpVerifyInPlatformEnum._(String name) : super(name);

  static BuiltSet<OtpVerifyInPlatformEnum> get values =>
      _$otpVerifyInPlatformEnumValues;
  static OtpVerifyInPlatformEnum valueOf(String name) =>
      _$otpVerifyInPlatformEnumValueOf(name);
}
