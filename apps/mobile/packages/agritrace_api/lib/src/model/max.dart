//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'max.g.dart';

/// Highest passing value, inclusive, e.g. moisture ≤ 11 %.
@BuiltValue()
abstract class Max implements Built<Max, MaxBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Max._();

  factory Max([void updates(MaxBuilder b)]) = _$Max;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaxBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Max> get serializer => _$MaxSerializer();
}

class _$MaxSerializer implements PrimitiveSerializer<Max> {
  @override
  final Iterable<Type> types = const [Max, _$Max];

  @override
  final String wireName = r'Max';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Max object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Max object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  Max deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MaxBuilder();
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
