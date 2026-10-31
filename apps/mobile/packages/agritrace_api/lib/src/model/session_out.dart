//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_out.g.dart';

/// A signed-in session: short-lived access token plus the device's refresh token.
///
/// Properties:
/// * [accessToken] - JWT for `Authorization: Bearer`; expires after `expires_in` s.
/// * [expiresIn] - Access token lifetime in seconds (900).
/// * [fpoId] - FPO the session is scoped to (the user's first membership).
/// * [kind] - Discriminator: a full session.
/// * [refreshToken] - Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients (`X-Client: web`), which receive it as an httpOnly cookie instead (D-022).
/// * [roles] - Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, `fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag.
@BuiltValue()
abstract class SessionOut implements Built<SessionOut, SessionOutBuilder> {
  /// JWT for `Authorization: Bearer`; expires after `expires_in` s.
  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  /// Access token lifetime in seconds (900).
  @BuiltValueField(wireName: r'expires_in')
  int get expiresIn;

  /// FPO the session is scoped to (the user's first membership).
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Discriminator: a full session.
  @BuiltValueField(wireName: r'kind')
  SessionOutKindEnum get kind;
  // enum kindEnum {  session,  };

  /// Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients (`X-Client: web`), which receive it as an httpOnly cookie instead (D-022).
  @BuiltValueField(wireName: r'refresh_token')
  String? get refreshToken;

  /// Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, `fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag.
  @BuiltValueField(wireName: r'roles')
  BuiltList<String> get roles;

  SessionOut._();

  factory SessionOut([void updates(SessionOutBuilder b)]) = _$SessionOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionOut> get serializer => _$SessionOutSerializer();
}

class _$SessionOutSerializer implements PrimitiveSerializer<SessionOut> {
  @override
  final Iterable<Type> types = const [SessionOut, _$SessionOut];

  @override
  final String wireName = r'SessionOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'access_token';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'expires_in';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(int),
    );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(SessionOutKindEnum),
    );
    yield r'refresh_token';
    yield object.refreshToken == null
        ? null
        : serializers.serialize(
            object.refreshToken,
            specifiedType: const FullType.nullable(String),
          );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SessionOut object, {
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
    required SessionOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SessionOutKindEnum),
          ) as SessionOutKindEnum;
          result.kind = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.refreshToken = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.roles.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SessionOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionOutBuilder();
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

/// Discriminator: a full session.
class SessionOutKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'session')
  static const SessionOutKindEnum session = _$sessionOutKindEnum_session;

  static Serializer<SessionOutKindEnum> get serializer =>
      _$sessionOutKindEnumSerializer;

  const SessionOutKindEnum._(String name) : super(name);

  static BuiltSet<SessionOutKindEnum> get values => _$sessionOutKindEnumValues;
  static SessionOutKindEnum valueOf(String name) =>
      _$sessionOutKindEnumValueOf(name);
}
