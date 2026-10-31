// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PinMethod _$liveGps = const PinMethod._('liveGps');
const PinMethod _$mapPin = const PinMethod._('mapPin');

PinMethod _$valueOf(String name) {
  switch (name) {
    case 'liveGps':
      return _$liveGps;
    case 'mapPin':
      return _$mapPin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PinMethod> _$values = BuiltSet<PinMethod>(const <PinMethod>[
  _$liveGps,
  _$mapPin,
]);

class _$PinMethodMeta {
  const _$PinMethodMeta();
  PinMethod get liveGps => _$liveGps;
  PinMethod get mapPin => _$mapPin;
  PinMethod valueOf(String name) => _$valueOf(name);
  BuiltSet<PinMethod> get values => _$values;
}

abstract class _$PinMethodMixin {
  // ignore: non_constant_identifier_names
  _$PinMethodMeta get PinMethod => const _$PinMethodMeta();
}

Serializer<PinMethod> _$pinMethodSerializer = _$PinMethodSerializer();

class _$PinMethodSerializer implements PrimitiveSerializer<PinMethod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'liveGps': 'live_gps',
    'mapPin': 'map_pin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'live_gps': 'liveGps',
    'map_pin': 'mapPin',
  };

  @override
  final Iterable<Type> types = const <Type>[PinMethod];
  @override
  final String wireName = 'PinMethod';

  @override
  Object serialize(Serializers serializers, PinMethod object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PinMethod deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PinMethod.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
