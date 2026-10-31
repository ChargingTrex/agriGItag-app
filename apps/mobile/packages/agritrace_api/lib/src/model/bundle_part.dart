//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bundle_part.g.dart';

/// Offline reference-bundle parts (backend-design.md §3; bodies per docs/agents/reports/M03.md).
class BundlePart extends EnumClass {
  @BuiltValueEnumConst(wireName: r'plots')
  static const BundlePart plots = _$plots;
  @BuiltValueEnumConst(wireName: r'crops')
  static const BundlePart crops = _$crops;
  @BuiltValueEnumConst(wireName: r'inputs')
  static const BundlePart inputs = _$inputs;
  @BuiltValueEnumConst(wireName: r'standards')
  static const BundlePart standards = _$standards;
  @BuiltValueEnumConst(wireName: r'gi_region')
  static const BundlePart giRegion = _$giRegion;
  @BuiltValueEnumConst(wireName: r'farmer_profile')
  static const BundlePart farmerProfile = _$farmerProfile;
  @BuiltValueEnumConst(wireName: r'villages')
  static const BundlePart villages = _$villages;
  @BuiltValueEnumConst(wireName: r'fields')
  static const BundlePart fields = _$fields;
  @BuiltValueEnumConst(wireName: r'prompts')
  static const BundlePart prompts = _$prompts;
  @BuiltValueEnumConst(wireName: r'images')
  static const BundlePart images = _$images;
  @BuiltValueEnumConst(wireName: r'calendar')
  static const BundlePart calendar = _$calendar;

  static Serializer<BundlePart> get serializer => _$bundlePartSerializer;

  const BundlePart._(String name) : super(name);

  static BuiltSet<BundlePart> get values => _$values;
  static BundlePart valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class BundlePartMixin = Object with _$BundlePartMixin;
