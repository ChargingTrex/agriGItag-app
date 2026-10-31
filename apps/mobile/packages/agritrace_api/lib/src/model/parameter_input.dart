//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/range_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/reading_source.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'parameter_input.g.dart';

/// One quality parameter of a profile: unit, method, where it is captured and its limit per grade.
///
/// Properties:
/// * [captureStages] - Stages where this parameter is captured (FR43 moisture: drying end, intake, grading).
/// * [code] - Stable snake_case code readings use, e.g. `moisture`.
/// * [declareForGrades] - Grades whose label must declare this value (role label_declaration).
/// * [exceptionFlags] - Batch attributes (e.g. `monsooned` coffee) under which a value outside the limits is a warning, not a fail: the parameter then does not lower the grade.
/// * [gradingStage] - Stage whose latest reading is used to compute the grade.
/// * [limits] - Interval the value must lie in to reach each grade, keyed by grade name; when set, every grade needs a key (`{}` means no constraint for that grade). Null: not graded on this parameter (see `status`).
/// * [maxGradeForSource] - Best grade a reading from that source can earn, e.g. visual → Standard (FR44).
/// * [methodRef] - Test method the standard prescribes (FR42).
/// * [nameEn] - English label for forms and the public page.
/// * [nameLocal] - Label in the local script (Tamil for the pilot).
/// * [plausible] - Physically sensible range; readings outside it are rejected at entry (FR50).
/// * [required_] - A grading reading is needed for a complete grade (only when `limits` is set).
/// * [role] - `grading` takes part in the grade; `label_declaration` is printed on the label for `declare_for_grades`; `contract_spec` is a buyer specification, recorded but never graded.
/// * [sourcesAllowed] - Measurement sources accepted at entry for this parameter (FR42, FR44).
/// * [status] - `load_from_standard`: limits still to be copied from the standard; graded as missing.
/// * [unit] - Unit every reading must carry, e.g. `%`.
@BuiltValue()
abstract class ParameterInput
    implements Built<ParameterInput, ParameterInputBuilder> {
  /// Stages where this parameter is captured (FR43 moisture: drying end, intake, grading).
  @BuiltValueField(wireName: r'capture_stages')
  BuiltList<ReadingStage>? get captureStages;

  /// Stable snake_case code readings use, e.g. `moisture`.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Grades whose label must declare this value (role label_declaration).
  @BuiltValueField(wireName: r'declare_for_grades')
  BuiltList<String>? get declareForGrades;

  /// Batch attributes (e.g. `monsooned` coffee) under which a value outside the limits is a warning, not a fail: the parameter then does not lower the grade.
  @BuiltValueField(wireName: r'exception_flags')
  BuiltList<String>? get exceptionFlags;

  /// Stage whose latest reading is used to compute the grade.
  @BuiltValueField(wireName: r'grading_stage')
  ReadingStage? get gradingStage;
  // enum gradingStageEnum {  drying_end,  intake,  grading,  storage,  };

  /// Interval the value must lie in to reach each grade, keyed by grade name; when set, every grade needs a key (`{}` means no constraint for that grade). Null: not graded on this parameter (see `status`).
  @BuiltValueField(wireName: r'limits')
  BuiltMap<String, RangeInput>? get limits;

  /// Best grade a reading from that source can earn, e.g. visual → Standard (FR44).
  @BuiltValueField(wireName: r'max_grade_for_source')
  BuiltMap<String, String>? get maxGradeForSource;

  /// Test method the standard prescribes (FR42).
  @BuiltValueField(wireName: r'method_ref')
  String? get methodRef;

  /// English label for forms and the public page.
  @BuiltValueField(wireName: r'name_en')
  String? get nameEn;

  /// Label in the local script (Tamil for the pilot).
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// Physically sensible range; readings outside it are rejected at entry (FR50).
  @BuiltValueField(wireName: r'plausible')
  RangeInput? get plausible;

  /// A grading reading is needed for a complete grade (only when `limits` is set).
  @BuiltValueField(wireName: r'required')
  bool? get required_;

  /// `grading` takes part in the grade; `label_declaration` is printed on the label for `declare_for_grades`; `contract_spec` is a buyer specification, recorded but never graded.
  @BuiltValueField(wireName: r'role')
  ParameterInputRoleEnum? get role;
  // enum roleEnum {  grading,  label_declaration,  contract_spec,  };

  /// Measurement sources accepted at entry for this parameter (FR42, FR44).
  @BuiltValueField(wireName: r'sources_allowed')
  BuiltList<ReadingSource>? get sourcesAllowed;

  /// `load_from_standard`: limits still to be copied from the standard; graded as missing.
  @BuiltValueField(wireName: r'status')
  ParameterInputStatusEnum? get status;
  // enum statusEnum {  active,  load_from_standard,  };

  /// Unit every reading must carry, e.g. `%`.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  ParameterInput._();

  factory ParameterInput([void updates(ParameterInputBuilder b)]) =
      _$ParameterInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ParameterInputBuilder b) => b
    ..gradingStage = ReadingStage.grading
    ..required_ = false
    ..role = ParameterInputRoleEnum.valueOf('grading')
    ..status = ParameterInputStatusEnum.valueOf('active');

  @BuiltValueSerializer(custom: true)
  static Serializer<ParameterInput> get serializer =>
      _$ParameterInputSerializer();
}

