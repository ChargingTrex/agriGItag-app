//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'pack_size.g.dart';

/// Typical pack size, in `unit`.
@BuiltValue()
abstract class PackSize implements Built<PackSize, PackSizeBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  PackSize._();

  factory PackSize([void updates(PackSizeBuilder b)]) = _$PackSize;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PackSizeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PackSize> get serializer => _$PackSizeSerializer();
}

class _$PackSizeSerializer implements PrimitiveSerializer<PackSize> {
  @override
  final Iterable<Type> types = const [PackSize, _$PackSize];

  @override
  final String wireName = r'PackSize';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PackSize object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PackSize object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  PackSize deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PackSizeBuilder();
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
