// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_health_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncHealthRow extends SyncHealthRow {
  @override
  final int entries;
  @override
  final QuantityOutput failureRate;
  @override
  final String? networkType;
  @override
  final QuantityOutput? photoUploadP50;
  @override
  final QuantityOutput? photoUploadP95;
  @override
  final QuantityOutput? saveToAckP50;
  @override
  final QuantityOutput? saveToAckP95;

  factory _$SyncHealthRow([void Function(SyncHealthRowBuilder)? updates]) =>
      (SyncHealthRowBuilder()..update(updates))._build();

  _$SyncHealthRow._(
      {required this.entries,
      required this.failureRate,
      this.networkType,
      this.photoUploadP50,
      this.photoUploadP95,
      this.saveToAckP50,
      this.saveToAckP95})
      : super._();
  @override
  SyncHealthRow rebuild(void Function(SyncHealthRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncHealthRowBuilder toBuilder() => SyncHealthRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncHealthRow &&
        entries == other.entries &&
        failureRate == other.failureRate &&
        networkType == other.networkType &&
        photoUploadP50 == other.photoUploadP50 &&
        photoUploadP95 == other.photoUploadP95 &&
        saveToAckP50 == other.saveToAckP50 &&
        saveToAckP95 == other.saveToAckP95;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jc(_$hash, failureRate.hashCode);
    _$hash = $jc(_$hash, networkType.hashCode);
    _$hash = $jc(_$hash, photoUploadP50.hashCode);
    _$hash = $jc(_$hash, photoUploadP95.hashCode);
    _$hash = $jc(_$hash, saveToAckP50.hashCode);
    _$hash = $jc(_$hash, saveToAckP95.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncHealthRow')
          ..add('entries', entries)
          ..add('failureRate', failureRate)
          ..add('networkType', networkType)
          ..add('photoUploadP50', photoUploadP50)
          ..add('photoUploadP95', photoUploadP95)
          ..add('saveToAckP50', saveToAckP50)
          ..add('saveToAckP95', saveToAckP95))
        .toString();
  }
}

class SyncHealthRowBuilder
    implements Builder<SyncHealthRow, SyncHealthRowBuilder> {
  _$SyncHealthRow? _$v;

  int? _entries;
  int? get entries => _$this._entries;
  set entries(int? entries) => _$this._entries = entries;

  QuantityOutputBuilder? _failureRate;
  QuantityOutputBuilder get failureRate =>
      _$this._failureRate ??= QuantityOutputBuilder();
  set failureRate(QuantityOutputBuilder? failureRate) =>
      _$this._failureRate = failureRate;

  String? _networkType;
  String? get networkType => _$this._networkType;
  set networkType(String? networkType) => _$this._networkType = networkType;

  QuantityOutputBuilder? _photoUploadP50;
  QuantityOutputBuilder get photoUploadP50 =>
      _$this._photoUploadP50 ??= QuantityOutputBuilder();
  set photoUploadP50(QuantityOutputBuilder? photoUploadP50) =>
      _$this._photoUploadP50 = photoUploadP50;

  QuantityOutputBuilder? _photoUploadP95;
  QuantityOutputBuilder get photoUploadP95 =>
      _$this._photoUploadP95 ??= QuantityOutputBuilder();
  set photoUploadP95(QuantityOutputBuilder? photoUploadP95) =>
      _$this._photoUploadP95 = photoUploadP95;

  QuantityOutputBuilder? _saveToAckP50;
  QuantityOutputBuilder get saveToAckP50 =>
      _$this._saveToAckP50 ??= QuantityOutputBuilder();
  set saveToAckP50(QuantityOutputBuilder? saveToAckP50) =>
      _$this._saveToAckP50 = saveToAckP50;

  QuantityOutputBuilder? _saveToAckP95;
  QuantityOutputBuilder get saveToAckP95 =>
      _$this._saveToAckP95 ??= QuantityOutputBuilder();
  set saveToAckP95(QuantityOutputBuilder? saveToAckP95) =>
      _$this._saveToAckP95 = saveToAckP95;

  SyncHealthRowBuilder() {
    SyncHealthRow._defaults(this);
  }

  SyncHealthRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries;
      _failureRate = $v.failureRate.toBuilder();
      _networkType = $v.networkType;
      _photoUploadP50 = $v.photoUploadP50?.toBuilder();
      _photoUploadP95 = $v.photoUploadP95?.toBuilder();
      _saveToAckP50 = $v.saveToAckP50?.toBuilder();
      _saveToAckP95 = $v.saveToAckP95?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncHealthRow other) {
    _$v = other as _$SyncHealthRow;
  }

  @override
  void update(void Function(SyncHealthRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncHealthRow build() => _build();

  _$SyncHealthRow _build() {
    _$SyncHealthRow _$result;
    try {
      _$result = _$v ??
          _$SyncHealthRow._(
            entries: BuiltValueNullFieldError.checkNotNull(
                entries, r'SyncHealthRow', 'entries'),
            failureRate: failureRate.build(),
            networkType: networkType,
            photoUploadP50: _photoUploadP50?.build(),
            photoUploadP95: _photoUploadP95?.build(),
            saveToAckP50: _saveToAckP50?.build(),
            saveToAckP95: _saveToAckP95?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'failureRate';
        failureRate.build();

        _$failedField = 'photoUploadP50';
        _photoUploadP50?.build();
        _$failedField = 'photoUploadP95';
        _photoUploadP95?.build();
        _$failedField = 'saveToAckP50';
        _saveToAckP50?.build();
        _$failedField = 'saveToAckP95';
        _saveToAckP95?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncHealthRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
