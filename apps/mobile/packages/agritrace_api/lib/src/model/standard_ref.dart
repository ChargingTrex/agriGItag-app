//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standard_ref.g.dart';

/// The published standard a profile version cites (FR47, FR51: shown on the public page with edition).
///
/// Properties:
/// * [clauseRef] - Clause cited; `LOAD_FROM_STANDARD` until copied from the standard text.
/// * [edition] - Edition or year cited; `LOAD_FROM_STANDARD` until copied from the text.
/// * [name] - Full name of the standard, e.g. AGMARK Dry Chillies rules.
/// * [schedule] - Schedule or part of the standard, e.g. `IV`.
@BuiltValue()
abstract class StandardRef implements Built<StandardRef, StandardRefBuilder> {
  /// Clause cited; `LOAD_FROM_STANDARD` until copied from the standard text.
  @BuiltValueField(wireName: r'clause_ref')
  String get clauseRef;

  /// Edition or year cited; `LOAD_FROM_STANDARD` until copied from the text.
  @BuiltValueField(wireName: r'edition')
  String get edition;

  /// Full name of the standard, e.g. AGMARK Dry Chillies rules.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Schedule or part of the standard, e.g. `IV`.
  @BuiltValueField(wireName: r'schedule')
  String? get schedule;

  StandardRef._();

  factory StandardRef([void updates(StandardRefBuilder b)]) = _$StandardRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandardRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandardRef> get serializer => _$StandardRefSerializer();
}

class _$StandardRefSerializer implements PrimitiveSerializer<StandardRef> {
  @override
  final Iterable<Type> types = const [StandardRef, _$StandardRef];

  @override
  final String wireName = r'StandardRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandardRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clause_ref';
    yield serializers.serialize(
      object.clauseRef,
      specifiedType: const FullType(String),
    );
    yield r'edition';
    yield serializers.serialize(
      object.edition,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.schedule != null) {
      yield r'schedule';
      yield serializers.serialize(
        object.schedule,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StandardRef object, {
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
    required StandardRefBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clause_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clauseRef = valueDes;
          break;
        case r'edition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.edition = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'schedule':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.schedule = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandardRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandardRefBuilder();
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
