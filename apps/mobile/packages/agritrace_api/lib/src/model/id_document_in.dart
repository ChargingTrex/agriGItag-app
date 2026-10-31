//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'id_document_in.g.dart';

/// Request to upload one identity document image (flag `id_document_capture`, consent-gated).
///
/// Properties:
/// * [consentRecordId] - The farmer's unrevoked `data_collection` consent under which it is captured.
/// * [contentType] - MIME type of the image to upload.
/// * [docType] - Document type code, e.g. `aadhaar`.
/// * [sha256] - Hex SHA-256 of the image (device).
@BuiltValue()
abstract class IdDocumentIn
    implements Built<IdDocumentIn, IdDocumentInBuilder> {
  /// The farmer's unrevoked `data_collection` consent under which it is captured.
  @BuiltValueField(wireName: r'consent_record_id')
  String get consentRecordId;

  /// MIME type of the image to upload.
  @BuiltValueField(wireName: r'content_type')
  IdDocumentInContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/jpeg,  image/webp,  };

  /// Document type code, e.g. `aadhaar`.
  @BuiltValueField(wireName: r'doc_type')
  String get docType;

  /// Hex SHA-256 of the image (device).
  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  IdDocumentIn._();

  factory IdDocumentIn([void updates(IdDocumentInBuilder b)]) = _$IdDocumentIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdDocumentInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IdDocumentIn> get serializer => _$IdDocumentInSerializer();
}

class _$IdDocumentInSerializer implements PrimitiveSerializer<IdDocumentIn> {
  @override
  final Iterable<Type> types = const [IdDocumentIn, _$IdDocumentIn];

  @override
  final String wireName = r'IdDocumentIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IdDocumentIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'consent_record_id';
    yield serializers.serialize(
      object.consentRecordId,
      specifiedType: const FullType(String),
    );
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(IdDocumentInContentTypeEnum),
    );
    yield r'doc_type';
    yield serializers.serialize(
      object.docType,
      specifiedType: const FullType(String),
    );
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IdDocumentIn object, {
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
    required IdDocumentInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'consent_record_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.consentRecordId = valueDes;
          break;
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IdDocumentInContentTypeEnum),
          ) as IdDocumentInContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'doc_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.docType = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IdDocumentIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdDocumentInBuilder();
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

/// MIME type of the image to upload.
class IdDocumentInContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const IdDocumentInContentTypeEnum imageSlashJpeg =
      _$idDocumentInContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const IdDocumentInContentTypeEnum imageSlashWebp =
      _$idDocumentInContentTypeEnum_imageSlashWebp;

  static Serializer<IdDocumentInContentTypeEnum> get serializer =>
      _$idDocumentInContentTypeEnumSerializer;

  const IdDocumentInContentTypeEnum._(String name) : super(name);

  static BuiltSet<IdDocumentInContentTypeEnum> get values =>
      _$idDocumentInContentTypeEnumValues;
  static IdDocumentInContentTypeEnum valueOf(String name) =>
      _$idDocumentInContentTypeEnumValueOf(name);
}
