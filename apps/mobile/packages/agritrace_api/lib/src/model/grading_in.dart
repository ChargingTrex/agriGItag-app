//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/quality_reading_in.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'grading_in.g.dart';

/// Grade a batch: the declared grade plus the readings to use (Dataflow Stage 8, FR48, FR49).
///
/// Properties:
/// * [declaredGrade] - Grade the QC officer declares.
/// * [readingIds] - Readings of this batch to use; omitted: every reading of the batch.
/// * [readings] - Readings to record first, then used too; their subject is forced to this batch.
@BuiltValue()
abstract class GradingIn implements Built<GradingIn, GradingInBuilder> {
  /// Grade the QC officer declares.
  @BuiltValueField(wireName: r'declared_grade')
  String get declaredGrade;

  /// Readings of this batch to use; omitted: every reading of the batch.
  @BuiltValueField(wireName: r'reading_ids')
  BuiltList<String>? get readingIds;

  /// Readings to record first, then used too; their subject is forced to this batch.
  @BuiltValueField(wireName: r'readings')
  BuiltList<QualityReadingIn>? get readings;

  GradingIn._();

  factory GradingIn([void updates(GradingInBuilder b)]) = _$GradingIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GradingInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GradingIn> get serializer => _$GradingInSerializer();
}

class _$GradingInSerializer implements PrimitiveSerializer<GradingIn> {
  @override
  final Iterable<Type> types = const [GradingIn, _$GradingIn];

  @override
  final String wireName = r'GradingIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GradingIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'declared_grade';
    yield serializers.serialize(
      object.declaredGrade,
      specifiedType: const FullType(String),
    );
    if (object.readingIds != null) {
      yield r'reading_ids';
      yield serializers.serialize(
        object.readingIds,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.readings != null) {
      yield r'readings';
      yield serializers.serialize(
        object.readings,
        specifiedType: const FullType(BuiltList, [FullType(QualityReadingIn)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GradingIn object, {
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
    required GradingInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'declared_grade':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.declaredGrade = valueDes;
          break;
        case r'reading_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.readingIds.replace(valueDes);
          break;
        case r'readings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(QualityReadingIn)]),
          ) as BuiltList<QualityReadingIn>?;
          if (valueDes == null) continue;
          result.readings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GradingIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GradingInBuilder();
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
