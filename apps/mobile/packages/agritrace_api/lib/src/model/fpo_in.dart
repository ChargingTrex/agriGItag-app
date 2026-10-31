//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/org_kind.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fpo_in.g.dart';

/// A new FPO (tenant); created by a super-admin.
///
/// Properties:
/// * [address] - Registered address (FR53).
/// * [code] - Stable upper-case code.
/// * [fssaiNo] - FSSAI licence number (FR62).
/// * [giAuthorisedUserNo] - GI authorised-user registration number (FR62).
/// * [kind] - Legal form: fpo, company or coop.
/// * [name] - Registered name.
/// * [publicShowFarmerNames] - Whether public pages may show farmer names (still subject to each consent).
@BuiltValue()
abstract class FpoIn implements Built<FpoIn, FpoInBuilder> {
  /// Registered address (FR53).
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// Stable upper-case code.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// FSSAI licence number (FR62).
  @BuiltValueField(wireName: r'fssai_no')
  String? get fssaiNo;

  /// GI authorised-user registration number (FR62).
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// Legal form: fpo, company or coop.
  @BuiltValueField(wireName: r'kind')
  OrgKind? get kind;
  // enum kindEnum {  fpo,  company,  coop,  };

  /// Registered name.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Whether public pages may show farmer names (still subject to each consent).
  @BuiltValueField(wireName: r'public_show_farmer_names')
  bool? get publicShowFarmerNames;

  FpoIn._();

  factory FpoIn([void updates(FpoInBuilder b)]) = _$FpoIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FpoInBuilder b) => b
    ..kind = OrgKind.fpo
    ..publicShowFarmerNames = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<FpoIn> get serializer => _$FpoInSerializer();
}

class _$FpoInSerializer implements PrimitiveSerializer<FpoIn> {
  @override
  final Iterable<Type> types = const [FpoIn, _$FpoIn];

  @override
  final String wireName = r'FpoIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FpoIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(Address),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.fssaiNo != null) {
      yield r'fssai_no';
      yield serializers.serialize(
        object.fssaiNo,
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
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(OrgKind),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.publicShowFarmerNames != null) {
      yield r'public_show_farmer_names';
      yield serializers.serialize(
        object.publicShowFarmerNames,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FpoIn object, {
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
    required FpoInBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'fssai_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fssaiNo = valueDes;
          break;
        case r'gi_authorised_user_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.giAuthorisedUserNo = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OrgKind),
          ) as OrgKind?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'public_show_farmer_names':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.publicShowFarmerNames = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FpoIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FpoInBuilder();
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
