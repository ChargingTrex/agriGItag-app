//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'org_kind.g.dart';

/// Legal form of an FPO or processor (PRD §5 Processor / FPO entity).
class OrgKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fpo')
  static const OrgKind fpo = _$fpo;
  @BuiltValueEnumConst(wireName: r'company')
  static const OrgKind company = _$company;
  @BuiltValueEnumConst(wireName: r'coop')
  static const OrgKind coop = _$coop;

  static Serializer<OrgKind> get serializer => _$orgKindSerializer;

  const OrgKind._(String name) : super(name);

  static BuiltSet<OrgKind> get values => _$values;
  static OrgKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class OrgKindMixin = Object with _$OrgKindMixin;
