// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LotStatus _$open = const LotStatus._('open');
const LotStatus _$drying = const LotStatus._('drying');
const LotStatus _$readyForSale = const LotStatus._('readyForSale');
const LotStatus _$received = const LotStatus._('received');
const LotStatus _$batched = const LotStatus._('batched');
const LotStatus _$closed = const LotStatus._('closed');

LotStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'drying':
      return _$drying;
    case 'readyForSale':
      return _$readyForSale;
    case 'received':
      return _$received;
    case 'batched':
      return _$batched;
    case 'closed':
      return _$closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LotStatus> _$values = BuiltSet<LotStatus>(const <LotStatus>[
  _$open,
  _$drying,
  _$readyForSale,
  _$received,
  _$batched,
  _$closed,
]);

class _$LotStatusMeta {
  const _$LotStatusMeta();
  LotStatus get open => _$open;
  LotStatus get drying => _$drying;
  LotStatus get readyForSale => _$readyForSale;
  LotStatus get received => _$received;
  LotStatus get batched => _$batched;
  LotStatus get closed => _$closed;
  LotStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<LotStatus> get values => _$values;
}

abstract class _$LotStatusMixin {
  // ignore: non_constant_identifier_names
  _$LotStatusMeta get LotStatus => const _$LotStatusMeta();
}

Serializer<LotStatus> _$lotStatusSerializer = _$LotStatusSerializer();

class _$LotStatusSerializer implements PrimitiveSerializer<LotStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'drying': 'drying',
    'readyForSale': 'ready_for_sale',
    'received': 'received',
    'batched': 'batched',
    'closed': 'closed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'drying': 'drying',
    'ready_for_sale': 'readyForSale',
    'received': 'received',
    'batched': 'batched',
    'closed': 'closed',
  };

  @override
  final Iterable<Type> types = const <Type>[LotStatus];
  @override
  final String wireName = 'LotStatus';

  @override
  Object serialize(Serializers serializers, LotStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LotStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LotStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
