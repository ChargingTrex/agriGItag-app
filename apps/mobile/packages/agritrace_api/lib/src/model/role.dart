//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'role.g.dart';

/// A user's role inside one FPO (FR14, Dataflow §3 role matrix).
class Role extends EnumClass {
  @BuiltValueEnumConst(wireName: r'farmer')
  static const Role farmer = _$farmer;
  @BuiltValueEnumConst(wireName: r'field_officer')
  static const Role fieldOfficer = _$fieldOfficer;
  @BuiltValueEnumConst(wireName: r'qc_officer')
  static const Role qcOfficer = _$qcOfficer;
  @BuiltValueEnumConst(wireName: r'fpo_admin')
  static const Role fpoAdmin = _$fpoAdmin;
  @BuiltValueEnumConst(wireName: r'viewer')
  static const Role viewer = _$viewer;

  static Serializer<Role> get serializer => _$roleSerializer;

  const Role._(String name) : super(name);

  static BuiltSet<Role> get values => _$values;
  static Role valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RoleMixin = Object with _$RoleMixin;
