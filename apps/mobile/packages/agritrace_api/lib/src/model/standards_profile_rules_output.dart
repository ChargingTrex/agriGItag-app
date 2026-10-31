//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/yield_rule_output.dart';
import 'package:agritrace_api/src/model/parameter_output.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/lab_certified_requires.dart';
import 'package:agritrace_api/src/model/trail_rule_output.dart';
import 'package:agritrace_api/src/model/lot_gate_output.dart';
import 'package:agritrace_api/src/model/standard_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standards_profile_rules_output.g.dart';

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
abstract class StandardsProfileRulesOutput
    implements
        Built<StandardsProfileRulesOutput, StandardsProfileRulesOutputBuilder> {
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
  BuiltMap<String, LotGateOutput>? get lotGates;

  /// Every parameter of the standard (FR46).
  @BuiltValueField(wireName: r'parameters')
  BuiltList<ParameterOutput> get parameters;

  /// Shown on the public page next to the grade (FR51); stamped when a version is published with parameters still `load_from_standard`.
  @BuiltValueField(wireName: r'public_note')
  String? get publicNote;

  /// Version of this JSON layout; only 1 exists.
  @BuiltValueField(wireName: r'schema_version')
  StandardsProfileRulesOutputSchemaVersionEnum get schemaVersion;
  // enum schemaVersionEnum {  1,  };

  /// Standard, edition and clause the limits come from (FR47).
  @BuiltValueField(wireName: r'standard')
  StandardRef get standard;

  /// Stage-to-stage rules (FR50).
  @BuiltValueField(wireName: r'trail_rules')
  BuiltList<TrailRuleOutput>? get trailRules;

  /// Yield-ceiling parameters (FR68); null: no yield check for the crop.
  @BuiltValueField(wireName: r'yield')
  YieldRuleOutput? get yield_;

  StandardsProfileRulesOutput._();

  factory StandardsProfileRulesOutput(
          [void updates(StandardsProfileRulesOutputBuilder b)]) =
      _$StandardsProfileRulesOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandardsProfileRulesOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandardsProfileRulesOutput> get serializer =>
      _$StandardsProfileRulesOutputSerializer();
}

class _$StandardsProfileRulesOutputSerializer
    implements PrimitiveSerializer<StandardsProfileRulesOutput> {
  @override
  final Iterable<Type> types = const [
    StandardsProfileRulesOutput,
    _$StandardsProfileRulesOutput
  ];

  @override
  final String wireName = r'StandardsProfileRulesOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandardsProfileRulesOutput object, {
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
            BuiltMap, [FullType(String), FullType(LotGateOutput)]),
      );
    }
    yield r'parameters';
    yield serializers.serialize(
      object.parameters,
      specifiedType: const FullType(BuiltList, [FullType(ParameterOutput)]),
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
          const FullType(StandardsProfileRulesOutputSchemaVersionEnum),
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
        specifiedType: const FullType(BuiltList, [FullType(TrailRuleOutput)]),
      );
    }
    if (object.yield_ != null) {
      yield r'yield';
      yield serializers.serialize(
        object.yield_,
        specifiedType: const FullType.nullable(YieldRuleOutput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StandardsProfileRulesOutput object, {
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
    required StandardsProfileRulesOutputBuilder result,
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
                BuiltMap, [FullType(String), FullType(LotGateOutput)]),
          ) as BuiltMap<String, LotGateOutput>?;
          if (valueDes == null) continue;
          result.lotGates.replace(valueDes);
          break;
        case r'parameters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ParameterOutput)]),
          ) as BuiltList<ParameterOutput>;
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
                const FullType(StandardsProfileRulesOutputSchemaVersionEnum),
          ) as StandardsProfileRulesOutputSchemaVersionEnum;
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
                const FullType.nullable(BuiltList, [FullType(TrailRuleOutput)]),
          ) as BuiltList<TrailRuleOutput>?;
          if (valueDes == null) continue;
          result.trailRules.replace(valueDes);
          break;
        case r'yield':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(YieldRuleOutput),
          ) as YieldRuleOutput?;
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
  StandardsProfileRulesOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandardsProfileRulesOutputBuilder();
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
class StandardsProfileRulesOutputSchemaVersionEnum extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 1)
  static const StandardsProfileRulesOutputSchemaVersionEnum number1 =
      _$standardsProfileRulesOutputSchemaVersionEnum_number1;

  static Serializer<StandardsProfileRulesOutputSchemaVersionEnum>
      get serializer =>
          _$standardsProfileRulesOutputSchemaVersionEnumSerializer;

  const StandardsProfileRulesOutputSchemaVersionEnum._(String name)
      : super(name);

  static BuiltSet<StandardsProfileRulesOutputSchemaVersionEnum> get values =>
      _$standardsProfileRulesOutputSchemaVersionEnumValues;
  static StandardsProfileRulesOutputSchemaVersionEnum valueOf(String name) =>
      _$standardsProfileRulesOutputSchemaVersionEnumValueOf(name);
}
