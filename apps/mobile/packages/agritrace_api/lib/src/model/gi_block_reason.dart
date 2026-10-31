//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gi_block_reason.g.dart';

/// Why a batch may not carry the GI label (FR29); it can still be traced as a normal batch.
///
/// Properties:
/// * [detail] - Hold reason, rule code or distance, when known.
/// * [lotId] - Lot concerned; null for a batch-wide reason.
/// * [reason] - `crop_has_no_gi_tag`, `gi_region_missing`, `lot_on_hold`, `plot_location_<status>`, `plot_outside_gi_region` or `hold_flag`.
@BuiltValue()
abstract class GiBlockReason
    implements Built<GiBlockReason, GiBlockReasonBuilder> {
  /// Hold reason, rule code or distance, when known.
  @BuiltValueField(wireName: r'detail')
  String? get detail;

  /// Lot concerned; null for a batch-wide reason.
  @BuiltValueField(wireName: r'lot_id')
  String? get lotId;

  /// `crop_has_no_gi_tag`, `gi_region_missing`, `lot_on_hold`, `plot_location_<status>`, `plot_outside_gi_region` or `hold_flag`.
  @BuiltValueField(wireName: r'reason')
  String get reason;

  GiBlockReason._();

  factory GiBlockReason([void updates(GiBlockReasonBuilder b)]) =
      _$GiBlockReason;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GiBlockReasonBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GiBlockReason> get serializer =>
      _$GiBlockReasonSerializer();
}

class _$GiBlockReasonSerializer implements PrimitiveSerializer<GiBlockReason> {
  @override
  final Iterable<Type> types = const [GiBlockReason, _$GiBlockReason];

  @override
  final String wireName = r'GiBlockReason';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GiBlockReason object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lotId != null) {
      yield r'lot_id';
      yield serializers.serialize(
        object.lotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GiBlockReason object, {
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
    required GiBlockReasonBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.detail = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lotId = valueDes;
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
  GiBlockReason deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GiBlockReasonBuilder();
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
