//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_status.g.dart';

/// Farmer onboarding state (Stage 0; FR67 activates on a confirmed location).
class FarmerStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const FarmerStatus pending = _$pending;
  @BuiltValueEnumConst(wireName: r'active')
  static const FarmerStatus active = _$active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const FarmerStatus suspended = _$suspended;

  static Serializer<FarmerStatus> get serializer => _$farmerStatusSerializer;

  const FarmerStatus._(String name) : super(name);

  static BuiltSet<FarmerStatus> get values => _$values;
  static FarmerStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FarmerStatusMixin = Object with _$FarmerStatusMixin;
