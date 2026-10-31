// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DataChangeKindEnum _$dataChangeKindEnum_create =
    const DataChangeKindEnum._('create');
const DataChangeKindEnum _$dataChangeKindEnum_correct =
    const DataChangeKindEnum._('correct');
const DataChangeKindEnum _$dataChangeKindEnum_undo =
    const DataChangeKindEnum._('undo');

DataChangeKindEnum _$dataChangeKindEnumValueOf(String name) {
  switch (name) {
    case 'create':
      return _$dataChangeKindEnum_create;
    case 'correct':
      return _$dataChangeKindEnum_correct;
    case 'undo':
      return _$dataChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DataChangeKindEnum> _$dataChangeKindEnumValues =
    BuiltSet<DataChangeKindEnum>(const <DataChangeKindEnum>[
  _$dataChangeKindEnum_create,
  _$dataChangeKindEnum_correct,
  _$dataChangeKindEnum_undo,
]);

const DataEventTypeEnum _$dataEventTypeEnum_finalPacking =
    const DataEventTypeEnum._('finalPacking');

DataEventTypeEnum _$dataEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'finalPacking':
      return _$dataEventTypeEnum_finalPacking;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DataEventTypeEnum> _$dataEventTypeEnumValues =
    BuiltSet<DataEventTypeEnum>(const <DataEventTypeEnum>[
  _$dataEventTypeEnum_finalPacking,
]);

Serializer<DataChangeKindEnum> _$dataChangeKindEnumSerializer =
    _$DataChangeKindEnumSerializer();
Serializer<DataEventTypeEnum> _$dataEventTypeEnumSerializer =
    _$DataEventTypeEnumSerializer();

class _$DataChangeKindEnumSerializer
    implements PrimitiveSerializer<DataChangeKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
  };

  @override
  final Iterable<Type> types = const <Type>[DataChangeKindEnum];
  @override
  final String wireName = 'DataChangeKindEnum';

  @override
  Object serialize(Serializers serializers, DataChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DataChangeKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DataChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DataEventTypeEnumSerializer
    implements PrimitiveSerializer<DataEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'finalPacking': 'final_packing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'final_packing': 'finalPacking',
  };

  @override
  final Iterable<Type> types = const <Type>[DataEventTypeEnum];
  @override
  final String wireName = 'DataEventTypeEnum';

  @override
  Object serialize(Serializers serializers, DataEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DataEventTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DataEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Data extends Data {
  @override
  final OneOf oneOf;

  factory _$Data([void Function(DataBuilder)? updates]) =>
      (DataBuilder()..update(updates))._build();

  _$Data._({required this.oneOf}) : super._();
  @override
  Data rebuild(void Function(DataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DataBuilder toBuilder() => DataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Data && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Data')..add('oneOf', oneOf))
        .toString();
  }
}

class DataBuilder implements Builder<Data, DataBuilder> {
  _$Data? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  DataBuilder() {
    Data._defaults(this);
  }

  DataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Data other) {
    _$v = other as _$Data;
  }

  @override
  void update(void Function(DataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Data build() => _build();

  _$Data _build() {
    final _$result = _$v ??
        _$Data._(
          oneOf: BuiltValueNullFieldError.checkNotNull(oneOf, r'Data', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
