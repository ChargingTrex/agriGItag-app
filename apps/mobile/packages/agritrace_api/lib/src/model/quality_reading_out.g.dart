// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_reading_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QualityReadingOut extends QualityReadingOut {
  @override
  final String? batchId;
  @override
  final Date? calibrationDueOnAtTime;
  @override
  final String fpoId;
  @override
  final String id;
  @override
  final String? instrumentId;
  @override
  final String? labNablNo;
  @override
  final String? labName;
  @override
  final String? lotId;
  @override
  final DateTime measuredAt;
  @override
  final String measuredByUserId;
  @override
  final SignedQuantityOutput measurement;
  @override
  final String? methodRef;
  @override
  final String parameterCode;
  @override
  final String? profileVersionId;
  @override
  final String? reasonCode;
  @override
  final String? sampleId;
  @override
  final DateTime serverReceivedAt;
  @override
  final ReadingSource source_;
  @override
  final ReadingStage stage;

  factory _$QualityReadingOut(
          [void Function(QualityReadingOutBuilder)? updates]) =>
      (QualityReadingOutBuilder()..update(updates))._build();

  _$QualityReadingOut._(
      {this.batchId,
      this.calibrationDueOnAtTime,
      required this.fpoId,
      required this.id,
      this.instrumentId,
      this.labNablNo,
      this.labName,
      this.lotId,
      required this.measuredAt,
      required this.measuredByUserId,
      required this.measurement,
      this.methodRef,
      required this.parameterCode,
      this.profileVersionId,
      this.reasonCode,
      this.sampleId,
      required this.serverReceivedAt,
      required this.source_,
      required this.stage})
      : super._();
  @override
  QualityReadingOut rebuild(void Function(QualityReadingOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QualityReadingOutBuilder toBuilder() =>
      QualityReadingOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QualityReadingOut &&
        batchId == other.batchId &&
        calibrationDueOnAtTime == other.calibrationDueOnAtTime &&
        fpoId == other.fpoId &&
        id == other.id &&
        instrumentId == other.instrumentId &&
        labNablNo == other.labNablNo &&
        labName == other.labName &&
        lotId == other.lotId &&
        measuredAt == other.measuredAt &&
        measuredByUserId == other.measuredByUserId &&
        measurement == other.measurement &&
        methodRef == other.methodRef &&
        parameterCode == other.parameterCode &&
        profileVersionId == other.profileVersionId &&
        reasonCode == other.reasonCode &&
        sampleId == other.sampleId &&
        serverReceivedAt == other.serverReceivedAt &&
        source_ == other.source_ &&
        stage == other.stage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, calibrationDueOnAtTime.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, instrumentId.hashCode);
    _$hash = $jc(_$hash, labNablNo.hashCode);
    _$hash = $jc(_$hash, labName.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, measuredAt.hashCode);
    _$hash = $jc(_$hash, measuredByUserId.hashCode);
    _$hash = $jc(_$hash, measurement.hashCode);
    _$hash = $jc(_$hash, methodRef.hashCode);
    _$hash = $jc(_$hash, parameterCode.hashCode);
    _$hash = $jc(_$hash, profileVersionId.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, sampleId.hashCode);
    _$hash = $jc(_$hash, serverReceivedAt.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QualityReadingOut')
          ..add('batchId', batchId)
          ..add('calibrationDueOnAtTime', calibrationDueOnAtTime)
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('instrumentId', instrumentId)
          ..add('labNablNo', labNablNo)
          ..add('labName', labName)
          ..add('lotId', lotId)
          ..add('measuredAt', measuredAt)
          ..add('measuredByUserId', measuredByUserId)
          ..add('measurement', measurement)
          ..add('methodRef', methodRef)
          ..add('parameterCode', parameterCode)
          ..add('profileVersionId', profileVersionId)
          ..add('reasonCode', reasonCode)
          ..add('sampleId', sampleId)
          ..add('serverReceivedAt', serverReceivedAt)
          ..add('source_', source_)
          ..add('stage', stage))
        .toString();
  }
}

