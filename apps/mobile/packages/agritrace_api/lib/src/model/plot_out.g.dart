// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlotOut extends PlotOut {
  @override
  final bool areaGapExceeds;
  @override
  final String? areaGapPct;
  @override
  final String code;
  @override
  final QuantityOutput declaredArea;
  @override
  final String farmerId;
  @override
  final FarmingType? farmingType;
  @override
  final String fpoId;
  @override
  final String id;
  @override
  final IrrigationSource? irrigationSource;
  @override
  final String? landRecordRef;
  @override
  final String? locationMethodLabel;
  @override
  final LocationStatus locationStatus;
  @override
  final GeoPoint pin;
  @override
  final DateTime pinDeviceTime;
  @override
  final DateTime? pinGpsTime;
  @override
  final PinMethod pinMethod;
  @override
  final DateTime pinServerReceivedAt;
  @override
  final RegionCheckOut? regionCheck;
  @override
  final String? reviewMethod;
  @override
  final String? reviewOutcome;
  @override
  final DateTime? reviewedAt;
  @override
  final int revisionNo;
  @override
  final String? soilType;
  @override
  final QuantityOutput? walkedArea;

  factory _$PlotOut([void Function(PlotOutBuilder)? updates]) =>
      (PlotOutBuilder()..update(updates))._build();

  _$PlotOut._(
      {required this.areaGapExceeds,
      this.areaGapPct,
      required this.code,
      required this.declaredArea,
      required this.farmerId,
      this.farmingType,
      required this.fpoId,
      required this.id,
      this.irrigationSource,
      this.landRecordRef,
      this.locationMethodLabel,
      required this.locationStatus,
      required this.pin,
      required this.pinDeviceTime,
      this.pinGpsTime,
      required this.pinMethod,
      required this.pinServerReceivedAt,
      this.regionCheck,
      this.reviewMethod,
      this.reviewOutcome,
      this.reviewedAt,
      required this.revisionNo,
      this.soilType,
      this.walkedArea})
      : super._();
  @override
  PlotOut rebuild(void Function(PlotOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlotOutBuilder toBuilder() => PlotOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlotOut &&
        areaGapExceeds == other.areaGapExceeds &&
        areaGapPct == other.areaGapPct &&
        code == other.code &&
        declaredArea == other.declaredArea &&
        farmerId == other.farmerId &&
        farmingType == other.farmingType &&
        fpoId == other.fpoId &&
        id == other.id &&
        irrigationSource == other.irrigationSource &&
        landRecordRef == other.landRecordRef &&
        locationMethodLabel == other.locationMethodLabel &&
        locationStatus == other.locationStatus &&
        pin == other.pin &&
        pinDeviceTime == other.pinDeviceTime &&
        pinGpsTime == other.pinGpsTime &&
        pinMethod == other.pinMethod &&
        pinServerReceivedAt == other.pinServerReceivedAt &&
        regionCheck == other.regionCheck &&
        reviewMethod == other.reviewMethod &&
        reviewOutcome == other.reviewOutcome &&
        reviewedAt == other.reviewedAt &&
        revisionNo == other.revisionNo &&
        soilType == other.soilType &&
        walkedArea == other.walkedArea;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, areaGapExceeds.hashCode);
    _$hash = $jc(_$hash, areaGapPct.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, declaredArea.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, farmingType.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, irrigationSource.hashCode);
    _$hash = $jc(_$hash, landRecordRef.hashCode);
    _$hash = $jc(_$hash, locationMethodLabel.hashCode);
    _$hash = $jc(_$hash, locationStatus.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, pinDeviceTime.hashCode);
    _$hash = $jc(_$hash, pinGpsTime.hashCode);
    _$hash = $jc(_$hash, pinMethod.hashCode);
    _$hash = $jc(_$hash, pinServerReceivedAt.hashCode);
    _$hash = $jc(_$hash, regionCheck.hashCode);
    _$hash = $jc(_$hash, reviewMethod.hashCode);
    _$hash = $jc(_$hash, reviewOutcome.hashCode);
    _$hash = $jc(_$hash, reviewedAt.hashCode);
    _$hash = $jc(_$hash, revisionNo.hashCode);
    _$hash = $jc(_$hash, soilType.hashCode);
    _$hash = $jc(_$hash, walkedArea.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlotOut')
          ..add('areaGapExceeds', areaGapExceeds)
          ..add('areaGapPct', areaGapPct)
          ..add('code', code)
          ..add('declaredArea', declaredArea)
          ..add('farmerId', farmerId)
          ..add('farmingType', farmingType)
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('irrigationSource', irrigationSource)
          ..add('landRecordRef', landRecordRef)
          ..add('locationMethodLabel', locationMethodLabel)
          ..add('locationStatus', locationStatus)
          ..add('pin', pin)
          ..add('pinDeviceTime', pinDeviceTime)
          ..add('pinGpsTime', pinGpsTime)
          ..add('pinMethod', pinMethod)
          ..add('pinServerReceivedAt', pinServerReceivedAt)
          ..add('regionCheck', regionCheck)
          ..add('reviewMethod', reviewMethod)
          ..add('reviewOutcome', reviewOutcome)
          ..add('reviewedAt', reviewedAt)
          ..add('revisionNo', revisionNo)
          ..add('soilType', soilType)
          ..add('walkedArea', walkedArea))
        .toString();
  }
}

