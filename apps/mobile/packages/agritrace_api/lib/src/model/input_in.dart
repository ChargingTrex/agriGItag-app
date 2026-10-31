//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/input_category.dart';
import 'package:agritrace_api/src/model/pack_size.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'input_in.g.dart';

/// A fertiliser or pesticide added to the master list (FR56).
///
/// Properties:
/// * [category] - Category from which practice tags are derived (FR56).
/// * [globalEntry] - True adds it to the list every FPO sees (super-admin only); else FPO-only.
/// * [manufacturer] - Manufacturer or brand.
/// * [nameEn] - Product name in English.
/// * [nameLocal] - Product name in the local script.
/// * [packSize]
/// * [photoKey] - Object key of a product photo.
/// * [unit] - Unit quantities are entered in, e.g. kg, l.
@BuiltValue()
abstract class InputIn implements Built<InputIn, InputInBuilder> {
  /// Category from which practice tags are derived (FR56).
  @BuiltValueField(wireName: r'category')
  InputCategory get category;
  // enum categoryEnum {  chemical_fertilizer,  organic_fertilizer,  bio_fertilizer,  chemical_pesticide,  bio_pesticide,  other,  };

  /// True adds it to the list every FPO sees (super-admin only); else FPO-only.
  @BuiltValueField(wireName: r'global_entry')
  bool? get globalEntry;

  /// Manufacturer or brand.
  @BuiltValueField(wireName: r'manufacturer')
  String? get manufacturer;

  /// Product name in English.
  @BuiltValueField(wireName: r'name_en')
  String get nameEn;

  /// Product name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  @BuiltValueField(wireName: r'pack_size')
  PackSize? get packSize;

  /// Object key of a product photo.
  @BuiltValueField(wireName: r'photo_key')
  String? get photoKey;

  /// Unit quantities are entered in, e.g. kg, l.
  @BuiltValueField(wireName: r'unit')
  String get unit;

  InputIn._();

  factory InputIn([void updates(InputInBuilder b)]) = _$InputIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InputInBuilder b) => b..globalEntry = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<InputIn> get serializer => _$InputInSerializer();
}

class _$InputInSerializer implements PrimitiveSerializer<InputIn> {
  @override
  final Iterable<Type> types = const [InputIn, _$InputIn];

  @override
  final String wireName = r'InputIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InputIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(InputCategory),
    );
    if (object.globalEntry != null) {
      yield r'global_entry';
      yield serializers.serialize(
        object.globalEntry,
        specifiedType: const FullType(bool),
      );
    }
    if (object.manufacturer != null) {
      yield r'manufacturer';
      yield serializers.serialize(
        object.manufacturer,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'name_en';
    yield serializers.serialize(
      object.nameEn,
      specifiedType: const FullType(String),
    );
    if (object.nameLocal != null) {
      yield r'name_local';
      yield serializers.serialize(
        object.nameLocal,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.packSize != null) {
      yield r'pack_size';
      yield serializers.serialize(
        object.packSize,
        specifiedType: const FullType.nullable(PackSize),
      );
    }
    if (object.photoKey != null) {
      yield r'photo_key';
      yield serializers.serialize(
        object.photoKey,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InputIn object, {
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
    required InputInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InputCategory),
          ) as InputCategory;
          result.category = valueDes;
          break;
        case r'global_entry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.globalEntry = valueDes;
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
            specifiedType: const FullType.nullable(PackSize),
          ) as PackSize?;
          if (valueDes == null) continue;
          result.packSize.replace(valueDes);
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
  InputIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InputInBuilder();
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
