//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pin_method.g.dart';

/// How a plot pin was placed (FR64).
class PinMethod extends EnumClass {
  @BuiltValueEnumConst(wireName: r'live_gps')
  static const PinMethod liveGps = _$liveGps;
  @BuiltValueEnumConst(wireName: r'map_pin')
  static const PinMethod mapPin = _$mapPin;

  static Serializer<PinMethod> get serializer => _$pinMethodSerializer;

  const PinMethod._(String name) : super(name);

  static BuiltSet<PinMethod> get values => _$values;
  static PinMethod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PinMethodMixin = Object with _$PinMethodMixin;