class PlotOutBuilder implements Builder<PlotOut, PlotOutBuilder> {
  _$PlotOut? _$v;

  bool? _areaGapExceeds;
  bool? get areaGapExceeds => _$this._areaGapExceeds;
  set areaGapExceeds(bool? areaGapExceeds) =>
      _$this._areaGapExceeds = areaGapExceeds;

  String? _areaGapPct;
  String? get areaGapPct => _$this._areaGapPct;
  set areaGapPct(String? areaGapPct) => _$this._areaGapPct = areaGapPct;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  QuantityOutputBuilder? _declaredArea;
  QuantityOutputBuilder get declaredArea =>
      _$this._declaredArea ??= QuantityOutputBuilder();
  set declaredArea(QuantityOutputBuilder? declaredArea) =>
      _$this._declaredArea = declaredArea;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  FarmingType? _farmingType;
  FarmingType? get farmingType => _$this._farmingType;
  set farmingType(FarmingType? farmingType) =>
      _$this._farmingType = farmingType;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  IrrigationSource? _irrigationSource;
  IrrigationSource? get irrigationSource => _$this._irrigationSource;
  set irrigationSource(IrrigationSource? irrigationSource) =>
      _$this._irrigationSource = irrigationSource;

  String? _landRecordRef;
  String? get landRecordRef => _$this._landRecordRef;
  set landRecordRef(String? landRecordRef) =>
      _$this._landRecordRef = landRecordRef;

  String? _locationMethodLabel;
  String? get locationMethodLabel => _$this._locationMethodLabel;
  set locationMethodLabel(String? locationMethodLabel) =>
      _$this._locationMethodLabel = locationMethodLabel;

  LocationStatus? _locationStatus;
  LocationStatus? get locationStatus => _$this._locationStatus;
  set locationStatus(LocationStatus? locationStatus) =>
      _$this._locationStatus = locationStatus;

  GeoPointBuilder? _pin;
  GeoPointBuilder get pin => _$this._pin ??= GeoPointBuilder();
  set pin(GeoPointBuilder? pin) => _$this._pin = pin;

  DateTime? _pinDeviceTime;
  DateTime? get pinDeviceTime => _$this._pinDeviceTime;
  set pinDeviceTime(DateTime? pinDeviceTime) =>
      _$this._pinDeviceTime = pinDeviceTime;

  DateTime? _pinGpsTime;
  DateTime? get pinGpsTime => _$this._pinGpsTime;
  set pinGpsTime(DateTime? pinGpsTime) => _$this._pinGpsTime = pinGpsTime;

  PinMethod? _pinMethod;
  PinMethod? get pinMethod => _$this._pinMethod;
  set pinMethod(PinMethod? pinMethod) => _$this._pinMethod = pinMethod;

  DateTime? _pinServerReceivedAt;
  DateTime? get pinServerReceivedAt => _$this._pinServerReceivedAt;
  set pinServerReceivedAt(DateTime? pinServerReceivedAt) =>
      _$this._pinServerReceivedAt = pinServerReceivedAt;

  RegionCheckOutBuilder? _regionCheck;
  RegionCheckOutBuilder get regionCheck =>
      _$this._regionCheck ??= RegionCheckOutBuilder();
  set regionCheck(RegionCheckOutBuilder? regionCheck) =>
      _$this._regionCheck = regionCheck;

  String? _reviewMethod;
  String? get reviewMethod => _$this._reviewMethod;
  set reviewMethod(String? reviewMethod) => _$this._reviewMethod = reviewMethod;

