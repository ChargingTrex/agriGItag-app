//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/reference_part.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reference_out.g.dart';

/// Parts whose version differs from the ones the phone holds (plan §13 C2).
///
/// Properties:
/// * [parts] - Changed or new parts only.
@BuiltValue()
abstract class ReferenceOut
    implements Built<ReferenceOut, ReferenceOutBuilder> {
  /// Changed or new parts only.
  @BuiltValueField(wireName: r'parts')
  BuiltMap<String, ReferencePart> get parts;

  ReferenceOut._();

  factory ReferenceOut([void updates(ReferenceOutBuilder b)]) = _$ReferenceOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReferenceOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReferenceOut> get serializer => _$ReferenceOutSerializer();
}

class _$ReferenceOutSerializer implements PrimitiveSerializer<ReferenceOut> {
  @override
  final Iterable<Type> types = const [ReferenceOut, _$ReferenceOut];

  @override
  final String wireName = r'ReferenceOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReferenceOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'parts';
    yield serializers.serialize(
      object.parts,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(ReferencePart)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReferenceOut object, {
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
    required ReferenceOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'parts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType(ReferencePart)]),
          ) as BuiltMap<String, ReferencePart>;
          result.parts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReferenceOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReferenceOutBuilder();
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
