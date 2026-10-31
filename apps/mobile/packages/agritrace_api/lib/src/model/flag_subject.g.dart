// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_subject.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FlagSubject _$plot = const FlagSubject._('plot');
const FlagSubject _$event = const FlagSubject._('event');
const FlagSubject _$lot = const FlagSubject._('lot');
const FlagSubject _$batch = const FlagSubject._('batch');
const FlagSubject _$reading = const FlagSubject._('reading');

FlagSubject _$valueOf(String name) {
  switch (name) {
    case 'plot':
      return _$plot;
    case 'event':
      return _$event;
    case 'lot':
      return _$lot;
    case 'batch':
      return _$batch;
    case 'reading':
      return _$reading;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FlagSubject> _$values =
    BuiltSet<FlagSubject>(const <FlagSubject>[
  _$plot,
  _$event,
  _$lot,
  _$batch,
  _$reading,
]);

class _$FlagSubjectMeta {
  const _$FlagSubjectMeta();
  FlagSubject get plot => _$plot;
  FlagSubject get event => _$event;
  FlagSubject get lot => _$lot;
  FlagSubject get batch => _$batch;
  FlagSubject get reading => _$reading;
  FlagSubject valueOf(String name) => _$valueOf(name);
  BuiltSet<FlagSubject> get values => _$values;
}

abstract class _$FlagSubjectMixin {
  // ignore: non_constant_identifier_names
  _$FlagSubjectMeta get FlagSubject => const _$FlagSubjectMeta();
}

Serializer<FlagSubject> _$flagSubjectSerializer = _$FlagSubjectSerializer();

class _$FlagSubjectSerializer implements PrimitiveSerializer<FlagSubject> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'plot': 'plot',
    'event': 'event',
    'lot': 'lot',
    'batch': 'batch',
    'reading': 'reading',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'plot': 'plot',
    'event': 'event',
    'lot': 'lot',
    'batch': 'batch',
    'reading': 'reading',
  };

  @override
  final Iterable<Type> types = const <Type>[FlagSubject];
  @override
  final String wireName = 'FlagSubject';

  @override
  Object serialize(Serializers serializers, FlagSubject object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FlagSubject deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FlagSubject.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
