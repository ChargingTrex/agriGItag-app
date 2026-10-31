//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/location_status.dart';
import 'package:agritrace_api/src/model/farming_type.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/pin_method.dart';
import 'package:agritrace_api/src/model/region_check_out.dart';
import 'package:agritrace_api/src/model/irrigation_source.dart';
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plot_out.g.dart';

/// A plot as returned by the API. The walked outline itself is not returned (internal only).
///
/// Properties:
/// * [areaGapExceeds] - True when |area_gap_pct| > 20 %: walked area far from declared size (FR66, FR70).
/// * [areaGapPct] - Walked minus declared, as % of declared; null when no boundary was walked.
/// * [code] - Plot code shown to people.
/// * [declaredArea] - Declared size (unit `acre`).
/// * [farmerId] - Owner.
/// * [farmingType] - irrigated or rainfed.
/// * [fpoId] - Owning FPO.
/// * [giTagId] - GI tag stored at onboarding or correction; null when none was sent (fallback).
/// * [id] - Plot id (client-generated, D-005).
/// * [irrigationSource] - Water source.
/// * [landRecordRef] - Land-record reference (internal only).
/// * [locationMethodLabel] - How the location was set, for the public page: `Live GPS pin`, `Boundary walked` or `Map pin` (FR72).
/// * [locationStatus] - confirmed, near_edge, outside, or needs_review (map pin or no region to check).
/// * [pin] - Plot pin (WGS84) with its GPS accuracy.
/// * [pinDeviceTime] - Phone clock when the pin was taken.
/// * [pinGpsTime] - GPS fix time of the pin.
/// * [pinMethod] - live_gps or map_pin.
/// * [pinServerReceivedAt] - When the server received the pin.
/// * [regionCheck] - Region check run by this request (create or correct); null on reads.
/// * [reviewMethod] - land_record, satellite or field_visit.
/// * [reviewOutcome] - accepted or rejected (FR70); null when not reviewed.
/// * [reviewedAt] - When a flagged location was reviewed (FR70).
/// * [revisionNo] - Current revision; bumps on every admin correction.
/// * [soilType] - Soil type.
/// * [walkedArea] - Area of the walked boundary (unit `acre`), if walked.
@BuiltValue()
abstract class PlotOut implements Built<PlotOut, PlotOutBuilder> {
  /// True when |area_gap_pct| > 20 %: walked area far from declared size (FR66, FR70).
  @BuiltValueField(wireName: r'area_gap_exceeds')
  bool get areaGapExceeds;

  /// Walked minus declared, as % of declared; null when no boundary was walked.
  @BuiltValueField(wireName: r'area_gap_pct')
  String? get areaGapPct;

  /// Plot code shown to people.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Declared size (unit `acre`).
  @BuiltValueField(wireName: r'declared_area')
  QuantityOutput get declaredArea;

  /// Owner.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// irrigated or rainfed.
  @BuiltValueField(wireName: r'farming_type')
  FarmingType? get farmingType;
  // enum farmingTypeEnum {  irrigated,  rainfed,  };

  /// Owning FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// GI tag stored at onboarding or correction; null when none was sent (fallback).
  @BuiltValueField(wireName: r'gi_tag_id')
  String? get giTagId;

  /// Plot id (client-generated, D-005).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Water source.
  @BuiltValueField(wireName: r'irrigation_source')
  IrrigationSource? get irrigationSource;
  // enum irrigationSourceEnum {  well,  borewell,  canal,  tank,  rain,  };

  /// Land-record reference (internal only).
  @BuiltValueField(wireName: r'land_record_ref')
  String? get landRecordRef;

  /// How the location was set, for the public page: `Live GPS pin`, `Boundary walked` or `Map pin` (FR72).
  @BuiltValueField(wireName: r'location_method_label')
  String? get locationMethodLabel;

  /// confirmed, near_edge, outside, or needs_review (map pin or no region to check).
  @BuiltValueField(wireName: r'location_status')
  LocationStatus get locationStatus;
  // enum locationStatusEnum {  confirmed,  needs_review,  outside,  near_edge,  };

  /// Plot pin (WGS84) with its GPS accuracy.
  @BuiltValueField(wireName: r'pin')
  GeoPoint get pin;

  /// Phone clock when the pin was taken.
  @BuiltValueField(wireName: r'pin_device_time')
  DateTime get pinDeviceTime;

  /// GPS fix time of the pin.
  @BuiltValueField(wireName: r'pin_gps_time')
  DateTime? get pinGpsTime;

  /// live_gps or map_pin.
  @BuiltValueField(wireName: r'pin_method')
  PinMethod get pinMethod;
  // enum pinMethodEnum {  live_gps,  map_pin,  };

  /// When the server received the pin.
  @BuiltValueField(wireName: r'pin_server_received_at')
  DateTime get pinServerReceivedAt;

  /// Region check run by this request (create or correct); null on reads.
  @BuiltValueField(wireName: r'region_check')
  RegionCheckOut? get regionCheck;

  /// land_record, satellite or field_visit.
  @BuiltValueField(wireName: r'review_method')
  String? get reviewMethod;

  /// accepted or rejected (FR70); null when not reviewed.
  @BuiltValueField(wireName: r'review_outcome')
  String? get reviewOutcome;

  /// When a flagged location was reviewed (FR70).
  @BuiltValueField(wireName: r'reviewed_at')
  DateTime? get reviewedAt;

