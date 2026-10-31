//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lot_gate_output.g.dart';

/// A reading condition a lot must meet before a lifecycle step, e.g. ready for sale (Dataflow Stage 5).
///
/// Properties:
/// * [max] - Highest passing value, inclusive, e.g. moisture ≤ 11 %.
/// * [min] - Lowest passing value, inclusive.
/// * [parameter] - Parameter code checked.
/// * [stage] - Stage whose latest reading is checked.
@BuiltValue()
abstract class LotGateOutput
    implements Built<LotGateOutput, LotGateOutputBuilder> {
  /// Highest passing value, inclusive, e.g. moisture ≤ 11 %.
  @BuiltValueField(wireName: r'max')
  num? get max;

  /// Lowest passing value, inclusive.
  @BuiltValueField(wireName: r'min')
  num? get min;

  /// Parameter code checked.
  @BuiltValueField(wireName: r'parameter')
  String get parameter;

  /// Stage whose latest reading is checked.
  @BuiltValueField(wireName: r'stage')
  ReadingStage get stage;
  // enum stageEnum {  drying_end,  intake,  grading,  storage,  };

  LotGateOutput._();

  factory LotGateOutput([void updates(LotGateOutputBuilder b)]) =
      _$LotGateOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LotGateOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LotGateOutput> get serializer =>
      _$LotGateOutputSerializer();
}

class _$LotGateOutputSerializer implements PrimitiveSerializer<LotGateOutput> {
  @override
  final Iterable<Type> types = const [LotGateOutput, _$LotGateOutput];

  @override
  final String wireName = r'LotGateOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LotGateOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.min != null) {
      yield r'min';
      yield serializers.serialize(
        object.min,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'parameter';
    yield serializers.serialize(
      object.parameter,
      specifiedType: const FullType(String),
    );
    yield r'stage';
    yield serializers.serialize(
      object.stage,
      specifiedType: const FullType(ReadingStage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LotGateOutput object, {
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
    required LotGateOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.max = valueDes;
          break;
        case r'min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.min = valueDes;
          break;
        case r'parameter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.parameter = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadingStage),
          ) as ReadingStage;
          result.stage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LotGateOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LotGateOutputBuilder();
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
