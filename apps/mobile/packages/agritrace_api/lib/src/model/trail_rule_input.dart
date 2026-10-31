//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/tolerance.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trail_rule_input.g.dart';

/// How a parameter may change from one capture stage to the next (FR50: moisture must not rise).
///
/// Properties:
/// * [overrideWithReason] - A violating reading is accepted when it carries a `reason_code` (then flagged).
/// * [parameter] - Parameter code the rule follows.
/// * [rule] - `non_increasing`: a later stage may not be higher.
/// * [stages] - Stages in chain order, earliest first.
/// * [tolerance]
@BuiltValue()
abstract class TrailRuleInput
    implements Built<TrailRuleInput, TrailRuleInputBuilder> {
  /// A violating reading is accepted when it carries a `reason_code` (then flagged).
  @BuiltValueField(wireName: r'override_with_reason')
  bool? get overrideWithReason;

  /// Parameter code the rule follows.
  @BuiltValueField(wireName: r'parameter')
  String get parameter;

  /// `non_increasing`: a later stage may not be higher.
  @BuiltValueField(wireName: r'rule')
  TrailRuleInputRuleEnum get rule;
  // enum ruleEnum {  non_increasing,  };

  /// Stages in chain order, earliest first.
  @BuiltValueField(wireName: r'stages')
  BuiltList<ReadingStage> get stages;

  @BuiltValueField(wireName: r'tolerance')
  Tolerance? get tolerance;

  TrailRuleInput._();

  factory TrailRuleInput([void updates(TrailRuleInputBuilder b)]) =
      _$TrailRuleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrailRuleInputBuilder b) =>
      b..overrideWithReason = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrailRuleInput> get serializer =>
      _$TrailRuleInputSerializer();
}

class _$TrailRuleInputSerializer
    implements PrimitiveSerializer<TrailRuleInput> {
  @override
  final Iterable<Type> types = const [TrailRuleInput, _$TrailRuleInput];

  @override
  final String wireName = r'TrailRuleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrailRuleInput object, {
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
      specifiedType: const FullType(TrailRuleInputRuleEnum),
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
        specifiedType: const FullType(Tolerance),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrailRuleInput object, {
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
    required TrailRuleInputBuilder result,
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
            specifiedType: const FullType(TrailRuleInputRuleEnum),
          ) as TrailRuleInputRuleEnum;
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
            specifiedType: const FullType.nullable(Tolerance),
          ) as Tolerance?;
          if (valueDes == null) continue;
          result.tolerance.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrailRuleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrailRuleInputBuilder();
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
class TrailRuleInputRuleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'non_increasing')
  static const TrailRuleInputRuleEnum nonIncreasing =
      _$trailRuleInputRuleEnum_nonIncreasing;

  static Serializer<TrailRuleInputRuleEnum> get serializer =>
      _$trailRuleInputRuleEnumSerializer;

  const TrailRuleInputRuleEnum._(String name) : super(name);

  static BuiltSet<TrailRuleInputRuleEnum> get values =>
      _$trailRuleInputRuleEnumValues;
  static TrailRuleInputRuleEnum valueOf(String name) =>
      _$trailRuleInputRuleEnumValueOf(name);
}
