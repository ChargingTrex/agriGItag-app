//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/pull_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pull_out.g.dart';

/// One page of changes since the cursor (backend-design.md §3).
///
/// Properties:
/// * [changes] - Changes ordered by change time, then id.
/// * [hasMore] - True when another page is waiting; call again with `next_cursor`.
/// * [nextCursor] - Opaque cursor to send next time; equals the sent cursor when nothing changed.
@BuiltValue()
abstract class PullOut implements Built<PullOut, PullOutBuilder> {
  /// Changes ordered by change time, then id.
  @BuiltValueField(wireName: r'changes')
  BuiltList<PullChange> get changes;

  /// True when another page is waiting; call again with `next_cursor`.
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Opaque cursor to send next time; equals the sent cursor when nothing changed.
  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  PullOut._();

  factory PullOut([void updates(PullOutBuilder b)]) = _$PullOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PullOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PullOut> get serializer => _$PullOutSerializer();
}

class _$PullOutSerializer implements PrimitiveSerializer<PullOut> {
  @override
  final Iterable<Type> types = const [PullOut, _$PullOut];

  @override
  final String wireName = r'PullOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PullOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(BuiltList, [FullType(PullChange)]),
    );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    yield r'next_cursor';
    yield object.nextCursor == null
        ? null
        : serializers.serialize(
            object.nextCursor,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PullOut object, {
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
    required PullOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PullChange)]),
          ) as BuiltList<PullChange>;
          result.changes.replace(valueDes);
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PullOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PullOutBuilder();
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
