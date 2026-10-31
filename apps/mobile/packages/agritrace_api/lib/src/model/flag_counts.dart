//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_counts.g.dart';

/// Active (open or escalated) flags of the FPO by severity.
///
/// Properties:
/// * [hold] - Active `hold` flags; each blocks GI labelling (count).
/// * [info] - Active `info` flags (count).
/// * [warn] - Active `warn` flags (count).
@BuiltValue()
abstract class FlagCounts implements Built<FlagCounts, FlagCountsBuilder> {
  /// Active `hold` flags; each blocks GI labelling (count).
  @BuiltValueField(wireName: r'hold')
  int get hold;

  /// Active `info` flags (count).
  @BuiltValueField(wireName: r'info')
  int get info;

  /// Active `warn` flags (count).
  @BuiltValueField(wireName: r'warn')
  int get warn;

  FlagCounts._();

  factory FlagCounts([void updates(FlagCountsBuilder b)]) = _$FlagCounts;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagCountsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagCounts> get serializer => _$FlagCountsSerializer();
}

class _$FlagCountsSerializer implements PrimitiveSerializer<FlagCounts> {
  @override
  final Iterable<Type> types = const [FlagCounts, _$FlagCounts];

  @override
  final String wireName = r'FlagCounts';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagCounts object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'hold';
    yield serializers.serialize(
      object.hold,
      specifiedType: const FullType(int),
    );
    yield r'info';
    yield serializers.serialize(
      object.info,
      specifiedType: const FullType(int),
    );
    yield r'warn';
    yield serializers.serialize(
      object.warn,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagCounts object, {
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
    required FlagCountsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'hold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hold = valueDes;
          break;
        case r'info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.info = valueDes;
          break;
        case r'warn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.warn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagCounts deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagCountsBuilder();
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
