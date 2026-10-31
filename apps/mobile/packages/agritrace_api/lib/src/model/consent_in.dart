//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/consent_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'consent_in.g.dart';

/// Record a farmer's consent; resending the same `client_id` returns the stored record (D-005).
///
/// Properties:
/// * [clientId] - UUIDv7 generated on the device; resending it is a no-op.
/// * [consentType] - What is consented to.
/// * [consentVersion] - Version of the consent text played, e.g. `v1-ta`.
/// * [farmerId] - Farmer who consents (the caller, or the assisted farmer).
/// * [givenAt] - When the farmer agreed (device clock), ISO 8601.
/// * [recordingRef] - Object key of the consent recording played or captured, if any.
@BuiltValue()
abstract class ConsentIn implements Built<ConsentIn, ConsentInBuilder> {
  /// UUIDv7 generated on the device; resending it is a no-op.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// What is consented to.
  @BuiltValueField(wireName: r'consent_type')
  ConsentType get consentType;
  // enum consentTypeEnum {  data_collection,  public_name,  partner_share,  };

  /// Version of the consent text played, e.g. `v1-ta`.
  @BuiltValueField(wireName: r'consent_version')
  String get consentVersion;

  /// Farmer who consents (the caller, or the assisted farmer).
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// When the farmer agreed (device clock), ISO 8601.
  @BuiltValueField(wireName: r'given_at')
  DateTime get givenAt;

  /// Object key of the consent recording played or captured, if any.
  @BuiltValueField(wireName: r'recording_ref')
  String? get recordingRef;

  ConsentIn._();

  factory ConsentIn([void updates(ConsentInBuilder b)]) = _$ConsentIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConsentInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConsentIn> get serializer => _$ConsentInSerializer();
}

class _$ConsentInSerializer implements PrimitiveSerializer<ConsentIn> {
  @override
  final Iterable<Type> types = const [ConsentIn, _$ConsentIn];

  @override
  final String wireName = r'ConsentIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConsentIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'consent_type';
    yield serializers.serialize(
      object.consentType,
      specifiedType: const FullType(ConsentType),
    );
    yield r'consent_version';
    yield serializers.serialize(
      object.consentVersion,
      specifiedType: const FullType(String),
    );
    yield r'farmer_id';
    yield serializers.serialize(
      object.farmerId,
      specifiedType: const FullType(String),
    );
    yield r'given_at';
    yield serializers.serialize(
      object.givenAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.recordingRef != null) {
      yield r'recording_ref';
      yield serializers.serialize(
        object.recordingRef,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConsentIn object, {
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
    required ConsentInBuilder result,
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
        case r'consent_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConsentType),
          ) as ConsentType;
          result.consentType = valueDes;
          break;
        case r'consent_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.consentVersion = valueDes;
          break;
        case r'farmer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.farmerId = valueDes;
          break;
        case r'given_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.givenAt = valueDes;
          break;
        case r'recording_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recordingRef = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConsentIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConsentInBuilder();
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
