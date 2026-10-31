//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'yield_rule_output.g.dart';

/// Plausible yield per acre with the warn and hold margins of the yield-ceiling check (FR68, Stage 7).
///
/// Properties:
/// * [ceilingKgPerAcre] - Plausible maximum harvest per acre, in kg/acre.
/// * [holdMarginPct] - Excess above which the lot is held out of GI, %.
/// * [note] - Where the ceiling came from; calibrate after season 1.
/// * [warnMarginPct] - Excess over the ceiling still passing silently, %.
@BuiltValue()
abstract class YieldRuleOutput
    implements Built<YieldRuleOutput, YieldRuleOutputBuilder> {
  /// Plausible maximum harvest per acre, in kg/acre.
  @BuiltValueField(wireName: r'ceiling_kg_per_acre')
  num get ceilingKgPerAcre;

  /// Excess above which the lot is held out of GI, %.
  @BuiltValueField(wireName: r'hold_margin_pct')
  num get holdMarginPct;

  /// Where the ceiling came from; calibrate after season 1.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Excess over the ceiling still passing silently, %.
  @BuiltValueField(wireName: r'warn_margin_pct')
  num get warnMarginPct;

  YieldRuleOutput._();

  factory YieldRuleOutput([void updates(YieldRuleOutputBuilder b)]) =
      _$YieldRuleOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(YieldRuleOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<YieldRuleOutput> get serializer =>
      _$YieldRuleOutputSerializer();
}

class _$YieldRuleOutputSerializer
    implements PrimitiveSerializer<YieldRuleOutput> {
  @override
  final Iterable<Type> types = const [YieldRuleOutput, _$YieldRuleOutput];

  @override
  final String wireName = r'YieldRuleOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    YieldRuleOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ceiling_kg_per_acre';
    yield serializers.serialize(
      object.ceilingKgPerAcre,
      specifiedType: const FullType(num),
    );
    yield r'hold_margin_pct';
    yield serializers.serialize(
      object.holdMarginPct,
      specifiedType: const FullType(num),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'warn_margin_pct';
    yield serializers.serialize(
      object.warnMarginPct,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    YieldRuleOutput object, {
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
    required YieldRuleOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ceiling_kg_per_acre':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.ceilingKgPerAcre = valueDes;
          break;
        case r'hold_margin_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.holdMarginPct = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'warn_margin_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.warnMarginPct = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  YieldRuleOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = YieldRuleOutputBuilder();
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
