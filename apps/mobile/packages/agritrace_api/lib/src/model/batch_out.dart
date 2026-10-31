//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/gi_block_reason.dart';
import 'package:agritrace_api/src/model/flag_brief.dart';
import 'package:agritrace_api/src/model/batch_status.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:agritrace_api/src/model/share_out.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_out.g.dart';

/// A batch with its shares, gate state and GI verdict.
///
/// Properties:
/// * [bestBeforeDate] - Best-before date for the label (FR62).
/// * [code] - 12-char batch code, e.g. `FGP8T4033HM7` (QR, public URL).
/// * [computedGrade] - Grade approved at the grading gate (FR48).
/// * [createdBy] - Admin who created the batch.
/// * [cropId] - Crop of every component lot.
/// * [currentBuildNo] - Latest public page build number; 0 before publishing.
/// * [flags] - Active flags found by this request's gate checks (POST routes); empty on GET.
/// * [giBlockReasons] - Why GI is blocked; empty when verified.
/// * [giLabelRequested] - The admin asked for the GI label.
/// * [giVerified] - GI label requested and every component lot passed the re-check.
/// * [graded] - Graded quantity in kg (ceiling for packing).
/// * [id] - Batch id.
/// * [packDate] - Pack date for the label (FR62).
/// * [packed] - Quantity in final packs in kg.
/// * [processorId] - Processor.
/// * [secondSignoffBy] - Second admin who signed it off.
/// * [secondSignoffRequired] - Total above the FPO's `second_signoff_threshold_kg` (Dataflow §4 gate 2).
/// * [shares] - Component lots and their shares.
/// * [standardsProfileVersionId] - Profile version graded on.
/// * [status] - created → graded → packed → published.
/// * [superlotCode] - Super-lot code, e.g. `COMBO_LOT_6C1DCCFE`.
/// * [totalReceived] - Sum of the lots' intake kg (FR10).
@BuiltValue()
abstract class BatchOut implements Built<BatchOut, BatchOutBuilder> {
  /// Best-before date for the label (FR62).
  @BuiltValueField(wireName: r'best_before_date')
  Date? get bestBeforeDate;

  /// 12-char batch code, e.g. `FGP8T4033HM7` (QR, public URL).
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Grade approved at the grading gate (FR48).
  @BuiltValueField(wireName: r'computed_grade')
  String? get computedGrade;

  /// Admin who created the batch.
  @BuiltValueField(wireName: r'created_by')
  String get createdBy;

  /// Crop of every component lot.
  @BuiltValueField(wireName: r'crop_id')
  String get cropId;

  /// Latest public page build number; 0 before publishing.
  @BuiltValueField(wireName: r'current_build_no')
  int get currentBuildNo;

  /// Active flags found by this request's gate checks (POST routes); empty on GET.
  @BuiltValueField(wireName: r'flags')
  BuiltList<FlagBrief>? get flags;

  /// Why GI is blocked; empty when verified.
  @BuiltValueField(wireName: r'gi_block_reasons')
  BuiltList<GiBlockReason> get giBlockReasons;

  /// The admin asked for the GI label.
  @BuiltValueField(wireName: r'gi_label_requested')
  bool get giLabelRequested;

  /// GI label requested and every component lot passed the re-check.
  @BuiltValueField(wireName: r'gi_verified')
  bool get giVerified;

  /// Graded quantity in kg (ceiling for packing).
  @BuiltValueField(wireName: r'graded')
  QuantityOutput? get graded;

  /// Batch id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Pack date for the label (FR62).
  @BuiltValueField(wireName: r'pack_date')
  Date? get packDate;

  /// Quantity in final packs in kg.
  @BuiltValueField(wireName: r'packed')
  QuantityOutput? get packed;

  /// Processor.
  @BuiltValueField(wireName: r'processor_id')
  String get processorId;

  /// Second admin who signed it off.
  @BuiltValueField(wireName: r'second_signoff_by')
  String? get secondSignoffBy;

  /// Total above the FPO's `second_signoff_threshold_kg` (Dataflow §4 gate 2).
  @BuiltValueField(wireName: r'second_signoff_required')
  bool get secondSignoffRequired;

  /// Component lots and their shares.
  @BuiltValueField(wireName: r'shares')
  BuiltList<ShareOut> get shares;

  /// Profile version graded on.
  @BuiltValueField(wireName: r'standards_profile_version_id')
  String? get standardsProfileVersionId;

  /// created → graded → packed → published.
  @BuiltValueField(wireName: r'status')
  BatchStatus get status;
  // enum statusEnum {  created,  graded,  packed,  published,  };

  /// Super-lot code, e.g. `COMBO_LOT_6C1DCCFE`.
  @BuiltValueField(wireName: r'superlot_code')
  String? get superlotCode;

