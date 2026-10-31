//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/reconciliation.dart';
import 'package:agritrace_api/src/model/flag_brief.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'intake_out.g.dart';

/// A stored intake with its quantity chain and the flags the lot rules raised.
///
/// Properties:
/// * [acceptedByUserId] - QC officer or FPO admin who accepted the lot.
/// * [correctionReason] - Why the superseded intake was wrong.
/// * [flags] - Active flags on the lot after the intake; empty on a resend.
/// * [id] - Intake id (the client id).
/// * [intakeMoistureReadingId] - Intake moisture reading.
/// * [lotId] - Lot received.
/// * [pricePerKg] - Price in INR per kg.
/// * [processorId] - Receiving processor.
/// * [received] - Quantity received in kg.
/// * [reconciliation] - Strict chain harvested ≥ packed ≥ received at intake (FR60); the tolerant verdict is the `quantity_mismatch` flag.
/// * [saleDate] - Date of sale.
/// * [supersedesIntakeId] - Intake this row corrects, if any.
@BuiltValue()
abstract class IntakeOut implements Built<IntakeOut, IntakeOutBuilder> {
  /// QC officer or FPO admin who accepted the lot.
  @BuiltValueField(wireName: r'accepted_by_user_id')
  String get acceptedByUserId;

  /// Why the superseded intake was wrong.
  @BuiltValueField(wireName: r'correction_reason')
  String? get correctionReason;

  /// Active flags on the lot after the intake; empty on a resend.
  @BuiltValueField(wireName: r'flags')
  BuiltList<FlagBrief>? get flags;

  /// Intake id (the client id).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Intake moisture reading.
  @BuiltValueField(wireName: r'intake_moisture_reading_id')
  String? get intakeMoistureReadingId;

  /// Lot received.
  @BuiltValueField(wireName: r'lot_id')
  String get lotId;

  /// Price in INR per kg.
  @BuiltValueField(wireName: r'price_per_kg')
  String? get pricePerKg;

  /// Receiving processor.
  @BuiltValueField(wireName: r'processor_id')
  String get processorId;

  /// Quantity received in kg.
  @BuiltValueField(wireName: r'received')
  QuantityOutput get received;

  /// Strict chain harvested ≥ packed ≥ received at intake (FR60); the tolerant verdict is the `quantity_mismatch` flag.
  @BuiltValueField(wireName: r'reconciliation')
  Reconciliation? get reconciliation;

  /// Date of sale.
  @BuiltValueField(wireName: r'sale_date')
  Date get saleDate;

  /// Intake this row corrects, if any.
  @BuiltValueField(wireName: r'supersedes_intake_id')
  String? get supersedesIntakeId;

  IntakeOut._();

  factory IntakeOut([void updates(IntakeOutBuilder b)]) = _$IntakeOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IntakeOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IntakeOut> get serializer => _$IntakeOutSerializer();
}

class _$IntakeOutSerializer implements PrimitiveSerializer<IntakeOut> {
  @override
  final Iterable<Type> types = const [IntakeOut, _$IntakeOut];

  @override
  final String wireName = r'IntakeOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IntakeOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accepted_by_user_id';
    yield serializers.serialize(
      object.acceptedByUserId,
      specifiedType: const FullType(String),
    );
    if (object.correctionReason != null) {
      yield r'correction_reason';
      yield serializers.serialize(
        object.correctionReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.flags != null) {
      yield r'flags';
      yield serializers.serialize(
        object.flags,
        specifiedType: const FullType(BuiltList, [FullType(FlagBrief)]),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.intakeMoistureReadingId != null) {
      yield r'intake_moisture_reading_id';
      yield serializers.serialize(
        object.intakeMoistureReadingId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lot_id';
    yield serializers.serialize(
      object.lotId,
      specifiedType: const FullType(String),
    );
    if (object.pricePerKg != null) {
      yield r'price_per_kg';
      yield serializers.serialize(
        object.pricePerKg,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'processor_id';
    yield serializers.serialize(
      object.processorId,
      specifiedType: const FullType(String),
    );
    yield r'received';
    yield serializers.serialize(
      object.received,
      specifiedType: const FullType(QuantityOutput),
    );
    if (object.reconciliation != null) {
      yield r'reconciliation';
      yield serializers.serialize(
        object.reconciliation,
        specifiedType: const FullType.nullable(Reconciliation),
      );
    }
    yield r'sale_date';
    yield serializers.serialize(
      object.saleDate,
      specifiedType: const FullType(Date),
    );
    if (object.supersedesIntakeId != null) {
      yield r'supersedes_intake_id';
      yield serializers.serialize(
        object.supersedesIntakeId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IntakeOut object, {
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
    required IntakeOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accepted_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.acceptedByUserId = valueDes;
          break;
        case r'correction_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.correctionReason = valueDes;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'intake_moisture_reading_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.intakeMoistureReadingId = valueDes;
          break;
        case r'lot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lotId = valueDes;
          break;
        case r'price_per_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pricePerKg = valueDes;
          break;
        case r'processor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.processorId = valueDes;
          break;
        case r'received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.received.replace(valueDes);
          break;
        case r'reconciliation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Reconciliation),
          ) as Reconciliation?;
          if (valueDes == null) continue;
          result.reconciliation.replace(valueDes);
          break;
        case r'sale_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.saleDate = valueDes;
          break;
        case r'supersedes_intake_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supersedesIntakeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IntakeOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IntakeOutBuilder();
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
