//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/range_output.dart';
import 'package:agritrace_api/src/model/reading_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'parameter_result.g.dart';

/// How one parameter contributed to the grade (`grade_computations.per_parameter`).
///
/// Properties:
/// * [cappedBySource] - True when `max_grade_for_source` lowered the grade.
/// * [grade] - Grade reached by this parameter (graded only).
/// * [labCertified] - An accredited lab result (source lab, non-blank NABL number) for this parameter is attached to the batch at any stage; lets the public page say which values are lab-measured (FR51).
/// * [limit] - Limit of the grade reached; null for the fail grade.
/// * [outcome] - graded: limits applied; missing: no reading at the grading stage; profile_incomplete: limits still load_from_standard; not_graded: label or contract value; exception: limits waived by a batch exception flag (warning).
/// * [parameter] - Parameter code.
/// * [readingId] - Reading used.
/// * [source_] - Source of the reading used.
/// * [unit] - Unit of the value.
/// * [value] - Value used.
@BuiltValue()
abstract class ParameterResult
    implements Built<ParameterResult, ParameterResultBuilder> {
  /// True when `max_grade_for_source` lowered the grade.
  @BuiltValueField(wireName: r'capped_by_source')
  bool? get cappedBySource;

  /// Grade reached by this parameter (graded only).
  @BuiltValueField(wireName: r'grade')
  String? get grade;

  /// An accredited lab result (source lab, non-blank NABL number) for this parameter is attached to the batch at any stage; lets the public page say which values are lab-measured (FR51).
  @BuiltValueField(wireName: r'lab_certified')
  bool? get labCertified;

  /// Limit of the grade reached; null for the fail grade.
  @BuiltValueField(wireName: r'limit')
  RangeOutput? get limit;

  /// graded: limits applied; missing: no reading at the grading stage; profile_incomplete: limits still load_from_standard; not_graded: label or contract value; exception: limits waived by a batch exception flag (warning).
  @BuiltValueField(wireName: r'outcome')
  ParameterResultOutcomeEnum get outcome;
  // enum outcomeEnum {  graded,  missing,  profile_incomplete,  not_graded,  exception,  };

  /// Parameter code.
  @BuiltValueField(wireName: r'parameter')
  String get parameter;

  /// Reading used.
  @BuiltValueField(wireName: r'reading_id')
  String? get readingId;

  /// Source of the reading used.
  @BuiltValueField(wireName: r'source')
  ReadingSource? get source_;
  // enum source_Enum {  lab,  instrument,  visual,  };

  /// Unit of the value.
  @BuiltValueField(wireName: r'unit')
  String? get unit;

  /// Value used.
  @BuiltValueField(wireName: r'value')
  String? get value;

  ParameterResult._();

  factory ParameterResult([void updates(ParameterResultBuilder b)]) =
      _$ParameterResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ParameterResultBuilder b) => b
    ..cappedBySource = false
    ..labCertified = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ParameterResult> get serializer =>
      _$ParameterResultSerializer();
}

class _$ParameterResultSerializer
    implements PrimitiveSerializer<ParameterResult> {
  @override
  final Iterable<Type> types = const [ParameterResult, _$ParameterResult];

  @override
  final String wireName = r'ParameterResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ParameterResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cappedBySource != null) {
      yield r'capped_by_source';
      yield serializers.serialize(
        object.cappedBySource,
        specifiedType: const FullType(bool),
      );
    }
    if (object.grade != null) {
      yield r'grade';
      yield serializers.serialize(
        object.grade,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.labCertified != null) {
      yield r'lab_certified';
      yield serializers.serialize(
        object.labCertified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType.nullable(RangeOutput),
      );
    }
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(ParameterResultOutcomeEnum),
    );
    yield r'parameter';
    yield serializers.serialize(
      object.parameter,
      specifiedType: const FullType(String),
    );
    if (object.readingId != null) {
      yield r'reading_id';
      yield serializers.serialize(
        object.readingId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType.nullable(ReadingSource),
      );
    }
    if (object.unit != null) {
      yield r'unit';
      yield serializers.serialize(
        object.unit,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.value != null) {
      yield r'value';
      yield serializers.serialize(
        object.value,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ParameterResult object, {
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
    required ParameterResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'capped_by_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.cappedBySource = valueDes;
          break;
        case r'grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.grade = valueDes;
          break;
        case r'lab_certified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.labCertified = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RangeOutput),
          ) as RangeOutput?;
          if (valueDes == null) continue;
          result.limit.replace(valueDes);
          break;
        case r'outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ParameterResultOutcomeEnum),
          ) as ParameterResultOutcomeEnum;
          result.outcome = valueDes;
          break;
        case r'parameter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.parameter = valueDes;
          break;
        case r'reading_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.readingId = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReadingSource),
          ) as ReadingSource?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.value = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ParameterResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ParameterResultBuilder();
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

/// graded: limits applied; missing: no reading at the grading stage; profile_incomplete: limits still load_from_standard; not_graded: label or contract value; exception: limits waived by a batch exception flag (warning).
class ParameterResultOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'graded')
  static const ParameterResultOutcomeEnum graded =
      _$parameterResultOutcomeEnum_graded;
  @BuiltValueEnumConst(wireName: r'missing')
  static const ParameterResultOutcomeEnum missing =
      _$parameterResultOutcomeEnum_missing;
  @BuiltValueEnumConst(wireName: r'profile_incomplete')
  static const ParameterResultOutcomeEnum profileIncomplete =
      _$parameterResultOutcomeEnum_profileIncomplete;
  @BuiltValueEnumConst(wireName: r'not_graded')
  static const ParameterResultOutcomeEnum notGraded =
      _$parameterResultOutcomeEnum_notGraded;
  @BuiltValueEnumConst(wireName: r'exception')
  static const ParameterResultOutcomeEnum exception =
      _$parameterResultOutcomeEnum_exception;

  static Serializer<ParameterResultOutcomeEnum> get serializer =>
      _$parameterResultOutcomeEnumSerializer;

  const ParameterResultOutcomeEnum._(String name) : super(name);

  static BuiltSet<ParameterResultOutcomeEnum> get values =>
      _$parameterResultOutcomeEnumValues;
  static ParameterResultOutcomeEnum valueOf(String name) =>
      _$parameterResultOutcomeEnumValueOf(name);
}
