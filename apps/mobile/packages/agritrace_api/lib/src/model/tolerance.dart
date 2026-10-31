//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'tolerance.g.dart';

/// Rise tolerated before it counts as a violation (meter noise).
@BuiltValue()
abstract class Tolerance implements Built<Tolerance, ToleranceBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Tolerance._();

  factory Tolerance([void updates(ToleranceBuilder b)]) = _$Tolerance;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToleranceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Tolerance> get serializer => _$ToleranceSerializer();
}

class _$ToleranceSerializer implements PrimitiveSerializer<Tolerance> {
  @override
  final Iterable<Type> types = const [Tolerance, _$Tolerance];

  @override
  final String wireName = r'Tolerance';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Tolerance object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Tolerance object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  Tolerance deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToleranceBuilder();
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
