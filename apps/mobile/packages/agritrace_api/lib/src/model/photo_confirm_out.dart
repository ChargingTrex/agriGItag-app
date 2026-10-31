//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photo_confirm_out.g.dart';

/// Whether storage holds the photo.
///
/// Properties:
/// * [clientId] - The photo's client id.
/// * [status] - received: stored and queued for verification; missing: upload again, then confirm.
@BuiltValue()
abstract class PhotoConfirmOut
    implements Built<PhotoConfirmOut, PhotoConfirmOutBuilder> {
  /// The photo's client id.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// received: stored and queued for verification; missing: upload again, then confirm.
  @BuiltValueField(wireName: r'status')
  PhotoConfirmOutStatusEnum get status;
  // enum statusEnum {  received,  missing,  };

  PhotoConfirmOut._();

  factory PhotoConfirmOut([void updates(PhotoConfirmOutBuilder b)]) =
      _$PhotoConfirmOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhotoConfirmOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhotoConfirmOut> get serializer =>
      _$PhotoConfirmOutSerializer();
}

class _$PhotoConfirmOutSerializer
    implements PrimitiveSerializer<PhotoConfirmOut> {
  @override
  final Iterable<Type> types = const [PhotoConfirmOut, _$PhotoConfirmOut];

  @override
  final String wireName = r'PhotoConfirmOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhotoConfirmOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PhotoConfirmOutStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhotoConfirmOut object, {
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
    required PhotoConfirmOutBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PhotoConfirmOutStatusEnum),
          ) as PhotoConfirmOutStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhotoConfirmOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhotoConfirmOutBuilder();
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

/// received: stored and queued for verification; missing: upload again, then confirm.
class PhotoConfirmOutStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'received')
  static const PhotoConfirmOutStatusEnum received =
      _$photoConfirmOutStatusEnum_received;
  @BuiltValueEnumConst(wireName: r'missing')
  static const PhotoConfirmOutStatusEnum missing =
      _$photoConfirmOutStatusEnum_missing;

  static Serializer<PhotoConfirmOutStatusEnum> get serializer =>
      _$photoConfirmOutStatusEnumSerializer;

  const PhotoConfirmOutStatusEnum._(String name) : super(name);

  static BuiltSet<PhotoConfirmOutStatusEnum> get values =>
      _$photoConfirmOutStatusEnumValues;
  static PhotoConfirmOutStatusEnum valueOf(String name) =>
      _$photoConfirmOutStatusEnumValueOf(name);
}
