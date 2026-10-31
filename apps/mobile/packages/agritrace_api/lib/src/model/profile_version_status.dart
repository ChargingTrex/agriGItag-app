//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_version_status.g.dart';

/// Publication state of a standards profile version (FR47).
class ProfileVersionStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const ProfileVersionStatus draft = _$draft;
  @BuiltValueEnumConst(wireName: r'published')
  static const ProfileVersionStatus published = _$published;
  @BuiltValueEnumConst(wireName: r'retired')
  static const ProfileVersionStatus retired = _$retired;

  static Serializer<ProfileVersionStatus> get serializer =>
      _$profileVersionStatusSerializer;

  const ProfileVersionStatus._(String name) : super(name);

  static BuiltSet<ProfileVersionStatus> get values => _$values;
  static ProfileVersionStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ProfileVersionStatusMixin = Object
    with _$ProfileVersionStatusMixin;
