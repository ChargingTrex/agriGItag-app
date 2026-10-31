//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/farmer_status.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_row.g.dart';

/// One row of the per-farmer dashboard table; no phone, address or plot location (CLAUDE.md §6).
///
/// Properties:
/// * [block] - Development block of the village.
/// * [code] - Farmer code, unique in the FPO.
/// * [declaredArea] - Sum of declared plot areas, unit `acre`.
/// * [id] - Farmer id.
/// * [lots] - Lots, of the `crop_id` filter when given (count).
/// * [lotsComplete] - Of those, lots with every mandatory event (count, D-037).
/// * [name] - Name in English script.
/// * [nameLocal] - Name in the local script.
/// * [plots] - Plots (count).
/// * [status] - Onboarding status.
/// * [village] - Village name in English.
/// * [villageId] - Village from the villages master, if picked.
/// * [walkedArea] - Sum of walked plot areas, unit `acre`.
@BuiltValue()
abstract class FarmerRow implements Built<FarmerRow, FarmerRowBuilder> {
  /// Development block of the village.
  @BuiltValueField(wireName: r'block')
  String? get block;

  /// Farmer code, unique in the FPO.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Sum of declared plot areas, unit `acre`.
  @BuiltValueField(wireName: r'declared_area')
  QuantityOutput get declaredArea;

  /// Farmer id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Lots, of the `crop_id` filter when given (count).
  @BuiltValueField(wireName: r'lots')
  int get lots;

  /// Of those, lots with every mandatory event (count, D-037).
  @BuiltValueField(wireName: r'lots_complete')
  int get lotsComplete;

  /// Name in English script.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// Plots (count).
  @BuiltValueField(wireName: r'plots')
  int get plots;

  /// Onboarding status.
  @BuiltValueField(wireName: r'status')
  FarmerStatus get status;
  // enum statusEnum {  pending,  active,  suspended,  };

  /// Village name in English.
  @BuiltValueField(wireName: r'village')
  String? get village;

  /// Village from the villages master, if picked.
  @BuiltValueField(wireName: r'village_id')
  String? get villageId;

  /// Sum of walked plot areas, unit `acre`.
  @BuiltValueField(wireName: r'walked_area')
  QuantityOutput get walkedArea;

  FarmerRow._();

  factory FarmerRow([void updates(FarmerRowBuilder b)]) = _$FarmerRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerRow> get serializer => _$FarmerRowSerializer();
}

class _$FarmerRowSerializer implements PrimitiveSerializer<FarmerRow> {
  @override
  final Iterable<Type> types = const [FarmerRow, _$FarmerRow];

  @override
  final String wireName = r'FarmerRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'block';
    yield object.block == null
        ? null
        : serializers.serialize(
            object.block,
            specifiedType: const FullType.nullable(String),
          );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'declared_area';
    yield serializers.serialize(
      object.declaredArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lots';
    yield serializers.serialize(
      object.lots,
      specifiedType: const FullType(int),
    );
    yield r'lots_complete';
    yield serializers.serialize(
      object.lotsComplete,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'name_local';
    yield object.nameLocal == null
        ? null
        : serializers.serialize(
            object.nameLocal,
            specifiedType: const FullType.nullable(String),
          );
    yield r'plots';
    yield serializers.serialize(
      object.plots,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FarmerStatus),
    );
    yield r'village';
    yield object.village == null
        ? null
        : serializers.serialize(
            object.village,
            specifiedType: const FullType.nullable(String),
          );
    yield r'village_id';
    yield object.villageId == null
        ? null
        : serializers.serialize(
            object.villageId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'walked_area';
    yield serializers.serialize(
      object.walkedArea,
      specifiedType: const FullType(QuantityOutput),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerRow object, {
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
    required FarmerRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'block':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.block = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.declaredArea.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lots = valueDes;
          break;
        case r'lots_complete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lotsComplete = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'name_local':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameLocal = valueDes;
          break;
        case r'plots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.plots = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FarmerStatus),
          ) as FarmerStatus;
          result.status = valueDes;
          break;
        case r'village':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.village = valueDes;
          break;
        case r'village_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.villageId = valueDes;
          break;
        case r'walked_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.walkedArea.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FarmerRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerRowBuilder();
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
