//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'tolerance_buffer_m.g.dart';

/// GPS-drift buffer around the outline in metres (FR32), e.g. 150.
@BuiltValue()
abstract class ToleranceBufferM
    implements Built<ToleranceBufferM, ToleranceBufferMBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  ToleranceBufferM._();

  factory ToleranceBufferM([void updates(ToleranceBufferMBuilder b)]) =
      _$ToleranceBufferM;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToleranceBufferMBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToleranceBufferM> get serializer =>
      _$ToleranceBufferMSerializer();
}

class _$ToleranceBufferMSerializer
    implements PrimitiveSerializer<ToleranceBufferM> {
  @override
  final Iterable<Type> types = const [ToleranceBufferM, _$ToleranceBufferM];

  @override
  final String wireName = r'ToleranceBufferM';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToleranceBufferM object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ToleranceBufferM object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  ToleranceBufferM deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToleranceBufferMBuilder();
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
