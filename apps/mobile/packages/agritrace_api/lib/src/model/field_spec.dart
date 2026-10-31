//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/labels.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'field_spec.g.dart';

/// One configurable field of an entity, after tenant overrides (D-017).
///
/// Properties:
/// * [core] - True: the database needs it, so tenants may not disable it or make it optional.
/// * [enabled] - False: hidden from clients and dropped from payloads; never required.
/// * [label] - Labels shown in the apps, English and Tamil.
/// * [name] - Payload key / CSV column, snake_case.
/// * [required_] - True: a payload without a value is refused (`field_required`).
/// * [stage] - Capture stage the field belongs to.
/// * [type] - Value kind; clients pick the input widget from it.
/// * [visibility] - Who may see the value: public (consumer page), partner (partner API) or internal.
@BuiltValue()
abstract class FieldSpec implements Built<FieldSpec, FieldSpecBuilder> {
  /// True: the database needs it, so tenants may not disable it or make it optional.
  @BuiltValueField(wireName: r'core')
  bool? get core;

  /// False: hidden from clients and dropped from payloads; never required.
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  /// Labels shown in the apps, English and Tamil.
  @BuiltValueField(wireName: r'label')
  Labels get label;

  /// Payload key / CSV column, snake_case.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// True: a payload without a value is refused (`field_required`).
  @BuiltValueField(wireName: r'required')
  bool get required_;

  /// Capture stage the field belongs to.
  @BuiltValueField(wireName: r'stage')
  FieldSpecStageEnum get stage;
  // enum stageEnum {  onboarding,  cultivation,  harvest,  drying,  packing,  intake,  grading,  master_data,  };

  /// Value kind; clients pick the input widget from it.
  @BuiltValueField(wireName: r'type')
  FieldSpecTypeEnum get type;
  // enum typeEnum {  text,  number,  integer,  boolean,  date,  datetime,  phone,  choice,  id,  address,  photo,  audio,  point,  polygon,  quantity,  };

  /// Who may see the value: public (consumer page), partner (partner API) or internal.
  @BuiltValueField(wireName: r'visibility')
  FieldSpecVisibilityEnum get visibility;
  // enum visibilityEnum {  public,  partner,  internal,  };

  FieldSpec._();

  factory FieldSpec([void updates(FieldSpecBuilder b)]) = _$FieldSpec;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FieldSpecBuilder b) => b..core = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<FieldSpec> get serializer => _$FieldSpecSerializer();
}

class _$FieldSpecSerializer implements PrimitiveSerializer<FieldSpec> {
  @override
  final Iterable<Type> types = const [FieldSpec, _$FieldSpec];

  @override
  final String wireName = r'FieldSpec';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FieldSpec object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.core != null) {
      yield r'core';
      yield serializers.serialize(
        object.core,
        specifiedType: const FullType(bool),
      );
    }
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(Labels),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'required';
    yield serializers.serialize(
      object.required_,
      specifiedType: const FullType(bool),
    );
    yield r'stage';
    yield serializers.serialize(
      object.stage,
      specifiedType: const FullType(FieldSpecStageEnum),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(FieldSpecTypeEnum),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(FieldSpecVisibilityEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FieldSpec object, {
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
    required FieldSpecBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'core':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.core = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Labels),
          ) as Labels;
          result.label.replace(valueDes);
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.required_ = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FieldSpecStageEnum),
          ) as FieldSpecStageEnum;
          result.stage = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FieldSpecTypeEnum),
          ) as FieldSpecTypeEnum;
          result.type = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FieldSpecVisibilityEnum),
          ) as FieldSpecVisibilityEnum;
          result.visibility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FieldSpec deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FieldSpecBuilder();
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

/// Capture stage the field belongs to.
class FieldSpecStageEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'onboarding')
  static const FieldSpecStageEnum onboarding = _$fieldSpecStageEnum_onboarding;
  @BuiltValueEnumConst(wireName: r'cultivation')
  static const FieldSpecStageEnum cultivation =
      _$fieldSpecStageEnum_cultivation;
  @BuiltValueEnumConst(wireName: r'harvest')
  static const FieldSpecStageEnum harvest = _$fieldSpecStageEnum_harvest;
  @BuiltValueEnumConst(wireName: r'drying')
  static const FieldSpecStageEnum drying = _$fieldSpecStageEnum_drying;
  @BuiltValueEnumConst(wireName: r'packing')
  static const FieldSpecStageEnum packing = _$fieldSpecStageEnum_packing;
  @BuiltValueEnumConst(wireName: r'intake')
  static const FieldSpecStageEnum intake = _$fieldSpecStageEnum_intake;
  @BuiltValueEnumConst(wireName: r'grading')
  static const FieldSpecStageEnum grading = _$fieldSpecStageEnum_grading;
  @BuiltValueEnumConst(wireName: r'master_data')
  static const FieldSpecStageEnum masterData = _$fieldSpecStageEnum_masterData;

  static Serializer<FieldSpecStageEnum> get serializer =>
      _$fieldSpecStageEnumSerializer;

  const FieldSpecStageEnum._(String name) : super(name);

  static BuiltSet<FieldSpecStageEnum> get values => _$fieldSpecStageEnumValues;
  static FieldSpecStageEnum valueOf(String name) =>
      _$fieldSpecStageEnumValueOf(name);
}

