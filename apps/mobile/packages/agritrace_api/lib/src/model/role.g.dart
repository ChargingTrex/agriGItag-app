// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Role _$farmer = const Role._('farmer');
const Role _$fieldOfficer = const Role._('fieldOfficer');
const Role _$qcOfficer = const Role._('qcOfficer');
const Role _$fpoAdmin = const Role._('fpoAdmin');
const Role _$viewer = const Role._('viewer');

Role _$valueOf(String name) {
  switch (name) {
    case 'farmer':
      return _$farmer;
    case 'fieldOfficer':
      return _$fieldOfficer;
    case 'qcOfficer':
      return _$qcOfficer;
    case 'fpoAdmin':
      return _$fpoAdmin;
    case 'viewer':
      return _$viewer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Role> _$values = BuiltSet<Role>(const <Role>[
  _$farmer,
  _$fieldOfficer,
  _$qcOfficer,
  _$fpoAdmin,
  _$viewer,
]);

class _$RoleMeta {
  const _$RoleMeta();
  Role get farmer => _$farmer;
  Role get fieldOfficer => _$fieldOfficer;
  Role get qcOfficer => _$qcOfficer;
  Role get fpoAdmin => _$fpoAdmin;
  Role get viewer => _$viewer;
  Role valueOf(String name) => _$valueOf(name);
  BuiltSet<Role> get values => _$values;
}

abstract class _$RoleMixin {
  // ignore: non_constant_identifier_names
  _$RoleMeta get Role => const _$RoleMeta();
}

Serializer<Role> _$roleSerializer = _$RoleSerializer();

class _$RoleSerializer implements PrimitiveSerializer<Role> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'farmer': 'farmer',
    'fieldOfficer': 'field_officer',
    'qcOfficer': 'qc_officer',
    'fpoAdmin': 'fpo_admin',
    'viewer': 'viewer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'farmer': 'farmer',
    'field_officer': 'fieldOfficer',
    'qc_officer': 'qcOfficer',
    'fpo_admin': 'fpoAdmin',
    'viewer': 'viewer',
  };

  @override
  final Iterable<Type> types = const <Type>[Role];
  @override
  final String wireName = 'Role';

  @override
  Object serialize(Serializers serializers, Role object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  Role deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Role.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
