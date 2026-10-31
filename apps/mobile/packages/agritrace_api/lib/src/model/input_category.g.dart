// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InputCategory _$chemicalFertilizer =
    const InputCategory._('chemicalFertilizer');
const InputCategory _$organicFertilizer =
    const InputCategory._('organicFertilizer');
const InputCategory _$bioFertilizer = const InputCategory._('bioFertilizer');
const InputCategory _$chemicalPesticide =
    const InputCategory._('chemicalPesticide');
const InputCategory _$bioPesticide = const InputCategory._('bioPesticide');
const InputCategory _$other = const InputCategory._('other');

InputCategory _$valueOf(String name) {
  switch (name) {
    case 'chemicalFertilizer':
      return _$chemicalFertilizer;
    case 'organicFertilizer':
      return _$organicFertilizer;
    case 'bioFertilizer':
      return _$bioFertilizer;
    case 'chemicalPesticide':
      return _$chemicalPesticide;
    case 'bioPesticide':
      return _$bioPesticide;
    case 'other':
      return _$other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InputCategory> _$values =
    BuiltSet<InputCategory>(const <InputCategory>[
  _$chemicalFertilizer,
  _$organicFertilizer,
  _$bioFertilizer,
  _$chemicalPesticide,
  _$bioPesticide,
  _$other,
]);

class _$InputCategoryMeta {
  const _$InputCategoryMeta();
  InputCategory get chemicalFertilizer => _$chemicalFertilizer;
  InputCategory get organicFertilizer => _$organicFertilizer;
  InputCategory get bioFertilizer => _$bioFertilizer;
  InputCategory get chemicalPesticide => _$chemicalPesticide;
  InputCategory get bioPesticide => _$bioPesticide;
  InputCategory get other => _$other;
  InputCategory valueOf(String name) => _$valueOf(name);
  BuiltSet<InputCategory> get values => _$values;
}

abstract class _$InputCategoryMixin {
  // ignore: non_constant_identifier_names
  _$InputCategoryMeta get InputCategory => const _$InputCategoryMeta();
}

Serializer<InputCategory> _$inputCategorySerializer =
    _$InputCategorySerializer();

class _$InputCategorySerializer implements PrimitiveSerializer<InputCategory> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'chemicalFertilizer': 'chemical_fertilizer',
    'organicFertilizer': 'organic_fertilizer',
    'bioFertilizer': 'bio_fertilizer',
    'chemicalPesticide': 'chemical_pesticide',
    'bioPesticide': 'bio_pesticide',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'chemical_fertilizer': 'chemicalFertilizer',
    'organic_fertilizer': 'organicFertilizer',
    'bio_fertilizer': 'bioFertilizer',
    'chemical_pesticide': 'chemicalPesticide',
    'bio_pesticide': 'bioPesticide',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[InputCategory];
  @override
  final String wireName = 'InputCategory';

  @override
  Object serialize(Serializers serializers, InputCategory object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InputCategory deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InputCategory.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
