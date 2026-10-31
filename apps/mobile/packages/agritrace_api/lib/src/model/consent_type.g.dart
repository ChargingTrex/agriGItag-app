// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ConsentType _$dataCollection = const ConsentType._('dataCollection');
const ConsentType _$publicName = const ConsentType._('publicName');
const ConsentType _$partnerShare = const ConsentType._('partnerShare');

ConsentType _$valueOf(String name) {
  switch (name) {
    case 'dataCollection':
      return _$dataCollection;
    case 'publicName':
      return _$publicName;
    case 'partnerShare':
      return _$partnerShare;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ConsentType> _$values =
    BuiltSet<ConsentType>(const <ConsentType>[
  _$dataCollection,
  _$publicName,
  _$partnerShare,
]);

class _$ConsentTypeMeta {
  const _$ConsentTypeMeta();
  ConsentType get dataCollection => _$dataCollection;
  ConsentType get publicName => _$publicName;
  ConsentType get partnerShare => _$partnerShare;
  ConsentType valueOf(String name) => _$valueOf(name);
  BuiltSet<ConsentType> get values => _$values;
}

abstract class _$ConsentTypeMixin {
  // ignore: non_constant_identifier_names
  _$ConsentTypeMeta get ConsentType => const _$ConsentTypeMeta();
}

Serializer<ConsentType> _$consentTypeSerializer = _$ConsentTypeSerializer();

class _$ConsentTypeSerializer implements PrimitiveSerializer<ConsentType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dataCollection': 'data_collection',
    'publicName': 'public_name',
    'partnerShare': 'partner_share',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'data_collection': 'dataCollection',
    'public_name': 'publicName',
    'partner_share': 'partnerShare',
  };

  @override
  final Iterable<Type> types = const <Type>[ConsentType];
  @override
  final String wireName = 'ConsentType';

  @override
  Object serialize(Serializers serializers, ConsentType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ConsentType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ConsentType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
