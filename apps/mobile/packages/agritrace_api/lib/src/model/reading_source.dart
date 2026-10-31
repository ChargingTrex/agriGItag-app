//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reading_source.g.dart';

/// How a quality value was measured (FR42, FR44).
class ReadingSource extends EnumClass {
  @BuiltValueEnumConst(wireName: r'lab')
  static const ReadingSource lab = _$lab;
  @BuiltValueEnumConst(wireName: r'instrument')
  static const ReadingSource instrument = _$instrument;
  @BuiltValueEnumConst(wireName: r'visual')
  static const ReadingSource visual = _$visual;

  static Serializer<ReadingSource> get serializer => _$readingSourceSerializer;

  const ReadingSource._(String name) : super(name);

  static BuiltSet<ReadingSource> get values => _$values;
  static ReadingSource valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ReadingSourceMixin = Object with _$ReadingSourceMixin;
