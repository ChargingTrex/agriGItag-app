//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/three_clocks.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'undo_in.g.dart';

/// A farmer's undo of an own entry within 24 hours (FR6, FR25).
///
/// Properties:
/// * [clientId] - Client id of the undo version (idempotency key, D-005).
/// * [clocks] - Phone clocks at the undo; omitted means server now.
/// * [reasonCode] - Coded reason, e.g. `entered_by_mistake`.
/// * [reasonText] - Free-text comment.
/// * [versionNo] - Current max version + 1.
@BuiltValue()
abstract class UndoIn implements Built<UndoIn, UndoInBuilder> {
  /// Client id of the undo version (idempotency key, D-005).
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Phone clocks at the undo; omitted means server now.
  @BuiltValueField(wireName: r'clocks')
  ThreeClocks? get clocks;

  /// Coded reason, e.g. `entered_by_mistake`.
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// Free-text comment.
  @BuiltValueField(wireName: r'reason_text')
  String? get reasonText;

  /// Current max version + 1.
  @BuiltValueField(wireName: r'version_no')
  int get versionNo;

  UndoIn._();

  factory UndoIn([void updates(UndoInBuilder b)]) = _$UndoIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UndoInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UndoIn> get serializer => _$UndoInSerializer();
}

class _$UndoInSerializer implements PrimitiveSerializer<UndoIn> {
  @override
  final Iterable<Type> types = const [UndoIn, _$UndoIn];

  @override
  final String wireName = r'UndoIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UndoIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.clocks != null) {
      yield r'clocks';
      yield serializers.serialize(
        object.clocks,
        specifiedType: const FullType.nullable(ThreeClocks),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonText != null) {
      yield r'reason_text';
      yield serializers.serialize(
        object.reasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'version_no';
    yield serializers.serialize(
      object.versionNo,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UndoIn object, {
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
    required UndoInBuilder result,
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
        case r'clocks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ThreeClocks),
          ) as ThreeClocks?;
          if (valueDes == null) continue;
          result.clocks.replace(valueDes);
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonText = valueDes;
          break;
        case r'version_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.versionNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UndoIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UndoInBuilder();
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
