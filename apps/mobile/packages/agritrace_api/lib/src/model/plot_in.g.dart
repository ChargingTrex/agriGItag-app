// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlotIn extends PlotIn {
  @override
  final String clientId;
  @override
  final String? code;
  @override
  final QuantityInput declaredArea;
  @override
  final DateTime deviceTime;
  @override
  final String farmerId;
  @override
  final FarmingType? farmingType;
  @override
  final String? giTagId;
  @override
  final DateTime? gpsTime;
  @override
  final IrrigationSource? irrigationSource;
  @override
  final String? landRecordRef;
  @override
  final GeoPoint pin;
  @override
  final PinMethod? pinMethod;
  @override
  final String? soilType;
  @override
  final PolygonGeoJSON? walkedBoundary;

  factory _$PlotIn([void Function(PlotInBuilder)? updates]) =>
      (PlotInBuilder()..update(updates))._build();

  _$PlotIn._(
      {required this.clientId,
      this.code,
      required this.declaredArea,
      required this.deviceTime,
      required this.farmerId,
      this.farmingType,
      this.giTagId,
      this.gpsTime,
      this.irrigationSource,
      this.landRecordRef,
      required this.pin,
      this.pinMethod,
      this.soilType,
      this.walkedBoundary})
      : super._();
  @override
  PlotIn rebuild(void Function(PlotInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlotInBuilder toBuilder() => PlotInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlotIn &&
        clientId == other.clientId &&
        code == other.code &&
        declaredArea == other.declaredArea &&
        deviceTime == other.deviceTime &&
        farmerId == other.farmerId &&
        farmingType == other.farmingType &&
        giTagId == other.giTagId &&
        gpsTime == other.gpsTime &&
        irrigationSource == other.irrigationSource &&
        landRecordRef == other.landRecordRef &&
        pin == other.pin &&
        pinMethod == other.pinMethod &&
        soilType == other.soilType &&
        walkedBoundary == other.walkedBoundary;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, declaredArea.hashCode);
    _$hash = $jc(_$hash, deviceTime.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, farmingType.hashCode);
    _$hash = $jc(_$hash, giTagId.hashCode);
    _$hash = $jc(_$hash, gpsTime.hashCode);
    _$hash = $jc(_$hash, irrigationSource.hashCode);
    _$hash = $jc(_$hash, landRecordRef.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, pinMethod.hashCode);
    _$hash = $jc(_$hash, soilType.hashCode);
    _$hash = $jc(_$hash, walkedBoundary.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlotIn')
          ..add('clientId', clientId)
          ..add('code', code)
          ..add('declaredArea', declaredArea)
          ..add('deviceTime', deviceTime)
          ..add('farmerId', farmerId)
          ..add('farmingType', farmingType)
          ..add('giTagId', giTagId)
          ..add('gpsTime', gpsTime)
          ..add('irrigationSource', irrigationSource)
          ..add('landRecordRef', landRecordRef)
          ..add('pin', pin)
          ..add('pinMethod', pinMethod)
          ..add('soilType', soilType)
          ..add('walkedBoundary', walkedBoundary))
        .toString();
  }
}

class PlotInBuilder implements Builder<PlotIn, PlotInBuilder> {
  _$PlotIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  QuantityInputBuilder? _declaredArea;
  QuantityInputBuilder get declaredArea =>
      _$this._declaredArea ??= QuantityInputBuilder();
  set declaredArea(QuantityInputBuilder? declaredArea) =>
      _$this._declaredArea = declaredArea;

  DateTime? _deviceTime;
  DateTime? get deviceTime => _$this._deviceTime;
  set deviceTime(DateTime? deviceTime) => _$this._deviceTime = deviceTime;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  FarmingType? _farmingType;
  FarmingType? get farmingType => _$this._farmingType;
  set farmingType(FarmingType? farmingType) =>
      _$this._farmingType = farmingType;

  String? _giTagId;
  String? get giTagId => _$this._giTagId;
  set giTagId(String? giTagId) => _$this._giTagId = giTagId;

  DateTime? _gpsTime;
  DateTime? get gpsTime => _$this._gpsTime;
  set gpsTime(DateTime? gpsTime) => _$this._gpsTime = gpsTime;

  IrrigationSource? _irrigationSource;
  IrrigationSource? get irrigationSource => _$this._irrigationSource;
  set irrigationSource(IrrigationSource? irrigationSource) =>
      _$this._irrigationSource = irrigationSource;

  String? _landRecordRef;
  String? get landRecordRef => _$this._landRecordRef;
  set landRecordRef(String? landRecordRef) =>
      _$this._landRecordRef = landRecordRef;

  GeoPointBuilder? _pin;
  GeoPointBuilder get pin => _$this._pin ??= GeoPointBuilder();
  set pin(GeoPointBuilder? pin) => _$this._pin = pin;

  PinMethod? _pinMethod;
  PinMethod? get pinMethod => _$this._pinMethod;
  set pinMethod(PinMethod? pinMethod) => _$this._pinMethod = pinMethod;

  String? _soilType;
  String? get soilType => _$this._soilType;
  set soilType(String? soilType) => _$this._soilType = soilType;

  PolygonGeoJSONBuilder? _walkedBoundary;
  PolygonGeoJSONBuilder get walkedBoundary =>
      _$this._walkedBoundary ??= PolygonGeoJSONBuilder();
  set walkedBoundary(PolygonGeoJSONBuilder? walkedBoundary) =>
      _$this._walkedBoundary = walkedBoundary;

  PlotInBuilder() {
    PlotIn._defaults(this);
  }

  PlotInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _code = $v.code;
      _declaredArea = $v.declaredArea.toBuilder();
      _deviceTime = $v.deviceTime;
      _farmerId = $v.farmerId;
      _farmingType = $v.farmingType;
      _giTagId = $v.giTagId;
      _gpsTime = $v.gpsTime;
      _irrigationSource = $v.irrigationSource;
      _landRecordRef = $v.landRecordRef;
      _pin = $v.pin.toBuilder();
      _pinMethod = $v.pinMethod;
      _soilType = $v.soilType;
      _walkedBoundary = $v.walkedBoundary?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlotIn other) {
    _$v = other as _$PlotIn;
  }

  @override
  void update(void Function(PlotInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlotIn build() => _build();

  _$PlotIn _build() {
    _$PlotIn _$result;
    try {
      _$result = _$v ??
          _$PlotIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'PlotIn', 'clientId'),
            code: code,
            declaredArea: declaredArea.build(),
            deviceTime: BuiltValueNullFieldError.checkNotNull(
                deviceTime, r'PlotIn', 'deviceTime'),
            farmerId: BuiltValueNullFieldError.checkNotNull(
                farmerId, r'PlotIn', 'farmerId'),
            farmingType: farmingType,
            giTagId: giTagId,
            gpsTime: gpsTime,
            irrigationSource: irrigationSource,
            landRecordRef: landRecordRef,
            pin: pin.build(),
            pinMethod: pinMethod,
            soilType: soilType,
            walkedBoundary: _walkedBoundary?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declaredArea';
        declaredArea.build();

        _$failedField = 'pin';
        pin.build();

        _$failedField = 'walkedBoundary';
        _walkedBoundary?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlotIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
