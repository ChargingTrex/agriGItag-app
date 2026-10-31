// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standards_scheme.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandardsScheme _$agmark = const StandardsScheme._('agmark');
const StandardsScheme _$iso = const StandardsScheme._('iso');
const StandardsScheme _$fssai = const StandardsScheme._('fssai');
const StandardsScheme _$custom = const StandardsScheme._('custom');

StandardsScheme _$valueOf(String name) {
  switch (name) {
    case 'agmark':
      return _$agmark;
    case 'iso':
      return _$iso;
    case 'fssai':
      return _$fssai;
    case 'custom':
      return _$custom;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandardsScheme> _$values =
    BuiltSet<StandardsScheme>(const <StandardsScheme>[
  _$agmark,
  _$iso,
  _$fssai,
  _$custom,
]);

class _$StandardsSchemeMeta {
  const _$StandardsSchemeMeta();
  StandardsScheme get agmark => _$agmark;
  StandardsScheme get iso => _$iso;
  StandardsScheme get fssai => _$fssai;
  StandardsScheme get custom => _$custom;
  StandardsScheme valueOf(String name) => _$valueOf(name);
  BuiltSet<StandardsScheme> get values => _$values;
}

abstract class _$StandardsSchemeMixin {
  // ignore: non_constant_identifier_names
  _$StandardsSchemeMeta get StandardsScheme => const _$StandardsSchemeMeta();
}

Serializer<StandardsScheme> _$standardsSchemeSerializer =
    _$StandardsSchemeSerializer();

class _$StandardsSchemeSerializer
    implements PrimitiveSerializer<StandardsScheme> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'agmark': 'agmark',
    'iso': 'iso',
    'fssai': 'fssai',
    'custom': 'custom',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'agmark': 'agmark',
    'iso': 'iso',
    'fssai': 'fssai',
    'custom': 'custom',
  };

  @override
  final Iterable<Type> types = const <Type>[StandardsScheme];
  @override
  final String wireName = 'StandardsScheme';

  @override
  Object serialize(Serializers serializers, StandardsScheme object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandardsScheme deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandardsScheme.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
