// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LotOut extends LotOut {
  @override
  final String code;
  @override
  final String cropId;
  @override
  final String farmerId;
  @override
  final bool giEligible;
  @override
  final String? giHoldReason;
  @override
  final QuantityOutput? harvested;
  @override
  final String id;
  @override
  final QuantityOutput? packed;
  @override
  final String plotId;
  @override
  final PracticeTags? practiceTags;
  @override
  final DateTime? readyAt;
  @override
  final String seasonLabel;
  @override
  final LotStatus status;

  factory _$LotOut([void Function(LotOutBuilder)? updates]) =>
      (LotOutBuilder()..update(updates))._build();

  _$LotOut._(
      {required this.code,
      required this.cropId,
      required this.farmerId,
      required this.giEligible,
      this.giHoldReason,
      this.harvested,
      required this.id,
      this.packed,
      required this.plotId,
      this.practiceTags,
      this.readyAt,
      required this.seasonLabel,
      required this.status})
      : super._();
  @override
  LotOut rebuild(void Function(LotOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LotOutBuilder toBuilder() => LotOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LotOut &&
        code == other.code &&
        cropId == other.cropId &&
        farmerId == other.farmerId &&
        giEligible == other.giEligible &&
        giHoldReason == other.giHoldReason &&
        harvested == other.harvested &&
        id == other.id &&
        packed == other.packed &&
        plotId == other.plotId &&
        practiceTags == other.practiceTags &&
        readyAt == other.readyAt &&
        seasonLabel == other.seasonLabel &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, cropId.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, giEligible.hashCode);
    _$hash = $jc(_$hash, giHoldReason.hashCode);
    _$hash = $jc(_$hash, harvested.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jc(_$hash, plotId.hashCode);
    _$hash = $jc(_$hash, practiceTags.hashCode);
    _$hash = $jc(_$hash, readyAt.hashCode);
    _$hash = $jc(_$hash, seasonLabel.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LotOut')
          ..add('code', code)
          ..add('cropId', cropId)
          ..add('farmerId', farmerId)
          ..add('giEligible', giEligible)
          ..add('giHoldReason', giHoldReason)
          ..add('harvested', harvested)
          ..add('id', id)
          ..add('packed', packed)
          ..add('plotId', plotId)
          ..add('practiceTags', practiceTags)
          ..add('readyAt', readyAt)
          ..add('seasonLabel', seasonLabel)
          ..add('status', status))
        .toString();
  }
}

class LotOutBuilder implements Builder<LotOut, LotOutBuilder> {
  _$LotOut? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _cropId;
  String? get cropId => _$this._cropId;
  set cropId(String? cropId) => _$this._cropId = cropId;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  bool? _giEligible;
  bool? get giEligible => _$this._giEligible;
  set giEligible(bool? giEligible) => _$this._giEligible = giEligible;

  String? _giHoldReason;
  String? get giHoldReason => _$this._giHoldReason;
  set giHoldReason(String? giHoldReason) => _$this._giHoldReason = giHoldReason;

  QuantityOutputBuilder? _harvested;
  QuantityOutputBuilder get harvested =>
      _$this._harvested ??= QuantityOutputBuilder();
  set harvested(QuantityOutputBuilder? harvested) =>
      _$this._harvested = harvested;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  QuantityOutputBuilder? _packed;
  QuantityOutputBuilder get packed =>
      _$this._packed ??= QuantityOutputBuilder();
  set packed(QuantityOutputBuilder? packed) => _$this._packed = packed;

  String? _plotId;
  String? get plotId => _$this._plotId;
  set plotId(String? plotId) => _$this._plotId = plotId;

  PracticeTagsBuilder? _practiceTags;
  PracticeTagsBuilder get practiceTags =>
      _$this._practiceTags ??= PracticeTagsBuilder();
  set practiceTags(PracticeTagsBuilder? practiceTags) =>
      _$this._practiceTags = practiceTags;

  DateTime? _readyAt;
  DateTime? get readyAt => _$this._readyAt;
  set readyAt(DateTime? readyAt) => _$this._readyAt = readyAt;

  String? _seasonLabel;
  String? get seasonLabel => _$this._seasonLabel;
  set seasonLabel(String? seasonLabel) => _$this._seasonLabel = seasonLabel;

  LotStatus? _status;
  LotStatus? get status => _$this._status;
  set status(LotStatus? status) => _$this._status = status;

  LotOutBuilder() {
    LotOut._defaults(this);
  }

  LotOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _cropId = $v.cropId;
      _farmerId = $v.farmerId;
      _giEligible = $v.giEligible;
      _giHoldReason = $v.giHoldReason;
      _harvested = $v.harvested?.toBuilder();
      _id = $v.id;
      _packed = $v.packed?.toBuilder();
      _plotId = $v.plotId;
      _practiceTags = $v.practiceTags?.toBuilder();
      _readyAt = $v.readyAt;
      _seasonLabel = $v.seasonLabel;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LotOut other) {
    _$v = other as _$LotOut;
  }

  @override
  void update(void Function(LotOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LotOut build() => _build();

  _$LotOut _build() {
    _$LotOut _$result;
    try {
      _$result = _$v ??
          _$LotOut._(
            code:
                BuiltValueNullFieldError.checkNotNull(code, r'LotOut', 'code'),
            cropId: BuiltValueNullFieldError.checkNotNull(
                cropId, r'LotOut', 'cropId'),
            farmerId: BuiltValueNullFieldError.checkNotNull(
                farmerId, r'LotOut', 'farmerId'),
            giEligible: BuiltValueNullFieldError.checkNotNull(
                giEligible, r'LotOut', 'giEligible'),
            giHoldReason: giHoldReason,
            harvested: _harvested?.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'LotOut', 'id'),
            packed: _packed?.build(),
            plotId: BuiltValueNullFieldError.checkNotNull(
                plotId, r'LotOut', 'plotId'),
            practiceTags: _practiceTags?.build(),
            readyAt: readyAt,
            seasonLabel: BuiltValueNullFieldError.checkNotNull(
                seasonLabel, r'LotOut', 'seasonLabel'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'LotOut', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'harvested';
        _harvested?.build();

        _$failedField = 'packed';
        _packed?.build();

        _$failedField = 'practiceTags';
        _practiceTags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LotOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
