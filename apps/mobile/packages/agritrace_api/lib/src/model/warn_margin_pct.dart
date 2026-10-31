//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'warn_margin_pct.g.dart';

/// Excess over the ceiling still passing silently, %.
@BuiltValue()
abstract class WarnMarginPct
    implements Built<WarnMarginPct, WarnMarginPctBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  WarnMarginPct._();

  factory WarnMarginPct([void updates(WarnMarginPctBuilder b)]) =
      _$WarnMarginPct;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WarnMarginPctBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WarnMarginPct> get serializer =>
      _$WarnMarginPctSerializer();
}

class _$WarnMarginPctSerializer implements PrimitiveSerializer<WarnMarginPct> {
  @override
  final Iterable<Type> types = const [WarnMarginPct, _$WarnMarginPct];

  @override
  final String wireName = r'WarnMarginPct';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WarnMarginPct object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    WarnMarginPct object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  WarnMarginPct deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WarnMarginPctBuilder();
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
