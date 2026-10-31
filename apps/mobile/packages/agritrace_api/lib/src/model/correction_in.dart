//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'correction_in.g.dart';

/// A correction of an event: the same shape as a sync `event_version` entry (FR25).
///
/// Properties:
/// * [clientId] - Client id of the new version (idempotency key, D-005).
/// * [data]
@BuiltValue()
abstract class CorrectionIn
    implements Built<CorrectionIn, CorrectionInBuilder> {
  /// Client id of the new version (idempotency key, D-005).
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  @BuiltValueField(wireName: r'data')
  Data get data;

  CorrectionIn._();

  factory CorrectionIn([void updates(CorrectionInBuilder b)]) = _$CorrectionIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CorrectionInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CorrectionIn> get serializer => _$CorrectionInSerializer();
}

class _$CorrectionInSerializer implements PrimitiveSerializer<CorrectionIn> {
  @override
  final Iterable<Type> types = const [CorrectionIn, _$CorrectionIn];

  @override
  final String wireName = r'CorrectionIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CorrectionIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Data),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CorrectionIn object, {
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
    required CorrectionInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Data),
          ) as Data;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CorrectionIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CorrectionInBuilder();
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
