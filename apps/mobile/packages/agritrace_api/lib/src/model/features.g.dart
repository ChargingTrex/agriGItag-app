// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'features.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Features extends Features {
  @override
  final bool boundaryWalk;
  @override
  final bool farmerPinLogin;
  @override
  final int gradingLossWarnPct;
  @override
  final bool idDocumentCapture;
  @override
  final int otpDailyCap;
  @override
  final bool producerGroups;
  @override
  final int secondSignoffThresholdKg;
  @override
  final int syncPushMaxBytes;
  @override
  final int syncPushMaxEntries;
  @override
  final bool wifiOnlyPhotosDefault;

  factory _$Features([void Function(FeaturesBuilder)? updates]) =>
      (FeaturesBuilder()..update(updates))._build();

  _$Features._(
      {required this.boundaryWalk,
      required this.farmerPinLogin,
      required this.gradingLossWarnPct,
      required this.idDocumentCapture,
      required this.otpDailyCap,
      required this.producerGroups,
      required this.secondSignoffThresholdKg,
      required this.syncPushMaxBytes,
      required this.syncPushMaxEntries,
      required this.wifiOnlyPhotosDefault})
      : super._();
  @override
  Features rebuild(void Function(FeaturesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FeaturesBuilder toBuilder() => FeaturesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Features &&
        boundaryWalk == other.boundaryWalk &&
        farmerPinLogin == other.farmerPinLogin &&
        gradingLossWarnPct == other.gradingLossWarnPct &&
        idDocumentCapture == other.idDocumentCapture &&
        otpDailyCap == other.otpDailyCap &&
        producerGroups == other.producerGroups &&
        secondSignoffThresholdKg == other.secondSignoffThresholdKg &&
        syncPushMaxBytes == other.syncPushMaxBytes &&
        syncPushMaxEntries == other.syncPushMaxEntries &&
        wifiOnlyPhotosDefault == other.wifiOnlyPhotosDefault;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, boundaryWalk.hashCode);
    _$hash = $jc(_$hash, farmerPinLogin.hashCode);
    _$hash = $jc(_$hash, gradingLossWarnPct.hashCode);
    _$hash = $jc(_$hash, idDocumentCapture.hashCode);
    _$hash = $jc(_$hash, otpDailyCap.hashCode);
    _$hash = $jc(_$hash, producerGroups.hashCode);
    _$hash = $jc(_$hash, secondSignoffThresholdKg.hashCode);
    _$hash = $jc(_$hash, syncPushMaxBytes.hashCode);
    _$hash = $jc(_$hash, syncPushMaxEntries.hashCode);
    _$hash = $jc(_$hash, wifiOnlyPhotosDefault.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Features')
          ..add('boundaryWalk', boundaryWalk)
          ..add('farmerPinLogin', farmerPinLogin)
          ..add('gradingLossWarnPct', gradingLossWarnPct)
          ..add('idDocumentCapture', idDocumentCapture)
          ..add('otpDailyCap', otpDailyCap)
          ..add('producerGroups', producerGroups)
          ..add('secondSignoffThresholdKg', secondSignoffThresholdKg)
          ..add('syncPushMaxBytes', syncPushMaxBytes)
          ..add('syncPushMaxEntries', syncPushMaxEntries)
          ..add('wifiOnlyPhotosDefault', wifiOnlyPhotosDefault))
        .toString();
  }
}

class FeaturesBuilder implements Builder<Features, FeaturesBuilder> {
  _$Features? _$v;

  bool? _boundaryWalk;
  bool? get boundaryWalk => _$this._boundaryWalk;
  set boundaryWalk(bool? boundaryWalk) => _$this._boundaryWalk = boundaryWalk;

  bool? _farmerPinLogin;
  bool? get farmerPinLogin => _$this._farmerPinLogin;
  set farmerPinLogin(bool? farmerPinLogin) =>
      _$this._farmerPinLogin = farmerPinLogin;

  int? _gradingLossWarnPct;
  int? get gradingLossWarnPct => _$this._gradingLossWarnPct;
  set gradingLossWarnPct(int? gradingLossWarnPct) =>
      _$this._gradingLossWarnPct = gradingLossWarnPct;

