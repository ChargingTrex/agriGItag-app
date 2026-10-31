//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_in.g.dart';

/// Merge received lots into a super-lot / batch (Stage 7, FR9, FR29).
///
/// Properties:
/// * [clientId] - UUIDv7 made by the client; batch id and idempotency key.
/// * [giLabelRequested] - Ask to label the batch as GI (re-checked, FR29).
/// * [lotIds] - `received` lots of the caller's FPO, no repeats; each brings all it delivered here.
/// * [processorId] - Processor that received every lot.
@BuiltValue()
abstract class BatchIn implements Built<BatchIn, BatchInBuilder> {
  /// UUIDv7 made by the client; batch id and idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Ask to label the batch as GI (re-checked, FR29).
  @BuiltValueField(wireName: r'gi_label_requested')
  bool? get giLabelRequested;

  /// `received` lots of the caller's FPO, no repeats; each brings all it delivered here.
  @BuiltValueField(wireName: r'lot_ids')
  BuiltList<String> get lotIds;

  /// Processor that received every lot.
  @BuiltValueField(wireName: r'processor_id')
  String get processorId;

  BatchIn._();

  factory BatchIn([void updates(BatchInBuilder b)]) = _$BatchIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BatchInBuilder b) => b..giLabelRequested = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<BatchIn> get serializer => _$BatchInSerializer();
}

class _$BatchInSerializer implements PrimitiveSerializer<BatchIn> {
  @override
  final Iterable<Type> types = const [BatchIn, _$BatchIn];

  @override
  final String wireName = r'BatchIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BatchIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.giLabelRequested != null) {
      yield r'gi_label_requested';
      yield serializers.serialize(
        object.giLabelRequested,
        specifiedType: const FullType(bool),
      );
    }
    yield r'lot_ids';
    yield serializers.serialize(
      object.lotIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'processor_id';
    yield serializers.serialize(
      object.processorId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BatchIn object, {
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
    required BatchInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'gi_label_requested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.giLabelRequested = valueDes;
          break;
        case r'lot_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.lotIds.replace(valueDes);
          break;
        case r'processor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.processorId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BatchIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BatchInBuilder();
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
