//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/grade_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/parameter_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'grade_out.g.dart';

/// A stored grade computation of a batch (FR48, FR49, FR51).
///
/// Properties:
/// * [batchId] - Batch graded.
/// * [computedAt] - When the engine ran.
/// * [computedGrade] - Lowest grade every parameter meets; null when incomplete.
/// * [declaredGrade] - Grade the QC officer declared.
/// * [id] - Computation id.
/// * [labCertified] - Any batch reading of a profile parameter is a lab result with a NABL number (FR51).
/// * [perParameter] - Contribution of each parameter, by code.
/// * [profileVersionId] - Profile version applied.
/// * [status] - ok, incomplete or declared_above_computed (FR49 blocks approval).
@BuiltValue()
abstract class GradeOut implements Built<GradeOut, GradeOutBuilder> {
  /// Batch graded.
  @BuiltValueField(wireName: r'batch_id')
  String get batchId;

  /// When the engine ran.
  @BuiltValueField(wireName: r'computed_at')
  DateTime get computedAt;

  /// Lowest grade every parameter meets; null when incomplete.
  @BuiltValueField(wireName: r'computed_grade')
  String? get computedGrade;

  /// Grade the QC officer declared.
  @BuiltValueField(wireName: r'declared_grade')
  String? get declaredGrade;

  /// Computation id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Any batch reading of a profile parameter is a lab result with a NABL number (FR51).
  @BuiltValueField(wireName: r'lab_certified')
  bool get labCertified;

  /// Contribution of each parameter, by code.
  @BuiltValueField(wireName: r'per_parameter')
  BuiltMap<String, ParameterResult> get perParameter;

  /// Profile version applied.
  @BuiltValueField(wireName: r'profile_version_id')
  String get profileVersionId;

  /// ok, incomplete or declared_above_computed (FR49 blocks approval).
  @BuiltValueField(wireName: r'status')
  GradeStatus get status;
  // enum statusEnum {  incomplete,  ok,  declared_above_computed,  };

  GradeOut._();

  factory GradeOut([void updates(GradeOutBuilder b)]) = _$GradeOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GradeOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GradeOut> get serializer => _$GradeOutSerializer();
}

class _$GradeOutSerializer implements PrimitiveSerializer<GradeOut> {
  @override
  final Iterable<Type> types = const [GradeOut, _$GradeOut];

  @override
  final String wireName = r'GradeOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GradeOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batch_id';
    yield serializers.serialize(
      object.batchId,
      specifiedType: const FullType(String),
    );
    yield r'computed_at';
    yield serializers.serialize(
      object.computedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'computed_grade';
    yield object.computedGrade == null
        ? null
        : serializers.serialize(
            object.computedGrade,
            specifiedType: const FullType.nullable(String),
          );
    yield r'declared_grade';
    yield object.declaredGrade == null
        ? null
        : serializers.serialize(
            object.declaredGrade,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lab_certified';
    yield serializers.serialize(
      object.labCertified,
      specifiedType: const FullType(bool),
    );
    yield r'per_parameter';
    yield serializers.serialize(
      object.perParameter,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType(ParameterResult)]),
    );
    yield r'profile_version_id';
    yield serializers.serialize(
      object.profileVersionId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GradeStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GradeOut object, {
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
    required GradeOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.batchId = valueDes;
          break;
        case r'computed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.computedAt = valueDes;
          break;
        case r'computed_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.computedGrade = valueDes;
          break;
        case r'declared_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.declaredGrade = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lab_certified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.labCertified = valueDes;
          break;
        case r'per_parameter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType(ParameterResult)]),
          ) as BuiltMap<String, ParameterResult>;
          result.perParameter.replace(valueDes);
          break;
        case r'profile_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.profileVersionId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GradeStatus),
          ) as GradeStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GradeOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GradeOutBuilder();
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
