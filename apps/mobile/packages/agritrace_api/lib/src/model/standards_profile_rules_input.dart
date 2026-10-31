//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/lot_gate_input.dart';
import 'package:agritrace_api/src/model/yield_rule_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/lab_certified_requires.dart';
import 'package:agritrace_api/src/model/trail_rule_input.dart';
import 'package:agritrace_api/src/model/standard_ref.dart';
import 'package:agritrace_api/src/model/parameter_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standards_profile_rules_input.g.dart';

/// The rules JSON of one Standards Profile version, interpreted by `grade_engine` (§4, D-015, FR47).  Grades are listed best first; `fail_grade` is what a batch gets when a parameter meets no grade.
///
/// Properties:
/// * [failGrade] - Grade given when a limit is not met, e.g. Below grade.
/// * [grades] - Grade names, best first, e.g. [Special, Standard].
/// * [labCertifiedRequires] - Condition for the Lab-certified badge (FR51); null: never lab-certified.
/// * [lotGates] - Named lot gates, e.g. `ready_for_sale` (Dataflow Stage 5).
/// * [parameters] - Every parameter of the standard (FR46).
/// * [publicNote] - Shown on the public page next to the grade (FR51); stamped when a version is published with parameters still `load_from_standard`.
/// * [schemaVersion] - Version of this JSON layout; only 1 exists.
/// * [standard] - Standard, edition and clause the limits come from (FR47).
/// * [trailRules] - Stage-to-stage rules (FR50).
/// * [yield_] - Yield-ceiling parameters (FR68); null: no yield check for the crop.
@BuiltValue()
abstract class StandardsProfileRulesInput
    implements
        Built<StandardsProfileRulesInput, StandardsProfileRulesInputBuilder> {
  /// Grade given when a limit is not met, e.g. Below grade.
  @BuiltValueField(wireName: r'fail_grade')
  String get failGrade;

  /// Grade names, best first, e.g. [Special, Standard].
  @BuiltValueField(wireName: r'grades')
  BuiltList<String> get grades;

  /// Condition for the Lab-certified badge (FR51); null: never lab-certified.
  @BuiltValueField(wireName: r'lab_certified_requires')
  LabCertifiedRequires? get labCertifiedRequires;

  /// Named lot gates, e.g. `ready_for_sale` (Dataflow Stage 5).
  @BuiltValueField(wireName: r'lot_gates')
  BuiltMap<String, LotGateInput>? get lotGates;

  /// Every parameter of the standard (FR46).
  @BuiltValueField(wireName: r'parameters')
  BuiltList<ParameterInput> get parameters;

  /// Shown on the public page next to the grade (FR51); stamped when a version is published with parameters still `load_from_standard`.
  @BuiltValueField(wireName: r'public_note')
  String? get publicNote;

  /// Version of this JSON layout; only 1 exists.
  @BuiltValueField(wireName: r'schema_version')
  StandardsProfileRulesInputSchemaVersionEnum get schemaVersion;
  // enum schemaVersionEnum {  1,  };

  /// Standard, edition and clause the limits come from (FR47).
  @BuiltValueField(wireName: r'standard')
  StandardRef get standard;

  /// Stage-to-stage rules (FR50).
  @BuiltValueField(wireName: r'trail_rules')
  BuiltList<TrailRuleInput>? get trailRules;

  /// Yield-ceiling parameters (FR68); null: no yield check for the crop.
  @BuiltValueField(wireName: r'yield')
  YieldRuleInput? get yield_;

  StandardsProfileRulesInput._();

  factory StandardsProfileRulesInput(
          [void updates(StandardsProfileRulesInputBuilder b)]) =
      _$StandardsProfileRulesInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandardsProfileRulesInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandardsProfileRulesInput> get serializer =>
      _$StandardsProfileRulesInputSerializer();
}

