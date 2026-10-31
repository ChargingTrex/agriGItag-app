//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reconciliation.g.dart';

/// Per-lot quantity chain: harvested ≥ packed ≥ received by the processor ≥ used in batches (FR60).
///
/// Properties:
/// * [harvested] - Sum of harvest event quantities; null if none.
/// * [inOrder] - True when every recorded step is ≤ the one before it.
/// * [packed] - On-farm packed quantity; null if not recorded.
/// * [received] - Quantity the processor received at intake.
/// * [used] - Quantity of this lot used in batches.
@BuiltValue()
abstract class Reconciliation
    implements Built<Reconciliation, ReconciliationBuilder> {
  /// Sum of harvest event quantities; null if none.
  @BuiltValueField(wireName: r'harvested')
  QuantityOutput? get harvested;

  /// True when every recorded step is ≤ the one before it.
  @BuiltValueField(wireName: r'in_order')
  bool get inOrder;

  /// On-farm packed quantity; null if not recorded.
  @BuiltValueField(wireName: r'packed')
  QuantityOutput? get packed;

  /// Quantity the processor received at intake.
  @BuiltValueField(wireName: r'received')
  QuantityOutput? get received;

  /// Quantity of this lot used in batches.
  @BuiltValueField(wireName: r'used')
  QuantityOutput? get used;

  Reconciliation._();

  factory Reconciliation([void updates(ReconciliationBuilder b)]) =
      _$Reconciliation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReconciliationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Reconciliation> get serializer =>
      _$ReconciliationSerializer();
}

class _$ReconciliationSerializer
    implements PrimitiveSerializer<Reconciliation> {
  @override
  final Iterable<Type> types = const [Reconciliation, _$Reconciliation];

  @override
  final String wireName = r'Reconciliation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Reconciliation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.harvested != null) {
      yield r'harvested';
      yield serializers.serialize(
        object.harvested,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    yield r'in_order';
    yield serializers.serialize(
      object.inOrder,
      specifiedType: const FullType(bool),
    );
    if (object.packed != null) {
      yield r'packed';
      yield serializers.serialize(
        object.packed,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    if (object.received != null) {
      yield r'received';
      yield serializers.serialize(
        object.received,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    if (object.used != null) {
      yield r'used';
      yield serializers.serialize(
        object.used,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Reconciliation object, {
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
    required ReconciliationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'harvested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.harvested.replace(valueDes);
          break;
        case r'in_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.inOrder = valueDes;
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.packed.replace(valueDes);
          break;
        case r'received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.received.replace(valueDes);
          break;
        case r'used':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.used.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Reconciliation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReconciliationBuilder();
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
