// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConsentIn extends ConsentIn {
  @override
  final String clientId;
  @override
  final ConsentType consentType;
  @override
  final String consentVersion;
  @override
  final String farmerId;
  @override
  final DateTime givenAt;
  @override
  final String? recordingRef;

  factory _$ConsentIn([void Function(ConsentInBuilder)? updates]) =>
      (ConsentInBuilder()..update(updates))._build();

  _$ConsentIn._(
      {required this.clientId,
      required this.consentType,
      required this.consentVersion,
      required this.farmerId,
      required this.givenAt,
      this.recordingRef})
      : super._();
  @override
  ConsentIn rebuild(void Function(ConsentInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConsentInBuilder toBuilder() => ConsentInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConsentIn &&
        clientId == other.clientId &&
        consentType == other.consentType &&
        consentVersion == other.consentVersion &&
        farmerId == other.farmerId &&
        givenAt == other.givenAt &&
        recordingRef == other.recordingRef;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, consentType.hashCode);
    _$hash = $jc(_$hash, consentVersion.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, givenAt.hashCode);
    _$hash = $jc(_$hash, recordingRef.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConsentIn')
          ..add('clientId', clientId)
          ..add('consentType', consentType)
          ..add('consentVersion', consentVersion)
          ..add('farmerId', farmerId)
          ..add('givenAt', givenAt)
          ..add('recordingRef', recordingRef))
        .toString();
  }
}

class ConsentInBuilder implements Builder<ConsentIn, ConsentInBuilder> {
  _$ConsentIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  ConsentType? _consentType;
  ConsentType? get consentType => _$this._consentType;
  set consentType(ConsentType? consentType) =>
      _$this._consentType = consentType;

  String? _consentVersion;
  String? get consentVersion => _$this._consentVersion;
  set consentVersion(String? consentVersion) =>
      _$this._consentVersion = consentVersion;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  DateTime? _givenAt;
  DateTime? get givenAt => _$this._givenAt;
  set givenAt(DateTime? givenAt) => _$this._givenAt = givenAt;

  String? _recordingRef;
  String? get recordingRef => _$this._recordingRef;
  set recordingRef(String? recordingRef) => _$this._recordingRef = recordingRef;

  ConsentInBuilder() {
    ConsentIn._defaults(this);
  }

  ConsentInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _consentType = $v.consentType;
      _consentVersion = $v.consentVersion;
      _farmerId = $v.farmerId;
      _givenAt = $v.givenAt;
      _recordingRef = $v.recordingRef;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConsentIn other) {
    _$v = other as _$ConsentIn;
  }

  @override
  void update(void Function(ConsentInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConsentIn build() => _build();

  _$ConsentIn _build() {
    final _$result = _$v ??
        _$ConsentIn._(
          clientId: BuiltValueNullFieldError.checkNotNull(
              clientId, r'ConsentIn', 'clientId'),
          consentType: BuiltValueNullFieldError.checkNotNull(
              consentType, r'ConsentIn', 'consentType'),
          consentVersion: BuiltValueNullFieldError.checkNotNull(
              consentVersion, r'ConsentIn', 'consentVersion'),
          farmerId: BuiltValueNullFieldError.checkNotNull(
              farmerId, r'ConsentIn', 'farmerId'),
          givenAt: BuiltValueNullFieldError.checkNotNull(
              givenAt, r'ConsentIn', 'givenAt'),
          recordingRef: recordingRef,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
