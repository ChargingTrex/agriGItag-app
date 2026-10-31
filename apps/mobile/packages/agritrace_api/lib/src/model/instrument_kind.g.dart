// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InstrumentKind _$moistureMeter = const InstrumentKind._('moistureMeter');
const InstrumentKind _$colorimeter = const InstrumentKind._('colorimeter');
const InstrumentKind _$hygrometer = const InstrumentKind._('hygrometer');
const InstrumentKind _$scale = const InstrumentKind._('scale');

InstrumentKind _$valueOf(String name) {
  switch (name) {
    case 'moistureMeter':
      return _$moistureMeter;
    case 'colorimeter':
      return _$colorimeter;
    case 'hygrometer':
      return _$hygrometer;
    case 'scale':
      return _$scale;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InstrumentKind> _$values =
    BuiltSet<InstrumentKind>(const <InstrumentKind>[
  _$moistureMeter,
  _$colorimeter,
  _$hygrometer,
  _$scale,
]);

class _$InstrumentKindMeta {
  const _$InstrumentKindMeta();
  InstrumentKind get moistureMeter => _$moistureMeter;
  InstrumentKind get colorimeter => _$colorimeter;
  InstrumentKind get hygrometer => _$hygrometer;
  InstrumentKind get scale => _$scale;
  InstrumentKind valueOf(String name) => _$valueOf(name);
  BuiltSet<InstrumentKind> get values => _$values;
}

abstract class _$InstrumentKindMixin {
  // ignore: non_constant_identifier_names
  _$InstrumentKindMeta get InstrumentKind => const _$InstrumentKindMeta();
}

Serializer<InstrumentKind> _$instrumentKindSerializer =
    _$InstrumentKindSerializer();

class _$InstrumentKindSerializer
    implements PrimitiveSerializer<InstrumentKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'moistureMeter': 'moisture_meter',
    'colorimeter': 'colorimeter',
    'hygrometer': 'hygrometer',
    'scale': 'scale',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'moisture_meter': 'moistureMeter',
    'colorimeter': 'colorimeter',
    'hygrometer': 'hygrometer',
    'scale': 'scale',
  };

  @override
  final Iterable<Type> types = const <Type>[InstrumentKind];
  @override
  final String wireName = 'InstrumentKind';

  @override
  Object serialize(Serializers serializers, InstrumentKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InstrumentKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InstrumentKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
