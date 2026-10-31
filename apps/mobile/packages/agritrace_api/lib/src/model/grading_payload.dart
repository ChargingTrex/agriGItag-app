//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'grading_payload.g.dart';

/// Stage 8 grading / sorting of a batch; readings and the computed grade live in quality.
///
/// Properties:
/// * [declaredGrade] - Grade declared by the QC officer.
/// * [quantity] - Graded quantity, unit `kg` (ceiling for packing).
@BuiltValue()
abstract class GradingPayload
    implements Built<GradingPayload, GradingPayloadBuilder> {
  /// Grade declared by the QC officer.
  @BuiltValueField(wireName: r'declared_grade')
  String? get declaredGrade;

  /// Graded quantity, unit `kg` (ceiling for packing).
  @BuiltValueField(wireName: r'quantity')
  QuantityInput? get quantity;

  GradingPayload._();

  factory GradingPayload([void updates(GradingPayloadBuilder b)]) =
      _$GradingPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GradingPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GradingPayload> get serializer =>
      _$GradingPayloadSerializer();
}

class _$GradingPayloadSerializer
    implements PrimitiveSerializer<GradingPayload> {
  @override
  final Iterable<Type> types = const [GradingPayload, _$GradingPayload];

  @override
  final String wireName = r'GradingPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GradingPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.declaredGrade != null) {
      yield r'declared_grade';
      yield serializers.serialize(
        object.declaredGrade,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GradingPayload object, {
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
    required GradingPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'declared_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.declaredGrade = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GradingPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GradingPayloadBuilder();
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
