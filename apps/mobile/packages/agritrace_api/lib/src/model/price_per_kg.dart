//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'price_per_kg.g.dart';

/// Price in INR per kg (optional, D-017).
@BuiltValue()
abstract class PricePerKg implements Built<PricePerKg, PricePerKgBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  PricePerKg._();

  factory PricePerKg([void updates(PricePerKgBuilder b)]) = _$PricePerKg;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PricePerKgBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PricePerKg> get serializer => _$PricePerKgSerializer();
}

class _$PricePerKgSerializer implements PrimitiveSerializer<PricePerKg> {
  @override
  final Iterable<Type> types = const [PricePerKg, _$PricePerKg];

  @override
  final String wireName = r'PricePerKg';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PricePerKg object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PricePerKg object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  PricePerKg deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PricePerKgBuilder();
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
