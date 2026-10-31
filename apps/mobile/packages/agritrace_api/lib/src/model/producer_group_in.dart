//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/producer_group_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'producer_group_in.g.dart';

/// A new producer group (SHG) in the caller's FPO (flag `producer_groups`).
///
/// Properties:
/// * [kind] - shg or other.
/// * [name] - Group name.
@BuiltValue()
abstract class ProducerGroupIn
    implements Built<ProducerGroupIn, ProducerGroupInBuilder> {
  /// shg or other.
  @BuiltValueField(wireName: r'kind')
  ProducerGroupKind? get kind;
  // enum kindEnum {  shg,  other,  };

  /// Group name.
  @BuiltValueField(wireName: r'name')
  String get name;

  ProducerGroupIn._();

  factory ProducerGroupIn([void updates(ProducerGroupInBuilder b)]) =
      _$ProducerGroupIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProducerGroupInBuilder b) =>
      b..kind = ProducerGroupKind.shg;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProducerGroupIn> get serializer =>
      _$ProducerGroupInSerializer();
}

class _$ProducerGroupInSerializer
    implements PrimitiveSerializer<ProducerGroupIn> {
  @override
  final Iterable<Type> types = const [ProducerGroupIn, _$ProducerGroupIn];

  @override
  final String wireName = r'ProducerGroupIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProducerGroupIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(ProducerGroupKind),
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
    ProducerGroupIn object, {
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
    required ProducerGroupInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProducerGroupKind),
          ) as ProducerGroupKind?;
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
  ProducerGroupIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProducerGroupInBuilder();
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
