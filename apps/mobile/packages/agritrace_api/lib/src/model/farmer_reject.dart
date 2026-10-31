//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_reject.g.dart';

/// Why an FPO admin turns down a pending farmer (Stage 0 approval, FR70).
///
/// Properties:
/// * [reasonCode] - Coded reason, e.g. `duplicate`, `not_a_member`, `outside_gi_area`, `incomplete`.
/// * [reasonText] - Free-text explanation.
@BuiltValue()
abstract class FarmerReject
    implements Built<FarmerReject, FarmerRejectBuilder> {
  /// Coded reason, e.g. `duplicate`, `not_a_member`, `outside_gi_area`, `incomplete`.
  @BuiltValueField(wireName: r'reason_code')
  String get reasonCode;

  /// Free-text explanation.
  @BuiltValueField(wireName: r'reason_text')
  String? get reasonText;

  FarmerReject._();

  factory FarmerReject([void updates(FarmerRejectBuilder b)]) = _$FarmerReject;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerRejectBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerReject> get serializer => _$FarmerRejectSerializer();
}

class _$FarmerRejectSerializer implements PrimitiveSerializer<FarmerReject> {
  @override
  final Iterable<Type> types = const [FarmerReject, _$FarmerReject];

  @override
  final String wireName = r'FarmerReject';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerReject object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(String),
    );
    if (object.reasonText != null) {
      yield r'reason_text';
      yield serializers.serialize(
        object.reasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerReject object, {
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
    required FarmerRejectBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reasonCode = valueDes;
          break;
        case r'reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FarmerReject deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerRejectBuilder();
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
