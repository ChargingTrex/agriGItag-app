// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metric_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncMetricIn extends SyncMetricIn {
  @override
  final DateTime? ackedAt;
  @override
  final String entryClientId;
  @override
  final int? failures;
  @override
  final String? networkType;
  @override
  final int? photoUploadMs;
  @override
  final DateTime savedAt;

  factory _$SyncMetricIn([void Function(SyncMetricInBuilder)? updates]) =>
      (SyncMetricInBuilder()..update(updates))._build();

  _$SyncMetricIn._(
      {this.ackedAt,
      required this.entryClientId,
      this.failures,
      this.networkType,
      this.photoUploadMs,
      required this.savedAt})
      : super._();
  @override
  SyncMetricIn rebuild(void Function(SyncMetricInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncMetricInBuilder toBuilder() => SyncMetricInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncMetricIn &&
        ackedAt == other.ackedAt &&
        entryClientId == other.entryClientId &&
        failures == other.failures &&
        networkType == other.networkType &&
        photoUploadMs == other.photoUploadMs &&
        savedAt == other.savedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ackedAt.hashCode);
    _$hash = $jc(_$hash, entryClientId.hashCode);
    _$hash = $jc(_$hash, failures.hashCode);
    _$hash = $jc(_$hash, networkType.hashCode);
    _$hash = $jc(_$hash, photoUploadMs.hashCode);
    _$hash = $jc(_$hash, savedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncMetricIn')
          ..add('ackedAt', ackedAt)
          ..add('entryClientId', entryClientId)
          ..add('failures', failures)
          ..add('networkType', networkType)
          ..add('photoUploadMs', photoUploadMs)
          ..add('savedAt', savedAt))
        .toString();
  }
}

class SyncMetricInBuilder
    implements Builder<SyncMetricIn, SyncMetricInBuilder> {
  _$SyncMetricIn? _$v;

  DateTime? _ackedAt;
  DateTime? get ackedAt => _$this._ackedAt;
  set ackedAt(DateTime? ackedAt) => _$this._ackedAt = ackedAt;

  String? _entryClientId;
  String? get entryClientId => _$this._entryClientId;
  set entryClientId(String? entryClientId) =>
      _$this._entryClientId = entryClientId;

  int? _failures;
  int? get failures => _$this._failures;
  set failures(int? failures) => _$this._failures = failures;

  String? _networkType;
  String? get networkType => _$this._networkType;
  set networkType(String? networkType) => _$this._networkType = networkType;

  int? _photoUploadMs;
  int? get photoUploadMs => _$this._photoUploadMs;
  set photoUploadMs(int? photoUploadMs) =>
      _$this._photoUploadMs = photoUploadMs;

  DateTime? _savedAt;
  DateTime? get savedAt => _$this._savedAt;
  set savedAt(DateTime? savedAt) => _$this._savedAt = savedAt;

  SyncMetricInBuilder() {
    SyncMetricIn._defaults(this);
  }

  SyncMetricInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ackedAt = $v.ackedAt;
      _entryClientId = $v.entryClientId;
      _failures = $v.failures;
      _networkType = $v.networkType;
      _photoUploadMs = $v.photoUploadMs;
      _savedAt = $v.savedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncMetricIn other) {
    _$v = other as _$SyncMetricIn;
  }

  @override
  void update(void Function(SyncMetricInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncMetricIn build() => _build();

  _$SyncMetricIn _build() {
    final _$result = _$v ??
        _$SyncMetricIn._(
          ackedAt: ackedAt,
          entryClientId: BuiltValueNullFieldError.checkNotNull(
              entryClientId, r'SyncMetricIn', 'entryClientId'),
          failures: failures,
          networkType: networkType,
          photoUploadMs: photoUploadMs,
          savedAt: BuiltValueNullFieldError.checkNotNull(
              savedAt, r'SyncMetricIn', 'savedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
