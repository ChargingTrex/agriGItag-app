//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/finished_batch.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finished_goods.g.dart';

/// Finished Goods: packed batches and their quantities.
///
/// Properties:
/// * [batches] - Packed or published batches (count).
/// * [items] - Newest 100 batches, latest pack date first.
/// * [packed] - Total in final packs, unit `kg`.
@BuiltValue()
abstract class FinishedGoods
    implements Built<FinishedGoods, FinishedGoodsBuilder> {
  /// Packed or published batches (count).
  @BuiltValueField(wireName: r'batches')
  int get batches;

  /// Newest 100 batches, latest pack date first.
  @BuiltValueField(wireName: r'items')
  BuiltList<FinishedBatch> get items;

  /// Total in final packs, unit `kg`.
  @BuiltValueField(wireName: r'packed')
  QuantityOutput get packed;

  FinishedGoods._();

  factory FinishedGoods([void updates(FinishedGoodsBuilder b)]) =
      _$FinishedGoods;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinishedGoodsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinishedGoods> get serializer =>
      _$FinishedGoodsSerializer();
}

class _$FinishedGoodsSerializer implements PrimitiveSerializer<FinishedGoods> {
  @override
  final Iterable<Type> types = const [FinishedGoods, _$FinishedGoods];

  @override
  final String wireName = r'FinishedGoods';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinishedGoods object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batches';
    yield serializers.serialize(
      object.batches,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FinishedBatch)]),
    );
    yield r'packed';
    yield serializers.serialize(
      object.packed,
      specifiedType: const FullType(QuantityOutput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FinishedGoods object, {
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
    required FinishedGoodsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batches':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.batches = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FinishedBatch)]),
          ) as BuiltList<FinishedBatch>;
          result.items.replace(valueDes);
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
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
  FinishedGoods deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinishedGoodsBuilder();
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
