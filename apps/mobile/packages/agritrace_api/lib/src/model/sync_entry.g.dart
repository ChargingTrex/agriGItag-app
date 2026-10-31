// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SyncEntryKindEnum _$syncEntryKindEnum_eventVersion =
    const SyncEntryKindEnum._('eventVersion');
const SyncEntryKindEnum _$syncEntryKindEnum_qualityReading =
    const SyncEntryKindEnum._('qualityReading');
const SyncEntryKindEnum _$syncEntryKindEnum_plot =
    const SyncEntryKindEnum._('plot');
const SyncEntryKindEnum _$syncEntryKindEnum_consent =
    const SyncEntryKindEnum._('consent');
const SyncEntryKindEnum _$syncEntryKindEnum_flagResolution =
    const SyncEntryKindEnum._('flagResolution');

SyncEntryKindEnum _$syncEntryKindEnumValueOf(String name) {
  switch (name) {
    case 'eventVersion':
      return _$syncEntryKindEnum_eventVersion;
    case 'qualityReading':
      return _$syncEntryKindEnum_qualityReading;
    case 'plot':
      return _$syncEntryKindEnum_plot;
    case 'consent':
      return _$syncEntryKindEnum_consent;
    case 'flagResolution':
      return _$syncEntryKindEnum_flagResolution;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SyncEntryKindEnum> _$syncEntryKindEnumValues =
    BuiltSet<SyncEntryKindEnum>(const <SyncEntryKindEnum>[
  _$syncEntryKindEnum_eventVersion,
  _$syncEntryKindEnum_qualityReading,
  _$syncEntryKindEnum_plot,
  _$syncEntryKindEnum_consent,
  _$syncEntryKindEnum_flagResolution,
]);

Serializer<SyncEntryKindEnum> _$syncEntryKindEnumSerializer =
    _$SyncEntryKindEnumSerializer();

class _$SyncEntryKindEnumSerializer
    implements PrimitiveSerializer<SyncEntryKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'eventVersion': 'event_version',
    'qualityReading': 'quality_reading',
    'plot': 'plot',
    'consent': 'consent',
    'flagResolution': 'flag_resolution',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'event_version': 'eventVersion',
    'quality_reading': 'qualityReading',
    'plot': 'plot',
    'consent': 'consent',
    'flag_resolution': 'flagResolution',
  };

  @override
  final Iterable<Type> types = const <Type>[SyncEntryKindEnum];
  @override
  final String wireName = 'SyncEntryKindEnum';

  @override
  Object serialize(Serializers serializers, SyncEntryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SyncEntryKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SyncEntryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SyncEntry extends SyncEntry {
  @override
  final String clientId;
  @override
  final BuiltMap<String, JsonObject?> data;
  @override
  final SyncEntryKindEnum kind;

  factory _$SyncEntry([void Function(SyncEntryBuilder)? updates]) =>
      (SyncEntryBuilder()..update(updates))._build();

  _$SyncEntry._(
      {required this.clientId, required this.data, required this.kind})
      : super._();
  @override
  SyncEntry rebuild(void Function(SyncEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncEntryBuilder toBuilder() => SyncEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncEntry &&
        clientId == other.clientId &&
        data == other.data &&
        kind == other.kind;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncEntry')
          ..add('clientId', clientId)
          ..add('data', data)
          ..add('kind', kind))
        .toString();
  }
}

class SyncEntryBuilder implements Builder<SyncEntry, SyncEntryBuilder> {
  _$SyncEntry? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  SyncEntryKindEnum? _kind;
  SyncEntryKindEnum? get kind => _$this._kind;
  set kind(SyncEntryKindEnum? kind) => _$this._kind = kind;

  SyncEntryBuilder() {
    SyncEntry._defaults(this);
  }

  SyncEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _data = $v.data.toBuilder();
      _kind = $v.kind;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncEntry other) {
    _$v = other as _$SyncEntry;
  }

  @override
  void update(void Function(SyncEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncEntry build() => _build();

  _$SyncEntry _build() {
    _$SyncEntry _$result;
    try {
      _$result = _$v ??
          _$SyncEntry._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'SyncEntry', 'clientId'),
            data: data.build(),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'SyncEntry', 'kind'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
