// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gi_region_version_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GiRegionVersionOut extends GiRegionVersionOut {
  @override
  final String confidence;
  @override
  final Date effectiveFrom;
  @override
  final String giTagId;
  @override
  final String id;
  @override
  final String licence;
  @override
  final String sourceRef;
  @override
  final BuiltList<String>? taluks;
  @override
  final String toleranceBufferM;
  @override
  final int versionNo;

  factory _$GiRegionVersionOut(
          [void Function(GiRegionVersionOutBuilder)? updates]) =>
      (GiRegionVersionOutBuilder()..update(updates))._build();

  _$GiRegionVersionOut._(
      {required this.confidence,
      required this.effectiveFrom,
      required this.giTagId,
      required this.id,
      required this.licence,
      required this.sourceRef,
      this.taluks,
      required this.toleranceBufferM,
      required this.versionNo})
      : super._();
  @override
  GiRegionVersionOut rebuild(
          void Function(GiRegionVersionOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GiRegionVersionOutBuilder toBuilder() =>
      GiRegionVersionOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GiRegionVersionOut &&
        confidence == other.confidence &&
        effectiveFrom == other.effectiveFrom &&
        giTagId == other.giTagId &&
        id == other.id &&
        licence == other.licence &&
        sourceRef == other.sourceRef &&
        taluks == other.taluks &&
        toleranceBufferM == other.toleranceBufferM &&
        versionNo == other.versionNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, giTagId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, licence.hashCode);
    _$hash = $jc(_$hash, sourceRef.hashCode);
    _$hash = $jc(_$hash, taluks.hashCode);
    _$hash = $jc(_$hash, toleranceBufferM.hashCode);
    _$hash = $jc(_$hash, versionNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GiRegionVersionOut')
          ..add('confidence', confidence)
          ..add('effectiveFrom', effectiveFrom)
          ..add('giTagId', giTagId)
          ..add('id', id)
          ..add('licence', licence)
          ..add('sourceRef', sourceRef)
          ..add('taluks', taluks)
          ..add('toleranceBufferM', toleranceBufferM)
          ..add('versionNo', versionNo))
        .toString();
  }
}

class GiRegionVersionOutBuilder
    implements Builder<GiRegionVersionOut, GiRegionVersionOutBuilder> {
  _$GiRegionVersionOut? _$v;

  String? _confidence;
  String? get confidence => _$this._confidence;
  set confidence(String? confidence) => _$this._confidence = confidence;

  Date? _effectiveFrom;
  Date? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(Date? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  String? _giTagId;
  String? get giTagId => _$this._giTagId;
  set giTagId(String? giTagId) => _$this._giTagId = giTagId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _licence;
  String? get licence => _$this._licence;
  set licence(String? licence) => _$this._licence = licence;

  String? _sourceRef;
  String? get sourceRef => _$this._sourceRef;
  set sourceRef(String? sourceRef) => _$this._sourceRef = sourceRef;

  ListBuilder<String>? _taluks;
  ListBuilder<String> get taluks => _$this._taluks ??= ListBuilder<String>();
  set taluks(ListBuilder<String>? taluks) => _$this._taluks = taluks;

  String? _toleranceBufferM;
  String? get toleranceBufferM => _$this._toleranceBufferM;
  set toleranceBufferM(String? toleranceBufferM) =>
      _$this._toleranceBufferM = toleranceBufferM;

  int? _versionNo;
  int? get versionNo => _$this._versionNo;
  set versionNo(int? versionNo) => _$this._versionNo = versionNo;

  GiRegionVersionOutBuilder() {
    GiRegionVersionOut._defaults(this);
  }

  GiRegionVersionOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _confidence = $v.confidence;
      _effectiveFrom = $v.effectiveFrom;
      _giTagId = $v.giTagId;
      _id = $v.id;
      _licence = $v.licence;
      _sourceRef = $v.sourceRef;
      _taluks = $v.taluks?.toBuilder();
      _toleranceBufferM = $v.toleranceBufferM;
      _versionNo = $v.versionNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GiRegionVersionOut other) {
    _$v = other as _$GiRegionVersionOut;
  }

  @override
  void update(void Function(GiRegionVersionOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GiRegionVersionOut build() => _build();

  _$GiRegionVersionOut _build() {
    _$GiRegionVersionOut _$result;
    try {
      _$result = _$v ??
          _$GiRegionVersionOut._(
            confidence: BuiltValueNullFieldError.checkNotNull(
                confidence, r'GiRegionVersionOut', 'confidence'),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'GiRegionVersionOut', 'effectiveFrom'),
            giTagId: BuiltValueNullFieldError.checkNotNull(
                giTagId, r'GiRegionVersionOut', 'giTagId'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GiRegionVersionOut', 'id'),
            licence: BuiltValueNullFieldError.checkNotNull(
                licence, r'GiRegionVersionOut', 'licence'),
            sourceRef: BuiltValueNullFieldError.checkNotNull(
                sourceRef, r'GiRegionVersionOut', 'sourceRef'),
            taluks: _taluks?.build(),
            toleranceBufferM: BuiltValueNullFieldError.checkNotNull(
                toleranceBufferM, r'GiRegionVersionOut', 'toleranceBufferM'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'GiRegionVersionOut', 'versionNo'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taluks';
        _taluks?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GiRegionVersionOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
