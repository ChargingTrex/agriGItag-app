//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quantity_output.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'completeness.g.dart';

/// Share of lots that have every mandatory event of their crop (D-037).
///
/// Properties:
/// * [complete] - complete_lots ÷ lots, unit `%`, one decimal; null when there are no lots.
/// * [completeLots] - Lots with a live event of every type in `event_schema.mandatory`.
/// * [lots] - Lots in scope (count).
@BuiltValue()
abstract class Completeness
    implements Built<Completeness, CompletenessBuilder> {
  /// complete_lots ÷ lots, unit `%`, one decimal; null when there are no lots.
  @BuiltValueField(wireName: r'complete')
  QuantityOutput? get complete;

  /// Lots with a live event of every type in `event_schema.mandatory`.
  @BuiltValueField(wireName: r'complete_lots')
  int get completeLots;

  /// Lots in scope (count).
  @BuiltValueField(wireName: r'lots')
  int get lots;

  Completeness._();

  factory Completeness([void updates(CompletenessBuilder b)]) = _$Completeness;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompletenessBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Completeness> get serializer => _$CompletenessSerializer();
}

class _$CompletenessSerializer implements PrimitiveSerializer<Completeness> {
  @override
  final Iterable<Type> types = const [Completeness, _$Completeness];

  @override
  final String wireName = r'Completeness';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Completeness object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'complete';
    yield object.complete == null
        ? null
        : serializers.serialize(
            object.complete,
            specifiedType: const FullType.nullable(QuantityOutput),
          );
    yield r'complete_lots';
    yield serializers.serialize(
      object.completeLots,
      specifiedType: const FullType(int),
    );
    yield r'lots';
    yield serializers.serialize(
      object.lots,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Completeness object, {
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
    required CompletenessBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'complete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityOutput),
          ) as QuantityOutput?;
          if (valueDes == null) continue;
          result.complete.replace(valueDes);
          break;
        case r'complete_lots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completeLots = valueDes;
          break;
        case r'lots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lots = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Completeness deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompletenessBuilder();
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
