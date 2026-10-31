//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_out.g.dart';

/// The signed-in user's own profile.
///
/// Properties:
/// * [id] - User id.
/// * [isSuperAdmin] - Platform compliance team flag.
/// * [lang] - Preferred UI language: `ta` or `en`.
/// * [name] - Display name in English script.
/// * [nameLocal] - Display name in the local script (Tamil).
/// * [phone] - The user's own mobile number, E.164.
@BuiltValue()
abstract class UserOut implements Built<UserOut, UserOutBuilder> {
  /// User id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Platform compliance team flag.
  @BuiltValueField(wireName: r'is_super_admin')
  bool get isSuperAdmin;

  /// Preferred UI language: `ta` or `en`.
  @BuiltValueField(wireName: r'lang')
  String get lang;

  /// Display name in English script.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Display name in the local script (Tamil).
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// The user's own mobile number, E.164.
  @BuiltValueField(wireName: r'phone')
  String get phone;

  UserOut._();

  factory UserOut([void updates(UserOutBuilder b)]) = _$UserOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserOut> get serializer => _$UserOutSerializer();
}

class _$UserOutSerializer implements PrimitiveSerializer<UserOut> {
  @override
  final Iterable<Type> types = const [UserOut, _$UserOut];

  @override
  final String wireName = r'UserOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'is_super_admin';
    yield serializers.serialize(
      object.isSuperAdmin,
      specifiedType: const FullType(bool),
    );
    yield r'lang';
    yield serializers.serialize(
      object.lang,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'name_local';
    yield object.nameLocal == null
        ? null
        : serializers.serialize(
            object.nameLocal,
            specifiedType: const FullType.nullable(String),
          );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserOut object, {
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
    required UserOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'is_super_admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSuperAdmin = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lang = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'name_local':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameLocal = valueDes;
          break;
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
  UserOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserOutBuilder();
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
