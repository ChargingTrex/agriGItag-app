// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConsentOut extends ConsentOut {
  @override
  final ConsentType consentType;
  @override
  final String consentVersion;
  @override
  final String farmerId;
  @override
  final DateTime givenAt;
  @override
  final String id;
  @override
  final String? recordingRef;
  @override
  final DateTime? revokedAt;
  @override
  final String? witnessedByUserId;

  factory _$ConsentOut([void Function(ConsentOutBuilder)? updates]) =>
      (ConsentOutBuilder()..update(updates))._build();

  _$ConsentOut._(
      {required this.consentType,
      required this.consentVersion,
      required this.farmerId,
      required this.givenAt,
      required this.id,
      this.recordingRef,
      this.revokedAt,
      this.witnessedByUserId})
      : super._();
  @override
  ConsentOut rebuild(void Function(ConsentOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConsentOutBuilder toBuilder() => ConsentOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConsentOut &&
        consentType == other.consentType &&
        consentVersion == other.consentVersion &&
        farmerId == other.farmerId &&
        givenAt == other.givenAt &&
        id == other.id &&
        recordingRef == other.recordingRef &&
        revokedAt == other.revokedAt &&
        witnessedByUserId == other.witnessedByUserId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, consentType.hashCode);
    _$hash = $jc(_$hash, consentVersion.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, givenAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, recordingRef.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jc(_$hash, witnessedByUserId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConsentOut')
          ..add('consentType', consentType)
          ..add('consentVersion', consentVersion)
          ..add('farmerId', farmerId)
          ..add('givenAt', givenAt)
          ..add('id', id)
          ..add('recordingRef', recordingRef)
          ..add('revokedAt', revokedAt)
          ..add('witnessedByUserId', witnessedByUserId))
        .toString();
  }
}

class ConsentOutBuilder implements Builder<ConsentOut, ConsentOutBuilder> {
  _$ConsentOut? _$v;

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

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _recordingRef;
  String? get recordingRef => _$this._recordingRef;
  set recordingRef(String? recordingRef) => _$this._recordingRef = recordingRef;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  String? _witnessedByUserId;
  String? get witnessedByUserId => _$this._witnessedByUserId;
  set witnessedByUserId(String? witnessedByUserId) =>
      _$this._witnessedByUserId = witnessedByUserId;

  ConsentOutBuilder() {
    ConsentOut._defaults(this);
  }

  ConsentOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _consentType = $v.consentType;
      _consentVersion = $v.consentVersion;
      _farmerId = $v.farmerId;
      _givenAt = $v.givenAt;
      _id = $v.id;
      _recordingRef = $v.recordingRef;
      _revokedAt = $v.revokedAt;
      _witnessedByUserId = $v.witnessedByUserId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConsentOut other) {
    _$v = other as _$ConsentOut;
  }

  @override
  void update(void Function(ConsentOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConsentOut build() => _build();

  _$ConsentOut _build() {
    final _$result = _$v ??
        _$ConsentOut._(
          consentType: BuiltValueNullFieldError.checkNotNull(
              consentType, r'ConsentOut', 'consentType'),
          consentVersion: BuiltValueNullFieldError.checkNotNull(
              consentVersion, r'ConsentOut', 'consentVersion'),
          farmerId: BuiltValueNullFieldError.checkNotNull(
              farmerId, r'ConsentOut', 'farmerId'),
          givenAt: BuiltValueNullFieldError.checkNotNull(
              givenAt, r'ConsentOut', 'givenAt'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'ConsentOut', 'id'),
          recordingRef: recordingRef,
          revokedAt: revokedAt,
          witnessedByUserId: witnessedByUserId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
