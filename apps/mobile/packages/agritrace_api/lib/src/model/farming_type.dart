//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farming_type.g.dart';

/// Irrigated or rainfed farming (FR54).
class FarmingType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'irrigated')
  static const FarmingType irrigated = _$irrigated;
  @BuiltValueEnumConst(wireName: r'rainfed')
  static const FarmingType rainfed = _$rainfed;

  static Serializer<FarmingType> get serializer => _$farmingTypeSerializer;

  const FarmingType._(String name) : super(name);

  static BuiltSet<FarmingType> get values => _$values;
  static FarmingType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FarmingTypeMixin = Object with _$FarmingTypeMixin;
