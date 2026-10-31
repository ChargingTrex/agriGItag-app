//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'min.g.dart';

/// Lowest passing value, inclusive.
@BuiltValue()
abstract class Min implements Built<Min, MinBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Min._();

  factory Min([void updates(MinBuilder b)]) = _$Min;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MinBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Min> get serializer => _$MinSerializer();
}

class _$MinSerializer implements PrimitiveSerializer<Min> {
  @override
  final Iterable<Type> types = const [Min, _$Min];

  @override
  final String wireName = r'Min';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Min object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Min object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  Min deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MinBuilder();
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
