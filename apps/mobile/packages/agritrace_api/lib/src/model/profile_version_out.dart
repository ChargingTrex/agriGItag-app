//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/profile_version_status.dart';
import 'package:agritrace_api/src/model/standards_profile_rules_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_version_out.g.dart';

/// One version of a profile with its rules (FR47).
///
/// Properties:
/// * [clauseRef] - Clause cited.
/// * [edition] - Edition of the standard cited.
/// * [id] - Version id; readings and grade computations reference it.
/// * [profileId] - Profile.
/// * [publishedAt] - When it was published.
/// * [rules] - The rules JSON.
/// * [status] - draft, published or retired.
/// * [versionNo] - Version number, 1 upwards.
@BuiltValue()
abstract class ProfileVersionOut
    implements Built<ProfileVersionOut, ProfileVersionOutBuilder> {
  /// Clause cited.
  @BuiltValueField(wireName: r'clause_ref')
  String get clauseRef;

  /// Edition of the standard cited.
  @BuiltValueField(wireName: r'edition')
  String get edition;

  /// Version id; readings and grade computations reference it.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Profile.
  @BuiltValueField(wireName: r'profile_id')
  String get profileId;

  /// When it was published.
  @BuiltValueField(wireName: r'published_at')
  DateTime? get publishedAt;

  /// The rules JSON.
  @BuiltValueField(wireName: r'rules')
  StandardsProfileRulesOutput get rules;

  /// draft, published or retired.
  @BuiltValueField(wireName: r'status')
  ProfileVersionStatus get status;
  // enum statusEnum {  draft,  published,  retired,  };

  /// Version number, 1 upwards.
  @BuiltValueField(wireName: r'version_no')
  int get versionNo;

  ProfileVersionOut._();

  factory ProfileVersionOut([void updates(ProfileVersionOutBuilder b)]) =
      _$ProfileVersionOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfileVersionOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfileVersionOut> get serializer =>
      _$ProfileVersionOutSerializer();
}

class _$ProfileVersionOutSerializer
    implements PrimitiveSerializer<ProfileVersionOut> {
  @override
  final Iterable<Type> types = const [ProfileVersionOut, _$ProfileVersionOut];

  @override
  final String wireName = r'ProfileVersionOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfileVersionOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clause_ref';
    yield serializers.serialize(
      object.clauseRef,
      specifiedType: const FullType(String),
    );
    yield r'edition';
    yield serializers.serialize(
      object.edition,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'profile_id';
    yield serializers.serialize(
      object.profileId,
      specifiedType: const FullType(String),
    );
    yield r'published_at';
    yield object.publishedAt == null
        ? null
        : serializers.serialize(
            object.publishedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'rules';
    yield serializers.serialize(
      object.rules,
      specifiedType: const FullType(StandardsProfileRulesOutput),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ProfileVersionStatus),
    );
    yield r'version_no';
    yield serializers.serialize(
      object.versionNo,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfileVersionOut object, {
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
    required ProfileVersionOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clause_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clauseRef = valueDes;
          break;
        case r'edition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.edition = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'profile_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.profileId = valueDes;
          break;
        case r'published_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.publishedAt = valueDes;
          break;
        case r'rules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandardsProfileRulesOutput),
          ) as StandardsProfileRulesOutput;
          result.rules.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProfileVersionStatus),
          ) as ProfileVersionStatus;
          result.status = valueDes;
          break;
        case r'version_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.versionNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfileVersionOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfileVersionOutBuilder();
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
