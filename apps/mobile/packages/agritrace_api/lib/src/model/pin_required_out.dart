//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pin_required_out.g.dart';

/// The OTP passed for an office role; the PIN step must follow before any session is released.
///
/// Properties:
/// * [expiresIn] - Pin token lifetime in seconds (300).
/// * [kind] - Discriminator: PIN step next.
/// * [pinSet] - False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN.
/// * [pinToken] - Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO.
@BuiltValue()
abstract class PinRequiredOut
    implements Built<PinRequiredOut, PinRequiredOutBuilder> {
  /// Pin token lifetime in seconds (300).
  @BuiltValueField(wireName: r'expires_in')
  int get expiresIn;

  /// Discriminator: PIN step next.
  @BuiltValueField(wireName: r'kind')
  PinRequiredOutKindEnum get kind;
  // enum kindEnum {  pin_required,  };

  /// False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN.
  @BuiltValueField(wireName: r'pin_set')
  bool get pinSet;

  /// Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO.
  @BuiltValueField(wireName: r'pin_token')
  String get pinToken;

  PinRequiredOut._();

  factory PinRequiredOut([void updates(PinRequiredOutBuilder b)]) =
      _$PinRequiredOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PinRequiredOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PinRequiredOut> get serializer =>
      _$PinRequiredOutSerializer();
}

class _$PinRequiredOutSerializer
    implements PrimitiveSerializer<PinRequiredOut> {
  @override
  final Iterable<Type> types = const [PinRequiredOut, _$PinRequiredOut];

  @override
  final String wireName = r'PinRequiredOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PinRequiredOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expires_in';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(int),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PinRequiredOutKindEnum),
    );
    yield r'pin_set';
    yield serializers.serialize(
      object.pinSet,
      specifiedType: const FullType(bool),
    );
    yield r'pin_token';
    yield serializers.serialize(
      object.pinToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PinRequiredOut object, {
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
    required PinRequiredOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PinRequiredOutKindEnum),
          ) as PinRequiredOutKindEnum;
          result.kind = valueDes;
          break;
        case r'pin_set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pinSet = valueDes;
          break;
        case r'pin_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pinToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PinRequiredOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PinRequiredOutBuilder();
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

/// Discriminator: PIN step next.
class PinRequiredOutKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pin_required')
  static const PinRequiredOutKindEnum pinRequired =
      _$pinRequiredOutKindEnum_pinRequired;

  static Serializer<PinRequiredOutKindEnum> get serializer =>
      _$pinRequiredOutKindEnumSerializer;

  const PinRequiredOutKindEnum._(String name) : super(name);

  static BuiltSet<PinRequiredOutKindEnum> get values =>
      _$pinRequiredOutKindEnumValues;
  static PinRequiredOutKindEnum valueOf(String name) =>
      _$pinRequiredOutKindEnumValueOf(name);
}
