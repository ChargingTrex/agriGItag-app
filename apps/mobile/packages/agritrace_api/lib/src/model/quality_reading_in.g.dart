// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_reading_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QualityReadingIn extends QualityReadingIn {
  @override
  final String? batchId;
  @override
  final String? certificatePhotoId;
  @override
  final String clientId;
  @override
  final DateTime? deviceTime;
  @override
  final String? evidencePhotoId;
  @override
  final GeoPoint? gps;
  @override
  final DateTime? gpsTime;
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
  final SignedQuantityInput measurement;
  @override
  final String? methodRef;
  @override
  final String parameterCode;
  @override
  final String? reasonCode;
  @override
  final String? sampleId;
  @override
  final ReadingSource source_;
  @override
  final ReadingStage stage;

  factory _$QualityReadingIn(
          [void Function(QualityReadingInBuilder)? updates]) =>
      (QualityReadingInBuilder()..update(updates))._build();

  _$QualityReadingIn._(
      {this.batchId,
      this.certificatePhotoId,
      required this.clientId,
      this.deviceTime,
      this.evidencePhotoId,
      this.gps,
      this.gpsTime,
      this.instrumentId,
      this.labNablNo,
      this.labName,
      this.lotId,
      required this.measuredAt,
      required this.measurement,
      this.methodRef,
      required this.parameterCode,
      this.reasonCode,
      this.sampleId,
      required this.source_,
      required this.stage})
      : super._();
  @override
  QualityReadingIn rebuild(void Function(QualityReadingInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QualityReadingInBuilder toBuilder() =>
      QualityReadingInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QualityReadingIn &&
        batchId == other.batchId &&
        certificatePhotoId == other.certificatePhotoId &&
        clientId == other.clientId &&
        deviceTime == other.deviceTime &&
        evidencePhotoId == other.evidencePhotoId &&
        gps == other.gps &&
        gpsTime == other.gpsTime &&
        instrumentId == other.instrumentId &&
        labNablNo == other.labNablNo &&
        labName == other.labName &&
        lotId == other.lotId &&
        measuredAt == other.measuredAt &&
        measurement == other.measurement &&
        methodRef == other.methodRef &&
        parameterCode == other.parameterCode &&
        reasonCode == other.reasonCode &&
        sampleId == other.sampleId &&
        source_ == other.source_ &&
        stage == other.stage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, certificatePhotoId.hashCode);
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, deviceTime.hashCode);
    _$hash = $jc(_$hash, evidencePhotoId.hashCode);
    _$hash = $jc(_$hash, gps.hashCode);
    _$hash = $jc(_$hash, gpsTime.hashCode);
    _$hash = $jc(_$hash, instrumentId.hashCode);
    _$hash = $jc(_$hash, labNablNo.hashCode);
    _$hash = $jc(_$hash, labName.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, measuredAt.hashCode);
    _$hash = $jc(_$hash, measurement.hashCode);
    _$hash = $jc(_$hash, methodRef.hashCode);
    _$hash = $jc(_$hash, parameterCode.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, sampleId.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QualityReadingIn')
          ..add('batchId', batchId)
          ..add('certificatePhotoId', certificatePhotoId)
          ..add('clientId', clientId)
          ..add('deviceTime', deviceTime)
          ..add('evidencePhotoId', evidencePhotoId)
          ..add('gps', gps)
          ..add('gpsTime', gpsTime)
          ..add('instrumentId', instrumentId)
          ..add('labNablNo', labNablNo)
          ..add('labName', labName)
          ..add('lotId', lotId)
          ..add('measuredAt', measuredAt)
          ..add('measurement', measurement)
          ..add('methodRef', methodRef)
          ..add('parameterCode', parameterCode)
          ..add('reasonCode', reasonCode)
          ..add('sampleId', sampleId)
          ..add('source_', source_)
          ..add('stage', stage))
        .toString();
  }
}

