//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'location_status.g.dart';

/// Result of the GI region check on a plot (FR28, FR67, FR70).
class LocationStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'confirmed')
  static const LocationStatus confirmed = _$confirmed;
  @BuiltValueEnumConst(wireName: r'needs_review')
  static const LocationStatus needsReview = _$needsReview;
  @BuiltValueEnumConst(wireName: r'outside')
  static const LocationStatus outside = _$outside;
  @BuiltValueEnumConst(wireName: r'near_edge')
  static const LocationStatus nearEdge = _$nearEdge;

  static Serializer<LocationStatus> get serializer =>
      _$locationStatusSerializer;

  const LocationStatus._(String name) : super(name);

  static BuiltSet<LocationStatus> get values => _$values;
  static LocationStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class LocationStatusMixin = Object with _$LocationStatusMixin;
