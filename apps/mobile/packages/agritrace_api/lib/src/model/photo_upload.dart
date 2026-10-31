//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photo_upload.g.dart';

/// How to upload one photo: a single presigned PUT (D-011).
///
/// Properties:
/// * [expiresAt] - When the URL stops working (15 minutes).
/// * [headers] - Headers to send exactly: `Content-Type` and `x-amz-checksum-sha256` (base64).
/// * [method] - HTTP method to use.
/// * [photoClientId] - The photo's client id.
/// * [url] - Presigned URL on the public storage endpoint.
@BuiltValue()
abstract class PhotoUpload implements Built<PhotoUpload, PhotoUploadBuilder> {
  /// When the URL stops working (15 minutes).
  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  /// Headers to send exactly: `Content-Type` and `x-amz-checksum-sha256` (base64).
  @BuiltValueField(wireName: r'headers')
  BuiltMap<String, String> get headers;

  /// HTTP method to use.
  @BuiltValueField(wireName: r'method')
  PhotoUploadMethodEnum? get method;
  // enum methodEnum {  PUT,  };

  /// The photo's client id.
  @BuiltValueField(wireName: r'photo_client_id')
  String get photoClientId;

  /// Presigned URL on the public storage endpoint.
  @BuiltValueField(wireName: r'url')
  String get url;

  PhotoUpload._();

  factory PhotoUpload([void updates(PhotoUploadBuilder b)]) = _$PhotoUpload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhotoUploadBuilder b) =>
      b..method = PhotoUploadMethodEnum.valueOf('PUT');

  @BuiltValueSerializer(custom: true)
  static Serializer<PhotoUpload> get serializer => _$PhotoUploadSerializer();
}

class _$PhotoUploadSerializer implements PrimitiveSerializer<PhotoUpload> {
  @override
  final Iterable<Type> types = const [PhotoUpload, _$PhotoUpload];

  @override
  final String wireName = r'PhotoUpload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhotoUpload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'headers';
    yield serializers.serialize(
      object.headers,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    if (object.method != null) {
      yield r'method';
      yield serializers.serialize(
        object.method,
        specifiedType: const FullType(PhotoUploadMethodEnum),
      );
    }
    yield r'photo_client_id';
    yield serializers.serialize(
      object.photoClientId,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhotoUpload object, {
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
    required PhotoUploadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'headers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.headers.replace(valueDes);
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PhotoUploadMethodEnum),
          ) as PhotoUploadMethodEnum?;
          if (valueDes == null) continue;
          result.method = valueDes;
          break;
        case r'photo_client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.photoClientId = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhotoUpload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhotoUploadBuilder();
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

/// HTTP method to use.
class PhotoUploadMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'PUT')
  static const PhotoUploadMethodEnum PUT = _$photoUploadMethodEnum_PUT;

  static Serializer<PhotoUploadMethodEnum> get serializer =>
      _$photoUploadMethodEnumSerializer;

  const PhotoUploadMethodEnum._(String name) : super(name);

  static BuiltSet<PhotoUploadMethodEnum> get values =>
      _$photoUploadMethodEnumValues;
  static PhotoUploadMethodEnum valueOf(String name) =>
      _$photoUploadMethodEnumValueOf(name);
}