class QualityReadingInBuilder
    implements Builder<QualityReadingIn, QualityReadingInBuilder> {
  _$QualityReadingIn? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  String? _certificatePhotoId;
  String? get certificatePhotoId => _$this._certificatePhotoId;
  set certificatePhotoId(String? certificatePhotoId) =>
      _$this._certificatePhotoId = certificatePhotoId;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  DateTime? _deviceTime;
  DateTime? get deviceTime => _$this._deviceTime;
  set deviceTime(DateTime? deviceTime) => _$this._deviceTime = deviceTime;

  String? _evidencePhotoId;
  String? get evidencePhotoId => _$this._evidencePhotoId;
  set evidencePhotoId(String? evidencePhotoId) =>
      _$this._evidencePhotoId = evidencePhotoId;

  GeoPointBuilder? _gps;
  GeoPointBuilder get gps => _$this._gps ??= GeoPointBuilder();
  set gps(GeoPointBuilder? gps) => _$this._gps = gps;

  DateTime? _gpsTime;
  DateTime? get gpsTime => _$this._gpsTime;
  set gpsTime(DateTime? gpsTime) => _$this._gpsTime = gpsTime;

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

  SignedQuantityInputBuilder? _measurement;
  SignedQuantityInputBuilder get measurement =>
      _$this._measurement ??= SignedQuantityInputBuilder();
  set measurement(SignedQuantityInputBuilder? measurement) =>
      _$this._measurement = measurement;

  String? _methodRef;
  String? get methodRef => _$this._methodRef;
  set methodRef(String? methodRef) => _$this._methodRef = methodRef;

  String? _parameterCode;
  String? get parameterCode => _$this._parameterCode;
  set parameterCode(String? parameterCode) =>
      _$this._parameterCode = parameterCode;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _sampleId;
  String? get sampleId => _$this._sampleId;
  set sampleId(String? sampleId) => _$this._sampleId = sampleId;

  ReadingSource? _source_;
  ReadingSource? get source_ => _$this._source_;
  set source_(ReadingSource? source_) => _$this._source_ = source_;

  ReadingStage? _stage;
  ReadingStage? get stage => _$this._stage;
  set stage(ReadingStage? stage) => _$this._stage = stage;

  QualityReadingInBuilder() {
    QualityReadingIn._defaults(this);
  }

  QualityReadingInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _certificatePhotoId = $v.certificatePhotoId;
      _clientId = $v.clientId;
      _deviceTime = $v.deviceTime;
      _evidencePhotoId = $v.evidencePhotoId;
      _gps = $v.gps?.toBuilder();
      _gpsTime = $v.gpsTime;
      _instrumentId = $v.instrumentId;
      _labNablNo = $v.labNablNo;
      _labName = $v.labName;
      _lotId = $v.lotId;
      _measuredAt = $v.measuredAt;
      _measurement = $v.measurement.toBuilder();
      _methodRef = $v.methodRef;
      _parameterCode = $v.parameterCode;
      _reasonCode = $v.reasonCode;
      _sampleId = $v.sampleId;
      _source_ = $v.source_;
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QualityReadingIn other) {
    _$v = other as _$QualityReadingIn;
  }

  @override
  void update(void Function(QualityReadingInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QualityReadingIn build() => _build();

  _$QualityReadingIn _build() {
    _$QualityReadingIn _$result;
    try {
      _$result = _$v ??
          _$QualityReadingIn._(
            batchId: batchId,
            certificatePhotoId: certificatePhotoId,
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'QualityReadingIn', 'clientId'),
            deviceTime: deviceTime,
            evidencePhotoId: evidencePhotoId,
            gps: _gps?.build(),
            gpsTime: gpsTime,
            instrumentId: instrumentId,
            labNablNo: labNablNo,
            labName: labName,
            lotId: lotId,
            measuredAt: BuiltValueNullFieldError.checkNotNull(
                measuredAt, r'QualityReadingIn', 'measuredAt'),
            measurement: measurement.build(),
            methodRef: methodRef,
            parameterCode: BuiltValueNullFieldError.checkNotNull(
                parameterCode, r'QualityReadingIn', 'parameterCode'),
            reasonCode: reasonCode,
            sampleId: sampleId,
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'QualityReadingIn', 'source_'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'QualityReadingIn', 'stage'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'gps';
        _gps?.build();

        _$failedField = 'measurement';
        measurement.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QualityReadingIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
