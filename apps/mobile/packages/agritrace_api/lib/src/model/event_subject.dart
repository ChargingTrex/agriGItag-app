//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_subject.g.dart';

/// What a farm or processing event is recorded against (PRD §5).
class EventSubject extends EnumClass {
  @BuiltValueEnumConst(wireName: r'lot')
  static const EventSubject lot = _$lot;
  @BuiltValueEnumConst(wireName: r'batch')
  static const EventSubject batch = _$batch;

  static Serializer<EventSubject> get serializer => _$eventSubjectSerializer;

  const EventSubject._(String name) : super(name);

  static BuiltSet<EventSubject> get values => _$values;
  static EventSubject valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class EventSubjectMixin = Object with _$EventSubjectMixin;
