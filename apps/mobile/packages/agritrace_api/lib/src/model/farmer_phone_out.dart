//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_phone_out.g.dart';

/// A farmer's full phone number, revealed to an FPO admin and audited (B14, D-017 `internal`).
///
/// Properties:
/// * [farmerId] - Farmer id.
/// * [phone] - Phone in E.164 from the sign-in account; null without one.
@BuiltValue()
abstract class FarmerPhoneOut
    implements Built<FarmerPhoneOut, FarmerPhoneOutBuilder> {
  /// Farmer id.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// Phone in E.164 from the sign-in account; null without one.
  @BuiltValueField(wireName: r'phone')
  String? get phone;

  FarmerPhoneOut._();

  factory FarmerPhoneOut([void updates(FarmerPhoneOutBuilder b)]) =
      _$FarmerPhoneOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerPhoneOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerPhoneOut> get serializer =>
      _$FarmerPhoneOutSerializer();
}

class _$FarmerPhoneOutSerializer
    implements PrimitiveSerializer<FarmerPhoneOut> {
  @override
  final Iterable<Type> types = const [FarmerPhoneOut, _$FarmerPhoneOut];

  @override
  final String wireName = r'FarmerPhoneOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerPhoneOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield object.phone == null
        ? null
        : serializers.serialize(
            object.phone,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerPhoneOut object, {
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
    required FarmerPhoneOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FarmerPhoneOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerPhoneOutBuilder();
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
