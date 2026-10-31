// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_correction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlotCorrectionReviewMethodEnum
    _$plotCorrectionReviewMethodEnum_landRecord =
    const PlotCorrectionReviewMethodEnum._('landRecord');
const PlotCorrectionReviewMethodEnum
    _$plotCorrectionReviewMethodEnum_satellite =
    const PlotCorrectionReviewMethodEnum._('satellite');
const PlotCorrectionReviewMethodEnum
    _$plotCorrectionReviewMethodEnum_fieldVisit =
    const PlotCorrectionReviewMethodEnum._('fieldVisit');

PlotCorrectionReviewMethodEnum _$plotCorrectionReviewMethodEnumValueOf(
    String name) {
  switch (name) {
    case 'landRecord':
      return _$plotCorrectionReviewMethodEnum_landRecord;
    case 'satellite':
      return _$plotCorrectionReviewMethodEnum_satellite;
    case 'fieldVisit':
      return _$plotCorrectionReviewMethodEnum_fieldVisit;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlotCorrectionReviewMethodEnum>
    _$plotCorrectionReviewMethodEnumValues = BuiltSet<
        PlotCorrectionReviewMethodEnum>(const <PlotCorrectionReviewMethodEnum>[
  _$plotCorrectionReviewMethodEnum_landRecord,
  _$plotCorrectionReviewMethodEnum_satellite,
  _$plotCorrectionReviewMethodEnum_fieldVisit,
]);

const PlotCorrectionReviewOutcomeEnum
    _$plotCorrectionReviewOutcomeEnum_accepted =
    const PlotCorrectionReviewOutcomeEnum._('accepted');
const PlotCorrectionReviewOutcomeEnum
    _$plotCorrectionReviewOutcomeEnum_rejected =
    const PlotCorrectionReviewOutcomeEnum._('rejected');

PlotCorrectionReviewOutcomeEnum _$plotCorrectionReviewOutcomeEnumValueOf(
    String name) {
  switch (name) {
    case 'accepted':
      return _$plotCorrectionReviewOutcomeEnum_accepted;
    case 'rejected':
      return _$plotCorrectionReviewOutcomeEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlotCorrectionReviewOutcomeEnum>
    _$plotCorrectionReviewOutcomeEnumValues = BuiltSet<
        PlotCorrectionReviewOutcomeEnum>(const <PlotCorrectionReviewOutcomeEnum>[
  _$plotCorrectionReviewOutcomeEnum_accepted,
  _$plotCorrectionReviewOutcomeEnum_rejected,
]);

Serializer<PlotCorrectionReviewMethodEnum>
    _$plotCorrectionReviewMethodEnumSerializer =
    _$PlotCorrectionReviewMethodEnumSerializer();
Serializer<PlotCorrectionReviewOutcomeEnum>
    _$plotCorrectionReviewOutcomeEnumSerializer =
    _$PlotCorrectionReviewOutcomeEnumSerializer();

class _$PlotCorrectionReviewMethodEnumSerializer
    implements PrimitiveSerializer<PlotCorrectionReviewMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'landRecord': 'land_record',
    'satellite': 'satellite',
    'fieldVisit': 'field_visit',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'land_record': 'landRecord',
    'satellite': 'satellite',
    'field_visit': 'fieldVisit',
  };

  @override
  final Iterable<Type> types = const <Type>[PlotCorrectionReviewMethodEnum];
  @override
  final String wireName = 'PlotCorrectionReviewMethodEnum';

  @override
  Object serialize(
          Serializers serializers, PlotCorrectionReviewMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlotCorrectionReviewMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlotCorrectionReviewMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlotCorrectionReviewOutcomeEnumSerializer
    implements PrimitiveSerializer<PlotCorrectionReviewOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'accepted': 'accepted',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accepted': 'accepted',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[PlotCorrectionReviewOutcomeEnum];
  @override
  final String wireName = 'PlotCorrectionReviewOutcomeEnum';

  @override
  Object serialize(
          Serializers serializers, PlotCorrectionReviewOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlotCorrectionReviewOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlotCorrectionReviewOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlotCorrection extends PlotCorrection {
  @override
  final QuantityInput? declaredArea;
  @override
  final FarmingType? farmingType;
  @override
  final String? giTagId;
  @override
  final IrrigationSource? irrigationSource;
  @override
  final String? landRecordRef;
  @override
  final GeoPoint? pin;
  @override
  final PinMethod? pinMethod;
  @override
  final String? reasonCode;
  @override
  final String? reasonText;
  @override
  final PlotCorrectionReviewMethodEnum? reviewMethod;
  @override
  final PlotCorrectionReviewOutcomeEnum? reviewOutcome;
  @override
  final String? soilType;
  @override
  final PolygonGeoJSON? walkedBoundary;

  factory _$PlotCorrection([void Function(PlotCorrectionBuilder)? updates]) =>
      (PlotCorrectionBuilder()..update(updates))._build();

  _$PlotCorrection._(
      {this.declaredArea,
      this.farmingType,
      this.giTagId,
      this.irrigationSource,
      this.landRecordRef,
      this.pin,
      this.pinMethod,
      this.reasonCode,
      this.reasonText,
      this.reviewMethod,
      this.reviewOutcome,
      this.soilType,
      this.walkedBoundary})
      : super._();
  @override
  PlotCorrection rebuild(void Function(PlotCorrectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlotCorrectionBuilder toBuilder() => PlotCorrectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlotCorrection &&
        declaredArea == other.declaredArea &&
        farmingType == other.farmingType &&
        giTagId == other.giTagId &&
        irrigationSource == other.irrigationSource &&
        landRecordRef == other.landRecordRef &&
        pin == other.pin &&
        pinMethod == other.pinMethod &&
        reasonCode == other.reasonCode &&
        reasonText == other.reasonText &&
        reviewMethod == other.reviewMethod &&
        reviewOutcome == other.reviewOutcome &&
        soilType == other.soilType &&
        walkedBoundary == other.walkedBoundary;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, declaredArea.hashCode);
    _$hash = $jc(_$hash, farmingType.hashCode);
    _$hash = $jc(_$hash, giTagId.hashCode);
    _$hash = $jc(_$hash, irrigationSource.hashCode);
    _$hash = $jc(_$hash, landRecordRef.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, pinMethod.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, reasonText.hashCode);
    _$hash = $jc(_$hash, reviewMethod.hashCode);
    _$hash = $jc(_$hash, reviewOutcome.hashCode);
    _$hash = $jc(_$hash, soilType.hashCode);
    _$hash = $jc(_$hash, walkedBoundary.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlotCorrection')
          ..add('declaredArea', declaredArea)
          ..add('farmingType', farmingType)
          ..add('giTagId', giTagId)
          ..add('irrigationSource', irrigationSource)
          ..add('landRecordRef', landRecordRef)
          ..add('pin', pin)
          ..add('pinMethod', pinMethod)
          ..add('reasonCode', reasonCode)
          ..add('reasonText', reasonText)
          ..add('reviewMethod', reviewMethod)
          ..add('reviewOutcome', reviewOutcome)
          ..add('soilType', soilType)
          ..add('walkedBoundary', walkedBoundary))
        .toString();
  }
}

class PlotCorrectionBuilder
    implements Builder<PlotCorrection, PlotCorrectionBuilder> {
  _$PlotCorrection? _$v;

  QuantityInputBuilder? _declaredArea;
  QuantityInputBuilder get declaredArea =>
      _$this._declaredArea ??= QuantityInputBuilder();
  set declaredArea(QuantityInputBuilder? declaredArea) =>
      _$this._declaredArea = declaredArea;

  FarmingType? _farmingType;
  FarmingType? get farmingType => _$this._farmingType;
  set farmingType(FarmingType? farmingType) =>
      _$this._farmingType = farmingType;

  String? _giTagId;
  String? get giTagId => _$this._giTagId;
  set giTagId(String? giTagId) => _$this._giTagId = giTagId;

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

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _reasonText;
  String? get reasonText => _$this._reasonText;
  set reasonText(String? reasonText) => _$this._reasonText = reasonText;

  PlotCorrectionReviewMethodEnum? _reviewMethod;
  PlotCorrectionReviewMethodEnum? get reviewMethod => _$this._reviewMethod;
  set reviewMethod(PlotCorrectionReviewMethodEnum? reviewMethod) =>
      _$this._reviewMethod = reviewMethod;

  PlotCorrectionReviewOutcomeEnum? _reviewOutcome;
  PlotCorrectionReviewOutcomeEnum? get reviewOutcome => _$this._reviewOutcome;
  set reviewOutcome(PlotCorrectionReviewOutcomeEnum? reviewOutcome) =>
      _$this._reviewOutcome = reviewOutcome;

  String? _soilType;
  String? get soilType => _$this._soilType;
  set soilType(String? soilType) => _$this._soilType = soilType;

  PolygonGeoJSONBuilder? _walkedBoundary;
  PolygonGeoJSONBuilder get walkedBoundary =>
      _$this._walkedBoundary ??= PolygonGeoJSONBuilder();
  set walkedBoundary(PolygonGeoJSONBuilder? walkedBoundary) =>
      _$this._walkedBoundary = walkedBoundary;

  PlotCorrectionBuilder() {
    PlotCorrection._defaults(this);
  }

  PlotCorrectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _declaredArea = $v.declaredArea?.toBuilder();
      _farmingType = $v.farmingType;
      _giTagId = $v.giTagId;
      _irrigationSource = $v.irrigationSource;
      _landRecordRef = $v.landRecordRef;
      _pin = $v.pin?.toBuilder();
      _pinMethod = $v.pinMethod;
      _reasonCode = $v.reasonCode;
      _reasonText = $v.reasonText;
      _reviewMethod = $v.reviewMethod;
      _reviewOutcome = $v.reviewOutcome;
      _soilType = $v.soilType;
      _walkedBoundary = $v.walkedBoundary?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlotCorrection other) {
    _$v = other as _$PlotCorrection;
  }

  @override
  void update(void Function(PlotCorrectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlotCorrection build() => _build();

  _$PlotCorrection _build() {
    _$PlotCorrection _$result;
    try {
      _$result = _$v ??
          _$PlotCorrection._(
            declaredArea: _declaredArea?.build(),
            farmingType: farmingType,
            giTagId: giTagId,
            irrigationSource: irrigationSource,
            landRecordRef: landRecordRef,
            pin: _pin?.build(),
            pinMethod: pinMethod,
            reasonCode: reasonCode,
            reasonText: reasonText,
            reviewMethod: reviewMethod,
            reviewOutcome: reviewOutcome,
            soilType: soilType,
            walkedBoundary: _walkedBoundary?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declaredArea';
        _declaredArea?.build();

        _$failedField = 'pin';
        _pin?.build();

        _$failedField = 'walkedBoundary';
        _walkedBoundary?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlotCorrection', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
