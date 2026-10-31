// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadingSource _$lab = const ReadingSource._('lab');
const ReadingSource _$instrument = const ReadingSource._('instrument');
const ReadingSource _$visual = const ReadingSource._('visual');

ReadingSource _$valueOf(String name) {
  switch (name) {
    case 'lab':
      return _$lab;
    case 'instrument':
      return _$instrument;
    case 'visual':
      return _$visual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadingSource> _$values =
    BuiltSet<ReadingSource>(const <ReadingSource>[
  _$lab,
  _$instrument,
  _$visual,
]);

class _$ReadingSourceMeta {
  const _$ReadingSourceMeta();
  ReadingSource get lab => _$lab;
  ReadingSource get instrument => _$instrument;
  ReadingSource get visual => _$visual;
  ReadingSource valueOf(String name) => _$valueOf(name);
  BuiltSet<ReadingSource> get values => _$values;
}

abstract class _$ReadingSourceMixin {
  // ignore: non_constant_identifier_names
  _$ReadingSourceMeta get ReadingSource => const _$ReadingSourceMeta();
}

Serializer<ReadingSource> _$readingSourceSerializer =
    _$ReadingSourceSerializer();

class _$ReadingSourceSerializer implements PrimitiveSerializer<ReadingSource> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'lab': 'lab',
    'instrument': 'instrument',
    'visual': 'visual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'lab': 'lab',
    'instrument': 'instrument',
    'visual': 'visual',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadingSource];
  @override
  final String wireName = 'ReadingSource';

  @override
  Object serialize(Serializers serializers, ReadingSource object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadingSource deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadingSource.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
