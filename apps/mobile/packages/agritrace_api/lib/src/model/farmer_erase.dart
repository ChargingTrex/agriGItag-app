//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_erase.g.dart';

/// An approved DPDP erasure request for one farmer (B24, runbook §2, D-065).
///
/// Properties:
/// * [confirm] - Must be `true`: an erasure cannot be undone.
/// * [reason] - Request reference and approver, e.g. `DPDP-2026-001, approved by the data officer`. Kept in the audit trail for good, so write no personal data in it.
@BuiltValue()
abstract class FarmerErase implements Built<FarmerErase, FarmerEraseBuilder> {
  /// Must be `true`: an erasure cannot be undone.
  @BuiltValueField(wireName: r'confirm')
  FarmerEraseConfirmEnum get confirm;
  // enum confirmEnum {  true,  };

  /// Request reference and approver, e.g. `DPDP-2026-001, approved by the data officer`. Kept in the audit trail for good, so write no personal data in it.
  @BuiltValueField(wireName: r'reason')
  String get reason;

  FarmerErase._();

  factory FarmerErase([void updates(FarmerEraseBuilder b)]) = _$FarmerErase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerEraseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerErase> get serializer => _$FarmerEraseSerializer();
}

class _$FarmerEraseSerializer implements PrimitiveSerializer<FarmerErase> {
  @override
  final Iterable<Type> types = const [FarmerErase, _$FarmerErase];

  @override
  final String wireName = r'FarmerErase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerErase object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'confirm';
    yield serializers.serialize(
      object.confirm,
      specifiedType: const FullType(FarmerEraseConfirmEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerErase object, {
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
    required FarmerEraseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'confirm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FarmerEraseConfirmEnum),
          ) as FarmerEraseConfirmEnum;
          result.confirm = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  FarmerErase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerEraseBuilder();
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

/// Must be `true`: an erasure cannot be undone.
class FarmerEraseConfirmEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'true')
  static const FarmerEraseConfirmEnum true_ = _$farmerEraseConfirmEnum_true_;

  static Serializer<FarmerEraseConfirmEnum> get serializer =>
      _$farmerEraseConfirmEnumSerializer;

  const FarmerEraseConfirmEnum._(String name) : super(name);

  static BuiltSet<FarmerEraseConfirmEnum> get values =>
      _$farmerEraseConfirmEnumValues;
  static FarmerEraseConfirmEnum valueOf(String name) =>
      _$farmerEraseConfirmEnumValueOf(name);
}
