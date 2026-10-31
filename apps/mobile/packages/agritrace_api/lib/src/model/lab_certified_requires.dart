//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/reading_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lab_certified_requires.g.dart';

/// What makes a grade \"Lab-certified\" on the public page (FR51).
///
/// Properties:
/// * [anyParameterSource] - At least one reading used for the grade must have this source.
/// * [nablNoPresent] - That reading must also carry a NABL accreditation number.
@BuiltValue()
abstract class LabCertifiedRequires
    implements Built<LabCertifiedRequires, LabCertifiedRequiresBuilder> {
  /// At least one reading used for the grade must have this source.
  @BuiltValueField(wireName: r'any_parameter_source')
  ReadingSource? get anyParameterSource;
  // enum anyParameterSourceEnum {  lab,  instrument,  visual,  };

  /// That reading must also carry a NABL accreditation number.
  @BuiltValueField(wireName: r'nabl_no_present')
  bool? get nablNoPresent;

  LabCertifiedRequires._();

  factory LabCertifiedRequires([void updates(LabCertifiedRequiresBuilder b)]) =
      _$LabCertifiedRequires;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LabCertifiedRequiresBuilder b) => b
    ..anyParameterSource = ReadingSource.lab
    ..nablNoPresent = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<LabCertifiedRequires> get serializer =>
      _$LabCertifiedRequiresSerializer();
}

class _$LabCertifiedRequiresSerializer
    implements PrimitiveSerializer<LabCertifiedRequires> {
  @override
  final Iterable<Type> types = const [
    LabCertifiedRequires,
    _$LabCertifiedRequires
  ];

  @override
  final String wireName = r'LabCertifiedRequires';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LabCertifiedRequires object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.anyParameterSource != null) {
      yield r'any_parameter_source';
      yield serializers.serialize(
        object.anyParameterSource,
        specifiedType: const FullType(ReadingSource),
      );
    }
    if (object.nablNoPresent != null) {
      yield r'nabl_no_present';
      yield serializers.serialize(
        object.nablNoPresent,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LabCertifiedRequires object, {
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
    required LabCertifiedRequiresBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'any_parameter_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReadingSource),
          ) as ReadingSource?;
          if (valueDes == null) continue;
          result.anyParameterSource = valueDes;
          break;
        case r'nabl_no_present':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.nablNoPresent = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LabCertifiedRequires deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LabCertifiedRequiresBuilder();
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