  /// Sum of the lots' intake kg (FR10).
  @BuiltValueField(wireName: r'total_received')
  QuantityOutput? get totalReceived;

  BatchOut._();

  factory BatchOut([void updates(BatchOutBuilder b)]) = _$BatchOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BatchOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BatchOut> get serializer => _$BatchOutSerializer();
}

class _$BatchOutSerializer implements PrimitiveSerializer<BatchOut> {
  @override
  final Iterable<Type> types = const [BatchOut, _$BatchOut];

  @override
  final String wireName = r'BatchOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BatchOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bestBeforeDate != null) {
      yield r'best_before_date';
      yield serializers.serialize(
        object.bestBeforeDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.computedGrade != null) {
      yield r'computed_grade';
      yield serializers.serialize(
        object.computedGrade,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_by';
    yield serializers.serialize(
      object.createdBy,
      specifiedType: const FullType(String),
    );
    yield r'crop_id';
    yield serializers.serialize(
      object.cropId,
      specifiedType: const FullType(String),
    );
    yield r'current_build_no';
    yield serializers.serialize(
      object.currentBuildNo,
      specifiedType: const FullType(int),
    );
    if (object.flags != null) {
      yield r'flags';
      yield serializers.serialize(
        object.flags,
        specifiedType: const FullType(BuiltList, [FullType(FlagBrief)]),
      );
    }
    yield r'gi_block_reasons';
    yield serializers.serialize(
      object.giBlockReasons,
      specifiedType: const FullType(BuiltList, [FullType(GiBlockReason)]),
    );
    yield r'gi_label_requested';
    yield serializers.serialize(
      object.giLabelRequested,
      specifiedType: const FullType(bool),
    );
    yield r'gi_verified';
    yield serializers.serialize(
      object.giVerified,
      specifiedType: const FullType(bool),
    );
    if (object.graded != null) {
      yield r'graded';
      yield serializers.serialize(
        object.graded,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.packDate != null) {
      yield r'pack_date';
      yield serializers.serialize(
        object.packDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.packed != null) {
      yield r'packed';
      yield serializers.serialize(
        object.packed,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
    yield r'processor_id';
    yield serializers.serialize(
      object.processorId,
      specifiedType: const FullType(String),
    );
    if (object.secondSignoffBy != null) {
      yield r'second_signoff_by';
      yield serializers.serialize(
        object.secondSignoffBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'second_signoff_required';
    yield serializers.serialize(
      object.secondSignoffRequired,
      specifiedType: const FullType(bool),
    );
    yield r'shares';
    yield serializers.serialize(
      object.shares,
      specifiedType: const FullType(BuiltList, [FullType(ShareOut)]),
    );
    if (object.standardsProfileVersionId != null) {
      yield r'standards_profile_version_id';
      yield serializers.serialize(
        object.standardsProfileVersionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BatchStatus),
    );
    if (object.superlotCode != null) {
      yield r'superlot_code';
      yield serializers.serialize(
        object.superlotCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.totalReceived != null) {
      yield r'total_received';
      yield serializers.serialize(
        object.totalReceived,
        specifiedType: const FullType.nullable(QuantityOutput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BatchOut object, {
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
    required BatchOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'best_before_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.bestBeforeDate = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'computed_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.computedGrade = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdBy = valueDes;
          break;
        case r'crop_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cropId = valueDes;
          break;
        case r'current_build_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.currentBuildNo = valueDes;
          break;
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(FlagBrief)]),
          ) as BuiltList<FlagBrief>?;
          if (valueDes == null) continue;
          result.flags.replace(valueDes);
          break;
        case r'gi_block_reasons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GiBlockReason)]),
          ) as BuiltList<GiBlockReason>;
          result.giBlockReasons.replace(valueDes);
          break;
        case r'gi_label_requested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.giLabelRequested = valueDes;
          break;
        case r'gi_verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.giVerified = valueDes;
          break;
        case r'graded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.graded.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'pack_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.packDate = valueDes;
          break;
        case r'packed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.packed.replace(valueDes);
          break;
        case r'processor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.processorId = valueDes;
          break;
        case r'second_signoff_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.secondSignoffBy = valueDes;
          break;
        case r'second_signoff_required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.secondSignoffRequired = valueDes;
          break;
        case r'shares':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ShareOut)]),
          ) as BuiltList<ShareOut>;
          result.shares.replace(valueDes);
          break;
        case r'standards_profile_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.standardsProfileVersionId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BatchStatus),
          ) as BatchStatus;
          result.status = valueDes;
          break;
        case r'superlot_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.superlotCode = valueDes;
          break;
        case r'total_received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.totalReceived.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BatchOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BatchOutBuilder();
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