/// Value kind; clients pick the input widget from it.
class FieldSpecTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'text')
  static const FieldSpecTypeEnum text = _$fieldSpecTypeEnum_text;
  @BuiltValueEnumConst(wireName: r'number')
  static const FieldSpecTypeEnum number = _$fieldSpecTypeEnum_number;
  @BuiltValueEnumConst(wireName: r'integer')
  static const FieldSpecTypeEnum integer = _$fieldSpecTypeEnum_integer;
  @BuiltValueEnumConst(wireName: r'boolean')
  static const FieldSpecTypeEnum boolean = _$fieldSpecTypeEnum_boolean;
  @BuiltValueEnumConst(wireName: r'date')
  static const FieldSpecTypeEnum date = _$fieldSpecTypeEnum_date;
  @BuiltValueEnumConst(wireName: r'datetime')
  static const FieldSpecTypeEnum datetime = _$fieldSpecTypeEnum_datetime;
  @BuiltValueEnumConst(wireName: r'phone')
  static const FieldSpecTypeEnum phone = _$fieldSpecTypeEnum_phone;
  @BuiltValueEnumConst(wireName: r'choice')
  static const FieldSpecTypeEnum choice = _$fieldSpecTypeEnum_choice;
  @BuiltValueEnumConst(wireName: r'id')
  static const FieldSpecTypeEnum id = _$fieldSpecTypeEnum_id;
  @BuiltValueEnumConst(wireName: r'address')
  static const FieldSpecTypeEnum address = _$fieldSpecTypeEnum_address;
  @BuiltValueEnumConst(wireName: r'photo')
  static const FieldSpecTypeEnum photo = _$fieldSpecTypeEnum_photo;
  @BuiltValueEnumConst(wireName: r'audio')
  static const FieldSpecTypeEnum audio = _$fieldSpecTypeEnum_audio;
  @BuiltValueEnumConst(wireName: r'point')
  static const FieldSpecTypeEnum point = _$fieldSpecTypeEnum_point;
  @BuiltValueEnumConst(wireName: r'polygon')
  static const FieldSpecTypeEnum polygon = _$fieldSpecTypeEnum_polygon;
  @BuiltValueEnumConst(wireName: r'quantity')
  static const FieldSpecTypeEnum quantity = _$fieldSpecTypeEnum_quantity;

  static Serializer<FieldSpecTypeEnum> get serializer =>
      _$fieldSpecTypeEnumSerializer;

  const FieldSpecTypeEnum._(String name) : super(name);

  static BuiltSet<FieldSpecTypeEnum> get values => _$fieldSpecTypeEnumValues;
  static FieldSpecTypeEnum valueOf(String name) =>
      _$fieldSpecTypeEnumValueOf(name);
}

/// Who may see the value: public (consumer page), partner (partner API) or internal.
class FieldSpecVisibilityEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'public')
  static const FieldSpecVisibilityEnum public =
      _$fieldSpecVisibilityEnum_public;
  @BuiltValueEnumConst(wireName: r'partner')
  static const FieldSpecVisibilityEnum partner =
      _$fieldSpecVisibilityEnum_partner;
  @BuiltValueEnumConst(wireName: r'internal')
  static const FieldSpecVisibilityEnum internal =
      _$fieldSpecVisibilityEnum_internal;

  static Serializer<FieldSpecVisibilityEnum> get serializer =>
      _$fieldSpecVisibilityEnumSerializer;

  const FieldSpecVisibilityEnum._(String name) : super(name);

  static BuiltSet<FieldSpecVisibilityEnum> get values =>
      _$fieldSpecVisibilityEnumValues;
  static FieldSpecVisibilityEnum valueOf(String name) =>
      _$fieldSpecVisibilityEnumValueOf(name);
}
