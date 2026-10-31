//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/practice_tag.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'practice_tags.g.dart';

/// Farming practice tags of a lot: what the farmer declared versus what the inputs used imply (FR56).
///
/// Properties:
/// * [contradiction] - True when a declared tag conflicts with the derived ones (raises a flag).
/// * [declared] - Tags the farmer declared.
/// * [derived] - Tags derived from the categories of inputs actually applied.
@BuiltValue()
abstract class PracticeTags
    implements Built<PracticeTags, PracticeTagsBuilder> {
  /// True when a declared tag conflicts with the derived ones (raises a flag).
  @BuiltValueField(wireName: r'contradiction')
  bool? get contradiction;

  /// Tags the farmer declared.
  @BuiltValueField(wireName: r'declared')
  BuiltList<PracticeTag>? get declared;

  /// Tags derived from the categories of inputs actually applied.
  @BuiltValueField(wireName: r'derived')
  BuiltList<PracticeTag>? get derived;

  PracticeTags._();

  factory PracticeTags([void updates(PracticeTagsBuilder b)]) = _$PracticeTags;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PracticeTagsBuilder b) => b..contradiction = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<PracticeTags> get serializer => _$PracticeTagsSerializer();
}

class _$PracticeTagsSerializer implements PrimitiveSerializer<PracticeTags> {
  @override
  final Iterable<Type> types = const [PracticeTags, _$PracticeTags];

  @override
  final String wireName = r'PracticeTags';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PracticeTags object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.contradiction != null) {
      yield r'contradiction';
      yield serializers.serialize(
        object.contradiction,
        specifiedType: const FullType(bool),
      );
    }
    if (object.declared != null) {
      yield r'declared';
      yield serializers.serialize(
        object.declared,
        specifiedType: const FullType(BuiltList, [FullType(PracticeTag)]),
      );
    }
    if (object.derived != null) {
      yield r'derived';
      yield serializers.serialize(
        object.derived,
        specifiedType: const FullType(BuiltList, [FullType(PracticeTag)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PracticeTags object, {
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
    required PracticeTagsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contradiction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.contradiction = valueDes;
          break;
        case r'declared':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(PracticeTag)]),
          ) as BuiltList<PracticeTag>?;
          if (valueDes == null) continue;
          result.declared.replace(valueDes);
          break;
        case r'derived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(PracticeTag)]),
          ) as BuiltList<PracticeTag>?;
          if (valueDes == null) continue;
          result.derived.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PracticeTags deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PracticeTagsBuilder();
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
