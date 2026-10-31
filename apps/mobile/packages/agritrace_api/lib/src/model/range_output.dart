//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'range_output.g.dart';

/// An inclusive numeric interval; a missing bound is open (no limit on that side).
///
/// Properties:
/// * [max] - Highest allowed value, inclusive; null means no upper bound.
/// * [min] - Lowest allowed value, inclusive; null means no lower bound.
@BuiltValue()
abstract class RangeOutput implements Built<RangeOutput, RangeOutputBuilder> {
  /// Highest allowed value, inclusive; null means no upper bound.
  @BuiltValueField(wireName: r'max')
  num? get max;

  /// Lowest allowed value, inclusive; null means no lower bound.
  @BuiltValueField(wireName: r'min')
  num? get min;

  RangeOutput._();

  factory RangeOutput([void updates(RangeOutputBuilder b)]) = _$RangeOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RangeOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RangeOutput> get serializer => _$RangeOutputSerializer();
}

class _$RangeOutputSerializer implements PrimitiveSerializer<RangeOutput> {
  @override
  final Iterable<Type> types = const [RangeOutput, _$RangeOutput];

  @override
  final String wireName = r'RangeOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RangeOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.min != null) {
      yield r'min';
      yield serializers.serialize(
        object.min,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RangeOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RangeOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.max = valueDes;
          break;
        case r'min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.min = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RangeOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RangeOutputBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
