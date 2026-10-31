//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_status.g.dart';

/// Flag resolution state (FR70).
class FlagStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const FlagStatus open = _$open;
  @BuiltValueEnumConst(wireName: r'cleared')
  static const FlagStatus cleared = _$cleared;
  @BuiltValueEnumConst(wireName: r'fixed')
  static const FlagStatus fixed = _$fixed;
  @BuiltValueEnumConst(wireName: r'escalated')
  static const FlagStatus escalated = _$escalated;

  static Serializer<FlagStatus> get serializer => _$flagStatusSerializer;

  const FlagStatus._(String name) : super(name);

  static BuiltSet<FlagStatus> get values => _$values;
  static FlagStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FlagStatusMixin = Object with _$FlagStatusMixin;
