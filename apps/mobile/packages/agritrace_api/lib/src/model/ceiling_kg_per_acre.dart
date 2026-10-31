//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'ceiling_kg_per_acre.g.dart';

/// Plausible maximum harvest per acre, in kg/acre.
@BuiltValue()
abstract class CeilingKgPerAcre
    implements Built<CeilingKgPerAcre, CeilingKgPerAcreBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  CeilingKgPerAcre._();

  factory CeilingKgPerAcre([void updates(CeilingKgPerAcreBuilder b)]) =
      _$CeilingKgPerAcre;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CeilingKgPerAcreBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CeilingKgPerAcre> get serializer =>
      _$CeilingKgPerAcreSerializer();
}

class _$CeilingKgPerAcreSerializer
    implements PrimitiveSerializer<CeilingKgPerAcre> {
  @override
  final Iterable<Type> types = const [CeilingKgPerAcre, _$CeilingKgPerAcre];

  @override
  final String wireName = r'CeilingKgPerAcre';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CeilingKgPerAcre object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    CeilingKgPerAcre object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  CeilingKgPerAcre deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CeilingKgPerAcreBuilder();
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
