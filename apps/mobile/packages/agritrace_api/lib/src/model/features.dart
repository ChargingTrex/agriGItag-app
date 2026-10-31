//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'features.g.dart';

/// Feature flags and limits (`features.yaml`, tenant overrides applied). Readers named in the YAML.
///
/// Properties:
/// * [boundaryWalk] - Onboarding offers the boundary walk step.
/// * [farmerPinLogin] - Farmers may sign in with a PIN (not wired on the server).
/// * [gradingLossWarnPct] - Batch output more than this % below its received kg warns (D-030).
/// * [idDocumentCapture] - ID document upload endpoint on (consent-gated).
/// * [otpDailyCap] - Most OTP codes per phone per 24 hours (informative).
/// * [producerGroups] - Producer group (SHG) endpoints on.
/// * [secondSignoffThresholdKg] - Batches above this weight need 2 sign-offs.
/// * [syncPushMaxBytes] - Largest sync push body, in bytes.
/// * [syncPushMaxEntries] - Most entries in one sync push.
/// * [wifiOnlyPhotosDefault] - Phones upload photos on Wi-Fi only by default.
@BuiltValue()
abstract class Features implements Built<Features, FeaturesBuilder> {
  /// Onboarding offers the boundary walk step.
  @BuiltValueField(wireName: r'boundary_walk')
  bool get boundaryWalk;

  /// Farmers may sign in with a PIN (not wired on the server).
  @BuiltValueField(wireName: r'farmer_pin_login')
  bool get farmerPinLogin;

  /// Batch output more than this % below its received kg warns (D-030).
  @BuiltValueField(wireName: r'grading_loss_warn_pct')
  int get gradingLossWarnPct;

  /// ID document upload endpoint on (consent-gated).
  @BuiltValueField(wireName: r'id_document_capture')
  bool get idDocumentCapture;

  /// Most OTP codes per phone per 24 hours (informative).
  @BuiltValueField(wireName: r'otp_daily_cap')
  int get otpDailyCap;

  /// Producer group (SHG) endpoints on.
  @BuiltValueField(wireName: r'producer_groups')
  bool get producerGroups;

  /// Batches above this weight need 2 sign-offs.
  @BuiltValueField(wireName: r'second_signoff_threshold_kg')
  int get secondSignoffThresholdKg;

  /// Largest sync push body, in bytes.
  @BuiltValueField(wireName: r'sync_push_max_bytes')
  int get syncPushMaxBytes;

  /// Most entries in one sync push.
  @BuiltValueField(wireName: r'sync_push_max_entries')
  int get syncPushMaxEntries;

  /// Phones upload photos on Wi-Fi only by default.
  @BuiltValueField(wireName: r'wifi_only_photos_default')
  bool get wifiOnlyPhotosDefault;

  Features._();

  factory Features([void updates(FeaturesBuilder b)]) = _$Features;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FeaturesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Features> get serializer => _$FeaturesSerializer();
}

class _$FeaturesSerializer implements PrimitiveSerializer<Features> {
  @override
  final Iterable<Type> types = const [Features, _$Features];

  @override
  final String wireName = r'Features';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Features object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'boundary_walk';
    yield serializers.serialize(
      object.boundaryWalk,
      specifiedType: const FullType(bool),
    );
    yield r'farmer_pin_login';
    yield serializers.serialize(
      object.farmerPinLogin,
      specifiedType: const FullType(bool),
    );
    yield r'grading_loss_warn_pct';
    yield serializers.serialize(
      object.gradingLossWarnPct,
      specifiedType: const FullType(int),
    );
    yield r'id_document_capture';
    yield serializers.serialize(
      object.idDocumentCapture,
      specifiedType: const FullType(bool),
    );
    yield r'otp_daily_cap';
    yield serializers.serialize(
      object.otpDailyCap,
      specifiedType: const FullType(int),
    );
    yield r'producer_groups';
    yield serializers.serialize(
      object.producerGroups,
      specifiedType: const FullType(bool),
    );
    yield r'second_signoff_threshold_kg';
    yield serializers.serialize(
      object.secondSignoffThresholdKg,
      specifiedType: const FullType(int),
    );
    yield r'sync_push_max_bytes';
    yield serializers.serialize(
      object.syncPushMaxBytes,
      specifiedType: const FullType(int),
    );
    yield r'sync_push_max_entries';
    yield serializers.serialize(
      object.syncPushMaxEntries,
      specifiedType: const FullType(int),
    );
    yield r'wifi_only_photos_default';
    yield serializers.serialize(
      object.wifiOnlyPhotosDefault,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Features object, {
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
    required FeaturesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'boundary_walk':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.boundaryWalk = valueDes;
          break;
        case r'farmer_pin_login':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.farmerPinLogin = valueDes;
          break;
        case r'grading_loss_warn_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.gradingLossWarnPct = valueDes;
          break;
        case r'id_document_capture':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.idDocumentCapture = valueDes;
          break;
        case r'otp_daily_cap':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.otpDailyCap = valueDes;
          break;
        case r'producer_groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.producerGroups = valueDes;
          break;
        case r'second_signoff_threshold_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.secondSignoffThresholdKg = valueDes;
          break;
        case r'sync_push_max_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.syncPushMaxBytes = valueDes;
          break;
        case r'sync_push_max_entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.syncPushMaxEntries = valueDes;
          break;
        case r'wifi_only_photos_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.wifiOnlyPhotosDefault = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Features deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FeaturesBuilder();
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
