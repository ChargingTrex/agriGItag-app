//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'grading_approve_in.g.dart';

/// FPO admin approves the latest grade computation (Stage 8, FR49).
///
/// Properties:
/// * [graded] - Graded quantity in kg; becomes the ceiling for final packing.
@BuiltValue()
abstract class GradingApproveIn
    implements Built<GradingApproveIn, GradingApproveInBuilder> {
  /// Graded quantity in kg; becomes the ceiling for final packing.
  @BuiltValueField(wireName: r'graded')
  QuantityInput get graded;

  GradingApproveIn._();

  factory GradingApproveIn([void updates(GradingApproveInBuilder b)]) =
      _$GradingApproveIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GradingApproveInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GradingApproveIn> get serializer =>
      _$GradingApproveInSerializer();
}

class _$GradingApproveInSerializer
    implements PrimitiveSerializer<GradingApproveIn> {
  @override
  final Iterable<Type> types = const [GradingApproveIn, _$GradingApproveIn];

  @override
  final String wireName = r'GradingApproveIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GradingApproveIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'graded';
    yield serializers.serialize(
      object.graded,
      specifiedType: const FullType(QuantityInput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GradingApproveIn object, {
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
    required GradingApproveInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'graded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityInput),
          ) as QuantityInput;
          result.graded.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GradingApproveIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GradingApproveInBuilder();
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
