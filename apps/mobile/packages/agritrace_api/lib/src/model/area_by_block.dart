//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'area_by_block.g.dart';

/// Plot areas of one development block.
///
/// Properties:
/// * [block] - Development block; null groups farmers without a village/block.
/// * [declaredArea] - Sum of declared areas, unit `acre`.
/// * [giConfirmedArea] - Declared area of plots whose location is `confirmed` inside the GI region, unit `acre`.
/// * [giConfirmedShare] - gi_confirmed_area ÷ declared_area, unit `%`; null when declared_area is 0.
/// * [plots] - Plots (count).
/// * [walkedArea] - Sum of walked areas, unit `acre`.
/// * [walkedDeclaredArea] - Declared area of the walked plots only, unit `acre`; compare with `walked_area`.
/// * [walkedPlots] - Plots with a GPS-walked boundary (count).
@BuiltValue()
abstract class AreaByBlock implements Built<AreaByBlock, AreaByBlockBuilder> {
  /// Development block; null groups farmers without a village/block.
  @BuiltValueField(wireName: r'block')
  String? get block;

  /// Sum of declared areas, unit `acre`.
  @BuiltValueField(wireName: r'declared_area')
  QuantityOutput get declaredArea;

  /// Declared area of plots whose location is `confirmed` inside the GI region, unit `acre`.
  @BuiltValueField(wireName: r'gi_confirmed_area')
  QuantityOutput get giConfirmedArea;

  /// gi_confirmed_area ÷ declared_area, unit `%`; null when declared_area is 0.
  @BuiltValueField(wireName: r'gi_confirmed_share')
  QuantityOutput? get giConfirmedShare;

  /// Plots (count).
  @BuiltValueField(wireName: r'plots')
  int get plots;

  /// Sum of walked areas, unit `acre`.
  @BuiltValueField(wireName: r'walked_area')
  QuantityOutput get walkedArea;

  /// Declared area of the walked plots only, unit `acre`; compare with `walked_area`.
  @BuiltValueField(wireName: r'walked_declared_area')
  QuantityOutput get walkedDeclaredArea;

  /// Plots with a GPS-walked boundary (count).
  @BuiltValueField(wireName: r'walked_plots')
  int get walkedPlots;

  AreaByBlock._();

  factory AreaByBlock([void updates(AreaByBlockBuilder b)]) = _$AreaByBlock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AreaByBlockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AreaByBlock> get serializer => _$AreaByBlockSerializer();
}

class _$AreaByBlockSerializer implements PrimitiveSerializer<AreaByBlock> {
  @override
  final Iterable<Type> types = const [AreaByBlock, _$AreaByBlock];

  @override
  final String wireName = r'AreaByBlock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AreaByBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'block';
    yield object.block == null
        ? null
        : serializers.serialize(
            object.block,
            specifiedType: const FullType.nullable(String),
          );
    yield r'declared_area';
    yield serializers.serialize(
      object.declaredArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'gi_confirmed_area';
    yield serializers.serialize(
      object.giConfirmedArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'gi_confirmed_share';
    yield object.giConfirmedShare == null
        ? null
        : serializers.serialize(
            object.giConfirmedShare,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'plots';
    yield serializers.serialize(
      object.plots,
      specifiedType: const FullType(int),
    );
    yield r'walked_area';
    yield serializers.serialize(
      object.walkedArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'walked_declared_area';
    yield serializers.serialize(
      object.walkedDeclaredArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'walked_plots';
    yield serializers.serialize(
      object.walkedPlots,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AreaByBlock object, {
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
    required AreaByBlockBuilder result,
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
        case r'declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.declaredArea.replace(valueDes);
          break;
        case r'gi_confirmed_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.giConfirmedArea.replace(valueDes);
          break;
        case r'gi_confirmed_share':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.giConfirmedShare.replace(valueDes);
          break;
        case r'plots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.plots = valueDes;
          break;
        case r'walked_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.walkedArea.replace(valueDes);
          break;
        case r'walked_declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.walkedDeclaredArea.replace(valueDes);
          break;
        case r'walked_plots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.walkedPlots = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AreaByBlock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaByBlockBuilder();
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
