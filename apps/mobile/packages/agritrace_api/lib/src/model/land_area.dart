//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/area_by_village.dart';
import 'package:agritrace_api/src/model/area_by_block.dart';
import 'package:agritrace_api/src/model/area_stats.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'land_area.g.dart';

/// Land Area Analytics: acres by village and block, declared vs walked, GI-confirmed share.
///
/// Properties:
/// * [byBlock] - One row per block, by block name.
/// * [byVillage] - One row per village, by block then village name.
/// * [total] - All plots in scope.
@BuiltValue()
abstract class LandArea implements Built<LandArea, LandAreaBuilder> {
  /// One row per block, by block name.
  @BuiltValueField(wireName: r'by_block')
  BuiltList<AreaByBlock> get byBlock;

  /// One row per village, by block then village name.
  @BuiltValueField(wireName: r'by_village')
  BuiltList<AreaByVillage> get byVillage;

  /// All plots in scope.
  @BuiltValueField(wireName: r'total')
  AreaStats get total;

  LandArea._();

  factory LandArea([void updates(LandAreaBuilder b)]) = _$LandArea;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LandAreaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LandArea> get serializer => _$LandAreaSerializer();
}

class _$LandAreaSerializer implements PrimitiveSerializer<LandArea> {
  @override
  final Iterable<Type> types = const [LandArea, _$LandArea];

  @override
  final String wireName = r'LandArea';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LandArea object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'by_block';
    yield serializers.serialize(
      object.byBlock,
      specifiedType: const FullType(BuiltList, [FullType(AreaByBlock)]),
    );
    yield r'by_village';
    yield serializers.serialize(
      object.byVillage,
      specifiedType: const FullType(BuiltList, [FullType(AreaByVillage)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(AreaStats),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LandArea object, {
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
    required LandAreaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'by_block':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AreaByBlock)]),
          ) as BuiltList<AreaByBlock>;
          result.byBlock.replace(valueDes);
          break;
        case r'by_village':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AreaByVillage)]),
          ) as BuiltList<AreaByVillage>;
          result.byVillage.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AreaStats),
          ) as AreaStats;
          result.total.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LandArea deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LandAreaBuilder();
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