  String? _reviewOutcome;
  String? get reviewOutcome => _$this._reviewOutcome;
  set reviewOutcome(String? reviewOutcome) =>
      _$this._reviewOutcome = reviewOutcome;

  DateTime? _reviewedAt;
  DateTime? get reviewedAt => _$this._reviewedAt;
  set reviewedAt(DateTime? reviewedAt) => _$this._reviewedAt = reviewedAt;

  int? _revisionNo;
  int? get revisionNo => _$this._revisionNo;
  set revisionNo(int? revisionNo) => _$this._revisionNo = revisionNo;

  String? _soilType;
  String? get soilType => _$this._soilType;
  set soilType(String? soilType) => _$this._soilType = soilType;

  QuantityOutputBuilder? _walkedArea;
  QuantityOutputBuilder get walkedArea =>
      _$this._walkedArea ??= QuantityOutputBuilder();
  set walkedArea(QuantityOutputBuilder? walkedArea) =>
      _$this._walkedArea = walkedArea;

  PlotOutBuilder() {
    PlotOut._defaults(this);
  }

  PlotOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _areaGapExceeds = $v.areaGapExceeds;
      _areaGapPct = $v.areaGapPct;
      _code = $v.code;
      _declaredArea = $v.declaredArea.toBuilder();
      _farmerId = $v.farmerId;
      _farmingType = $v.farmingType;
      _fpoId = $v.fpoId;
      _id = $v.id;
      _irrigationSource = $v.irrigationSource;
      _landRecordRef = $v.landRecordRef;
      _locationMethodLabel = $v.locationMethodLabel;
      _locationStatus = $v.locationStatus;
      _pin = $v.pin.toBuilder();
      _pinDeviceTime = $v.pinDeviceTime;
      _pinGpsTime = $v.pinGpsTime;
      _pinMethod = $v.pinMethod;
      _pinServerReceivedAt = $v.pinServerReceivedAt;
      _regionCheck = $v.regionCheck?.toBuilder();
      _reviewMethod = $v.reviewMethod;
      _reviewOutcome = $v.reviewOutcome;
      _reviewedAt = $v.reviewedAt;
      _revisionNo = $v.revisionNo;
      _soilType = $v.soilType;
      _walkedArea = $v.walkedArea?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlotOut other) {
    _$v = other as _$PlotOut;
  }

  @override
  void update(void Function(PlotOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlotOut build() => _build();

  _$PlotOut _build() {
    _$PlotOut _$result;
    try {
      _$result = _$v ??
          _$PlotOut._(
            areaGapExceeds: BuiltValueNullFieldError.checkNotNull(
                areaGapExceeds, r'PlotOut', 'areaGapExceeds'),
            areaGapPct: areaGapPct,
            code:
                BuiltValueNullFieldError.checkNotNull(code, r'PlotOut', 'code'),
            declaredArea: declaredArea.build(),
            farmerId: BuiltValueNullFieldError.checkNotNull(
                farmerId, r'PlotOut', 'farmerId'),
            farmingType: farmingType,
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'PlotOut', 'fpoId'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'PlotOut', 'id'),
            irrigationSource: irrigationSource,
            landRecordRef: landRecordRef,
            locationMethodLabel: locationMethodLabel,
            locationStatus: BuiltValueNullFieldError.checkNotNull(
                locationStatus, r'PlotOut', 'locationStatus'),
            pin: pin.build(),
            pinDeviceTime: BuiltValueNullFieldError.checkNotNull(
                pinDeviceTime, r'PlotOut', 'pinDeviceTime'),
            pinGpsTime: pinGpsTime,
            pinMethod: BuiltValueNullFieldError.checkNotNull(
                pinMethod, r'PlotOut', 'pinMethod'),
            pinServerReceivedAt: BuiltValueNullFieldError.checkNotNull(
                pinServerReceivedAt, r'PlotOut', 'pinServerReceivedAt'),
            regionCheck: _regionCheck?.build(),
            reviewMethod: reviewMethod,
            reviewOutcome: reviewOutcome,
            reviewedAt: reviewedAt,
            revisionNo: BuiltValueNullFieldError.checkNotNull(
                revisionNo, r'PlotOut', 'revisionNo'),
            soilType: soilType,
            walkedArea: _walkedArea?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declaredArea';
        declaredArea.build();

        _$failedField = 'pin';
        pin.build();

        _$failedField = 'regionCheck';
        _regionCheck?.build();

        _$failedField = 'walkedArea';
        _walkedArea?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlotOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
