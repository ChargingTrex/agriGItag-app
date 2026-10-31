//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stage_tile.g.dart';

/// Lot counts for one farm stage (D-037); done + in_progress + not_started = lots in scope.
///
/// Properties:
/// * [done] - Lots with this stage recorded and a later stage reached (count).
/// * [inProgress] - Lots whose furthest recorded stage is this one while the lot is still in the field.
/// * [notStarted] - Lots with no live event of this stage (count).
/// * [stage] - Event type of the stage, e.g. `land_preparation`, `harvest`.
@BuiltValue()
abstract class StageTile implements Built<StageTile, StageTileBuilder> {
  /// Lots with this stage recorded and a later stage reached (count).
  @BuiltValueField(wireName: r'done')
  int get done;

  /// Lots whose furthest recorded stage is this one while the lot is still in the field.
  @BuiltValueField(wireName: r'in_progress')
  int get inProgress;

  /// Lots with no live event of this stage (count).
  @BuiltValueField(wireName: r'not_started')
  int get notStarted;

  /// Event type of the stage, e.g. `land_preparation`, `harvest`.
  @BuiltValueField(wireName: r'stage')
  String get stage;

  StageTile._();

  factory StageTile([void updates(StageTileBuilder b)]) = _$StageTile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StageTileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StageTile> get serializer => _$StageTileSerializer();
}

class _$StageTileSerializer implements PrimitiveSerializer<StageTile> {
  @override
  final Iterable<Type> types = const [StageTile, _$StageTile];

  @override
  final String wireName = r'StageTile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StageTile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'done';
    yield serializers.serialize(
      object.done,
      specifiedType: const FullType(int),
    );
    yield r'in_progress';
    yield serializers.serialize(
      object.inProgress,
      specifiedType: const FullType(int),
    );
    yield r'not_started';
    yield serializers.serialize(
      object.notStarted,
      specifiedType: const FullType(int),
    );
    yield r'stage';
    yield serializers.serialize(
      object.stage,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StageTile object, {
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
    required StageTileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'done':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.done = valueDes;
          break;
        case r'in_progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.inProgress = valueDes;
          break;
        case r'not_started':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.notStarted = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  StageTile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StageTileBuilder();
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
