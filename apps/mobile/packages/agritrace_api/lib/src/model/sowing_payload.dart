//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sowing_payload.g.dart';

/// Stage 2 sowing or transplanting in the main field, one entry per instance (FR3, FR55).
///
/// Properties:
/// * [method] - Direct seeding, or transplanting nursery seedlings.
/// * [seedVariety] - Seed variety sown or transplanted.
/// * [sownArea] - Area sown, unit `acre`.
@BuiltValue()
abstract class SowingPayload
    implements Built<SowingPayload, SowingPayloadBuilder> {
  /// Direct seeding, or transplanting nursery seedlings.
  @BuiltValueField(wireName: r'method')
  SowingPayloadMethodEnum? get method;
  // enum methodEnum {  direct_seeding,  transplanting,  };

  /// Seed variety sown or transplanted.
  @BuiltValueField(wireName: r'seed_variety')
  String? get seedVariety;

  /// Area sown, unit `acre`.
  @BuiltValueField(wireName: r'sown_area')
  QuantityInput? get sownArea;

  SowingPayload._();

  factory SowingPayload([void updates(SowingPayloadBuilder b)]) =
      _$SowingPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SowingPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SowingPayload> get serializer =>
      _$SowingPayloadSerializer();
}

class _$SowingPayloadSerializer implements PrimitiveSerializer<SowingPayload> {
  @override
  final Iterable<Type> types = const [SowingPayload, _$SowingPayload];

  @override
  final String wireName = r'SowingPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SowingPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.method != null) {
      yield r'method';
      yield serializers.serialize(
        object.method,
        specifiedType: const FullType.nullable(SowingPayloadMethodEnum),
      );
    }
    if (object.seedVariety != null) {
      yield r'seed_variety';
      yield serializers.serialize(
        object.seedVariety,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sownArea != null) {
      yield r'sown_area';
      yield serializers.serialize(
        object.sownArea,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SowingPayload object, {
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
    required SowingPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SowingPayloadMethodEnum),
          ) as SowingPayloadMethodEnum?;
          if (valueDes == null) continue;
          result.method = valueDes;
          break;
        case r'seed_variety':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.seedVariety = valueDes;
          break;
        case r'sown_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.sownArea.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SowingPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SowingPayloadBuilder();
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

/// Direct seeding, or transplanting nursery seedlings.
class SowingPayloadMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'direct_seeding')
  static const SowingPayloadMethodEnum directSeeding =
      _$sowingPayloadMethodEnum_directSeeding;
  @BuiltValueEnumConst(wireName: r'transplanting')
  static const SowingPayloadMethodEnum transplanting =
      _$sowingPayloadMethodEnum_transplanting;

  static Serializer<SowingPayloadMethodEnum> get serializer =>
      _$sowingPayloadMethodEnumSerializer;

  const SowingPayloadMethodEnum._(String name) : super(name);

  static BuiltSet<SowingPayloadMethodEnum> get values =>
      _$sowingPayloadMethodEnumValues;
  static SowingPayloadMethodEnum valueOf(String name) =>
      _$sowingPayloadMethodEnumValueOf(name);
}
