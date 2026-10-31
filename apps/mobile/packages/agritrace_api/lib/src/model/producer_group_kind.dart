//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'producer_group_kind.g.dart';

/// Kind of producer group (flag `producer_groups`, D-017).
class ProducerGroupKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'shg')
  static const ProducerGroupKind shg = _$shg;
  @BuiltValueEnumConst(wireName: r'other')
  static const ProducerGroupKind other = _$other;

  static Serializer<ProducerGroupKind> get serializer =>
      _$producerGroupKindSerializer;

  const ProducerGroupKind._(String name) : super(name);

  static BuiltSet<ProducerGroupKind> get values => _$values;
  static ProducerGroupKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ProducerGroupKindMixin = Object with _$ProducerGroupKindMixin;
