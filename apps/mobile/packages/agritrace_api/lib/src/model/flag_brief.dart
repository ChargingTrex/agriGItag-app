//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/severity.dart';
import 'package:agritrace_api/src/model/flag_status.dart';
import 'package:agritrace_api/src/model/flag_subject.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_brief.g.dart';

/// An active rule flag found by the gate checks of this request (B08 `run_gate_checks`).
///
/// Properties:
/// * [id] - Flag id; details at `GET /v1/flags/{id}`.
/// * [ruleCode] - Rule, e.g. `quantity_mismatch`.
/// * [severity] - info, warn, or hold (a hold blocks approval and GI labelling).
/// * [status] - open or escalated.
/// * [subjectId] - Id of the flagged row.
/// * [subjectType] - Kind of row flagged.
@BuiltValue()
abstract class FlagBrief implements Built<FlagBrief, FlagBriefBuilder> {
  /// Flag id; details at `GET /v1/flags/{id}`.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Rule, e.g. `quantity_mismatch`.
  @BuiltValueField(wireName: r'rule_code')
  String get ruleCode;

  /// info, warn, or hold (a hold blocks approval and GI labelling).
  @BuiltValueField(wireName: r'severity')
  Severity get severity;
  // enum severityEnum {  info,  warn,  hold,  };

  /// open or escalated.
  @BuiltValueField(wireName: r'status')
  FlagStatus get status;
  // enum statusEnum {  open,  cleared,  fixed,  escalated,  };

  /// Id of the flagged row.
  @BuiltValueField(wireName: r'subject_id')
  String get subjectId;

  /// Kind of row flagged.
  @BuiltValueField(wireName: r'subject_type')
  FlagSubject get subjectType;
  // enum subjectTypeEnum {  plot,  event,  lot,  batch,  reading,  };

  FlagBrief._();

  factory FlagBrief([void updates(FlagBriefBuilder b)]) = _$FlagBrief;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagBriefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagBrief> get serializer => _$FlagBriefSerializer();
}

class _$FlagBriefSerializer implements PrimitiveSerializer<FlagBrief> {
  @override
  final Iterable<Type> types = const [FlagBrief, _$FlagBrief];

  @override
  final String wireName = r'FlagBrief';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagBrief object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'rule_code';
    yield serializers.serialize(
      object.ruleCode,
      specifiedType: const FullType(String),
    );
    yield r'severity';
    yield serializers.serialize(
      object.severity,
      specifiedType: const FullType(Severity),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FlagStatus),
    );
    yield r'subject_id';
    yield serializers.serialize(
      object.subjectId,
      specifiedType: const FullType(String),
    );
    yield r'subject_type';
    yield serializers.serialize(
      object.subjectType,
      specifiedType: const FullType(FlagSubject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagBrief object, {
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
    required FlagBriefBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'rule_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ruleCode = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Severity),
          ) as Severity;
          result.severity = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FlagStatus),
          ) as FlagStatus;
          result.status = valueDes;
          break;
        case r'subject_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subjectId = valueDes;
          break;
        case r'subject_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FlagSubject),
          ) as FlagSubject;
          result.subjectType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagBrief deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagBriefBuilder();
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
