//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/max.dart';
import 'package:agritrace_api/src/model/min.dart';
import 'package:agritrace_api/src/model/reading_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lot_gate_input.g.dart';

/// A reading condition a lot must meet before a lifecycle step, e.g. ready for sale (Dataflow Stage 5).
///
/// Properties:
/// * [max]
/// * [min]
/// * [parameter] - Parameter code checked.
/// * [stage] - Stage whose latest reading is checked.
@BuiltValue()
abstract class LotGateInput
    implements Built<LotGateInput, LotGateInputBuilder> {
  @BuiltValueField(wireName: r'max')
  Max? get max;

  @BuiltValueField(wireName: r'min')
  Min? get min;

  /// Parameter code checked.
  @BuiltValueField(wireName: r'parameter')
  String get parameter;

  /// Stage whose latest reading is checked.
  @BuiltValueField(wireName: r'stage')
  ReadingStage get stage;
  // enum stageEnum {  drying_end,  intake,  grading,  storage,  };

  LotGateInput._();

  factory LotGateInput([void updates(LotGateInputBuilder b)]) = _$LotGateInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LotGateInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LotGateInput> get serializer => _$LotGateInputSerializer();
}

class _$LotGateInputSerializer implements PrimitiveSerializer<LotGateInput> {
  @override
  final Iterable<Type> types = const [LotGateInput, _$LotGateInput];

  @override
  final String wireName = r'LotGateInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LotGateInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType.nullable(Max),
      );
    }
    if (object.min != null) {
      yield r'min';
      yield serializers.serialize(
        object.min,
        specifiedType: const FullType.nullable(Min),
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
    LotGateInput object, {
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
    required LotGateInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Max),
          ) as Max?;
          if (valueDes == null) continue;
          result.max.replace(valueDes);
          break;
        case r'min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Min),
          ) as Min?;
          if (valueDes == null) continue;
          result.min.replace(valueDes);
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
  LotGateInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LotGateInputBuilder();
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
