// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gi_region_version_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GiRegionVersionInConfidenceEnum
    _$giRegionVersionInConfidenceEnum_official =
    const GiRegionVersionInConfidenceEnum._('official');
const GiRegionVersionInConfidenceEnum
    _$giRegionVersionInConfidenceEnum_districtDerived =
    const GiRegionVersionInConfidenceEnum._('districtDerived');
const GiRegionVersionInConfidenceEnum
    _$giRegionVersionInConfidenceEnum_fixture =
    const GiRegionVersionInConfidenceEnum._('fixture');

GiRegionVersionInConfidenceEnum _$giRegionVersionInConfidenceEnumValueOf(
    String name) {
  switch (name) {
    case 'official':
      return _$giRegionVersionInConfidenceEnum_official;
    case 'districtDerived':
      return _$giRegionVersionInConfidenceEnum_districtDerived;
    case 'fixture':
      return _$giRegionVersionInConfidenceEnum_fixture;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GiRegionVersionInConfidenceEnum>
    _$giRegionVersionInConfidenceEnumValues = BuiltSet<
        GiRegionVersionInConfidenceEnum>(const <GiRegionVersionInConfidenceEnum>[
  _$giRegionVersionInConfidenceEnum_official,
  _$giRegionVersionInConfidenceEnum_districtDerived,
  _$giRegionVersionInConfidenceEnum_fixture,
]);

Serializer<GiRegionVersionInConfidenceEnum>
    _$giRegionVersionInConfidenceEnumSerializer =
    _$GiRegionVersionInConfidenceEnumSerializer();

class _$GiRegionVersionInConfidenceEnumSerializer
    implements PrimitiveSerializer<GiRegionVersionInConfidenceEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'official': 'official',
    'districtDerived': 'district_derived',
    'fixture': 'fixture',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'official': 'official',
    'district_derived': 'districtDerived',
    'fixture': 'fixture',
  };

  @override
  final Iterable<Type> types = const <Type>[GiRegionVersionInConfidenceEnum];
  @override
  final String wireName = 'GiRegionVersionInConfidenceEnum';

  @override
  Object serialize(
          Serializers serializers, GiRegionVersionInConfidenceEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GiRegionVersionInConfidenceEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GiRegionVersionInConfidenceEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GiRegionVersionIn extends GiRegionVersionIn {
  @override
  final String attribution;
  @override
  final GiRegionVersionInConfidenceEnum confidence;
  @override
  final Date? effectiveFrom;
  @override
  final MultiPolygonGeoJSON geometry;
  @override
  final String licence;
  @override
  final bool shareAlike;
  @override
  final String sourceRef;
  @override
  final BuiltList<String> taluks;
  @override
  final ToleranceBufferM toleranceBufferM;

  factory _$GiRegionVersionIn(
          [void Function(GiRegionVersionInBuilder)? updates]) =>
      (GiRegionVersionInBuilder()..update(updates))._build();

  _$GiRegionVersionIn._(
      {required this.attribution,
      required this.confidence,
      this.effectiveFrom,
      required this.geometry,
      required this.licence,
      required this.shareAlike,
      required this.sourceRef,
      required this.taluks,
      required this.toleranceBufferM})
      : super._();
  @override
  GiRegionVersionIn rebuild(void Function(GiRegionVersionInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GiRegionVersionInBuilder toBuilder() =>
      GiRegionVersionInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GiRegionVersionIn &&
        attribution == other.attribution &&
        confidence == other.confidence &&
        effectiveFrom == other.effectiveFrom &&
        geometry == other.geometry &&
        licence == other.licence &&
        shareAlike == other.shareAlike &&
        sourceRef == other.sourceRef &&
        taluks == other.taluks &&
        toleranceBufferM == other.toleranceBufferM;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attribution.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, geometry.hashCode);
    _$hash = $jc(_$hash, licence.hashCode);
    _$hash = $jc(_$hash, shareAlike.hashCode);
    _$hash = $jc(_$hash, sourceRef.hashCode);
    _$hash = $jc(_$hash, taluks.hashCode);
    _$hash = $jc(_$hash, toleranceBufferM.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GiRegionVersionIn')
          ..add('attribution', attribution)
          ..add('confidence', confidence)
          ..add('effectiveFrom', effectiveFrom)
          ..add('geometry', geometry)
          ..add('licence', licence)
          ..add('shareAlike', shareAlike)
          ..add('sourceRef', sourceRef)
          ..add('taluks', taluks)
          ..add('toleranceBufferM', toleranceBufferM))
        .toString();
  }
}

class GiRegionVersionInBuilder
    implements Builder<GiRegionVersionIn, GiRegionVersionInBuilder> {
  _$GiRegionVersionIn? _$v;

  String? _attribution;
  String? get attribution => _$this._attribution;
  set attribution(String? attribution) => _$this._attribution = attribution;

  GiRegionVersionInConfidenceEnum? _confidence;
  GiRegionVersionInConfidenceEnum? get confidence => _$this._confidence;
  set confidence(GiRegionVersionInConfidenceEnum? confidence) =>
      _$this._confidence = confidence;

  Date? _effectiveFrom;
  Date? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(Date? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  MultiPolygonGeoJSONBuilder? _geometry;
  MultiPolygonGeoJSONBuilder get geometry =>
      _$this._geometry ??= MultiPolygonGeoJSONBuilder();
  set geometry(MultiPolygonGeoJSONBuilder? geometry) =>
      _$this._geometry = geometry;

  String? _licence;
  String? get licence => _$this._licence;
  set licence(String? licence) => _$this._licence = licence;

  bool? _shareAlike;
  bool? get shareAlike => _$this._shareAlike;
  set shareAlike(bool? shareAlike) => _$this._shareAlike = shareAlike;

  String? _sourceRef;
  String? get sourceRef => _$this._sourceRef;
  set sourceRef(String? sourceRef) => _$this._sourceRef = sourceRef;

  ListBuilder<String>? _taluks;
  ListBuilder<String> get taluks => _$this._taluks ??= ListBuilder<String>();
  set taluks(ListBuilder<String>? taluks) => _$this._taluks = taluks;

  ToleranceBufferMBuilder? _toleranceBufferM;
  ToleranceBufferMBuilder get toleranceBufferM =>
      _$this._toleranceBufferM ??= ToleranceBufferMBuilder();
  set toleranceBufferM(ToleranceBufferMBuilder? toleranceBufferM) =>
      _$this._toleranceBufferM = toleranceBufferM;

  GiRegionVersionInBuilder() {
    GiRegionVersionIn._defaults(this);
  }

  GiRegionVersionInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attribution = $v.attribution;
      _confidence = $v.confidence;
      _effectiveFrom = $v.effectiveFrom;
      _geometry = $v.geometry.toBuilder();
      _licence = $v.licence;
      _shareAlike = $v.shareAlike;
      _sourceRef = $v.sourceRef;
      _taluks = $v.taluks.toBuilder();
      _toleranceBufferM = $v.toleranceBufferM.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GiRegionVersionIn other) {
    _$v = other as _$GiRegionVersionIn;
  }

  @override
  void update(void Function(GiRegionVersionInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GiRegionVersionIn build() => _build();

  _$GiRegionVersionIn _build() {
    _$GiRegionVersionIn _$result;
    try {
      _$result = _$v ??
          _$GiRegionVersionIn._(
            attribution: BuiltValueNullFieldError.checkNotNull(
                attribution, r'GiRegionVersionIn', 'attribution'),
            confidence: BuiltValueNullFieldError.checkNotNull(
                confidence, r'GiRegionVersionIn', 'confidence'),
            effectiveFrom: effectiveFrom,
            geometry: geometry.build(),
            licence: BuiltValueNullFieldError.checkNotNull(
                licence, r'GiRegionVersionIn', 'licence'),
            shareAlike: BuiltValueNullFieldError.checkNotNull(
                shareAlike, r'GiRegionVersionIn', 'shareAlike'),
            sourceRef: BuiltValueNullFieldError.checkNotNull(
                sourceRef, r'GiRegionVersionIn', 'sourceRef'),
            taluks: taluks.build(),
            toleranceBufferM: toleranceBufferM.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'geometry';
        geometry.build();

        _$failedField = 'taluks';
        taluks.build();
        _$failedField = 'toleranceBufferM';
        toleranceBufferM.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GiRegionVersionIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
