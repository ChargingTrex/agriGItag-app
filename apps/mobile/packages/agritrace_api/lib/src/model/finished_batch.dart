//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/batch_status.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finished_batch.g.dart';

/// A packed or published batch in the Finished Goods inventory.
///
/// Properties:
/// * [batchId] - Batch id.
/// * [code] - Batch code printed on the label.
/// * [packDate] - Pack date on the label.
/// * [packed] - Quantity in final packs, unit `kg`; null if not recorded.
/// * [remaining] - Quantity still in stock, unit `kg`; equals `packed` until sales are recorded.
/// * [scans] - Public page scans of this batch code (count, FR20).
/// * [status] - `packed` or `published`.
@BuiltValue()
abstract class FinishedBatch
    implements Built<FinishedBatch, FinishedBatchBuilder> {
  /// Batch id.
  @BuiltValueField(wireName: r'batch_id')
  String get batchId;

  /// Batch code printed on the label.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Pack date on the label.
  @BuiltValueField(wireName: r'pack_date')
  Date? get packDate;

  /// Quantity in final packs, unit `kg`; null if not recorded.
  @BuiltValueField(wireName: r'packed')
  QuantityOutput? get packed;

  /// Quantity still in stock, unit `kg`; equals `packed` until sales are recorded.
  @BuiltValueField(wireName: r'remaining')
  QuantityOutput? get remaining;

  /// Public page scans of this batch code (count, FR20).
  @BuiltValueField(wireName: r'scans')
  int get scans;

  /// `packed` or `published`.
  @BuiltValueField(wireName: r'status')
  BatchStatus get status;
  // enum statusEnum {  created,  graded,  packed,  published,  };

  FinishedBatch._();

  factory FinishedBatch([void updates(FinishedBatchBuilder b)]) =
      _$FinishedBatch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinishedBatchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinishedBatch> get serializer =>
      _$FinishedBatchSerializer();
}

class _$FinishedBatchSerializer implements PrimitiveSerializer<FinishedBatch> {
  @override
  final Iterable<Type> types = const [FinishedBatch, _$FinishedBatch];

  @override
  final String wireName = r'FinishedBatch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinishedBatch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batch_id';
    yield serializers.serialize(
      object.batchId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'pack_date';
    yield object.packDate == null
        ? null
        : serializers.serialize(
            object.packDate,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'packed';
    yield object.packed == null
        ? null
        : serializers.serialize(
            object.packed,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'remaining';
    yield object.remaining == null
        ? null
        : serializers.serialize(
            object.remaining,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'scans';
    yield serializers.serialize(
      object.scans,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BatchStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FinishedBatch object, {
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
    required FinishedBatchBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.batchId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'pack_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.packDate = valueDes;
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.packed.replace(valueDes);
          break;
        case r'remaining':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.remaining.replace(valueDes);
          break;
        case r'scans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.scans = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BatchStatus),
          ) as BatchStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinishedBatch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinishedBatchBuilder();
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
