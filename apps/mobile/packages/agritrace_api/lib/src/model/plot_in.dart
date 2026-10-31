//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/farming_type.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:agritrace_api/src/model/pin_method.dart';
import 'package:agritrace_api/src/model/polygon_geo_json.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:agritrace_api/src/model/irrigation_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plot_in.g.dart';

/// A plot captured at onboarding: live-GPS pin, declared size, optional walked boundary (FR64–FR66).
///
/// Properties:
/// * [clientId] - UUIDv7 generated on the device; primary key and idempotency key.
/// * [code] - Plot code shown to people; default `P-<n>` per farmer.
/// * [declaredArea] - Land size declared by the farmer; unit `acre` or `cent` (100 cents = 1 acre), FR65.
/// * [deviceTime] - Phone clock when the pin was taken.
/// * [farmerId] - Farmer who owns the plot (same FPO as the caller).
/// * [farmingType] - irrigated or rainfed (FR54).
/// * [giTagId] - GI tag of the crop picked at onboarding; null uses the only GI tag with a region, if exactly one exists (pilot), else the plot needs review.
/// * [gpsTime] - GPS fix time of the pin, if any.
/// * [irrigationSource] - Water source (FR54).
/// * [landRecordRef] - Survey number / patta / chitta reference; never public (FR65).
/// * [pin] - Pin from live GPS while standing on the plot, with its accuracy (FR64).
/// * [pinMethod] - live_gps, or map_pin (assisted fallback; always needs review).
/// * [soilType] - Soil type (field configuration, D-017).
/// * [walkedBoundary] - Boundary walked with GPS (FR66); never public.
@BuiltValue()
abstract class PlotIn implements Built<PlotIn, PlotInBuilder> {
  /// UUIDv7 generated on the device; primary key and idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Plot code shown to people; default `P-<n>` per farmer.
  @BuiltValueField(wireName: r'code')
  String? get code;

  /// Land size declared by the farmer; unit `acre` or `cent` (100 cents = 1 acre), FR65.
  @BuiltValueField(wireName: r'declared_area')
  QuantityInput get declaredArea;

  /// Phone clock when the pin was taken.
  @BuiltValueField(wireName: r'device_time')
  DateTime get deviceTime;

  /// Farmer who owns the plot (same FPO as the caller).
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// irrigated or rainfed (FR54).
  @BuiltValueField(wireName: r'farming_type')
  FarmingType? get farmingType;
  // enum farmingTypeEnum {  irrigated,  rainfed,  };

  /// GI tag of the crop picked at onboarding; null uses the only GI tag with a region, if exactly one exists (pilot), else the plot needs review.
  @BuiltValueField(wireName: r'gi_tag_id')
  String? get giTagId;

  /// GPS fix time of the pin, if any.
  @BuiltValueField(wireName: r'gps_time')
  DateTime? get gpsTime;

  /// Water source (FR54).
  @BuiltValueField(wireName: r'irrigation_source')
  IrrigationSource? get irrigationSource;
  // enum irrigationSourceEnum {  well,  borewell,  canal,  tank,  rain,  };

  /// Survey number / patta / chitta reference; never public (FR65).
  @BuiltValueField(wireName: r'land_record_ref')
  String? get landRecordRef;

  /// Pin from live GPS while standing on the plot, with its accuracy (FR64).
  @BuiltValueField(wireName: r'pin')
  GeoPoint get pin;

  /// live_gps, or map_pin (assisted fallback; always needs review).
  @BuiltValueField(wireName: r'pin_method')
  PinMethod? get pinMethod;
  // enum pinMethodEnum {  live_gps,  map_pin,  };

  /// Soil type (field configuration, D-017).
  @BuiltValueField(wireName: r'soil_type')
  String? get soilType;

  /// Boundary walked with GPS (FR66); never public.
  @BuiltValueField(wireName: r'walked_boundary')
  PolygonGeoJSON? get walkedBoundary;

  PlotIn._();

  factory PlotIn([void updates(PlotInBuilder b)]) = _$PlotIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlotInBuilder b) => b..pinMethod = PinMethod.liveGps;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlotIn> get serializer => _$PlotInSerializer();
}

class _$PlotInSerializer implements PrimitiveSerializer<PlotIn> {
  @override
  final Iterable<Type> types = const [PlotIn, _$PlotIn];

  @override
  final String wireName = r'PlotIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlotIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'declared_area';
    yield serializers.serialize(
      object.declaredArea,
      specifiedType: const FullType(QuantityInput),
    );
    yield r'device_time';
    yield serializers.serialize(
      object.deviceTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
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
    if (object.gpsTime != null) {
      yield r'gps_time';
      yield serializers.serialize(
        object.gpsTime,
        specifiedType: const FullType.nullable(DateTime),
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
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(GeoPoint),
    );
    if (object.pinMethod != null) {
      yield r'pin_method';
      yield serializers.serialize(
        object.pinMethod,
        specifiedType: const FullType(PinMethod),
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
    PlotIn object, {
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
    required PlotInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'declared_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(QuantityInput),
          ) as QuantityInput;
          result.declaredArea.replace(valueDes);
          break;
        case r'device_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.deviceTime = valueDes;
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
        case r'gi_tag_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giTagId = valueDes;
          break;
        case r'gps_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.gpsTime = valueDes;
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
            specifiedType: const FullType(GeoPoint),
          ) as GeoPoint;
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
  PlotIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlotInBuilder();
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
