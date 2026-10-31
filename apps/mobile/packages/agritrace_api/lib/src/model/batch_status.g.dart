// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BatchStatus _$created = const BatchStatus._('created');
const BatchStatus _$graded = const BatchStatus._('graded');
const BatchStatus _$packed = const BatchStatus._('packed');
const BatchStatus _$published = const BatchStatus._('published');

BatchStatus _$valueOf(String name) {
  switch (name) {
    case 'created':
      return _$created;
    case 'graded':
      return _$graded;
    case 'packed':
      return _$packed;
    case 'published':
      return _$published;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BatchStatus> _$values =
    BuiltSet<BatchStatus>(const <BatchStatus>[
  _$created,
  _$graded,
  _$packed,
  _$published,
]);

class _$BatchStatusMeta {
  const _$BatchStatusMeta();
  BatchStatus get created => _$created;
  BatchStatus get graded => _$graded;
  BatchStatus get packed => _$packed;
  BatchStatus get published => _$published;
  BatchStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<BatchStatus> get values => _$values;
}

abstract class _$BatchStatusMixin {
  // ignore: non_constant_identifier_names
  _$BatchStatusMeta get BatchStatus => const _$BatchStatusMeta();
}

Serializer<BatchStatus> _$batchStatusSerializer = _$BatchStatusSerializer();

class _$BatchStatusSerializer implements PrimitiveSerializer<BatchStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'created': 'created',
    'graded': 'graded',
    'packed': 'packed',
    'published': 'published',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'created': 'created',
    'graded': 'graded',
    'packed': 'packed',
    'published': 'published',
  };

  @override
  final Iterable<Type> types = const <Type>[BatchStatus];
  @override
  final String wireName = 'BatchStatus';

  @override
  Object serialize(Serializers serializers, BatchStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BatchStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BatchStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
