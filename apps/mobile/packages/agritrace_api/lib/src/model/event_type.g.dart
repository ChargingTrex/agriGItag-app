// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EventType _$landPreparation = const EventType._('landPreparation');
const EventType _$nursery = const EventType._('nursery');
const EventType _$sowing = const EventType._('sowing');
const EventType _$inputApplication = const EventType._('inputApplication');
const EventType _$harvest = const EventType._('harvest');
const EventType _$drying = const EventType._('drying');
const EventType _$packing = const EventType._('packing');
const EventType _$problem = const EventType._('problem');
const EventType _$intake = const EventType._('intake');
const EventType _$grading = const EventType._('grading');
const EventType _$finalPacking = const EventType._('finalPacking');

EventType _$valueOf(String name) {
  switch (name) {
    case 'landPreparation':
      return _$landPreparation;
    case 'nursery':
      return _$nursery;
    case 'sowing':
      return _$sowing;
    case 'inputApplication':
      return _$inputApplication;
    case 'harvest':
      return _$harvest;
    case 'drying':
      return _$drying;
    case 'packing':
      return _$packing;
    case 'problem':
      return _$problem;
    case 'intake':
      return _$intake;
    case 'grading':
      return _$grading;
    case 'finalPacking':
      return _$finalPacking;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EventType> _$values = BuiltSet<EventType>(const <EventType>[
  _$landPreparation,
  _$nursery,
  _$sowing,
  _$inputApplication,
  _$harvest,
  _$drying,
  _$packing,
  _$problem,
  _$intake,
  _$grading,
  _$finalPacking,
]);

class _$EventTypeMeta {
  const _$EventTypeMeta();
  EventType get landPreparation => _$landPreparation;
  EventType get nursery => _$nursery;
  EventType get sowing => _$sowing;
  EventType get inputApplication => _$inputApplication;
  EventType get harvest => _$harvest;
  EventType get drying => _$drying;
  EventType get packing => _$packing;
  EventType get problem => _$problem;
  EventType get intake => _$intake;
  EventType get grading => _$grading;
  EventType get finalPacking => _$finalPacking;
  EventType valueOf(String name) => _$valueOf(name);
  BuiltSet<EventType> get values => _$values;
}

abstract class _$EventTypeMixin {
  // ignore: non_constant_identifier_names
  _$EventTypeMeta get EventType => const _$EventTypeMeta();
}

Serializer<EventType> _$eventTypeSerializer = _$EventTypeSerializer();

class _$EventTypeSerializer implements PrimitiveSerializer<EventType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'landPreparation': 'land_preparation',
    'nursery': 'nursery',
    'sowing': 'sowing',
    'inputApplication': 'input_application',
    'harvest': 'harvest',
    'drying': 'drying',
    'packing': 'packing',
    'problem': 'problem',
    'intake': 'intake',
    'grading': 'grading',
    'finalPacking': 'final_packing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'land_preparation': 'landPreparation',
    'nursery': 'nursery',
    'sowing': 'sowing',
    'input_application': 'inputApplication',
    'harvest': 'harvest',
    'drying': 'drying',
    'packing': 'packing',
    'problem': 'problem',
    'intake': 'intake',
    'grading': 'grading',
    'final_packing': 'finalPacking',
  };

  @override
  final Iterable<Type> types = const <Type>[EventType];
  @override
  final String wireName = 'EventType';

  @override
  Object serialize(Serializers serializers, EventType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EventType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EventType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
