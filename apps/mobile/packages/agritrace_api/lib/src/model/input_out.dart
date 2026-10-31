//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/input_category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input_out.g.dart';

/// An entry of the input master list.
///
/// Properties:
/// * [active] - False hides it from new entries.
/// * [category] - Input category (FR56).
/// * [fpoId] - FPO-specific entry; null for the global list.
/// * [id] - Input id.
/// * [manufacturer] - Manufacturer or brand.
/// * [nameEn] - Product name in English.
/// * [nameLocal] - Product name in the local script.
/// * [packSize] - Typical pack size, in `unit`.
/// * [photoKey] - Object key of a product photo.
/// * [unit] - Unit quantities are entered in.
@BuiltValue()
abstract class InputOut implements Built<InputOut, InputOutBuilder> {
  /// False hides it from new entries.
  @BuiltValueField(wireName: r'active')
  bool get active;

  /// Input category (FR56).
  @BuiltValueField(wireName: r'category')
  InputCategory get category;
  // enum categoryEnum {  chemical_fertilizer,  organic_fertilizer,  bio_fertilizer,  chemical_pesticide,  bio_pesticide,  other,  };

  /// FPO-specific entry; null for the global list.
  @BuiltValueField(wireName: r'fpo_id')
  String? get fpoId;

  /// Input id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Manufacturer or brand.
  @BuiltValueField(wireName: r'manufacturer')
  String? get manufacturer;

  /// Product name in English.
  @BuiltValueField(wireName: r'name_en')
  String get nameEn;

  /// Product name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// Typical pack size, in `unit`.
  @BuiltValueField(wireName: r'pack_size')
  String? get packSize;

  /// Object key of a product photo.
  @BuiltValueField(wireName: r'photo_key')
  String? get photoKey;

  /// Unit quantities are entered in.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  InputOut._();

  factory InputOut([void updates(InputOutBuilder b)]) = _$InputOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InputOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InputOut> get serializer => _$InputOutSerializer();
}

class _$InputOutSerializer implements PrimitiveSerializer<InputOut> {
  @override
  final Iterable<Type> types = const [InputOut, _$InputOut];

  @override
  final String wireName = r'InputOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InputOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(InputCategory),
    );
    yield r'fpo_id';
    yield object.fpoId == null
        ? null
        : serializers.serialize(
            object.fpoId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'manufacturer';
    yield object.manufacturer == null
        ? null
        : serializers.serialize(
            object.manufacturer,
            specifiedType: const FullType.nullable(String),
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
    yield r'pack_size';
    yield object.packSize == null
        ? null
        : serializers.serialize(
            object.packSize,
            specifiedType: const FullType.nullable(String),
          );
    yield r'photo_key';
    yield object.photoKey == null
        ? null
        : serializers.serialize(
            object.photoKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InputOut object, {
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
    required InputOutBuilder result,
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
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InputCategory),
          ) as InputCategory;
          result.category = valueDes;
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fpoId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'manufacturer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.manufacturer = valueDes;
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
        case r'pack_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.packSize = valueDes;
          break;
        case r'photo_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photoKey = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InputOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InputOutBuilder();
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
