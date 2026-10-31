//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'avg_sale_price_per_kg.g.dart';

/// Average sale price, INR per kg.
@BuiltValue()
abstract class AvgSalePricePerKg
    implements Built<AvgSalePricePerKg, AvgSalePricePerKgBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  AvgSalePricePerKg._();

  factory AvgSalePricePerKg([void updates(AvgSalePricePerKgBuilder b)]) =
      _$AvgSalePricePerKg;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AvgSalePricePerKgBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AvgSalePricePerKg> get serializer =>
      _$AvgSalePricePerKgSerializer();
}

class _$AvgSalePricePerKgSerializer
    implements PrimitiveSerializer<AvgSalePricePerKg> {
  @override
  final Iterable<Type> types = const [AvgSalePricePerKg, _$AvgSalePricePerKg];

  @override
  final String wireName = r'AvgSalePricePerKg';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AvgSalePricePerKg object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AvgSalePricePerKg object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  AvgSalePricePerKg deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AvgSalePricePerKgBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(num),
      FullType(String),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
