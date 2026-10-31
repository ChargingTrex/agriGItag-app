//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_type.g.dart';

/// Event types sharing the one event_versions table (D-014; Stages 1–9; FR3, FR55).
class EventType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'land_preparation')
  static const EventType landPreparation = _$landPreparation;
  @BuiltValueEnumConst(wireName: r'nursery')
  static const EventType nursery = _$nursery;
  @BuiltValueEnumConst(wireName: r'sowing')
  static const EventType sowing = _$sowing;
  @BuiltValueEnumConst(wireName: r'input_application')
  static const EventType inputApplication = _$inputApplication;
  @BuiltValueEnumConst(wireName: r'harvest')
  static const EventType harvest = _$harvest;
  @BuiltValueEnumConst(wireName: r'drying')
  static const EventType drying = _$drying;
  @BuiltValueEnumConst(wireName: r'packing')
  static const EventType packing = _$packing;
  @BuiltValueEnumConst(wireName: r'problem')
  static const EventType problem = _$problem;
  @BuiltValueEnumConst(wireName: r'intake')
  static const EventType intake = _$intake;
  @BuiltValueEnumConst(wireName: r'grading')
  static const EventType grading = _$grading;
  @BuiltValueEnumConst(wireName: r'final_packing')
  static const EventType finalPacking = _$finalPacking;

  static Serializer<EventType> get serializer => _$eventTypeSerializer;

  const EventType._(String name) : super(name);

  static BuiltSet<EventType> get values => _$values;
  static EventType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class EventTypeMixin = Object with _$EventTypeMixin;
