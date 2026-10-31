//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/photo_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photos_confirm_in.g.dart';

/// Photos the phone believes are uploaded.
///
/// Properties:
/// * [photos] - Photos to confirm.
@BuiltValue()
abstract class PhotosConfirmIn
    implements Built<PhotosConfirmIn, PhotosConfirmInBuilder> {
  /// Photos to confirm.
  @BuiltValueField(wireName: r'photos')
  BuiltList<PhotoRef> get photos;

  PhotosConfirmIn._();

  factory PhotosConfirmIn([void updates(PhotosConfirmInBuilder b)]) =
      _$PhotosConfirmIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhotosConfirmInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhotosConfirmIn> get serializer =>
      _$PhotosConfirmInSerializer();
}

class _$PhotosConfirmInSerializer
    implements PrimitiveSerializer<PhotosConfirmIn> {
  @override
  final Iterable<Type> types = const [PhotosConfirmIn, _$PhotosConfirmIn];

  @override
  final String wireName = r'PhotosConfirmIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhotosConfirmIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'photos';
    yield serializers.serialize(
      object.photos,
      specifiedType: const FullType(BuiltList, [FullType(PhotoRef)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhotosConfirmIn object, {
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
    required PhotosConfirmInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PhotoRef)]),
          ) as BuiltList<PhotoRef>;
          result.photos.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhotosConfirmIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhotosConfirmInBuilder();
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