class QualityReadingOutBuilder
    implements Builder<QualityReadingOut, QualityReadingOutBuilder> {
  _$QualityReadingOut? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  Date? _calibrationDueOnAtTime;
  Date? get calibrationDueOnAtTime => _$this._calibrationDueOnAtTime;
  set calibrationDueOnAtTime(Date? calibrationDueOnAtTime) =>
      _$this._calibrationDueOnAtTime = calibrationDueOnAtTime;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _instrumentId;
  String? get instrumentId => _$this._instrumentId;
  set instrumentId(String? instrumentId) => _$this._instrumentId = instrumentId;

  String? _labNablNo;
  String? get labNablNo => _$this._labNablNo;
  set labNablNo(String? labNablNo) => _$this._labNablNo = labNablNo;

  String? _labName;
  String? get labName => _$this._labName;
  set labName(String? labName) => _$this._labName = labName;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  DateTime? _measuredAt;
  DateTime? get measuredAt => _$this._measuredAt;
  set measuredAt(DateTime? measuredAt) => _$this._measuredAt = measuredAt;

  String? _measuredByUserId;
  String? get measuredByUserId => _$this._measuredByUserId;
  set measuredByUserId(String? measuredByUserId) =>
      _$this._measuredByUserId = measuredByUserId;

  SignedQuantityOutputBuilder? _measurement;
  SignedQuantityOutputBuilder get measurement =>
      _$this._measurement ??= SignedQuantityOutputBuilder();
  set measurement(SignedQuantityOutputBuilder? measurement) =>
      _$this._measurement = measurement;

  String? _methodRef;
  String? get methodRef => _$this._methodRef;
  set methodRef(String? methodRef) => _$this._methodRef = methodRef;

  String? _parameterCode;
  String? get parameterCode => _$this._parameterCode;
  set parameterCode(String? parameterCode) =>
      _$this._parameterCode = parameterCode;

  String? _profileVersionId;
  String? get profileVersionId => _$this._profileVersionId;
  set profileVersionId(String? profileVersionId) =>
      _$this._profileVersionId = profileVersionId;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _sampleId;
  String? get sampleId => _$this._sampleId;
  set sampleId(String? sampleId) => _$this._sampleId = sampleId;

  DateTime? _serverReceivedAt;
  DateTime? get serverReceivedAt => _$this._serverReceivedAt;
  set serverReceivedAt(DateTime? serverReceivedAt) =>
      _$this._serverReceivedAt = serverReceivedAt;

  ReadingSource? _source_;
  ReadingSource? get source_ => _$this._source_;
  set source_(ReadingSource? source_) => _$this._source_ = source_;

  ReadingStage? _stage;
  ReadingStage? get stage => _$this._stage;
  set stage(ReadingStage? stage) => _$this._stage = stage;

  QualityReadingOutBuilder() {
    QualityReadingOut._defaults(this);
  }

  QualityReadingOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _calibrationDueOnAtTime = $v.calibrationDueOnAtTime;
      _fpoId = $v.fpoId;
      _id = $v.id;
      _instrumentId = $v.instrumentId;
      _labNablNo = $v.labNablNo;
      _labName = $v.labName;
      _lotId = $v.lotId;
      _measuredAt = $v.measuredAt;
      _measuredByUserId = $v.measuredByUserId;
      _measurement = $v.measurement.toBuilder();
      _methodRef = $v.methodRef;
      _parameterCode = $v.parameterCode;
      _profileVersionId = $v.profileVersionId;
      _reasonCode = $v.reasonCode;
      _sampleId = $v.sampleId;
      _serverReceivedAt = $v.serverReceivedAt;
      _source_ = $v.source_;
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QualityReadingOut other) {
    _$v = other as _$QualityReadingOut;
  }

  @override
  void update(void Function(QualityReadingOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QualityReadingOut build() => _build();

  _$QualityReadingOut _build() {
    _$QualityReadingOut _$result;
    try {
      _$result = _$v ??
          _$QualityReadingOut._(
            batchId: batchId,
            calibrationDueOnAtTime: calibrationDueOnAtTime,
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'QualityReadingOut', 'fpoId'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'QualityReadingOut', 'id'),
            instrumentId: instrumentId,
            labNablNo: labNablNo,
            labName: labName,
            lotId: lotId,
            measuredAt: BuiltValueNullFieldError.checkNotNull(
                measuredAt, r'QualityReadingOut', 'measuredAt'),
            measuredByUserId: BuiltValueNullFieldError.checkNotNull(
                measuredByUserId, r'QualityReadingOut', 'measuredByUserId'),
            measurement: measurement.build(),
            methodRef: methodRef,
            parameterCode: BuiltValueNullFieldError.checkNotNull(
                parameterCode, r'QualityReadingOut', 'parameterCode'),
            profileVersionId: profileVersionId,
            reasonCode: reasonCode,
            sampleId: sampleId,
            serverReceivedAt: BuiltValueNullFieldError.checkNotNull(
                serverReceivedAt, r'QualityReadingOut', 'serverReceivedAt'),
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'QualityReadingOut', 'source_'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'QualityReadingOut', 'stage'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'measurement';
        measurement.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QualityReadingOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
