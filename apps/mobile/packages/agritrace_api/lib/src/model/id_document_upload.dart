//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'id_document_upload.g.dart';

/// Where to PUT the ID document image; the URL accepts only bytes matching `sha256`.
///
/// Properties:
/// * [expiresAt] - When the URL stops working.
/// * [headers] - Headers to send: `Content-Type` and `x-amz-checksum-sha256` (base64 digest).
/// * [id] - ID document id.
/// * [method] - Always PUT.
/// * [url] - Presigned URL into the private id-docs bucket (15 minutes).
@BuiltValue()
abstract class IdDocumentUpload
    implements Built<IdDocumentUpload, IdDocumentUploadBuilder> {
  /// When the URL stops working.
  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  /// Headers to send: `Content-Type` and `x-amz-checksum-sha256` (base64 digest).
  @BuiltValueField(wireName: r'headers')
  BuiltMap<String, String> get headers;

  /// ID document id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Always PUT.
  @BuiltValueField(wireName: r'method')
  IdDocumentUploadMethodEnum get method;
  // enum methodEnum {  PUT,  };

  /// Presigned URL into the private id-docs bucket (15 minutes).
  @BuiltValueField(wireName: r'url')
  String get url;

  IdDocumentUpload._();

  factory IdDocumentUpload([void updates(IdDocumentUploadBuilder b)]) =
      _$IdDocumentUpload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdDocumentUploadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IdDocumentUpload> get serializer =>
      _$IdDocumentUploadSerializer();
}

class _$IdDocumentUploadSerializer
    implements PrimitiveSerializer<IdDocumentUpload> {
  @override
  final Iterable<Type> types = const [IdDocumentUpload, _$IdDocumentUpload];

  @override
  final String wireName = r'IdDocumentUpload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IdDocumentUpload object, {
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
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(IdDocumentUploadMethodEnum),
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
    IdDocumentUpload object, {
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
    required IdDocumentUploadBuilder result,
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IdDocumentUploadMethodEnum),
          ) as IdDocumentUploadMethodEnum;
          result.method = valueDes;
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
  IdDocumentUpload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdDocumentUploadBuilder();
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

/// Always PUT.
class IdDocumentUploadMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'PUT')
  static const IdDocumentUploadMethodEnum PUT =
      _$idDocumentUploadMethodEnum_PUT;

  static Serializer<IdDocumentUploadMethodEnum> get serializer =>
      _$idDocumentUploadMethodEnumSerializer;

  const IdDocumentUploadMethodEnum._(String name) : super(name);

  static BuiltSet<IdDocumentUploadMethodEnum> get values =>
      _$idDocumentUploadMethodEnumValues;
  static IdDocumentUploadMethodEnum valueOf(String name) =>
      _$idDocumentUploadMethodEnumValueOf(name);
}
