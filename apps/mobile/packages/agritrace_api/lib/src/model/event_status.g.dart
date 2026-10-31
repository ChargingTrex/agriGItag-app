// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EventStatus _$draft = const EventStatus._('draft');
const EventStatus _$submitted = const EventStatus._('submitted');
const EventStatus _$undone = const EventStatus._('undone');
const EventStatus _$superseded = const EventStatus._('superseded');
const EventStatus _$locked = const EventStatus._('locked');

EventStatus _$valueOf(String name) {
  switch (name) {
    case 'draft':
      return _$draft;
    case 'submitted':
      return _$submitted;
    case 'undone':
      return _$undone;
    case 'superseded':
      return _$superseded;
    case 'locked':
      return _$locked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EventStatus> _$values =
    BuiltSet<EventStatus>(const <EventStatus>[
  _$draft,
  _$submitted,
  _$undone,
  _$superseded,
  _$locked,
]);

class _$EventStatusMeta {
  const _$EventStatusMeta();
  EventStatus get draft => _$draft;
  EventStatus get submitted => _$submitted;
  EventStatus get undone => _$undone;
  EventStatus get superseded => _$superseded;
  EventStatus get locked => _$locked;
  EventStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<EventStatus> get values => _$values;
}

abstract class _$EventStatusMixin {
  // ignore: non_constant_identifier_names
  _$EventStatusMeta get EventStatus => const _$EventStatusMeta();
}

Serializer<EventStatus> _$eventStatusSerializer = _$EventStatusSerializer();

class _$EventStatusSerializer implements PrimitiveSerializer<EventStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'submitted': 'submitted',
    'undone': 'undone',
    'superseded': 'superseded',
    'locked': 'locked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'submitted': 'submitted',
    'undone': 'undone',
    'superseded': 'superseded',
    'locked': 'locked',
  };

  @override
  final Iterable<Type> types = const <Type>[EventStatus];
  @override
  final String wireName = 'EventStatus';

  @override
  Object serialize(Serializers serializers, EventStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EventStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EventStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
