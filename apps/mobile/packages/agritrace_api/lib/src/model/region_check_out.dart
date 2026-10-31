//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'region_check_out.g.dart';

/// Result of the automatic GI region check run on create or correct (FR67).
///
/// Properties:
/// * [bufferM] - Tolerance buffer of that version, in metres (FR32).
/// * [distanceM] - Metres from the outline; 0 inside.
/// * [regionVersionId] - Region version checked against.
/// * [status] - Where the pin lies.
@BuiltValue()
abstract class RegionCheckOut
    implements Built<RegionCheckOut, RegionCheckOutBuilder> {
  /// Tolerance buffer of that version, in metres (FR32).
  @BuiltValueField(wireName: r'buffer_m')
  String get bufferM;

  /// Metres from the outline; 0 inside.
  @BuiltValueField(wireName: r'distance_m')
  num get distanceM;

  /// Region version checked against.
  @BuiltValueField(wireName: r'region_version_id')
  String get regionVersionId;

  /// Where the pin lies.
  @BuiltValueField(wireName: r'status')
  RegionCheckOutStatusEnum get status;
  // enum statusEnum {  inside,  near_edge,  outside,  };

  RegionCheckOut._();

  factory RegionCheckOut([void updates(RegionCheckOutBuilder b)]) =
      _$RegionCheckOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegionCheckOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegionCheckOut> get serializer =>
      _$RegionCheckOutSerializer();
}

class _$RegionCheckOutSerializer
    implements PrimitiveSerializer<RegionCheckOut> {
  @override
  final Iterable<Type> types = const [RegionCheckOut, _$RegionCheckOut];

  @override
  final String wireName = r'RegionCheckOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegionCheckOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'buffer_m';
    yield serializers.serialize(
      object.bufferM,
      specifiedType: const FullType(String),
    );
    yield r'distance_m';
    yield serializers.serialize(
      object.distanceM,
      specifiedType: const FullType(num),
    );
    yield r'region_version_id';
    yield serializers.serialize(
      object.regionVersionId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RegionCheckOutStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegionCheckOut object, {
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
    required RegionCheckOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'buffer_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bufferM = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceM = valueDes;
          break;
        case r'region_version_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.regionVersionId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegionCheckOutStatusEnum),
          ) as RegionCheckOutStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegionCheckOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegionCheckOutBuilder();
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

/// Where the pin lies.
class RegionCheckOutStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'inside')
  static const RegionCheckOutStatusEnum inside =
      _$regionCheckOutStatusEnum_inside;
  @BuiltValueEnumConst(wireName: r'near_edge')
  static const RegionCheckOutStatusEnum nearEdge =
      _$regionCheckOutStatusEnum_nearEdge;
  @BuiltValueEnumConst(wireName: r'outside')
  static const RegionCheckOutStatusEnum outside =
      _$regionCheckOutStatusEnum_outside;

  static Serializer<RegionCheckOutStatusEnum> get serializer =>
      _$regionCheckOutStatusEnumSerializer;

  const RegionCheckOutStatusEnum._(String name) : super(name);

  static BuiltSet<RegionCheckOutStatusEnum> get values =>
      _$regionCheckOutStatusEnumValues;
  static RegionCheckOutStatusEnum valueOf(String name) =>
      _$regionCheckOutStatusEnumValueOf(name);
}
