// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InstrumentOut extends InstrumentOut {
  @override
  final bool? active;
  @override
  final Date? calibratedOn;
  @override
  final String? calibrationCertPhotoId;
  @override
  final Date? calibrationDueOn;
  @override
  final String fpoId;
  @override
  final String id;
  @override
  final InstrumentKind kind;
  @override
  final String makeModel;
  @override
  final String serialNo;

  factory _$InstrumentOut([void Function(InstrumentOutBuilder)? updates]) =>
      (InstrumentOutBuilder()..update(updates))._build();

  _$InstrumentOut._(
      {this.active,
      this.calibratedOn,
      this.calibrationCertPhotoId,
      this.calibrationDueOn,
      required this.fpoId,
      required this.id,
      required this.kind,
      required this.makeModel,
      required this.serialNo})
      : super._();
  @override
  InstrumentOut rebuild(void Function(InstrumentOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InstrumentOutBuilder toBuilder() => InstrumentOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InstrumentOut &&
        active == other.active &&
        calibratedOn == other.calibratedOn &&
        calibrationCertPhotoId == other.calibrationCertPhotoId &&
        calibrationDueOn == other.calibrationDueOn &&
        fpoId == other.fpoId &&
        id == other.id &&
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
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, makeModel.hashCode);
    _$hash = $jc(_$hash, serialNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InstrumentOut')
          ..add('active', active)
          ..add('calibratedOn', calibratedOn)
          ..add('calibrationCertPhotoId', calibrationCertPhotoId)
          ..add('calibrationDueOn', calibrationDueOn)
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('kind', kind)
          ..add('makeModel', makeModel)
          ..add('serialNo', serialNo))
        .toString();
  }
}

class InstrumentOutBuilder
    implements Builder<InstrumentOut, InstrumentOutBuilder> {
  _$InstrumentOut? _$v;

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

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  InstrumentKind? _kind;
  InstrumentKind? get kind => _$this._kind;
  set kind(InstrumentKind? kind) => _$this._kind = kind;

  String? _makeModel;
  String? get makeModel => _$this._makeModel;
  set makeModel(String? makeModel) => _$this._makeModel = makeModel;

  String? _serialNo;
  String? get serialNo => _$this._serialNo;
  set serialNo(String? serialNo) => _$this._serialNo = serialNo;

  InstrumentOutBuilder() {
    InstrumentOut._defaults(this);
  }

  InstrumentOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _calibratedOn = $v.calibratedOn;
      _calibrationCertPhotoId = $v.calibrationCertPhotoId;
      _calibrationDueOn = $v.calibrationDueOn;
      _fpoId = $v.fpoId;
      _id = $v.id;
      _kind = $v.kind;
      _makeModel = $v.makeModel;
      _serialNo = $v.serialNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InstrumentOut other) {
    _$v = other as _$InstrumentOut;
  }

  @override
  void update(void Function(InstrumentOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InstrumentOut build() => _build();

  _$InstrumentOut _build() {
    final _$result = _$v ??
        _$InstrumentOut._(
          active: active,
          calibratedOn: calibratedOn,
          calibrationCertPhotoId: calibrationCertPhotoId,
          calibrationDueOn: calibrationDueOn,
          fpoId: BuiltValueNullFieldError.checkNotNull(
              fpoId, r'InstrumentOut', 'fpoId'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'InstrumentOut', 'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'InstrumentOut', 'kind'),
          makeModel: BuiltValueNullFieldError.checkNotNull(
              makeModel, r'InstrumentOut', 'makeModel'),
          serialNo: BuiltValueNullFieldError.checkNotNull(
              serialNo, r'InstrumentOut', 'serialNo'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
