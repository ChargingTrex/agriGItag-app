//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_out.g.dart';

/// One role in one FPO.
///
/// Properties:
/// * [fpoId] - The FPO.
/// * [role] - Role inside that FPO.
@BuiltValue()
abstract class MembershipOut
    implements Built<MembershipOut, MembershipOutBuilder> {
  /// The FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Role inside that FPO.
  @BuiltValueField(wireName: r'role')
  Role get role;
  // enum roleEnum {  farmer,  field_officer,  qc_officer,  fpo_admin,  viewer,  };

  MembershipOut._();

  factory MembershipOut([void updates(MembershipOutBuilder b)]) =
      _$MembershipOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipOut> get serializer =>
      _$MembershipOutSerializer();
}

class _$MembershipOutSerializer implements PrimitiveSerializer<MembershipOut> {
  @override
  final Iterable<Type> types = const [MembershipOut, _$MembershipOut];

  @override
  final String wireName = r'MembershipOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(Role),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipOut object, {
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
    required MembershipOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Role),
          ) as Role;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipOutBuilder();
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
