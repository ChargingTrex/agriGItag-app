//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/standards_profile_rules_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_version_in.g.dart';

/// A new version of a profile's rules, created by the compliance team (super-admin, FR47).
///
/// Properties:
/// * [allowIncomplete] - Required to publish while a grading parameter is still `load_from_standard`; the grade is then computed from the other parameters and a `public_note` is stamped if none is given.
/// * [rules] - The rules JSON (backend-design.md §4).
/// * [status] - `published` makes it the version used for new readings and retires the previous one.
@BuiltValue()
abstract class ProfileVersionIn
    implements Built<ProfileVersionIn, ProfileVersionInBuilder> {
  /// Required to publish while a grading parameter is still `load_from_standard`; the grade is then computed from the other parameters and a `public_note` is stamped if none is given.
  @BuiltValueField(wireName: r'allow_incomplete')
  bool? get allowIncomplete;

  /// The rules JSON (backend-design.md §4).
  @BuiltValueField(wireName: r'rules')
  StandardsProfileRulesInput get rules;

  /// `published` makes it the version used for new readings and retires the previous one.
  @BuiltValueField(wireName: r'status')
  ProfileVersionInStatusEnum? get status;
  // enum statusEnum {  draft,  published,  };

  ProfileVersionIn._();

  factory ProfileVersionIn([void updates(ProfileVersionInBuilder b)]) =
      _$ProfileVersionIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfileVersionInBuilder b) => b
    ..allowIncomplete = false
    ..status = ProfileVersionInStatusEnum.valueOf('published');

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfileVersionIn> get serializer =>
      _$ProfileVersionInSerializer();
}

class _$ProfileVersionInSerializer
    implements PrimitiveSerializer<ProfileVersionIn> {
  @override
  final Iterable<Type> types = const [ProfileVersionIn, _$ProfileVersionIn];

  @override
  final String wireName = r'ProfileVersionIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfileVersionIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.allowIncomplete != null) {
      yield r'allow_incomplete';
      yield serializers.serialize(
        object.allowIncomplete,
        specifiedType: const FullType(bool),
      );
    }
    yield r'rules';
    yield serializers.serialize(
      object.rules,
      specifiedType: const FullType(StandardsProfileRulesInput),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ProfileVersionInStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfileVersionIn object, {
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
    required ProfileVersionInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'allow_incomplete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.allowIncomplete = valueDes;
          break;
        case r'rules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandardsProfileRulesInput),
          ) as StandardsProfileRulesInput;
          result.rules.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProfileVersionInStatusEnum),
          ) as ProfileVersionInStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfileVersionIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfileVersionInBuilder();
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

/// `published` makes it the version used for new readings and retires the previous one.
class ProfileVersionInStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const ProfileVersionInStatusEnum draft =
      _$profileVersionInStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'published')
  static const ProfileVersionInStatusEnum published =
      _$profileVersionInStatusEnum_published;

  static Serializer<ProfileVersionInStatusEnum> get serializer =>
      _$profileVersionInStatusEnumSerializer;

  const ProfileVersionInStatusEnum._(String name) : super(name);

  static BuiltSet<ProfileVersionInStatusEnum> get values =>
      _$profileVersionInStatusEnumValues;
  static ProfileVersionInStatusEnum valueOf(String name) =>
      _$profileVersionInStatusEnumValueOf(name);
}