class _$StandardsProfileRulesInputSerializer
    implements PrimitiveSerializer<StandardsProfileRulesInput> {
  @override
  final Iterable<Type> types = const [
    StandardsProfileRulesInput,
    _$StandardsProfileRulesInput
  ];

  @override
  final String wireName = r'StandardsProfileRulesInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandardsProfileRulesInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fail_grade';
    yield serializers.serialize(
      object.failGrade,
      specifiedType: const FullType(String),
    );
    yield r'grades';
    yield serializers.serialize(
      object.grades,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.labCertifiedRequires != null) {
      yield r'lab_certified_requires';
      yield serializers.serialize(
        object.labCertifiedRequires,
        specifiedType: const FullType.nullable(LabCertifiedRequires),
      );
    }
    if (object.lotGates != null) {
      yield r'lot_gates';
      yield serializers.serialize(
        object.lotGates,
        specifiedType: const FullType(
            BuiltMap, [FullType(String), FullType(LotGateInput)]),
      );
    }
    yield r'parameters';
    yield serializers.serialize(
      object.parameters,
      specifiedType: const FullType(BuiltList, [FullType(ParameterInput)]),
    );
    if (object.publicNote != null) {
      yield r'public_note';
      yield serializers.serialize(
        object.publicNote,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'schema_version';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType:
          const FullType(StandardsProfileRulesInputSchemaVersionEnum),
    );
    yield r'standard';
    yield serializers.serialize(
      object.standard,
      specifiedType: const FullType(StandardRef),
    );
    if (object.trailRules != null) {
      yield r'trail_rules';
      yield serializers.serialize(
        object.trailRules,
        specifiedType: const FullType(BuiltList, [FullType(TrailRuleInput)]),
      );
    }
    if (object.yield_ != null) {
      yield r'yield';
      yield serializers.serialize(
        object.yield_,
        specifiedType: const FullType.nullable(YieldRuleInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StandardsProfileRulesInput object, {
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
    required StandardsProfileRulesInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fail_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.failGrade = valueDes;
          break;
        case r'grades':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.grades.replace(valueDes);
          break;
        case r'lab_certified_requires':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(LabCertifiedRequires),
          ) as LabCertifiedRequires?;
          if (valueDes == null) continue;
          result.labCertifiedRequires.replace(valueDes);
          break;
        case r'lot_gates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(LotGateInput)]),
          ) as BuiltMap<String, LotGateInput>?;
          if (valueDes == null) continue;
          result.lotGates.replace(valueDes);
          break;
        case r'parameters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ParameterInput)]),
          ) as BuiltList<ParameterInput>;
          result.parameters.replace(valueDes);
          break;
        case r'public_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.publicNote = valueDes;
          break;
        case r'schema_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(StandardsProfileRulesInputSchemaVersionEnum),
          ) as StandardsProfileRulesInputSchemaVersionEnum;
          result.schemaVersion = valueDes;
          break;
        case r'standard':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandardRef),
          ) as StandardRef;
          result.standard.replace(valueDes);
          break;
        case r'trail_rules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(TrailRuleInput)]),
          ) as BuiltList<TrailRuleInput>?;
          if (valueDes == null) continue;
          result.trailRules.replace(valueDes);
          break;
        case r'yield':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(YieldRuleInput),
          ) as YieldRuleInput?;
          if (valueDes == null) continue;
          result.yield_.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandardsProfileRulesInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandardsProfileRulesInputBuilder();
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

/// Version of this JSON layout; only 1 exists.
class StandardsProfileRulesInputSchemaVersionEnum extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 1)
  static const StandardsProfileRulesInputSchemaVersionEnum number1 =
      _$standardsProfileRulesInputSchemaVersionEnum_number1;

  static Serializer<StandardsProfileRulesInputSchemaVersionEnum>
      get serializer => _$standardsProfileRulesInputSchemaVersionEnumSerializer;

  const StandardsProfileRulesInputSchemaVersionEnum._(String name)
      : super(name);

  static BuiltSet<StandardsProfileRulesInputSchemaVersionEnum> get values =>
      _$standardsProfileRulesInputSchemaVersionEnumValues;
  static StandardsProfileRulesInputSchemaVersionEnum valueOf(String name) =>
      _$standardsProfileRulesInputSchemaVersionEnumValueOf(name);
}
