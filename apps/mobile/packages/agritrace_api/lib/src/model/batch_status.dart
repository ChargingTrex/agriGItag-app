//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_status.g.dart';

/// Batch lifecycle (Stages 7–10).
class BatchStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'created')
  static const BatchStatus created = _$created;
  @BuiltValueEnumConst(wireName: r'graded')
  static const BatchStatus graded = _$graded;
  @BuiltValueEnumConst(wireName: r'packed')
  static const BatchStatus packed = _$packed;
  @BuiltValueEnumConst(wireName: r'published')
  static const BatchStatus published = _$published;

  static Serializer<BatchStatus> get serializer => _$batchStatusSerializer;

  const BatchStatus._(String name) : super(name);

  static BuiltSet<BatchStatus> get values => _$values;
  static BatchStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class BatchStatusMixin = Object with _$BatchStatusMixin;
