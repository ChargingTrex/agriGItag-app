//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/date.dart';
import 'package:agritrace_api/src/model/quantity_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'land_preparation_payload.g.dart';

/// Stage 1 land preparation: cultivated area and the last ploughing date.
///
/// Properties:
/// * [cultivatedArea] - Area prepared, unit `acre` (flagged when above the plot's declared size).
/// * [lastPloughedOn] - Last date of ploughing, YYYY-MM-DD.
@BuiltValue()
abstract class LandPreparationPayload
    implements Built<LandPreparationPayload, LandPreparationPayloadBuilder> {
  /// Area prepared, unit `acre` (flagged when above the plot's declared size).
  @BuiltValueField(wireName: r'cultivated_area')
  QuantityInput? get cultivatedArea;

  /// Last date of ploughing, YYYY-MM-DD.
  @BuiltValueField(wireName: r'last_ploughed_on')
  Date? get lastPloughedOn;

  LandPreparationPayload._();

  factory LandPreparationPayload(
          [void updates(LandPreparationPayloadBuilder b)]) =
      _$LandPreparationPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LandPreparationPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LandPreparationPayload> get serializer =>
      _$LandPreparationPayloadSerializer();
}

class _$LandPreparationPayloadSerializer
    implements PrimitiveSerializer<LandPreparationPayload> {
  @override
  final Iterable<Type> types = const [
    LandPreparationPayload,
    _$LandPreparationPayload
  ];

  @override
  final String wireName = r'LandPreparationPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LandPreparationPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cultivatedArea != null) {
      yield r'cultivated_area';
      yield serializers.serialize(
        object.cultivatedArea,
        specifiedType: const FullType.nullable(QuantityInput),
      );
    }
    if (object.lastPloughedOn != null) {
      yield r'last_ploughed_on';
      yield serializers.serialize(
        object.lastPloughedOn,
        specifiedType: const FullType.nullable(Date),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LandPreparationPayload object, {
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
    required LandPreparationPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cultivated_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(QuantityInput),
          ) as QuantityInput?;
          if (valueDes == null) continue;
          result.cultivatedArea.replace(valueDes);
          break;
        case r'last_ploughed_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.lastPloughedOn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LandPreparationPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LandPreparationPayloadBuilder();
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
