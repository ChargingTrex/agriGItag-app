//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/org_kind.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'processor_out.g.dart';

/// A processor as returned by the API.
///
/// Properties:
/// * [address] - Address.
/// * [addressLine] - Address on one line, without repeated parts.
/// * [fpoId] - FPO that registered it; null for a shared processor.
/// * [fssaiNo] - FSSAI licence number.
/// * [giAuthorisedUserNo] - GI authorised-user registration number.
/// * [id] - Processor id.
/// * [kind] - Legal form.
/// * [name] - Registered name.
@BuiltValue()
abstract class ProcessorOut
    implements Built<ProcessorOut, ProcessorOutBuilder> {
  /// Address.
  @BuiltValueField(wireName: r'address')
  Address? get address;

  /// Address on one line, without repeated parts.
  @BuiltValueField(wireName: r'address_line')
  String get addressLine;

  /// FPO that registered it; null for a shared processor.
  @BuiltValueField(wireName: r'fpo_id')
  String? get fpoId;

  /// FSSAI licence number.
  @BuiltValueField(wireName: r'fssai_no')
  String? get fssaiNo;

  /// GI authorised-user registration number.
  @BuiltValueField(wireName: r'gi_authorised_user_no')
  String? get giAuthorisedUserNo;

  /// Processor id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Legal form.
  @BuiltValueField(wireName: r'kind')
  OrgKind get kind;
  // enum kindEnum {  fpo,  company,  coop,  };

  /// Registered name.
  @BuiltValueField(wireName: r'name')
  String get name;

  ProcessorOut._();

  factory ProcessorOut([void updates(ProcessorOutBuilder b)]) = _$ProcessorOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProcessorOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProcessorOut> get serializer => _$ProcessorOutSerializer();
}

class _$ProcessorOutSerializer implements PrimitiveSerializer<ProcessorOut> {
  @override
  final Iterable<Type> types = const [ProcessorOut, _$ProcessorOut];

  @override
  final String wireName = r'ProcessorOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProcessorOut object, {
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
    yield r'fpo_id';
    yield object.fpoId == null
        ? null
        : serializers.serialize(
            object.fpoId,
            specifiedType: const FullType.nullable(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ProcessorOut object, {
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
    required ProcessorOutBuilder result,
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
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fpoId = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProcessorOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProcessorOutBuilder();
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
