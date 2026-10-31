//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'final_packing_in.g.dart';

/// FPO admin signs off final (retail) packing (Stage 9, FR62).
///
/// Properties:
/// * [bestBeforeDate] - Best-before date printed on the label.
/// * [packDate] - Pack date printed on the label.
/// * [packed] - Quantity in final packs in kg; at most the graded quantity.
@BuiltValue()
abstract class FinalPackingIn
    implements Built<FinalPackingIn, FinalPackingInBuilder> {
  /// Best-before date printed on the label.
  @BuiltValueField(wireName: r'best_before_date')
  Date get bestBeforeDate;

  /// Pack date printed on the label.
  @BuiltValueField(wireName: r'pack_date')
  Date get packDate;

  /// Quantity in final packs in kg; at most the graded quantity.
  @BuiltValueField(wireName: r'packed')
  QuantityInput get packed;

  FinalPackingIn._();

  factory FinalPackingIn([void updates(FinalPackingInBuilder b)]) =
      _$FinalPackingIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinalPackingInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinalPackingIn> get serializer =>
      _$FinalPackingInSerializer();
}

class _$FinalPackingInSerializer
    implements PrimitiveSerializer<FinalPackingIn> {
  @override
  final Iterable<Type> types = const [FinalPackingIn, _$FinalPackingIn];

  @override
  final String wireName = r'FinalPackingIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinalPackingIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'best_before_date';
    yield serializers.serialize(
      object.bestBeforeDate,
      specifiedType: const FullType(Date),
    );
    yield r'pack_date';
    yield serializers.serialize(
      object.packDate,
      specifiedType: const FullType(Date),
    );
    yield r'packed';
    yield serializers.serialize(
      object.packed,
      specifiedType: const FullType(QuantityInput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FinalPackingIn object, {
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
    required FinalPackingInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'best_before_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.bestBeforeDate = valueDes;
          break;
        case r'pack_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.packDate = valueDes;
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityInput),
          ) as QuantityInput;
          result.packed.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinalPackingIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinalPackingInBuilder();
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
