//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standards_scheme.g.dart';

/// Grading scheme of a standards profile (FR47).
class StandardsScheme extends EnumClass {
  @BuiltValueEnumConst(wireName: r'agmark')
  static const StandardsScheme agmark = _$agmark;
  @BuiltValueEnumConst(wireName: r'iso')
  static const StandardsScheme iso = _$iso;
  @BuiltValueEnumConst(wireName: r'fssai')
  static const StandardsScheme fssai = _$fssai;
  @BuiltValueEnumConst(wireName: r'custom')
  static const StandardsScheme custom = _$custom;

  static Serializer<StandardsScheme> get serializer =>
      _$standardsSchemeSerializer;

  const StandardsScheme._(String name) : super(name);

  static BuiltSet<StandardsScheme> get values => _$values;
  static StandardsScheme valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class StandardsSchemeMixin = Object with _$StandardsSchemeMixin;
