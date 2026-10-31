//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/producer_group_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'producer_group_out.g.dart';

/// A producer group.
///
/// Properties:
/// * [fpoId] - Owning FPO.
/// * [id] - Group id.
/// * [kind] - shg or other.
/// * [name] - Group name.
@BuiltValue()
abstract class ProducerGroupOut
    implements Built<ProducerGroupOut, ProducerGroupOutBuilder> {
  /// Owning FPO.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Group id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// shg or other.
  @BuiltValueField(wireName: r'kind')
  ProducerGroupKind get kind;
  // enum kindEnum {  shg,  other,  };

  /// Group name.
  @BuiltValueField(wireName: r'name')
  String get name;

  ProducerGroupOut._();

  factory ProducerGroupOut([void updates(ProducerGroupOutBuilder b)]) =
      _$ProducerGroupOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProducerGroupOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProducerGroupOut> get serializer =>
      _$ProducerGroupOutSerializer();
}

class _$ProducerGroupOutSerializer
    implements PrimitiveSerializer<ProducerGroupOut> {
  @override
  final Iterable<Type> types = const [ProducerGroupOut, _$ProducerGroupOut];

  @override
  final String wireName = r'ProducerGroupOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProducerGroupOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ProducerGroupKind),
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
    ProducerGroupOut object, {
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
    required ProducerGroupOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
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
            specifiedType: const FullType(ProducerGroupKind),
          ) as ProducerGroupKind;
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
  ProducerGroupOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProducerGroupOutBuilder();
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
