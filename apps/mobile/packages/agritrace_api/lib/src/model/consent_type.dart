//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'consent_type.g.dart';

/// What a farmer consented to (FR41, CLAUDE.md §6).
class ConsentType extends EnumClass {
  @BuiltValueEnumConst(wireName: r'data_collection')
  static const ConsentType dataCollection = _$dataCollection;
  @BuiltValueEnumConst(wireName: r'public_name')
  static const ConsentType publicName = _$publicName;
  @BuiltValueEnumConst(wireName: r'partner_share')
  static const ConsentType partnerShare = _$partnerShare;

  static Serializer<ConsentType> get serializer => _$consentTypeSerializer;

  const ConsentType._(String name) : super(name);

  static BuiltSet<ConsentType> get values => _$values;
  static ConsentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ConsentTypeMixin = Object with _$ConsentTypeMixin;
