//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'irrigation_source.g.dart';

/// Water source of an irrigated plot (FR54).
class IrrigationSource extends EnumClass {
  @BuiltValueEnumConst(wireName: r'well')
  static const IrrigationSource well = _$well;
  @BuiltValueEnumConst(wireName: r'borewell')
  static const IrrigationSource borewell = _$borewell;
  @BuiltValueEnumConst(wireName: r'canal')
  static const IrrigationSource canal = _$canal;
  @BuiltValueEnumConst(wireName: r'tank')
  static const IrrigationSource tank = _$tank;
  @BuiltValueEnumConst(wireName: r'rain')
  static const IrrigationSource rain = _$rain;

  static Serializer<IrrigationSource> get serializer =>
      _$irrigationSourceSerializer;

  const IrrigationSource._(String name) : super(name);

  static BuiltSet<IrrigationSource> get values => _$values;
  static IrrigationSource valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class IrrigationSourceMixin = Object with _$IrrigationSourceMixin;
