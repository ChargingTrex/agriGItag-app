//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_health_row.g.dart';

/// Phone sync timings of one network type over the last 7 days (plan §13 F1).
///
/// Properties:
/// * [entries] - Entries measured (count).
/// * [failureRate] - Failed send attempts ÷ all send attempts (failures + entries), unit `%`.
/// * [networkType] - Network at send time, e.g. `2g`, `lte`, `wifi`; null if unknown.
/// * [photoUploadP50] - Median photo upload time, unit `ms`.
/// * [photoUploadP95] - 95th percentile photo upload time, unit `ms`.
/// * [saveToAckP50] - Median phone save → server ack time, unit `ms`.
/// * [saveToAckP95] - 95th percentile save → ack time, unit `ms`.
@BuiltValue()
abstract class SyncHealthRow
    implements Built<SyncHealthRow, SyncHealthRowBuilder> {
  /// Entries measured (count).
  @BuiltValueField(wireName: r'entries')
  int get entries;

  /// Failed send attempts ÷ all send attempts (failures + entries), unit `%`.
  @BuiltValueField(wireName: r'failure_rate')
  QuantityOutput get failureRate;

  /// Network at send time, e.g. `2g`, `lte`, `wifi`; null if unknown.
  @BuiltValueField(wireName: r'network_type')
  String? get networkType;

  /// Median photo upload time, unit `ms`.
  @BuiltValueField(wireName: r'photo_upload_p50')
  QuantityOutput? get photoUploadP50;

  /// 95th percentile photo upload time, unit `ms`.
  @BuiltValueField(wireName: r'photo_upload_p95')
  QuantityOutput? get photoUploadP95;

  /// Median phone save → server ack time, unit `ms`.
  @BuiltValueField(wireName: r'save_to_ack_p50')
  QuantityOutput? get saveToAckP50;

  /// 95th percentile save → ack time, unit `ms`.
  @BuiltValueField(wireName: r'save_to_ack_p95')
  QuantityOutput? get saveToAckP95;

  SyncHealthRow._();

  factory SyncHealthRow([void updates(SyncHealthRowBuilder b)]) =
      _$SyncHealthRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncHealthRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncHealthRow> get serializer =>
      _$SyncHealthRowSerializer();
}

class _$SyncHealthRowSerializer implements PrimitiveSerializer<SyncHealthRow> {
  @override
  final Iterable<Type> types = const [SyncHealthRow, _$SyncHealthRow];

  @override
  final String wireName = r'SyncHealthRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncHealthRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entries';
    yield serializers.serialize(
      object.entries,
      specifiedType: const FullType(int),
    );
    yield r'failure_rate';
    yield serializers.serialize(
      object.failureRate,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'network_type';
    yield object.networkType == null
        ? null
        : serializers.serialize(
            object.networkType,
            specifiedType: const FullType.nullable(String),
          );
    yield r'photo_upload_p50';
    yield object.photoUploadP50 == null
        ? null
        : serializers.serialize(
            object.photoUploadP50,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'photo_upload_p95';
    yield object.photoUploadP95 == null
        ? null
        : serializers.serialize(
            object.photoUploadP95,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'save_to_ack_p50';
    yield object.saveToAckP50 == null
        ? null
        : serializers.serialize(
            object.saveToAckP50,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'save_to_ack_p95';
    yield object.saveToAckP95 == null
        ? null
        : serializers.serialize(
            object.saveToAckP95,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncHealthRow object, {
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
    required SyncHealthRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.entries = valueDes;
          break;
        case r'failure_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.failureRate.replace(valueDes);
          break;
        case r'network_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.networkType = valueDes;
          break;
        case r'photo_upload_p50':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.photoUploadP50.replace(valueDes);
          break;
        case r'photo_upload_p95':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.photoUploadP95.replace(valueDes);
          break;
        case r'save_to_ack_p50':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.saveToAckP50.replace(valueDes);
          break;
        case r'save_to_ack_p95':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.saveToAckP95.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncHealthRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncHealthRowBuilder();
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
