//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_revoke_in.g.dart';

/// Sign a lost or stolen device out (B23); the body may be omitted.
///
/// Properties:
/// * [reason] - Why the device is signed out (e.g. `phone lost`); audited.
@BuiltValue()
abstract class DeviceRevokeIn
    implements Built<DeviceRevokeIn, DeviceRevokeInBuilder> {
  /// Why the device is signed out (e.g. `phone lost`); audited.
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  DeviceRevokeIn._();

  factory DeviceRevokeIn([void updates(DeviceRevokeInBuilder b)]) =
      _$DeviceRevokeIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceRevokeInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceRevokeIn> get serializer =>
      _$DeviceRevokeInSerializer();
}

class _$DeviceRevokeInSerializer
    implements PrimitiveSerializer<DeviceRevokeIn> {
  @override
  final Iterable<Type> types = const [DeviceRevokeIn, _$DeviceRevokeIn];

  @override
  final String wireName = r'DeviceRevokeIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceRevokeIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceRevokeIn object, {
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
    required DeviceRevokeInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceRevokeIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceRevokeInBuilder();
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
