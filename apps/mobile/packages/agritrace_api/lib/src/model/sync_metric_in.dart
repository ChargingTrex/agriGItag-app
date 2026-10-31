//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_metric_in.g.dart';

/// Per-entry sync telemetry measured on the phone (plan §13 F1).
///
/// Properties:
/// * [ackedAt] - When the server acknowledged it, if known.
/// * [entryClientId] - Client id of the entry measured.
/// * [failures] - Failed send attempts before success.
/// * [networkType] - Network at send time: 2g, 3g, lte, wifi.
/// * [photoUploadMs] - Total photo upload time in milliseconds.
/// * [savedAt] - When the entry was saved on the phone.
@BuiltValue()
abstract class SyncMetricIn
    implements Built<SyncMetricIn, SyncMetricInBuilder> {
  /// When the server acknowledged it, if known.
  @BuiltValueField(wireName: r'acked_at')
  DateTime? get ackedAt;

  /// Client id of the entry measured.
  @BuiltValueField(wireName: r'entry_client_id')
  String get entryClientId;

  /// Failed send attempts before success.
  @BuiltValueField(wireName: r'failures')
  int? get failures;

  /// Network at send time: 2g, 3g, lte, wifi.
  @BuiltValueField(wireName: r'network_type')
  String? get networkType;

  /// Total photo upload time in milliseconds.
  @BuiltValueField(wireName: r'photo_upload_ms')
  int? get photoUploadMs;

  /// When the entry was saved on the phone.
  @BuiltValueField(wireName: r'saved_at')
  DateTime get savedAt;

  SyncMetricIn._();

  factory SyncMetricIn([void updates(SyncMetricInBuilder b)]) = _$SyncMetricIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncMetricInBuilder b) => b..failures = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncMetricIn> get serializer => _$SyncMetricInSerializer();
}

class _$SyncMetricInSerializer implements PrimitiveSerializer<SyncMetricIn> {
  @override
  final Iterable<Type> types = const [SyncMetricIn, _$SyncMetricIn];

  @override
  final String wireName = r'SyncMetricIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncMetricIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ackedAt != null) {
      yield r'acked_at';
      yield serializers.serialize(
        object.ackedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'entry_client_id';
    yield serializers.serialize(
      object.entryClientId,
      specifiedType: const FullType(String),
    );
    if (object.failures != null) {
      yield r'failures';
      yield serializers.serialize(
        object.failures,
        specifiedType: const FullType(int),
      );
    }
    if (object.networkType != null) {
      yield r'network_type';
      yield serializers.serialize(
        object.networkType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.photoUploadMs != null) {
      yield r'photo_upload_ms';
      yield serializers.serialize(
        object.photoUploadMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'saved_at';
    yield serializers.serialize(
      object.savedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncMetricIn object, {
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
    required SyncMetricInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acked_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.ackedAt = valueDes;
          break;
        case r'entry_client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entryClientId = valueDes;
          break;
        case r'failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.failures = valueDes;
          break;
        case r'network_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.networkType = valueDes;
          break;
        case r'photo_upload_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.photoUploadMs = valueDes;
          break;
        case r'saved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.savedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncMetricIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncMetricInBuilder();
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
