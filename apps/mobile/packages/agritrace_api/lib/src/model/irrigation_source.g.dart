// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'irrigation_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IrrigationSource _$well = const IrrigationSource._('well');
const IrrigationSource _$borewell = const IrrigationSource._('borewell');
const IrrigationSource _$canal = const IrrigationSource._('canal');
const IrrigationSource _$tank = const IrrigationSource._('tank');
const IrrigationSource _$rain = const IrrigationSource._('rain');

IrrigationSource _$valueOf(String name) {
  switch (name) {
    case 'well':
      return _$well;
    case 'borewell':
      return _$borewell;
    case 'canal':
      return _$canal;
    case 'tank':
      return _$tank;
    case 'rain':
      return _$rain;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IrrigationSource> _$values =
    BuiltSet<IrrigationSource>(const <IrrigationSource>[
  _$well,
  _$borewell,
  _$canal,
  _$tank,
  _$rain,
]);

class _$IrrigationSourceMeta {
  const _$IrrigationSourceMeta();
  IrrigationSource get well => _$well;
  IrrigationSource get borewell => _$borewell;
  IrrigationSource get canal => _$canal;
  IrrigationSource get tank => _$tank;
  IrrigationSource get rain => _$rain;
  IrrigationSource valueOf(String name) => _$valueOf(name);
  BuiltSet<IrrigationSource> get values => _$values;
}

abstract class _$IrrigationSourceMixin {
  // ignore: non_constant_identifier_names
  _$IrrigationSourceMeta get IrrigationSource => const _$IrrigationSourceMeta();
}

Serializer<IrrigationSource> _$irrigationSourceSerializer =
    _$IrrigationSourceSerializer();

class _$IrrigationSourceSerializer
    implements PrimitiveSerializer<IrrigationSource> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'well': 'well',
    'borewell': 'borewell',
    'canal': 'canal',
    'tank': 'tank',
    'rain': 'rain',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'well': 'well',
    'borewell': 'borewell',
    'canal': 'canal',
    'tank': 'tank',
    'rain': 'rain',
  };

  @override
  final Iterable<Type> types = const <Type>[IrrigationSource];
  @override
  final String wireName = 'IrrigationSource';

  @override
  Object serialize(Serializers serializers, IrrigationSource object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IrrigationSource deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IrrigationSource.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
