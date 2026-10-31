// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_part.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BundlePart _$plots = const BundlePart._('plots');
const BundlePart _$crops = const BundlePart._('crops');
const BundlePart _$inputs = const BundlePart._('inputs');
const BundlePart _$standards = const BundlePart._('standards');
const BundlePart _$giRegion = const BundlePart._('giRegion');
const BundlePart _$farmerProfile = const BundlePart._('farmerProfile');
const BundlePart _$villages = const BundlePart._('villages');
const BundlePart _$fields = const BundlePart._('fields');
const BundlePart _$prompts = const BundlePart._('prompts');
const BundlePart _$images = const BundlePart._('images');
const BundlePart _$calendar = const BundlePart._('calendar');

BundlePart _$valueOf(String name) {
  switch (name) {
    case 'plots':
      return _$plots;
    case 'crops':
      return _$crops;
    case 'inputs':
      return _$inputs;
    case 'standards':
      return _$standards;
    case 'giRegion':
      return _$giRegion;
    case 'farmerProfile':
      return _$farmerProfile;
    case 'villages':
      return _$villages;
    case 'fields':
      return _$fields;
    case 'prompts':
      return _$prompts;
    case 'images':
      return _$images;
    case 'calendar':
      return _$calendar;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BundlePart> _$values = BuiltSet<BundlePart>(const <BundlePart>[
  _$plots,
  _$crops,
  _$inputs,
  _$standards,
  _$giRegion,
  _$farmerProfile,
  _$villages,
  _$fields,
  _$prompts,
  _$images,
  _$calendar,
]);

class _$BundlePartMeta {
  const _$BundlePartMeta();
  BundlePart get plots => _$plots;
  BundlePart get crops => _$crops;
  BundlePart get inputs => _$inputs;
  BundlePart get standards => _$standards;
  BundlePart get giRegion => _$giRegion;
  BundlePart get farmerProfile => _$farmerProfile;
  BundlePart get villages => _$villages;
  BundlePart get fields => _$fields;
  BundlePart get prompts => _$prompts;
  BundlePart get images => _$images;
  BundlePart get calendar => _$calendar;
  BundlePart valueOf(String name) => _$valueOf(name);
  BuiltSet<BundlePart> get values => _$values;
}

abstract class _$BundlePartMixin {
  // ignore: non_constant_identifier_names
  _$BundlePartMeta get BundlePart => const _$BundlePartMeta();
}

Serializer<BundlePart> _$bundlePartSerializer = _$BundlePartSerializer();

class _$BundlePartSerializer implements PrimitiveSerializer<BundlePart> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'plots': 'plots',
    'crops': 'crops',
    'inputs': 'inputs',
    'standards': 'standards',
    'giRegion': 'gi_region',
    'farmerProfile': 'farmer_profile',
    'villages': 'villages',
    'fields': 'fields',
    'prompts': 'prompts',
    'images': 'images',
    'calendar': 'calendar',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'plots': 'plots',
    'crops': 'crops',
    'inputs': 'inputs',
    'standards': 'standards',
    'gi_region': 'giRegion',
    'farmer_profile': 'farmerProfile',
    'villages': 'villages',
    'fields': 'fields',
    'prompts': 'prompts',
    'images': 'images',
    'calendar': 'calendar',
  };

  @override
  final Iterable<Type> types = const <Type>[BundlePart];
  @override
  final String wireName = 'BundlePart';

  @override
  Object serialize(Serializers serializers, BundlePart object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BundlePart deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BundlePart.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
