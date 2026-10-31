//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assist_end_in.g.dart';

/// Close an assist session.
///
/// Properties:
/// * [assistSessionId] - The session to end (its client id).
@BuiltValue()
abstract class AssistEndIn implements Built<AssistEndIn, AssistEndInBuilder> {
  /// The session to end (its client id).
  @BuiltValueField(wireName: r'assist_session_id')
  String get assistSessionId;

  AssistEndIn._();

  factory AssistEndIn([void updates(AssistEndInBuilder b)]) = _$AssistEndIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssistEndInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssistEndIn> get serializer => _$AssistEndInSerializer();
}

class _$AssistEndInSerializer implements PrimitiveSerializer<AssistEndIn> {
  @override
  final Iterable<Type> types = const [AssistEndIn, _$AssistEndIn];

  @override
  final String wireName = r'AssistEndIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssistEndIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'assist_session_id';
    yield serializers.serialize(
      object.assistSessionId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AssistEndIn object, {
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
    required AssistEndInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assist_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assistSessionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssistEndIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssistEndInBuilder();
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
