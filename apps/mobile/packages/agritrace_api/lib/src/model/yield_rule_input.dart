//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/hold_margin_pct.dart';
import 'package:agritrace_api/src/model/warn_margin_pct.dart';
import 'package:agritrace_api/src/model/ceiling_kg_per_acre.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'yield_rule_input.g.dart';

/// Plausible yield per acre with the warn and hold margins of the yield-ceiling check (FR68, Stage 7).
///
/// Properties:
/// * [ceilingKgPerAcre]
/// * [holdMarginPct]
/// * [note] - Where the ceiling came from; calibrate after season 1.
/// * [warnMarginPct]
@BuiltValue()
abstract class YieldRuleInput
    implements Built<YieldRuleInput, YieldRuleInputBuilder> {
  @BuiltValueField(wireName: r'ceiling_kg_per_acre')
  CeilingKgPerAcre get ceilingKgPerAcre;

  @BuiltValueField(wireName: r'hold_margin_pct')
  HoldMarginPct get holdMarginPct;

  /// Where the ceiling came from; calibrate after season 1.
  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'warn_margin_pct')
  WarnMarginPct get warnMarginPct;

  YieldRuleInput._();

  factory YieldRuleInput([void updates(YieldRuleInputBuilder b)]) =
      _$YieldRuleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(YieldRuleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<YieldRuleInput> get serializer =>
      _$YieldRuleInputSerializer();
}

class _$YieldRuleInputSerializer
    implements PrimitiveSerializer<YieldRuleInput> {
  @override
  final Iterable<Type> types = const [YieldRuleInput, _$YieldRuleInput];

  @override
  final String wireName = r'YieldRuleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    YieldRuleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ceiling_kg_per_acre';
    yield serializers.serialize(
      object.ceilingKgPerAcre,
      specifiedType: const FullType(CeilingKgPerAcre),
    );
    yield r'hold_margin_pct';
    yield serializers.serialize(
      object.holdMarginPct,
      specifiedType: const FullType(HoldMarginPct),
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
      specifiedType: const FullType(WarnMarginPct),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    YieldRuleInput object, {
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
    required YieldRuleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ceiling_kg_per_acre':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CeilingKgPerAcre),
          ) as CeilingKgPerAcre;
          result.ceilingKgPerAcre.replace(valueDes);
          break;
        case r'hold_margin_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HoldMarginPct),
          ) as HoldMarginPct;
          result.holdMarginPct.replace(valueDes);
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
            specifiedType: const FullType(WarnMarginPct),
          ) as WarnMarginPct;
          result.warnMarginPct.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  YieldRuleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = YieldRuleInputBuilder();
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
