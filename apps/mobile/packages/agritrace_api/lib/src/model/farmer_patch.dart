//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_patch.g.dart';

/// Changes to a farmer's profile; only the fields sent are changed.
///
/// Properties:
/// * [address] - Structured address (replaces the stored one).
/// * [giAuthorisedUserNo] - GI authorised-user number.
/// * [name] - Name in English script.
/// * [nameLocal] - Name in the local script.
/// * [noSmartphone] - True when the officer always enters data.
/// * [photoKey] - Object key of the profile photo.
/// * [villageId] - Village picked from GET /v1/villages.
@BuiltValue()
abstract class FarmerPatch implements Built<FarmerPatch, FarmerPatchBuilder> {
  /// Structured address (replaces the stored one).
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// GI authorised-user number.
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// Name in English script.
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// True when the officer always enters data.
  @BuiltValueField(wireName: r'no_smartphone')
  bool? get noSmartphone;

  /// Object key of the profile photo.
  @BuiltValueField(wireName: r'photo_key')
  String? get photoKey;

  /// Village picked from GET /v1/villages.
  @BuiltValueField(wireName: r'village_id')
  String? get villageId;

  FarmerPatch._();

  factory FarmerPatch([void updates(FarmerPatchBuilder b)]) = _$FarmerPatch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerPatchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerPatch> get serializer => _$FarmerPatchSerializer();
}

class _$FarmerPatchSerializer implements PrimitiveSerializer<FarmerPatch> {
  @override
  final Iterable<Type> types = const [FarmerPatch, _$FarmerPatch];

  @override
  final String wireName = r'FarmerPatch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerPatch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(Address),
      );
    }
    if (object.giAuthorisedUserNo != null) {
      yield r'gi_authorised_user_no';
      yield serializers.serialize(
        object.giAuthorisedUserNo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nameLocal != null) {
      yield r'name_local';
      yield serializers.serialize(
        object.nameLocal,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.noSmartphone != null) {
      yield r'no_smartphone';
      yield serializers.serialize(
        object.noSmartphone,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.photoKey != null) {
      yield r'photo_key';
      yield serializers.serialize(
        object.photoKey,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.villageId != null) {
      yield r'village_id';
      yield serializers.serialize(
        object.villageId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerPatch object, {
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
    required FarmerPatchBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Address),
          ) as Address?;
          if (valueDes == null) continue;
          result.address.replace(valueDes);
          break;
        case r'gi_authorised_user_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giAuthorisedUserNo = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'name_local':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameLocal = valueDes;
          break;
        case r'no_smartphone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.noSmartphone = valueDes;
          break;
        case r'photo_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photoKey = valueDes;
          break;
        case r'village_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.villageId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FarmerPatch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerPatchBuilder();
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
