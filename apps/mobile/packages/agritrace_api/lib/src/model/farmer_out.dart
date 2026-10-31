//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/farmer_status.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_out.g.dart';

/// A farmer as returned by the API; the phone (on the sign-in account) only masked (B14).
///
/// Properties:
/// * [address] - Structured address.
/// * [addressLine] - Address on one line, without repeated parts.
/// * [approvedAt] - When the farmer was approved.
/// * [approvedBy] - Admin who approved the farmer.
/// * [code] - Farmer code, unique inside the FPO.
/// * [fpoId] - Owning FPO.
/// * [giAuthorisedUserNo] - GI authorised-user registration number.
/// * [id] - Farmer id.
/// * [name] - Name in English script.
/// * [nameLocal] - Name in the local script.
/// * [noSmartphone] - True when the officer always enters data.
/// * [phoneMasked] - Phone of the sign-in account with all but the last 4 digits hidden, e.g. `XXXXXX3210`; null without a phone. FPO admins read the full number via GET /v1/farmers/{id}/phone (audited).
/// * [photoKey] - Object key of the profile photo.
/// * [status] - pending until an FPO admin approves; then active; suspended when rejected (B14).
/// * [userId] - Sign-in account; null when no phone was given.
/// * [villageId] - Village from the directory.
@BuiltValue()
abstract class FarmerOut implements Built<FarmerOut, FarmerOutBuilder> {
  /// Structured address.
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// Address on one line, without repeated parts.
  @BuiltValueField(wireName: r'address_line')
  String get addressLine;

  /// When the farmer was approved.
  @BuiltValueField(wireName: r'approved_at')
  DateTime? get approvedAt;

  /// Admin who approved the farmer.
  @BuiltValueField(wireName: r'approved_by')
  String? get approvedBy;

  /// Farmer code, unique inside the FPO.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Owning FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// GI authorised-user registration number.
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// Farmer id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Name in English script.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Name in the local script.
  @BuiltValueField(wireName: r'name_local')
  String? get nameLocal;

  /// True when the officer always enters data.
  @BuiltValueField(wireName: r'no_smartphone')
  bool get noSmartphone;

  /// Phone of the sign-in account with all but the last 4 digits hidden, e.g. `XXXXXX3210`; null without a phone. FPO admins read the full number via GET /v1/farmers/{id}/phone (audited).
  @BuiltValueField(wireName: r'phone_masked')
  String? get phoneMasked;

  /// Object key of the profile photo.
  @BuiltValueField(wireName: r'photo_key')
  String? get photoKey;

  /// pending until an FPO admin approves; then active; suspended when rejected (B14).
  @BuiltValueField(wireName: r'status')
  FarmerStatus get status;
  // enum statusEnum {  pending,  active,  suspended,  };

  /// Sign-in account; null when no phone was given.
  @BuiltValueField(wireName: r'user_id')
  String? get userId;

  /// Village from the directory.
  @BuiltValueField(wireName: r'village_id')
  String? get villageId;

  FarmerOut._();

  factory FarmerOut([void updates(FarmerOutBuilder b)]) = _$FarmerOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerOut> get serializer => _$FarmerOutSerializer();
}

class _$FarmerOutSerializer implements PrimitiveSerializer<FarmerOut> {
  @override
  final Iterable<Type> types = const [FarmerOut, _$FarmerOut];

  @override
  final String wireName = r'FarmerOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'address';
    yield object.address == null
        ? null
        : serializers.serialize(
            object.address,
            specifiedType: const FullType.nullable(Address),
          );
    yield r'address_line';
    yield serializers.serialize(
      object.addressLine,
      specifiedType: const FullType(String),
    );
    yield r'approved_at';
    yield object.approvedAt == null
        ? null
        : serializers.serialize(
            object.approvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'approved_by';
    yield object.approvedBy == null
        ? null
        : serializers.serialize(
            object.approvedBy,
            specifiedType: const FullType.nullable(String),
          );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'gi_authorised_user_no';
    yield object.giAuthorisedUserNo == null
        ? null
        : serializers.serialize(
            object.giAuthorisedUserNo,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'name_local';
    yield object.nameLocal == null
        ? null
        : serializers.serialize(
            object.nameLocal,
            specifiedType: const FullType.nullable(String),
          );
    yield r'no_smartphone';
    yield serializers.serialize(
      object.noSmartphone,
      specifiedType: const FullType(bool),
    );
    if (object.phoneMasked != null) {
      yield r'phone_masked';
      yield serializers.serialize(
        object.phoneMasked,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'photo_key';
    yield object.photoKey == null
        ? null
        : serializers.serialize(
            object.photoKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FarmerStatus),
    );
    yield r'user_id';
    yield object.userId == null
        ? null
        : serializers.serialize(
            object.userId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'village_id';
    yield object.villageId == null
        ? null
        : serializers.serialize(
            object.villageId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerOut object, {
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
    required FarmerOutBuilder result,
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
        case r'address_line':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.addressLine = valueDes;
          break;
        case r'approved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.approvedAt = valueDes;
          break;
        case r'approved_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvedBy = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'gi_authorised_user_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giAuthorisedUserNo = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
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
            specifiedType: const FullType(bool),
          ) as bool;
          result.noSmartphone = valueDes;
          break;
        case r'phone_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phoneMasked = valueDes;
          break;
        case r'photo_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photoKey = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FarmerStatus),
          ) as FarmerStatus;
          result.status = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
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
  FarmerOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerOutBuilder();
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
