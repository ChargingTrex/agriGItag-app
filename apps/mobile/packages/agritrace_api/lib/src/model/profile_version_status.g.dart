// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_version_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProfileVersionStatus _$draft = const ProfileVersionStatus._('draft');
const ProfileVersionStatus _$published =
    const ProfileVersionStatus._('published');
const ProfileVersionStatus _$retired = const ProfileVersionStatus._('retired');

ProfileVersionStatus _$valueOf(String name) {
  switch (name) {
    case 'draft':
      return _$draft;
    case 'published':
      return _$published;
    case 'retired':
      return _$retired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProfileVersionStatus> _$values =
    BuiltSet<ProfileVersionStatus>(const <ProfileVersionStatus>[
  _$draft,
  _$published,
  _$retired,
]);

class _$ProfileVersionStatusMeta {
  const _$ProfileVersionStatusMeta();
  ProfileVersionStatus get draft => _$draft;
  ProfileVersionStatus get published => _$published;
  ProfileVersionStatus get retired => _$retired;
  ProfileVersionStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ProfileVersionStatus> get values => _$values;
}

abstract class _$ProfileVersionStatusMixin {
  // ignore: non_constant_identifier_names
  _$ProfileVersionStatusMeta get ProfileVersionStatus =>
      const _$ProfileVersionStatusMeta();
}

Serializer<ProfileVersionStatus> _$profileVersionStatusSerializer =
    _$ProfileVersionStatusSerializer();

class _$ProfileVersionStatusSerializer
    implements PrimitiveSerializer<ProfileVersionStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'published': 'published',
    'retired': 'retired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'published': 'published',
    'retired': 'retired',
  };

  @override
  final Iterable<Type> types = const <Type>[ProfileVersionStatus];
  @override
  final String wireName = 'ProfileVersionStatus';

  @override
  Object serialize(Serializers serializers, ProfileVersionStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProfileVersionStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProfileVersionStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
