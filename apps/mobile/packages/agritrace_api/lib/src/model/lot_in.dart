//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/practice_tag.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lot_in.g.dart';

/// Open a season lot on a plot (Stage 4); fields follow `config/fields/lot.yaml` (D-017).
///
/// Properties:
/// * [clientId] - UUIDv7 made on the device; the lot id and idempotency key.
/// * [cropId] - Crop grown.
/// * [plotId] - Plot the crop grows on; a farmer may only use their own.
/// * [practiceTagsDeclared] - Farming practice the farmer declares (FR56), e.g. `[ipm]`.
/// * [seasonLabel] - Season, e.g. `2025-26 Rabi`.
@BuiltValue()
abstract class LotIn implements Built<LotIn, LotInBuilder> {
  /// UUIDv7 made on the device; the lot id and idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Crop grown.
  @BuiltValueField(wireName: r'crop_id')
  String get cropId;

  /// Plot the crop grows on; a farmer may only use their own.
  @BuiltValueField(wireName: r'plot_id')
  String get plotId;

  /// Farming practice the farmer declares (FR56), e.g. `[ipm]`.
  @BuiltValueField(wireName: r'practice_tags_declared')
  BuiltList<PracticeTag>? get practiceTagsDeclared;

  /// Season, e.g. `2025-26 Rabi`.
  @BuiltValueField(wireName: r'season_label')
  String? get seasonLabel;

  LotIn._();

  factory LotIn([void updates(LotInBuilder b)]) = _$LotIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LotInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LotIn> get serializer => _$LotInSerializer();
}

class _$LotInSerializer implements PrimitiveSerializer<LotIn> {
  @override
  final Iterable<Type> types = const [LotIn, _$LotIn];

  @override
  final String wireName = r'LotIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LotIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'crop_id';
    yield serializers.serialize(
      object.cropId,
      specifiedType: const FullType(String),
    );
    yield r'plot_id';
    yield serializers.serialize(
      object.plotId,
      specifiedType: const FullType(String),
    );
    if (object.practiceTagsDeclared != null) {
      yield r'practice_tags_declared';
      yield serializers.serialize(
        object.practiceTagsDeclared,
        specifiedType: const FullType(BuiltList, [FullType(PracticeTag)]),
      );
    }
    if (object.seasonLabel != null) {
      yield r'season_label';
      yield serializers.serialize(
        object.seasonLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LotIn object, {
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
    required LotInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'crop_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cropId = valueDes;
          break;
        case r'plot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plotId = valueDes;
          break;
        case r'practice_tags_declared':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(PracticeTag)]),
          ) as BuiltList<PracticeTag>?;
          if (valueDes == null) continue;
          result.practiceTagsDeclared.replace(valueDes);
          break;
        case r'season_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.seasonLabel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LotIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LotInBuilder();
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
