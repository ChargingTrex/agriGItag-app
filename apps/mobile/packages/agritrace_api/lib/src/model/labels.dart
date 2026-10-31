//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'labels.g.dart';

/// Field label in each app language (FR5).
///
/// Properties:
/// * [en] - English label.
/// * [ta] - Tamil label.
@BuiltValue()
abstract class Labels implements Built<Labels, LabelsBuilder> {
  /// English label.
  @BuiltValueField(wireName: r'en')
  String get en;

  /// Tamil label.
  @BuiltValueField(wireName: r'ta')
  String get ta;

  Labels._();

  factory Labels([void updates(LabelsBuilder b)]) = _$Labels;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LabelsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Labels> get serializer => _$LabelsSerializer();
}

class _$LabelsSerializer implements PrimitiveSerializer<Labels> {
  @override
  final Iterable<Type> types = const [Labels, _$Labels];

  @override
  final String wireName = r'Labels';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Labels object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'en';
    yield serializers.serialize(
      object.en,
      specifiedType: const FullType(String),
    );
    yield r'ta';
    yield serializers.serialize(
      object.ta,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Labels object, {
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
    required LabelsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.en = valueDes;
          break;
        case r'ta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ta = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Labels deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LabelsBuilder();
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
