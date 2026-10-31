//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trail_rule_output.g.dart';

/// How a parameter may change from one capture stage to the next (FR50: moisture must not rise).
///
/// Properties:
/// * [overrideWithReason] - A violating reading is accepted when it carries a `reason_code` (then flagged).
/// * [parameter] - Parameter code the rule follows.
/// * [rule] - `non_increasing`: a later stage may not be higher.
/// * [stages] - Stages in chain order, earliest first.
/// * [tolerance] - Rise tolerated before it counts as a violation (meter noise).
@BuiltValue()
abstract class TrailRuleOutput
    implements Built<TrailRuleOutput, TrailRuleOutputBuilder> {
  /// A violating reading is accepted when it carries a `reason_code` (then flagged).
  @BuiltValueField(wireName: r'override_with_reason')
  bool? get overrideWithReason;

  /// Parameter code the rule follows.
  @BuiltValueField(wireName: r'parameter')
  String get parameter;

  /// `non_increasing`: a later stage may not be higher.
  @BuiltValueField(wireName: r'rule')
  TrailRuleOutputRuleEnum get rule;
  // enum ruleEnum {  non_increasing,  };

  /// Stages in chain order, earliest first.
  @BuiltValueField(wireName: r'stages')
  BuiltList<ReadingStage> get stages;

  /// Rise tolerated before it counts as a violation (meter noise).
  @BuiltValueField(wireName: r'tolerance')
  num? get tolerance;

  TrailRuleOutput._();

  factory TrailRuleOutput([void updates(TrailRuleOutputBuilder b)]) =
      _$TrailRuleOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrailRuleOutputBuilder b) => b
    ..overrideWithReason = false
    ..tolerance = 0.0;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrailRuleOutput> get serializer =>
      _$TrailRuleOutputSerializer();
}

class _$TrailRuleOutputSerializer
    implements PrimitiveSerializer<TrailRuleOutput> {
  @override
  final Iterable<Type> types = const [TrailRuleOutput, _$TrailRuleOutput];

  @override
  final String wireName = r'TrailRuleOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrailRuleOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.overrideWithReason != null) {
      yield r'override_with_reason';
      yield serializers.serialize(
        object.overrideWithReason,
        specifiedType: const FullType(bool),
      );
    }
    yield r'parameter';
    yield serializers.serialize(
      object.parameter,
      specifiedType: const FullType(String),
    );
    yield r'rule';
    yield serializers.serialize(
      object.rule,
      specifiedType: const FullType(TrailRuleOutputRuleEnum),
    );
    yield r'stages';
    yield serializers.serialize(
      object.stages,
      specifiedType: const FullType(BuiltList, [FullType(ReadingStage)]),
    );
    if (object.tolerance != null) {
      yield r'tolerance';
      yield serializers.serialize(
        object.tolerance,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrailRuleOutput object, {
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
    required TrailRuleOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'override_with_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.overrideWithReason = valueDes;
          break;
        case r'parameter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.parameter = valueDes;
          break;
        case r'rule':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrailRuleOutputRuleEnum),
          ) as TrailRuleOutputRuleEnum;
          result.rule = valueDes;
          break;
        case r'stages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReadingStage)]),
          ) as BuiltList<ReadingStage>;
          result.stages.replace(valueDes);
          break;
        case r'tolerance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.tolerance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrailRuleOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrailRuleOutputBuilder();
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

/// `non_increasing`: a later stage may not be higher.
class TrailRuleOutputRuleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'non_increasing')
  static const TrailRuleOutputRuleEnum nonIncreasing =
      _$trailRuleOutputRuleEnum_nonIncreasing;

  static Serializer<TrailRuleOutputRuleEnum> get serializer =>
      _$trailRuleOutputRuleEnumSerializer;

  const TrailRuleOutputRuleEnum._(String name) : super(name);

  static BuiltSet<TrailRuleOutputRuleEnum> get values =>
      _$trailRuleOutputRuleEnumValues;
  static TrailRuleOutputRuleEnum valueOf(String name) =>
      _$trailRuleOutputRuleEnumValueOf(name);
}
