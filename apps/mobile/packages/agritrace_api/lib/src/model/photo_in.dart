//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/geo_point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photo_in.g.dart';

/// An evidence photo or voice note announced with its entry; bytes follow by presigned PUT (D-011).
///
/// Properties:
/// * [clientId] - UUIDv7 generated on the phone; the photo's id (D-005).
/// * [contentType] - `image/jpeg` for photos (M04); voice notes `audio/ogg` (Android 10+) or `audio/mp4` (iOS, Android 8–9). Bound into the PUT; picks the object key extension.
/// * [exifGps] - GPS position the phone wrote into EXIF, if any.
/// * [exifTakenAt] - Capture time the phone wrote into EXIF, with offset; re-read by the server.
/// * [sha256] - Lower-case hex SHA-256 of the JPEG; bound into the PUT.
/// * [sizeBytes] - File size in bytes.
@BuiltValue()
abstract class PhotoIn implements Built<PhotoIn, PhotoInBuilder> {
  /// UUIDv7 generated on the phone; the photo's id (D-005).
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// `image/jpeg` for photos (M04); voice notes `audio/ogg` (Android 10+) or `audio/mp4` (iOS, Android 8–9). Bound into the PUT; picks the object key extension.
  @BuiltValueField(wireName: r'content_type')
  PhotoInContentTypeEnum? get contentType;
  // enum contentTypeEnum {  image/jpeg,  audio/ogg,  audio/mp4,  };

  /// GPS position the phone wrote into EXIF, if any.
  @BuiltValueField(wireName: r'exif_gps')
  GeoPoint? get exifGps;

  /// Capture time the phone wrote into EXIF, with offset; re-read by the server.
  @BuiltValueField(wireName: r'exif_taken_at')
  DateTime? get exifTakenAt;

  /// Lower-case hex SHA-256 of the JPEG; bound into the PUT.
  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  /// File size in bytes.
  @BuiltValueField(wireName: r'size_bytes')
  int get sizeBytes;

  PhotoIn._();

  factory PhotoIn([void updates(PhotoInBuilder b)]) = _$PhotoIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhotoInBuilder b) =>
      b..contentType = PhotoInContentTypeEnum.valueOf('image/jpeg');

  @BuiltValueSerializer(custom: true)
  static Serializer<PhotoIn> get serializer => _$PhotoInSerializer();
}

class _$PhotoInSerializer implements PrimitiveSerializer<PhotoIn> {
  @override
  final Iterable<Type> types = const [PhotoIn, _$PhotoIn];

  @override
  final String wireName = r'PhotoIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhotoIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.contentType != null) {
      yield r'content_type';
      yield serializers.serialize(
        object.contentType,
        specifiedType: const FullType(PhotoInContentTypeEnum),
      );
    }
    if (object.exifGps != null) {
      yield r'exif_gps';
      yield serializers.serialize(
        object.exifGps,
        specifiedType: const FullType.nullable(GeoPoint),
      );
    }
    if (object.exifTakenAt != null) {
      yield r'exif_taken_at';
      yield serializers.serialize(
        object.exifTakenAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'size_bytes';
    yield serializers.serialize(
      object.sizeBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhotoIn object, {
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
    required PhotoInBuilder result,
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
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PhotoInContentTypeEnum),
          ) as PhotoInContentTypeEnum?;
          if (valueDes == null) continue;
          result.contentType = valueDes;
          break;
        case r'exif_gps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GeoPoint),
          ) as GeoPoint?;
          if (valueDes == null) continue;
          result.exifGps.replace(valueDes);
          break;
        case r'exif_taken_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.exifTakenAt = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sizeBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhotoIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhotoInBuilder();
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

/// `image/jpeg` for photos (M04); voice notes `audio/ogg` (Android 10+) or `audio/mp4` (iOS, Android 8–9). Bound into the PUT; picks the object key extension.
class PhotoInContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const PhotoInContentTypeEnum imageSlashJpeg =
      _$photoInContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'audio/ogg')
  static const PhotoInContentTypeEnum audioSlashOgg =
      _$photoInContentTypeEnum_audioSlashOgg;
  @BuiltValueEnumConst(wireName: r'audio/mp4')
  static const PhotoInContentTypeEnum audioSlashMp4 =
      _$photoInContentTypeEnum_audioSlashMp4;

  static Serializer<PhotoInContentTypeEnum> get serializer =>
      _$photoInContentTypeEnumSerializer;

  const PhotoInContentTypeEnum._(String name) : super(name);

  static BuiltSet<PhotoInContentTypeEnum> get values =>
      _$photoInContentTypeEnumValues;
  static PhotoInContentTypeEnum valueOf(String name) =>
      _$photoInContentTypeEnumValueOf(name);
}
