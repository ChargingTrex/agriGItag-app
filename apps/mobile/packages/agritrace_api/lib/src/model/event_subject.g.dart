// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_subject.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EventSubject _$lot = const EventSubject._('lot');
const EventSubject _$batch = const EventSubject._('batch');

EventSubject _$valueOf(String name) {
  switch (name) {
    case 'lot':
      return _$lot;
    case 'batch':
      return _$batch;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EventSubject> _$values =
    BuiltSet<EventSubject>(const <EventSubject>[
  _$lot,
  _$batch,
]);

class _$EventSubjectMeta {
  const _$EventSubjectMeta();
  EventSubject get lot => _$lot;
  EventSubject get batch => _$batch;
  EventSubject valueOf(String name) => _$valueOf(name);
  BuiltSet<EventSubject> get values => _$values;
}

abstract class _$EventSubjectMixin {
  // ignore: non_constant_identifier_names
  _$EventSubjectMeta get EventSubject => const _$EventSubjectMeta();
}

Serializer<EventSubject> _$eventSubjectSerializer = _$EventSubjectSerializer();

class _$EventSubjectSerializer implements PrimitiveSerializer<EventSubject> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'lot': 'lot',
    'batch': 'batch',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'lot': 'lot',
    'batch': 'batch',
  };

  @override
  final Iterable<Type> types = const <Type>[EventSubject];
  @override
  final String wireName = 'EventSubject';

  @override
  Object serialize(Serializers serializers, EventSubject object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EventSubject deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EventSubject.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
