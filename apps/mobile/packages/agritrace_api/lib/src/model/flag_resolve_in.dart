//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_resolve_in.g.dart';

/// A reviewer's outcome for one flag (FR70).
///
/// Properties:
/// * [note] - Free text: method, evidence, what changed.
/// * [reasonCode] - Coded reason, e.g. `land_record_checked`, `field_visit`; required (else 422).
/// * [resolution] - looks_fine → cleared; fixed → fixed; escalated → escalated and reassigned to fpo_admin.
@BuiltValue()
abstract class FlagResolveIn
    implements Built<FlagResolveIn, FlagResolveInBuilder> {
  /// Free text: method, evidence, what changed.
  @BuiltValueField(wireName: r'note')
  String? get note;

  /// Coded reason, e.g. `land_record_checked`, `field_visit`; required (else 422).
  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  /// looks_fine → cleared; fixed → fixed; escalated → escalated and reassigned to fpo_admin.
  @BuiltValueField(wireName: r'resolution')
  FlagResolveInResolutionEnum get resolution;
  // enum resolutionEnum {  looks_fine,  fixed,  escalated,  };

  FlagResolveIn._();

  factory FlagResolveIn([void updates(FlagResolveInBuilder b)]) =
      _$FlagResolveIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagResolveInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagResolveIn> get serializer =>
      _$FlagResolveInSerializer();
}

class _$FlagResolveInSerializer implements PrimitiveSerializer<FlagResolveIn> {
  @override
  final Iterable<Type> types = const [FlagResolveIn, _$FlagResolveIn];

  @override
  final String wireName = r'FlagResolveIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagResolveIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'resolution';
    yield serializers.serialize(
      object.resolution,
      specifiedType: const FullType(FlagResolveInResolutionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagResolveIn object, {
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
    required FlagResolveInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FlagResolveInResolutionEnum),
          ) as FlagResolveInResolutionEnum;
          result.resolution = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagResolveIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagResolveInBuilder();
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

/// looks_fine → cleared; fixed → fixed; escalated → escalated and reassigned to fpo_admin.
class FlagResolveInResolutionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'looks_fine')
  static const FlagResolveInResolutionEnum looksFine =
      _$flagResolveInResolutionEnum_looksFine;
  @BuiltValueEnumConst(wireName: r'fixed')
  static const FlagResolveInResolutionEnum fixed =
      _$flagResolveInResolutionEnum_fixed;
  @BuiltValueEnumConst(wireName: r'escalated')
  static const FlagResolveInResolutionEnum escalated =
      _$flagResolveInResolutionEnum_escalated;

  static Serializer<FlagResolveInResolutionEnum> get serializer =>
      _$flagResolveInResolutionEnumSerializer;

  const FlagResolveInResolutionEnum._(String name) : super(name);

  static BuiltSet<FlagResolveInResolutionEnum> get values =>
      _$flagResolveInResolutionEnumValues;
  static FlagResolveInResolutionEnum valueOf(String name) =>
      _$flagResolveInResolutionEnumValueOf(name);
}
