//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/pin_required_out.dart';
import 'package:agritrace_api/src/model/session_out.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'response_otp_verify_v1_auth_otp_verify_post.g.dart';

/// `session` for farmers, `pin_required` for office roles.
///
/// Properties:
/// * [accessToken] - JWT for `Authorization: Bearer`; expires after `expires_in` s.
/// * [expiresIn] - Pin token lifetime in seconds (300).
/// * [fpoId] - FPO the session is scoped to (the user's first membership).
/// * [kind] - Discriminator: PIN step next.
/// * [refreshToken] - Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients (`X-Client: web`), which receive it as an httpOnly cookie instead (D-022).
/// * [roles] - Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, `fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag.
/// * [pinSet] - False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN.
/// * [pinToken] - Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO.
@BuiltValue()
abstract class ResponseOtpVerifyV1AuthOtpVerifyPost
    implements
        Built<ResponseOtpVerifyV1AuthOtpVerifyPost,
            ResponseOtpVerifyV1AuthOtpVerifyPostBuilder> {
  /// One Of [PinRequiredOut], [SessionOut]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'kind';

  static const Map<String, Type> discriminatorMapping = {
    r'pin_required': PinRequiredOut,
    r'session': SessionOut,
  };

  ResponseOtpVerifyV1AuthOtpVerifyPost._();

  factory ResponseOtpVerifyV1AuthOtpVerifyPost(
          [void updates(ResponseOtpVerifyV1AuthOtpVerifyPostBuilder b)]) =
      _$ResponseOtpVerifyV1AuthOtpVerifyPost;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResponseOtpVerifyV1AuthOtpVerifyPostBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResponseOtpVerifyV1AuthOtpVerifyPost> get serializer =>
      _$ResponseOtpVerifyV1AuthOtpVerifyPostSerializer();
}

extension ResponseOtpVerifyV1AuthOtpVerifyPostDiscriminatorExt
    on ResponseOtpVerifyV1AuthOtpVerifyPost {
  String? get discriminatorValue {
    if (this is PinRequiredOut) {
      return r'pin_required';
    }
    if (this is SessionOut) {
      return r'session';
    }
    return null;
  }
}

extension ResponseOtpVerifyV1AuthOtpVerifyPostBuilderDiscriminatorExt
    on ResponseOtpVerifyV1AuthOtpVerifyPostBuilder {
  String? get discriminatorValue {
    if (this is PinRequiredOutBuilder) {
      return r'pin_required';
    }
    if (this is SessionOutBuilder) {
      return r'session';
    }
    return null;
  }
}

class _$ResponseOtpVerifyV1AuthOtpVerifyPostSerializer
    implements PrimitiveSerializer<ResponseOtpVerifyV1AuthOtpVerifyPost> {
  @override
  final Iterable<Type> types = const [
    ResponseOtpVerifyV1AuthOtpVerifyPost,
    _$ResponseOtpVerifyV1AuthOtpVerifyPost
  ];

  @override
  final String wireName = r'ResponseOtpVerifyV1AuthOtpVerifyPost';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResponseOtpVerifyV1AuthOtpVerifyPost object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ResponseOtpVerifyV1AuthOtpVerifyPost object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ResponseOtpVerifyV1AuthOtpVerifyPost deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResponseOtpVerifyV1AuthOtpVerifyPostBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(
            ResponseOtpVerifyV1AuthOtpVerifyPost.discriminatorFieldName) +
        1;
    final discValue = serializers.deserialize(serializedList[discIndex],
        specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [
      PinRequiredOut,
      SessionOut,
    ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'pin_required':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(PinRequiredOut),
        ) as PinRequiredOut;
        oneOfType = PinRequiredOut;
        break;
      case r'session':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SessionOut),
        ) as SessionOut;
        oneOfType = SessionOut;
        break;
      default:
        throw UnsupportedError(
            "Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(
        typeIndex: oneOfTypes.indexOf(oneOfType),
        types: oneOfTypes,
        value: oneOfResult);
    return result.build();
  }
}

/// Discriminator: PIN step next.
class ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pin_required')
  static const ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum pinRequired =
      _$responseOtpVerifyV1AuthOtpVerifyPostKindEnum_pinRequired;

  static Serializer<ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum>
      get serializer =>
          _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumSerializer;

  const ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum._(String name)
      : super(name);

  static BuiltSet<ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum> get values =>
      _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumValues;
  static ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum valueOf(String name) =>
      _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumValueOf(name);
}
