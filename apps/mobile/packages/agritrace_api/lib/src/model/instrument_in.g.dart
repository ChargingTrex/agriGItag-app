// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InstrumentIn extends InstrumentIn {
  @override
  final bool? active;
  @override
  final Date? calibratedOn;
  @override
  final String? calibrationCertPhotoId;
  @override
  final Date? calibrationDueOn;
  @override
  final InstrumentKind kind;
  @override
  final String makeModel;
  @override
  final String serialNo;

  factory _$InstrumentIn([void Function(InstrumentInBuilder)? updates]) =>
      (InstrumentInBuilder()..update(updates))._build();

  _$InstrumentIn._(
      {this.active,
      this.calibratedOn,
      this.calibrationCertPhotoId,
      this.calibrationDueOn,
      required this.kind,
      required this.makeModel,
      required this.serialNo})
      : super._();
  @override
  InstrumentIn rebuild(void Function(InstrumentInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InstrumentInBuilder toBuilder() => InstrumentInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InstrumentIn &&
        active == other.active &&
        calibratedOn == other.calibratedOn &&
        calibrationCertPhotoId == other.calibrationCertPhotoId &&
        calibrationDueOn == other.calibrationDueOn &&
        kind == other.kind &&
        makeModel == other.makeModel &&
        serialNo == other.serialNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, calibratedOn.hashCode);
    _$hash = $jc(_$hash, calibrationCertPhotoId.hashCode);
    _$hash = $jc(_$hash, calibrationDueOn.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, makeModel.hashCode);
    _$hash = $jc(_$hash, serialNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InstrumentIn')
          ..add('active', active)
          ..add('calibratedOn', calibratedOn)
          ..add('calibrationCertPhotoId', calibrationCertPhotoId)
          ..add('calibrationDueOn', calibrationDueOn)
          ..add('kind', kind)
          ..add('makeModel', makeModel)
          ..add('serialNo', serialNo))
        .toString();
  }
}

class InstrumentInBuilder
    implements Builder<InstrumentIn, InstrumentInBuilder> {
  _$InstrumentIn? _$v;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  Date? _calibratedOn;
  Date? get calibratedOn => _$this._calibratedOn;
  set calibratedOn(Date? calibratedOn) => _$this._calibratedOn = calibratedOn;

  String? _calibrationCertPhotoId;
  String? get calibrationCertPhotoId => _$this._calibrationCertPhotoId;
  set calibrationCertPhotoId(String? calibrationCertPhotoId) =>
      _$this._calibrationCertPhotoId = calibrationCertPhotoId;

  Date? _calibrationDueOn;
  Date? get calibrationDueOn => _$this._calibrationDueOn;
  set calibrationDueOn(Date? calibrationDueOn) =>
      _$this._calibrationDueOn = calibrationDueOn;

  InstrumentKind? _kind;
  InstrumentKind? get kind => _$this._kind;
  set kind(InstrumentKind? kind) => _$this._kind = kind;

  String? _makeModel;
  String? get makeModel => _$this._makeModel;
  set makeModel(String? makeModel) => _$this._makeModel = makeModel;

  String? _serialNo;
  String? get serialNo => _$this._serialNo;
  set serialNo(String? serialNo) => _$this._serialNo = serialNo;

  InstrumentInBuilder() {
    InstrumentIn._defaults(this);
  }

  InstrumentInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _calibratedOn = $v.calibratedOn;
      _calibrationCertPhotoId = $v.calibrationCertPhotoId;
      _calibrationDueOn = $v.calibrationDueOn;
      _kind = $v.kind;
      _makeModel = $v.makeModel;
      _serialNo = $v.serialNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InstrumentIn other) {
    _$v = other as _$InstrumentIn;
  }

  @override
  void update(void Function(InstrumentInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InstrumentIn build() => _build();

  _$InstrumentIn _build() {
    final _$result = _$v ??
        _$InstrumentIn._(
          active: active,
          calibratedOn: calibratedOn,
          calibrationCertPhotoId: calibrationCertPhotoId,
          calibrationDueOn: calibrationDueOn,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'InstrumentIn', 'kind'),
          makeModel: BuiltValueNullFieldError.checkNotNull(
              makeModel, r'InstrumentIn', 'makeModel'),
          serialNo: BuiltValueNullFieldError.checkNotNull(
              serialNo, r'InstrumentIn', 'serialNo'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
