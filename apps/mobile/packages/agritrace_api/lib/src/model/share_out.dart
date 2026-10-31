//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_out.g.dart';

/// A lot's share of a batch (FR60).
///
/// Properties:
/// * [contributed] - Kilograms of the lot in the batch (its intake kg).
/// * [farmerId] - Grower of the lot.
/// * [lotId] - Component lot.
/// * [sharePct] - Percent of the batch, 3 decimals; the shares sum to 100.000.
@BuiltValue()
abstract class ShareOut implements Built<ShareOut, ShareOutBuilder> {
  /// Kilograms of the lot in the batch (its intake kg).
  @BuiltValueField(wireName: r'contributed')
  QuantityOutput get contributed;

  /// Grower of the lot.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// Component lot.
  @BuiltValueField(wireName: r'lot_id')
  String get lotId;

  /// Percent of the batch, 3 decimals; the shares sum to 100.000.
  @BuiltValueField(wireName: r'share_pct')
  String get sharePct;

  ShareOut._();

  factory ShareOut([void updates(ShareOutBuilder b)]) = _$ShareOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareOut> get serializer => _$ShareOutSerializer();
}

class _$ShareOutSerializer implements PrimitiveSerializer<ShareOut> {
  @override
  final Iterable<Type> types = const [ShareOut, _$ShareOut];

  @override
  final String wireName = r'ShareOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contributed';
    yield serializers.serialize(
      object.contributed,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'lot_id';
    yield serializers.serialize(
      object.lotId,
      specifiedType: const FullType(String),
    );
    yield r'share_pct';
    yield serializers.serialize(
      object.sharePct,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareOut object, {
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
    required ShareOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contributed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.contributed.replace(valueDes);
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lotId = valueDes;
          break;
        case r'share_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sharePct = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShareOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareOutBuilder();
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
