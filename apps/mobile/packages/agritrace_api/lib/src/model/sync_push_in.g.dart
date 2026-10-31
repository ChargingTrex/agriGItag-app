// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncPushIn extends SyncPushIn {
  @override
  final String appVersion;
  @override
  final String deviceId;
  @override
  final DateTime deviceTime;
  @override
  final BuiltList<SyncEntry> entries;
  @override
  final BuiltList<SyncMetricIn>? metrics;

  factory _$SyncPushIn([void Function(SyncPushInBuilder)? updates]) =>
      (SyncPushInBuilder()..update(updates))._build();

  _$SyncPushIn._(
      {required this.appVersion,
      required this.deviceId,
      required this.deviceTime,
      required this.entries,
      this.metrics})
      : super._();
  @override
  SyncPushIn rebuild(void Function(SyncPushInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncPushInBuilder toBuilder() => SyncPushInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncPushIn &&
        appVersion == other.appVersion &&
        deviceId == other.deviceId &&
        deviceTime == other.deviceTime &&
        entries == other.entries &&
        metrics == other.metrics;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceTime.hashCode);
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jc(_$hash, metrics.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncPushIn')
          ..add('appVersion', appVersion)
          ..add('deviceId', deviceId)
          ..add('deviceTime', deviceTime)
          ..add('entries', entries)
          ..add('metrics', metrics))
        .toString();
  }
}

class SyncPushInBuilder implements Builder<SyncPushIn, SyncPushInBuilder> {
  _$SyncPushIn? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  DateTime? _deviceTime;
  DateTime? get deviceTime => _$this._deviceTime;
  set deviceTime(DateTime? deviceTime) => _$this._deviceTime = deviceTime;

  ListBuilder<SyncEntry>? _entries;
  ListBuilder<SyncEntry> get entries =>
      _$this._entries ??= ListBuilder<SyncEntry>();
  set entries(ListBuilder<SyncEntry>? entries) => _$this._entries = entries;

  ListBuilder<SyncMetricIn>? _metrics;
  ListBuilder<SyncMetricIn> get metrics =>
      _$this._metrics ??= ListBuilder<SyncMetricIn>();
  set metrics(ListBuilder<SyncMetricIn>? metrics) => _$this._metrics = metrics;

  SyncPushInBuilder() {
    SyncPushIn._defaults(this);
  }

  SyncPushInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _deviceId = $v.deviceId;
      _deviceTime = $v.deviceTime;
      _entries = $v.entries.toBuilder();
      _metrics = $v.metrics?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncPushIn other) {
    _$v = other as _$SyncPushIn;
  }

  @override
  void update(void Function(SyncPushInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncPushIn build() => _build();

  _$SyncPushIn _build() {
    _$SyncPushIn _$result;
    try {
      _$result = _$v ??
          _$SyncPushIn._(
            appVersion: BuiltValueNullFieldError.checkNotNull(
                appVersion, r'SyncPushIn', 'appVersion'),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'SyncPushIn', 'deviceId'),
            deviceTime: BuiltValueNullFieldError.checkNotNull(
                deviceTime, r'SyncPushIn', 'deviceTime'),
            entries: entries.build(),
            metrics: _metrics?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        entries.build();
        _$failedField = 'metrics';
        _metrics?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncPushIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
