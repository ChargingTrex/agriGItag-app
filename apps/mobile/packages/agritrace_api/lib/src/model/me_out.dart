//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/membership_out.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/user_out.dart';
import 'package:agritrace_api/src/model/device_out.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_out.g.dart';

/// Who is signed in, where, and on which device.
///
/// Properties:
/// * [device] - The device of this session; null if it was deleted.
/// * [memberships] - Every FPO role of the user, oldest first.
/// * [user] - The user.
@BuiltValue()
abstract class MeOut implements Built<MeOut, MeOutBuilder> {
  /// The device of this session; null if it was deleted.
  @BuiltValueField(wireName: r'device')
  DeviceOut? get device;

  /// Every FPO role of the user, oldest first.
  @BuiltValueField(wireName: r'memberships')
  BuiltList<MembershipOut> get memberships;

  /// The user.
  @BuiltValueField(wireName: r'user')
  UserOut get user;

  MeOut._();

  factory MeOut([void updates(MeOutBuilder b)]) = _$MeOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeOut> get serializer => _$MeOutSerializer();
}

class _$MeOutSerializer implements PrimitiveSerializer<MeOut> {
  @override
  final Iterable<Type> types = const [MeOut, _$MeOut];

  @override
  final String wireName = r'MeOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device';
    yield object.device == null
        ? null
        : serializers.serialize(
            object.device,
            specifiedType: const FullType.nullable(DeviceOut),
          );
    yield r'memberships';
    yield serializers.serialize(
      object.memberships,
      specifiedType: const FullType(BuiltList, [FullType(MembershipOut)]),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserOut),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeOut object, {
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
    required MeOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DeviceOut),
          ) as DeviceOut?;
          if (valueDes == null) continue;
          result.device.replace(valueDes);
          break;
        case r'memberships':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MembershipOut)]),
          ) as BuiltList<MembershipOut>;
          result.memberships.replace(valueDes);
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserOut),
          ) as UserOut;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeOutBuilder();
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
