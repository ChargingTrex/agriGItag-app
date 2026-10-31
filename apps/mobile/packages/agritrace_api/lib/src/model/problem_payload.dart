//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'problem_payload.g.dart';

/// A problem seen in the field (pest, disease, weather), reported with a photo.
///
/// Properties:
/// * [affectedArea] - Area affected, unit `acre` or `cent`.
/// * [description] - What was seen, in the farmer's words.
/// * [problemType] - Kind of problem.
@BuiltValue()
abstract class ProblemPayload
    implements Built<ProblemPayload, ProblemPayloadBuilder> {
  /// Area affected, unit `acre` or `cent`.
  @BuiltValueField(wireName: r'affected_area')
  QuantityInput? get affectedArea;

  /// What was seen, in the farmer's words.
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Kind of problem.
  @BuiltValueField(wireName: r'problem_type')
  ProblemPayloadProblemTypeEnum? get problemType;
  // enum problemTypeEnum {  pest,  disease,  weather,  other,  };

  ProblemPayload._();

  factory ProblemPayload([void updates(ProblemPayloadBuilder b)]) =
      _$ProblemPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProblemPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProblemPayload> get serializer =>
      _$ProblemPayloadSerializer();
}

class _$ProblemPayloadSerializer
    implements PrimitiveSerializer<ProblemPayload> {
  @override
  final Iterable<Type> types = const [ProblemPayload, _$ProblemPayload];

  @override
  final String wireName = r'ProblemPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProblemPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.affectedArea != null) {
      yield r'affected_area';
      yield serializers.serialize(
        object.affectedArea,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.problemType != null) {
      yield r'problem_type';
      yield serializers.serialize(
        object.problemType,
        specifiedType: const FullType.nullable(ProblemPayloadProblemTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProblemPayload object, {
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
    required ProblemPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'affected_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.affectedArea.replace(valueDes);
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'problem_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(ProblemPayloadProblemTypeEnum),
          ) as ProblemPayloadProblemTypeEnum?;
          if (valueDes == null) continue;
          result.problemType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProblemPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProblemPayloadBuilder();
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

/// Kind of problem.
class ProblemPayloadProblemTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pest')
  static const ProblemPayloadProblemTypeEnum pest =
      _$problemPayloadProblemTypeEnum_pest;
  @BuiltValueEnumConst(wireName: r'disease')
  static const ProblemPayloadProblemTypeEnum disease =
      _$problemPayloadProblemTypeEnum_disease;
  @BuiltValueEnumConst(wireName: r'weather')
  static const ProblemPayloadProblemTypeEnum weather =
      _$problemPayloadProblemTypeEnum_weather;
  @BuiltValueEnumConst(wireName: r'other')
  static const ProblemPayloadProblemTypeEnum other =
      _$problemPayloadProblemTypeEnum_other;

  static Serializer<ProblemPayloadProblemTypeEnum> get serializer =>
      _$problemPayloadProblemTypeEnumSerializer;

  const ProblemPayloadProblemTypeEnum._(String name) : super(name);

  static BuiltSet<ProblemPayloadProblemTypeEnum> get values =>
      _$problemPayloadProblemTypeEnumValues;
  static ProblemPayloadProblemTypeEnum valueOf(String name) =>
      _$problemPayloadProblemTypeEnumValueOf(name);
}
