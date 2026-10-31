//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'crop_out.g.dart';

/// A crop farmers can grow, with its GI tag and event schema (FR22, FR55).
///
/// Properties:
/// * [active] - False hides the crop from new lots.
/// * [code] - Stable crop code.
/// * [eventSchema] - Mandatory event types and date-order rules (FR55).
/// * [giTagId] - GI tag the crop is sold under, if any.
/// * [id] - Crop id.
/// * [lang] - Language code of name_local.
/// * [nameEn] - Crop name in English.
/// * [nameLocal] - Crop name in the local script.
@BuiltValue()
abstract class CropOut implements Built<CropOut, CropOutBuilder> {
  /// False hides the crop from new lots.
  @BuiltValueField(wireName: r'active')
  bool get active;

  /// Stable crop code.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Mandatory event types and date-order rules (FR55).
  @BuiltValueField(wireName: r'event_schema')
  BuiltMap<String, JsonObject?> get eventSchema;

  /// GI tag the crop is sold under, if any.
  @BuiltValueField(wireName: r'gi_tag_id')
  String? get giTagId;

  /// Crop id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Language code of name_local.
  @BuiltValueField(wireName: r'lang')
  String get lang;

  /// Crop name in English.
  @BuiltValueField(wireName: r'name_en')
  String get nameEn;

  /// Crop name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  CropOut._();

  factory CropOut([void updates(CropOutBuilder b)]) = _$CropOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CropOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CropOut> get serializer => _$CropOutSerializer();
}

class _$CropOutSerializer implements PrimitiveSerializer<CropOut> {
  @override
  final Iterable<Type> types = const [CropOut, _$CropOut];

  @override
  final String wireName = r'CropOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CropOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'event_schema';
    yield serializers.serialize(
      object.eventSchema,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'gi_tag_id';
    yield object.giTagId == null
        ? null
        : serializers.serialize(
            object.giTagId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lang';
    yield serializers.serialize(
      object.lang,
      specifiedType: const FullType(String),
    );
    yield r'name_en';
    yield serializers.serialize(
      object.nameEn,
      specifiedType: const FullType(String),
    );
    yield r'name_local';
    yield object.nameLocal == null
        ? null
        : serializers.serialize(
            object.nameLocal,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    CropOut object, {
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
    required CropOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'event_schema':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.eventSchema.replace(valueDes);
          break;
        case r'gi_tag_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giTagId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lang = valueDes;
          break;
        case r'name_en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nameEn = valueDes;
          break;
        case r'name_local':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameLocal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CropOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CropOutBuilder();
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
