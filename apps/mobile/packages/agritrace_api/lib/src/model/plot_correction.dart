//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/farming_type.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/pin_method.dart';
import 'package:agritrace_api/src/model/polygon_geo_json.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:agritrace_api/src/model/irrigation_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plot_correction.g.dart';

/// An FPO admin's correction of an onboarded plot; only the fields sent change (FR70, FR71).
///
/// Properties:
/// * [declaredArea] - Corrected declared size (`acre` or `cent`).
/// * [farmingType] - Corrected farming type.
/// * [giTagId] - GI tag to re-check against (see PlotIn).
/// * [irrigationSource] - Corrected irrigation source.
/// * [landRecordRef] - Corrected land-record reference.
/// * [pin] - Corrected pin.
/// * [pinMethod] - How the corrected pin was placed.
/// * [reasonCode] - Coded reason, e.g. `gps_drift`, `wrong_plot`, `land_record_checked`; required (422 `reason_required` when missing).
/// * [reasonText] - Free-text explanation.
/// * [reviewMethod] - How a flagged location was reviewed (FR70); send with `review_outcome`.
/// * [reviewOutcome] - Review result (FR70): `accepted` lets the region check decide the status (also for a map pin); `rejected` keeps the plot `needs_review`. Put the reviewer's note in `reason_text`.
/// * [soilType] - Corrected soil type.
/// * [walkedBoundary] - Corrected walked boundary.
@BuiltValue()
abstract class PlotCorrection
    implements Built<PlotCorrection, PlotCorrectionBuilder> {
  /// Corrected declared size (`acre` or `cent`).
  @BuiltValueField(wireName: r'declared_area')
  QuantityInput? get declaredArea;

  /// Corrected farming type.
  @BuiltValueField(wireName: r'farming_type')
  FarmingType? get farmingType;
  // enum farmingTypeEnum {  irrigated,  rainfed,  };

  /// GI tag to re-check against (see PlotIn).
  @BuiltValueField(wireName: r'gi_tag_id')
  String? get giTagId;

  /// Corrected irrigation source.
  @BuiltValueField(wireName: r'irrigation_source')
  IrrigationSource? get irrigationSource;
  // enum irrigationSourceEnum {  well,  borewell,  canal,  tank,  rain,  };

  /// Corrected land-record reference.
  @BuiltValueField(wireName: r'land_record_ref')
  String? get landRecordRef;

  /// Corrected pin.
  @BuiltValueField(wireName: r'pin')
  GeoPoint? get pin;

  /// How the corrected pin was placed.
  @BuiltValueField(wireName: r'pin_method')
  PinMethod? get pinMethod;
  // enum pinMethodEnum {  live_gps,  map_pin,  };

  /// Coded reason, e.g. `gps_drift`, `wrong_plot`, `land_record_checked`; required (422 `reason_required` when missing).
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// Free-text explanation.
  @BuiltValueField(wireName: r'reason_text')
  String? get reasonText;

  /// How a flagged location was reviewed (FR70); send with `review_outcome`.
  @BuiltValueField(wireName: r'review_method')
  PlotCorrectionReviewMethodEnum? get reviewMethod;
  // enum reviewMethodEnum {  land_record,  satellite,  field_visit,  };

  /// Review result (FR70): `accepted` lets the region check decide the status (also for a map pin); `rejected` keeps the plot `needs_review`. Put the reviewer's note in `reason_text`.
  @BuiltValueField(wireName: r'review_outcome')
  PlotCorrectionReviewOutcomeEnum? get reviewOutcome;
  // enum reviewOutcomeEnum {  accepted,  rejected,  };

  /// Corrected soil type.
  @BuiltValueField(wireName: r'soil_type')
  String? get soilType;

  /// Corrected walked boundary.
  @BuiltValueField(wireName: r'walked_boundary')
  PolygonGeoJSON? get walkedBoundary;

  PlotCorrection._();

  factory PlotCorrection([void updates(PlotCorrectionBuilder b)]) =
      _$PlotCorrection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlotCorrectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlotCorrection> get serializer =>
      _$PlotCorrectionSerializer();
}

