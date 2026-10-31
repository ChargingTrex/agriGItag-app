//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'address.g.dart';

/// Structured address of a farmer, plot, FPO or processor (FR53); also a second GI check by taluk.  Every part is optional here: which parts are required is field configuration (D-017, B13).
///
/// Properties:
/// * [block] - Development block.
/// * [district] - District, e.g. `Virudhunagar`.
/// * [pin] - Six-digit Indian PIN code.
/// * [state] - State, e.g. `Tamil Nadu`.
/// * [taluk] - Taluk (sub-district); second GI check against registered taluks (FR53).
/// * [village] - Village or hamlet name.
@BuiltValue()
abstract class Address implements Built<Address, AddressBuilder> {
  /// Development block.
  @BuiltValueField(wireName: r'block')
  String? get block;

  /// District, e.g. `Virudhunagar`.
  @BuiltValueField(wireName: r'district')
  String? get district;

  /// Six-digit Indian PIN code.
  @BuiltValueField(wireName: r'pin')
  String? get pin;

  /// State, e.g. `Tamil Nadu`.
  @BuiltValueField(wireName: r'state')
  String? get state;

  /// Taluk (sub-district); second GI check against registered taluks (FR53).
  @BuiltValueField(wireName: r'taluk')
  String? get taluk;

  /// Village or hamlet name.
  @BuiltValueField(wireName: r'village')
  String? get village;

  Address._();

  factory Address([void updates(AddressBuilder b)]) = _$Address;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Address> get serializer => _$AddressSerializer();
}

class _$AddressSerializer implements PrimitiveSerializer<Address> {
  @override
  final Iterable<Type> types = const [Address, _$Address];

  @override
  final String wireName = r'Address';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Address object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.block != null) {
      yield r'block';
      yield serializers.serialize(
        object.block,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.district != null) {
      yield r'district';
      yield serializers.serialize(
        object.district,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.state != null) {
      yield r'state';
      yield serializers.serialize(
        object.state,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.taluk != null) {
      yield r'taluk';
      yield serializers.serialize(
        object.taluk,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.village != null) {
      yield r'village';
      yield serializers.serialize(
        object.village,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Address object, {
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
    required AddressBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.district = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pin = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'village':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.village = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Address deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddressBuilder();
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
