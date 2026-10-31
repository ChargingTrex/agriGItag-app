//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/org_kind.dart';
import 'package:agritrace_api/src/model/address.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'processor_in.g.dart';

/// A processor an FPO sells to (Stage 7); registered by the FPO admin.
///
/// Properties:
/// * [address] - Address (FR53).
/// * [fssaiNo] - FSSAI licence number (FR62).
/// * [giAuthorisedUserNo] - GI authorised-user registration number (FR62).
/// * [kind] - Legal form: fpo, company or coop.
/// * [name] - Registered name.
@BuiltValue()
abstract class ProcessorIn implements Built<ProcessorIn, ProcessorInBuilder> {
  /// Address (FR53).
  @BuiltValueField(wireName: r'address')
  Address? get address;

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

  ProcessorIn._();

  factory ProcessorIn([void updates(ProcessorInBuilder b)]) = _$ProcessorIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProcessorInBuilder b) => b..kind = OrgKind.company;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProcessorIn> get serializer => _$ProcessorInSerializer();
}

class _$ProcessorInSerializer implements PrimitiveSerializer<ProcessorIn> {
  @override
  final Iterable<Type> types = const [ProcessorIn, _$ProcessorIn];

  @override
  final String wireName = r'ProcessorIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProcessorIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(Address),
      );
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ProcessorIn object, {
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
    required ProcessorInBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProcessorIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProcessorInBuilder();
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
