//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/max.dart';
import 'package:agritrace_api/src/model/min.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'range_input.g.dart';

/// An inclusive numeric interval; a missing bound is open (no limit on that side).
///
/// Properties:
/// * [max]
/// * [min]
@BuiltValue()
abstract class RangeInput implements Built<RangeInput, RangeInputBuilder> {
  @BuiltValueField(wireName: r'max')
  Max? get max;

  @BuiltValueField(wireName: r'min')
  Min? get min;

  RangeInput._();

  factory RangeInput([void updates(RangeInputBuilder b)]) = _$RangeInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RangeInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RangeInput> get serializer => _$RangeInputSerializer();
}

class _$RangeInputSerializer implements PrimitiveSerializer<RangeInput> {
  @override
  final Iterable<Type> types = const [RangeInput, _$RangeInput];

  @override
  final String wireName = r'RangeInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RangeInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType.nullable(Max),
      );
    }
    if (object.min != null) {
      yield r'min';
      yield serializers.serialize(
        object.min,
        specifiedType: const FullType.nullable(Min),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RangeInput object, {
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
    required RangeInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Max),
          ) as Max?;
          if (valueDes == null) continue;
          result.max.replace(valueDes);
          break;
        case r'min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Min),
          ) as Min?;
          if (valueDes == null) continue;
          result.min.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RangeInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RangeInputBuilder();
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
