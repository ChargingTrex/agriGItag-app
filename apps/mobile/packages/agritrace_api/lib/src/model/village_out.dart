//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'village_out.g.dart';

/// A village from the LGD directory, as offered in the onboarding picker (FR53).
///
/// Properties:
/// * [block] - Development block.
/// * [district] - District.
/// * [id] - Village id.
/// * [lgdCode] - Local Government Directory village code.
/// * [nameEn] - Village name in English.
/// * [nameLocal] - Village name in the local script.
/// * [pincode] - Six-digit PIN code.
/// * [state] - State.
/// * [taluk] - Taluk (sub-district).
@BuiltValue()
abstract class VillageOut implements Built<VillageOut, VillageOutBuilder> {
  /// Development block.
  @BuiltValueField(wireName: r'block')
  String? get block;

  /// District.
  @BuiltValueField(wireName: r'district')
  String get district;

  /// Village id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Local Government Directory village code.
  @BuiltValueField(wireName: r'lgd_code')
  String? get lgdCode;

  /// Village name in English.
  @BuiltValueField(wireName: r'name_en')
  String get nameEn;

  /// Village name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// Six-digit PIN code.
  @BuiltValueField(wireName: r'pincode')
  String? get pincode;

  /// State.
  @BuiltValueField(wireName: r'state')
  String get state;

  /// Taluk (sub-district).
  @BuiltValueField(wireName: r'taluk')
  String? get taluk;

  VillageOut._();

  factory VillageOut([void updates(VillageOutBuilder b)]) = _$VillageOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VillageOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VillageOut> get serializer => _$VillageOutSerializer();
}

class _$VillageOutSerializer implements PrimitiveSerializer<VillageOut> {
  @override
  final Iterable<Type> types = const [VillageOut, _$VillageOut];

  @override
  final String wireName = r'VillageOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VillageOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'block';
    yield object.block == null
        ? null
        : serializers.serialize(
            object.block,
            specifiedType: const FullType.nullable(String),
          );
    yield r'district';
    yield serializers.serialize(
      object.district,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lgd_code';
    yield object.lgdCode == null
        ? null
        : serializers.serialize(
            object.lgdCode,
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
    yield r'pincode';
    yield object.pincode == null
        ? null
        : serializers.serialize(
            object.pincode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(String),
    );
    yield r'taluk';
    yield object.taluk == null
        ? null
        : serializers.serialize(
            object.taluk,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    VillageOut object, {
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
    required VillageOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'block':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.block = valueDes;
          break;
        case r'district':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.district = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'lgd_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lgdCode = valueDes;
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
        case r'pincode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pincode = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.state = valueDes;
          break;
        case r'taluk':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taluk = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VillageOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VillageOutBuilder();
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
