//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'value1.g.dart';

/// Amount; negative allowed (adjustment or difference).
@BuiltValue()
abstract class Value1 implements Built<Value1, Value1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Value1._();

  factory Value1([void updates(Value1Builder b)]) = _$Value1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Value1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Value1> get serializer => _$Value1Serializer();
}

class _$Value1Serializer implements PrimitiveSerializer<Value1> {
  @override
  final Iterable<Type> types = const [Value1, _$Value1];

  @override
  final String wireName = r'Value1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Value1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Value1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  Value1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Value1Builder();
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