  bool? _idDocumentCapture;
  bool? get idDocumentCapture => _$this._idDocumentCapture;
  set idDocumentCapture(bool? idDocumentCapture) =>
      _$this._idDocumentCapture = idDocumentCapture;

  int? _otpDailyCap;
  int? get otpDailyCap => _$this._otpDailyCap;
  set otpDailyCap(int? otpDailyCap) => _$this._otpDailyCap = otpDailyCap;

  bool? _producerGroups;
  bool? get producerGroups => _$this._producerGroups;
  set producerGroups(bool? producerGroups) =>
      _$this._producerGroups = producerGroups;

  int? _secondSignoffThresholdKg;
  int? get secondSignoffThresholdKg => _$this._secondSignoffThresholdKg;
  set secondSignoffThresholdKg(int? secondSignoffThresholdKg) =>
      _$this._secondSignoffThresholdKg = secondSignoffThresholdKg;

  int? _syncPushMaxBytes;
  int? get syncPushMaxBytes => _$this._syncPushMaxBytes;
  set syncPushMaxBytes(int? syncPushMaxBytes) =>
      _$this._syncPushMaxBytes = syncPushMaxBytes;

  int? _syncPushMaxEntries;
  int? get syncPushMaxEntries => _$this._syncPushMaxEntries;
  set syncPushMaxEntries(int? syncPushMaxEntries) =>
      _$this._syncPushMaxEntries = syncPushMaxEntries;

  bool? _wifiOnlyPhotosDefault;
  bool? get wifiOnlyPhotosDefault => _$this._wifiOnlyPhotosDefault;
  set wifiOnlyPhotosDefault(bool? wifiOnlyPhotosDefault) =>
      _$this._wifiOnlyPhotosDefault = wifiOnlyPhotosDefault;

  FeaturesBuilder() {
    Features._defaults(this);
  }

  FeaturesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _boundaryWalk = $v.boundaryWalk;
      _farmerPinLogin = $v.farmerPinLogin;
      _gradingLossWarnPct = $v.gradingLossWarnPct;
      _idDocumentCapture = $v.idDocumentCapture;
      _otpDailyCap = $v.otpDailyCap;
      _producerGroups = $v.producerGroups;
      _secondSignoffThresholdKg = $v.secondSignoffThresholdKg;
      _syncPushMaxBytes = $v.syncPushMaxBytes;
      _syncPushMaxEntries = $v.syncPushMaxEntries;
      _wifiOnlyPhotosDefault = $v.wifiOnlyPhotosDefault;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Features other) {
    _$v = other as _$Features;
  }

  @override
  void update(void Function(FeaturesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Features build() => _build();

  _$Features _build() {
    final _$result = _$v ??
        _$Features._(
          boundaryWalk: BuiltValueNullFieldError.checkNotNull(
              boundaryWalk, r'Features', 'boundaryWalk'),
          farmerPinLogin: BuiltValueNullFieldError.checkNotNull(
              farmerPinLogin, r'Features', 'farmerPinLogin'),
          gradingLossWarnPct: BuiltValueNullFieldError.checkNotNull(
              gradingLossWarnPct, r'Features', 'gradingLossWarnPct'),
          idDocumentCapture: BuiltValueNullFieldError.checkNotNull(
              idDocumentCapture, r'Features', 'idDocumentCapture'),
          otpDailyCap: BuiltValueNullFieldError.checkNotNull(
              otpDailyCap, r'Features', 'otpDailyCap'),
          producerGroups: BuiltValueNullFieldError.checkNotNull(
              producerGroups, r'Features', 'producerGroups'),
          secondSignoffThresholdKg: BuiltValueNullFieldError.checkNotNull(
              secondSignoffThresholdKg,
              r'Features',
              'secondSignoffThresholdKg'),
          syncPushMaxBytes: BuiltValueNullFieldError.checkNotNull(
              syncPushMaxBytes, r'Features', 'syncPushMaxBytes'),
          syncPushMaxEntries: BuiltValueNullFieldError.checkNotNull(
              syncPushMaxEntries, r'Features', 'syncPushMaxEntries'),
          wifiOnlyPhotosDefault: BuiltValueNullFieldError.checkNotNull(
              wifiOnlyPhotosDefault, r'Features', 'wifiOnlyPhotosDefault'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
