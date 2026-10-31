//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'practice_tag.g.dart';

/// Farming practice label declared by the farmer or derived from inputs (FR56, PRD §5).
class PracticeTag extends EnumClass {
  @BuiltValueEnumConst(wireName: r'organic')
  static const PracticeTag organic = _$organic;
  @BuiltValueEnumConst(wireName: r'inorganic')
  static const PracticeTag inorganic = _$inorganic;
  @BuiltValueEnumConst(wireName: r'ipm')
  static const PracticeTag ipm = _$ipm;

  static Serializer<PracticeTag> get serializer => _$practiceTagSerializer;

  const PracticeTag._(String name) : super(name);

  static BuiltSet<PracticeTag> get values => _$values;
  static PracticeTag valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PracticeTagMixin = Object with _$PracticeTagMixin;
