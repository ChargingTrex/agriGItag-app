//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input_category.g.dart';

/// Category of a farm input; practice tags are derived from it (FR56).
class InputCategory extends EnumClass {
  @BuiltValueEnumConst(wireName: r'chemical_fertilizer')
  static const InputCategory chemicalFertilizer = _$chemicalFertilizer;
  @BuiltValueEnumConst(wireName: r'organic_fertilizer')
  static const InputCategory organicFertilizer = _$organicFertilizer;
  @BuiltValueEnumConst(wireName: r'bio_fertilizer')
  static const InputCategory bioFertilizer = _$bioFertilizer;
  @BuiltValueEnumConst(wireName: r'chemical_pesticide')
  static const InputCategory chemicalPesticide = _$chemicalPesticide;
  @BuiltValueEnumConst(wireName: r'bio_pesticide')
  static const InputCategory bioPesticide = _$bioPesticide;
  @BuiltValueEnumConst(wireName: r'other')
  static const InputCategory other = _$other;

  static Serializer<InputCategory> get serializer => _$inputCategorySerializer;

  const InputCategory._(String name) : super(name);

  static BuiltSet<InputCategory> get values => _$values;
  static InputCategory valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class InputCategoryMixin = Object with _$InputCategoryMixin;