class _$ParameterInputSerializer
    implements PrimitiveSerializer<ParameterInput> {
  @override
  final Iterable<Type> types = const [ParameterInput, _$ParameterInput];

  @override
  final String wireName = r'ParameterInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ParameterInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.captureStages != null) {
      yield r'capture_stages';
      yield serializers.serialize(
        object.captureStages,
        specifiedType: const FullType(BuiltList, [FullType(ReadingStage)]),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.declareForGrades != null) {
      yield r'declare_for_grades';
      yield serializers.serialize(
        object.declareForGrades,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.exceptionFlags != null) {
      yield r'exception_flags';
      yield serializers.serialize(
        object.exceptionFlags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.gradingStage != null) {
      yield r'grading_stage';
      yield serializers.serialize(
        object.gradingStage,
        specifiedType: const FullType(ReadingStage),
      );
    }
    if (object.limits != null) {
      yield r'limits';
      yield serializers.serialize(
        object.limits,
        specifiedType: const FullType.nullable(
            BuiltMap, [FullType(String), FullType(RangeInput)]),
      );
    }
    if (object.maxGradeForSource != null) {
      yield r'max_grade_for_source';
      yield serializers.serialize(
        object.maxGradeForSource,
        specifiedType:
            const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.methodRef != null) {
      yield r'method_ref';
      yield serializers.serialize(
        object.methodRef,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nameEn != null) {
      yield r'name_en';
      yield serializers.serialize(
        object.nameEn,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nameLocal != null) {
      yield r'name_local';
      yield serializers.serialize(
        object.nameLocal,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.plausible != null) {
      yield r'plausible';
      yield serializers.serialize(
        object.plausible,
        specifiedType: const FullType.nullable(RangeInput),
      );
    }
    if (object.required_ != null) {
      yield r'required';
      yield serializers.serialize(
        object.required_,
        specifiedType: const FullType(bool),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(ParameterInputRoleEnum),
      );
    }
    if (object.sourcesAllowed != null) {
      yield r'sources_allowed';
      yield serializers.serialize(
        object.sourcesAllowed,
        specifiedType: const FullType(BuiltList, [FullType(ReadingSource)]),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ParameterInputStatusEnum),
      );
    }
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ParameterInput object, {
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
    required ParameterInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'capture_stages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(ReadingStage)]),
          ) as BuiltList<ReadingStage>?;
          if (valueDes == null) continue;
          result.captureStages.replace(valueDes);
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'declare_for_grades':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.declareForGrades.replace(valueDes);
          break;
        case r'exception_flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.exceptionFlags.replace(valueDes);
          break;
        case r'grading_stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReadingStage),
          ) as ReadingStage?;
          if (valueDes == null) continue;
          result.gradingStage = valueDes;
          break;
        case r'limits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(RangeInput)]),
          ) as BuiltMap<String, RangeInput>?;
          if (valueDes == null) continue;
          result.limits.replace(valueDes);
          break;
        case r'max_grade_for_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.maxGradeForSource.replace(valueDes);
          break;
        case r'method_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.methodRef = valueDes;
          break;
        case r'name_en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameEn = valueDes;
          break;
        case r'name_local':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameLocal = valueDes;
          break;
        case r'plausible':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RangeInput),
          ) as RangeInput?;
          if (valueDes == null) continue;
          result.plausible.replace(valueDes);
          break;
        case r'required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.required_ = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ParameterInputRoleEnum),
          ) as ParameterInputRoleEnum?;
          if (valueDes == null) continue;
          result.role = valueDes;
          break;
        case r'sources_allowed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(ReadingSource)]),
          ) as BuiltList<ReadingSource>?;
          if (valueDes == null) continue;
          result.sourcesAllowed.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ParameterInputStatusEnum),
          ) as ParameterInputStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ParameterInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ParameterInputBuilder();
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

/// `grading` takes part in the grade; `label_declaration` is printed on the label for `declare_for_grades`; `contract_spec` is a buyer specification, recorded but never graded.
class ParameterInputRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grading')
  static const ParameterInputRoleEnum grading =
      _$parameterInputRoleEnum_grading;
  @BuiltValueEnumConst(wireName: r'label_declaration')
  static const ParameterInputRoleEnum labelDeclaration =
      _$parameterInputRoleEnum_labelDeclaration;
  @BuiltValueEnumConst(wireName: r'contract_spec')
  static const ParameterInputRoleEnum contractSpec =
      _$parameterInputRoleEnum_contractSpec;

  static Serializer<ParameterInputRoleEnum> get serializer =>
      _$parameterInputRoleEnumSerializer;

  const ParameterInputRoleEnum._(String name) : super(name);

  static BuiltSet<ParameterInputRoleEnum> get values =>
      _$parameterInputRoleEnumValues;
  static ParameterInputRoleEnum valueOf(String name) =>
      _$parameterInputRoleEnumValueOf(name);
}

/// `load_from_standard`: limits still to be copied from the standard; graded as missing.
class ParameterInputStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const ParameterInputStatusEnum active =
      _$parameterInputStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'load_from_standard')
  static const ParameterInputStatusEnum loadFromStandard =
      _$parameterInputStatusEnum_loadFromStandard;

  static Serializer<ParameterInputStatusEnum> get serializer =>
      _$parameterInputStatusEnumSerializer;

  const ParameterInputStatusEnum._(String name) : super(name);

  static BuiltSet<ParameterInputStatusEnum> get values =>
      _$parameterInputStatusEnumValues;
  static ParameterInputStatusEnum valueOf(String name) =>
      _$parameterInputStatusEnumValueOf(name);
}
