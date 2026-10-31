//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photo_ref.g.dart';

/// A photo the phone has uploaded.
///
/// Properties:
/// * [clientId] - The photo's client id.
@BuiltValue()
abstract class PhotoRef implements Built<PhotoRef, PhotoRefBuilder> {
  /// The photo's client id.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  PhotoRef._();

  factory PhotoRef([void updates(PhotoRefBuilder b)]) = _$PhotoRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhotoRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhotoRef> get serializer => _$PhotoRefSerializer();
}

class _$PhotoRefSerializer implements PrimitiveSerializer<PhotoRef> {
  @override
  final Iterable<Type> types = const [PhotoRef, _$PhotoRef];

  @override
  final String wireName = r'PhotoRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhotoRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhotoRef object, {
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
    required PhotoRefBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhotoRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhotoRefBuilder();
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
