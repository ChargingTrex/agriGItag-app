//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pull_change.g.dart';

/// One server-side change for the phone's local copy.
///
/// Properties:
/// * [data] - The record, lean; decimals are strings, times ISO 8601 UTC.
/// * [entity] - Kind of record in `data`.
/// * [op] - Always `upsert`: replace the local row with the same `id`.
@BuiltValue()
abstract class PullChange implements Built<PullChange, PullChangeBuilder> {
  /// The record, lean; decimals are strings, times ISO 8601 UTC.
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  /// Kind of record in `data`.
  @BuiltValueField(wireName: r'entity')
  PullChangeEntityEnum get entity;
  // enum entityEnum {  flag,  lot,  event,  intake,  notification,  photo_pending,  };

  /// Always `upsert`: replace the local row with the same `id`.
  @BuiltValueField(wireName: r'op')
  PullChangeOpEnum get op;
  // enum opEnum {  upsert,  };

  PullChange._();

  factory PullChange([void updates(PullChangeBuilder b)]) = _$PullChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PullChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PullChange> get serializer => _$PullChangeSerializer();
}

class _$PullChangeSerializer implements PrimitiveSerializer<PullChange> {
  @override
  final Iterable<Type> types = const [PullChange, _$PullChange];

  @override
  final String wireName = r'PullChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PullChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'entity';
    yield serializers.serialize(
      object.entity,
      specifiedType: const FullType(PullChangeEntityEnum),
    );
    yield r'op';
    yield serializers.serialize(
      object.op,
      specifiedType: const FullType(PullChangeOpEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PullChange object, {
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
    required PullChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.data.replace(valueDes);
          break;
        case r'entity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PullChangeEntityEnum),
          ) as PullChangeEntityEnum;
          result.entity = valueDes;
          break;
        case r'op':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PullChangeOpEnum),
          ) as PullChangeOpEnum;
          result.op = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PullChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PullChangeBuilder();
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

/// Kind of record in `data`.
class PullChangeEntityEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'flag')
  static const PullChangeEntityEnum flag = _$pullChangeEntityEnum_flag;
  @BuiltValueEnumConst(wireName: r'lot')
  static const PullChangeEntityEnum lot = _$pullChangeEntityEnum_lot;
  @BuiltValueEnumConst(wireName: r'event')
  static const PullChangeEntityEnum event = _$pullChangeEntityEnum_event;
  @BuiltValueEnumConst(wireName: r'intake')
  static const PullChangeEntityEnum intake = _$pullChangeEntityEnum_intake;
  @BuiltValueEnumConst(wireName: r'notification')
  static const PullChangeEntityEnum notification =
      _$pullChangeEntityEnum_notification;
  @BuiltValueEnumConst(wireName: r'photo_pending')
  static const PullChangeEntityEnum photoPending =
      _$pullChangeEntityEnum_photoPending;

  static Serializer<PullChangeEntityEnum> get serializer =>
      _$pullChangeEntityEnumSerializer;

  const PullChangeEntityEnum._(String name) : super(name);

  static BuiltSet<PullChangeEntityEnum> get values =>
      _$pullChangeEntityEnumValues;
  static PullChangeEntityEnum valueOf(String name) =>
      _$pullChangeEntityEnumValueOf(name);
}

/// Always `upsert`: replace the local row with the same `id`.
class PullChangeOpEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const PullChangeOpEnum upsert = _$pullChangeOpEnum_upsert;

  static Serializer<PullChangeOpEnum> get serializer =>
      _$pullChangeOpEnumSerializer;

  const PullChangeOpEnum._(String name) : super(name);

  static BuiltSet<PullChangeOpEnum> get values => _$pullChangeOpEnumValues;
  static PullChangeOpEnum valueOf(String name) =>
      _$pullChangeOpEnumValueOf(name);
}
