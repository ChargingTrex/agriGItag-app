//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reading_stage.g.dart';

/// Where in the chain a quality reading was taken (FR43, FR45).
class ReadingStage extends EnumClass {
  @BuiltValueEnumConst(wireName: r'drying_end')
  static const ReadingStage dryingEnd = _$dryingEnd;
  @BuiltValueEnumConst(wireName: r'intake')
  static const ReadingStage intake = _$intake;
  @BuiltValueEnumConst(wireName: r'grading')
  static const ReadingStage grading = _$grading;
  @BuiltValueEnumConst(wireName: r'storage')
  static const ReadingStage storage = _$storage;

  static Serializer<ReadingStage> get serializer => _$readingStageSerializer;

  const ReadingStage._(String name) : super(name);

  static BuiltSet<ReadingStage> get values => _$values;
  static ReadingStage valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ReadingStageMixin = Object with _$ReadingStageMixin;
