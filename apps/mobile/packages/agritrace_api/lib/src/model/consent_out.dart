//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/consent_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'consent_out.g.dart';

/// A stored consent record.
///
/// Properties:
/// * [consentType] - What was consented to.
/// * [consentVersion] - Version of the consent text.
/// * [farmerId] - Farmer who consented.
/// * [givenAt] - When consent was given.
/// * [id] - Consent id (the client id it was recorded with).
/// * [recordingRef] - Object key of the recording, if any.
/// * [revokedAt] - When it was withdrawn; null while in force.
/// * [witnessedByUserId] - Officer who witnessed it (assist mode).
@BuiltValue()
abstract class ConsentOut implements Built<ConsentOut, ConsentOutBuilder> {
  /// What was consented to.
  @BuiltValueField(wireName: r'consent_type')
  ConsentType get consentType;
  // enum consentTypeEnum {  data_collection,  public_name,  partner_share,  };

  /// Version of the consent text.
  @BuiltValueField(wireName: r'consent_version')
  String get consentVersion;

  /// Farmer who consented.
  @BuiltValueField(wireName: r'farmer_id')
  String get farmerId;

  /// When consent was given.
  @BuiltValueField(wireName: r'given_at')
  DateTime get givenAt;

  /// Consent id (the client id it was recorded with).
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Object key of the recording, if any.
  @BuiltValueField(wireName: r'recording_ref')
  String? get recordingRef;

  /// When it was withdrawn; null while in force.
  @BuiltValueField(wireName: r'revoked_at')
  DateTime? get revokedAt;

  /// Officer who witnessed it (assist mode).
  @BuiltValueField(wireName: r'witnessed_by_user_id')
  String? get witnessedByUserId;

  ConsentOut._();

  factory ConsentOut([void updates(ConsentOutBuilder b)]) = _$ConsentOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConsentOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConsentOut> get serializer => _$ConsentOutSerializer();
}

class _$ConsentOutSerializer implements PrimitiveSerializer<ConsentOut> {
  @override
  final Iterable<Type> types = const [ConsentOut, _$ConsentOut];

  @override
  final String wireName = r'ConsentOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConsentOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'recording_ref';
    yield object.recordingRef == null
        ? null
        : serializers.serialize(
            object.recordingRef,
            specifiedType: const FullType.nullable(String),
          );
    yield r'revoked_at';
    yield object.revokedAt == null
        ? null
        : serializers.serialize(
            object.revokedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'witnessed_by_user_id';
    yield object.witnessedByUserId == null
        ? null
        : serializers.serialize(
            object.witnessedByUserId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConsentOut object, {
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
    required ConsentOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'recording_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recordingRef = valueDes;
          break;
        case r'revoked_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.revokedAt = valueDes;
          break;
        case r'witnessed_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.witnessedByUserId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConsentOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConsentOutBuilder();
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
