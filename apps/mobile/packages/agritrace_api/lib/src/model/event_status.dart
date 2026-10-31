//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_status.g.dart';

/// Lifecycle of an event (FR25, FR59).
class EventStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const EventStatus draft = _$draft;
  @BuiltValueEnumConst(wireName: r'submitted')
  static const EventStatus submitted = _$submitted;
  @BuiltValueEnumConst(wireName: r'undone')
  static const EventStatus undone = _$undone;
  @BuiltValueEnumConst(wireName: r'superseded')
  static const EventStatus superseded = _$superseded;
  @BuiltValueEnumConst(wireName: r'locked')
  static const EventStatus locked = _$locked;

  static Serializer<EventStatus> get serializer => _$eventStatusSerializer;

  const EventStatus._(String name) : super(name);

  static BuiltSet<EventStatus> get values => _$values;
  static EventStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class EventStatusMixin = Object with _$EventStatusMixin;
