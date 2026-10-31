//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/sync_result.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_push_out.g.dart';

/// Per-entry results, in the order sent.
///
/// Properties:
/// * [results] - One result per entry, same order.
/// * [serverTime] - Server clock (UTC), for the phone's skew display.
@BuiltValue()
abstract class SyncPushOut implements Built<SyncPushOut, SyncPushOutBuilder> {
  /// One result per entry, same order.
  @BuiltValueField(wireName: r'results')
  BuiltList<SyncResult> get results;

  /// Server clock (UTC), for the phone's skew display.
  @BuiltValueField(wireName: r'server_time')
  DateTime get serverTime;

  SyncPushOut._();

  factory SyncPushOut([void updates(SyncPushOutBuilder b)]) = _$SyncPushOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncPushOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncPushOut> get serializer => _$SyncPushOutSerializer();
}

class _$SyncPushOutSerializer implements PrimitiveSerializer<SyncPushOut> {
  @override
  final Iterable<Type> types = const [SyncPushOut, _$SyncPushOut];

  @override
  final String wireName = r'SyncPushOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncPushOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(SyncResult)]),
    );
    yield r'server_time';
    yield serializers.serialize(
      object.serverTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncPushOut object, {
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
    required SyncPushOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncResult)]),
          ) as BuiltList<SyncResult>;
          result.results.replace(valueDes);
          break;
        case r'server_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncPushOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncPushOutBuilder();
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
