// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PullChangeEntityEnum _$pullChangeEntityEnum_flag =
    const PullChangeEntityEnum._('flag');
const PullChangeEntityEnum _$pullChangeEntityEnum_lot =
    const PullChangeEntityEnum._('lot');
const PullChangeEntityEnum _$pullChangeEntityEnum_event =
    const PullChangeEntityEnum._('event');
const PullChangeEntityEnum _$pullChangeEntityEnum_intake =
    const PullChangeEntityEnum._('intake');
const PullChangeEntityEnum _$pullChangeEntityEnum_notification =
    const PullChangeEntityEnum._('notification');
const PullChangeEntityEnum _$pullChangeEntityEnum_photoPending =
    const PullChangeEntityEnum._('photoPending');

PullChangeEntityEnum _$pullChangeEntityEnumValueOf(String name) {
  switch (name) {
    case 'flag':
      return _$pullChangeEntityEnum_flag;
    case 'lot':
      return _$pullChangeEntityEnum_lot;
    case 'event':
      return _$pullChangeEntityEnum_event;
    case 'intake':
      return _$pullChangeEntityEnum_intake;
    case 'notification':
      return _$pullChangeEntityEnum_notification;
    case 'photoPending':
      return _$pullChangeEntityEnum_photoPending;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PullChangeEntityEnum> _$pullChangeEntityEnumValues =
    BuiltSet<PullChangeEntityEnum>(const <PullChangeEntityEnum>[
  _$pullChangeEntityEnum_flag,
  _$pullChangeEntityEnum_lot,
  _$pullChangeEntityEnum_event,
  _$pullChangeEntityEnum_intake,
  _$pullChangeEntityEnum_notification,
  _$pullChangeEntityEnum_photoPending,
]);

const PullChangeOpEnum _$pullChangeOpEnum_upsert =
    const PullChangeOpEnum._('upsert');

PullChangeOpEnum _$pullChangeOpEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$pullChangeOpEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PullChangeOpEnum> _$pullChangeOpEnumValues =
    BuiltSet<PullChangeOpEnum>(const <PullChangeOpEnum>[
  _$pullChangeOpEnum_upsert,
]);

Serializer<PullChangeEntityEnum> _$pullChangeEntityEnumSerializer =
    _$PullChangeEntityEnumSerializer();
Serializer<PullChangeOpEnum> _$pullChangeOpEnumSerializer =
    _$PullChangeOpEnumSerializer();

class _$PullChangeEntityEnumSerializer
    implements PrimitiveSerializer<PullChangeEntityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'flag': 'flag',
    'lot': 'lot',
    'event': 'event',
    'intake': 'intake',
    'notification': 'notification',
    'photoPending': 'photo_pending',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'flag': 'flag',
    'lot': 'lot',
    'event': 'event',
    'intake': 'intake',
    'notification': 'notification',
    'photo_pending': 'photoPending',
  };

  @override
  final Iterable<Type> types = const <Type>[PullChangeEntityEnum];
  @override
  final String wireName = 'PullChangeEntityEnum';

  @override
  Object serialize(Serializers serializers, PullChangeEntityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PullChangeEntityEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PullChangeEntityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PullChangeOpEnumSerializer
    implements PrimitiveSerializer<PullChangeOpEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[PullChangeOpEnum];
  @override
  final String wireName = 'PullChangeOpEnum';

  @override
  Object serialize(Serializers serializers, PullChangeOpEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PullChangeOpEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PullChangeOpEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PullChange extends PullChange {
  @override
  final BuiltMap<String, JsonObject?> data;
  @override
  final PullChangeEntityEnum entity;
  @override
  final PullChangeOpEnum op;

  factory _$PullChange([void Function(PullChangeBuilder)? updates]) =>
      (PullChangeBuilder()..update(updates))._build();

  _$PullChange._({required this.data, required this.entity, required this.op})
      : super._();
  @override
  PullChange rebuild(void Function(PullChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PullChangeBuilder toBuilder() => PullChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PullChange &&
        data == other.data &&
        entity == other.entity &&
        op == other.op;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, entity.hashCode);
    _$hash = $jc(_$hash, op.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PullChange')
          ..add('data', data)
          ..add('entity', entity)
          ..add('op', op))
        .toString();
  }
}

class PullChangeBuilder implements Builder<PullChange, PullChangeBuilder> {
  _$PullChange? _$v;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  PullChangeEntityEnum? _entity;
  PullChangeEntityEnum? get entity => _$this._entity;
  set entity(PullChangeEntityEnum? entity) => _$this._entity = entity;

  PullChangeOpEnum? _op;
  PullChangeOpEnum? get op => _$this._op;
  set op(PullChangeOpEnum? op) => _$this._op = op;

  PullChangeBuilder() {
    PullChange._defaults(this);
  }

  PullChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _entity = $v.entity;
      _op = $v.op;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PullChange other) {
    _$v = other as _$PullChange;
  }

  @override
  void update(void Function(PullChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PullChange build() => _build();

  _$PullChange _build() {
    _$PullChange _$result;
    try {
      _$result = _$v ??
          _$PullChange._(
            data: data.build(),
            entity: BuiltValueNullFieldError.checkNotNull(
                entity, r'PullChange', 'entity'),
            op: BuiltValueNullFieldError.checkNotNull(op, r'PullChange', 'op'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PullChange', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
