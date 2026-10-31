//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/lot_status.dart';
import 'package:agritrace_api/src/model/practice_tags.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lot_out.g.dart';

/// A component lot with its lifecycle state and GI eligibility.
///
/// Properties:
/// * [code] - Lot code `LOT` + 8 hex, e.g. `LOT0EF81415`.
/// * [cropId] - Crop.
/// * [farmerId] - Grower.
/// * [giEligible] - False while a hold keeps the lot out of GI batches (FR68, FR70).
/// * [giHoldReason] - Why the lot is held out of GI batches.
/// * [harvested] - Harvested quantity in kg, filled at intake.
/// * [id] - Lot id.
/// * [packed] - On-farm packed quantity in kg, filled at intake.
/// * [plotId] - Plot harvested.
/// * [practiceTags] - Declared and derived tags (FR56).
/// * [readyAt] - When the lot passed the ready-for-sale gate.
/// * [seasonLabel] - Season label; empty when the tenant does not capture it.
/// * [status] - open → drying → ready_for_sale → received → batched → closed.
@BuiltValue()
abstract class LotOut implements Built<LotOut, LotOutBuilder> {
  /// Lot code `LOT` + 8 hex, e.g. `LOT0EF81415`.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Crop.
  @BuiltValueField(wireName: r'crop_id')
  String get cropId;

  /// Grower.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// False while a hold keeps the lot out of GI batches (FR68, FR70).
  @BuiltValueField(wireName: r'gi_eligible')
  bool get giEligible;

  /// Why the lot is held out of GI batches.
  @BuiltValueField(wireName: r'gi_hold_reason')
  String? get giHoldReason;

  /// Harvested quantity in kg, filled at intake.
  @BuiltValueField(wireName: r'harvested')
  QuantityOutput? get harvested;

  /// Lot id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// On-farm packed quantity in kg, filled at intake.
  @BuiltValueField(wireName: r'packed')
  QuantityOutput? get packed;

  /// Plot harvested.
  @BuiltValueField(wireName: r'plot_id')
  String get plotId;

  /// Declared and derived tags (FR56).
  @BuiltValueField(wireName: r'practice_tags')
  PracticeTags? get practiceTags;

  /// When the lot passed the ready-for-sale gate.
  @BuiltValueField(wireName: r'ready_at')
  DateTime? get readyAt;

  /// Season label; empty when the tenant does not capture it.
  @BuiltValueField(wireName: r'season_label')
  String get seasonLabel;

  /// open → drying → ready_for_sale → received → batched → closed.
  @BuiltValueField(wireName: r'status')
  LotStatus get status;
  // enum statusEnum {  open,  drying,  ready_for_sale,  received,  batched,  closed,  };

  LotOut._();

  factory LotOut([void updates(LotOutBuilder b)]) = _$LotOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LotOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LotOut> get serializer => _$LotOutSerializer();
}

class _$LotOutSerializer implements PrimitiveSerializer<LotOut> {
  @override
  final Iterable<Type> types = const [LotOut, _$LotOut];

  @override
  final String wireName = r'LotOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LotOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'crop_id';
    yield serializers.serialize(
      object.cropId,
      specifiedType: const FullType(String),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'gi_eligible';
    yield serializers.serialize(
      object.giEligible,
      specifiedType: const FullType(bool),
    );
    if (object.giHoldReason != null) {
      yield r'gi_hold_reason';
      yield serializers.serialize(
        object.giHoldReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.harvested != null) {
      yield r'harvested';
      yield serializers.serialize(
        object.harvested,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.packed != null) {
      yield r'packed';
      yield serializers.serialize(
        object.packed,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    yield r'plot_id';
    yield serializers.serialize(
      object.plotId,
      specifiedType: const FullType(String),
    );
    if (object.practiceTags != null) {
      yield r'practice_tags';
      yield serializers.serialize(
        object.practiceTags,
        specifiedType: const FullType.nullable(PracticeTags),
      );
    }
    if (object.readyAt != null) {
      yield r'ready_at';
      yield serializers.serialize(
        object.readyAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'season_label';
    yield serializers.serialize(
      object.seasonLabel,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LotStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LotOut object, {
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
    required LotOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'crop_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cropId = valueDes;
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'gi_eligible':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.giEligible = valueDes;
          break;
        case r'gi_hold_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giHoldReason = valueDes;
          break;
        case r'harvested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.harvested.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.packed.replace(valueDes);
          break;
        case r'plot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plotId = valueDes;
          break;
        case r'practice_tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PracticeTags),
          ) as PracticeTags?;
          if (valueDes == null) continue;
          result.practiceTags.replace(valueDes);
          break;
        case r'ready_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readyAt = valueDes;
          break;
        case r'season_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.seasonLabel = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LotStatus),
          ) as LotStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LotOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LotOutBuilder();
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
