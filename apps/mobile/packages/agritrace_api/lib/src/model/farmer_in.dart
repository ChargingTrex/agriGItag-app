//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_in.g.dart';

/// A farmer onboarded by a field officer or admin (Stage 0, UserFlows §Onboarding a farmer).
///
/// Properties:
/// * [address] - Structured address (FR53); parts left empty are filled from `village_id`.
/// * [clientId] - Farmer id generated on the phone (UUIDv7, D-031); becomes the farmer's `id`. Resending it returns the stored farmer with 201 (no phone check, no second account); an id used by another FPO → 409 `client_id_conflict`. In a sync push `farmer` entry the entry's `client_id` is used.
/// * [giAuthorisedUserNo] - Farmer's GI authorised-user registration number (FR62).
/// * [lang] - Preferred language for app, SMS and voice.
/// * [name] - Name in English script.
/// * [nameLocal] - Name in the local script (FR5).
/// * [noSmartphone] - True when the officer always enters data for this farmer (assist mode).
/// * [phone] - Mobile number in E.164, e.g. +919876543210; creates or links the farmer's sign-in account (also for feature-phone farmers, who get SMS).
/// * [photoKey] - Object key of the profile photo.
/// * [villageId] - Village picked from GET /v1/villages.
@BuiltValue()
abstract class FarmerIn implements Built<FarmerIn, FarmerInBuilder> {
  /// Structured address (FR53); parts left empty are filled from `village_id`.
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// Farmer id generated on the phone (UUIDv7, D-031); becomes the farmer's `id`. Resending it returns the stored farmer with 201 (no phone check, no second account); an id used by another FPO → 409 `client_id_conflict`. In a sync push `farmer` entry the entry's `client_id` is used.
  @BuiltValueField(wireName: r'client_id')
  String? get clientId;

  /// Farmer's GI authorised-user registration number (FR62).
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// Preferred language for app, SMS and voice.
  @BuiltValueField(wireName: r'lang')
  FarmerInLangEnum? get lang;
  // enum langEnum {  ta,  en,  };

  /// Name in English script.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Name in the local script (FR5).
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// True when the officer always enters data for this farmer (assist mode).
  @BuiltValueField(wireName: r'no_smartphone')
  bool? get noSmartphone;

  /// Mobile number in E.164, e.g. +919876543210; creates or links the farmer's sign-in account (also for feature-phone farmers, who get SMS).
  @BuiltValueField(wireName: r'phone')
  String? get phone;

  /// Object key of the profile photo.
  @BuiltValueField(wireName: r'photo_key')
  String? get photoKey;

  /// Village picked from GET /v1/villages.
  @BuiltValueField(wireName: r'village_id')
  String? get villageId;

  FarmerIn._();

  factory FarmerIn([void updates(FarmerInBuilder b)]) = _$FarmerIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerInBuilder b) => b
    ..lang = FarmerInLangEnum.valueOf('ta')
    ..noSmartphone = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerIn> get serializer => _$FarmerInSerializer();
}

class _$FarmerInSerializer implements PrimitiveSerializer<FarmerIn> {
  @override
  final Iterable<Type> types = const [FarmerIn, _$FarmerIn];

  @override
  final String wireName = r'FarmerIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(Address),
      );
    }
    if (object.clientId != null) {
      yield r'client_id';
      yield serializers.serialize(
        object.clientId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.giAuthorisedUserNo != null) {
      yield r'gi_authorised_user_no';
      yield serializers.serialize(
        object.giAuthorisedUserNo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lang != null) {
      yield r'lang';
      yield serializers.serialize(
        object.lang,
        specifiedType: const FullType(FarmerInLangEnum),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
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
        specifiedType: const FullType(bool),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
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
    FarmerIn object, {
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
    required FarmerInBuilder result,
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
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientId = valueDes;
          break;
        case r'gi_authorised_user_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giAuthorisedUserNo = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FarmerInLangEnum),
          ) as FarmerInLangEnum?;
          if (valueDes == null) continue;
          result.lang = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
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
  FarmerIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerInBuilder();
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

/// Preferred language for app, SMS and voice.
class FarmerInLangEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ta')
  static const FarmerInLangEnum ta = _$farmerInLangEnum_ta;
  @BuiltValueEnumConst(wireName: r'en')
  static const FarmerInLangEnum en = _$farmerInLangEnum_en;

  static Serializer<FarmerInLangEnum> get serializer =>
      _$farmerInLangEnumSerializer;

  const FarmerInLangEnum._(String name) : super(name);

  static BuiltSet<FarmerInLangEnum> get values => _$farmerInLangEnumValues;
  static FarmerInLangEnum valueOf(String name) =>
      _$farmerInLangEnumValueOf(name);
}
