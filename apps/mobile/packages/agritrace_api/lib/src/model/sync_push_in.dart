//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/sync_entry.dart';
import 'package:agritrace_api/src/model/sync_metric_in.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_push_in.g.dart';

/// Sync push envelope: at most 50 entries and 256 KB (backend-design.md §3, plan §13 A4).
///
/// Properties:
/// * [appVersion] - App version, e.g. `1.0.3`.
/// * [deviceId] - Device id of the app; the token's device is what is stored.
/// * [deviceTime] - Phone clock when the push was sent.
/// * [entries] - Entries in capture order; each one is its own transaction.
/// * [metrics] - Telemetry rows to store in `sync_metrics`.
@BuiltValue()
abstract class SyncPushIn implements Built<SyncPushIn, SyncPushInBuilder> {
  /// App version, e.g. `1.0.3`.
  @BuiltValueField(wireName: r'app_version')
  String get appVersion;

  /// Device id of the app; the token's device is what is stored.
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  /// Phone clock when the push was sent.
  @BuiltValueField(wireName: r'device_time')
  DateTime get deviceTime;

  /// Entries in capture order; each one is its own transaction.
  @BuiltValueField(wireName: r'entries')
  BuiltList<SyncEntry> get entries;

  /// Telemetry rows to store in `sync_metrics`.
  @BuiltValueField(wireName: r'metrics')
  BuiltList<SyncMetricIn>? get metrics;

  SyncPushIn._();

  factory SyncPushIn([void updates(SyncPushInBuilder b)]) = _$SyncPushIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncPushInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncPushIn> get serializer => _$SyncPushInSerializer();
}

class _$SyncPushInSerializer implements PrimitiveSerializer<SyncPushIn> {
  @override
  final Iterable<Type> types = const [SyncPushIn, _$SyncPushIn];

  @override
  final String wireName = r'SyncPushIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncPushIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'app_version';
    yield serializers.serialize(
      object.appVersion,
      specifiedType: const FullType(String),
    );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'device_time';
    yield serializers.serialize(
      object.deviceTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'entries';
    yield serializers.serialize(
      object.entries,
      specifiedType: const FullType(BuiltList, [FullType(SyncEntry)]),
    );
    if (object.metrics != null) {
      yield r'metrics';
      yield serializers.serialize(
        object.metrics,
        specifiedType: const FullType(BuiltList, [FullType(SyncMetricIn)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncPushIn object, {
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
    required SyncPushInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appVersion = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'device_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.deviceTime = valueDes;
          break;
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncEntry)]),
          ) as BuiltList<SyncEntry>;
          result.entries.replace(valueDes);
          break;
        case r'metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(SyncMetricIn)]),
          ) as BuiltList<SyncMetricIn>?;
          if (valueDes == null) continue;
          result.metrics.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncPushIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncPushInBuilder();
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
