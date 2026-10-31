// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farming_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FarmingType _$irrigated = const FarmingType._('irrigated');
const FarmingType _$rainfed = const FarmingType._('rainfed');

FarmingType _$valueOf(String name) {
  switch (name) {
    case 'irrigated':
      return _$irrigated;
    case 'rainfed':
      return _$rainfed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FarmingType> _$values =
    BuiltSet<FarmingType>(const <FarmingType>[
  _$irrigated,
  _$rainfed,
]);

class _$FarmingTypeMeta {
  const _$FarmingTypeMeta();
  FarmingType get irrigated => _$irrigated;
  FarmingType get rainfed => _$rainfed;
  FarmingType valueOf(String name) => _$valueOf(name);
  BuiltSet<FarmingType> get values => _$values;
}

abstract class _$FarmingTypeMixin {
  // ignore: non_constant_identifier_names
  _$FarmingTypeMeta get FarmingType => const _$FarmingTypeMeta();
}

Serializer<FarmingType> _$farmingTypeSerializer = _$FarmingTypeSerializer();

class _$FarmingTypeSerializer implements PrimitiveSerializer<FarmingType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'irrigated': 'irrigated',
    'rainfed': 'rainfed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'irrigated': 'irrigated',
    'rainfed': 'rainfed',
  };

  @override
  final Iterable<Type> types = const <Type>[FarmingType];
  @override
  final String wireName = 'FarmingType';

  @override
  Object serialize(Serializers serializers, FarmingType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FarmingType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FarmingType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
