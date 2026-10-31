//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/photo_status.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'event_photo_out.g.dart';

/// An evidence photo on the timeline.
///
/// Properties:
/// * [id] - Photo id.
/// * [status] - Upload and verification state.
/// * [variants] - {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links.
@BuiltValue()
abstract class EventPhotoOut
    implements Built<EventPhotoOut, EventPhotoOutBuilder> {
  /// Photo id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Upload and verification state.
  @BuiltValueField(wireName: r'status')
  PhotoStatus get status;
  // enum statusEnum {  pending_upload,  uploaded,  verified,  checksum_mismatch,  exif_mismatch,  };

  /// {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links.
  @BuiltValueField(wireName: r'variants')
  BuiltMap<String, JsonObject?>? get variants;

  EventPhotoOut._();

  factory EventPhotoOut([void updates(EventPhotoOutBuilder b)]) =
      _$EventPhotoOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EventPhotoOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EventPhotoOut> get serializer =>
      _$EventPhotoOutSerializer();
}

class _$EventPhotoOutSerializer implements PrimitiveSerializer<EventPhotoOut> {
  @override
  final Iterable<Type> types = const [EventPhotoOut, _$EventPhotoOut];

  @override
  final String wireName = r'EventPhotoOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EventPhotoOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PhotoStatus),
    );
    if (object.variants != null) {
      yield r'variants';
      yield serializers.serialize(
        object.variants,
        specifiedType: const FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EventPhotoOut object, {
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
    required EventPhotoOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PhotoStatus),
          ) as PhotoStatus;
          result.status = valueDes;
          break;
        case r'variants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.variants.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EventPhotoOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EventPhotoOutBuilder();
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
