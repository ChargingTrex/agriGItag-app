//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/org_kind.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fpo_out.g.dart';

/// An FPO as returned by the API.
///
/// Properties:
/// * [address] - Registered address.
/// * [addressLine] - Address on one line, without repeated parts.
/// * [bbox] - [min_lon, min_lat, max_lon, max_lat] (WGS84) of the FPO's plots, or of the current GI regions when it has none; for the portal map and tile cache. Only on GET /v1/fpos/{id} for fpo_admin, field_officer, qc_officer and super-admins; null for farmers and viewers, on lists and when there is nothing to frame. One plot gives a zero-size box: pad it client-side.
/// * [code] - Stable upper-case code.
/// * [fssaiNo] - FSSAI licence number.
/// * [giAuthorisedUserNo] - GI authorised-user registration number.
/// * [id] - FPO id.
/// * [kind] - Legal form.
/// * [name] - Registered name.
/// * [publicShowFarmerNames] - Whether public pages may show farmer names.
@BuiltValue()
abstract class FpoOut implements Built<FpoOut, FpoOutBuilder> {
  /// Registered address.
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// Address on one line, without repeated parts.
  @BuiltValueField(wireName: r'address_line')
  String get addressLine;

  /// [min_lon, min_lat, max_lon, max_lat] (WGS84) of the FPO's plots, or of the current GI regions when it has none; for the portal map and tile cache. Only on GET /v1/fpos/{id} for fpo_admin, field_officer, qc_officer and super-admins; null for farmers and viewers, on lists and when there is nothing to frame. One plot gives a zero-size box: pad it client-side.
  @BuiltValueField(wireName: r'bbox')
  BuiltList<num>? get bbox;

  /// Stable upper-case code.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// FSSAI licence number.
  @BuiltValueField(wireName: r'fssai_no')
  String? get fssaiNo;

  /// GI authorised-user registration number.
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// FPO id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Legal form.
  @BuiltValueField(wireName: r'kind')
  OrgKind get kind;
  // enum kindEnum {  fpo,  company,  coop,  };

  /// Registered name.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Whether public pages may show farmer names.
  @BuiltValueField(wireName: r'public_show_farmer_names')
  bool get publicShowFarmerNames;

  FpoOut._();

  factory FpoOut([void updates(FpoOutBuilder b)]) = _$FpoOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FpoOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FpoOut> get serializer => _$FpoOutSerializer();
}

class _$FpoOutSerializer implements PrimitiveSerializer<FpoOut> {
  @override
  final Iterable<Type> types = const [FpoOut, _$FpoOut];

  @override
  final String wireName = r'FpoOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FpoOut object, {
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
    if (object.bbox != null) {
      yield r'bbox';
      yield serializers.serialize(
        object.bbox,
        specifiedType: const FullType.nullable(BuiltList, [FullType(num)]),
      );
    }
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'fssai_no';
    yield object.fssaiNo == null
        ? null
        : serializers.serialize(
            object.fssaiNo,
            specifiedType: const FullType.nullable(String),
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
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(OrgKind),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'public_show_farmer_names';
    yield serializers.serialize(
      object.publicShowFarmerNames,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FpoOut object, {
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
    required FpoOutBuilder result,
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
        case r'bbox':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(num)]),
          ) as BuiltList<num>?;
          if (valueDes == null) continue;
          result.bbox.replace(valueDes);
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrgKind),
          ) as OrgKind;
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
            specifiedType: const FullType(bool),
          ) as bool;
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
  FpoOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FpoOutBuilder();
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
