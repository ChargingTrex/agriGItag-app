// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producer_group_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProducerGroupKind _$shg = const ProducerGroupKind._('shg');
const ProducerGroupKind _$other = const ProducerGroupKind._('other');

ProducerGroupKind _$valueOf(String name) {
  switch (name) {
    case 'shg':
      return _$shg;
    case 'other':
      return _$other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProducerGroupKind> _$values =
    BuiltSet<ProducerGroupKind>(const <ProducerGroupKind>[
  _$shg,
  _$other,
]);

class _$ProducerGroupKindMeta {
  const _$ProducerGroupKindMeta();
  ProducerGroupKind get shg => _$shg;
  ProducerGroupKind get other => _$other;
  ProducerGroupKind valueOf(String name) => _$valueOf(name);
  BuiltSet<ProducerGroupKind> get values => _$values;
}

abstract class _$ProducerGroupKindMixin {
  // ignore: non_constant_identifier_names
  _$ProducerGroupKindMeta get ProducerGroupKind =>
      const _$ProducerGroupKindMeta();
}

Serializer<ProducerGroupKind> _$producerGroupKindSerializer =
    _$ProducerGroupKindSerializer();

class _$ProducerGroupKindSerializer
    implements PrimitiveSerializer<ProducerGroupKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'shg': 'shg',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'shg': 'shg',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[ProducerGroupKind];
  @override
  final String wireName = 'ProducerGroupKind';

  @override
  Object serialize(Serializers serializers, ProducerGroupKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProducerGroupKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProducerGroupKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
