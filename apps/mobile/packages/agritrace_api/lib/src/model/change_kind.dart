//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_kind.g.dart';

/// Why an event version exists (FR25 corrections with reason, FR59 system entries).
class ChangeKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'create')
  static const ChangeKind create = _$create;
  @BuiltValueEnumConst(wireName: r'correct')
  static const ChangeKind correct = _$correct;
  @BuiltValueEnumConst(wireName: r'undo')
  static const ChangeKind undo = _$undo;
  @BuiltValueEnumConst(wireName: r'system')
  static const ChangeKind system = _$system;

  static Serializer<ChangeKind> get serializer => _$changeKindSerializer;

  const ChangeKind._(String name) : super(name);

  static BuiltSet<ChangeKind> get values => _$values;
  static ChangeKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ChangeKindMixin = Object with _$ChangeKindMixin;
