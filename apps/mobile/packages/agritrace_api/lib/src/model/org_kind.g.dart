// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OrgKind _$fpo = const OrgKind._('fpo');
const OrgKind _$company = const OrgKind._('company');
const OrgKind _$coop = const OrgKind._('coop');

OrgKind _$valueOf(String name) {
  switch (name) {
    case 'fpo':
      return _$fpo;
    case 'company':
      return _$company;
    case 'coop':
      return _$coop;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OrgKind> _$values = BuiltSet<OrgKind>(const <OrgKind>[
  _$fpo,
  _$company,
  _$coop,
]);

class _$OrgKindMeta {
  const _$OrgKindMeta();
  OrgKind get fpo => _$fpo;
  OrgKind get company => _$company;
  OrgKind get coop => _$coop;
  OrgKind valueOf(String name) => _$valueOf(name);
  BuiltSet<OrgKind> get values => _$values;
}

abstract class _$OrgKindMixin {
  // ignore: non_constant_identifier_names
  _$OrgKindMeta get OrgKind => const _$OrgKindMeta();
}

Serializer<OrgKind> _$orgKindSerializer = _$OrgKindSerializer();

class _$OrgKindSerializer implements PrimitiveSerializer<OrgKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fpo': 'fpo',
    'company': 'company',
    'coop': 'coop',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fpo': 'fpo',
    'company': 'company',
    'coop': 'coop',
  };

  @override
  final Iterable<Type> types = const <Type>[OrgKind];
  @override
  final String wireName = 'OrgKind';

  @override
  Object serialize(Serializers serializers, OrgKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OrgKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OrgKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
