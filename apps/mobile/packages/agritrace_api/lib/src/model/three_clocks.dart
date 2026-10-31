//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'three_clocks.g.dart';

/// The three timestamps kept for every offline capture (device, GPS, server).
///
/// Properties:
/// * [deviceTime] - Phone clock at capture, ISO 8601 with offset.
/// * [gpsTime] - GPS fix time at capture, if a fix was taken.
/// * [serverReceivedAt] - Set by the server when the entry arrives; clients leave it empty.
@BuiltValue()
abstract class ThreeClocks implements Built<ThreeClocks, ThreeClocksBuilder> {
  /// Phone clock at capture, ISO 8601 with offset.
  @BuiltValueField(wireName: r'device_time')
  DateTime get deviceTime;

  /// GPS fix time at capture, if a fix was taken.
  @BuiltValueField(wireName: r'gps_time')
  DateTime? get gpsTime;

  /// Set by the server when the entry arrives; clients leave it empty.
  @BuiltValueField(wireName: r'server_received_at')
  DateTime? get serverReceivedAt;

  ThreeClocks._();

  factory ThreeClocks([void updates(ThreeClocksBuilder b)]) = _$ThreeClocks;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreeClocksBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreeClocks> get serializer => _$ThreeClocksSerializer();
}

class _$ThreeClocksSerializer implements PrimitiveSerializer<ThreeClocks> {
  @override
  final Iterable<Type> types = const [ThreeClocks, _$ThreeClocks];

  @override
  final String wireName = r'ThreeClocks';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreeClocks object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device_time';
    yield serializers.serialize(
      object.deviceTime,
      specifiedType: const FullType(DateTime),
    );
    if (object.gpsTime != null) {
      yield r'gps_time';
      yield serializers.serialize(
        object.gpsTime,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.serverReceivedAt != null) {
      yield r'server_received_at';
      yield serializers.serialize(
        object.serverReceivedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreeClocks object, {
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
    required ThreeClocksBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.deviceTime = valueDes;
          break;
        case r'gps_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.gpsTime = valueDes;
          break;
        case r'server_received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.serverReceivedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreeClocks deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreeClocksBuilder();
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
