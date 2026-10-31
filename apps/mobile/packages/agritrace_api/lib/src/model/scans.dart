//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'scans.g.dart';

/// Public page scans of the FPO's batch codes (FR20).
///
/// Properties:
/// * [last7Days] - Scans in the last 7 days (count).
/// * [total] - All scans (count).
@BuiltValue()
abstract class Scans implements Built<Scans, ScansBuilder> {
  /// Scans in the last 7 days (count).
  @BuiltValueField(wireName: r'last_7_days')
  int get last7Days;

  /// All scans (count).
  @BuiltValueField(wireName: r'total')
  int get total;

  Scans._();

  factory Scans([void updates(ScansBuilder b)]) = _$Scans;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScansBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Scans> get serializer => _$ScansSerializer();
}

class _$ScansSerializer implements PrimitiveSerializer<Scans> {
  @override
  final Iterable<Type> types = const [Scans, _$Scans];

  @override
  final String wireName = r'Scans';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Scans object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'last_7_days';
    yield serializers.serialize(
      object.last7Days,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Scans object, {
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
    required ScansBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'last_7_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.last7Days = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Scans deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScansBuilder();
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