  /// Current revision; bumps on every admin correction.
  @BuiltValueField(wireName: r'revision_no')
  int get revisionNo;

  /// Soil type.
  @BuiltValueField(wireName: r'soil_type')
  String? get soilType;

  /// Area of the walked boundary (unit `acre`), if walked.
  @BuiltValueField(wireName: r'walked_area')
  QuantityOutput? get walkedArea;

  PlotOut._();

  factory PlotOut([void updates(PlotOutBuilder b)]) = _$PlotOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlotOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlotOut> get serializer => _$PlotOutSerializer();
}

class _$PlotOutSerializer implements PrimitiveSerializer<PlotOut> {
  @override
  final Iterable<Type> types = const [PlotOut, _$PlotOut];

  @override
  final String wireName = r'PlotOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlotOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'area_gap_exceeds';
    yield serializers.serialize(
      object.areaGapExceeds,
      specifiedType: const FullType(bool),
    );
    yield r'area_gap_pct';
    yield object.areaGapPct == null
        ? null
        : serializers.serialize(
            object.areaGapPct,
            specifiedType: const FullType.nullable(String),
          );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'declared_area';
    yield serializers.serialize(
      object.declaredArea,
      specifiedType: const FullType(QuantityOutput),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'farming_type';
    yield object.farmingType == null
        ? null
        : serializers.serialize(
            object.farmingType,
            specifiedType: const FullType.nullable(FarmingType),
          );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    if (object.giTagId != null) {
      yield r'gi_tag_id';
      yield serializers.serialize(
        object.giTagId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'irrigation_source';
    yield object.irrigationSource == null
        ? null
        : serializers.serialize(
            object.irrigationSource,
            specifiedType: const FullType.nullable(IrrigationSource),
          );
    yield r'land_record_ref';
    yield object.landRecordRef == null
        ? null
        : serializers.serialize(
            object.landRecordRef,
            specifiedType: const FullType.nullable(String),
          );
    yield r'location_method_label';
    yield object.locationMethodLabel == null
        ? null
        : serializers.serialize(
            object.locationMethodLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'location_status';
    yield serializers.serialize(
      object.locationStatus,
      specifiedType: const FullType(LocationStatus),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(GeoPoint),
    );
    yield r'pin_device_time';
    yield serializers.serialize(
      object.pinDeviceTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'pin_gps_time';
    yield object.pinGpsTime == null
        ? null
        : serializers.serialize(
            object.pinGpsTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'pin_method';
    yield serializers.serialize(
      object.pinMethod,
      specifiedType: const FullType(PinMethod),
    );
    yield r'pin_server_received_at';
    yield serializers.serialize(
      object.pinServerReceivedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.regionCheck != null) {
      yield r'region_check';
      yield serializers.serialize(
        object.regionCheck,
        specifiedType: const FullType.nullable(RegionCheckOut),
      );
    }
    yield r'review_method';
    yield object.reviewMethod == null
        ? null
        : serializers.serialize(
            object.reviewMethod,
            specifiedType: const FullType.nullable(String),
          );
    yield r'review_outcome';
    yield object.reviewOutcome == null
        ? null
        : serializers.serialize(
            object.reviewOutcome,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reviewed_at';
    yield object.reviewedAt == null
        ? null
        : serializers.serialize(
            object.reviewedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'revision_no';
    yield serializers.serialize(
      object.revisionNo,
      specifiedType: const FullType(int),
    );
    yield r'soil_type';
    yield object.soilType == null
        ? null
        : serializers.serialize(
            object.soilType,
            specifiedType: const FullType.nullable(String),
          );
    yield r'walked_area';
    yield object.walkedArea == null
        ? null
        : serializers.serialize(
            object.walkedArea,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlotOut object, {
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
    required PlotOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'area_gap_exceeds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.areaGapExceeds = valueDes;
          break;
        case r'area_gap_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaGapPct = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityOutput),
          ) as QuantityOutput;
          result.declaredArea.replace(valueDes);
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'farming_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FarmingType),
          ) as FarmingType?;
          if (valueDes == null) continue;
          result.farmingType = valueDes;
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'gi_tag_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giTagId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
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
        case r'location_method_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locationMethodLabel = valueDes;
          break;
        case r'location_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LocationStatus),
          ) as LocationStatus;
          result.locationStatus = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoPoint),
          ) as GeoPoint;
          result.pin.replace(valueDes);
          break;
        case r'pin_device_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.pinDeviceTime = valueDes;
          break;
        case r'pin_gps_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.pinGpsTime = valueDes;
          break;
        case r'pin_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PinMethod),
          ) as PinMethod;
          result.pinMethod = valueDes;
          break;
        case r'pin_server_received_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.pinServerReceivedAt = valueDes;
          break;
        case r'region_check':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RegionCheckOut),
          ) as RegionCheckOut?;
          if (valueDes == null) continue;
          result.regionCheck.replace(valueDes);
          break;
        case r'review_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewMethod = valueDes;
          break;
        case r'review_outcome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewOutcome = valueDes;
          break;
        case r'reviewed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.reviewedAt = valueDes;
          break;
        case r'revision_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revisionNo = valueDes;
          break;
        case r'soil_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.soilType = valueDes;
          break;
        case r'walked_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.walkedArea.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlotOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlotOutBuilder();
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