class _$PlotCorrectionSerializer
    implements PrimitiveSerializer<PlotCorrection> {
  @override
  final Iterable<Type> types = const [PlotCorrection, _$PlotCorrection];

  @override
  final String wireName = r'PlotCorrection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlotCorrection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.declaredArea != null) {
      yield r'declared_area';
      yield serializers.serialize(
        object.declaredArea,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
    if (object.farmingType != null) {
      yield r'farming_type';
      yield serializers.serialize(
        object.farmingType,
        specifiedType: const FullType.nullable(FarmingType),
      );
    }
    if (object.giTagId != null) {
      yield r'gi_tag_id';
      yield serializers.serialize(
        object.giTagId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.irrigationSource != null) {
      yield r'irrigation_source';
      yield serializers.serialize(
        object.irrigationSource,
        specifiedType: const FullType.nullable(IrrigationSource),
      );
    }
    if (object.landRecordRef != null) {
      yield r'land_record_ref';
      yield serializers.serialize(
        object.landRecordRef,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType.nullable(GeoPoint),
      );
    }
    if (object.pinMethod != null) {
      yield r'pin_method';
      yield serializers.serialize(
        object.pinMethod,
        specifiedType: const FullType.nullable(PinMethod),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonText != null) {
      yield r'reason_text';
      yield serializers.serialize(
        object.reasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reviewMethod != null) {
      yield r'review_method';
      yield serializers.serialize(
        object.reviewMethod,
        specifiedType: const FullType.nullable(PlotCorrectionReviewMethodEnum),
      );
    }
    if (object.reviewOutcome != null) {
      yield r'review_outcome';
      yield serializers.serialize(
        object.reviewOutcome,
        specifiedType: const FullType.nullable(PlotCorrectionReviewOutcomeEnum),
      );
    }
    if (object.soilType != null) {
      yield r'soil_type';
      yield serializers.serialize(
        object.soilType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.walkedBoundary != null) {
      yield r'walked_boundary';
      yield serializers.serialize(
        object.walkedBoundary,
        specifiedType: const FullType.nullable(PolygonGeoJSON),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlotCorrection object, {
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
    required PlotCorrectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.declaredArea.replace(valueDes);
          break;
        case r'farming_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FarmingType),
          ) as FarmingType?;
          if (valueDes == null) continue;
          result.farmingType = valueDes;
          break;
        case r'gi_tag_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giTagId = valueDes;
          break;
        case r'irrigation_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IrrigationSource),
          ) as IrrigationSource?;
          if (valueDes == null) continue;
          result.irrigationSource = valueDes;
          break;
        case r'land_record_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.landRecordRef = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GeoPoint),
          ) as GeoPoint?;
          if (valueDes == null) continue;
          result.pin.replace(valueDes);
          break;
        case r'pin_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PinMethod),
          ) as PinMethod?;
          if (valueDes == null) continue;
          result.pinMethod = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonText = valueDes;
          break;
        case r'review_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(PlotCorrectionReviewMethodEnum),
          ) as PlotCorrectionReviewMethodEnum?;
          if (valueDes == null) continue;
          result.reviewMethod = valueDes;
          break;
        case r'review_outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(PlotCorrectionReviewOutcomeEnum),
          ) as PlotCorrectionReviewOutcomeEnum?;
          if (valueDes == null) continue;
          result.reviewOutcome = valueDes;
          break;
        case r'soil_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.soilType = valueDes;
          break;
        case r'walked_boundary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PolygonGeoJSON),
          ) as PolygonGeoJSON?;
          if (valueDes == null) continue;
          result.walkedBoundary.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlotCorrection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlotCorrectionBuilder();
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

/// How a flagged location was reviewed (FR70); send with `review_outcome`.
class PlotCorrectionReviewMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'land_record')
  static const PlotCorrectionReviewMethodEnum landRecord =
      _$plotCorrectionReviewMethodEnum_landRecord;
  @BuiltValueEnumConst(wireName: r'satellite')
  static const PlotCorrectionReviewMethodEnum satellite =
      _$plotCorrectionReviewMethodEnum_satellite;
  @BuiltValueEnumConst(wireName: r'field_visit')
  static const PlotCorrectionReviewMethodEnum fieldVisit =
      _$plotCorrectionReviewMethodEnum_fieldVisit;

  static Serializer<PlotCorrectionReviewMethodEnum> get serializer =>
      _$plotCorrectionReviewMethodEnumSerializer;

  const PlotCorrectionReviewMethodEnum._(String name) : super(name);

  static BuiltSet<PlotCorrectionReviewMethodEnum> get values =>
      _$plotCorrectionReviewMethodEnumValues;
  static PlotCorrectionReviewMethodEnum valueOf(String name) =>
      _$plotCorrectionReviewMethodEnumValueOf(name);
}

/// Review result (FR70): `accepted` lets the region check decide the status (also for a map pin); `rejected` keeps the plot `needs_review`. Put the reviewer's note in `reason_text`.
class PlotCorrectionReviewOutcomeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const PlotCorrectionReviewOutcomeEnum accepted =
      _$plotCorrectionReviewOutcomeEnum_accepted;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const PlotCorrectionReviewOutcomeEnum rejected =
      _$plotCorrectionReviewOutcomeEnum_rejected;

  static Serializer<PlotCorrectionReviewOutcomeEnum> get serializer =>
      _$plotCorrectionReviewOutcomeEnumSerializer;

  const PlotCorrectionReviewOutcomeEnum._(String name) : super(name);

  static BuiltSet<PlotCorrectionReviewOutcomeEnum> get values =>
      _$plotCorrectionReviewOutcomeEnumValues;
  static PlotCorrectionReviewOutcomeEnum valueOf(String name) =>
      _$plotCorrectionReviewOutcomeEnumValueOf(name);
}
