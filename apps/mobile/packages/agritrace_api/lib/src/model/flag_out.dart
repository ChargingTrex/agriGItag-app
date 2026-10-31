//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/severity.dart';
import 'package:agritrace_api/src/model/flag_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/flag_subject.dart';
import 'package:built_value/json_object.dart';
import 'package:agritrace_api/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_out.g.dart';

/// One rule finding and its review state.
///
/// Properties:
/// * [assignedRole] - Role expected to review it: field_officer, or fpo_admin.
/// * [details] - Rule inputs and limits behind the finding; quantities carry `unit`.
/// * [fpoId] - FPO that owns the flagged record.
/// * [id] - Flag id (UUIDv7, so newer flags sort later).
/// * [raisedAt] - When a rule first raised it, ISO 8601 UTC.
/// * [resolutionNote] - Reviewer's note: method, evidence, what was fixed.
/// * [resolutionReasonCode] - Coded reason of the resolution; `rule_passed` when a later rule run no longer raised it.
/// * [resolvedAt] - When it was resolved, ISO 8601 UTC.
/// * [resolvedBy] - User who resolved it; null when open or closed by a rule.
/// * [ruleCode] - Rule that raised it, e.g. `quantity_mismatch`, `event_off_plot`.
/// * [severity] - info, warn, or hold (keeps the lot out of GI-labelled batches).
/// * [status] - open, cleared (looked fine), fixed, or escalated to the FPO admin.
/// * [subjectId] - Id of the flagged record.
/// * [subjectType] - Kind of record flagged: plot, event, lot, batch or reading.
@BuiltValue()
abstract class FlagOut implements Built<FlagOut, FlagOutBuilder> {
  /// Role expected to review it: field_officer, or fpo_admin.
  @BuiltValueField(wireName: r'assigned_role')
  Role? get assignedRole;
  // enum assignedRoleEnum {  farmer,  field_officer,  qc_officer,  fpo_admin,  viewer,  };

  /// Rule inputs and limits behind the finding; quantities carry `unit`.
  @BuiltValueField(wireName: r'details')
  BuiltMap<String, JsonObject?>? get details;

  /// FPO that owns the flagged record.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Flag id (UUIDv7, so newer flags sort later).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// When a rule first raised it, ISO 8601 UTC.
  @BuiltValueField(wireName: r'raised_at')
  DateTime get raisedAt;

  /// Reviewer's note: method, evidence, what was fixed.
  @BuiltValueField(wireName: r'resolution_note')
  String? get resolutionNote;

  /// Coded reason of the resolution; `rule_passed` when a later rule run no longer raised it.
  @BuiltValueField(wireName: r'resolution_reason_code')
  String? get resolutionReasonCode;

  /// When it was resolved, ISO 8601 UTC.
  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  /// User who resolved it; null when open or closed by a rule.
  @BuiltValueField(wireName: r'resolved_by')
  String? get resolvedBy;

  /// Rule that raised it, e.g. `quantity_mismatch`, `event_off_plot`.
  @BuiltValueField(wireName: r'rule_code')
  String get ruleCode;

  /// info, warn, or hold (keeps the lot out of GI-labelled batches).
  @BuiltValueField(wireName: r'severity')
  Severity get severity;
  // enum severityEnum {  info,  warn,  hold,  };

  /// open, cleared (looked fine), fixed, or escalated to the FPO admin.
  @BuiltValueField(wireName: r'status')
  FlagStatus get status;
  // enum statusEnum {  open,  cleared,  fixed,  escalated,  };

  /// Id of the flagged record.
  @BuiltValueField(wireName: r'subject_id')
  String get subjectId;

  /// Kind of record flagged: plot, event, lot, batch or reading.
  @BuiltValueField(wireName: r'subject_type')
  FlagSubject get subjectType;
  // enum subjectTypeEnum {  plot,  event,  lot,  batch,  reading,  };

  FlagOut._();

  factory FlagOut([void updates(FlagOutBuilder b)]) = _$FlagOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagOut> get serializer => _$FlagOutSerializer();
}

class _$FlagOutSerializer implements PrimitiveSerializer<FlagOut> {
  @override
  final Iterable<Type> types = const [FlagOut, _$FlagOut];

  @override
  final String wireName = r'FlagOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'assigned_role';
    yield object.assignedRole == null
        ? null
        : serializers.serialize(
            object.assignedRole,
            specifiedType: const FullType.nullable(Role),
          );
    yield r'details';
    yield object.details == null
        ? null
        : serializers.serialize(
            object.details,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'raised_at';
    yield serializers.serialize(
      object.raisedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'resolution_note';
    yield object.resolutionNote == null
        ? null
        : serializers.serialize(
            object.resolutionNote,
            specifiedType: const FullType.nullable(String),
          );
    yield r'resolution_reason_code';
    yield object.resolutionReasonCode == null
        ? null
        : serializers.serialize(
            object.resolutionReasonCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'resolved_by';
    yield object.resolvedBy == null
        ? null
        : serializers.serialize(
            object.resolvedBy,
            specifiedType: const FullType.nullable(String),
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
    FlagOut object, {
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
    required FlagOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assigned_role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Role),
          ) as Role?;
          if (valueDes == null) continue;
          result.assignedRole = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.details.replace(valueDes);
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'raised_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.raisedAt = valueDes;
          break;
        case r'resolution_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionNote = valueDes;
          break;
        case r'resolution_reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionReasonCode = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'resolved_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolvedBy = valueDes;
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
  FlagOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagOutBuilder();
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
