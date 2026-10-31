//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'hold_margin_pct.g.dart';

/// Excess above which the lot is held out of GI, %.
@BuiltValue()
abstract class HoldMarginPct
    implements Built<HoldMarginPct, HoldMarginPctBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  HoldMarginPct._();

  factory HoldMarginPct([void updates(HoldMarginPctBuilder b)]) =
      _$HoldMarginPct;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HoldMarginPctBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HoldMarginPct> get serializer =>
      _$HoldMarginPctSerializer();
}

class _$HoldMarginPctSerializer implements PrimitiveSerializer<HoldMarginPct> {
  @override
  final Iterable<Type> types = const [HoldMarginPct, _$HoldMarginPct];

  @override
  final String wireName = r'HoldMarginPct';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HoldMarginPct object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    HoldMarginPct object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  HoldMarginPct deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HoldMarginPctBuilder();
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
